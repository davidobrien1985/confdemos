#param ($Infile,$outfolder)

$infile = "C:\php.zip"
$outfolder = "C:\php"
[System.Reflection.Assembly]::LoadWithPartialName('System.IO.Compression.FileSystem')
[System.IO.Compression.ZipFile]::ExtractToDirectory($Infile,$outfolder)