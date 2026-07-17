# Revive Duper (Roblox DOORS)
This is a script that allows you to dupe revives in DOORS.

# How to use it?
1. You need to have an alt account that would be used for duping
2. Create elevator with main and alt account and press start (omg is that gd reference)
3. If you have revive on alt account then you can start the script by executing this FIRST on sender account and THEN on receiver account (you can execute at door 0):
```lua
receiver = "MAIN ACCOUNT"
sender = "ALT ACCOUNT"
revives = 1000 -- how many revives to dupe
destroylaggystuff = true -- if you set big amount of revives you should turn this on

loadstring(game:HttpGet("https://raw.githubusercontent.com/tplaygd/revive/refs/heads/main/.lua"))()
```
If you dont have revive on alt account then you can get from achievements, or by simply transfering from main account by executing this FIRST on sender account and THEN on receiver account (you can execute at door 0):
```lua
receiver = "ALT ACCOUNT"
sender = "MAIN ACCOUNT"
revives = 1
destroylaggystuff = false

loadstring(game:HttpGet("https://raw.githubusercontent.com/tplaygd/revive/refs/heads/main/.lua"))()
```
4. Now wait until the script does everything!

# Why did i made this?
idfk
