Write-Host ""
Write-Host "What would you like to do?"
Write-Host "A) Collect new Baseline?"
Write-Host "B) Begin monitoring files with saved Baseline?"

$response = Read-Host -Prompt "Please enter 'A' or 'B'"
Write-Host "User entered $($response)"
Write-Host ""

Function Calculate-File-Hash($filepath) {
    $filehash = Get-FileHash -Path $filepath -Algorithm SHA512
    return $filehash
}

Function Erase-Baseline-If-Already-Exist() {
    $baselineExists = Test-Path -Path .\baseline.txt
    if ($baselineExists) {
        # Delete it
        Remove-Item -Path .\baseline.txt
    }
}

Function Update-Baseline($files) {
    Erase-Baseline-If-Already-Exist

    foreach ($f in $files) {
        $hash = Calculate-File-Hash $f.FullName
        "$($f.FullName.Substring($pwd.Path.Length + 1))|$($hash.Hash)" | Out-File -FilePath .\baseline.txt -Append
    }

    Write-Host "Baseline updated" -ForegroundColor Cyan
}

if ($response -eq "A".ToUpper()) {
    # Collect new baseline
    $files = Get-ChildItem -Path .\files
    Update-Baseline $files
}
elseif ($response -eq "B".ToUpper()) {
    # Begin monitoring files with saved Baseline
    Write-Host "Read existing baseline.txt, start monitoring" -ForegroundColor Yellow

    $baseline = Get-Content -Path .\baseline.txt

    # Set up a timer to check for changes every second
    $timer = New-Object System.Timers.Timer
    $timer.Interval = 1000

    # Event handler for the timer
    $timerAction = {
        $files = Get-ChildItem -Path .\files
        $currentBaseline = Get-Content -Path .\baseline.txt

        if ($currentBaseline.Count -eq 0) {
            # If the baseline is empty, update it and skip the rest
            Update-Baseline $files
            return
        }

        foreach ($i in 0..($files.Count - 1)) {
            $currentFile = $files[$i].FullName.Substring($pwd.Path.Length + 1)
            $currentHash = Calculate-File-Hash $files[$i].FullName

            $baselineFile = $currentBaseline[$i].Split("|")[0]
            $baselineHash = $currentBaseline[$i].Split("|")[1]

            if ($currentFile -ne $baselineFile) {
                    # File path has changed, notify the user
                    Write-Host "$($currentFile) has a different path!!!" -ForegroundColor Yellow
                    Update-Baseline $files
                    break
                }

                if ($currentHash.Hash -ne $baselineHash) {
                    # File content has changed, notify the user
                    Write-Host "$($currentFile) has different content!!!" -ForegroundColor Yellow
                    Update-Baseline $files
                    break
                }
        }
    }

    # Register the event
    Register-ObjectEvent -InputObject $timer -EventName Elapsed -Action $timerAction | Out-Null

    # Start the timer
    $timer.Start()

    # Keep the script running
    do {
        Start-Sleep -Seconds 1
    } while ($true)
}
 

