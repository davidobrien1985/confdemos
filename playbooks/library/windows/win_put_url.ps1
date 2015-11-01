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

$params = Parse-Args $args;

$result = New-Object psobject @{
  win_put_url = New-Object psobject
  changed = $false
}

# Check if all arguments were provided and set defaults for optional params
If ($params.dest) {
  $destination = $params.dest
}
Else {
  Fail-Json $result "mising required argument: dest"
}

If ($params.src) {
  $source = $params.src
}
Else {
  Fail-Json $result "mising required argument: src"
}

If ($params.user_name) {
  $username = $params.user_name
}
Else {
  Fail-Json $result "mising required argument: user_name"
}

If ($params.user_pwd) {
  $userpassword = $params.user_pwd
}
Else {
  Fail-Json $result "mising required argument: user_pwd"
}

# Check if source exists
if (-not (Test-Path -Path $source)) {
  Fail-Json $result "Source $source does not exist."
}

$pair = "$($username):$($userpassword)"
$bytes = [System.Text.Encoding]::ASCII.GetBytes($pair)
$base64 = [System.Convert]::ToBase64String($bytes)
$basicAuthValue = "Basic $base64"
$headers = @{ Authorization = $basicAuthValue }

# Upload the file 
$webClient = New-Object System.Net.WebClient
try {
  Invoke-RestMethod -Uri $NewUrl -Method Put -InFile $source -Headers $headers -Verbose
}
catch {
  $ErrorMessage = $_.Exception.Message
  Fail-Json $result $ErrorMessage
}

Set-Attr $result.win_put_url 'src' $source.ToString()
Set-Attr $result.win_put_url 'dest' $destination.ToString()

Exit-Json $result;