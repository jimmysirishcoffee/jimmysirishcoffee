Add-Type -AssemblyName System.Drawing

function Check-Asset($filename) {
    $path = Join-Path "assets" $filename
    if (-not (Test-Path $path)) {
        Write-Output "File not found: $path"
        return
    }
    $bmp = New-Object System.Drawing.Bitmap($path)
    $w = $bmp.Width
    $h = $bmp.Height
    
    # Check if it has any transparent pixels (alpha < 255)
    $hasAlpha = $false
    $transparentCount = 0
    $sampleCount = 0
    
    # Sample a few pixels to check transparency
    for ($y = 0; $y -lt $h; $y += [math]::Max(1, [math]::Floor($h/20))) {
        for ($x = 0; $x -lt $w; $x += [math]::Max(1, [math]::Floor($w/20))) {
            $c = $bmp.GetPixel($x, $y)
            $sampleCount++
            if ($c.A -lt 255) {
                $hasAlpha = $true
                $transparentCount++
            }
        }
    }
    
    Write-Output "Image: $filename ($w x $h)"
    Write-Output "  Has transparent alpha channel: $hasAlpha (Sampled transparent: $transparentCount / $sampleCount)"
    $bmp.Dispose()
}

Check-Asset "cup.png"
Check-Asset "Latte.png"
Check-Asset "icedLatte-removebg-preview.png"
Check-Asset "almond-removebg-preview.png"
