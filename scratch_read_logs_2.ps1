$logPath = "C:\Users\herob\.gemini\antigravity\brain\ae89c1dd-a65c-4394-9e20-5c489e696acb\.system_generated\logs\transcript.jsonl"

if (Test-Path $logPath) {
    $lines = Get-Content $logPath
    Write-Output "Search for '111246':"
    $matches = $lines | Where-Object { $_ -like "*111246*" }
    Write-Output "Found $($matches.Count) matches"
    $matches | Select-Object -First 10 | ForEach-Object {
        if ($_ -match '"content":"([^"]+)"') {
            # Print first 500 characters of the match
            $txt = $Matches[1]
            if ($txt.Length -gt 600) { $txt = $txt.Substring(0, 600) + "..." }
            Write-Output "  Content: $txt"
            Write-Output "------------------------"
        }
    }
} else {
    Write-Output "Log not found"
}
