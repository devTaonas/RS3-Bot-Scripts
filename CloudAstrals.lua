local API = require("api")
local UTILS = require("utils")
local MAX_IDLE_TIME_MINUTES = 10 -- CHANGE TO (5) IF NOT ON JAGEX ACC
local interval = 40 * 60 -- 40 minutes in seconds
local lastActionTime = os.time()

skill = "RUNECRAFTING"
startXp = API.GetSkillXP(skill)
local Trips = 0
local Runes, fail = 0, 0
local startTime, afk = os.time(), os.time()
ID = {
    Astral = 9075,
    key = 24154,
    TITAN_POUCH = 12796,
    BANK = 16700

}




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
    local currentXp = API.GetSkillXP(skill)
    local elapsedMinutes = (os.time() - startTime) / 60
    local diffXp = math.abs(currentXp - startXp);
    local xpPH = round((diffXp * 60) / elapsedMinutes);
    local TripsPH = round((Trips * 60) / elapsedMinutes)
    local RunesPH = round((Runes * 60) / elapsedMinutes)
    local time = formatElapsedTime(startTime)
    local currentLevel = API.XPLevelTable(API.GetSkillXP(skill))
    IGP.radius = calcProgressPercentage(skill, API.GetSkillXP(skill)) / 100
    IGP.string_value = time ..
        " | " ..
        string.lower(skill):gsub("^%l", string.upper) ..
        ": " .. currentLevel .. " | XP/H: " .. formatNumber(xpPH) .. " | XP: " .. formatNumber(diffXp) .. " | Trips: " .. formatNumber(Trips) .. " | Trips/H: " .. formatNumber(TripsPH) .. " | Runes: " .. formatNumber(Runes) .. " | Runes/H: " .. formatNumber(RunesPH)

    end

local function setupGUI()
    IGP = API.CreateIG_answer()
    IGP.box_start = FFPOINT.new(5, 5, 0)
    IGP.box_name = "PROGRESSBAR"
    IGP.colour = ImColor.new(0, 204, 204);
    IGP.string_value = "Astral RuneCrafter"
end

local function drawGUI()
    DrawProgressBar(IGP)
end



local function idleCheck()
    local timeDiff = os.difftime(os.time(), afk)
    local randomTime = math.random((MAX_IDLE_TIME_MINUTES * 60) * 0.6, (MAX_IDLE_TIME_MINUTES * 60) * 0.9)

    if timeDiff > randomTime then
        local rnd1 = math.random(25, 28)
        local rnd2 = math.random(25, 28)

        API.KeyboardPress31(0x28, math.random(20, 60), math.random(50, 200))
        API.KeyboardPress31(0x27, math.random(20, 60), math.random(50, 200))

        afk = os.time()
    end
end

local function ClaimKey()
    if API.InvItemcount_1(ID.Key) == true then
        API.DoAction_Object1()

    end
end



local function CheckFamiliar()
    local currentTime = os.time()
    local elapsedTime = currentTime - lastActionTime

    print("Renewing at Obelisk")
    API.DoAction_Object1(0x29,GeneralObject_route0,{29944},50)
    API.RandomSleep2(1000,1000,1000)
    API.WaitUntilMovingEnds()
    API.RandomSleep2(1000,1000,1000)
    print("Clicking Pouch")
    API.DoAction_Interface(0x24,0x31fc,1,1473,5,1,GeneralInterface_route)

end

local function BacktoHome()
    print("Clicking Lunar Lodestone")
    --GoToLodestone(LODESTONES.LODESTONE.LUNAR_ISLE)
    API.DoAction_Interface(0x2e,0xffffffff,1,1430,64,-1,GeneralInterface_route)
    API.RandomSleep2(4500,500,500)
    UTILS.waitForAnimation(0, 20)
    print("checking if at lodestone")
     if not API.PInArea(2085, 10, 3915, 10) then
        API.DoAction_Interface(0x2e,0xffffffff,1,1430,64,-1,5376)
        API.RandomSleep2(4500,500,500)
        UTILS.waitForAnimation(0, 20)
     else 
        API.DoAction_Tile(WPOINT.new( 2099 + API.Math_RandomNumber(2), 3918 + API.Math_RandomNumber(2), 0))
        API.RandomSleep2(1000,500,500)
        API.WaitUntilMovingEnds()
     end
end

local function bank()
    print("Opening Bank")
    API.DoAction_Object1(0x5,80,{16700},GeneralObject_route1)
    API.RandomSleep2(1750,500,500)
    if API.BankGetItem(7936) then
    print(" Checking for Pure Essence ")
    API.DoAction_Interface(0x24,0xffffffff,1,517,119,1,GeneralInterface_route)
    print(" Found Essence")
    API.RandomSleep2(1000,500,500)
    else
        print(" Trying to stop script ")
        API.Write_LoopyLoop(false)
    end
end

local function RuntoAltar()
    print("Tile 1")
    API.DoAction_Tile(WPOINT.new( 2116 + API.Math_RandomNumber(6), 3881 + API.Math_RandomNumber(6), 0))
    API.RandomSleep2(2500,500,500)
    API.WaitUntilMovingEnds()
    print("Tile 2")
    API.DoAction_Tile(WPOINT.new( 2154 + API.Math_RandomNumber(4), 3864 + API.Math_RandomNumber(4), 0))
    API.RandomSleep2(2500,500,500)
    API.WaitUntilMovingEnds()
    print("Is Player At Altar?")
    if not (API.PInArea(2158, 5, 3865, 5))then
        print("No: Clicking Near altar again")
        API.DoAction_Tile(WPOINT.new( 2156 + API.Math_RandomNumber(-4), 3863 + API.Math_RandomNumber(4), 0))
        API.RandomSleep2(2500,500,500)
        API.WaitUntilMovingEnds()
    end
end

local function canUsePowerburst()
    local debuffs = API.DeBuffbar_GetAllIDs()
    local powerburstCoolldown = false
    for _, a in ipairs(debuffs) do
        if a.id == 48960 then
            powerburstCoolldown = true
        end
    end
    return not powerburstCoolldown
end

local function findPowerburst()
    local powerburstIds = { 49069, 49067, 49065, 49063 }
    local powerbursts = API.CheckInvStuff3(powerburstIds)
    local foundIdx = 0
    for i, value in ipairs(powerbursts) do
        if tostring(value) == '1' then
            foundIdx = i
        end
    end
    return powerburstIds[foundIdx]
end


local function Magic()
    local isPowerburstReady = canUsePowerburst()

    if isPowerburstReady and API.PInArea(2158, 5, 3865, 5) then
        print("MAGIC: Powerbursting Boost is Now active")
        API.DoAction_Interface(0x30, {findPowerburst()}, 1, 1473, 5, 2, 3808)
        API.RandomSleep2(850, 850, 80)
        print("MAGIC: Powerbursting Boost Active Clicking Altar")
        API.DoAction_Object1(0x42, 0, {17010}, 50)
        API.RandomSleep2(1050, 850, 80)
        UTILS.waitForAnimation()
        print("MAGIC: ---Updating RuneCount---")
        Trips = Trips + API.InvItemcount_1(ID.Astral)
        Runes = Runes + API.InvStackSize(ID.Astral)
    else
        print("MAGIC: Powerbursting Boost In-Active Clicking Altar")
        API.DoAction_Object1(0x42, 0, {17010}, 50)
        API.RandomSleep2(1050, 850, 80)
        UTILS.waitForAnimation()
        API.RandomSleep2(1550, 850, 80)
        print("MAGIC: ---Updating RuneCount---")
        Trips = Trips + API.InvItemcount_1(ID.Astral)
        Runes = Runes + API.InvStackSize(ID.Astral)
    end
end

local function hasfamiliar()
    return API.Buffbar_GetIDstatus(26095).id > 0
end

local function summonFam()
    if API.InvItemFound1(12796) then
        print("summonfam: Pouch found Clicking on Pouch")
        API.DoAction_Ability("Abyssal titan pouch", 1, OFF_ACT_GeneralInterface_route)
        API.RandomSleep2(300, 50, 50)
    end
    return true
end

setupGUI()

    API.Write_LoopyLoop(true)
    while (API.Read_LoopyLoop()) do

        local currentTime = os.time()
        local elapsedTime = currentTime - lastActionTime
        
        print("LOGIC: IDLE CHECK")
        idleCheck()

        drawGUI()
        print("Updating UI")
        printProgressReport()
        
        if elapsedTime >= interval and API.PInArea(2099, 20, 3919, 20) then
            print("LOGIC:  Checking and Renewing Familiar after 45Mins if at bank")
            CheckFamiliar()
            lastActionTime = os.time()
            print("LOGIC:Invy Full Running to altar ")
            if API.InvFull_ then
                RuntoAltar()
            else 
                print("LOGIC: Banking ")
                Bank()
                API.RandomSleep2(600,500,500)
                if not API.InvFull_() then
                   print(" Trying to stop script ")
                    API.Write_LoopyLoop(false)
                end
                print("LOGIC:Summoning Familiar")
                CheckFamiliar()
            end
        end

        if not hasfamiliar() then
            print("LOGIC: Renewing at Obelisk")
            API.DoAction_Object1(0x29,0,{"Small obelisk"},GeneralObject_route0)
            API.RandomSleep2(1000,1000,1000)
            API.WaitUntilMovingEnds()
            API.RandomSleep2(1000,1000,1000)
            print("LOGIC:Clicking Pouch")
            API.DoAction_Interface(0x24,0x31fc,1,1473,5,2,5376)
        end
    
        if not API.InvFull_() and (API.PInArea(2099, 20, 3919, 20))then
            bank()
            API.RandomSleep2(600,500,500)
        end

        if API.InvFull_() then
            print("LOGIC:Running To Altar")
            RuntoAltar()
            print("LOGIC: Time for Magic")
            if (API.PInArea(2158, 5, 3865, 5))then
                Magic()
                print("Updating UI")
                printProgressReport()
            else 
                API.DoAction_Tile(WPOINT.new( 2158 + API.Math_RandomNumber(4), 3865 + API.Math_RandomNumber(4), 0))
                API.RandomSleep2(650,500,500)
                API.WaitUntilMovingEnds()
                Magic()
                API.RandomSleep2(1000,500,500)
            end
        end
    
        API.RandomSleep2(500,500,500)
    
        if not API.InvFull_() and not(API.PInArea(2099, 20, 3919, 20))then
            print("LOGIC: Invy Not Full")
            print("LOGIC:Heading Back to Bank")
            BacktoHome()
            API.RandomSleep2(1050,500,500)
            print("Banking to get full")
            bank()
            API.RandomSleep2(600,500,500)
                bank()
            if elapsedTime >= interval then
            CheckFamiliar()
            end
            API.RandomSleep2(650,500,500)
        end
    
        ::continue::
        printProgressReport()
        API.RandomSleep2(500, 650, 500)
    end