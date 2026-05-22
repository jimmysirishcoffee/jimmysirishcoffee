Add-Type -AssemblyName System.Drawing
function Check-Image($filename) {
    $path = Join-Path "assets" $filename
    if (-not (Test-Path $path)) {
        Write-Output "Not found: $path"
        return
    }
    $bmp = New-Object System.Drawing.Bitmap($path)
    $w = $bmp.Width
    $h = $bmp.Height
    Write-Output "Image: $filename ($w x $h)"
    $bmp.Dispose()
}
Check-Image "Almond.png"
Check-Image "Latte (2).png"
Check-Image "iced latte.png"
