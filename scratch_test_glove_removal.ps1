Add-Type -AssemblyName System.Drawing

$srcPath = "assets/reference2.png"
$dstPath = "assets/cup_black_lid_clean.png"

if (-not (Test-Path $srcPath)) {
    Write-Output "Source not found: $srcPath"
    exit
}

$bmpSrc = New-Object System.Drawing.Bitmap($srcPath)
$w = $bmpSrc.Width
$h = $bmpSrc.Height

# Create a temporary bitmap to hold the cropped cup
$bmpCropped = New-Object System.Drawing.Bitmap($w, $h)
$g = [System.Drawing.Graphics]::FromImage($bmpCropped)
$g.Clear([System.Drawing.Color]::Transparent)
$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias

# Use the polygon points for reference2.png cup boundary
$points = @(
    [System.Drawing.PointF]::new(85, 150),
    [System.Drawing.PointF]::new(332, 130),
    [System.Drawing.PointF]::new(580, 150),
    [System.Drawing.PointF]::new(615, 170),
    [System.Drawing.PointF]::new(590, 240),
    [System.Drawing.PointF]::new(560, 250),
    [System.Drawing.PointF]::new(495, 870),
    [System.Drawing.PointF]::new(332, 895),
    [System.Drawing.PointF]::new(170, 870),
    [System.Drawing.PointF]::new(105, 250),
    [System.Drawing.PointF]::new(75, 240),
    [System.Drawing.PointF]::new(50, 170)
)

$path = New-Object System.Drawing.Drawing2D.GraphicsPath
$path.AddPolygon($points)
$g.SetClip($path)
$g.DrawImage($bmpSrc, 0, 0, $w, $h)

# Now, process pixels below the lid (Y > 250) to remove the black glove and skin tones
# The cup body is white/cream, so we can preserve pixels that are bright or have cup color,
# and transparentize pixels that are dark (glove) or skin-colored (hand).
for ($y = 252; $y -lt $h; $y++) {
    for ($x = 0; $x -lt $w; $x++) {
        $c = $bmpCropped.GetPixel($x, $y)
        if ($c.A -eq 0) { continue }
        
        $isGlove = ($c.R -lt 70 -and $c.G -lt 70 -and $c.B -lt 70)
        $isSkin  = ($c.R -gt 100 -and $c.G -gt 60 -and $c.B -gt 45 -and $c.R -gt $c.G -and $c.G -gt $c.B)
        
        # If it's glove or skin tone, make it transparent
        if ($isGlove -or $isSkin) {
            $bmpCropped.SetPixel($x, $y, [System.Drawing.Color]::Transparent)
        }
    }
}

# Save the resulting clean cup image
$bmpCropped.Save($dstPath, [System.Drawing.Imaging.ImageFormat]::Png)

$g.Dispose()
$bmpCropped.Dispose()
$bmpSrc.Dispose()

Write-Output "Done! Cropped and filtered cup saved to $dstPath"
