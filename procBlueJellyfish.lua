print("Run Lua script procBlueJellyfish.")

local API = require("api")
local Utils = require("utils")

local startTime = os.time()
local idleTimeThreshold = math.random(120, 260)
local timerDuration = 60  -- Timer duration in seconds
API.Write_ScripCuRunning0("procJellies")

local function AntiAFK()
    local currentTime = os.time()
    local elapsedTime = os.difftime(currentTime, startTime)

    if elapsedTime >= idleTimeThreshold then
        API.PIdle2()
        startTime = os.time()
        idleTimeThreshold = math.random(200, 280)
        print("Reset Timer & Threshhold")
    end
end

local function FindJellies()
    local allNPCS = API.ReadAllObjectsArray(false, 1)
    local jellies = {}
    if #allNPCS > 0 then
        for _, a in pairs(allNPCS) do
            if(a.Id > 0) then
                local distance = API.Math_DistanceF(a.Tile_XYZ, API.PlayerCoordfloat())
            a.Distance = distance;
            if a.Id ~= 0 and distance < 50 then
                if a.Name == "Blue blubber jellyfish" then
                    table.insert(jellies, a.Id)
                end
            end
            end
            
        end
        
        return { npcs = jellies }
    end
end

local function Fishing()

    local player = API.GetLocalPlayerName()
    local fishing = API.IsPlayerAnimating_(player, 3)
    
    if(fishing == false) then
        print("Starting to fish")
        local jellies = FindJellies()

        Utils.randomSleep(100)
        API.DoAction_NPC(0x3c, API.OFF_ACT_InteractNPC_route, {jellies.npcs[1]}, 15)
        Utils.randomSleep(100)

        API.WaitUntilMovingEnds()
    end
end

--Exported function list is in API
--main loop
API.Write_LoopyLoop(true)
while(API.Read_LoopyLoop())
do-----------------------------------------------------------------------------------

    API.DoRandomEvents()
    Fishing()
    AntiAFK();


API.RandomSleep2(500, 10000, 12000)
end----------------------------------------------------------------------------------
