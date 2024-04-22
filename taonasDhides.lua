os.execute("cls")
local API = require("api")
local player = API.GetLocalPlayerName()
API.Write_ScripCuRunning0("t_ScriptName: " .. player)

local idleTimeThreshold = math.random(120, 260)
local startTime = os.time()

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

local function Crafting()

    if(not API.isProcessing()) then
        print("not processing")
        if(not API.InvFull_()) then
            print("loading preset")
            API.DoAction_Object1(0x33,240,{ 79036 },50)
            API.RandomSleep2(2000, 200, 200)
        end

        print("Clicking crafter")
        API.DoAction_Interface(0x3e,0x9cd,1,1473,5,0,3808)
        API.RandomSleep2(2000, 200, 200)
        API.KeyPress_(" ")
    end
end

API.Write_LoopyLoop(true)
while(API.Read_LoopyLoop())
do
    
    if (API.GetGameState2() == 2) then
        API.KeyPress_(" ")
        API.RandomSleep2(200, 200, 200)
    end

    if(API.GetGameState2() == 3) then
        API.DoRandomEvents()
        AntiAFK();
        Crafting()
    end

API.RandomSleep2(500, 3050, 12000)
end