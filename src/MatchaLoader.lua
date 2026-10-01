local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local Config = require(script.Parent.Config)
local Pricing = require(script.Parent.Pricing)
local TradeScanner = require(script.Parent.TradeScanner)

local TradeBot = {}
TradeBot.__index = TradeBot

function TradeBot.new()
	local self = setmetatable({}, TradeBot)
	self.scanner = TradeScanner.new()
	self.running = false
	self.tradeStartTime = nil
	self.scannerInstance = nil
	return self
end

function TradeBot:isTradeOpen()
	local gui = Players.LocalPlayer:FindFirstChild("PlayerGui")
	if not gui then
		return false
	end

	for _, obj in ipairs(gui:GetDescendants()) do
		if obj:IsA("TextLabel") or obj:IsA("TextButton") then
			local txt = Pricing.normalizeKey(tostring(obj.Text or ""))
			for _, keyword in ipairs(Config.tradeKeywords) do
				if txt:find(keyword) then
					return true
				end
			end
		end
	end

	return false
end

function TradeBot:findButtonByText(buttonName)
	local gui = Players.LocalPlayer:FindFirstChild("PlayerGui")
	if not gui then
		return false
	end

	for _, obj in ipairs(gui:GetDescendants()) do
		if obj:IsA("TextButton") then
			local txt = Pricing.normalizeKey(tostring(obj.Text or ""))
			local name = Pricing.normalizeKey(tostring(obj.Name or ""))
			if txt:find(buttonName) or name:find(buttonName) then
				pcall(function()
					obj:Click()
					print("[MM2 Bot] Clicked button:", buttonName)
				end)
				return true
			end
		end
	end

	return false
end

function TradeBot:findOfferInputField()
	local gui = Players.LocalPlayer:FindFirstChild("PlayerGui")
	if not gui then
		return nil
	end

	for _, obj in ipairs(gui:GetDescendants()) do
		if obj:IsA("TextBox") then
			return obj
		end
	end

	return nil
end

function TradeBot:submitCounter(amount)
	local inputField = self:findOfferInputField()
	if inputField then
		pcall(function()
			inputField:CaptureFocus()
			inputField.Text = tostring(amount)
			print("[MM2 Bot] Counter offer submitted:", amount)
		end)
		return true
	end

	return false
end

function TradeBot:calculateOffer(itemList)
	local total = 0
	for _, item in ipairs(itemList) do
		total += item.value
	end

	if total <= 0 then
		return 0
	end

	local target = total * (Config.counterCapPercent / 100)
	return math.floor(target)
end

function TradeBot:doubleCheckOffer(theirTotal, yourCounter)
	if yourCounter <= 0 then
		return false
	end

	local maxAllowed = math.floor(theirTotal * (Config.counterCapPercent / 100))
	if yourCounter > maxAllowed then
		print("[MM2 Bot] Safety check failed: counter exceeds 97% of their offer.")
		return false
	end

	print("[MM2 Bot] Safety check passed: offer is within 97% cap.")
	return true
end

function TradeBot:theyAcceptedCounter()
	local gui = Players.LocalPlayer:FindFirstChild("PlayerGui")
	if not gui then
		return false
	end

	for _, obj in ipairs(gui:GetDescendants()) do
		if obj:IsA("TextLabel") then
			local txt = Pricing.normalizeKey(tostring(obj.Text or ""))
			for _, keyword in ipairs(Config.acceptedTextKeywords) do
				if txt:find(keyword) then
					return true
				end
			end
		end
	end

	return false
end

function TradeBot:processTrade()
	if not self:isTradeOpen() then
		self.tradeStartTime = nil
		return
	end

	if self.tradeStartTime == nil then
		self.tradeStartTime = tick()
		print("[MM2 Bot] Trade opened. Auto-decline in 2 minutes if no action is taken.")
	end

	if (tick() - self.tradeStartTime) > Config.autoDeclineAfter then
		print("[MM2 Bot] Trade has lasted over 2 minutes. Auto-declining trade.")
		self:findButtonByText("decline")
		self.tradeStartTime = nil
		return
	end

	local theirItems = self.scanner:scanTradeForItems()
	if #theirItems == 0 then
		print("[MM2 Bot] No trade items detected yet.")
		return
	end

	local validItems, blacklistedItems = self.scanner:filterBlacklist(theirItems)
	if #blacklistedItems > 0 then
		print("[MM2 Bot] Blacklisted items found (counted as 0 value):")
		for _, name in ipairs(blacklistedItems) do
			print("  - " .. name .. " (ignored)")
		end
	end

	local theirTotal = 0
	for _, item in ipairs(validItems) do
		theirTotal += item.value
	end

	if theirTotal <= 0 then
		print("[MM2 Bot] Remaining offer value is 0. No counter offer will be made.")
		return
	end

	print("[MM2 Bot] Valid offer items:")
	for _, item in ipairs(validItems) do
		print("  - " .. item.name .. " = " .. item.value)
	end
	print("[MM2 Bot] Total valid value:", theirTotal)

	local counterOffer = self:calculateOffer(validItems)
	print("[MM2 Bot] Counter offer at 97%:", counterOffer)

	if not self:doubleCheckOffer(theirTotal, counterOffer) then
		print("[MM2 Bot] Not safe. Won't counter; waiting for manual review.")
		return
	end

	self:submitCounter(counterOffer)
	wait(0.4)
	self:findButtonByText("offer")
	print("[MM2 Bot] Counter submitted. Waiting for them to accept...")

	local timeout = 60
	local elapsed = 0
	while elapsed < timeout do
		if self:theyAcceptedCounter() then
			print("[MM2 Bot] They accepted the counter. Auto-accepting now.")
			wait(0.5)
			self:findButtonByText("accept")
			self.tradeStartTime = nil
			return
		end
		if (tick() - self.tradeStartTime) > Config.autoDeclineAfter then
			print("[MM2 Bot] Trade exceeded 2 minutes while waiting for acceptance. Declining.")
			self:findButtonByText("decline")
			self.tradeStartTime = nil
			return
		end
		elapsed += 1
		wait(1)
	end

	print("[MM2 Bot] Timeout waiting for them to accept the counter.")
	self.tradeStartTime = nil
end

function TradeBot:start()
	self.running = true
	print("[MM2 Bot] Started. Press Numpad 8 to stop.")
	print("[MM2 Bot] Flow: They send trade -> ignore blacklisted & unknown items as 0 -> counter at 97% -> decline after 2 minutes -> auto-accept on acceptance.")

	while self.running do
		if self:isTradeOpen() then
			self:processTrade()
			wait(1.5)
		else
			self.tradeStartTime = nil
			wait(0.4)
		end
	end

	print("[MM2 Bot] Stopped.")
end

function TradeBot:stop()
	self.running = false
	print("[MM2 Bot] Stopping bot...")
end

return TradeBot
