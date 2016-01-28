$installed = Get-WmiObject -Query "Select * from win32_product" | where {$_.name -eq "Microsoft Visual C++ 2012 x64 Additional Runtime - 11.0.61030"}

if ($installed -eq $null)
{
    C:\vcredist_x64.exe /install /passive /norestart
}