Add-Type -AssemblyName System.Drawing

function Analyze-Sleeve($filename) {
    $path = Join-Path "assets" $filename
    if (-not (Test-Path $path)) {
        Write-Output "Not found: $path"
        return
    }
    $bmp = New-Object System.Drawing.Bitmap($path)
    $w = $bmp.Width
    $h = $bmp.Height
    
    Write-Output "=== Analyzing $filename ($w x $h) ==="
    
    # We will print the average R,G,B for 10 horizontal slices of the image
    $slices = 10
    for ($i = 0; $i -lt $slices; $i++) {
        $startY = [math]::Floor(($i / $slices) * $h)
        $endY = [math]::Floor((($i + 1) / $slices) * $h)
        
        $sumR = 0; $sumG = 0; $sumB = 0; $count = 0
        
        # Focus on the middle columns (X between 30% and 70%) where the cup lies
        $startX = [math]::Floor($w * 0.3)
        $endX = [math]::Floor($w * 0.7)
        
        for ($y = $startY; $y -lt $endY; $y++) {
            for ($x = $startX; $x -lt $endX; $x++) {
                $c = $bmp.GetPixel($x, $y)
                $sumR += $c.R
                $sumG += $c.G
                $sumB += $c.B
                $count++
            }
        }
        
        $avgR = [math]::Round($sumR / $count)
        $avgG = [math]::Round($sumG / $count)
        $avgB = [math]::Round($sumB / $count)
        
        # Cardboard sleeve is typically brown (R ~ 140-180, G ~ 100-140, B ~ 60-100)
        # Standard white cup is bright (R > 180, G > 180, B > 180)
        # Black lid is dark (R < 80, G < 80, B < 80)
        $label = "Other"
        if ($avgR -gt 180 -and $avgG -gt 180 -and $avgB -gt 180) {
            $label = "White Cup Body"
        } elseif ($avgR -lt 85 -and $avgG -lt 85 -and $avgB -lt 85) {
            $label = "Dark / Black Lid"
        } elseif ($avgR -gt $avgB + 40 -and $avgG -gt $avgB + 20 -and $avgR -gt 120) {
            $label = "Brown Cardboard Sleeve or Coffee"
        }
        
        Write-Output "Slice $i (Y=$startY to $endY): R=$avgR G=$avgG B=$avgB -> $label"
    }
    $bmp.Dispose()
    Write-Output "======================================="
}

Analyze-Sleeve "reference 1.png"
Analyze-Sleeve "reference2.png"
Analyze-Sleeve "reference 3.png"
Analyze-Sleeve "reference4.png"
