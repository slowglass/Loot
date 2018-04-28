Slowglass = {}
Slowglass.LootAnnounce = {}

local LootAnnounce = Slowglass.LootAnnounce
LootAnnounce.name = 'LootAnnounce'
LootAnnounce.author = 'Slowglass'
LootAnnounce.version = '0.1.0'

local QualityText = {
		[0] = "Junk (Gray)",
		[1] = "Normal (White)" , 
		[2] = "Fine (Green)", 
		[3] = "Superior (Blue)" , 
		[4] = "Epic (Purple)" , 
		[5] = "Legendary (Orange)" 
}

local QualityColour = {
	[0] = "c707070",
	[1] = "cC0C0C0",
	[2] = "c064F0D",
	[3] = "c0000CC",
	[4] = "c660066",
	[5] = "cCC6600",
	[6] = "c660000"
}
local LastItemUpdated = {}

local function Col(c, msg) return "|"..QualityColour[c]..msg.."|r" end
local function Green(msg) return "|c064F0D"..msg.."|r" end

local function Announce(col, itemName, postfix)
   CHAT_SYSTEM:AddMessage(Col(6,"Loot Received: [ ") .. Col(col,itemName) .. Col(6," ]" .. postfix))
end

local function ShowMyLoot(quantity)
  local itemQuality = GetItemLinkQuality(LastItemUpdated.realItemName)
  local itemName = LocalizeString("<<C:1>>", LastItemUpdated.realItemName)
  
  local totals = "" 
  if (quantity > 1) then      
    totals = totals .. " x " .. tostring(quantity) .. " "
  end    
    
  if (LastItemUpdated.itemStackSize > 1) then
    totals = totals .. " - Stack: " .. tostring(LastItemUpdated.updateStackCount) .. "/" .. tostring(LastItemUpdated.itemStackSize)          
  end
      
  if (LastItemUpdated.totalItemCount > 1 and LastItemUpdated.totalItemCount ~= LastItemUpdated.updateStackCount) then
    totals = totals .. " - Total: " .. tostring(LastItemUpdated.totalItemCount)            
  end

	Announce(itemQuality, itemName, totals)
end

local function ShowLoot(receivedBy, itemName, quantity)

  local itemQuality = GetItemLinkQuality(itemName)
  local lItemName = LocalizeString("<<C:1>>", itemName)
  local lReceivedBy = LocalizeString("<<C:1>>", receivedBy)

  local totals = "" 
  if (quantity > 1) then      
    totals = totals .. " x " .. tostring(quantity) .. " "
  end    
  Announce(itemQuality, itemName, totals .. " by " .. lReceivedBy)
end

local function LootReceived(eventCode, receivedBy, itemName, quantity, itemSound, lootType, mine) 
  if lootType ~= LOOT_TYPE_ITEM then return end

  if (mine and LastItemUpdated.realItemName ~= nil) then
    ShowMyLoot(quantity)
  else
    ShowLoot(receivedBy, itemName, quantity)
  end

  LastItemUpdated.realItemName = nil
end

local function InventoryUpdate(eventCode, bagId, slotId, isNewItem, itemSoundCategory, updateReason)
  if updateReason == INVENTORY_UPDATE_REASON_DURABILITY_CHANGE then return end
  
  LastItemUpdated.totalItemCount    = GetItemTotalCount(bagId, slotId)
  LastItemUpdated.updateStackCount, LastItemUpdated.itemStackSize  = GetSlotStackSize(bagId, slotId)
  LastItemUpdated.realItemName      = GetItemLink(bagId, slotId, LINK_STYLE_DEFAULT)
end

local function OnLoad(eventCode, addOnName)
	if(addOnName ~= LootAnnounce.name) then return end
  EVENT_MANAGER:UnregisterForEvent(LootAnnounce.name, EVENT_ADD_ON_LOADED)
	EVENT_MANAGER:RegisterForEvent(LootAnnounce.name, EVENT_LOOT_RECEIVED,                LootReceived)
	EVENT_MANAGER:RegisterForEvent(LootAnnounce.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, InventoryUpdate)
end

EVENT_MANAGER:RegisterForEvent(LootAnnounce.name, EVENT_ADD_ON_LOADED, OnLoad)

