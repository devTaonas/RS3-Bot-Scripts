print("Run Lua script procProteans.")

local API = require("api")
local procLib = require("procLib")

local startTime = os.time()
local startTime2 = os.time()
local idleTimeThreshold = math.random(120, 260)
local timerDuration = 60  -- Timer duration in seconds
API.Write_ScripCuRunning0("procWells")

local function AntiAFK()
    local currentTime = os.time()
    local elapsedTime = os.difftime(currentTime, startTime2)

    if elapsedTime >= idleTimeThreshold then
        API.PIdle2()
        startTime2 = os.time()
        idleTimeThreshold = math.random(200, 280)
        print("Reset Timer & Threshhold")
    end
end

local HERBLOREStartXP = API.GetSkillXP("HERBLORE")
local firstRun = true;

local function InitHERBLOREGUI()
    guiBackPlate = API.CreateIG_answer();
    guiBackPlate.box_name = "back";
    guiBackPlate.box_start = FFPOINT.new(0, 0, 0)
    guiBackPlate.box_size = FFPOINT.new(400, 45, 0)
    guiBackPlate.colour = ImColor.new(15, 13, 18, 255)
    guiBackPlate.string_value = ""
     
    progressBar = API.CreateIG_answer()
    progressBar.box_start = FFPOINT.new(5, 4, 0)
    progressBar.box_name = "ProgressBar"
    progressBar.colour = ImColor.new(50,205,50);
    progressBar.string_value = "HERBLORE XP"
end

local function DrawHERBLOREGUI()

    API.DrawSquareFilled(guiBackPlate)

    local skill = "HERBLORE"
    local currentXp = API.GetSkillXP(skill)
    local elapsedMinutes = (os.time() - startTime) / 60
    local diffXp = math.abs(currentXp - HERBLOREStartXP);
    local xpPH = procLib.RoundNumber((diffXp * 60) / elapsedMinutes);
    local time = procLib.FormatElapsedTime(startTime)
    local currentLevel = API.XPLevelTable(API.GetSkillXP(skill))
    progressBar.radius = procLib.ProgressBarPercentage(skill, API.GetSkillXP(skill)) / 100
    progressBar.string_value = time .. " | " .. "Level" .. ": " .. currentLevel .. " | XP:" .. (API.GetSkillXP("HERBLORE") - HERBLOREStartXP) .. " | XP/H: " .. procLib.FormatNumber(xpPH) .. ""
    API.DrawProgressBar(progressBar)
end

InitHERBLOREGUI()


local function procWells()

    if(not API.isProcessing()) then
        print("Making protean shakes")
        API.DoAction_Object1(0x3f,0,{ 89770 },50)
        API.RandomSleep2(600, 800, 1200)
        API.KeyPress_(" ")
        API.RandomSleep2(300, 500, 800)
    end

end

--Exported function list is in API
--main loop
API.Write_LoopyLoop(true)
while(API.Read_LoopyLoop())
do-----------------------------------------------------------------------------------


        DrawHERBLOREGUI()
        API.DoRandomEvents()
        procLib.IncenseSticks()
        AntiAFK()
        procWells()





API.RandomSleep2(500, 3050, 12000)
end----------------------------------------------------------------------------------
