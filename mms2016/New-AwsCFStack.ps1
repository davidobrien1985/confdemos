param (
    [Parameter(mandatory=$true)]
    [string]$CFStackName,
    [Parameter(mandatory=$true)]
    [ValidatePattern('^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])(\/([0-9]|[1-2][0-9]|3[0-2]))$')]
    [string]$SourceCidrForRDP,
    [Parameter(mandatory=$true)]
    [string]$AWSKeyName
)

$VerbosePreference = 'Continue'
# Get creds to access AWS
$AwsCred = Get-AutomationPSCredential -Name 'aws'
$awscloudformationregion = Get-AutomationVariable -Name 'awscloudformationregion'
$AwsAccessKeyId = $AwsCred.UserName
$AwsSecretKey = $AwsCred.GetNetworkCredential().Password

# Set up the environment to access AWS
Set-AWSCredentials -AccessKey $AwsAccessKeyId -SecretKey $AwsSecretKey -StoreAs AWSProfile -Verbose
Set-DefaultAWSRegion -Region $awscloudformationregion

$param1 = New-Object Amazon.CloudFormation.Model.Parameter
$param1.Key = 'SourceCidrForRDP'
$param1.Value = $SourceCidrForRDP

$param2 = New-Object Amazon.CloudFormation.Model.Parameter -Property @{ParameterKey='KeyName'; ParameterValue=$AWSKeyName}

$params = @($param1, $param2)

.\Send-SlackMessage.ps1 -message "$(Get-Date) : Starting to deploy $CFStackName..."

try {
    New-CFNStack -StackName $CFStackName -TemplateURL https://s3-ap-southeast-2.amazonaws.com/cloudformation-templates-ap-southeast-2/Windows_Roles_And_Features.template -Parameter $params -ProfileName AWSProfile -Verbose -ErrorAction Stop
}
catch {
    $errormessage = $_.Exception.Message
    'Creating the CloudFormation Stack {0} failed with the error: `n {1}' -f $CFStackName, $errormessage
	.\Send-SlackMessage.ps1 -message "Creating the CloudFormation Stack $CFStackName failed with the error: `n $errormessage"
}

do {
    (Get-CFNStack -StackName $CFStackName -ProfileName AWSProfile).StackStatus
    'Waiting for CloudFormation Stack {0} to be fully provisioned. This might take a few minutes.' -f $CFStackName
    Start-Sleep -Seconds 30
}
while ( (Get-CFNStack -StackName $CFStackName -ProfileName AWSProfile).StackStatus -ine 'CREATE_COMPLETE')

.\Send-SlackMessage.ps1 -message "$CFStackName has been created."