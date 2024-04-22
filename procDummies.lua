function file_exists(path)
    local f = io.open(path, "r")
    if f then f:close()end
    return f ~= nil
end

function require_if_exists(file)
    local user_profile = os.getenv("USERPROFILE")
    local directory = user_profile .. "\\Documents\\MemoryError\\Lua_Scripts\\procDummies\\"
    local filename = file:gsub("%.", "\\")
    local path = directory .. filename .. ".lua"
    
print(file_exists(path))

    if file_exists(path) then
        local path_to_add = directory .. "?.lua"
        if not string.find(package.path, path_to_add, 1, true) then
            package.path = package.path .. ";" .. path_to_add
        end
        return require(file)
    end
end

local status, module_or_error = pcall(require_if_exists, "procGUI")
local procGUI = {}
local API = require("api")

    os.execute("cls")
    print("#####################################")
    print("#     Starting Script ProcDummies   #")
    print("#####################################")
if (status) then
    print("#  procGUI.lua Loaded Successfully  #")
    print("#####################################")
    procGUI = module_or_error
    procGUI.Init()
    API.Write_ScripCuRunning0("procDummies")
else
    print("#        procGUI.lua missing        #")
    print("#      No Functionality Loaded      #")
    print("#####################################")
    print(module_or_error)
end

local scriptFirstRun = true

local function FirstRun()
    local player = API.GetLocalPlayerName()
    API.Write_ScripCuRunning0("procDummies: " .. player)
    scriptFirstRun = false;
end

local startTime2 = os.time()
local idleTimeThreshold = math.random(120, 260)

local function AntiAFK()
    local currentTime = os.time()
    local elapsedTime = os.difftime(currentTime, startTime2)

    if elapsedTime >= idleTimeThreshold then
        API.PIdle2()
        startTime2 = os.time()
        idleTimeThreshold = math.random(200, 280)
        print("Reset Timer & Threshhold")
    end
end

local function PerformAction(itemId, sticks) 
    local i = 0
    local inv = API.ReadInvArrays33()
    if #inv > 0 then
        for _, a in pairs(inv) do
            if(a.itemid1 == itemId) then
                if(sticks == false) then
                    API.DoAction_Interface(0x24,0x8d63,2,1473,5,i,5392);
                    API.RandomSleep2(200, 400, 800)
                else
                    if (API.InvItemcount_1(47715) > 0) then
                        if (not API.Buffbar_GetIDstatus(47715,false).found) then
                            API.DoAction_Interface(0x41,0xba63,2,1473,5,i,5392)
                            API.RandomSleep2(200, 400, 800)
                        end
                    
                        buffOverloadValue = API.Buffbar_GetIDstatus(47715, false).text
                        buffOverloadValue = buffOverloadValue:sub(1, -2)
                    
                        if(buffOverloadValue:match("1$")) then
                            print(API.Buffbar_GetIDstatus(47715, false).text)
                            API.DoAction_Interface(0x41,0xba63,2,1473,5,i,5392)
                            API.RandomSleep2(200, 400, 800)
                        end
                    
                        if(API.Buffbar_GetIDstatus(47715, false).conv_text < 11 and string.find(API.Buffbar_GetIDstatus(47715, false).text,"(4)")) then
                            API.DoAction_Interface(0x41,0xba63,1,1473,5,i,5392)
                            API.RandomSleep2(500, 1500, 1500)
                            API.DoAction_Interface(0x41,0xba63,1,1473,5,i,5392)
                            API.RandomSleep2(500, 1500, 1500)
                            API.DoAction_Interface(0x41,0xba63,1,1473,5,i,5392)
                            API.RandomSleep2(500, 1500, 1500)
                            API.DoAction_Interface(0x41,0xba63,1,1473,5,i,5392)
                            API.RandomSleep2(500, 1500, 1500)
                            API.DoAction_Interface(0x41,0xba63,1,1473,5,i,5392)
                        end
                    end
                end
            end
            i = i + 1
        end
    end
end


local function ActionDummy()
    local locationToChosenValue = {
        Slayer = 36195, Agility = 37700, Theiving = 36194, Archaeology = 54021, Dungeoneering = 54020, Combat = 50442
    }

    print(dummiesList.string_value)
    local chosenValue = locationToChosenValue[dummiesList.string_value]
    print(locationToChosenValue[dummiesList.string_value])

    if chosenValue then
        print("Deploying " .. chosenValue)
        PerformAction(locationToChosenValue[dummiesList.string_value], false)
        API.RandomSleep2(200, 250, 350)
    end
end

local function AnimCheck(loops)
    local player = API.GetLocalPlayerName()
    if(API.IsPlayerAnimating_(player, loops)) then
        print("Animating, not placing")
        API.RandomSleep2(2000, 2500, 3500)
        return true
    end
    print("Not animating, placing new dummy")
    return false
end

local function IncenseSticks()
    print("Checking incense...")
    if (API.InvItemcount_1(47715) > 0) then
        if (not API.Buffbar_GetIDstatus(47715,false).found) then
            print("Buff not found")
            PerformAction(47715, true)
        end
    
        buffOverloadValue = API.Buffbar_GetIDstatus(47715, false).text
        buffOverloadValue = buffOverloadValue:sub(1, -2)
    
        if(buffOverloadValue:match("1$")) then
            print("Buff not overloaded")
            PerformAction(47715, true)
        end

        print(API.Buffbar_GetIDstatus(47715, false).conv_text)
        print(string.find(API.Buffbar_GetIDstatus(47715, false).text,"(4)"))

        if(API.Buffbar_GetIDstatus(47715, false).conv_text < 11 and string.find(API.Buffbar_GetIDstatus(47715, false).text,"(4)")) then
            PerformAction(47715, true)
            print("Buff not maxed")
        end
    end
end

local function procDummies()

    local player = API.GetLocalPlayerName()
    local isWorking = API.IsPlayerAnimating_(player, 5)

    if(not AnimCheck(150)) then
        if(not AnimCheck(15)) then
            IncenseSticks()
            ActionDummy()
            API.RandomSleep2(200, 250, 350)
        end
    end
end

API.Write_LoopyLoop(true)
while(API.Read_LoopyLoop())
do-----------------------------------------------------------------------------------

    procGUI.Draw()

    if (API.GetGameState() == 2) then
        API.KeyPress_(" ")
    end

    if(API.GetGameState() == 3) then

        API.DoRandomEvents()
        AntiAFK()

        if(dummiesList.string_value == "Select Action" or dummiesList.string_value == nil or dummiesList.string_value == "" or dummiesList.string_value == " ") then
            print("Waiting for user to finish setup")
        else

            if(scriptFirstRun) then 
                print("First run!")
                FirstRun() 
                if(string.upper(dummiesList.string_value) ~= "Combat") then
                    procGUI.Config(string.upper(dummiesList.string_value))
                end
            end

            procDummies()
        end
    end

    API.RandomSleep2(500, 750, 1500)
end----------------------------------------------------------------------------------
