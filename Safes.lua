os.execute("cls")
local API = require("api")
local player = API.GetLocalPlayerName()
API.Write_ScripCuRunning0("t_Safes: " .. player)

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

local function DoSafes()

    if(not API.IsPlayerAnimating_(player, 5)) then
        print("clicking 1")
        API.DoAction_Object1(0x29,0,{ 111225 },50)
        API.RandomSleep2(4000, 500, 500)
    end

    if(not API.IsPlayerAnimating_(player, 5)) then
        print("clicking 2")
        API.DoAction_Object1(0x29,0,{ 111226 },50)
        API.RandomSleep2(4000, 500, 500)
    end

    if(not API.IsPlayerAnimating_(player, 5)) then
        print("clicking 3")
        API.DoAction_Object1(0x29,0,{ 111227 },50)
        API.RandomSleep2(4000, 500, 500)
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
        DoSafes();
        AntiAFK();
    end

API.RandomSleep2(500, 3050, 12000)
end