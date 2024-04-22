print("Run Lua script procTeleTabs.")

local API = require("api")
local Utils = require("utils")


local function WriteLog(inputLog)
    local time = os.date('%Y-%m-%d %H:%M:%S')
    print(time .. ": " .. inputLog)
end


API.Write_LoopyLoop(true)
while(API.Read_LoopyLoop())
do-----------------------------------------------------------------------------------

    if(API.GetGameState() == 3) then

        API.DoRandomEvents()
        local working = API.isProcessing()

        if(API.InvItemcount_1(1761) >= 5 and working == false) then
            WriteLog("Making tablets")
            API.RandomSleep2(500, 500, 500)
            API.DoAction_Object1(0x3f,0,{ 13647 },50); --Click lecturn

            API.RandomSleep2(1500, 1500, 1500)
            API.DoAction_Interface(0xffffffff,0xffffffff,0,1370,30,-1,4512) --Make selected tabs
            API.RandomSleep2(1500, 1500, 1500)
        end

        if(API.InvItemcount_1(1761) == 0 and working == false) then
            WriteLog("Getting more unnoted soft clay")
            API.RandomSleep2(500, 500, 500)
            API.DoAction_Interface(0x24,0x6e2,0,1473,5,26,4432)
            API.RandomSleep2(500, 500, 500)

            API.DoAction_NPC(0x24,1408,{ 4243 },50)
            API.RandomSleep2(1000, 1000, 1000)

            if(API.SelectToolOpen("Un-cert")) then
                print("found uncert")

                API.KeyPress_("2") -- send 2
                API.RandomSleep2(200, 200, 200)

                API.KeyPress_("0") -- send 5
                API.RandomSleep2(500, 500, 500)

                API.KeyPress_("\13") -- send enter
                API.RandomSleep2(3000, 3000, 3000)
            end

        end
    end



API.RandomSleep2(500, 3050, 12000)
end----------------------------------------------------------------------------------
