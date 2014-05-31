
local AutoTrade = false

local function Trade(text)
  local me = GetDisplayName()

  if text == nil then text="" end;
  local com = {}
  for word in string.gmatch(text,"%w+") do  
      table.insert(com, word)
  end
  if (com[1] == "auto") then
    AutoTrade = not AutoTrade
    d("Auto Trading is now ".. (AutoTrade and "ON" or "OFF"))
    return
  end

  local invite = com[1]
  if (com[1] == nil and "@slowglass" == me) then invite = "Iumini" end
  if (com[1] == nil and "@JProud" == me) then invite = "Neithan" end
  TradeInviteByName(invite)
end

local function AutoAcceptTrade(who)
  if (not AutoTrade) then return end
  d("Accepting Trade from "..who)
    TradeInviteAccept()
end

local function FinishTrade(who, state)
  if (not AutoTrade) then return end
  TradeAccept()
end

local function Initialise(self, addOnName)
  if(addOnName ~= "Loot") then return end
  
  EVENT_MANAGER:UnregisterForEvent("AutoTrade",EVENT_ADD_ON_LOADED)

  EVENT_MANAGER:RegisterForEvent("AutoTrade" , EVENT_TRADE_INVITE_CONSIDERING, AutoAcceptTrade)
  -- EVENT_MANAGER:RegisterForEvent("AutoTrade" , EVENT_TRADE_INVITE_WAITING, AcceptTrade)
  EVENT_MANAGER:RegisterForEvent("AutoTrade" , EVENT_TRADE_CONFIRMATION_CHANGED, FinishTrade)
  SLASH_COMMANDS["/trade"] = Trade
end

EVENT_MANAGER:RegisterForEvent("AutoTrade", EVENT_ADD_ON_LOADED, Initialise)
