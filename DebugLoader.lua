local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local botRunning = false
local tradeStartTime = nil
local debugMode = true

local function normalizeKey(str)
	if type(str) ~= "string" then return "" end
	str = str:lower()
	str = str:gsub("'", "")
	str = str:gsub("%p", "")
	str = str:gsub("%s+", " ")
	str = str:gsub("^%s+", "")
	str = str:gsub("%s+$", "")
	return str
end

local ITEM_PRICES = {
	[normalizeKey("Traveler's Gun")] = 5200,
	[normalizeKey("Evergun")] = 3450,
	[normalizeKey("Evergreen")] = 2625,
	[normalizeKey("Constellation")] = 2600,
	[normalizeKey("Alienbeam")] = 1950,
	[normalizeKey("Turkey")] = 1950,
	[normalizeKey("Vampire's Gun")] = 1900,
	[normalizeKey("Darkshot")] = 1800,
	[normalizeKey("Raygun")] = 1800,
	[normalizeKey("Darksword")] = 1775,
	[normalizeKey("Blossom")] = 1360,
	[normalizeKey("Sakura")] = 1350,
	[normalizeKey("Sunrise")] = 1075,
	[normalizeKey("Bauble")] = 675,
	[normalizeKey("Snowcannon")] = 675,
	[normalizeKey("Soul")] = 670,
	[normalizeKey("Spirit")] = 660,
	[normalizeKey("Sunset")] = 650,
	[normalizeKey("Rainbow Gun")] = 420,
	[normalizeKey("Flora")] = 410,
	[normalizeKey("Rainbow")] = 410,
	[normalizeKey("Xenoknife")] = 405,
	[normalizeKey("Xenoshot")] = 405,
	[normalizeKey("Bloom")] = 400,
	[normalizeKey("Heart Wand")] = 340,
	[normalizeKey("Blizzard")] = 305,
	[normalizeKey("Snowstorm")] = 305,
	[normalizeKey("Ocean")] = 275,
	[normalizeKey("Waves")] = 270,
	[normalizeKey("Flowerwood Gun")] = 250,
	[normalizeKey("Flowerwood")] = 245,
	[normalizeKey("Snow Dagger")] = 175,
	[normalizeKey("Watergun")] = 160,
	[normalizeKey("Icecream")] = 155,
	[normalizeKey("Treat")] = 155,
	[normalizeKey("Sweet")] = 150,
	[normalizeKey("Borealis")] = 145,
	[normalizeKey("Australis")] = 140,
	[normalizeKey("Bat")] = 125,
	[normalizeKey("Beachy")] = 90,
	[normalizeKey("Sands")] = 90,
	[normalizeKey("Pearlshine")] = 80,
	[normalizeKey("Candy")] = 80,
	[normalizeKey("Pearl")] = 75,
	[normalizeKey("Ornament")] = 70,
	[normalizeKey("Heartblade")] = 65,
	[normalizeKey("Phantom")] = 35,
	[normalizeKey("Red Luger")] = 35,
	[normalizeKey("Spectre")] = 35,
	[normalizeKey("Candleflame")] = 33,
	[normalizeKey("Darkbringer")] = 33,
	[normalizeKey("Elderwood Blade")] = 33,
	[normalizeKey("Elderwood Revolver")] = 33,
	[normalizeKey("Iceblaster")] = 33,
	[normalizeKey("Makeshift")] = 33,
	[normalizeKey("Lightbringer")] = 32,
	[normalizeKey("Sugar")] = 32,
	[normalizeKey("Green Luger")] = 23,
	[normalizeKey("Amerilaser")] = 22,
	[normalizeKey("Laser")] = 22,
	[normalizeKey("Hallowgun")] = 20,
	[normalizeKey("Nightblade")] = 20,
	[normalizeKey("Shark")] = 20,
	[normalizeKey("Icebeam")] = 18,
	[normalizeKey("Luger")] = 18,
	[normalizeKey("Plasmabeam")] = 18,
	[normalizeKey("Swirly Gun")] = 18,
	[normalizeKey("Battleaxe II")] = 17,
	[normalizeKey("Blaster")] = 17,
	[normalizeKey("Ginger Luger")] = 17,
	[normalizeKey("Pixel")] = 17,
	[normalizeKey("Gemstone")] = 15,
	[normalizeKey("Iceflake")] = 15,
	[normalizeKey("Old Glory")] = 15,
	[normalizeKey("Plasmablade")] = 15,
	[normalizeKey("Slasher")] = 15,
	[normalizeKey("Vampire's Edge")] = 15,
	[normalizeKey("Cookiecane")] = 13,
	[normalizeKey("Deathshard")] = 13,
	[normalizeKey("Eternalcane")] = 13,
	[normalizeKey("Gingerblade")] = 13,
	[normalizeKey("Jinglegun")] = 13,
	[normalizeKey("Lugercane")] = 13,
	[normalizeKey("Minty")] = 13,
	[normalizeKey("Nebula")] = 13,
	[normalizeKey("Virtual")] = 13,
	[normalizeKey("Battleaxe")] = 12,
	[normalizeKey("Gingermint")] = 12,
	[normalizeKey("Swirly Blade")] = 12,
	[normalizeKey("Chill")] = 10,
	[normalizeKey("Clockwork")] = 10,
	[normalizeKey("Fang")] = 10,
	[normalizeKey("Frostsaber")] = 10,
	[normalizeKey("Heat")] = 10,
	[normalizeKey("Spider")] = 10,
	[normalizeKey("Tides")] = 10,
	[normalizeKey("Bioblade")] = 8,
	[normalizeKey("Eternal III")] = 8,
	[normalizeKey("Eternal IV")] = 8,
	[normalizeKey("Hallow's Blade")] = 8,
	[normalizeKey("Hallow's Edge")] = 8,
	[normalizeKey("Handsaw")] = 8,
	[normalizeKey("Boneblade")] = 7,
	[normalizeKey("Eternal")] = 7,
	[normalizeKey("Eternal II")] = 7,
	[normalizeKey("Frostbite")] = 7,
	[normalizeKey("Ghostblade")] = 7,
	[normalizeKey("Ice Dragon")] = 7,
	[normalizeKey("Ice Shard")] = 7,
	[normalizeKey("Prismatic")] = 7,
	[normalizeKey("Pumpking")] = 7,
	[normalizeKey("Saw")] = 7,
	[normalizeKey("Xmas")] = 7,
	[normalizeKey("Eggblade")] = 5,
	[normalizeKey("Flames")] = 5,
	[normalizeKey("Snowflake")] = 5,
	[normalizeKey("Winter's Edge")] = 5,
	[normalizeKey("Peppermint")] = 4,
	[normalizeKey("Cookieblade")] = 3,
	[normalizeKey("Blue Seer")] = 3,
	[normalizeKey("Purple Seer")] = 3,
	[normalizeKey("Red Seer")] = 3,
	[normalizeKey("Seer")] = 3,
	[normalizeKey("Orange Seer")] = 2,
	[normalizeKey("Yellow Seer")] = 2,
	[normalizeKey("C. Traveler's Gun")] = 145000,
	[normalizeKey("Chroma Evergun")] = 56000,
	[normalizeKey("Chroma Evergreen")] = 42000,
	[normalizeKey("Chroma Bauble")] = 31000,
	[normalizeKey("C. Constellation")] = 29000,
	[normalizeKey("C. Vampire's Gun")] = 29000,
	[normalizeKey("Chroma Alienbeam")] = 24000,
	[normalizeKey("Chroma Raygun")] = 14250,
	[normalizeKey("Chroma Sunrise")] = 10750,
	[normalizeKey("Chroma Snowcannon")] = 7750,
	[normalizeKey("Chroma Sunset")] = 7750,
	[normalizeKey("Chroma Blizzard")] = 5500,
	[normalizeKey("Chroma Snowstorm")] = 4250,
	[normalizeKey("Chroma Heart Wand")] = 4000,
	[normalizeKey("Chroma Watergun")] = 2350,
	[normalizeKey("Chroma Snow Dagger")] = 2350,
	[normalizeKey("Chroma Ornament")] = 1825,
	[normalizeKey("Chroma Treat")] = 1775,
	[normalizeKey("Chroma Icecream")] = 1750,
	[normalizeKey("Chroma Sweet")] = 1725,
	[normalizeKey("Chroma Sands")] = 1200,
	[normalizeKey("Chroma Beachy")] = 1150,
	[normalizeKey("Chroma Darkbringer")] = 65,
	[normalizeKey("Chroma Lightbringer")] = 60,
	[normalizeKey("Chroma Luger")] = 50,
	[normalizeKey("Chroma Candleflame")] = 40,
	[normalizeKey("Chroma Laser")] = 40,
	[normalizeKey("C. Elderwood Blade")] = 37,
	[normalizeKey("Chroma Deathshard")] = 35,
	[normalizeKey("Chroma Swirly Gun")] = 35,
	[normalizeKey("Chroma Cookiecane")] = 32,
	[normalizeKey("Chroma Fang")] = 32,
	[normalizeKey("Chroma Gemstone")] = 32,
	[normalizeKey("Chroma Shark")] = 32,
	[normalizeKey("Chroma Slasher")] = 32,
	[normalizeKey("Chroma Heat")] = 28,
	[normalizeKey("Chroma Seer")] = 28,
	[normalizeKey("Chroma Gingerblade")] = 27,
	[normalizeKey("Chroma Tides")] = 27,
	[normalizeKey("Chroma Saw")] = 23,
	[normalizeKey("Chroma Boneblade")] = 22,
	[normalizeKey("Gingerscope")] = 15750,
	[normalizeKey("Traveler's Axe")] = 8000,
	[normalizeKey("Celestial")] = 2250,
	[normalizeKey("Vampire's Axe")] = 1600,
	[normalizeKey("Harvester")] = 250,
	[normalizeKey("Icepiercer")] = 160,
	[normalizeKey("Icebreaker")] = 65,
	[normalizeKey("Batwing")] = 42,
	[normalizeKey("Elderwood Scythe")] = 38,
	[normalizeKey("Swirly Axe")] = 38,
	[normalizeKey("Hallowscythe")] = 30,
	[normalizeKey("Logchopper")] = 18,
	[normalizeKey("Icewing")] = 13,
	[normalizeKey("Corrupt")] = 350,
}

local BLACKLIST = {
	[normalizeKey("Chroma Beachy")] = true,
	[normalizeKey("Chroma Sands")] = true,
	[normalizeKey("Chroma Heart Wand")] = true,
	[normalizeKey("Flowerwood")] = true,
	[normalizeKey("Flowerwood Gun")] = true,
	[normalizeKey("Ornament")] = true,
}

local function debugPrint(msg)
	if debugMode then
		print("[MM2 DEBUG] " .. tostring(msg))
	end
end

local function getAllGuiText()
	local gui = Players.LocalPlayer:FindFirstChild("PlayerGui")
	if not gui then return {} end
	local texts = {}
	for _, obj in ipairs(gui:GetDescendants()) do
		if obj:IsA("TextLabel") or obj:IsA("TextButton") then
			local text = tostring(obj.Text or "")
			if text ~= "" then
				table.insert(texts, text)
			end
		end
	end
	return texts
end

local function isTradeOpen()
	local gui = Players.LocalPlayer:FindFirstChild("PlayerGui")
	if not gui then return false end
	for _, obj in ipairs(gui:GetDescendants()) do
		if obj:IsA("TextLabel") or obj:IsA("TextButton") then
			local txt = normalizeKey(tostring(obj.Text or ""))
			if txt:find("trade") or txt:find("offer") or txt:find("accept") or txt:find("decline") then
				return true
			end
		end
	end
	return false
end

local function findTradeGui()
	local gui = Players.LocalPlayer:FindFirstChild("PlayerGui")
	if not gui then return nil end
	for _, obj in ipairs(gui:GetDescendants()) do
		if obj:IsA("Frame") or obj:IsA("ScreenGui") then
			local name = normalizeKey(obj.Name)
			if name:find("trade") or name:find("offer") then
				return obj
			end
		end
	end
	return nil
end

local function scanTradeForItems()
	local tradeGui = findTradeGui()
	if not tradeGui then 
		debugPrint("No trade GUI found. Scanning all PlayerGui text...")
		local allText = getAllGuiText()
		debugPrint("Found " .. #allText .. " text elements in PlayerGui")
		for i, text in ipairs(allText) do
			debugPrint("  [" .. i .. "] " .. text)
		end
		return {} 
	end
	local found = {}
	local seen = {}
	for _, obj in ipairs(tradeGui:GetDescendants()) do
		if obj:IsA("TextLabel") or obj:IsA("TextButton") then
			local text = tostring(obj.Text or "")
			if text ~= "" then
				local normalized = normalizeKey(text)
				if ITEM_PRICES[normalized] then
					if not seen[normalized] then
						seen[normalized] = true
						table.insert(found, {name = text, value = ITEM_PRICES[normalized], hasPrice = true})
					end
				else
					if not seen[normalized] then
						seen[normalized] = true
						table.insert(found, {name = text, value = 0, hasPrice = false})
					end
				end
			end
		end
	end
	return found
end

local function filterBlacklist(itemList)
	local filtered = {}
	local blacklistedItems = {}
	for _, item in ipairs(itemList) do
		local key = normalizeKey(item.name)
		if BLACKLIST[key] then
			table.insert(blacklistedItems, item.name)
		else
			table.insert(filtered, item)
		end
	end
	return filtered, blacklistedItems
end

local function calculateOffer(itemList)
	local total = 0
	for _, item in ipairs(itemList) do
		total = total + item.value
	end
	if total <= 0 then return 0 end
	local target = total * 0.97
	return math.floor(target)
end

local function findButtonByText(buttonName)
	local gui = Players.LocalPlayer:FindFirstChild("PlayerGui")
	if not gui then return false end
	for _, obj in ipairs(gui:GetDescendants()) do
		if obj:IsA("TextButton") then
			local txt = normalizeKey(tostring(obj.Text or ""))
			local name = normalizeKey(tostring(obj.Name or ""))
			if txt:find(buttonName) or name:find(buttonName) then
				pcall(function() obj:Click() end)
				debugPrint("Clicked: " .. buttonName)
				return true
			end
		end
	end
	return false
end

local function findOfferInputField()
	local gui = Players.LocalPlayer:FindFirstChild("PlayerGui")
	if not gui then return nil end
	for _, obj in ipairs(gui:GetDescendants()) do
		if obj:IsA("TextBox") then
			return obj
		end
	end
	return nil
end

local function submitCounter(amount)
	local inputField = findOfferInputField()
	if inputField then
		pcall(function()
			inputField:CaptureFocus()
			inputField.Text = tostring(amount)
			debugPrint("Counter submitted: " .. amount)
		end)
		return true
	end
	return false
end

local function theyAcceptedCounter()
	local gui = Players.LocalPlayer:FindFirstChild("PlayerGui")
	if not gui then return false end
	for _, obj in ipairs(gui:GetDescendants()) do
		if obj:IsA("TextLabel") then
			local txt = normalizeKey(tostring(obj.Text or ""))
			if txt:find("accepted") or txt:find("waiting") then
				return true
			end
		end
	end
	return false
end

local function processTrade()
	if not isTradeOpen() then
		tradeStartTime = nil
		return
	end
	
	debugPrint("Trade is open!")
	
	if tradeStartTime == nil then
		tradeStartTime = tick()
		debugPrint("Trade session started")
	end
	
	if (tick() - tradeStartTime) > 120 then
		debugPrint("2 min timeout. Declining.")
		findButtonByText("decline")
		tradeStartTime = nil
		return
	end
	
	local theirItems = scanTradeForItems()
	debugPrint("Scanned items: " .. #theirItems)
	if #theirItems == 0 then 
		debugPrint("No items found in trade")
		return 
	end
	
	local validItems, blacklistedItems = filterBlacklist(theirItems)
	if #blacklistedItems > 0 then
		debugPrint("Blacklisted items ignored: " .. #blacklistedItems)
	end
	
	local theirTotal = 0
	for _, item in ipairs(validItems) do
		theirTotal = theirTotal + item.value
	end
	
	if theirTotal <= 0 then
		debugPrint("No value detected")
		return
	end
	
	debugPrint("Total value: " .. theirTotal)
	local counterOffer = calculateOffer(validItems)
	debugPrint("Counter at 97%: " .. counterOffer)
	
	submitCounter(counterOffer)
	wait(0.4)
	findButtonByText("offer")
	debugPrint("Counter submitted. Waiting...")
	
	local timeout = 60
	local elapsed = 0
	while elapsed < timeout do
		if theyAcceptedCounter() then
			debugPrint("They accepted. Accepting now.")
			wait(0.5)
			findButtonByText("accept")
			tradeStartTime = nil
			return
		end
		if (tick() - tradeStartTime) > 120 then
			debugPrint("2 min timeout. Declining.")
			findButtonByText("decline")
			tradeStartTime = nil
			return
		end
		elapsed = elapsed + 1
		wait(1)
	end
	
	tradeStartTime = nil
end

local function startBot()
	botRunning = true
	print("[MM2 Bot] Started. Press Numpad 8 to stop. Debug mode ON.")
	
	while botRunning do
		if isTradeOpen() then
			processTrade()
			wait(1.5)
		else
			tradeStartTime = nil
			wait(0.4)
		end
	end
	
	print("[MM2 Bot] Stopped.")
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.KeyCode == Enum.KeyCode.Keypad8 then
		if botRunning then
			botRunning = false
			print("[MM2 Bot] Stopping...")
		else
			task.spawn(function() startBot() end)
		end
	end
end)

print("[MM2 Bot] Ready. Press Numpad 8 to toggle. Debug mode is ON.")
