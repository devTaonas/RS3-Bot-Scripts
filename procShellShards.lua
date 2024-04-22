os.execute("cls")
print("############################")
print("# Starting procShellShards #")
print("############################")
print("")
print("")
local API = require("api")
local Utils = require("utils")
local procLib = require("procLib")

local startTime = os.time()
local firemakingStartXP = API.GetSkillXP("FIREMAKING")
local firstRun = true;

local function InitFiremakingGUI()
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
    progressBar.string_value = "Firemaking XP"
end

local function DrawFiremakingGUI()

    API.DrawSquareFilled(guiBackPlate)

    local skill = "FIREMAKING"
    local currentXp = API.GetSkillXP(skill)
    local elapsedMinutes = (os.time() - startTime) / 60
    local diffXp = math.abs(currentXp - firemakingStartXP);
    local xpPH = procLib.RoundNumber((diffXp * 60) / elapsedMinutes);
    local time = procLib.FormatElapsedTime(startTime)
    local currentLevel = API.XPLevelTable(API.GetSkillXP(skill))
    progressBar.radius = procLib.ProgressBarPercentage(skill, API.GetSkillXP(skill)) / 100
    progressBar.string_value = time .. " | " .. "Level" .. ": " .. currentLevel .. " | XP:" .. (API.GetSkillXP("FIREMAKING") - firemakingStartXP) .. " | XP/H: " .. procLib.FormatNumber(xpPH) .. ""
    API.DrawProgressBar(progressBar)
end

InitFiremakingGUI()

API.Write_LoopyLoop(true)
while(API.Read_LoopyLoop())
do-----------------------------------------------------------------------------------

    DrawFiremakingGUI()

    if (API.GetGameState2() == 3) then
        if(firstRun) then
            local player = API.GetLocalPlayerName()
            API.Write_ScripCuRunning0("procShellShards: " .. player)
            firstRun = false;
        end

        API.DoRandomEvents()
        --procLib.IncenseSticks()

        if(not API.isProcessing()) then
            API.DoAction_Interface(0x41,0xcf65,2,1473,5,7,3808)
            API.RandomSleep2(600, 800, 1200)
            API.KeyPress_(" ")
            API.RandomSleep2(300, 500, 800)
        end
    end

API.RandomSleep2(500, 3050, 12000)
end----------------------------------------------------------------------------------

