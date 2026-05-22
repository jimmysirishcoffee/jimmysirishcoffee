Add-Type -AssemblyName System.Drawing
$bmp = New-Object System.Drawing.Bitmap("assets/Almond.png")
$w = $bmp.Width
$h = $bmp.Height
Write-Output "Image size: $w x $h"

# Let's inspect the center column and some horizontal lines
# to find where the cup borders are.
# We will print the average color and brightness of pixels at Y=200, 400, 600, 800
$sampleY = @(100, 200, 300, 400, 500, 600, 700, 800, 900, 1000)
foreach ($y in $sampleY) {
    if ($y -ge $h) { continue }
    # Let's print out the pixel colors every 20 pixels across the width
    $rowStr = "Y=$y : "
    for ($x = 0; $x -lt $w; $x += 30) {
        $c = $bmp.GetPixel($x, $y)
        # B = Brightness
        $b = [math]::Round(($c.R + $c.G + $c.B)/3)
        if ($b -lt 50) { $rowStr += "." } # Dark
        elseif ($b -lt 120) { $rowStr += "x" } # Mid-dark
        elseif ($b -lt 200) { $rowStr += "o" } # Mid-bright
        else { $rowStr += "O" } # Bright
    }
    Write-Output $rowStr
}
$bmp.Dispose()
