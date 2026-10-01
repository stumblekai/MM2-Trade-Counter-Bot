# MM2 Trade Counter Bot for Roblox Matcha

This repo contains a Roblox Lua bot designed to work in a Matcha-style executor environment. It scans the trade UI, detects item names, filters blacklisted/unknown items, values the offer using the MM2 pricing tables, calculates a safe counter offer, and can auto-accept when the other player accepts.

Features:
- Reads visible trade UI labels
- Detects ancients / uniques / chromas / godlies
- Uses price tables and a blacklist
- Caps counter offers at 97% of their offer value
- Submits a counter offer automatically
- Declines after 2 minutes of inactivity
- Auto-accepts if they accept your counter
- Toggleable with Numpad 8

Project layout:
- src/Config.lua
- src/Pricing.lua
- src/TradeScanner.lua
- src/TradeBot.lua
- src/MatchaLoader.lua

How to use in Matcha:
1. Create a folder in ReplicatedStorage named `MM2TradeBot`.
2. Insert the following files into that folder:
   - Config.lua
   - Pricing.lua
   - TradeScanner.lua
   - TradeBot.lua
3. Put `MatchaLoader.lua` into the script executor as the main script.
4. Press Execute.
5. Press Numpad 8 to toggle the bot on/off.

Important:
- This is meant for local Roblox execution while a trade window is open.
- Some UI names differ depending on the game version or your Roblox client.
- You may need to adjust the detection patterns if the trade panel names change.

This bot intentionally follows the safer flow used in the original MM2 scripts:
- unknown items count as 0
- blacklisted items count as 0
- counter offer is capped at 97% of the valid value
- stale trades auto-decline

