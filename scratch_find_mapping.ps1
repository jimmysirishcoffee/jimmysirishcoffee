$logPath = "C:\Users\herob\.gemini\antigravity\brain\ae89c1dd-a65c-4394-9e20-5c489e696acb\.system_generated\logs\transcript.jsonl"

if (Test-Path $logPath) {
    $lines = Get-Content $logPath
    Write-Output "Searching for copy/Screenshot commands..."
    
    $matches = $lines | Where-Object { $_ -like "*Screenshot 2026-05-20*" -or $_ -like "*media_*" }
    Write-Output "Found $($matches.Count) lines with Screenshot or media_"
    
    $matches | Select-Object -Last 15 | ForEach-Object {
        if ($_ -match '"tool_calls":\s*(\[[^\]]+\])') {
            Write-Output "Tool call: $($Matches[1])"
        }
        if ($_ -match '"CommandLine":\s*"([^"]+)"') {
            Write-Output "CmdLine: $($Matches[1])"
        }
        if ($_ -match '"content":\s*"([^"]+)"') {
            $txt = $Matches[1]
            if ($txt.Length -gt 300) { $txt = $txt.Substring(0, 300) + "..." }
            Write-Output "Content: $txt"
        }
        Write-Output "--------------------------------------------------"
    }
} else {
    Write-Output "Log not found"
}
