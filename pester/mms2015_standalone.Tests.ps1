Function Create-File {
[CmdletBinding(SupportsShouldProcess=$true)]
[OutputType('System.IO.FileInfo')]
param (
    [switch]$Force = $true,
    [Parameter(mandatory=$true)]
    [ValidateSet('File','Directory')]
    [string]$ItemType,
    [Parameter(mandatory=$true)]
    [string]$Path
)
    $file = New-Item @PSBoundParameters
    return $file
}

Describe 'Demo' {
  Context 'File testing' {
  
    It 'creates a file' {
    { New-Item -Path Testdrive:\test.txt -ItemType File } | Should Not throw
    }

    It 'File really exists' {
    { Test-Path -Path Testdrive:\test.txt } | Should Be $true
    }

    $content = 'This is some random content for the dummy file'
    $null = Set-Content -Value $content -Path Testdrive:\test.txt

    It "checks the file's content" {
      'TestDrive:\test.txt' | Should Contain 'This'
    }
  }

  Context 'Mocking' {
    Mock -CommandName New-Item -MockWith {} -Verifiable

    $file = Create-File -Path Testdrive:\bla.txt -ItemType File -Force

    It 'verifies that the command was called' {
        Assert-VerifiableMocks
    }
    It 'checks it has been called only once with correct params' {
        Assert-MockCalled -CommandName New-Item -Times 1 -Scope Context -ParameterFilter {($Path -eq 'Testdrive:\bla.txt') -and ($ItemType -eq 'File')}
    }
  }
  Context 'Functional test' {
    It 'checks the actual output' {
        Mock -CommandName New-Item -MockWith {$file = New-Object -TypeName pscustomobject -Property @{FullName = ''}; $file.FullName = 'Testdrive:\bla.txt'; return $file }

        $file = Create-File -Path Testdrive:\bla.txt -ItemType File -Force
        $file.FullName | Should Be Testdrive:\bla.txt
    }
  }
}