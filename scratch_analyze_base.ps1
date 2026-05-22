Add-Type -AssemblyName System.Drawing

$img = "Screenshot 2026-05-20 130848.png"
$path = Join-Path "assets" $img
$bmp = New-Object System.Drawing.Bitmap($path)

Write-Output "--- Horizontal scan at Y=1150 (Base) ---"
for ($x = 0; $x -lt $bmp.Width; $x += 10) {
    $c = $bmp.GetPixel($x, 1150)
    Write-Output "X=$x : R=$($c.R) G=$($c.G) B=$($c.B)"
}

$bmp.Dispose()
