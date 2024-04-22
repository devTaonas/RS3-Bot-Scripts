function file_exists(path)
    local f = io.open(path, "r")
    if f then f:close()end
    return f ~= nil
end

function require_if_exists(file)
    local user_profile = os.getenv("USERPROFILE")
    local directory = user_profile .. "\\Documents\\MemoryError\\Lua_Scripts\\procTeleTabs\\"
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
    print("#    Starting Script ProcTeleTabs   #")
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

local scriptFirstRun = true
local butlerIsWorking = false
local lastWithdrawAmount = 0


local function SelectTeleTab()
    local locationToChosenValue = {
        Varrock = 25, Lumbridge = 29, Camelot = 37,
        Ardougne = 41, Watchtower = 45, Falador = 33, House = 49, GWD = 53
    }

    local chosenValue = locationToChosenValue[teleTabList.string_value]

    if chosenValue then
        API.DoAction_Interface(0xffffffff,0xffffffff,1,1371,22,locationToChosenValue[teleTabList.string_value],API.OFF_ACT_GeneralInterface_route)
        API.RandomSleep2(200, 250, 350)
        API.DoAction_Interface(0xffffffff,0xffffffff,0,1370,30,-1,4512)
    end
end

function FindLectern()
    local searchIDs = {13642, 13643, 13644, 13645, 13646, 13647, 13648}
    local allObjects = API.ReadAllObjectsArray(false, 0)

    for _, object in ipairs(allObjects) do
        if(object.Id ~= nil) then
            for _, id in ipairs(searchIDs) do
                if(object.Id ~= nil) then
                    if object.Id == id then
                        return id
                    end
                end
            end
        end
        
    end
    return nil
end

local function FindButler()
    local availableButlers = {
        {name = "DemonButler", id = 4243, maxItems = 26},
        {name = "Butler", id = 4241, maxItems = 20},
        {name = "Cook", id = 4239, maxItems = 16},
        {name = "Maid", id = 4237, maxItems = 10},
        {name = "RoyalGuard", id = 15513, maxItems = 6},
        {name = "Rick", id = 4235, maxItems = 6},
    }

    local allNPCs = API.ReadAllObjectsArray(false, 1)
    local foundButler = nil

    for _, npc in pairs(allNPCs) do
        if npc.Id > 0 then
            local distance = API.Math_DistanceF(npc.Tile_XYZ, API.PlayerCoordfloat())
            if npc.Id ~= 0 and distance < 150 then
                for _, butler in ipairs(availableButlers) do
                    if npc.Id == butler.id then
                        print("Found Butler")
                        foundButler = {
                            id = butler.id,
                            maxItems = butler.maxItems,
                            distance = distance
                        }
                        break
                    end
                end
            end
        end
        if foundButler then break end
    end

    return foundButler
end

local function WaitForButler()
    local startTime = os.time()
    local maxWait = 10
    local butlerIsTalking = false

    local function summonButler()
        API.DoAction_Interface(0x24,0xffffffff,1,1665,13,-1,5392)
    end

    summonButler()

    repeat
        butlerIsTalking = (API.VB_FindPSett(2874, 0).state == 12)

        if not butlerIsTalking then
            API.RandomSleep2(500, 800, 1000)
        end

        if os.difftime(os.time(), startTime) >= maxWait then
            print("Butler didn't respond in time, calling again.")
            summonButler()
            startTime = os.time()
        end
    until butlerIsTalking
end

local function HandleButlerWithdrawal(butler)

    local function withdrawItemCount(itemCount)
        API.RandomSleep2(200, 500, 600)
        print(API.VB_FindPSett(2874, 0).state)
        API.RandomSleep2(500, 700, 950)
        if(API.VB_FindPSett(2874, 0).state == 10) then
            API.RandomSleep2(200, 500, 600)
            print("withdrawing " .. itemCount)
            local digits = tostring(itemCount)
            for i = 1, #digits do
                local digit = digits:sub(i, i)
                API.RandomSleep2(200, 500, 600)
                API.KeyPress_(digit)
            end
            API.RandomSleep2(200, 500, 600)
            API.KeyPress_("\13")
        end
        butlerIsWorking = true
        lastWithdrawAmount = itemCount
    end

    local function interactWithButler()
        print("Clicking soft clay")
        API.DoAction_Inventory1(1762, 0, 2, 4432)
        API.RandomSleep2(500, 800, 1500)
        print("Using on Butler")
        API.DoAction_NPC(0x24, 1408, { butler.id }, 50)
    end

    if API.VB_FindPSett(2874, 0).state == 0 and API.InventoryInterfaceCheckvarbit() == false then
        print("API.VB_FindPSett(2874, 0).state == 0 & inventoryVisible = false - Sending B key")
        API.KeyboardPress32(0x42, 0)
        API.RandomSleep2(500, 800, 800)
    end

    print(API.InventoryInterfaceCheckvarbit())
    if API.InventoryInterfaceCheckvarbit() then

        if API.VB_FindPSett(2874, 0).state == 12 then
            if lastWithdrawAmount > 0 and lastWithdrawAmount <= API.Invfreecount_() then
                print("Selecting Un-cert previous amount")
                if API.Select_Option("Un-cert another") then
                    butlerIsWorking = true
                    API.RandomSleep2(1500, 2000, 3500)
                    return
                end
            end

            if API.Select_Option("Un-cert") then
                print("Select un-cert new amount")
                local itemCount = math.min(API.Invfreecount_() - 1, butler.maxItems)
                if itemCount > 0 then
                    withdrawItemCount(itemCount)
                else
                    print("No free inventory slots available")
                end
                API.RandomSleep2(1500, 2000, 3500)
            end
        end

        if API.VB_FindPSett(2874, 0).state == 0 or API.VB_FindPSett(2874, 0).state == 12 then
            print("Inventory visible and not talking or base talking - interacting with butler")
            interactWithButler()
            API.RandomSleep2(500, 650, 800)
        end
    end
end

local function procTeleTabs()

    local isWorking = API.isProcessing()
    local softClayCount = API.InvItemcount_1(1761)
    local lawRuneCount = API.InvStackSize(563)

    if(lawRuneCount == 0) then
        return
    end

    if(isWorking == false and butlerIsWorking == false and softClayCount == 0 and lawRuneCount > 0) then
        local butler = FindButler()
        if(butler ~= nill) then
            if(butler.distance > 5) then
                print("Waiting for butler")
                WaitForButler()
            else
                print("Withdrawing from butler")
                HandleButlerWithdrawal(butler)
            end
        end
    end

    if(isWorking == false and softClayCount > 0 and lawRuneCount > 0) then
        API.DoAction_Object1(0x3f,0,{ FindLectern() },50)
        API.RandomSleep2(1500, 2000, 3500)
        SelectTeleTab()
        API.RandomSleep2(500, 700, 1500)
        API.DoAction_Interface(0xffffffff,0xffffffff,0,1370,30,-1,4512)
        API.RandomSleep2(500, 500, 500)
        butlerIsWorking = false
    end
end

local function FirstRun()
    local player = API.GetLocalPlayerName()
    API.Write_ScripCuRunning0("procTeleTabs: " .. player)
    firstRun = false;
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
        if(scriptFirstRun) then 
            FirstRun() 
        end

        if(teleTabList.string_value == "Select Tab" or teleTabList.string_value == nil or teleTabList.string_value == "" or teleTabList.string_value == " ") then
            print("Waiting for user to finish setup")
        else
            procTeleTabs()
        end
    end

API.RandomSleep2(500, 3050, 5000)
end----------------------------------------------------------------------------------
