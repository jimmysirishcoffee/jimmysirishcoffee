Add-Type -AssemblyName System.Drawing

function Remove-GreenScreen($inputPath, $outputPath) {
    if (-not (Test-Path $inputPath)) {
        Write-Output "File not found: $inputPath"
        return
    }
    
    $bmp = New-Object System.Drawing.Bitmap($inputPath)
    $w = $bmp.Width
    $h = $bmp.Height
    
    $bmpDst = New-Object System.Drawing.Bitmap($w, $h)
    $g = [System.Drawing.Graphics]::FromImage($bmpDst)
    $g.Clear([System.Drawing.Color]::Transparent)
    
    Write-Output "Processing image $inputPath ($w x $h)..."
    
    $removedCount = 0
    $totalCount = $w * $h
    
    for ($y = 0; $y -lt $h; $y++) {
        for ($x = 0; $x -lt $w; $x++) {
            $c = $bmp.GetPixel($x, $y)
            
            # Smart green-screen detection
            # Green should be the dominant color and above a threshold
            # R is red, G is green, B is blue
            $isGreen = ($c.G -gt 90 -and $c.G -gt ($c.R + 25) -and $c.G -gt ($c.B + 25))
            
            # Or very bright lime/neon green
            if (-not $isGreen) {
                $isGreen = ($c.G -gt 150 -and $c.R -lt 120 -and $c.B -lt 120)
            }
            
            if ($isGreen) {
                $bmpDst.SetPixel($x, $y, [System.Drawing.Color]::Transparent)
                $removedCount++
            } else {
                # We can also do a slight edge feathering/anti-aliasing if it's near green
                # For simplicity, let's keep the original pixel
                $bmpDst.SetPixel($x, $y, $c)
            }
        }
    }
    
    # Trim transparent padding
    $minX = $w
    $maxX = 0
    $minY = $h
    $maxY = 0
    
    for ($y = 0; $y -lt $h; $y++) {
        for ($x = 0; $x -lt $w; $x++) {
            $c = $bmpDst.GetPixel($x, $y)
            if ($c.A -gt 5) {
                if ($x -lt $minX) { $minX = $x }
                if ($x -gt $maxX) { $maxX = $x }
                if ($y -lt $minY) { $minY = $y }
                if ($y -gt $maxY) { $maxY = $y }
            }
        }
    }
    
    if ($minX -lt $maxX -and $minY -lt $maxY) {
        $cropW = $maxX - $minX + 1
        $cropH = $maxY - $minY + 1
        $bmpTrimmed = New-Object System.Drawing.Bitmap($cropW, $cropH)
        $gTrim = [System.Drawing.Graphics]::FromImage($bmpTrimmed)
        $gTrim.Clear([System.Drawing.Color]::Transparent)
        $gTrim.DrawImage($bmpDst, 0, 0, [System.Drawing.Rectangle]::new($minX, $minY, $cropW, $cropH), [System.Drawing.GraphicsUnit]::Pixel)
        $gTrim.Dispose()
        
        $bmpTrimmed.Save($outputPath, [System.Drawing.Imaging.ImageFormat]::Png)
        $bmpTrimmed.Dispose()
        Write-Output "Saved trimmed transparent image to $outputPath ($cropW x $cropH)"
    } else {
        $bmpDst.Save($outputPath, [System.Drawing.Imaging.ImageFormat]::Png)
        Write-Output "Saved untrimmed transparent image to $outputPath ($w x $h)"
    }
    
    Write-Output "Removed $removedCount green pixels ($([math]::Round(($removedCount / $totalCount) * 100, 2)) % of image)"
    
    $g.Dispose()
    $bmpDst.Dispose()
    $bmp.Dispose()
}

$inputImg = "C:\Users\herob\.gemini\antigravity\brain\ae89c1dd-a65c-4394-9e20-5c489e696acb\cup_black_lid_green_1779285254061.png"
$outputImg = "assets/cup_black_lid_clean.png"

Remove-GreenScreen $inputImg $outputImg
