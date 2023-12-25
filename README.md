# FIM
File Integrity Monitoring Tool - Using Windows Powershell

This PowerShell script provides a simple file monitoring system. Let's break down the key components and functionalities:

**Menu and User Input**
The script begins by displaying a menu using Write-Host and prompts the user to choose between two options: collecting a new baseline (A) or beginning the monitoring of files with a saved baseline (B). The user's input is read using Read-Host.

**File Hash Calculation**
The script defines a function Calculate-File-Hash that takes a file path as input and uses the Get-FileHash cmdlet to calculate the SHA-512 hash of the file. The function returns the calculated hash.

**Baseline Management Functions**
Erase-Baseline-If-Already-Exist: Checks if a baseline file (baseline.txt) exists and deletes it if it does.

**Update-Baseline:**
Takes an array of files as input, calculates the hash for each file, and appends the file path and hash to the baseline.txt file. Before updating, it erases the existing baseline using the Erase-Baseline-If-Already-Exist function.

**Main Execution Logic**
The script checks the user's input and performs the following actions:

If the user chose 'A' (to collect a new baseline), it retrieves a list of files in the specified directory and updates the baseline using the Update-Baseline function.

If the user chose 'B' (to begin monitoring files), it reads the existing baseline from baseline.txt and sets up a timer to check for changes in files every second.

**Timer Event Action**
The timer event action ($timerAction) is triggered every second. It retrieves the current list of files and the baseline from baseline.txt and compares each file's path and hash with the baseline.

If the baseline is empty, it updates the baseline and skips the comparison.
If a file's path or content has changed, it notifies the user and updates the baseline.
Timer Setup and Execution
The script sets up a timer using System.Timers.Timer and registers an event handler for the timer's elapsed event. The event handler is the $timerAction script block.

The timer is started, and the script enters a loop to keep it running indefinitely. The loop includes a Start-Sleep command to avoid excessive resource usage.

**Summary**
In summary, the script allows the user to either collect a new baseline or monitor files based on an existing baseline. It employs file hashing and a timer-based approach to detect changes in file paths or contents and updates the baseline accordingly. The script runs continuously until manually terminated.
