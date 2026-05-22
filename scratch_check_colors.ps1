Add-Type -AssemblyName System.Drawing

$images = @(
    "Screenshot 2026-05-20 130908.png",
    "Screenshot 2026-05-20 130900.png",
    "Screenshot 2026-05-20 130848.png"
)

foreach ($img in $images) {
    $path = Join-Path "assets" $img
    if (Test-Path $path) {
        $bmp = New-Object System.Drawing.Bitmap($path)
        $c1 = $bmp.GetPixel(0, 0)
        $c2 = $bmp.GetPixel(10, 10)
        $c3 = $bmp.GetPixel($bmp.Width - 11, 10)
        Write-Output "$img : Width=$($bmp.Width), Height=$($bmp.Height)"
        Write-Output "  Pixel(0,0): R=$($c1.R) G=$($c1.G) B=$($c1.B)"
        Write-Output "  Pixel(10,10): R=$($c2.R) G=$($c2.G) B=$($c2.B)"
        Write-Output "  Pixel(W-10,10): R=$($c3.R) G=$($c3.G) B=$($c3.B)"
        $bmp.Dispose()
    } else {
        Write-Output "Not found: $path"
    }
}
