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
}
