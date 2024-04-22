os.execute("cls")
print("Run Lua script procFishFarm.")

local API = require("api")
local Utils = require("utils")
local procLib = require("procLib")

local startTime = os.time()
local firemakingStartXP = API.GetSkillXP("FISHING")
local firstRun = true;


local function InitFishingGUI()
    guiBackPlate = API.CreateIG_answer();
    guiBackPlate.box_name = "back";
    guiBackPlate.box_start = FFPOINT.new(0, 0, 0)
    guiBackPlate.box_size = FFPOINT.new(400, 45, 0)
    guiBackPlate.colour = ImColor.new(15, 13, 18, 255)
    guiBackPlate.string_value = ""
     
    progressBar = API.CreateIG_answer()
    progressBar.box_start = FFPOINT.new(5, 4, 0)
    progressBar.box_name = "ProgressBar"
    progressBar.colour = ImColor.new(220,20,60);
    progressBar.string_value = "Fishing XP"
end

local function DrawFishingGUI()

    API.DrawSquareFilled(guiBackPlate)

    local skill = "FISHING"
    local currentXp = API.GetSkillXP(skill)
    local elapsedMinutes = (os.time() - startTime) / 60
    local diffXp = math.abs(currentXp - firemakingStartXP);
    local xpPH = procLib.RoundNumber((diffXp * 60) / elapsedMinutes);
    local time = procLib.FormatElapsedTime(startTime)
    local currentLevel = API.XPLevelTable(API.GetSkillXP(skill))
    progressBar.radius = procLib.ProgressBarPercentage(skill, API.GetSkillXP(skill)) / 100
    progressBar.string_value = time .. " | " .. "Level" .. ": " .. currentLevel .. " | XP:" .. (API.GetSkillXP("FISHING") - firemakingStartXP) .. " | XP/H: " .. procLib.FormatNumber(xpPH) .. ""
    API.DrawProgressBar(progressBar)
end


InitFishingGUI()

local function DropItems(itemId) 
    local i = 0
    local inv = API.ReadInvArrays33()
    if #inv > 0 then
        for _, a in pairs(inv) do
            if(a.itemid1 == itemId) then
                API.DoAction_Interface(0x24,0xe5,8,1473,5,i,6112);
                API.RandomSleep2(200, 400, 800)
            end
            i = i + 1
        end
    end

end

local function BankAll()
    if(API.BankOpen2()) then
        API.DoAction_Interface(0xffffffff,0xffffffff,1,517,39,-1,5392);
    end
end

local function Above68Under91()
    local player = API.GetLocalPlayerName()
    local distanceToSpot = API.Math_DistanceW(API.PlayerCoord(), WPOINT.new(2614, 3385, 0))
    local distanceToSwarm = API.Math_DistanceW(API.PlayerCoord(), WPOINT.new(2098, 7078, 0))
    local isFishing = API.IsPlayerAnimating_(player, 20)
    local insideSpot = false;

    if(API.Math_DistanceW(API.PlayerCoord(), WPOINT.new(2135, 7107, 0)) < 200) then
        insideSpot = true
    end

    procLib.WriteLog("Fishing 68-91: " .. tostring(isFishing))

    if(distanceToSpot > 30 and insideSpot == false) then
        procLib.Lodestone(14)
        procLib.WebWalker(2614, 3385, 0)
        API.RandomSleep2(500, 700, 1500)
        API.DoAction_Object1(0x3f,0,{ 49016 },50)
        API.RandomSleep2(500, 700, 1500)
        procLib.WebWalker(2594, 3410, 0)
        API.RandomSleep2(500, 700, 1500)
        API.DoAction_NPC(0x3c, API.OFF_ACT_InteractNPC_route, {25190}, 15)
        API.WaitUntilMovingEnds()
        API.RandomSleep2(500, 700, 1500)
        API.KeyPress_("\32")
        API.RandomSleep2(800, 1100, 1500)
        API.Select_Option("Sure")
        API.RandomSleep2(3000, 4000, 4500)
        API.DoAction_Object1(0x3f,0,{ 110591 },50)
        API.RandomSleep2(500, 700, 1500)

        if(API.BankOpen2()) then
            API.DoAction_Interface(0xffffffff,0xffffffff,1,517,39,-1,5392);
        end
    end

    if(API.InvFull_()) then
        procLib.WebWalker(2098,7093, 0)
        API.DoAction_Object1(0x29, API.OFF_ACT_GeneralObject_route1, {110857}, 50)
    end

    if(distanceToSwarm < 50 and isFishing == false and API.Invfreecount_() > 0) then
        API.RandomSleep2(500, 700, 700)
        procLib.WebWalker(2098, 7078,0)
        local spots = procLib.FindEntity(1, "Swarm")
        API.DoAction_NPC(0x3c, API.OFF_ACT_InteractNPC_route, {spots.npcs[1]}, 15)
        API.RandomSleep2(500, 700, 1500)
        API.WaitUntilMovingEnds()
    end

    ---if(API.XPLevelTable(API.GetSkillXP("FISHING")) == 91) then
    ---    procLib.WebWalker(2098,7078, 0)
    ---    API.DoAction_Object1(0x3f,0,{ 110857 },50)
    ---    API.RandomSleep2(500, 700, 1500)
    ---    API.DoAction_Interface(0x24,0xffffffff,1,11,5,-1,5392)
    ---end
end

local function Above20Under68()

    local player = API.GetLocalPlayerName()
    local distance = API.Math_DistanceW(API.PlayerCoord(), WPOINT.new(3107, 3433, 0))
    local isFishing = API.IsPlayerAnimating_(player, 20)

    procLib.WriteLog("Fishing 20-68: " .. tostring(isFishing))

    if(distance > 10) then
        procLib.Lodestone(16)
        procLib.WebWalker(3107, 3433, 0)
    end

    if(API.InvFull_()) then
        DropItems(335)
        DropItems(331)
    end

    if(distance < 25 and isFishing == false and API.Invfreecount_() > 0) then
        
        local spots = procLib.FindEntity(1, "Fishing spot")
        API.DoAction_NPC(0x3c, API.OFF_ACT_InteractNPC_route, {spots.npcs[1]}, 15)
        API.RandomSleep2(500, 700, 1500)
        API.WaitUntilMovingEnds()
    end

    if(API.XPLevelTable(API.GetSkillXP("FISHING")) == 68) then
        DropItems(335)
        DropItems(331)
    end
end

local function Under20() 

    local player = API.GetLocalPlayerName()
    local distance = API.Math_DistanceW(API.PlayerCoord(), WPOINT.new(3257, 3206, 0))
    local isFishing = API.IsPlayerAnimating_(player, 20)

    procLib.WriteLog("Fishing: " .. tostring(isFishing))

    if(distance > 10) then
        procLib.Lodestone(18)
        procLib.WebWalker(3257, 3206, 0)
    end

    if(API.InvFull_()) then
        DropItems(13435)
    end

    if(distance < 10 and isFishing == false and API.Invfreecount_() > 0) then
        local spots = procLib.FindEntity(1, "Fishing spot")
        API.DoAction_NPC(0x3c, API.OFF_ACT_InteractNPC_route, {spots.npcs[1]}, 15)
        API.RandomSleep2(500, 700, 1500)
        API.WaitUntilMovingEnds()
    end

    if(API.XPLevelTable(API.GetSkillXP("FISHING")) == 20) then
        DropItems(13435)
    end

end

local function Path()

    local fishingLevel = API.XPLevelTable(API.GetSkillXP("FISHING"))
    if(fishingLevel <= 19) then
        Under20()
    end

    if(fishingLevel >= 20 and fishingLevel < 68) then
        Above20Under68()
    end

    if(fishingLevel >= 68) then --and fishingLevel < 91
        Above68Under91()
    end
end

local firstRun = true;

API.Write_LoopyLoop(true)
while(API.Read_LoopyLoop())
do-----------------------------------------------------------------------------------

    procLib.Login()
    procLib.Lobby()
    procLib.AntiAFK()

    if (API.GetGameState() == 3) then

        if(firstRun) then
            local player = API.GetLocalPlayerName()
            API.Write_ScripCuRunning0("procFishFarm: " .. player)
            firstRun = false;
        end

        API.DoRandomEvents()
        DrawFishingGUI()
        Path()
    end



API.RandomSleep2(500, 3050, 12000)
end----------------------------------------------------------------------------------
