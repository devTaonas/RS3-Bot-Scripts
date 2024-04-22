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

local function Arrowheads()

    if(not API.IsPlayerAnimating_(player, 5)) then
        print("getting more things")
        API.DoAction_Object1(0x3f,0,{ 113262 },50)
        API.RandomSleep2(1000,500,500)
        API.KeyPress_(" ")
        API.RandomSleep2(2000,500,500)
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
        Arrowheads()
    end

API.RandomSleep2(500, 3050, 12000)
end