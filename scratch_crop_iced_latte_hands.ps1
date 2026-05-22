Add-Type -AssemblyName System.Drawing

$srcPath = "assets/iced latte.png"
$dstPath = "assets/cup_iced_latte.png"

if (-not (Test-Path $srcPath)) {
    Write-Output "Source not found: $srcPath"
    exit
}

$bmpSrc = New-Object System.Drawing.Bitmap($srcPath)
$w = $bmpSrc.Width
$h = $bmpSrc.Height

# Temporary bitmap to crop and filter the glass
$bmpDst = New-Object System.Drawing.Bitmap($w, $h)
$g = [System.Drawing.Graphics]::FromImage($bmpDst)
$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
$g.Clear([System.Drawing.Color]::Transparent)

# 16-point polygon outlining the straw, brownie, lid and glass body
$points = @(
    [System.Drawing.PointF]::new(268, 240), # Straw top-left
    [System.Drawing.PointF]::new(295, 240), # Straw top-right
    [System.Drawing.PointF]::new(260, 430), # Straw right edge entering brownie
    [System.Drawing.PointF]::new(310, 430), # Brownie top-right
    [System.Drawing.PointF]::new(350, 480), # Brownie right base
    [System.Drawing.PointF]::new(380, 560), # Lid right corner
    [System.Drawing.PointF]::new(385, 600), # Glass body right top
    [System.Drawing.PointF]::new(395, 800), # Glass body right mid
    [System.Drawing.PointF]::new(415, 1150),# Glass base bottom-right
    [System.Drawing.PointF]::new(95, 1150), # Glass base bottom-left
    [System.Drawing.PointF]::new(70, 800),  # Glass body left mid
    [System.Drawing.PointF]::new(45, 600),  # Glass body left top
    [System.Drawing.PointF]::new(55, 560),  # Lid left corner
    [System.Drawing.PointF]::new(120, 480), # Brownie left base
    [System.Drawing.PointF]::new(180, 430), # Brownie top-left
    [System.Drawing.PointF]::new(230, 430)  # Straw left edge entering brownie
)

$path = New-Object System.Drawing.Drawing2D.GraphicsPath
$path.AddPolygon($points)

$g.SetClip($path)
$g.DrawImage($bmpSrc, 0, 0, $w, $h)
$g.ResetClip()

# Programmatic Hand Removal on the glass body (Y > 560)
# Scan pixels and make skin tones transparent
for ($y = 560; $y -lt 1150; $y++) {
    for ($x = 0; $x -lt $w; $x++) {
        $c = $bmpDst.GetPixel($x, $y)
        if ($c.A -eq 0) { continue }
        
        # Skin tone check (bare hand)
        # Skin colors: relatively high R, G < R, B < G
        $isSkin = ($c.R -gt 130 -and $c.G -gt 85 -and $c.B -gt 70 -and ($c.R - $c.G) -gt 25 -and ($c.G - $c.B) -gt 10 -and ($c.R - $c.B) -gt 35)
        
        # Also, check if there are dark outlines of the fingers/shadows that look dirty (dark skin colors)
        $isFingerOutline = ($c.R -gt 80 -and $c.G -gt 50 -and $c.B -gt 40 -and ($c.R - $c.G) -gt 15 -and ($c.G - $c.B) -gt 5 -and $y -gt 650 -and $y -lt 1050 -and ($x -lt 150 -or $x -gt 330))
        
        if ($isSkin -or $isFingerOutline) {
            $bmpDst.SetPixel($x, $y, [System.Drawing.Color]::Transparent)
        }
    }
}

# Create final composited canvas
$canvas = New-Object System.Drawing.Bitmap($w, $h)
$gCanvas = [System.Drawing.Graphics]::FromImage($canvas)
$gCanvas.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
$gCanvas.Clear([System.Drawing.Color]::Transparent)

# Glass body polygon to fill with beautiful layered iced-latte gradient
$glassBodyPoints = @(
    [System.Drawing.PointF]::new(45, 600),
    [System.Drawing.PointF]::new(385, 600),
    [System.Drawing.PointF]::new(395, 800),
    [System.Drawing.PointF]::new(415, 1150),
    [System.Drawing.PointF]::new(95, 1150),
    [System.Drawing.PointF]::new(70, 800)
)
$glassBodyPath = New-Object System.Drawing.Drawing2D.GraphicsPath
$glassBodyPath.AddPolygon($glassBodyPoints)

# Create a beautiful layered coffee gradient: dark espresso at the top swirling into creamy milk
$rectGlass = [System.Drawing.RectangleF]::new(45, 600, 370, 550)
$blendGlass = New-Object System.Drawing.Drawing2D.ColorBlend
$blendGlass.Colors = @(
    [System.Drawing.Color]::FromArgb(90, 60, 40),    # Dark espresso top layer
    [System.Drawing.Color]::FromArgb(190, 150, 110), # Swirling coffee middle
    [System.Drawing.Color]::FromArgb(240, 220, 195), # Creamy milk bottom-middle
    [System.Drawing.Color]::FromArgb(210, 175, 135), # Warm latte base
    [System.Drawing.Color]::FromArgb(100, 70, 45)    # Dark coffee bottom rim
)
$blendGlass.Positions = @(0.0, 0.25, 0.5, 0.75, 1.0)

$brushGlass = New-Object System.Drawing.Drawing2D.LinearGradientBrush($rectGlass, [System.Drawing.Color]::White, [System.Drawing.Color]::Black, 90.0) # vertical gradient
$brushGlass.InterpolationColors = $blendGlass

# Fill the glass body with the beautiful layered coffee gradient
$gCanvas.FillPath($brushGlass, $glassBodyPath)

# Add some soft decorative white/beige ellipse shapes representing floating ice cubes inside!
$iceBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(40, 255, 255, 255))
$gCanvas.FillRectangle($iceBrush, [System.Drawing.RectangleF]::new(120, 700, 90, 90))
$gCanvas.FillRectangle($iceBrush, [System.Drawing.RectangleF]::new(210, 850, 100, 100))
$gCanvas.FillRectangle($iceBrush, [System.Drawing.RectangleF]::new(100, 950, 80, 80))

# Now overlay the original cropped glass (with hands removed)
$gCanvas.DrawImage($bmpDst, 0, 0, $w, $h)

# Add vertical white glossy reflection highlights to make the glass pop and look highly premium
$glassPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(110, 255, 255, 255), 5)
$gCanvas.DrawLine($glassPen, 85, 620, 110, 1130)

$glassPenRight = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(60, 255, 255, 255), 3)
$gCanvas.DrawLine($glassPenRight, 365, 620, 395, 1130)

# Draw a clean glossy outline around the glass body
$rimPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(65, 255, 255, 255), 2.5)
$gCanvas.DrawPath($rimPen, $glassBodyPath)

# Trim transparent padding
function Trim-TransparentPadding($bmp) {
    $w = $bmp.Width
    $h = $bmp.Height
    $minX = $w; $maxX = 0; $minY = $h; $maxY = 0
    for ($y = 0; $y -lt $h; $y++) {
        for ($x = 0; $x -lt $w; $x++) {
            if ($bmp.GetPixel($x, $y).A -gt 5) {
                if ($x -lt $minX) { $minX = $x }
                if ($x -gt $maxX) { $maxX = $x }
                if ($y -lt $minY) { $minY = $y }
                if ($y -gt $maxY) { $maxY = $y }
            }
        }
    }
    if ($minX -ge $maxX -or $minY -ge $maxY) { return $bmp }
    $cropW = $maxX - $minX + 1
    $cropH = $maxY - $minY + 1
    $trimmed = New-Object System.Drawing.Bitmap($cropW, $cropH)
    $gt = [System.Drawing.Graphics]::FromImage($trimmed)
    $gt.Clear([System.Drawing.Color]::Transparent)
    $gt.DrawImage($bmp, 0, 0, [System.Drawing.Rectangle]::new($minX, $minY, $cropW, $cropH), [System.Drawing.GraphicsUnit]::Pixel)
    $gt.Dispose()
    return $trimmed
}

$trimmedCanvas = Trim-TransparentPadding $canvas
$trimmedCanvas.Save($dstPath, [System.Drawing.Imaging.ImageFormat]::Png)

# Cleanup
$iceBrush.Dispose()
$glassPen.Dispose()
$glassPenRight.Dispose()
$rimPen.Dispose()
$brushGlass.Dispose()
$trimmedCanvas.Dispose()
$canvas.Dispose()
$gCanvas.Dispose()
$bmpDst.Dispose()
$bmpSrc.Dispose()

Write-Output "Successfully removed hands and saved clean iced latte cup to $dstPath!"
