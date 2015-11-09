
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")
. "$here\$sut"
Import-Module 'C:\Program Files (x86)\Microsoft Configuration Manager\AdminConsole\bin\ConfigurationManager.psd1'
Push-Location 'cm2:\'


#Describe "New-MMSDemoCollection" {
#    It "Verifies collection is created" {
#        $Results = New-MMSDemoCollection -FolderName 'Regions' -ColName 'MMSDemoCollection' -LimitCollection 'All Systems'
#        Remove-CMDeviceCollection -InputObject $Results -Force
#        $Results.Name | Should be 'MMSDemoCollection'
#        $Results.LimitToCollectionName | Should be 'All Systems'
#    }
#}

Describe "New-MMSDemoApplication" {
    It "Throws when application exists" {
        Mock Get-CMApplication { return "1" }
        { New-MMSDemoApplication -AppName 'MMSDemoApplication' -MSIPath '\\SomeWeirdPath' -MSIName 'MSIFileName.msi' } `
            | Should Throw 'Application Exists'
    }
    It "Throws when MSI path doesn't exist" {
        Mock Get-CMApplication
        Mock Test-Path { return $false }
        { New-MMSDemoApplication -AppName 'MMSDemoApplication' -MSIPath '\\SomeWeirdPath' -MSIName 'MSIFileName.msi' } `
           | Should Throw "MSI Doesn't Exist"
    }

    It "Makes sure mocks are called" {
        Mock Get-CMApplication
        Mock Test-Path { return $true }
        Mock New-CMApplication
        Mock Add-CMDeploymentType
        New-MMSDemoApplication -AppName 'MMSDemoApplication' -MSIPath '\\SomeWeirdPath' -MSIName 'MSIFileName.msi'
        Assert-MockCalled New-CMApplication -Times 1 -Scope It -ParameterFilter { $Name -eq 'MMSDemoApplication' }
        Assert-MockCalled Add-CMDeploymentType -Scope It -Times 1 -ParameterFilter {
            $ApplicationName -eq 'MMSDemoApplication' -and
            $DeploymentTypeName -eq "DT - MMSDemoApplication"
        }
    }
}
#
Pop-Location
