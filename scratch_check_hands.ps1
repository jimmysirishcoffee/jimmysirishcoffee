Add-Type -AssemblyName System.Drawing

function Check-Hands-And-Holders($filename) {
    $path = Join-Path "assets" $filename
    if (-not (Test-Path $path)) {
        Write-Output "Not found: $path"
        return
    }
    $bmp = New-Object System.Drawing.Bitmap($path)
    $w = $bmp.Width
    $h = $bmp.Height
    
    # We will search for black glove color (extremely dark: R < 40, G < 40, B < 40)
    # and skin tones (R > 140, G in 90-130, B in 70-110)
    $glovePixels = 0
    $skinPixels = 0
    
    for ($y = 0; $y -lt $h; $y++) {
        for ($x = 0; $x -lt $w; $x++) {
            $c = $bmp.GetPixel($x, $y)
            if ($c.R -lt 40 -and $c.G -lt 40 -and $c.B -lt 40) {
                $glovePixels++
            }
            if ($c.R -gt 140 -and $c.G -ge 90 -and $c.G -le 150 -and $c.B -ge 70 -and $c.B -le 130) {
                $skinPixels++
            }
        }
    }
    
    $glovePct = [math]::Round(($glovePixels / ($w * $h)) * 100, 2)
    $skinPct = [math]::Round(($skinPixels / ($w * $h)) * 100, 2)
    
    Write-Output "Image: $filename"
    Write-Output "  Glove pixels: $glovePct % of image"
    Write-Output "  Skin tone pixels: $skinPct % of image"
    $bmp.Dispose()
}

Check-Hands-And-Holders "reference 1.png"
Check-Hands-And-Holders "reference2.png"
Check-Hands-And-Holders "reference 3.png"
Check-Hands-And-Holders "reference4.png"
