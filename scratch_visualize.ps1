Add-Type -AssemblyName System.Drawing

function Visualize-Image($filename, $rows = 30, $cols = 40) {
    $path = Join-Path "assets" $filename
    if (-not (Test-Path $path)) {
        Write-Output "Not found: $path"
        return
    }
    $bmp = New-Object System.Drawing.Bitmap($path)
    $w = $bmp.Width
    $h = $bmp.Height
    
    Write-Output "=== VISUALIZING $filename ($w x $h) ==="
    
    # Sample background color from top-left corner
    $bgCol = $bmp.GetPixel(5, 5)
    
    for ($y = 0; $y -lt $rows; $y++) {
        $pixelY = [math]::Floor(($y / $rows) * $h)
        $line = ""
        for ($x = 0; $x -lt $cols; $x++) {
            $pixelX = [math]::Floor(($x / $cols) * $w)
            $c = $bmp.GetPixel($pixelX, $pixelY)
            
            # Simple brightness
            $brightness = ($c.R + $c.G + $c.B) / 3
            
            # Simple distance to top-left corner color
            $dist = [math]::Sqrt([math]::Pow($c.R - $bgCol.R, 2) + [math]::Pow($c.G - $bgCol.G, 2) + [math]::Pow($c.B - $bgCol.B, 2))
            
            if ($dist -lt 30) {
                # Very close to background color
                $line += "."
            } else {
                # Different from background
                if ($brightness -lt 80) {
                    $line += "#" # Dark (like coffee cup lid, glove, or dark accents)
                } elseif ($brightness -lt 160) {
                    $line += "x" # Medium
                } else {
                    $line += "o" # Bright (like white paper cup, highlights)
                }
            }
        }
        Write-Output $line
    }
    $bmp.Dispose()
    Write-Output "======================================="
}

Visualize-Image "Screenshot 2026-05-20 130908.png" 35 50
Visualize-Image "Screenshot 2026-05-20 130900.png" 35 50
Visualize-Image "Screenshot 2026-05-20 130848.png" 35 50
