
local LastItemUpdated = {}

local function Green(msg) return "|c064F0D"..msg.."|r" end

local function TimeStamp()
  if (pChat==nil or pChat.opts == nil or pChat.opts.showTimestamp == nil) then return "" end
  if (pChat.opts.colours==nil or pChat.opts.colours.timestamp == nil) then return "" end
  if pChat.opts.showTimestamp ~= true then return "" end
  return string.format("%s[%s] ", pChat.opts.colours.timestamp, GetTimeString())
end

local function ShowMyLoot(quantity)
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

  CHAT_SYSTEM:AddMessage(TimeStamp()..Green("Loot Received: [ ") .. itemName .. Green(" ]" .. totals))
end

local function ShowLoot(receivedBy, itemName, quantity)
  local lItemName = LocalizeString("<<C:1>>", itemName)
  local lReceivedBy = LocalizeString("<<C:1>>", receivedBy)

  local totals = "" 
  if (quantity > 1) then      
    totals = totals .. " x " .. tostring(quantity) .. " "
  end    

  CHAT_SYSTEM:AddMessage(TimeStamp()..Green("Loot Received: [ ") .. lItemName .. Green(" ]" .. totals .. " by " .. lReceivedBy))
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

local function Initialise(self, addOnName)
  if(addOnName ~= "Loot") then return end
  
  EVENT_MANAGER:UnregisterForEvent("Loot",EVENT_ADD_ON_LOADED)
  EVENT_MANAGER:RegisterForEvent("Loot" , EVENT_LOOT_RECEIVED,                LootReceived) 
  EVENT_MANAGER:RegisterForEvent("Loot" , EVENT_INVENTORY_SINGLE_SLOT_UPDATE, InventoryUpdate)
end

EVENT_MANAGER:RegisterForEvent("Loot", EVENT_ADD_ON_LOADED, Initialise)
