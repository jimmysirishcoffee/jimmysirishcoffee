$logPath = "C:\Users\herob\.gemini\antigravity\brain\ae89c1dd-a65c-4394-9e20-5c489e696acb\.system_generated\logs\transcript.jsonl"

if (Test-Path $logPath) {
    Write-Output "Log file found!"
    $lines = Get-Content $logPath
    Write-Output "Total lines in log: $($lines.Count)"
    
    # Search for keywords
    $keywords = @("bean", "split", "four cups", "reference", "holder", "hands", "Almond", "latte art")
    
    foreach ($kw in $keywords) {
        Write-Output "--- Search results for: $kw ---"
        $matches = $lines | Where-Object { $_ -like "*$kw*" }
        Write-Output "Found $($matches.Count) matches"
        # Print the first 5 matches
        $matches | Select-Object -First 5 | ForEach-Object {
            # Parse a bit of text from JSON
            if ($_ -match '"content":"([^"]+)"') {
                Write-Output "  Match: $($Matches[1])"
            } else {
                Write-Output "  Raw Match: $($_.SubString(0, [math]::Min($_.Length, 200)))..."
            }
        }
    }
} else {
    Write-Output "Log file not found at: $logPath"
}
