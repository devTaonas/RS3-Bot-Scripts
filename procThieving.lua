function file_exists(path)
    local f = io.open(path, "r")
    if f then f:close()end
    return f ~= nil
end

function require_if_exists(file)
    local user_profile = os.getenv("USERPROFILE")
    local directory = user_profile .. "\\Documents\\MemoryError\\Lua_Scripts\\procThieving\\"
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
    print("#    Starting Script procThieving   #")
    print("#####################################")
if (status) then
    print("#  procGUI.lua Loaded Successfully  #")
    print("#####################################")
    procGUI = module_or_error
    procGUI.Init()
else
    print("#        procGUI.lua missing        #")
    print("#           No GUI Loaded           #")
    print("#####################################")
    print(module_or_error)
end

local function FirstRun()
    local player = API.GetLocalPlayerName()
    API.Write_ScripCuRunning0("procThieving: " .. player)
    firstRun = false;
end
    
local function FindNPC(target)
    local allNPCs = API.ReadAllObjectsArray(false, 1)
    local foundNPC = nil

    for _, npc in pairs(allNPCs) do
        if npc.Id > 0 then
            local distance = API.Math_DistanceF(npc.Tile_XYZ, API.PlayerCoordfloat())
            npc.Distance = distance;
            if npc.Id ~= 0 and distance < 150 then
                if npc.Name == target then
                    if(npc.Distance < 10) then
                        print("Found NPC")
                        foundNPC = npc.Id
                    end
                end
            end
        end
        if foundNPC then break end
    end

    return foundNPC
end

local function procThieving()

    local isWorking = API.isProcessing()
    print(isWorking)

    if (teleTabList.string_value == "Man/Woman") then

        if(not isWorking) then
            API.DoAction_NPC(0x29,3328,{ FindNPC("Man") },50)
            API.WaitUntilMovingEnds()
        end
    end

end

API.Write_LoopyLoop(true)
while(API.Read_LoopyLoop())
do-----------------------------------------------------------------------------------

    if(status) then
        procGUI.Draw()
    end

    if (API.GetGameState() == 2) then
        API.KeyPress_(" ")
    end

    if(API.GetGameState() == 3) then
        API.DoRandomEvents()

        if(scriptFirstRun) then 
            FirstRun() 
        end

        if(teleTabList.string_value == "Select Action" or teleTabList.string_value == nil or teleTabList.string_value == "" or teleTabList.string_value == " ") then
            print("Waiting for user to finish setup")
        else
            procThieving()
        end
    end



API.RandomSleep2(500, 3050, 12000)
end----------------------------------------------------------------------------------
