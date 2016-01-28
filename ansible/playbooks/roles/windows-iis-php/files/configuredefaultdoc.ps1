if (!(get-webconfiguration -Filter "//defaultDocument/files/*" | where {$_.Value -eq "index.php"}))
{
      Add-WebConfiguration //defaultDocument/files "IIS:\" -atIndex 0 -Value @{value="index.php"} 
}
