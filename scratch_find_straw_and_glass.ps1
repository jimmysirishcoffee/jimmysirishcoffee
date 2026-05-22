Add-Type -AssemblyName System.Drawing

$img = "Screenshot 2026-05-20 130848.png"
$path = Join-Path "assets" $img
$bmp = New-Object System.Drawing.Bitmap($path)

Write-Output "=== DETECTING STRAW (Bright Green) ==="
# Bright green is characterized by high Green value compared to Red/Blue
for ($y = 100; $y -lt 600; $y += 20) {
    $greenX = @()
    for ($x = 0; $x -lt $bmp.Width; $x++) {
        $c = $bmp.GetPixel($x, $y)
        # Check if green-ish (e.g. G > 120 and R < 120 and B > 80)
        if ($c.G -gt 120 -and $c.R -lt 100) {
            $greenX += $x
        }
    }
    if ($greenX.Count -gt 0) {
        $avgX = [System.Linq.Enumerable]::Average($greenX)
        $minX = $greenX[0]
        $maxX = $greenX[-1]
        Write-Output "Y=$y : Straw detected from X=$minX to X=$maxX (Center=$avgX)"
    }
}

Write-Output "`n=== DETECTING GLASS EDGES AT DIFFERENT Y LEVES ==="
# Detect glass edge by checking where pixels are different from background
# Background at top-left is very dark: R < 50, G < 50, B < 40
foreach ($y in @(500, 600, 700, 800, 900, 1000, 1100, 1150)) {
    $leftEdge = -1
    $rightEdge = -1
    
    # Scan from left to right for left edge
    for ($x = 0; $x -lt $bmp.Width; $x++) {
        $c = $bmp.GetPixel($x, $y)
        if ($c.R -gt 60 -or $c.G -gt 60 -or $c.B -gt 50) {
            $leftEdge = $x
            break
        }
    }
    
    # Scan from right to left for right edge
    for ($x = $bmp.Width - 1; $x -ge 0; $x--) {
        $c = $bmp.GetPixel($x, $y)
        if ($c.R -gt 60 -or $c.G -gt 60 -or $c.B -gt 50) {
            $rightEdge = $x
            break
        }
    }
    
    Write-Output "Y=$y : Glass body from X=$leftEdge to X=$rightEdge (Width=$($rightEdge - $leftEdge))"
}

$bmp.Dispose()
