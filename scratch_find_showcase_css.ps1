$css = Get-Content "index.css"
for ($i = 0; $i -lt $css.Length; $i++) {
    if ($css[$i] -like "*showcase*" -or $css[$i] -like "*parallax-stage*") {
        Write-Output "Line $($i + 1): $($css[$i])"
    }
}
