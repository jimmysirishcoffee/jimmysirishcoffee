Add-Type -AssemblyName System.Drawing

$img = "Screenshot 2026-05-20 130848.png"
$path = Join-Path "assets" $img
$bmp = New-Object System.Drawing.Bitmap($path)

Write-Output "Image size: Width=$($bmp.Width), Height=$($bmp.Height)"

# Let's scan a horizontal line at Y = 600 (middle of the glass)
Write-Output "--- Horizontal scan at Y=600 ---"
for ($x = 0; $x -lt $bmp.Width; $x += 15) {
    $c = $bmp.GetPixel($x, 600)
    Write-Output "X=$x : R=$($c.R) G=$($c.G) B=$($c.B)"
}

# Let's scan a vertical line through the middle (X = 240)
Write-Output "--- Vertical scan at X=240 ---"
for ($y = 0; $y -lt $bmp.Height; $y += 30) {
    $c = $bmp.GetPixel(240, $y)
    Write-Output "Y=$y : R=$($c.R) G=$($c.G) B=$($c.B)"
}

$bmp.Dispose()
