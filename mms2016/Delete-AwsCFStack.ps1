param (
    [Parameter(mandatory=$true)]
    [string]$CFStackName
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
try {
    Remove-CFNStack -StackName $CFStackName -ProfileName AWSProfile -Verbose -Force -ErrorAction Stop
}
catch {
    $errormessage = $_.Exception.Message
    'Removing the CloudFormation Stack {0} failed because of the following error: `n {1}' -f $errormessage, $CFStackName
    throw
}

do {
    'The CloudFormation Stack {0} is currently being deleted. This operation can take a few minutes.' -f $CFStackName
    Start-Sleep -Seconds 30
}
while ((Get-CFNStack -StackName $CFStackName -ProfileName AWSProfile).StackStatus -eq 'DELETE_IN_PROGRESS')

.\Send-SlackMessage.ps1 -message "@david $CFStackName has been deleted."