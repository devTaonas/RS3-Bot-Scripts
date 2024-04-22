local procDummiesGUI = {}
local API = require("api")

local scriptStartingTime = os.time()
local skillStartingXP = 0
local setup = false

function procDummiesGUI.Config(skill) 

    skillStartingXP = API.GetSkillXP(string.upper(dummiesList.string_value))

    xpGained = API.CreateIG_answer()
    xpGained.box_start = FFPOINT.new(80, 130, 0)
    xpGained.colour = ImColor.new(141, 145, 1)
    xpGained.box_name = "xpGained"

    xpGained.string_value = "Gained " .. procDummiesGUI.CommaFormatting((API.GetSkillXP(string.upper(dummiesList.string_value)) -skillStartingXP)) .. " XP"
    API.DrawTextAt(xpGained)

    timeTillLevel = API.CreateIG_answer()
    timeTillLevel.box_start = FFPOINT.new(93, 165, 0)
    timeTillLevel.colour = ImColor.new(141, 145, 1)
    timeTillLevel.box_name = "ttl"
    timeTillLevel.string_value = "TTL 00:00:00"

    timeTillLevel.string_value = "TTL " .. (procDummiesGUI.CalculateTimeFrame() or "00:00:00")
    API.DrawTextAt(timeTillLevel)

    setup = true
end

function procDummiesGUI.Init()
    backgroundPanel = API.CreateIG_answer();
    backgroundPanel.box_start = FFPOINT.new(10, 100, 0)
    backgroundPanel.box_size = FFPOINT.new(250, 235, 0)
    backgroundPanel.colour = ImColor.new(15, 13, 18, 150)

    titleBarText = API.CreateIG_answer()
    titleBarText.box_start = FFPOINT.new(48, 100, 0)
    titleBarText.colour = ImColor.new(141, 145, 1)
    titleBarText.box_name = "titleBar"
    titleBarText.string_value = "### procDummies v1.0 ###"

    dummiesList = API.CreateIG_answer()
    dummiesList.box_name = "     "
    dummiesList.box_start = FFPOINT.new(79, 205, 0)
    dummiesList.stringsArr = {"Select Action", "Slayer", "Agility", "Thieving", "Archaeology", "Dungeoneering", "Combat"}


    totalTimeRunning = API.CreateIG_answer()
    totalTimeRunning.box_start = FFPOINT.new(105, 196, 0)
    totalTimeRunning.colour = ImColor.new(141, 145, 1)
    totalTimeRunning.box_name = "ttr"
    totalTimeRunning.string_value = procDummiesGUI.Runtime()
end

function procDummiesGUI.Draw()
    API.DrawSquareFilled(backgroundPanel)
    API.DrawTextAt(titleBarText)
    API.DrawComboBox(dummiesList, false)

    if(setup) then
        xpGained.string_value = "Gained " .. procDummiesGUI.CommaFormatting((API.GetSkillXP(string.upper(dummiesList.string_value)) -skillStartingXP)) .. " XP"
        API.DrawTextAt(xpGained)

        timeTillLevel.string_value = "TTL " .. (procDummiesGUI.CalculateTimeFrame() or "00:00:00")
        API.DrawTextAt(timeTillLevel)
    end

    totalTimeRunning.string_value = procDummiesGUI.Runtime()
    API.DrawTextAt(totalTimeRunning)
end

function procDummiesGUI.Runtime()
    local diff = os.difftime(os.time(), scriptStartingTime)
    local hours = math.floor(diff / 3600)
    local minutes = math.floor((diff % 3600) / 60)
    local seconds = diff % 60
    return string.format("%02d:%02d:%02d", hours, minutes, seconds)
end

function procDummiesGUI.RoundNumber(value, decimalPlaces)
    local multiplier = 10^(decimalPlaces or 0)
    return math.floor(value * multiplier + 0.5) / multiplier
end

function procDummiesGUI.CommaFormatting(number)
    local formatted = tostring(number)
    local k
    while true do  
        formatted, k = formatted:gsub("^(-?%d+)(%d%d%d)", '%1,%2')
        if (k==0) then
            break
        end
    end
    return formatted
end

function procDummiesGUI.CalculateTimeFrame()

    local currentXp = API.GetSkillXP(string.upper(dummiesList.string_value))
    local elapsedMinutes = (os.time() - scriptStartingTime) / 60
    local diffXp = math.abs(currentXp - skillStartingXP);
    local xpPH = procDummiesGUI.RoundNumber((diffXp * 60) / elapsedMinutes);

    local currentXp = API.GetSkillXP(string.upper(dummiesList.string_value))
    local xpNeededForCondition = API.XPForLevel(API.XPLevelTable(currentXp) + 1)

    local xpRemaining = xpNeededForCondition - currentXp

    if xpPH == 0 then
        return
    end

    local hoursNeeded = xpRemaining / xpPH

    local wholeHours = math.floor(hoursNeeded)
    local minutesNeeded = math.floor((hoursNeeded - wholeHours) * 60)
    local secondsNeeded = math.floor((((hoursNeeded - wholeHours) * 60) - minutesNeeded) * 60)

    local success, timeNeededStr = pcall(string.format, "%02d:%02d:%02d", wholeHours, minutesNeeded, secondsNeeded)
    if not success then
        return
    end

    return timeNeededStr
end

function procDummiesGUI.CountItems(itemID)
    return API.InvStackSize(itemID)
end

return procDummiesGUI