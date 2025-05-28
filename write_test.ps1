# $Limit = 100000
$Limit = 10000

try
{
    Remove-Item .\test1.txt
    Remove-Item .\test2.txt
}
catch
{Write-Output "Can't remove what isn't there!"}

$current_time = Get-Date
Write-Output "Timeclock: $current_time"
Write-Output "Out-File Test"

for($i = 1; $i -le $Limit; $i++)
{
    $i | Out-File -Append  -FilePath .\test1.txt
}

$current_time = Get-Date
Write-Output "Timeclock: $current_time"
Write-Output "Out-File Test done, starting Stream Rest"

$Limit = 3000000
$streamWriter = New-Object System.IO.StreamWriter(".\test2.txt")
for($i = 1; $i -le $Limit; $i++)
{
    $streamWriter.WriteLine("$i")
}
$streamWriter.Flush()
$streamWriter.Close()

$current_time = Get-Date
Write-Output "Timeclock: $current_time"