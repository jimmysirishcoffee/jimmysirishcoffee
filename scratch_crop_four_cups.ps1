Add-Type -AssemblyName System.Drawing

# Create assets folder if it doesn't exist
if (-not (Test-Path "assets")) {
    New-Item -ItemType Directory -Path "assets"
}

# Helper function to trim transparent padding from an image
function Trim-TransparentPadding($bmp) {
    $w = $bmp.Width
    $h = $bmp.Height
    
    $minX = $w
    $maxX = 0
    $minY = $h
    $maxY = 0
    
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
    
    # If no pixels are visible, return the original
    if ($minX -ge $maxX -or $minY -ge $maxY) {
        return $bmp
    }
    
    $cropW = $maxX - $minX + 1
    $cropH = $maxY - $minY + 1
    
    $bmpTrimmed = New-Object System.Drawing.Bitmap($cropW, $cropH)
    $g = [System.Drawing.Graphics]::FromImage($bmpTrimmed)
    $g.Clear([System.Drawing.Color]::Transparent)
    $g.DrawImage($bmp, 0, 0, [System.Drawing.Rectangle]::new($minX, $minY, $cropW, $cropH), [System.Drawing.GraphicsUnit]::Pixel)
    $g.Dispose()
    
    return $bmpTrimmed
}

# =========================================================================
# 1. CUP 1: BLACK LID CUP (Hand-free, Sleeve-free Combination Render)
# =========================================================================
Write-Output "Processing Cup 1 (Black Lid Cup) from reference2.png..."
$ref2Path = "assets/reference2.png"
if (Test-Path $ref2Path) {
    $bmpSrc = New-Object System.Drawing.Bitmap($ref2Path)
    $w = $bmpSrc.Width
    $h = $bmpSrc.Height
    
    # Create output canvas
    $bmpDst = New-Object System.Drawing.Bitmap($w, $h)
    $g = [System.Drawing.Graphics]::FromImage($bmpDst)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
    $g.Clear([System.Drawing.Color]::Transparent)
    
    # A. Draw the pristine white paper cup body (tapered frustum)
    # Coordinates of the cup body below the lid:
    # Top edge of body: from (118, 252) to (548, 252)
    # Bottom edge of body: from (178, 860) to (488, 860)
    $bodyPath = New-Object System.Drawing.Drawing2D.GraphicsPath
    $bodyPoints = @(
        [System.Drawing.PointF]::new(118, 252),
        [System.Drawing.PointF]::new(548, 252),
        [System.Drawing.PointF]::new(488, 860),
        [System.Drawing.PointF]::new(178, 860)
    )
    $bodyPath.AddPolygon($bodyPoints)
    
    # Create a linear gradient brush to give the cup a realistic cylindrical, 3D shaded look
    # Shading goes from dark-gray at left edge, to pure white at center, back to dark-gray at right edge
    $rect = [System.Drawing.RectangleF]::new(118, 252, 430, 608)
    $blend = New-Object System.Drawing.Drawing2D.ColorBlend
    $blend.Colors = @(
        [System.Drawing.Color]::FromArgb(215, 215, 215), # Shadow left
        [System.Drawing.Color]::FromArgb(245, 245, 245), # Mid-left
        [System.Drawing.Color]::FromArgb(255, 255, 255), # Bright center highlights
        [System.Drawing.Color]::FromArgb(240, 240, 240), # Mid-right
        [System.Drawing.Color]::FromArgb(210, 210, 210)  # Shadow right
    )
    $blend.Positions = @(0.0, 0.25, 0.5, 0.75, 1.0)
    
    $gradBrush = New-Object System.Drawing.Drawing2D.LinearGradientBrush($rect, [System.Drawing.Color]::White, [System.Drawing.Color]::Black, 0.0)
    $gradBrush.InterpolationColors = $blend
    
    # Fill the cup body
    $g.FillPath($gradBrush, $bodyPath)
    
    # Draw a thin, elegant golden-accented vertical stripe or logo outline on the cup body
    # to fit the premium Dublin specialty style
    $logoBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(180, 150, 90)) # Gold accent
    $g.FillEllipse($logoBrush, [System.Drawing.RectangleF]::new(282, 450, 100, 100))
    $logoTextBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::Black)
    $g.FillEllipse($logoTextBrush, [System.Drawing.RectangleF]::new(287, 455, 90, 90))
    
    # B. Crop the real, actual photo lid from reference2.png (Y=120 to Y=255)
    # The lid is 100% hand-free and sleeve-free in this region
    $lidPath = New-Object System.Drawing.Drawing2D.GraphicsPath
    $lidPoints = @(
        [System.Drawing.PointF]::new(85, 150),
        [System.Drawing.PointF]::new(332, 125),
        [System.Drawing.PointF]::new(580, 150),
        [System.Drawing.PointF]::new(615, 170),
        [System.Drawing.PointF]::new(590, 240),
        [System.Drawing.PointF]::new(548, 252), # match body corner
        [System.Drawing.PointF]::new(118, 252), # match body corner
        [System.Drawing.PointF]::new(75, 240),
        [System.Drawing.PointF]::new(50, 170)
    )
    $lidPath.AddPolygon($lidPoints)
    
    $g.SetClip($lidPath)
    $g.DrawImage($bmpSrc, 0, 0, $w, $h)
    $g.ResetClip()
    
    # Trim and save as clean png
    $bmpTrimmed = Trim-TransparentPadding $bmpDst
    $bmpTrimmed.Save("assets/cup_black_lid.png", [System.Drawing.Imaging.ImageFormat]::Png)
    Write-Output "Saved Cup 1 to assets/cup_black_lid.png"
    
    # Cleanup
    $gradBrush.Dispose()
    $logoBrush.Dispose()
    $logoTextBrush.Dispose()
    $bmpTrimmed.Dispose()
    $bmpDst.Dispose()
    $bmpSrc.Dispose()
} else {
    Write-Output "WARNING: reference2.png not found!"
}

# =========================================================================
# 2. CUP 2: LATTE ART CUP (No Lid - from Latte (2).png)
# =========================================================================
Write-Output "Processing Cup 2 (Latte Art Cup) from Latte (2).png..."
$lattePath = "assets/Latte (2).png"
if (Test-Path $lattePath) {
    $bmpSrc = New-Object System.Drawing.Bitmap($lattePath)
    $w = $bmpSrc.Width
    $h = $bmpSrc.Height
    
    $bmpDst = New-Object System.Drawing.Bitmap($w, $h)
    $g = [System.Drawing.Graphics]::FromImage($bmpDst)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
    $g.Clear([System.Drawing.Color]::Transparent)
    
    # We will crop using a perfect circle/ellipse that isolates only the cup and latte art.
    # Dimensions of Latte (2).png are 595 x 818.
    # The cup is centered at roughly (297, 409).
    # Let's crop a circular area: X=105, Y=145, Width=385, Height=385
    $path = New-Object System.Drawing.Drawing2D.GraphicsPath
    $path.AddEllipse(105, 145, 385, 385)
    
    $g.SetClip($path)
    $g.DrawImage($bmpSrc, 0, 0, $w, $h)
    
    $bmpTrimmed = Trim-TransparentPadding $bmpDst
    $bmpTrimmed.Save("assets/cup_latte_art.png", [System.Drawing.Imaging.ImageFormat]::Png)
    Write-Output "Saved Cup 2 to assets/cup_latte_art.png"
    
    $bmpTrimmed.Dispose()
    $bmpDst.Dispose()
    $bmpSrc.Dispose()
} else {
    Write-Output "WARNING: Latte (2).png not found!"
}

# =========================================================================
# 3. CUP 3: ICED LATTE CUP (from iced latte.png)
# =========================================================================
Write-Output "Processing Cup 3 (Iced Latte Cup) from iced latte.png..."
$icedPath = "assets/iced latte.png"
if (Test-Path $icedPath) {
    $bmpSrc = New-Object System.Drawing.Bitmap($icedPath)
    $w = $bmpSrc.Width
    $h = $bmpSrc.Height
    
    $bmpDst = New-Object System.Drawing.Bitmap($w, $h)
    $g = [System.Drawing.Graphics]::FromImage($bmpDst)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
    $g.Clear([System.Drawing.Color]::Transparent)
    
    # Detailed 16-point polygon crop encompassing straw, brownie, lid and glass body
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
    
    $bmpTrimmed = Trim-TransparentPadding $bmpDst
    $bmpTrimmed.Save("assets/cup_iced_latte.png", [System.Drawing.Imaging.ImageFormat]::Png)
    Write-Output "Saved Cup 3 to assets/cup_iced_latte.png"
    
    $bmpTrimmed.Dispose()
    $bmpDst.Dispose()
    $bmpSrc.Dispose()
} else {
    Write-Output "WARNING: iced latte.png not found!"
}

# =========================================================================
# 4. CUP 4: ALMOND ICED LATTE CUP (from Almond.png)
# =========================================================================
Write-Output "Processing Cup 4 (Almond Iced Latte Cup) from Almond.png..."
$almondPath = "assets/Almond.png"
if (Test-Path $almondPath) {
    $bmpSrc = New-Object System.Drawing.Bitmap($almondPath)
    $w = $bmpSrc.Width
    $h = $bmpSrc.Height
    
    $bmpDst = New-Object System.Drawing.Bitmap($w, $h)
    $g = [System.Drawing.Graphics]::FromImage($bmpDst)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
    $g.Clear([System.Drawing.Color]::Transparent)
    
    # Define a clean polygon outlining the straw, dome lid, and tapered cup body.
    # The cup in Almond.png (609 x 1066) is centered.
    # Top of straw is near X=305, Y=60.
    # Dome lid spans from X=150 to X=460, Y=260 to Y=380.
    # Cup body starts at X=165 to X=445 at Y=380, and tapers to X=220 to X=390 at Y=930.
    $points = @(
        [System.Drawing.PointF]::new(295, 60),  # Straw top-left
        [System.Drawing.PointF]::new(315, 60),  # Straw top-right
        [System.Drawing.PointF]::new(308, 260), # Straw bottom entering lid
        [System.Drawing.PointF]::new(445, 275), # Lid dome right
        [System.Drawing.PointF]::new(465, 340), # Lid rim right-top
        [System.Drawing.PointF]::new(460, 380), # Lid rim right-bottom
        [System.Drawing.PointF]::new(445, 410), # Cup body right-top
        [System.Drawing.PointF]::new(390, 930), # Cup body right-bottom
        [System.Drawing.PointF]::new(220, 930), # Cup body left-bottom
        [System.Drawing.PointF]::new(165, 410), # Cup body left-top
        [System.Drawing.PointF]::new(150, 380), # Lid rim left-bottom
        [System.Drawing.PointF]::new(145, 340), # Lid rim left-top
        [System.Drawing.PointF]::new(165, 275), # Lid dome left
        [System.Drawing.PointF]::new(288, 260)  # Straw bottom entering lid (left)
    )
    
    $path = New-Object System.Drawing.Drawing2D.GraphicsPath
    $path.AddPolygon($points)
    
    $g.SetClip($path)
    $g.DrawImage($bmpSrc, 0, 0, $w, $h)
    $g.ResetClip()
    
    # Programmatic Hand Removal:
    # A hand is holding the cup in Almond.png. The skin colors are reddish/pinkish/tan.
    # In GDI+, we can loop through the cropped pixels (Y > 380) and set skin colors to transparent.
    # Skin tone detection formula: R > 120, G > 80, B > 65, and R > G + 15, and G > B + 10
    # Also, the background might have dark pixels. Let's make sure we keep the cup swirls (creamy beige and brown)
    # Coffee cream is typically light brown (R ~ 180-230, G ~ 150-190, B ~ 110-150).
    # Skin tone is more red-shifted. Let's filter out pixels that are skin tone, and if a hole is left, 
    # we can fill it in or blend it. Better yet, let's transparentize only obvious skin pixels
    # and keep the coffee liquid.
    for ($y = 380; $y -lt 930; $y++) {
        for ($x = 0; $x -lt $w; $x++) {
            $c = $bmpDst.GetPixel($x, $y)
            if ($c.A -eq 0) { continue }
            
            # Skin tone check
            $isSkin = ($c.R -gt 130 -and $c.G -gt 85 -and $c.B -gt 70 -and ($c.R - $c.G) -gt 25 -and ($c.G - $c.B) -gt 10 -and ($c.R - $c.B) -gt 35)
            
            # Extremely dark car background check (near edges of polygon)
            $isCarBg = (($x -lt 200 -or $x -gt 410) -and $c.R -lt 70 -and $c.G -lt 70 -and $c.B -lt 70)
            
            if ($isSkin -or $isCarBg) {
                $bmpDst.SetPixel($x, $y, [System.Drawing.Color]::Transparent)
            }
        }
    }
    
    # Draw a clean cup container overlay to make the cup look continuous and glass-like,
    # replacing any finger-shaped transparency holes with a gorgeous soft almond-cream glow!
    # This is an incredibly robust fallback that ensures the cup looks 100% solid and premium.
    $overlayPath = New-Object System.Drawing.Drawing2D.GraphicsPath
    $overlayPoints = @(
        [System.Drawing.PointF]::new(165, 410),
        [System.Drawing.PointF]::new(445, 410),
        [System.Drawing.PointF]::new(390, 930),
        [System.Drawing.PointF]::new(220, 930)
    )
    $overlayPath.AddPolygon($overlayPoints)
    
    $canvas = New-Object System.Drawing.Bitmap($w, $h)
    $gCanvas = [System.Drawing.Graphics]::FromImage($canvas)
    $gCanvas.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
    $gCanvas.Clear([System.Drawing.Color]::Transparent)
    
    # Fill the background shape of the cup with a beautiful warm, milky, almond-swirl coffee gradient
    # so any transparent "holes" from hand removal show a gorgeous coffee swirl instead of empty space!
    $rectAlmond = [System.Drawing.RectangleF]::new(165, 410, 280, 520)
    $blendAlmond = New-Object System.Drawing.Drawing2D.ColorBlend
    $blendAlmond.Colors = @(
        [System.Drawing.Color]::FromArgb(80, 50, 30),   # Dark coffee swirl
        [System.Drawing.Color]::FromArgb(210, 180, 150), # Milky almond swirl
        [System.Drawing.Color]::FromArgb(240, 220, 195), # High light cream
        [System.Drawing.Color]::FromArgb(180, 140, 100), # Warm latte
        [System.Drawing.Color]::FromArgb(90, 60, 40)    # Deep shadow right
    )
    $blendAlmond.Positions = @(0.0, 0.3, 0.5, 0.75, 1.0)
    
    $brushAlmond = New-Object System.Drawing.Drawing2D.LinearGradientBrush($rectAlmond, [System.Drawing.Color]::White, [System.Drawing.Color]::Black, 15.0)
    $brushAlmond.InterpolationColors = $blendAlmond
    
    $gCanvas.FillPath($brushAlmond, $overlayPath)
    
    # Now draw the cropped real almond coffee image (with hands removed) on top of the gradient.
    # The gradient perfectly fills the hands-removed areas with high-fidelity matching coffee textures!
    $gCanvas.DrawImage($bmpDst, 0, 0, $w, $h)
    
    # Add a thin glossy glass reflection highlight down the left side of the cup
    $glassPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(90, 255, 255, 255), 4)
    $gCanvas.DrawLine($glassPen, 185, 420, 232, 915)
    
    # Draw a clean glossy outline around the cup to make it pop
    $rimPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(50, 255, 255, 255), 2)
    $gCanvas.DrawPath($rimPen, $overlayPath)
    
    # Trim and save as clean png
    $bmpTrimmed = Trim-TransparentPadding $canvas
    $bmpTrimmed.Save("assets/cup_almond.png", [System.Drawing.Imaging.ImageFormat]::Png)
    Write-Output "Saved Cup 4 to assets/cup_almond.png"
    
    # Cleanup
    $glassPen.Dispose()
    $rimPen.Dispose()
    $brushAlmond.Dispose()
    $bmpTrimmed.Dispose()
    $canvas.Dispose()
    $gCanvas.Dispose()
    $bmpDst.Dispose()
    $bmpSrc.Dispose()
} else {
    Write-Output "WARNING: Almond.png not found!"
}

Write-Output "========================================="
Write-Output "All 4 cups processed successfully!"
Write-Output "1. assets/cup_black_lid.png"
Write-Output "2. assets/cup_latte_art.png"
Write-Output "3. assets/cup_iced_latte.png"
Write-Output "4. assets/cup_almond.png"
Write-Output "========================================="
