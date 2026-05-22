Add-Type -AssemblyName System.Drawing

function Trim-TransparentPadding($inputPath, $outputPath) {
    if (-not (Test-Path $inputPath)) {
        Write-Output "File not found: $inputPath"
        return
    }
    
    $bmp = New-Object System.Drawing.Bitmap($inputPath)
    $w = $bmp.Width
    $h = $bmp.Height
    
    $minX = $w
    $maxX = 0
    $minY = $h
    $maxY = 0
    
    # Scan for bounding box of non-transparent pixels (Alpha > 5)
    for ($y = 0; $y -lt $h; $y++) {
        for ($x = 0; $x -lt $w; $x++) {
            $c = $bmp.GetPixel($x, $y)
            if ($c.A -gt 5) {
                if ($x -lt $minX) { $minX = $x }
                if ($x -gt $maxX) { $maxX = $x }
                if ($y -lt $minY) { $minY = $y }
                if ($y -gt $maxY) { $maxY = $y }
            }
        }
    }
    
    if ($minX -ge $maxX -or $minY -ge $maxY) {
        # If image is empty or fully transparent, copy original
        $bmp.Save($outputPath, [System.Drawing.Imaging.ImageFormat]::Png)
        Write-Output "Copied unmodified (empty or fully opaque) to $outputPath"
    } else {
        $cropW = $maxX - $minX + 1
        $cropH = $maxY - $minY + 1
        
        $trimmed = New-Object System.Drawing.Bitmap($cropW, $cropH)
        $g = [System.Drawing.Graphics]::FromImage($trimmed)
        $g.Clear([System.Drawing.Color]::Transparent)
        $g.DrawImage($bmp, 0, 0, [System.Drawing.Rectangle]::new($minX, $minY, $cropW, $cropH), [System.Drawing.GraphicsUnit]::Pixel)
        $g.Dispose()
        
        $trimmed.Save($outputPath, [System.Drawing.Imaging.ImageFormat]::Png)
        $trimmed.Dispose()
        Write-Output "Trimmed and saved: $inputPath ($w x $h) -> $outputPath ($cropW x $cropH)"
    }
    
    $bmp.Dispose()
}

Write-Output "=== PROCESSING USER-PROVIDED IMAGES ==="

# Trim and save all 4 target cups
Trim-TransparentPadding "assets/cup.png" "assets/cup_black_lid.png"
Trim-TransparentPadding "assets/Latte.png" "assets/cup_latte_art.png"
Trim-TransparentPadding "assets/icedLatte-removebg-preview.png" "assets/cup_iced_latte.png"
Trim-TransparentPadding "assets/almond-removebg-preview.png" "assets/cup_almond.png"

# Copy to duplicates
Write-Output "`n=== COPYING TO COMPATIBILITY DUPLICATES ==="
Copy-Item "assets/cup_black_lid.png" "assets/left_cup_trans.png" -Force
Copy-Item "assets/cup_latte_art.png" "assets/center_cup_trans.png" -Force
Copy-Item "assets/cup_iced_latte.png" "assets/right_cup_trans.png" -Force

Write-Output "Done! All 4 target cups and compatibility duplicates are updated with the user-provided images!"
