Get-AWSPowerShellVersion -ListServiceVersionInfo

Get-AWSRegion # -IncludeChina #-IncludeGovCloud

Get-AWSCredentials -ListProfiles

#Set-AWSCredentials -StoreAs nicconf -AccessKey $accesskey -SecretKey $secretkey

#region create a VM - EC2

$ec2key = New-EC2KeyPair -KeyName mms2016 -ProfileName versent-innovation -Verbose
# show new key in management console

New-EC2SecurityGroup -GroupName mms2016 -Description 'security group for nicconf' -Verbose
Get-EC2SecurityGroup -GroupName mms2016

$cidrBlocks = New-Object 'collections.generic.list[string]'
$cidrBlocks.add('0.0.0.0/0')
$ipPermissions = New-Object Amazon.EC2.Model.IpPermission 
$ipPermissions.IpProtocol = 'tcp' 
$ipPermissions.FromPort = 3389 
$ipPermissions.ToPort = 3389
$ipPermissions.IpRanges = $cidrBlocks
Grant-EC2SecurityGroupIngress -GroupName mms2016 -IpPermissions $ipPermissions

Get-EC2SecurityGroup -GroupName mms2016
#show new Security Group in management console

Get-EC2Image -Owner amazon, self


$platforms = New-Object 'collections.generic.list[string]'
$platforms.add('windows')
$filter = New-Object Amazon.EC2.Model.Filter -Property @{Name = 'platform'; Values = $platforms}

Get-EC2Image -Owner amazon, self -Filter @{Name = 'platform'; Values = 'windows'} # $filter
Get-EC2ImageByName
$ami = Get-EC2ImageByName -Name WINDOWS_2012R2_BASE

$instance = New-EC2Instance -ImageId $ami.ImageId -MinCount 1 -MaxCount 1 -KeyName mms2016 -SecurityGroups mms2016 -InstanceType t1.micro -Verbose | Select-Object -ExpandProperty instances
Get-EC2Instance -Filter @{Name = 'reservation-id'; Value = $instance.reservationID}
(Get-EC2Instance -Filter @{Name = 'reservation-id'; Value = $instance.reservationID}).Instances


Stop-EC2Instance -Instance $instance.InstanceId -Terminate -Force -Verbose
#endregion create a VM - EC2

#region CloudFormation

$CFStackName = 'mms2016'

$param1 = New-Object Amazon.CloudFormation.Model.Parameter
$param1.Key = 'SourceCidrForRDP'
$param1.Value = '0.0.0.0/24'

$param2 = New-Object Amazon.CloudFormation.Model.Parameter -Property @{ParameterKey='KeyName'; ParameterValue='mms2016'}

# create additional objects as needed, then add into the array initializer:
$params = @($param1, $param2)

$cfnstack = New-CFNStack -StackName $CFStackName -TemplateURL https://s3-ap-southeast-2.amazonaws.com/cloudformation-templates-ap-southeast-2/Windows_Roles_And_Features.template -Parameter $params -Verbose

do {
    (Get-CFNStack -StackName $CFStackName -ProfileName versent-innovation).StackStatus
    'Waiting for CloudFormation Stack {0} to be fully provisioned. This might take a few minutes.' -f $CFStackName
    Start-Sleep -Seconds 30
}
while ( (Get-CFNStack -StackName $CFStackName -ProfileName versent-innovation).StackStatus -ine 'CREATE_COMPLETE')

Get-CFNStackResources -StackName $CFStackName
Get-CFNStackResources -StackName $CFStackName | Select-Object LogicalResourceId, ResourceStatus

Get-CFNStackEvent -StackName $CFStackName | Select-Object ResourceType, ResourceStatus

$stackinstance = Get-CFNStackResources -StackName $CFStackName | Where-Object -FilterScript {$PSItem.ResourceType -eq 'AWS::EC2::Instance'}
$instance = Get-EC2Instance -Instance $stackinstance.PhysicalResourceId

$cfntemplate = Get-CFNTemplate -StackName $CFStackName
Get-CFNTemplateSummary -StackName $CFStackName

$url = Measure-CFNTemplateCost -TemplateBody $cfntemplate -Parameter $params
& 'C:\Program Files\Internet Explorer\iexplore.exe' $url

Remove-CFNStack -StackName $CFStackName -WhatIf
#region API

$subscriptionID = '31d39423-6438-4cd9-a203-052634635dd2'
$resourcegroup = 'demos'
$automationaccount = 'nicconf'

$json = 
@'
{
   "properties":{
      "runbook":{
         "name":"New-AwsCFStack"
      },
      "parameters":{
         "CFSTACKNAME":"Scarlett",
         "SOURCECIDRFORRDP":"0.0.0.0/24"
      }
     }
   }
'@

Add-AzureRmAccount
<#
Invoke-restmethod -uri https://management.azure.com/subscriptions/$subscriptionID/rescourceGroups/$resourcegroup/providers/Microsoft.Automation/automationAccounts/$automationaccount/runbooks?api-version=2015-10-31 -Method Get -Verbose

Invoke-RestMethod -Uri https://management.core.windows.net/$subscription/cloudservices -Method Get #-Headers $requestHeader

$guid = [GUID]::NewGuid().ToString()
Invoke-RestMethod -uri https://management.core.windows.net/$subscription/cloudServices/$resourcegroup/resources/automation/~/automationAccounts/$automationaccount/jobs/$($guid)?api-version=2014-12-08 -Method Put -Body $json -Headers $requestHeader
#>
#endregion API

Start-AzureRmAutomationRunbook -Name New-AwsCFStack -Parameters @{SourceCidrForRDP='0.0.0.0/24';CFSTACKNAME='mms2016';AWSKEYNAME='nicconf'} -Wait -AutomationAccountName nicconf -ResourceGroupName demos -Verbose

Start-AzureRmAutomationRunbook -Name Delete-AwsCFStack -Parameters @{CFSTACKNAME='mms2016'} -ResourceGroupName demos -AutomationAccountName nicconf -Wait -Verbose

#endregion CloudFormation