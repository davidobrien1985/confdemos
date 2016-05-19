param (
    $message
)

$token = Get-AutomationVariable -Name 'slack_apikey'
$user = Get-AutomationVariable -Name 'slack_username'

$postSlackMessage = @{token=$token;channel='#build_notifications';text=$message;username=$user}
try {
    Invoke-RestMethod -Uri 'https://slack.com/api/chat.postMessage' -Body $postSlackMessage -Erroraction Stop
}
catch {
    'Slack Message unable to be posted with the following error: {0}' -f $_
    exit 1
}