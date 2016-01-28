#param ($Infile,$outfolder)

$infile = "C:\wordpress.zip"
$outfolder = "C:\inetpub\wordpress"
[System.Reflection.Assembly]::LoadWithPartialName('System.IO.Compression.FileSystem')
[System.IO.Compression.ZipFile]::ExtractToDirectory($Infile,$outfolder)