$logPath = "C:\Users\herob\.gemini\antigravity\brain\ae89c1dd-a65c-4394-9e20-5c489e696acb\.system_generated\logs\transcript.jsonl"
if (Test-Path $logPath) {
    $lines = Get-Content $logPath
    $editSteps = @(434, 435, 557, 558, 697, 698, 962, 963, 977, 1007, 1011)
    
    foreach ($stepNum in $editSteps) {
        $m = $lines | Where-Object { $_ -like "*""step_index"":$stepNum,*" -or $_ -like "*""step_index"":$stepNum}*" }
        if ($m -and ($m -like "*main-header*" -or $m -like "*logo-text*" -or $m -like "*nav*" -or $m -like "*logo-link*")) {
            Write-Output "Step $stepNum contains header keywords! Length: $($m.Length)"
            # Let's extract TargetContent or ReplacementContent or tool args snippet
            if ($m -match '"tool_calls":\s*(\[[^\]]+\])') {
                $tool = $Matches[1]
                if ($tool.Length -gt 1500) { $tool = $tool.Substring(0, 1500) + "..." }
                $clean = [System.Text.RegularExpressions.Regex]::Unescape($tool)
                Write-Output "Tool call unescaped: $clean"
            }
            if ($m -match '"content":"([^"]+)"') {
                $content = $Matches[1]
                if ($content.Length -gt 1500) { $content = $content.Substring(0, 1500) + "..." }
                $clean = [System.Text.RegularExpressions.Regex]::Unescape($content)
                Write-Output "Content unescaped: $clean"
            }
            Write-Output "=================================================="
        }
    }
} else {
    Write-Output "Transcript not found"
}
