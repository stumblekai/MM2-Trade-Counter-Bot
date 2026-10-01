local Pricing = require(script.Parent.Pricing)
local Config = require(script.Parent.Config)

local TradeScanner = {}
TradeScanner.__index = TradeScanner

local function getPlayerGui()
	local gui = game:GetService("Players").LocalPlayer:FindFirstChild("PlayerGui")
	if gui then
		return gui
	end
	return nil
end

function TradeScanner.new()
	local self = setmetatable({}, TradeScanner)
	self.Config = Config
	self.Pricing = Pricing
	return self
end

function TradeScanner:normalizeText(text)
	return Pricing.normalizeKey(text)
end

function TradeScanner:findTradeGui()
	local gui = getPlayerGui()
	if not gui then
		return nil
	end

	for _, obj in ipairs(gui:GetDescendants()) do
		if obj:IsA("Frame") or obj:IsA("ScreenGui") then
			local name = self:normalizeText(obj.Name)
			for _, keyword in ipairs(self.Config.tradeKeywords) do
				if name:find(keyword) then
					return obj
				end
			end
		end
	end

	return nil
end

function TradeScanner:getVisibleTextLabels(container)
	local labels = {}
	if not container then
		return labels
	end

	for _, obj in ipairs(container:GetDescendants()) do
		if obj:IsA("TextLabel") or obj:IsA("TextButton") then
			local text = tostring(obj.Text or "")
			if text ~= "" then
				table.insert(labels, text)
			end
		end
	end

	return labels
end

function TradeScanner:findItemNameFromText(text)
	local normalizedText = self:normalizeText(text)
	if normalizedText == "" then
		return nil, nil
	end

	for itemName, value in pairs(self.Pricing.Prices) do
		if self:normalizeText(itemName) == normalizedText then
			return itemName, value
		end
	end

	return nil, nil
end

function TradeScanner:scanTradeForItems()
	local tradeGui = self:findTradeGui()
	if not tradeGui then
		return {}
	end

	local found = {}
	local seen = {}
	for _, text in ipairs(self:getVisibleTextLabels(tradeGui)) do
		local itemName, value = self:findItemNameFromText(text)
		if itemName and value then
			local key = self:normalizeText(itemName)
			if not seen[key] then
				seen[key] = true
				table.insert(found, { name = itemName, value = value, hasPrice = true })
			end
		else
			local trimmedText = tostring(text):gsub("^%s+", ""):gsub("%s+$", "")
			if trimmedText ~= "" then
				local key = self:normalizeText(trimmedText)
				if not seen[key] then
					seen[key] = true
					table.insert(found, { name = trimmedText, value = 0, hasPrice = false })
				end
			end
		end
	end

	return found
end

function TradeScanner:filterBlacklist(itemList)
	local filtered = {}
	local blacklistedItems = {}

	for _, item in ipairs(itemList) do
		local key = self:normalizeText(item.name)
		if self.Pricing.Blacklist[key] then
			table.insert(blacklistedItems, item.name)
		else
			table.insert(filtered, item)
		end
	end

	return filtered, blacklistedItems
end

function TradeScanner:parseTradeTotals(itemList)
	local totals = {
		ancients = 0,
		uniques = 0,
		chromas = 0,
		godlies = 0,
	}

	for _, item in ipairs(itemList) do
		local text = self:normalizeText(item.name)
		if text:find("ancient") then
			totals.ancients += 1
		elseif text:find("unique") then
			totals.uniques += 1
		elseif text:find("chroma") then
			totals.chromas += 1
		elseif text:find("godly") then
			totals.godlies += 1
		end
	end

	return totals
end

return TradeScanner
