os.execute("cls")
local API = require("api")
local player = API.GetLocalPlayerName()
local idleTimeThreshold = math.random(120, 260)
local startTime = os.time()

API.Write_ScripCuRunning0("t_Tetracompass: " .. player)

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
  
    return false, nil
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
      API.KeyPress_("1")
      API.RandomSleep2(4500,500,500)
      API.DoAction_WalkerW(WPOINT.new(2383,7320,0))
      API.RandomSleep2(500,500,500)
      while(API.IsPlayerMoving_(player)) do
          print("Player is moving")
          API.RandomSleep2(1000,500,500)
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

    if API.InvItemcount_1(29285) == 0 and not FindBuffs(51490, 20) and API.InvItemcount_1(49976) == 0 and not API.PInAreaW(WPOINT.new(2409,2824,0), 10) then
        TeleportToBank()
    elseif(API.PInAreaW(WPOINT.new(2409,2824,0), 10) and not API.IsPlayerAnimating_(player, 5) and not API.IsPlayerMoving_(player) and FindBuffs(51490, 450) == false and API.InvItemcount_1(29285) == 0) then
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

local function InitGUI()
  guiFrame = API.CreateIG_answer();
  guiFrame.box_name = "back";
  guiFrame.box_start = FFPOINT.new(0, 0, 0)
  guiFrame.box_size = FFPOINT.new(310, 150, 0)
  guiFrame.colour = ImColor.new(15, 13, 18, 200)
  guiFrame.string_value = ""

  guiTitleBarText = API.CreateIG_answer()
  guiTitleBarText.box_start = FFPOINT.new(60, 4, 0)
  guiTitleBarText.colour = ImColor.new(141, 145, 1)
  guiTitleBarText.box_name = "titleBar"
  guiTitleBarText.string_value = "### Taonas Tetracompass ###"

  guiComboBox = API.CreateIG_answer()
  guiComboBox.box_name = "| "
  guiComboBox.box_start = FFPOINT.new(1,15,0)
  guiComboBox.box_size = FFPOINT.new(140, 50, 0)
  guiComboBox.stringsArr = {"","Artefacts", "Materials","Restoring", "Collection" , "Completing"}

  guiSeparator = API.CreateIG_answer()
  guiSeparator.box_start = FFPOINT.new(12, 45, 0)
  guiSeparator.colour = ImColor.new(141, 145, 1)
  guiSeparator.box_name = "guiSeparator"
  guiSeparator.string_value = "----------------------------------------"
end

local artefactsGuiBool = false;
local enableRoutine = false;
local function DrawGUI()

  API.DrawSquareFilled(guiFrame)
  API.DrawComboBox(guiComboBox, false)
  API.DrawTextAt(guiTitleBarText)
  API.DrawTextAt(guiSeparator)

  if (guiComboBox.return_click) then
    guiComboBox.return_click = false
  end

  if(guiComboBox ~= nil and guiComboBox.string_value ~= "Artefacts") then
    artefactsGuiBool = false;
  end

  if(guiComboBox2 ~= nil and guiComboBox.string_value == "") then
    enableRoutine = false;
  end

  if(guiComboBox2 ~= nil and guiComboBox2.string_value == "") then
    enableRoutine = false;
  end

  if(guiComboBox.string_value == "Artefacts" and artefactsGuiBool == false) then
    print("Artefacts selected")
    guiComboBox2 = API.CreateIG_answer()
    guiComboBox2.box_name = "   "
    guiComboBox2.box_start = FFPOINT.new(110,15,0)
    guiComboBox2.box_size = FFPOINT.new(275, 50, 0)
    guiComboBox2.stringsArr = {"","Yubiusk Animal Pen", "Crucible Stands Debris"}
    artefactsGuiBool = true
  end

  if(guiComboBox.string_value == "Artefacts" and artefactsGuiBool == true) then
    API.DrawComboBox(guiComboBox2, false)

    if(guiComboBox2.string_value == "Yubiusk Animal Pen") then
      enableRoutine = true;
      Yubiusk_Animal_Pen()
    end

    if(guiComboBox2.string_value == "Crucible Stands Debris") then
      enableRoutine = true;
      Crucible_Stands_Debris()
    end
  end

end

InitGUI()
API.Write_LoopyLoop(true)
while(API.Read_LoopyLoop())
do
    
    if (API.GetGameState2() == 2) then
        API.KeyPress_(" ")
        API.RandomSleep2(200, 200, 200)
    end

    if(API.GetGameState2() == 3) then
        API.DoRandomEvents()
        DrawGUI()
        if(enableRoutine) then
          ItemUsage()
        end
        AntiAFK()
    end

API.RandomSleep2(500, 3050, 12000)
end