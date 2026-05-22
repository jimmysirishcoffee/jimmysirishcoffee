Add-Type -AssemblyName System.Drawing
$images = Get-ChildItem -Path "assets" -Filter "*.png"
foreach ($img in $images) {
    $bmp = New-Object System.Drawing.Bitmap($img.FullName)
    Write-Output "Image: $($img.Name) - Width: $($bmp.Width) - Height: $($bmp.Height)"
    $bmp.Dispose()
}
