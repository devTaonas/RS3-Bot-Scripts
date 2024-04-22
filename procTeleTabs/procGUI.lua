local procTeleTabGUI = {}
local API = require("api")

local scriptStartingTime = os.time()
local skillBeingTrained = "MAGIC"
local skillStartingXP = API.GetSkillXP(skillBeingTrained)

local teleTabIDs = {8007, 8001, 8012, 8013, 8008, 8009, 31665, 8010, 8011}
local startingCount = 0

function procTeleTabGUI.Init()

    backgroundPanel = API.CreateIG_answer();
    backgroundPanel.box_start = FFPOINT.new(10, 100, 0)
    backgroundPanel.box_size = FFPOINT.new(250, 235, 0)
    backgroundPanel.colour = ImColor.new(15, 13, 18, 150)

    titleBarText = API.CreateIG_answer()
    titleBarText.box_start = FFPOINT.new(48, 100, 0)
    titleBarText.colour = ImColor.new(141, 145, 1)
    titleBarText.box_name = "titleBar"
    titleBarText.string_value = "### procTeleTabs v2.0 ###"

    teleTabList = API.CreateIG_answer()
    teleTabList.box_name = "     "
    teleTabList.box_start = FFPOINT.new(79, 205, 0)
    teleTabList.stringsArr = {"Select Tab", "Varrock","Lumbridge","Falador" , "Camelot", "Ardougne", "Watchtower", "House", "GWD"}

    xpGained = API.CreateIG_answer()
    xpGained.box_start = FFPOINT.new(90, 130, 0)
    xpGained.colour = ImColor.new(141, 145, 1)
    xpGained.box_name = "xpGained"
    xpGained.string_value = "Gained " .. (API.GetSkillXP(skillBeingTrained) -skillStartingXP) .. " XP"

    itemsCrafted = API.CreateIG_answer()
    itemsCrafted.box_start = FFPOINT.new(58, 152, 0)
    itemsCrafted.colour = ImColor.new(141, 145, 1)
    itemsCrafted.box_name = "itemsCrafted"
    itemsCrafted.string_value = "Crafted " .. ("0") .. " total items"

    timeTillLevel = API.CreateIG_answer()
    timeTillLevel.box_start = FFPOINT.new(93, 165, 0)
    timeTillLevel.colour = ImColor.new(141, 145, 1)
    timeTillLevel.box_name = "ttl"
    timeTillLevel.string_value = "TTL 00:00:00"

    totalTimeRunning = API.CreateIG_answer()
    totalTimeRunning.box_start = FFPOINT.new(105, 196, 0)
    totalTimeRunning.colour = ImColor.new(141, 145, 1)
    totalTimeRunning.box_name = "ttr"
    totalTimeRunning.string_value = procTeleTabGUI.Runtime()

    for i = 1, #teleTabIDs do
        local value = teleTabIDs[i]
        startingCount = startingCount + procTeleTabGUI.CountItems(value)
    end
end

function procTeleTabGUI.Draw()
    API.DrawSquareFilled(backgroundPanel)
    API.DrawTextAt(titleBarText)
    API.DrawComboBox(teleTabList, false)

    xpGained.string_value = "Gained " .. procTeleTabGUI.CommaFormatting((API.GetSkillXP(skillBeingTrained) -skillStartingXP)) .. " XP"
    API.DrawTextAt(xpGained)

    local count = 0
    local finalCount = 0

    for i = 1, #teleTabIDs do
        local value = teleTabIDs[i]
        count = count + procTeleTabGUI.CountItems(value)
    end

    itemsCrafted.string_value = "Crafted " .. (count - startingCount) .. " total items"
    API.DrawTextAt(itemsCrafted)

    timeTillLevel.string_value = "TTL " .. (procTeleTabGUI.CalculateTimeFrame() or "00:00:00")
    API.DrawTextAt(timeTillLevel)

    totalTimeRunning.string_value = procTeleTabGUI.Runtime()
    API.DrawTextAt(totalTimeRunning)
end

function procTeleTabGUI.Runtime()
    local diff = os.difftime(os.time(), scriptStartingTime)
    local hours = math.floor(diff / 3600)
    local minutes = math.floor((diff % 3600) / 60)
    local seconds = diff % 60
    return string.format("%02d:%02d:%02d", hours, minutes, seconds)
end

function procTeleTabGUI.RoundNumber(value, decimalPlaces)
    local multiplier = 10^(decimalPlaces or 0)
    return math.floor(value * multiplier + 0.5) / multiplier
end

function procTeleTabGUI.CommaFormatting(number)
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

function procTeleTabGUI.CalculateTimeFrame()

    local currentXp = API.GetSkillXP(skillBeingTrained)
    local elapsedMinutes = (os.time() - scriptStartingTime) / 60
    local diffXp = math.abs(currentXp - skillStartingXP);
    local xpPH = procTeleTabGUI.RoundNumber((diffXp * 60) / elapsedMinutes);

    local currentXp = API.GetSkillXP(skillBeingTrained)
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

function procTeleTabGUI.CountItems(itemID)
    return API.InvStackSize(itemID)
end

return procTeleTabGUI