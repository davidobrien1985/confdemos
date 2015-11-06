#!powershell
# This file is part of Ansible
#
# Copyright 2015, David O'Brien <david.obrien@versent.com.au>
#
# Ansible is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Ansible is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Ansible.  If not, see <http://www.gnu.org/licenses/>.

# WANT_JSON
# POWERSHELL_COMMON

Function Test-Key
{
  param (
    [string]$path,
    [string]$key
  )

  if (!(Test-Path $path)) {
    return $false
  }
  if ((Get-ItemProperty $path).$key -eq $null) {
    return $false
  }
  return $true
}

Function Get-FrameworkVersions
{
  $installedFrameworks = @()
  if (Test-Key "HKLM:\Software\Microsoft\NET Framework Setup\NDP\v4\Client" "Install") {
    $installedFrameworks += "4.0c"
    If ((Get-ItemProperty "HKLM:\Software\Microsoft\NET Framework Setup\NDP\v4\Client").Version -like "4.5*") {
      $installedFrameworks += "4.5c"
    }
  }
  If (Test-Key "HKLM:\Software\Microsoft\NET Framework Setup\NDP\v4\Full" "Install") {
    [int32]$intRelease = (Get-ItemProperty "HKLM:\Software\Microsoft\NET Framework Setup\NDP\v4\Full").Release
    Switch ($intRelease)
    {
      "378389" { $installedFrameworks += "4.5" }
      "378675" { $installedFrameworks += "4.5.1" }
      "378758" { $installedFrameworks += "4.5.1" }
    }
  }
  return $installedFrameworks
}

$params = Parse-Args $args;

$result = New-Object psobject @{
  win_zip = New-Object psobject
  changed = $false
}

# Check if all arguments were provided and set defaults for optional params
If ($params.src) {
  $source = $params.src
}
Else {
  Fail-Json $result "mising required argument: src"
}
If ($params.force) {
  $force = $params.force | ConvertTo-Bool
}
Else {
  $force = $false
}

if ($params.dest) {
  $destination = $params.dest
}
else {
  Fail-Json $result "mising required argument: dest"
}

# Check .Net version -ge 4.5
If (! (Get-FrameworkVersions) -contains '4.5') {
  Fail-Json $result "dotnet Framework 4.5 is required for this module to run."
}

# Check if source actually exist
if (! (Test-Path -Path $source)) {
  Fail-Json $result "Source $source does not exist"
}

# Check if the backupfolder already exists, if not, create it
if (-not (Test-Path -Path 'C:\Windows\Temp\Backup')) {
  try {
    New-Item -Path 'C:\Windows\Temp\Backup' -ItemType Directory -Force
  }
  catch {
    Fail-Json $result 'Failed to create C:\Windows\Temp\Backup folder.'
  }
}

# Check if zip file already exists
if (Test-Path -Path $destination) {
  if (-not ($force)) {
    try {
      $bakdestination = $destination.ToString().Replace(".zip",".bak")
      Copy-Item -Path $destination -Destination $bakdestination
    }
    catch {
      Fail-Json $result 'Failed to create a copy of the existing backup.'
    }
  }
}

# Copy the source to a temporary Backup folder, then zip that folder
if (Test-Path -Path $source -PathType Container) {
  try {
    Copy-Item -Path $source -Destination 'C:\Windows\Temp\Backup' -Recurse -Force
  }
  catch {
    Fail-Json $result 'Failed to copy the source to the backup folder.'
  }
}
else {
  try {
    Copy-Item -Path $source -Destination 'C:\Windows\Temp\Backup' -Force
  }
  catch {
    Fail-Json $result 'Failed to copy the source to the backup folder.'
  }
}

# compress the folder
$sourceFolder = 'C:\Windows\Temp\Backup'

try {
  Remove-Item -Path $destination -Force
  $null = [Reflection.Assembly]::LoadWithPartialName( "System.IO.Compression.FileSystem" )
  [System.IO.Compression.ZipFile]::CreateFromDirectory($sourceFolder, $destination)
}
catch {
  Fail-Json $result 'Something went wrong packing the backup.'
}

# cleanup after yourself
Remove-Item -Path 'C:\Windows\Temp\Backup' -Recurse -Force

Set-Attr $result.win_zip 'src' $source.ToString()
Set-Attr $result.win_zip 'dest' $destination.ToString()

Exit-Json $result;
