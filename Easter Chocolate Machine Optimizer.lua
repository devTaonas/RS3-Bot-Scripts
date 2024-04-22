--[[    
Easter Chocolate Machine Optimizer
Author: Stryder
Version 1.0
Requirements: API v1.92
              ~3GB free memory
Purpose: The purpose of this script is to constantly earn x6 spring tokens as much as possible (RNG permitting) during the easter 2024 event
How-to-use: Stand anywhere within the Egg Plant (chocolate machine area) within Blooming Burrow - the easter 2024 event area.
            Optimization does not start until bunnies give instructions, but script works at any time.

-Incomplete & Potential Features-
(Time permitting)
Road Map: Complete 2 station optimization
          Complete 1 station optimization
          Refactoring
          Complete tracking Spring Coins collected
          Complete Spring Coins per/hr tracker
          Complete XP/hr tracker
          Complete GUI
          Refactoring

-Bugs-
Known Issues:

-Resolved-
Bug Fix: There is a chance to get stuck on a menu choice [increased sleep time]
--]]

---------------WORK SPACE---------------

local API   = require("api")

print("Initializing Variables. . .")

-- Initializing Variables --
local mixingStationEnabled              = 1                             -- Flag to enable or disable a specific station
local mouldingStationEnabled            = 1                             -- Flag to enable or disable a specific station
local foilingStationEnabled             = 1                             -- Flag to enable or disable a specific station
local totalStationsEnabled              = mixingStationEnabled + mouldingStationEnabled + foilingStationEnabled
local mixingStationID                   = 129766                        -- Game's ID for world object
local mouldingStationID                 = 129769                        -- Game's ID for world object
local foilingStationID                  = 129772                        -- Game's ID for world object
local mixingStationLocation             = WPOINT.new(3750, 4942, 0)     -- Tile coordinates in game
local mixingStationPlayerLocation       = WPOINT.new(3751, 4942, 0)     -- Where the player stands when operating the mixing station
local mouldingStationLocation           = WPOINT.new(3750, 4946, 0)     -- Tile coordinates in game
local mouldingStationPlayerLocation     = WPOINT.new(3751, 4946, 0)     -- Where the player stands when operating the moulding station
local foilingStationLocation            = WPOINT.new(3750, 4950, 0)     -- Tile coordinates in game
local foilingStationPlayerLocation      = WPOINT.new(3751, 4950, 0)     -- Where the player stands when operating the foiling station
local newMixingStationInstruction       = "searching"                   -- Which product was instructed to be made at the mixing station
local newMouldingStationInstruction     = "searching"                   -- Which product was instructed to be made at the moulding station
local newFoilingStationInstruction      = "searching"                   -- Which product was instructed to be made at the foiling station
local curMixingStationInstruction       = "initializing"                -- Which product was instructed to be made at the mixing station
local curMouldingStationInstruction     = "initializing"                -- Which product was instructed to be made at the moulding station
local curFoilingStationInstruction      = "initializing"                -- Which product was instructed to be made at the foiling station
local prevMixingStationInstruction      = "off"                         -- Retains the previous Mixing station instruction
local prevMouldingStationInstruction    = "off"                         -- Retains the previous Moulding station instruction
local prevFoilingStationInstruction     = "off"                         -- Retains the previous Foiling station instruction
local newOverworkedStationNumber        = 0                             -- Logs which station is overworked, 0 = None, 1 = Mixing, 2 = Moulding, 3 = Foiling
local curOverworkedStationNumber        = 0                             -- Logs which station is overworked, 0 = None, 1 = Mixing, 2 = Moulding, 3 = Foiling
local previousMagicNumber               = 0                             -- global variable utilized to resetting the overworkedStation flag
local currentMagicNumber                = 0                             -- global variable utilized to resetting the overworkedStation flag affected by new bunny orders recorded
local tileDistanceMaximum               = 50                            -- Maximum distance from player (Can be raised or lowered)
local keyboardButtonPressed1            = 0x31                          -- Submits a keyboard press of 1 from the num row
local keyboardButtonPressed2            = 0x32                          -- Submits a keyboard press of 2 from the num row
local keyboardButtonPressed3            = 0x33                          -- Submits a keyboard press of 3 from the num row
local worldInteractionResponse          = 0x38                          -- Submits the interaction equivalent of a left click
local offsetValue                       = 0                             -- offset value
local curPlayerStation                  = 0                             -- 0 = idle, 1 = Mixing station, 2 = Moulding station, 3 = Foiling station
local curPlayerOptionSelected           = 0                             -- 0 = idle, 1 = menu option 1, 2 = menu option 2, 3 = menu option 3
local curMixInstructionNumber           = 0                             -- 0 = idle, 1 = menu option 1, 2 = menu option 2, 3 = menu option 3
local curMouldInstructionNumber         = 0                             -- 0 = idle, 1 = menu option 1, 2 = menu option 2, 3 = menu option 3
local curFoilInstructionNumber          = 0                             -- 0 = idle, 1 = menu option 1, 2 = menu option 2, 3 = menu option 3
local randomizedIndexNumber             = math.random(1, 9)             -- Selects a random number within 1 and 9
--local startTime                         = os.time()                     -- Not yet implemented
local idleTimeThreshold                 = math.random(46, 247)          -- Used in antiIdle
local optimizationFirstPassFlag         = 0                             -- Global variable to check if first pass was done to reduce console spam
local mixingStationRefTable = {
    ["fruit and nut"] = 1,
    ["banoffee"] = 2,
    ["rocky road"] = 3
}
local mouldingStationRefTable = {
    ["eggs"] = 1,
    ["bars"] = 2,
    ["bunnies"] = 3
}
local foilingStationRefTable = {
    ["pink"] = 1,
    ["blue"] = 2,
    ["yellow"] = 3
}

print("Initializing Variables Completed.") -- prints to console

print("Defining functions. . .") -- prints to console

-- Defining Functions --

-- Custom wait function
local function wait(seconds)
    local start = os.time()
    repeat
        -- Keep looping until the specified time has passed
    until os.time() > start + seconds
end
    
-- Converts distance of 1 tile per tick (0.6 seconds)
local function distanceToTime(waitTile)
    local curPlayerPosition = API.PlayerCoord()
    local distanceX = waitTile.x - curPlayerPosition.x
    local distanceY = waitTile.y - curPlayerPosition.y
    local distance = math.sqrt(distanceX * distanceX + distanceY * distanceY)
    local timeToWait = distance * 0.6 -- multiply tile distance by tick time
        
    return timeToWait
end
    
-- Custom travel wait function due to bug incurred with DoObject + WaitUntilMovingEnds
local function waitUntilTileReached()
    local waitTile = ""
    local timeToWait = 0
    if curPlayerStation == 1 then
        waitTile = mixingStationPlayerLocation
        timeToWait = distanceToTime(waitTile)
        wait(timeToWait)
    elseif curPlayerStation == 2 then
        waitTile = mouldingStationPlayerLocation
        timeToWait = distanceToTime(waitTile)
        wait(timeToWait)
    elseif curPlayerStation == 3 then
        waitTile = foilingStationPlayerLocation
        timeToWait = distanceToTime(waitTile)
        wait(timeToWait)
    end
end

-- Takes an arbitrary number and determines which stationID that corresponds to
local function defineStation(stationNumber)
    local stationDefinitions = {mixingStationID, mouldingStationID, foilingStationID}
    local stationDefinition = stationDefinitions[stationNumber]
    return stationDefinition
end

-- Take ObjectID and revert it to its table key
local function undefineStation(stationDefinition)
    local stationNumber = 0
    if stationDefinition == mixingStationID then
        stationNumber = 1
    elseif stationDefinition == mouldingStationID then
        stationNumber = 2
    elseif stationDefinition == foilingStationID then
        stationNumber = 3
    end
    return stationNumber
end

-- Takes productNumber and finds productDefinition
local function defineProduction(stationNumber, productNumber)
    local mixingStationProducts = {"fruit and nut","banoffee","rocky road"}
    local mouldingStationProducts = {"eggs","bars","bunnies"}
    local foilingStationProducts = {"pink", "blue", "yellow"}
    local productDefinition = ""

    if stationNumber == 1 then
        productDefinition = mixingStationProducts[productNumber]
    elseif stationNumber == 2 then
        productDefinition = mouldingStationProducts[productNumber]
    elseif stationNumber == 3 then
        productDefinition = foilingStationProducts[productNumber]
    end

    return productDefinition
end

-- Takes productDefinition and finds productNumber
local function undefineProduction(stationNumber, productDefinition)
    local productNumber = 0
    if stationNumber == 1 then
        for key, value in pairs(mixingStationRefTable) do
            productNumber = mixingStationRefTable[productDefinition]
        end
    elseif stationNumber == 2 then
        for key, value in pairs(mouldingStationRefTable) do
            productNumber = mouldingStationRefTable[productDefinition]
        end
    elseif stationNumber == 3 then
        for key, value in pairs(foilingStationRefTable) do
            productNumber = foilingStationRefTable[productDefinition]
        end
    end
    return productNumber
end

-- Provides a random station to work with
-- Returns stationDefinition
local function setRandomStation()
    local randomstation = {1, 2, 3, 1, 2, 3, 1, 2, 3}
    local stationUsed = randomstation[randomizedIndexNumber]
    local stationDefinition = defineStation(stationUsed)
    return stationDefinition
end

-- Provides a random set of production orders
-- Returns productionSettings
local function setRandomProduction()
    local randomProduction = {"fruit and nut","eggs","pink","banoffee","bars","blue","rocky road","bunnies","yellow"}
    local productionSettings = randomProduction[randomizedIndexNumber]
    return productionSettings
end

-- Determines which station to interact with
local function setStation(stationDefinition)
    local stationLocations = {mixingStationLocation, mouldingStationLocation, foilingStationLocation}
    local stationNumber = undefineStation(stationDefinition)
    local stationLocation = stationLocations[stationNumber]

    print("Interacting with station: " .. stationNumber)
    API.DoAction_Object2(worldInteractionResponse, offsetValue, {stationDefinition}, tileDistanceMaximum, stationLocation)
    curPlayerStation = stationNumber
end

-- Tells the script which button to press based on production orders
local function setProduction(productionSettings)
    --print("Debug_productionSettings: " .. productionSettings) --debug
    if productionSettings == "fruit and nut" or productionSettings == "eggs" or productionSettings == "pink" then
        print("Selecting option 1")
        API.KeyboardPress31(keyboardButtonPressed1, 300, 299)
        curPlayerOptionSelected = 1
    elseif productionSettings == "banoffee" or productionSettings == "bars" or productionSettings == "blue" then
        print("Selecting option 2")
        API.KeyboardPress31(keyboardButtonPressed2, 300, 299)
        curPlayerOptionSelected = 2
    elseif productionSettings == "rocky road" or productionSettings == "bunnies" or productionSettings == "yellow" then
        print("Selection option 3")
        API.KeyboardPress31(keyboardButtonPressed3, 300, 299)
        curPlayerOptionSelected = 3
    end
end

-- Tells the script which button to press based on production orders
local function setStationPrimeOptions(curMixingStationInstruction, curMouldingStationInstruction, curFoilingStationInstruction)
    for key, value in pairs(mixingStationRefTable) do
        curMixInstructionNumber = mixingStationRefTable[curMixingStationInstruction]
    end
    for key, value in pairs(mouldingStationRefTable) do
        curMouldInstructionNumber = mouldingStationRefTable[curMouldingStationInstruction]
    end
    for key, value in pairs(foilingStationRefTable) do
        curFoilInstructionNumber = foilingStationRefTable[curFoilingStationInstruction]
    end
end

-- Will compare player's y position to the station's y position to determine current station
local function usingStationAtPlayerPosition()
    local currentPlayerPosition = API.PlayerCoord()
    
    if currentPlayerPosition.y == mixingStationPlayerLocation.y then
        curPlayerStation = 1
    elseif currentPlayerPosition.y == mouldingStationPlayerLocation.y then
        curPlayerStation = 2
    elseif currentPlayerPosition.y == foilingStationPlayerLocation.y then
        curPlayerStation = 3
    else
        curPlayerStation = 0
    end
end

-- Finds mixing station instructions and returns mixing station productionSettings
local function stewyOrders(chatMessages)
    local mixingStationChatTable = {          -- Creates a table references
        ["<col=FCDC86>Stewy Bunny</col>: <col=99FF99>Mix some fruit and nut chocolate!</col>"]   = "fruit and nut",
        ["<col=FCDC86>Stewy Bunny</col>: <col=99FF99>Mix some banoffee chocolate!</col>"]        = "banoffee",
        ["<col=FCDC86>Stewy Bunny</col>: <col=99FF99>Mix some rocky road chocolate!</col>"]      = "rocky road"
    }
    for key, value in pairs(mixingStationChatTable) do 
        if mixingStationChatTable[chatMessages] ~= nil then
            currentMagicNumber = currentMagicNumber + 1
            -- print(mixingStationChatTable[chatMessages]) --debug
            return mixingStationChatTable[chatMessages]
        end
    end
end

-- Filters out nil variables and assigns global variable
local function assignCurMixingStationInstruction (newMixingStationInstruction)
    if newMixingStationInstruction ~= nil then
        curMixingStationInstruction = newMixingStationInstruction
    end
end

local function assignPlayerMixingInstruction()
    if curPlayerOptionSelected ~= curMixInstructionNumber then
        print("Current Player Selection: " .. curPlayerOptionSelected)
        print("Current Mix Instruction Number: " .. curMixInstructionNumber)
        if optimizationFirstPassFlag == 0 then
            curMixInstructionNumber = curPlayerOptionSelected
            curMixingStationInstruction = defineProduction(1, curMixInstructionNumber)
        end

        if optimizationFirstPassFlag > 0 then
            API.RandomSleep2(300,100,100)
            setStation(mixingStationID)
            waitUntilTileReached()
            API.RandomSleep2(1000,700,1000)
            --print("Debug_CurMixingStationInstruction: " .. curMixingStationInstruction) --debug
            setProduction(curMixingStationInstruction)
        end
        curPlayerOptionSelected = curMixInstructionNumber
        print("Current Player Selection: " .. curPlayerOptionSelected)
        print("Current Mix Instruction Number: " .. curMixInstructionNumber)
    end
end

-- Finds moulding station instructions and returns moulding station productionSettings
local function gooeyOrders(chatMessages)
    local mouldingStationChatTable = {         -- Creates a table with references
        ["<col=93D7FA>Gooey Bunny</col>: <col=99FF99>Mould the chocolate into eggs!</col>"]      = "eggs",
        ["<col=93D7FA>Gooey Bunny</col>: <col=99FF99>Mould the chocolate into bars!</col>"]      = "bars",
        ["<col=93D7FA>Gooey Bunny</col>: <col=99FF99>Mould the chocolate into bunnies!</col>"]   = "bunnies"
    }
    for key, value in pairs(mouldingStationChatTable) do 
        if mouldingStationChatTable[chatMessages] ~= nil then
            currentMagicNumber = currentMagicNumber + 1
            -- print(mouldingStationChatTable[chatMessages]) --debug
            return mouldingStationChatTable[chatMessages]
        end
    end
end

-- Filters out nil variables and assigns global variable
local function assignCurMouldingStationInstruction (newMixingStationInstruction)
    if newMouldingStationInstruction ~= nil then
        curMouldingStationInstruction = newMouldingStationInstruction
    end
end

local function assignPlayerMouldingInstruction()
    if curPlayerOptionSelected ~= curMouldInstructionNumber then
        print("Current Player Selection: " .. curPlayerOptionSelected)
        print("Current Mould Instruction Number: " .. curMouldInstructionNumber)
        if optimizationFirstPassFlag == 0 then
            curMouldInstructionNumber = curPlayerOptionSelected
            curMouldingStationInstruction = defineProduction(2, curMouldInstructionNumber)
        end

        if optimizationFirstPassFlag > 0 then
            API.RandomSleep2(300,100,100)
            setStation(mouldingStationID)
            waitUntilTileReached()
            API.RandomSleep2(1000,700,1000)
            --print("Debug_CurMouldingStationInstruction: " .. curMouldingStationInstruction) --debug
            setProduction(curMouldingStationInstruction)
        end
        curPlayerOptionSelected = curMouldInstructionNumber
        print("Current Player Selection: " .. curPlayerOptionSelected)
        print("Current Mould Instruction Number: " .. curMouldInstructionNumber)
    end
end

-- Finds foiling station instructions and returns foiling station productionSettings
local function chewyOrders(chatMessages)
    local foilingStationChatTable = {          -- Creates a table with references
        ["<col=FFADC3>Chewy Bunny</col>: <col=99FF99>Wrap the chocolate in pink foil!</col>"]    = "pink",
        ["<col=FFADC3>Chewy Bunny</col>: <col=99FF99>Wrap the chocolate in blue foil!</col>"]    = "blue",
        ["<col=FFADC3>Chewy Bunny</col>: <col=99FF99>Wrap the chocolate in yellow foil!</col>"]  = "yellow"
    }
    for key, value in pairs(foilingStationChatTable) do 
        if foilingStationChatTable[chatMessages] ~= nil then
            currentMagicNumber = currentMagicNumber + 1
            -- print(foilingStationChatTable[chatMessages]) --debug
            return foilingStationChatTable[chatMessages]
        end
    end
end

-- Filters out nil variables and assigns global variable
local function assignCurFoilingStationInstruction (newMixingStationInstruction)
    if newFoilingStationInstruction ~= nil then
        curFoilingStationInstruction = newFoilingStationInstruction
    end
end

local function assignPlayerFoilingInstruction()
    if curPlayerOptionSelected ~= curFoilInstructionNumber then
        print("Current Player Selection: " .. curPlayerOptionSelected)
        print("Current Foil Instruction Number: " .. curFoilInstructionNumber)
        if optimizationFirstPassFlag == 0 then
            curFoilInstructionNumber = curPlayerOptionSelected
            curFoilingStationInstruction = defineProduction(3, curFoilInstructionNumber)
        end

        if optimizationFirstPassFlag > 0 then
            API.RandomSleep2(300,100,300)
            setStation(foilingStationID)
            waitUntilTileReached()
            API.RandomSleep2(1000,700,1000)
            --print("Debug_CurMouldingStationInstruction: " .. curMouldingStationInstruction) --debug
            setProduction(curFoilingStationInstruction)
        end
        curPlayerOptionSelected = curFoilInstructionNumber
        print("Current Player Selection: " .. curPlayerOptionSelected)
        print("Current Foil Instruction Number: " .. curFoilInstructionNumber)
    end
end

-- Finds the overworked station and returns stationNumber
local function stationOverworked(chatMessages)
    local eventShoutChatTable = {              -- Creates a table with references
        ["<col=FCDC86>Stewy Bunny</col>: <col=99FF99>The mixing station is overworked, we need more workers elsewhere!</col>"]   = 1,
        ["<col=93D7FA>Gooey Bunny</col>: <col=99FF99>The moulding station is overworked, we need more workers elsewhere!</col>"] = 2,
        ["<col=FFADC3>Chewy Bunny</col>: <col=99FF99>The foiling station is overworked, we need more workers elsewhere!</col>"]  = 3
    }
    for key, value in pairs(eventShoutChatTable) do 
        if eventShoutChatTable[chatMessages] ~= nil then
            --print(eventShoutChatTable[chatMessages]) --debug
            return eventShoutChatTable[chatMessages]
        end
    end
end

-- Tallies the instruction changes and 
-- compares to the last change to see if overworked machine flag needs to reset
-- returns 0 if true
local function overworkedStationResetCheck()
    if previousMagicNumber < currentMagicNumber then
        return 0
    end
end

-- Filters out nil variables and assigns global variable
local function assignOverworkedStation(curOverworkedStation)
    if newOverworkedStationNumber ~= nil then
        curOverworkedStationNumber = newOverworkedStationNumber
    end
end

-- Checks to see if the player is currently at the Overworked Station
-- Returns Boolean
local function playerAtOverworkedStation()
    if curPlayerStation == curOverworkedStationNumber then
        return true
    else
        return false
    end 
end

-- Determines if the player should change stations
local function stopWastingTime(playerTimeWasted) -- Pass through boolean
    local stationDefinition = 0
    if curPlayerStation == 1 then
        stationDefinition = defineStation(2)
        setStation(stationDefinition)
    elseif curPlayerStation == 2 then
        stationDefinition = defineStation(1)
        setStation(stationDefinition)
    elseif curPlayerStation == 3 then
        stationDefinition = defineStation(2)
        setStation(stationDefinition)
    elseif curPlayerStation == 0 then
        os.quit()
    end
end

    -- Assigns a random station to start working at
local function assignRandomStation()
    local station = setRandomStation()
    local product = setRandomProduction()

    setStation(station)
    waitUntilTileReached()
    setProduction(product,station)
end

-- Assigns the station directly next to the player to work at
local function assignCloseStation()
    local station = curPlayerStation
    local product = setRandomProduction()
    
    station = defineStation(station)
    setStation(station)
    API.RandomSleep2(500,300,300)
    setProduction(product,station)
end

-- Maximization Logic for all stations
local function springTokenMaximizationAllStations()
    local playerTimeWasted = playerAtOverworkedStation()
    
    if optimizationFirstPassFlag == 0 or currentMagicNumber > previousMagicNumber then
        if prevMixingStationInstruction ~= curMixingStationInstruction then
            print("Mixing station instructions changed from "  .. prevMixingStationInstruction .. " to " .. curMixingStationInstruction .. ".")
        end
        if prevMouldingStationInstruction ~= curMouldingStationInstruction then
            print("Moulding station instructions changed from " .. prevMouldingStationInstruction .. " to " .. curMouldingStationInstruction .. ".")
        end
        if prevFoilingStationInstruction ~= curFoilingStationInstruction then
            print("Foiling station instructions changed from " .. prevFoilingStationInstruction .. " to " .. curFoilingStationInstruction .. ".")
        end
        -- Can't concatenate boolean, formats to look normal in console
        if playerTimeWasted == true then
            print("Station Overworked: true")
        elseif playerTimeWasted == false then
            print("Station Overworked: false")
        end
        
        prevMixingStationInstruction = curMixingStationInstruction
        prevMouldingStationInstruction = curMouldingStationInstruction
        prevFoilingStationInstruction = curFoilingStationInstruction
    end

    if playerTimeWasted == true then
        stopWastingTime(playerTimeWasted)
    end

    if curPlayerStation == 1 then
        assignPlayerMixingInstruction()
    elseif curPlayerStation == 2 then    
        assignPlayerMouldingInstruction()
    elseif curPlayerStation == 3 then
        assignPlayerFoilingInstruction()
    elseif curPlayerStation == 0 then
        os.quit()
    end
end

-- Maximization Logic for two enabled stations
local function springTokenMaximization2Stations()
    print("Not yet implemented - changing all enabled flags to on")
    mixingStationEnabled = 1
    mouldingStationEnabled = 1
    foilingStationEnabled = 1
end

-- Maximization Logic for one enabled station
local function springTokenMaximization1Station()
    print("Not yet implemented - changing all enabled flags to on")
    mixingStationEnabled = 1
    mouldingStationEnabled = 1
    foilingStationEnabled = 1
end

-- Prioritizes maximum spring tokens across all stations
local function allStationsEnabled()
    springTokenMaximizationAllStations()
end

-- Prioritizes maximum spring tokens between two stations
local function twoStationsEnabled()
    springTokenMaximization2Stations()
end

-- Prioritizes maximum spring tokens one a single station
local function oneStationEnabled()
    springTokenMaximization1Station()
end

-- You need a station enabled, so this just quits :)
local function noStationEnabled()
    print("Stations must be enabled")
    print("Goodbye. . .")
    os.exit()    
end


--Debug prints to check variables throughout text capturing
local function debug_CurrentlyStoredVariablesPrints() 
    if curMixingStationInstruction == nil then
        print("Mixing Station Instruction: ")
    else
        print("Mixing Station Instruction: " .. curMixingStationInstruction)   
    end
    
    if curMouldingStationInstruction == nil then
        print("Moulding Station Instruction: ")
    else
        print("Moulding Station Instruction: " .. curMouldingStationInstruction)
    end
    
    if curFoilingStationInstruction == nil then 
        print("Foiling Station Instruction: ")
    else
        print("Foiling Station Instruction: " .. curFoilingStationInstruction)
    end
    
    if curOverworkedStationNumber == nil then
        print("Overworked Station Number: ")
    else
        print("Overworked Station Number: " .. curOverworkedStationNumber)
    end

    print("Previous Magic Number: " .. previousMagicNumber)
    print("Current Magic Number: " .. currentMagicNumber)
end


print("Functions defined.")

print("\t\tRunning lua script Easter Chocolate Machine Optimizer.\n")

-- Main --
usingStationAtPlayerPosition() -- Checks to see if player is already next to a station
print("Current Player Station: " .. curPlayerStation)--debug
if curPlayerStation > 0 then
    assignCloseStation()           -- Assigns the station the player is infront of w/ random production
else
    assignRandomStation()          -- If player is not standing infront of a particular station assign random
end

print("Detected " .. totalStationsEnabled .. " stations are enabled.")

API.Write_LoopyLoop(true)
while(API.Read_LoopyLoop()) do
    API.RandomEvents()
    local chatData = API.GatherEvents_chat_check()           -- Chat log messages

    for _, message in pairs (chatData) do                    
        if message.name == "" then                           -- differentiates player and npc messages
            print(message.text)                              -- outputs to console
        else
            print(message.name .. ": " .. message.text)      -- outputs to console
        end
        
        newMixingStationInstruction = stewyOrders(message.text)
        assignCurMixingStationInstruction (newMixingStationInstruction)
        
        newMouldingStationInstruction = gooeyOrders(message.text)
        assignCurMouldingStationInstruction (newMouldingStationInstruction)
        
        newFoilingStationInstruction = chewyOrders(message.text)
        assignCurFoilingStationInstruction (newFoilingStationInstruction)
        
        newOverworkedStationNumber = overworkedStationResetCheck()
        assignOverworkedStation(newOverworkedStationNumber)
        newOverworkedStationNumber = stationOverworked(message.text)
        assignOverworkedStation(newOverworkedStationNumber)
        
        --debug_CurrentlyStoredVariablesPrints()

        if curMixingStationInstruction ~= "initializing" and curMouldingStationInstruction ~= "initializing" and curFoilingStationInstruction ~= "initializing" then
            setStationPrimeOptions(curMixingStationInstruction, curMouldingStationInstruction, curFoilingStationInstruction)
        end
    end

    if totalStationsEnabled == 3 then
        allStationsEnabled()
    elseif totalStationsEnabled == 2 then
        twoStationsEnabled()
    elseif totalStationsEnabled == 1 then
        oneStationEnabled()
    elseif totalStationsEnabled == 0 then
        noStationEnabled()
    end

    previousMagicNumber = currentMagicNumber
    optimizationFirstPassFlag = 1
end
