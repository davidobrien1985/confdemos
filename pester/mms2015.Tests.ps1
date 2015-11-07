param (
    [Parameter(mandatory=$false)]
    [string]$server = 'localhost'
)

Describe "preflight tests"{
    context 'System config' {
        It "Tests Port 80" {
            (Test-NetConnection -ComputerName $server -Port 80).TcpTestSucceeded | Should Be 'True'
        }
        It "Tests Port 5986" {
            (Test-NetConnection -ComputerName $server -Port 5986).TcpTestSucceeded | Should Be 'True'
        }
        It "Server's C:\ partition should have minimum 5GB of free disk space" {
            (Get-WmiObject -Class win32_logicaldisk -ComputerName $server -Filter "DeviceID = 'C:'").FreeSpace/1GB | Should BeGreaterThan 5
        }
    }
    context "OS config" {
        it "Has DotNet 4.5.2 or later installed" {
            ( Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full').version -gt 4.5.51650 | 
                Should be $true
        }
    }
    context "Windows Features" {
        $features = @(
            "Wow64-Support",
            "Powershell",
            "NET-Framework-Core",
            "NET-Framework-45-Core"
        )

        $installed_features = Get-WindowsFeature | Where-Object -Filterscript {$PSItem.Installed}
        foreach($feature in $features)
        {
            it "Has the following feature installed: $feature" {
                $installed_features.name -eq $feature | Should Not BeNullOrEmpty
            }
        }
    }
}