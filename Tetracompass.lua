os.execute("cls")
local API = require("api")
local player = API.GetLocalPlayerName()
API.Write_ScripCuRunning0("t_Tetracompass: " .. player)

local function remove_after_space_and_number(text)
    local space_one_pos = string.find(text, " 1")
    if space_one_pos then
      return string.sub(text, 1, space_one_pos - 1)
    else
      return text
    end
end

local function ScanBank()
    local bankItems = API.FetchBankArray()
    local processedItems = {}
  
    for key, value in pairs(bankItems) do
      if value.itemid1 ~= 48447 then
        local cleanedText = remove_after_space_and_number(string.gsub(value.textitem, "<([^>]+)>", ""))
        local itemData = {
          cleanedText = cleanedText,
          size = value.itemid1_size,
          slotId = key - 1
        }
        table.insert(processedItems, itemData)
      end
    end
  
    return processedItems
  end
  
  local function CheckBankItemExists(targetName)
    local items = ScanBank() 

    for _, itemData in ipairs(items) do
      if itemData.cleanedText == targetName then
        local foundSlotId = itemData.slotId
        print("found", targetName, "at slot", foundSlotId)
        return true, foundSlotId
      end
    end
  
    return false, nil  -- No match found, return false and nil
  end

  local function SaveItemSizes()
    local items = ScanBank()
  
    local beastkeeperHelmSize = nil
    local orkCleaverSize = nil
    local ogreKyzajSize = nil
    local nosorogSculptureSize = nil
  
    for _, itemData in ipairs(items) do
      if itemData.cleanedText == "Beastkeeper helm (damaged)" then
        beastkeeperHelmSize = itemData.size
      elseif itemData.cleanedText == "Ork cleaver sword (damaged)" then
        orkCleaverSize = itemData.size
      elseif itemData.cleanedText == "Ogre Kyzaj axe (damaged)" then
        ogreKyzajSize = itemData.size
      elseif itemData.cleanedText == "'Nosorog!' sculpture (damaged)" then
        nosorogSculptureSize = itemData.size
      end
    end
  
    print("Saved sizes:")
    print("Beastkeeper helm:", beastkeeperHelmSize)
    print("Ork cleaver sword:", orkCleaverSize)
    print("Ogre Kyzaj axe:", ogreKyzajSize)
    print("Nosorog! sculpture:", nosorogSculptureSize)
  end
  

local function FindCache(targetID)
    local objects = API.ReadAllObjectsArray({-1}, {-1}, {})
  
    local cache = {}
    for _, npc in ipairs(objects) do
      local distance = API.Math_DistanceF(npc.Tile_XYZ, API.PlayerCoordfloat())
  
      if npc.Id == targetID and distance < 10 and npc.Bool1 == 0 then
        print("Found material cache at distance", distance)
        table.insert(cache, npc.Id)
      end
    end
  
    return { spots = cache }
end
  
local function FindBuffs(targetId, tolerance)
    local allBuffs = API.Buffbar_GetAllIDs()
    local buffs = {}
  
    for _, buff in ipairs(allBuffs) do
      if(buff.Id == targetID) then
        local buffValue = tonumber(buff.text)
        if (buffValue and buffValue < tolerance) then
          return false
        end
      end
    end
  
    return true
end

local function Crucible_Stands_Debris()

    if (not API.IsPlayerAnimating_(player, 5) and not API.IsPlayerMoving_(player)) then
        local caches = FindCache(117367)

        if #caches.spots > 0 then
            API.DoAction_Object1(0x2,0,{caches.spots[1]},50);
        end
        
    end

end

local function Yubiusk_Animal_Pen()

    if (not API.IsPlayerAnimating_(player, 5) and not API.IsPlayerMoving_(player)) then
        local caches = FindCache(117373)

        if #caches.spots > 0 then
            API.DoAction_Object1(0x2,0,{caches.spots[1]},50);
        end
        
    end

end
  
local function Yubiusk_Animal_Pen_Travel()
    if(API.PInAreaW(WPOINT.new(2409,2824,0), 10) and not API.IsPlayerAnimating_(player, 5) and not API.IsPlayerMoving_(player) and FindBuffs(51490, 450) == true and API.InvItemcount_1(29285) == 15) then
        print("heading to animal")
        API.DoAction_Object1(0x39,0,{ 117243 },50)
        API.RandomSleep2(1000,500,500)
        while(API.IsPlayerMoving_(player)) do
            print("Player is moving")
            API.RandomSleep2(1000,500,500)
        end
        API.RandomSleep2(2000,500,500)
        print("Sending option 3")
        API.KeyPress_("3")
        API.RandomSleep2(4500,500,500)
        API.DoAction_WalkerW(WPOINT.new(2293,7337,0))
        API.RandomSleep2(500,500,500)
        while(API.IsPlayerMoving_(player)) do
            print("Player is moving")
            API.RandomSleep2(1000,500,500)
        end
    end
end

local function ItemUsage()
  
    --if no porters, teleport to bank
    if(API.InvItemcount_1(29285) == 0 and FindBuffs(51490, 30) == false and API.InvItemcount_1(49976) == 0) then
        print("Inventory full, getting porters")
        API.DoAction_Interface(0xffffffff,0xc315,3,1464,15,0,3808)
        API.RandomSleep2(4500,500,500)
    end

    --sign of the porter usage
    if(FindBuffs(51490, 30) == false) then
        if(API.InvItemcount_1(29285) > 0) then
            print("using porters")
            API.DoAction_Interface(0xffffffff,0xae06,6,1464,15,2,4608)
            API.RandomSleep2(4500,500,500)
        end
    end

    --if inventory is full but we have porters
    if(API.InvItemcount_1(29285) > 0 and API.InvFull_()) then
        print("Inventory full, using porters...")
        API.DoAction_Interface(0xffffffff,0xae06,6,1464,15,2,4608)
        API.RandomSleep2(4500,500,500)
    end

    --complete tombs at arch guild
    if(API.InvItemcount_1(29285) == 0 and FindBuffs(51490, 30) == false and API.InvItemcount_1(49976) > 0) then
        print("Inventory full, but contains tomb, going to study")
        API.DoAction_Interface(0xffffffff,0xc315,2,1464,15,0,3808)
        API.RandomSleep2(1500,500,500)
        API.KeyPress_("1")
        API.RandomSleep2(1500,500,500)
        while(API.IsPlayerAnimating_(player, 5)) do
            print("Player is animating to hotspot")
            API.RandomSleep2(1000,500,500)
        end

        API.DoAction_Object1(0x34,0,{ 93020 },50)
        API.RandomSleep2(500,500,500)
        while(API.IsPlayerMoving_(player)) do
            print("Player is moving to stairs")
            API.RandomSleep2(1000,500,500)
        end
        API.RandomSleep2(1500,500,500)
        API.DoAction_WalkerW(WPOINT.new(3326,3377,0))
        API.RandomSleep2(500,500,500)
        while(API.IsPlayerMoving_(player)) do
            print("Player is moving to hotspot")
            API.RandomSleep2(1000,500,500)
        end
        API.DoAction_Object1(0x32,0,{ 116454 },50)
        API.RandomSleep2(1000,500,500)
        while(API.IsPlayerMoving_(player)) do
            print("Player is moving to study")
            API.RandomSleep2(1000,500,500)
        end
        API.RandomSleep2(1500,500,500)
        while(API.IsPlayerAnimating_(player, 5)) do
            print("Player is animating to hotspot")
            API.RandomSleep2(1000,500,500)
        end
    end

    --withdraw preset
    if(API.PInAreaW(WPOINT.new(2409,2824,0), 10) and not API.IsPlayerAnimating_(player, 5) and not API.IsPlayerMoving_(player) and FindBuffs(51490, 450) == true) then
        print("At bank area, withdrawing preset")
        API.DoAction_Object1(0x2e,80,{ 115427 },50)
        API.RandomSleep2(1500,500,500)
  
        while(API.IsPlayerMoving_(player)) do
            print("Player is moving")
            API.RandomSleep2(1000,500,500)
        end
  
        if(API.Compare2874Status(24, false)) then
            print("Bank is open, depositing all")
            API.DoAction_Interface(0xffffffff,0xffffffff,1,517,39,-1,3808)
            API.RandomSleep2(1000,500,500)
            API.KeyPress_("1")
            API.RandomSleep2(2500,500,500)
            Yubiusk_Animal_Pen_Travel()
        end
    end
  
    --if at bank withdraw and use porters
    if(API.PInAreaW(WPOINT.new(2409,2824,0), 10) and not API.IsPlayerAnimating_(player, 5) and not API.IsPlayerMoving_(player) and FindBuffs(51490, 450) == false) then
        print("At bank area, checking for porters")
        API.DoAction_Object1(0x2e,80,{ 115427 },50)
        API.RandomSleep2(1500,500,500)
  
        while(API.IsPlayerMoving_(player)) do
            print("Player is moving")
            API.RandomSleep2(1000,500,500)
        end
  
        if(API.Compare2874Status(24, false)) then
            print("Bank is open, depositing all")
            API.DoAction_Interface(0xffffffff,0xffffffff,1,517,39,-1,3808)
            local found, slotId = CheckBankItemExists("Sign of the porter VI")
            if found then
              print("found porters, withdrawing from slot", slotId)
              API.RandomSleep2(1500,500,500)
              API.DoAction_Interface(0xffffffff,0x7265,1,517,195,slotId,3808)
              API.RandomSleep2(500,500,500)
              API.DoAction_Interface(0x24,0xffffffff,1,517,306,-1,3808)
            end
        end
    end

    --if at bank and no porters found make some

    --if at bank and no porters and no mats to make any, stop script
end

API.Write_LoopyLoop(true)
while(API.Read_LoopyLoop())
do
    
    if (API.GetGameState2() == 2) then
        API.KeyPress_(" ")
        API.RandomSleep2(200, 200, 200)
    end

    if(API.GetGameState2() == 3) then
        API.DoRandomEvents()
        ItemUsage()
        Yubiusk_Animal_Pen()
    end

API.RandomSleep2(500, 3050, 12000)
end