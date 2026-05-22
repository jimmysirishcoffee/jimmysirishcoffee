Add-Type -AssemblyName System.Drawing

function Visualize-Image($filename, $rows = 20, $cols = 40) {
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
            
            if ($dist -lt 35) {
                $line += "."
            } else {
                if ($brightness -lt 80) {
                    $line += "#"
                } elseif ($brightness -lt 160) {
                    $line += "x"
                } else {
                    $line += "o"
                }
            }
        }
        Write-Output $line
    }
    $bmp.Dispose()
    Write-Output "======================================="
}

Visualize-Image "reference 1.png" 20 40
Visualize-Image "reference 3.png" 20 40
Visualize-Image "reference4.png" 20 40
Visualize-Image "Almond.png" 20 40
