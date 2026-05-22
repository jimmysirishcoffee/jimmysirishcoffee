Add-Type -AssemblyName System.Drawing
$path = "assets/cup_bg.png"
if (Test-Path $path) {
    $bmp = New-Object System.Drawing.Bitmap($path)
    Write-Output "cup_bg.png is: $($bmp.Width)x$($bmp.Height)"
    $bmp.Dispose()
} else {
    Write-Output "Not found"
}
