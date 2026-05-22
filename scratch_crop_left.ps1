Add-Type -AssemblyName System.Drawing
$srcPath = "assets/Screenshot 2026-05-20 130908.png"
$dstPath = "assets/left_cup_trans.png"

$bmpSrc = New-Object System.Drawing.Bitmap($srcPath)
$bmpDst = New-Object System.Drawing.Bitmap($bmpSrc.Width, $bmpSrc.Height)
$g = [System.Drawing.Graphics]::FromImage($bmpDst)

$g.Clear([System.Drawing.Color]::Transparent)
$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias

# Define the points outlining the hot cup
# Width = 665, Height = 937
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
$g.DrawImage($bmpSrc, 0, 0, $bmpSrc.Width, $bmpSrc.Height)

$bmpDst.Save($dstPath, [System.Drawing.Imaging.ImageFormat]::Png)

$g.Dispose()
$bmpDst.Dispose()
$bmpSrc.Dispose()
Write-Output "Successfully saved cropped left cup to $dstPath"
