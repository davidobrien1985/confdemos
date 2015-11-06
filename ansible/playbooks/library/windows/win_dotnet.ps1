#!powershell
# This file is part of Ansible.
#
# Copyright 2014, Paul Durivage <paul.durivage@rackspace.com>
# Changes: David O'Brien <obrien.david@outlook.com>
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

Function Get-FrameworkVersions
{
  $versioninstalled = @()
  $ndpDirectory = 'hklm:\SOFTWARE\Microsoft\NET Framework Setup\NDP\'

  if (Test-Path "$ndpDirectory\v2.0.50727") {
    $versioninstalled += '2.0'
  }

  if (Test-Path "$ndpDirectory\v3.0") {
    $versioninstalled += '3.0'
  }

  if (Test-Path "$ndpDirectory\v3.5") {
    $versioninstalled += '3.5'
  }

  $v4Directory = "$ndpDirectory\v4\Full"
  if (Test-Path $v4Directory) {
    $versioninstalled += '4'
  }
  return $versioninstalled
}

$params = Parse-Args $args;

$result = New-Object psobject @{
  win_dotnet = New-Object psobject
  changed = $false
}

# Check if all arguments were provided and set defaults for optional params
If ($params.src) {
  $source = $params.src
}
Else {
  Fail-Json $result "mising required argument: src"
}
If ($params.version) {
  $version = $params.version
}
Else {
  Fail-Json $result "mising required argument: version"
}

if ($(Get-FrameworkVersions) -contains $version) {
  Exit-Json $result 'Desired dotnet version is already installed. Nothing for us to do here.'
}

if (-not (Test-Path -Path $source)) {
  Fail-Json $result 'Source installer does not exist'
}

# Source is accessible, execute installer
try {
  switch ($version) {
  '2.0' { $proc = Start-Process -FilePath $source -ArgumentList "/c:`"install `"" -Wait -Verbose -PassThru
            $proc.WaitForExit()
        }
  '3.0' { $proc = Start-Process -FilePath $source -ArgumentList " /q /norestart" -Wait -Verbose -PassThru
            $proc.WaitForExit()
        }
  '3.5' { $proc = Start-Process -FilePath $source -ArgumentList "/q /norestart" -Verbose -PassThru
            $proc.WaitForExit()
        }
  '4' { $proc = Start-Process -FilePath $source -ArgumentList "/q /norestart" -Verbose -PassThru
            $proc.WaitForExit()
      }
  }
}
catch {
  $ErrorMessage = $_.Exception.Message
  Fail-Json $result $ErrorMessage
}

$result.changed = $true

Set-Attr $result.win_dotnet 'src' $source.ToString()
Set-Attr $result.win_dotnet 'version' $version.ToString()

Exit-Json $result;
