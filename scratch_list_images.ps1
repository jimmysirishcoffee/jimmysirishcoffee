Get-ChildItem -Path "assets" -Recurse | ForEach-Object {
    Write-Output "File: $($_.Name) - Size: $($_.Length) bytes - RelativePath: assets/$($_.Name)"
}
