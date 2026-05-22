$logPath = "C:\Users\herob\.gemini\antigravity\brain\ae89c1dd-a65c-4394-9e20-5c489e696acb\.system_generated\logs\transcript.jsonl"

if (Test-Path $logPath) {
    $lines = Get-Content $logPath
    Write-Output "Searching for Copy-Item or assets copy in logs..."
    
    $matches = $lines | Where-Object { $_ -like "*Copy-Item*" -and $_ -like "*media_*" }
    Write-Output "Found $($matches.Count) match lines."
    
    foreach ($m in $matches) {
        if ($m -match '"CommandLine":\s*"([^"]+)"') {
            Write-Output "Command: $($Matches[1])"
        }
    }
} else {
    Write-Output "Log not found"
}
