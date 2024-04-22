--[[
    @name Alpha Portables
    @description Automates tasks at portable skilling stations (ideally at W84 Fort Forinthry)
    @author Aria
    @version 1.1
]]

local API = require("api")

--make sure the left click option is configured to be the one you want for portables with a "Configure" option
local SCENE_OBJECTS = {
    WORKBENCH = 117926,
    FLETCHER = 106599, --might also be 106598?
    RANGE = 89768,
    WELL = 89770,
    CRAFTER = 106595,

    BANK_CHEST = 125115, --Fort Forinthry bank chest
    WORKROOM_BANK_CHEST = 125734 --Fort Forinthry workroom bank chest
}

local PORTABLES = {
    {id = SCENE_OBJECTS.WORKBENCH, action = 0x29, skill = "CONSTRUCTION"},
    {id = SCENE_OBJECTS.FLETCHER, action = 0x29, skill = "FLETCHING"},
    {id = SCENE_OBJECTS.RANGE, action = 0x40, skill = "COOKING"},
    {id = SCENE_OBJECTS.WELL, action = 0x29, skill = "HERBLORE"},
    {id = SCENE_OBJECTS.CRAFTER, action = 0x29, skill = "CRAFTING"}
}

--#region User Inputs, don't modify this if you don't know what you're doing
local loadPresetKey = 0x32 --The 2 key
--Change this value to 1 = workbench, 2 = fletcher, 3 = range, 4 = well, 5 = crafter if you don't want to have to select the portable you're using each time
local chosenPortable = -1
--Max time to remain in the "processing" state before attempting to interact again
--You may want to change the timeout (in seconds) depending on the skill you are training
local processingTimeout = 250 

--add the ids of the items you are processing to the table below, click "Inv" in the debug menu to view the ids of the items in the inventory
local ID = {
    RAW_GREEN_JELLYFISH = 42256,

    SUPER_RANGING = 169,
    GRENWALL_SPIKES = 12539,

    UNCUT_DRAGONSTONE = 1631,
    
    ASCENSION_SHARD = 28436,

    PROTEAN_PLANK = 30037,
}

--Add the items you are processing to this list
itemList = {} 
--Example for cooking raw green jellyfish
--itemList[1] = { id = ID.RAW_GREEN_JELLYFISH, amount = 28 }

--#endregion

local startTimeAFK = os.time()
local idleTimeThreshold2 = math.random(120, 260)

function AntiAFK() 
    if(API.GetGameState() == 3) then
        local currentTime2 = os.time()
        local elapsedTime2 = os.difftime(currentTime2, startTimeAFK)
    
        if elapsedTime2 >= idleTimeThreshold2 then
            API.PIdle2()
            startTimeAFK = os.time()
            idleTimeThreshold2 = math.random(200, 280)
            print("Reset Timer & Threshhold")
        end
    end
end

if chosenPortable == -1 then
    print("Please select the portable station you want to use")
end

if not itemList[1] then
    print("Empty item list detected, attempting to get the items being processed from your inventory")

    local added = {}
    local vec = API.ReadInvArrays33()
    for i = 1, #vec do
      if not added[vec[i].itemid1] and vec[i].itemid1 > 0 then
        local amt = math.max(API.InvItemcount_1(vec[i].itemid1), API.InvStackSize(vec[i].itemid1))
        itemList[#itemList + 1] = { id = vec[i].itemid1, amount = amt } 
        print("Added item: " .. vec[i].textitem .. " (" .. vec[i].itemid1 .. ") with amount " .. amt)
        added[vec[i].itemid1] = true
      end
    end
    --print("Please add the items you are processing")
end

local portableOptions = { "Workbench", "Fletcher", "Range", "Well", "Crafter" }

startXp = 0 --API.GetSkillXP(PORTABLES[chosenPortable].skill)
lastXp = startXp
startTime, afk = os.time(), os.time()
lastTimeGainedXp = os.time()

local function resetStats() 
    startXp = API.GetSkillXP(PORTABLES[chosenPortable].skill)
    lastXp = startXp
    startTime, afk = os.time(), os.time()
    lastTimeGainedXp = os.time()
end

-- Rounds a number to the nearest integer or to a specified number of decimal places.
local function round(val, decimal)
    if decimal then
        return math.floor((val * 10 ^ decimal) + 0.5) / (10 ^ decimal)
    else
        return math.floor(val + 0.5)
    end
end

function formatNumber(num)
    if num >= 1e6 then
        return string.format("%.1fM", num / 1e6)
    elseif num >= 1e3 then
        return string.format("%.1fK", num / 1e3)
    else
        return tostring(num)
    end
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

local function calcProgressPercentage(skill, currentExp)
    local currentLevel = API.XPLevelTable(API.GetSkillXP(skill))
    if currentLevel == 120 then return 100 end
    local nextLevelExp = XPForLevel(currentLevel + 1)
    local currentLevelExp = XPForLevel(currentLevel)
    local progressPercentage = (currentExp - currentLevelExp) / (nextLevelExp - currentLevelExp) * 100
    return math.floor(progressPercentage)
end

local function printProgressReport(final)
    local skill = PORTABLES[chosenPortable].skill
    local currentXp = API.GetSkillXP(skill)
    if currentXp > lastXp then
        lastXp = currentXp
        lastTimeGainedXp = os.time()
    end
    local elapsedMinutes = (os.time() - startTime) / 60
    local diffXp = math.abs(currentXp - startXp);
    local xpPH = round((diffXp * 60) / elapsedMinutes);
    local time = formatElapsedTime(startTime)
    local currentLevel = API.XPLevelTable(API.GetSkillXP(skill))
    IGP.radius = calcProgressPercentage(skill, API.GetSkillXP(skill)) / 100
    IGP.string_value = time ..
    " | " ..
    string.lower(skill):gsub("^%l", string.upper) ..
    ": " .. currentLevel .. " | XP/H: " .. formatNumber(xpPH) .. " | XP: " .. formatNumber(diffXp)
end

local function setupGUI()
    IGP = API.CreateIG_answer()
    IGP.box_start = FFPOINT.new(5, 5, 0)
    IGP.box_name = "PROGRESSBAR"
    IGP.colour = ImColor.new(116, 2, 179);
    IGP.string_value = PORTABLES[chosenPortable].skill
end

function drawGUI()
    DrawProgressBar(IGP)
end

local comboBoxSelect = API.CreateIG_answer()

local function setupOptions()
    comboBoxSelect.box_name = "Portables"
    comboBoxSelect.box_start = FFPOINT.new(1,60,0)
    comboBoxSelect.stringsArr = {}
    comboBoxSelect.box_size = FFPOINT.new(440, 0, 0)

    table.insert(comboBoxSelect.stringsArr, "Select an option")

    for i, option in ipairs(portableOptions) do
        table.insert(comboBoxSelect.stringsArr, option)
    end

    API.DrawComboBox(comboBoxSelect, false)
end

if chosenPortable == -1 then
    setupOptions()
else 
    resetStats() 
end

function waitUntil(x, timeout)
    start = os.time()
    while not x() and start + timeout > os.time() do
        API.RandomSleep2(600, 200, 200)
    end
    return start + timeout > os.time()
end

function getCreationInterfaceSelectedItemID()
    return API.VB_FindPSett(1170, 0).SumOfstate
end

function creationInterfaceOpen() 
    return getCreationInterfaceSelectedItemID() ~= -1
end

function notInBank()
    return not API.BankOpen2()
end

local function waitWhileProcessing(timeout)
    local startTime = os.time()
    print("Waiting for items to be processed")
    while os.time() - startTime < timeout do
        if not isProcessing() then
            return true
        end
        API.DoRandomEvents()
        printProgressReport()

        API.RandomSleep2(600, 200, 200)
    end
    return false
end

local function loadPreset()
    print("Loading preset")
    API.KeyboardPress32(loadPresetKey, 0)
    waitUntil(notInBank, 5)
end

--Checks whether we have at least `amount` of each item
local function hasAllItems()
    for i = 1, #itemList do
        if itemList[i].id == nil then
            print("Error: undefined item id: probably didn't add the item's id to the ID table, stopping script")
            API.Write_LoopyLoop(false)
            return false
        end
        if API.InvItemcount_1(itemList[i].id) < itemList[i].amount and API.InvStackSize(itemList[i].id) < itemList[i].amount then
            print("Not enough of item:", itemList[i].id)
            return false
        end
    end
    return true
end

local hasSetupGUI = false

API.Write_LoopyLoop(true)
while (API.Read_LoopyLoop()) do

    if (comboBoxSelect.return_click) then
        comboBoxSelect.return_click = false
        
        for i, option in ipairs(portableOptions) do
            if (comboBoxSelect.string_value == option) then
                print("Chose portable: ", option, "index: ", i)
                chosenPortable = i
                resetStats() 
            end
        end
    end

    if chosenPortable ~= -1 then
        if not hasSetupGUI then
            setupGUI()
            hasSetupGUI = true
        end

        drawGUI()
        printProgressReport()
        API.DoRandomEvents()
        AntiAFK()
        --stop script if no exp gained in the past 60s
        if (os.time() - lastTimeGainedXp) > 60 then
            API.Write_LoopyLoop(false)
        elseif hasAllItems() then
            if API.BankOpen2() then
                loadPreset()
            else 
                --The script currently doesn't validate whether the selected item in the creation interface is the correct item
                --which could be a problem if there are multiple items that use the same ingredients i.e. urns
                print("Interacting with portable")
                if API.DoAction_Object1(PORTABLES[chosenPortable].action, 0, { PORTABLES[chosenPortable].id }, 5) then
                    print("Waiting for creation interface")
                    if waitUntil(creationInterfaceOpen, 5) then
                        API.KeyboardPress32(0x20,0) --press Space
                        print("Waiting for processing to begin")
                        if waitUntil(API.isProcessing, 5) then
                            waitWhileProcessing(processingTimeout)
                        end
                    end
                else
                    print("Unable to find portable")
                    API.RandomSleep2(1000, 100, 200)
                end
            end    
        elseif API.BankOpen2() then
            loadPreset()
        else
            print("Opening bankZZ")
            
        end
    end
    
    API.RandomSleep2(100, 10, 20)
end
