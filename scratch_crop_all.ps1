Add-Type -AssemblyName System.Drawing

# Helper function to crop using a polygon and save as transparent PNG
function Crop-Polygon($srcName, $dstName, $points) {
    $srcPath = Join-Path "assets" $srcName
    $dstPath = Join-Path "assets" $dstName
    
    if (-not (Test-Path $srcPath)) {
        Write-Output "Source file not found: $srcPath"
        return
    }
    
    $bmpSrc = New-Object System.Drawing.Bitmap($srcPath)
    $bmpDst = New-Object System.Drawing.Bitmap($bmpSrc.Width, $bmpSrc.Height)
    $g = [System.Drawing.Graphics]::FromImage($bmpDst)
    
    $g.Clear([System.Drawing.Color]::Transparent)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    
    $path = New-Object System.Drawing.Drawing2D.GraphicsPath
    $gPoints = @()
    foreach ($pt in $points) {
        $gPoints += [System.Drawing.PointF]::new($pt[0], $pt[1])
    }
    $path.AddPolygon($gPoints)
    
    $g.SetClip($path)
    $g.DrawImage($bmpSrc, 0, 0, $bmpSrc.Width, $bmpSrc.Height)
    
    $bmpDst.Save($dstPath, [System.Drawing.Imaging.ImageFormat]::Png)
    
    $g.Dispose()
    $bmpDst.Dispose()
    $bmpSrc.Dispose()
    Write-Output "Successfully saved cropped image to $dstPath"
}

# Helper function to crop using an ellipse and save as transparent PNG
function Crop-Ellipse($srcName, $dstName, $x, $y, $w, $h) {
    $srcPath = Join-Path "assets" $srcName
    $dstPath = Join-Path "assets" $dstName
    
    if (-not (Test-Path $srcPath)) {
        Write-Output "Source file not found: $srcPath"
        return
    }
    
    $bmpSrc = New-Object System.Drawing.Bitmap($srcPath)
    $bmpDst = New-Object System.Drawing.Bitmap($bmpSrc.Width, $bmpSrc.Height)
    $g = [System.Drawing.Graphics]::FromImage($bmpDst)
    
    $g.Clear([System.Drawing.Color]::Transparent)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    
    $path = New-Object System.Drawing.Drawing2D.GraphicsPath
    $path.AddEllipse($x, $y, $w, $h)
    
    $g.SetClip($path)
    $g.DrawImage($bmpSrc, 0, 0, $bmpSrc.Width, $bmpSrc.Height)
    
    $bmpDst.Save($dstPath, [System.Drawing.Imaging.ImageFormat]::Png)
    
    $g.Dispose()
    $bmpDst.Dispose()
    $bmpSrc.Dispose()
    Write-Output "Successfully saved elliptical crop to $dstPath"
}

# 1. Left Cup Polygon
# Tapered cylinder to slice out the black gloved hand on the left base
$leftPoints = @(
    @(85, 150),
    @(332, 130),
    @(580, 150),
    @(615, 170),
    @(590, 240),
    @(560, 250),
    @(495, 870),
    @(332, 895),
    @(170, 870),
    @(105, 250),
    @(75, 240),
    @(50, 170)
)
Crop-Polygon "Screenshot 2026-05-20 130908.png" "left_cup_trans.png" $leftPoints

# 2. Center Cup Ellipse
# Perfect circle/ellipse tracing the top-down latte art cup (hand-free!)
Crop-Ellipse "Screenshot 2026-05-20 130900.png" "center_cup_trans.png" 110 160 380 390

# 3. Right Glass Polygon
# Detailed outline for straw, brownie, lid and glass body
$rightPoints = @(
    @(268, 240), # Straw top-left
    @(295, 240), # Straw top-right
    @(260, 430), # Straw right edge entering brownie
    @(310, 430), # Brownie top-right
    @(350, 480), # Brownie right base
    @(380, 560), # Lid right corner
    @(385, 600), # Glass body right top
    @(395, 800), # Glass body right mid
    @(415, 1150),# Glass base bottom-right
    @(95, 1150), # Glass base bottom-left
    @(70, 800),  # Glass body left mid
    @(45, 600),  # Glass body left top
    @(55, 560),  # Lid left corner
    @(120, 480), # Brownie left base
    @(180, 430), # Brownie top-left
    @(230, 430)  # Straw left edge entering brownie
)
Crop-Polygon "Screenshot 2026-05-20 130848.png" "right_cup_trans.png" $rightPoints
