$logPath = "C:\Users\herob\.gemini\antigravity\brain\ae89c1dd-a65c-4394-9e20-5c489e696acb\.system_generated\logs\transcript.jsonl"

if (Test-Path $logPath) {
    $lines = Get-Content $logPath
    Write-Output "Searching for 130650 or 130836 in logs..."
    
    $matches = $lines | Where-Object { $_ -like "*130650*" -or $_ -like "*130836*" }
    Write-Output "Found $($matches.Count) match lines."
    
    foreach ($m in $matches) {
        if ($m -match '"CommandLine":\s*"([^"]+)"') {
            Write-Output "Command: $($Matches[1])"
        }
        if (-not ($m -like "*CommandLine*") -and $m -match '"content":\s*"([^"]+)"') {
            $txt = $Matches[1]
            if ($txt.Length -gt 300) { $txt = $txt.Substring(0, 300) + "..." }
            Write-Output "Content: $txt"
        }
        Write-Output "----------------------------------"
    }
} else {
    Write-Output "Log not found"
}
