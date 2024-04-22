os.execute("cls")
local API = require("api")
local player = API.GetLocalPlayerName()
API.Write_ScripCuRunning0("Hellfire: " .. player)

local idleTimeThreshold = math.random(120, 260)
local startTime = os.time()

local function AntiAFK()
    local currentTime = os.time()
    local elapsedTime = os.difftime(currentTime, startTime)

    if elapsedTime >= idleTimeThreshold then
        API.PIdle2()
        startTime = os.time()
        idleTimeThreshold = math.random(200, 280)
        print("Reset Timer & Threshhold")
    end
end

local function FindJellies()
    local allNPCS = API.ReadAllObjectsArray({-1}, {-1}, {})
    local jellies = {}
    if #allNPCS > 0 then
        for _, a in pairs(allNPCS) do
            if(a.Id > 0) then
                --print(a.Id .. " - " .. a.Name)
                local distance = API.Math_DistanceF(a.Tile_XYZ, API.PlayerCoordfloat())
                a.Distance = distance;
                if a.Id ~= 0 and distance < 25 and a.Bool1 == 0 then
                    if a.Id == 116425 then
                        if(a.Distance > 5 and not API.IsPlayerAnimating_(player, 5)) then
                            --API.DoAction_WalkerW(WPOINT.new(2642,7466,0))
                            if(API.PInAreaW(WPOINT.new(2648,7466,0), 2) and API.IsPlayerMoving_(player) == false) then
                                API.DoAction_WalkerW(WPOINT.new(2641,7465,0))
                                API.RandomSleep2(4500,500,500)
                            end

                            if(API.PInAreaW(WPOINT.new(2637,7463,0), 2) and API.IsPlayerMoving_(player) == false) then
                                API.DoAction_WalkerW(WPOINT.new(2648,7466,0))
                                API.RandomSleep2(4500,500,500)
                            end
                        end
                        print("found material cache at distance " .. distance)
                        table.insert(jellies, a.Id)
                    end
                end
            end
            
        end
        
        return { npcs = jellies }
    end
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

local function Hellfire_Metal()
    
    if (not API.IsPlayerAnimating_(player, 5) and not API.IsPlayerMoving_(player)) then
        
        print("finding caches")
        local jellies = FindJellies()

        if #jellies.npcs > 0 then
            print("DoAction")
            API.DoAction_Object1(0x2,0,{jellies.npcs[1]},50);
        end
    end

    if(API.PInAreaW(WPOINT.new(3259,3499,0), 100) and FindBuffs(51490, 450) == true) then
        API.DoAction_Object1(0x39,0,{ 116691 },50)
        API.RandomSleep2(1500,500,500)
        while(API.IsPlayerMoving_(player)) do
            print("Player is moving")
            API.RandomSleep2(1000,500,500)
        end
        API.KeyPress_("3")
        API.RandomSleep2(4000,500,500)
        API.DoAction_WalkerW(WPOINT.new(2581,7423,0))
        while(API.IsPlayerMoving_(player)) do
            print("Player is moving")
            API.RandomSleep2(1000,500,500)
        end
        API.DoAction_Object1(0x39,0,{ 116736 },50)
        API.RandomSleep2(4000,500,500)
        API.DoAction_WalkerW(WPOINT.new(2640,7465,0))
        while(API.IsPlayerMoving_(player)) do
            print("Player is moving")
            API.RandomSleep2(1000,500,500)
        end
    end
end

local function IsAtBank()
    return API.PInAreaW(WPOINT.new(2409, 2824, 0), 10) and not API.IsPlayerAnimating_(player, 5) and not API.IsPlayerMoving_(player)
  end
  
  local function TeleportToBank()
    print("Inventory full, getting porters")
    API.DoAction_Interface(0xffffffff, 0xc315, 3, 1464, 15, 0, 3808)
    API.RandomSleep2(4500, 500, 500)
  end
  
  local function GoToArchGuild()
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
  
  local function ItemUsage()
  
      local function usePorter()
          print("using porters")
          API.DoAction_Interface(0xffffffff, 0xae06, 6, 1464, 15, 2, 4608)
          API.RandomSleep2(4500, 500, 500)
      end
  
      local function withdrawPreset()
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
              API.RandomSleep2(1500,500,500)
              API.KeyPress_("1")
              API.RandomSleep2(2500,500,500)
          end
      end
  
      local function checkForPorters()
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
                API.RandomSleep2(2500,500,500)
                API.DoAction_Interface(0x24,0xffffffff,1,517,306,-1,3808)
                API.RandomSleep2(2500,500,500)
              end
          end
      end
  
      if API.InvItemcount_1(29285) == 0 and not FindBuffs(51490, 20) and API.InvItemcount_1(49976) == 0 and not API.PInAreaW(WPOINT.new(3259,3499,0), 100) then
          TeleportToBank()
      elseif(API.PInAreaW(WPOINT.new(3259,3499,0), 100) and not API.IsPlayerAnimating_(player, 5) and not API.IsPlayerMoving_(player) and FindBuffs(51490, 450) == false and API.InvItemcount_1(29285) == 0) then
          checkForPorters()
      elseif not FindBuffs(51490, 20) and API.InvItemcount_1(29285) > 0 then
          usePorter()
      elseif API.InvItemcount_1(29285) > 0 and API.InvFull_() then
          usePorter()
      elseif API.InvItemcount_1(29285) == 0 and not FindBuffs(51490, 20) and API.InvItemcount_1(49976) > 0 then
          GoToArchGuild()
      elseif IsAtBank() then
          withdrawPreset()
      end
  
      -- Additional conditions for handling other scenarios can be added here
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
        AntiAFK()
        Hellfire_Metal()
        ItemUsage();
    end

API.RandomSleep2(500, 3050, 12000)
end