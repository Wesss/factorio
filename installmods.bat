
REM /MIR: Mirrors a directory tree, deleting files in the destination that are not present in the source. This creates an exact replica.
REM /DCOPY:T: Copies directory timestamps.
REM /MT:8: Creates multi-threaded copies with 8 threads for faster performance (you can adjust the number).
REM /R:3: Retries failed copies 3 times.
REM /W:10: Waits 10 seconds between retries.

robocopy "./westest" "C:/Users/wesle/AppData/Roaming/Factorio/mods/westest" /MIR /DCOPY:T /MT:8 /R:3 /W:10