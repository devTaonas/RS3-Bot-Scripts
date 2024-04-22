print("Run Lua script procDivOMatic.")

local API = require("api")
local UTILS = require("utils")

local startTime = os.time()
local idleTimeThreshold = math.random(120, 260)
local timerDuration = 60  -- Timer duration in seconds

local function antiIdleTask()
    local currentTime = os.time()
    local elapsedTime = os.difftime(currentTime, startTime)

    if elapsedTime >= idleTimeThreshold then
        API.PIdle2()
        -- Reset the timer and generate a new random idle time
        startTime = os.time()
        idleTimeThreshold = math.random(220, 260)
        ScripCuRunning1 = "Timer interupt"
        print("Reset Timer & Threshhold")
    end
end

local function FindWisps() 

    local allNPCS = API.ReadAllObjectsArray(false, 1)
    local wisps = {}
    if #allNPCS > 0 then
        
        for _, a in pairs(allNPCS) do
            local distance = API.Math_DistanceF(a.Tile_XYZ, API.PlayerCoordfloat())
            a.Distance = distance;
            if a.Id ~= 0 and distance < 50 then
                if a.Name == "Incandescent wisp" then
                    print("found wisp " .. a.Id .. " - " .. a.Name)
                    table.insert(wisps, a.Id)
                end
            end
        end
        
        return { npcs = wisps }
    end
end


--Exported function list is in API
--main loop
API.Write_LoopyLoop(true)
while(API.Read_LoopyLoop())
do-----------------------------------------------------------------------------------

    --API.DoAction_NPC(0x29, API.OFF_ACT_InteractNPC_route, { target.id }, 15);

    if API.GetGameState() == 3 then
        API.DoRandomEvents()
        antiIdleTask()

        local player = API.GetLocalPlayerName()
        local isAnim = API.IsPlayerAnimating_(player, 10) 

        if(isAnim == false) then
            print("isAnim = false, clicking wisp")
            local target = FindWisps()

            API.DoAction_NPC(0x29, API.OFF_ACT_InteractNPC_route, { target.npcs[1] }, 15)
            API.WaitUntilMovingEnds()
        end
        API.RandomSleep2(500, 500, 500)
        API.WaitUntilMovingEnds()
        API.RandomSleep2(500, 500, 500)
    end





API.RandomSleep2(500, 3050, 12000)
end----------------------------------------------------------------------------------
