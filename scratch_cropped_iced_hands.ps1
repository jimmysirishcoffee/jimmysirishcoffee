Add-Type -AssemblyName System.Drawing

$path = "assets/cup_iced_latte.png"
if (-not (Test-Path $path)) {
    Write-Output "File not found: $path"
    exit
}

$bmp = New-Object System.Drawing.Bitmap($path)
$w = $bmp.Width
$h = $bmp.Height

$skinCount = 0
$gloveCount = 0
$totalOpaque = 0

for ($y = 0; $y -lt $h; $y++) {
    for ($x = 0; $x -lt $w; $x++) {
        $c = $bmp.GetPixel($x, $y)
        if ($c.A -lt 10) { continue }
        
        $totalOpaque++
        
        # Skin tone check
        $isSkin = ($c.R -gt 130 -and $c.G -gt 85 -and $c.B -gt 70 -and ($c.R - $c.G) -gt 25 -and ($c.G - $c.B) -gt 10 -and ($c.R - $c.B) -gt 35)
        
        # Black glove or dark background check
        $isGlove = ($c.R -lt 40 -and $c.G -lt 40 -and $c.B -lt 40)
        
        if ($isSkin) { $skinCount++ }
        if ($isGlove) { $gloveCount++ }
    }
}

Write-Output "Image: assets/cup_iced_latte.png ($w x $h)"
Write-Output "Total opaque/visible pixels: $totalOpaque"
Write-Output "Skin tone pixels: $skinCount ($([math]::Round(($skinCount / $totalOpaque) * 100, 2)) % of visible)"
Write-Output "Dark/Glove pixels: $gloveCount ($([math]::Round(($gloveCount / $totalOpaque) * 100, 2)) % of visible)"

$bmp.Dispose()
