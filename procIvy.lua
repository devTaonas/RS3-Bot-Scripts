print("Run Lua script procIvy.")

local API = require("api")
local Utils = require("utils")
local procLib = require("procLib")

local startTime = os.time()
local WOODCUTTINGStartXP = API.GetSkillXP("WOODCUTTING")
local firstRun = true;

local function InitWoodcuttingGUI()
    guiBackPlate = API.CreateIG_answer();
    guiBackPlate.box_name = "back";
    guiBackPlate.box_start = FFPOINT.new(0, 0, 0)
    guiBackPlate.box_size = FFPOINT.new(400, 45, 0)
    guiBackPlate.colour = ImColor.new(15, 13, 18, 255)
    guiBackPlate.string_value = ""
     
    progressBar = API.CreateIG_answer()
    progressBar.box_start = FFPOINT.new(5, 4, 0)
    progressBar.box_name = "ProgressBar"
    progressBar.colour = ImColor.new(0,128,0);
    progressBar.string_value = "WOODCUTTING XP"
end

local function DrawWoodcuttingGUI()

    API.DrawSquareFilled(guiBackPlate)

    local skill = "WOODCUTTING"
    local currentXp = API.GetSkillXP(skill)
    local elapsedMinutes = (os.time() - startTime) / 60
    local diffXp = math.abs(currentXp - WOODCUTTINGStartXP);
    local xpPH = procLib.RoundNumber((diffXp * 60) / elapsedMinutes);
    local time = procLib.FormatElapsedTime(startTime)
    local currentLevel = API.XPLevelTable(API.GetSkillXP(skill))
    progressBar.radius = procLib.ProgressBarPercentage(skill, API.GetSkillXP(skill)) / 100
    progressBar.string_value = time .. " | " .. "Level" .. ": " .. currentLevel .. " | XP:" .. (API.GetSkillXP("WOODCUTTING") - WOODCUTTINGStartXP) .. " | XP/H: " .. procLib.FormatNumber(xpPH) .. ""
    API.DrawProgressBar(progressBar)
end

local function ChopIvy() 

    local player = API.GetLocalPlayerName()
    local isWorking = API.IsPlayerAnimating_(player, 7)

    if(isWorking == false) then
        API.DoAction_Object1(0x3b,0,{ 46324 },50);
        API.RandomSleep2(1000, 1500, 1500)
    end
end

InitWoodcuttingGUI()

API.Write_LoopyLoop(true)
while(API.Read_LoopyLoop())
do-----------------------------------------------------------------------------------

    procLib.Login()
    procLib.Lobby()
    procLib.AntiAFK()
    procLib.IncenseSticks()
    DrawWoodcuttingGUI()

    if(API.GetGameState() == 3) then
        API.DoRandomEvents()
        ChopIvy()
    end

API.RandomSleep2(500, 3050, 12000)
end----------------------------------------------------------------------------------
