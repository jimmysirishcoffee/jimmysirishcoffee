Add-Type -AssemblyName System.Drawing

function Trim-Transparent($imgName) {
    $path = Join-Path "assets" $imgName
    if (-not (Test-Path $path)) {
        Write-Output "File not found: $path"
        return
    }
    
    $bmp = New-Object System.Drawing.Bitmap($path)
    $w = $bmp.Width
    $h = $bmp.Height
    
    $minX = $w
    $maxX = -1
    $minY = $h
    $maxY = -1
    
    # Find bounding box of non-transparent pixels
    for ($y = 0; $y -lt $h; $y++) {
        for ($x = 0; $x -lt $w; $x++) {
            $c = $bmp.GetPixel($x, $y)
            if ($c.A -gt 0) {
                if ($x -lt $minX) { $minX = $x }
                if ($x -gt $maxX) { $maxX = $x }
                if ($y -lt $minY) { $minY = $y }
                if ($y -gt $maxY) { $maxY = $y }
            }
        }
    }
    
    # Check if image is completely transparent
    if ($maxX -lt $minX -or $maxY -lt $minY) {
        Write-Output "Image is fully transparent: $imgName"
        $bmp.Dispose()
        return
    }
    
    $cropW = $maxX - $minX + 1
    $cropH = $maxY - $minY + 1
    
    Write-Output "$imgName Bounding Box: Left=$minX, Top=$minY, Width=$cropW, Height=$cropH"
    
    # Create trimmed bitmap
    $trimmedBmp = New-Object System.Drawing.Bitmap($cropW, $cropH)
    $g = [System.Drawing.Graphics]::FromImage($trimmedBmp)
    $g.DrawImage($bmp, 
        [System.Drawing.Rectangle]::new(0, 0, $cropW, $cropH), 
        [System.Drawing.Rectangle]::new($minX, $minY, $cropW, $cropH), 
        [System.Drawing.GraphicsUnit]::Pixel
    )
    
    $bmp.Dispose()
    $g.Dispose()
    
    # Save over the original transparent PNG
    $trimmedBmp.Save($path, [System.Drawing.Imaging.ImageFormat]::Png)
    $trimmedBmp.Dispose()
    Write-Output "Successfully trimmed and saved $imgName"
}

Trim-Transparent "left_cup_trans.png"
Trim-Transparent "center_cup_trans.png"
Trim-Transparent "right_cup_trans.png"
