print("Started DeepSeaFisher")

local API = require("api")
local UTILS = require("utils")

local afk = os.time()
local startTime = os.time()
local startXp = API.GetSkillXP("FISHING")

local blueCol = ImColor.new(0, 150, 255)

local fishTypeData = {
    "Swarm",
    "Minnow shoal",
    "Green blubber jellyfish",
    "Blue blubber jellyfish"
}

local function idleCheck()
    local timeDiff = os.difftime(os.time(), afk)
    local randomTime = math.random(180, 280)

    if timeDiff > randomTime then
        API.PIdle2()
        afk = os.time()
    end
end

local function round(val, decimal)
    if decimal then
        return math.floor((val * 10 ^ decimal) + 0.5) / (10 ^ decimal)
    else
        return math.floor(val + 0.5)
    end
end

-- Format a number with commas as thousands separator
local function formatNumberWithCommas(amount)
    local formatted = tostring(amount)
    while true do
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
        if (k == 0) then
            break
        end
    end
    return formatted
end

-- Format script elapsed time to [hh:mm:ss]
local function formatElapsedTime(startTime)
    local currentTime = os.time()
    local elapsedTime = currentTime - startTime
    local hours = math.floor(elapsedTime / 3600)
    local minutes = math.floor((elapsedTime % 3600) / 60)
    local seconds = elapsedTime % 60
    return string.format("[%02d:%02d:%02d]", hours, minutes, seconds)
end

local function printProgressReport(final)
    local currentXp = API.GetSkillXP("FISHING")
    local elapsedMinutes = (os.time() - startTime) / 60
    local diffXp = math.abs(currentXp - startXp);
    local xpPH = round((diffXp * 60) / elapsedMinutes);
    local time = formatElapsedTime(startTime)
    Runtime.string_value = "Runtime : " .. time
    FishingXP.string_value = "Fishing XP : " .. formatNumberWithCommas(diffXp) .. " (" .. formatNumberWithCommas(xpPH) .. ")"
    if final then
        print(os.date("%H:%M:%S") .. " Script Finished\nRuntime : " .. time .. "\nFishing XP : " .. formatNumberWithCommas(diffXp))
    end
end

local function setGUI()
    BackDrop = API.CreateIG_answer()
    BackDrop.box_name = "backDrop"
    BackDrop.box_start = FFPOINT.new(0, 50, 0)
    BackDrop.box_size = FFPOINT.new(300, 200, 0)
    BackDrop.colour = ImColor.new(0, 0, 0, 150)

    Title = API.CreateIG_answer()
    Title.box_name = "titleText"
    Title.string_value = "DeepSeaFisher by Shmoopey"
    Title.box_start = FFPOINT.new(60, 65, 0)
    Title.colour = blueCol

    Runtime = API.CreateIG_answer()
    Runtime.box_name = "Runtime"
    Runtime.string_value = "[00:00:00]"
    Runtime.box_start = FFPOINT.new(10, 90, 0)
    Runtime.colour = blueCol

    FishingXP = API.CreateIG_answer()
    FishingXP.box_name = "FishingXP"
    FishingXP.string_value = "Fishing XP : 0 (0)"
    FishingXP.box_start = FFPOINT.new(10, 110, 0)
    FishingXP.colour = blueCol

    FishTypeCombo = API.CreateIG_answer()
    FishTypeCombo.box_name = "Fish Type"
    FishTypeCombo.box_start = FFPOINT.new(10, 130, 0)
    FishTypeCombo.stringsArr = fishTypeData

end

local function drawGUI()
    API.DrawSquareFilled(BackDrop)
    API.DrawTextAt(Title)
    API.DrawTextAt(Runtime)
    API.DrawTextAt(FishingXP)
    API.DrawComboBox(FishTypeCombo, true)
end

local function depositChest()
    UTILS.randomSleep(350)
    API.DoAction_Object1(0x29, 256, {110860}, 50)
    UTILS.randomSleep(100)
    API.WaitUntilMovingEnds()
end

local function depositMNet()
    UTILS.randomSleep(350)
    API.DoAction_Object1(0x29, API.OFF_ACT_GeneralObject_route2, {110857}, 50)
    UTILS.randomSleep(100)
    API.WaitUntilMovingEnds()
end

local function fish()
    UTILS.randomSleep(100)
    API.DoAction_NPC_str(0x3c, API.OFF_ACT_InteractNPC_route, {FishTypeCombo.string_value}, 50)
    UTILS.randomSleep(100)
    API.WaitUntilMovingEnds()
end

local function deposit()
    if FishTypeCombo.string_value == "Swarm" then
        depositMNet()
    elseif FishTypeCombo.string_value == "Green blubber jellyfish" or FishTypeCombo.string_value == "Blue blubber jellyfish" then
        depositChest()
    end
end

setGUI()

local scriptFirstRun = true


local function FirstRun()
    local player = API.GetLocalPlayerName()
    API.Write_ScripCuRunning0("fishingScript: " .. player)
    scriptFirstRun = false;
end

API.Write_LoopyLoop(true)
while (API.Read_LoopyLoop()) do -----------------------------------------------------------------------------------

    drawGUI()

    if(scriptFirstRun) then 
        FirstRun() 
    end

    API.DoRandomEvents()
    idleCheck()
    if not API.ReadPlayerMovin() then
        if not API.InvFull_() then 
            if (FishTypeCombo.string_value == "Green blubber jellyfish" and API.PlayerInterActingWith_2(API.GetLocalPlayerAddress()) ~= "Green blubber jellyfish") or (FishTypeCombo.string_value == "Blue blubber jellyfish" and API.PlayerInterActingWith_2(API.GetLocalPlayerAddress()) ~= "Blue blubber jellyfish") then
                fish()
            end
            if not API.CheckAnim(100) then
                fish()
            end
        else
            deposit()
        end
end 


    printProgressReport()
    API.RandomSleep2(500, 1500, 2500)
end ----------------------------------------------------------------------------------
