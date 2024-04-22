print("Run Lua script procPrawnBrocker.")

local API = require("api")
local procLib = require("procLib")

local initialize = true;
local butcherRunning = false

local startTime = os.time()
local ConstructionStartXP = API.GetSkillXP("CONSTRUCTION")

local function InitConstructionGUI()
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
    progressBar.string_value = "Construction XP"
end

local function DrawConstructionGUI()

    API.DrawSquareFilled(guiBackPlate)

    local skill = "CONSTRUCTION"
    local currentXp = API.GetSkillXP(skill)
    local elapsedMinutes = (os.time() - startTime) / 60
    local diffXp = math.abs(currentXp - ConstructionStartXP);
    local xpPH = procLib.RoundNumber((diffXp * 60) / elapsedMinutes);
    local time = procLib.FormatElapsedTime(startTime)
    local currentLevel = API.XPLevelTable(API.GetSkillXP(skill))
    progressBar.radius = procLib.ProgressBarPercentage(skill, API.GetSkillXP(skill)) / 100
    progressBar.string_value = time .. " | " .. "Level" .. ": " .. currentLevel .. " | XP:" .. (API.GetSkillXP("CONSTRUCTION") - ConstructionStartXP) .. " | XP/H: " .. procLib.FormatNumber(xpPH) .. ""
    API.DrawProgressBar(progressBar)
end

InitConstructionGUI()

local function Work()
    local isWorking = API.isProcessing()

    if(not isWorking and not butcherRunning and API.InvItemcount_1(8782) == 0) then
        procLib.WriteLog("Fetching more mahogany planks")
        API.DoAction_Inventory1(8783, 0, 2, 4432)
        API.RandomSleep2(700, 1000, 1000)
        API.DoAction_NPC(0x24,1408,{ 4243 },50)
        API.RandomSleep2(500, 800, 1500)

        if(not butcherRunning and API.Select_Option("Un-cert another")) then
            butcherRunning = true
            procLib.WriteLog("Waiting for butler to return")
            API.RandomSleep2(1500, 2000, 3500)
        end

        if(not butcherRunning and API.Select_Option("Un-cert")) then
            API.RandomSleep2(500, 500, 500)
            API.KeyPress_("2")
            API.RandomSleep2(200, 500, 600)
            API.KeyPress_("4")
            API.RandomSleep2(200, 500, 600)
            API.KeyPress_("\13")
            API.RandomSleep2(200, 500, 600)
            butcherRunning = true
            procLib.WriteLog("Waiting for butler to return")
            API.RandomSleep2(1500, 2000, 3500)
        end
    end

    if(not isWorking and API.InvItemcount_1(8782) > 0) then

        procLib.WriteLog("Building PrawnBroker: " .. API.VB_FindPSett(2874, 0).state)

        local built = procLib.FindEntity(0, "Flotsam prawnbroker")

        if(#built.npcs > 0) then
            API.RandomSleep2(1200, 1500, 1500)
            API.DoAction_Object1(0x29,5712,{ 96658 },50,{13590,3337,0})
            API.RandomSleep2(200, 500, 600)
        end

        if(API.VB_FindPSett(2874, 0).state == 0 or API.VB_FindPSett(2874, 0).state == 12) then
            API.DoAction_Object1(0x3f,0,{96656},50)
            API.RandomSleep2(200, 500, 600)
        end

        if(API.VB_FindPSett(2874, 0).state == 75) then
            API.DoAction_Interface(0xffffffff,0xffffffff,0,1306,13,4,4512)
            API.RandomSleep2(200, 500, 600)
        end
        
        if(butcherRunning) then
            butcherRunning = false
        end

    end
end

API.Write_LoopyLoop(true)
while(API.Read_LoopyLoop())
do-----------------------------------------------------------------------------------

    procLib.Lobby()
    procLib.AntiAFK()

    if (API.GetGameState() == 3) then

        API.DoRandomEvents()
        if(initialize) then
            local player = API.GetLocalPlayerName()
            API.Write_ScripCuRunning0("procPrawnBroker: " .. player)
            initialize = false;
        end

        Work()
        DrawConstructionGUI()
    end

API.RandomSleep2(500, 1000, 1000)
end----------------------------------------------------------------------------------
