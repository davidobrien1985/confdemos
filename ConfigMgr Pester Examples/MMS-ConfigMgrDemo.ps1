Import-Module 'C:\Program Files (x86)\Microsoft Configuration Manager\AdminConsole\bin\ConfigurationManager.psd1'
Push-Location 'cm2:\'

Function New-MMSDemoCollection {
    Param (
        [string]$FolderName,
        [string]$ColName,
        [string]$LimitCollection = 'All Systems'
    )
    If (Get-CMCollection -Name $ColName) {
        Throw 'Collection Exists'
    }
    Else {
        $Collection = New-CMDeviceCollection -Name $ColName -LimitingCollectionName $LimitCollection
        Move-CMObject -FolderPath 'CM2:\DeviceCollection\Regions' -InputObject $Collection
        return $Collection
    }
}

Function New-MMSDemoApplication {
    Param(
        [string]$AppName,
        [string]$MSIPath,
        [string]$MSIName
    )

    If (Get-CMApplication -Name $AppName) { Throw 'Application Exists' }
    elseif (!(Test-Path "$MSIPath\$MSIName")) { Throw "MSI Doesn't Exist" }
    else {
        $ApplicationObject = New-CMApplication -Name $AppName
        $DeploymentTypeHash = @{
            'ApplicationName'=$AppName
            'DeploymentTypeName'="DT - $AppName"
            'MSIInstaller'=$true
            'AutoIdentifyFromInstallationFile'=$true
            'ForceForUnknownPublisher'=$true
            'InstallationProgram'="msiexec /i $MSIName /qn"
            'InstallationFileLocation'=$MSIPath
        }
        $DeploymentType = Add-CMDeploymentType @DeploymentTypeHash
        return $ApplicationObject
    }
}

Function Deploy-MMSDemoApplication {
    Param(
        [string]$AppName,
        [string]$CollectionName
    )
    
}

function MMS-Demo {
    Param(
        [string]$AppName,
        [string]$MSIPath,
        [string]$MSIName,
        [String]$FolderName,
        [string]$CollectionName,
        [string]$LimitCollection = 'All Systems'
    )

    $Collection = New-MMSDemoCollection -FolderName $FolderName -ColName $CollectionName
    $Application = New-MMSDemoApplication -AppName $AppName -MSIPath $MSIPath -MSIName $MSIName
    $Deployment = Deploy-MMSDemoApplication -AppName $AppName -CollectionName $CollectionName
}

