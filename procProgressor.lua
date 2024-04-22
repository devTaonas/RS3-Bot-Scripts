---@diagnostic disable: missing-parameter, undefined-global
local API = require("api")
local UTILS = require("utils")

local USERNAME_BOX_VARBIT_STR = "00000000000000000000000001100100"
local PASSWORD_BOX_VARBIT_STR = "00000000000000000000000001100101"
local INVALID_BOX_VARBIT_STR = "00000000000000000000000001100110"
local CURSOR_LOCATION_VARBIT_ID = 174
local BACKSPACE_KEY = 8
local USERNAME = false
local PASSWORD = false

local CurrentStage = "login"
local LoggedIn = false
local InsideRunespan = false
local CraftNatures = false
local RunesCrafted = 0

local accountOne = "" -- replace with your actual username/email

local coords = API.PlayerCoord()
local StartTime = os.time()

CurrentTarget = { idx = 0, type = 0, id = 0, weight = 0 }
local retryCount = 0

local specialChars = {
    ["!"] = true, ["@"] = true, ["#"] = true, ["$"] = true, ["%"] = true, ["^"] = true,
    ["&"] = true, ["*"] = true, ["("] = true, [")"] = true, ["_"] = true, ["-"] = true,
    ["+"] = true, ["="] = true, ["{"] = true, ["}"] = true, ["["] = true, ["]"] = true,
    ["|"] = true, ["\\"] = true, [":"] = true, [";"] = true, ['"'] = true, ["'"] = true,
    ["<"] = true, [">"] = true, [","] = true, ["."] = true, ["/"] = true, ["?"] = true, ["~"] = true
}

local function WriteLog(inputLog)
    local time = os.date('%Y-%m-%d %H:%M:%S')

    print(time .. ": " .. inputLog)
end

local function SplitString(s, sep)
    local fields = {}
    
    local sep = sep or " "
    local pattern = string.format("([^%s]+)", sep)
    string.gsub(s, pattern, function(c) fields[#fields + 1] = c end)
    
    return fields
end

local function GetCursorState()
    cursor_box = tostring(API.VB_GetBits(CURSOR_LOCATION_VARBIT_ID))

    USERNAME = false
    PASSWORD = false

    if cursor_box == USERNAME_BOX_VARBIT_STR then
        WriteLog("Detected username box...")
        USERNAME = true
    elseif 
        cursor_box == PASSWORD_BOX_VARBIT_STR then
            WriteLog("Detected password box...")
        PASSWORD = true
    end
end

local function GetUsernameInterfaceText()
    return API.ScanForInterfaceTest2Get(false,
        {{744, 0, -1, -1, 0}, {744, 26, -1, 0, 0}, {744, 39, -1, 26, 0}, {744, 52, -1, 39, 0}, {744, 93, -1, 52, 0}, {744, 94, -1, 93, 0}, {744, 96, -1, 94, 0}, {744, 110, -1, 96, 0}, {744, 111, -1, 110, 0}})[1].textids
end

local function DetectInvalidLoginScreen()
    local text = API.ScanForInterfaceTest2Get(false,
        {{744, 0, -1, -1, 0}, {744, 197, -1, 0, 0}, {744, 338, -1, 197, 0}, {744, 340, -1, 338, 0},
            {744, 342, -1, 340, 0}, {744, 345, -1, 342, 0}})[1].textids

    return text and text:find("Invalid email or password.")
end

local function ClearPasswordInput()
    if (API.GetGameState() == 1) then
        if USERNAME then
            API.KeyPress_("\t")
            API.RandomSleep2(600, 200, 200)
        end

        if PASSWORD then
            for i = 1, 40 do
                API.KeyboardPress2(BACKSPACE_KEY, .6, .2)
            end
            API.RandomSleep2(600, 200, 200)
        end
    end
end

local function TypeString(inputString)
    for i = 1, #inputString do
        local char = inputString:sub(i, i)
        API.KeyPress_(char)

        if specialChars[char] or char:match("%u") then
            API.RandomSleep2(200, 0, 0)
        end
    end
end

local function formatElapsedTime(startTime)
    local currentTime = os.time()
    local elapsedTime = currentTime - startTime
    local hours = math.floor(elapsedTime / 3600)
    local minutes = math.floor((elapsedTime % 3600) / 60)
    local seconds = elapsedTime % 60
    return string.format("[%02d:%02d:%02d]", hours, minutes, seconds)
end

local function Login(userPass)
    GetCursorState()
    local usernametext = GetUsernameInterfaceText()
    local combo = SplitString(userPass, ":")

    if (DetectInvalidLoginScreen()) then
        API.KeyPress_("\27")
        API.RandomSleep2(50, 50, 50)
        ClearPasswordInput()
    end

    if USERNAME then
        if usernametext == combo[1] then
            WriteLog("Username correctly entered")
            API.KeyPress_("\t")
            API.RandomSleep2(200, 200, 200)
        elseif usernametext == "" then
            WriteLog("Entering input...")
            TypeString(combo[1])
            API.RandomSleep2(200, 0, 0)
        elseif usernametext ~= "" and usernametext ~= combo[1] then
            WriteLog("Username detected, clearing login input...")
            for i = 1, 40 do
                API.KeyboardPress2(BACKSPACE_KEY, .6, .2)
            end
            API.RandomSleep2(5, 0, 0)
        else
            WriteLog("Something went very wrong...")
            API.Write_LoopyLoop(false)
        end
    end

    if PASSWORD then
        WriteLog("Entering input...")
        TypeString(combo[2])
        API.RandomSleep2(200, 0, 0)

        if usernametext == combo[1] then
            API.KeyPress_("\n")
            API.RandomSleep2(200, 0, 0)
        else
            API.KeyPress_("\t")
            API.RandomSleep2(200, 0, 0)
        end
    end
end

local function Staging()

    RunecraftingLevel = API.XPLevelTable(API.GetSkillXP("RUNECRAFTING"))

    if(RunecraftingLevel < 44) then

        WriteLog("Runecrafting level less than 44, moving to Runespan")
        API.RandomSleep2(3000, 2050, 5000)

        --Open Lodestone interface
        API.DoAction_Interface(0xffffffff, 0xffffffff, 1, 1465, 18, -1, API.OFF_ACT_GeneralInterface_route)
        API.RandomSleep2(500, 3050, 12000)

        --Is Draynor lodestone available?
        API.DoAction_Interface(0xffffffff, 0xffffffff, 1, 1092, 15, -1, API.OFF_ACT_GeneralInterface_route)
        API.RandomSleep2(3000, 2050, 5000)

        if(string.find(UTILS.UserDataToString(API.GetChatMessage(0, 3)), "You'll need to activate")) then
            
            CurrentStage = "LumbridgeToRunespan"

            --Lode not available teleport to lumbridge
            WriteLog("Draynor lode not available, teleporting to lumbridge and walking...")
            API.DoAction_Interface(0xffffffff, 0xffffffff, 1, 1092, 18, -1, API.OFF_ACT_GeneralInterface_route)
            API.RandomSleep2(3000, 2050, 5000)
            
            --Wait for teleport animation to finish
            UTILS.waitForAnimation(0, 20)
            API.RandomSleep2(3000, 2050, 5000)

            WriteLog("Arrived at Lumbridge lodestone... Walking to Runespan")
            API.RandomSleep2(6000, 3050, 8000)

            if(API.GetGameState() == 3) then
                print("Distance to Runespan: " .. API.Math_DistanceW(coords, WPOINT.new(3103, 3159, 0)))
            end

            API.DoAction_WalkerW(WPOINT.new(3103, 3159, 0))
            UTILS.waitForPlayerAtCoords(WPOINT.new(3103, 3159, 0), 0, 30)
            API.WaitUntilMovingEnds()

        else
            CurrentStage = "DraynorToRunespan"

            --Wait for teleport animation to finish
            UTILS.waitForAnimation(0, 20)
            API.RandomSleep2(3000, 2050, 5000)
            WriteLog("Teleporting to Draynor lodestone... Walking to Runespan")

            API.DoAction_WalkerW(WPOINT.new(3103, 3159, 0))
            UTILS.waitForPlayerAtCoords(WPOINT.new(3103, 3159, 0), 0, 30)
            API.WaitUntilMovingEnds()


        end
    end

end

local function WizardsTower()
    if(API.Math_DistanceW(coords, WPOINT.new(3103, 3159, 0)) < 10 and API.GetFloorLv_2() ~= 3 and CurrentStage ~= "RunespanFirstFloor") then
        --Go to top of tower 
        API.DoAction_Object_r(0x29,80,{ 79773 },50,WPOINT.new(3101,3154,0),5);
        API.RandomSleep2(3000, 2050, 5000) -- change to anim check ascending

        --API.RandomSleep2(3000, 2050, 5000)
        if(API.GetFloorLv_2() == 3) then
            CurrentStage = "RunespanTopFloor"
            API.RandomSleep2(200, 200, 200)
        end
    end

    if(API.Math_DistanceW(coords, WPOINT.new(3103, 3155, 3)) < 10) then
            WriteLog("Entering Runespan")
            API.DoAction_Object1(0x3f,0,{ 79519 },50);
            API.WaitUntilMovingEnds()
            API.RandomSleep2(6000, 3050, 8000) -- change to animal check going into portal

            if(API.Math_DistanceW(API.PlayerCoord(), WPOINT.new(3995, 6106, 1)) < 20) then
                WriteLog("Inside Runespan")
                CurrentStage = "RunespanFirstFloor"
                InsideRunespan = true
            end
    end
end

local function Compare(a, b)
    -- Compare weights in descending order
    if a.weight > b.weight then
        return true
    elseif a.weight < b.weight then
        return false
    end
    -- If weights are equal, compare distances in ascending order
    return a.distance < b.distance
end

local function DoActionTarget(target)
    if target.type == 0 then
        API.DoAction_Object2(0x29, API.OFF_ACT_GeneralObject_route0, { target.allObj.Id }, 15,
            WPOINT.new(target.allObj.TileX / 512, target.allObj.TileY / 512, target.allObj.TileZ / 512));
        CurrentTarget = { idx = target.idx, type = 0, id = target.allObj.Id, weight = target.weight }
        UTILS.randomSleep(4000)
        API.WaitUntilMovingEnds()
    elseif target.type == 1 then
        API.DoAction_NPC(0x29, API.OFF_ACT_InteractNPC_route, { target.id }, 15);
        CurrentTarget = { idx = target.idx, type = 1, id = target.allObj.Id, weight = target.weight }
        UTILS.randomSleep(4000)
        API.WaitUntilMovingEnds()
    end
end

local function IdentifyTargets()
    RunecraftingLevel = API.XPLevelTable(API.GetSkillXP("RUNECRAFTING"))
    local npcs = {}
    local objs = {}
    if RunecraftingLevel >= 1 then
        table.insert(npcs, { id = 15403, weight = 1001, type = 1 })                                 -- Air essling
        table.insert(npcs, { id = 15404, weight = 1002, type = 1 })                                 -- Mind essling
        table.insert(objs, { id = 70455, weight = 1006, type = 0 })                                 -- Cyclone
        table.insert(objs, { id = 70456, weight = 1007, type = 0 })                                 -- Mind storm
        if RunecraftingLevel >= 5 then
            table.insert(npcs, { id = 15405, weight = 1003, type = 1 })                             -- Water essling
            table.insert(objs, { id = 70457, weight = 1009, type = 0 })                             -- Water pool
            if RunecraftingLevel >= 9 then
                table.insert(npcs, { id = 15406, weight = 1004, type = 1 })                         -- Earth essling
                table.insert(objs, { id = 70458, weight = 1011, type = 0 })                         -- Rock fragment
                if RunecraftingLevel >= 14 then
                    table.insert(npcs, { id = 15407, weight = 1005, type = 1 })                     -- Fire essling
                    table.insert(objs, { id = 70459, weight = 1013, type = 0 })                     -- Fireball
                    if RunecraftingLevel >= 17 then
                        table.insert(objs, { id = 70460, weight = 1014, type = 0 })                 -- Vine
                        if RunecraftingLevel >= 20 then
                            table.insert(npcs, { id = 15408, weight = 1008, type = 1 })                 -- Body esshound
                            table.insert(objs, { id = 70461, weight = 1016, type = 0 })                 -- Fleshy growth
                            if RunecraftingLevel >= 27 then
                                table.insert(npcs, { id = 15409, weight = 1010, type = 1 })             -- Cosmic esshound
                                table.insert(objs, { id = 70462, weight = 1017, type = 0 })             -- Fire storm
                                if RunecraftingLevel >= 35 then
                                    table.insert(npcs, { id = 15410, weight = 1012, type = 1 })         -- Chaos esshound
                                    table.insert(objs, { id = 70463, weight = 1021, type = 0 })         -- Chaotic cloud
                                    if RunecraftingLevel >= 40 then
                                        table.insert(npcs, { id = 15411, weight = 1015, type = 1 })     -- Astral esshound
                                        table.insert(objs, { id = 70464, weight = 1023, type = 0 })     -- Nebula
                                        if RunecraftingLevel >= 44 then
                                            table.insert(npcs, { id = 15412, weight = 1018, type = 1 }) -- Nature esshound
                                            table.insert(objs, { id = 70465, weight = 1024, type = 0 }) -- Shifter
                                        end
                                    end 
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    return { objects = objs, npcs = npcs }
end

local function FindBestTarget()
    local allTargets = IdentifyTargets()
    local targets = {}
    for i, target in pairs(allTargets.objects) do
        local lTarget = API.GetAllObjArrayInteract({ target.id }, 5, 0)
        if lTarget[1] ~= nil then
            local temp = lTarget[1]
            local distance = API.Math_DistanceW(WPOINT.new(temp.TileX / 512, temp.TileY / 512, temp.TileZ / 512), API.PlayerCoord())
            table.insert(targets, { idx = i, name = temp.Name, type = 0, weight = target.weight, distance = distance, id = temp.Id, allObj = temp })
        end
    end
    for j, target2 in pairs(allTargets.npcs) do
        local lTarget = API.GetAllObjArrayInteract({ target2.id }, 5 , 1)
        if lTarget[1] ~= nil then
            local temp = lTarget[1]
            local distance = API.Math_DistanceW(WPOINT.new(temp.TileX / 512, temp.TileY / 512, temp.TileZ / 512), API.PlayerCoord())
            table.insert(targets, { idx = j, name = temp.Name, type = 1, weight = target2.weight, distance = distance, id = temp.Id, allObj = temp })
        end
    end
    table.sort(targets, Compare)
    return targets[1]
end

local function IsCurrentTargetBest(target)
    if CurrentTarget.id == target.id then
        return true
    elseif CurrentTarget.weight <= target.weight then
        return false
    else
        return true
    end
end

local function Runespan()  
    CurrentStage = "Training RC"
    local target = FindBestTarget()
    UTILS.randomSleep(3000) 
    if not target then
        UTILS.randomSleep(500)
        findBestTarget()
        retryCount = retryCount + 1
        if retryCount > 5 then
            API.DoAction_Tile(startPos)
            UTILS.randomSleep(1000)
            API.WaitUntilMovingEnds()
            retryCount = 0
        end
    else
        if CurrentTarget.weight == 0 then
            CurrentTarget = { idx = target.idx, type = target.type, id = target.allObj.Id, weight = target.weight }
        end
        if API.InvItemcount_1(24227) == 0 then
            --No more essence
            API.DoAction_NPC(0x29, API.OFF_ACT_InteractNPC_route, { 15402 }, 50);
            UTILS.randomSleep(600)
            API.WaitUntilMovingEnds()
        elseif not IsCurrentTargetBest(target) then
            print('Switching to better target')
            DoActionTarget(target)
            UTILS.randomSleep(600)
        elseif not API.CheckAnim(80) then
            DoActionTarget(target)
        end
    end


end

local function LeaveRunespan()
    
    API.DoAction_Interface(0xffffffff, 0xffffffff, 1, 1465, 18, -1, API.OFF_ACT_GeneralInterface_route)
    API.RandomSleep2(500, 3050, 12000)

    --Is Edgeville lodestone available?
    API.DoAction_Interface(0xffffffff, 0xffffffff, 1, 1092, 16, -1, API.OFF_ACT_GeneralInterface_route)
    API.RandomSleep2(500, 3050, 12000)

    API.KeyPress_("\32")
    API.RandomSleep2(1000, 1500, 2500)
    API.KeyPress_("\49")

    API.RandomSleep2(3000, 2050, 5000)
    UTILS.waitForAnimation(0, 20)
    API.RandomSleep2(3000, 2050, 5000)

    WriteLog("Arrived at Edgeville lodestone... Walking to bank")

    API.DoAction_WalkerW(WPOINT.new(3093, 3494, 0))
    UTILS.waitForPlayerAtCoords(WPOINT.new(3093, 3494, 0), 0, 30)
    API.WaitUntilMovingEnds()

    InsideRunespan = false
    API.RandomSleep2(3000, 2050, 5000)
end

local function NatureRunner()

    API.DoRandomEvents()

    if(API.Math_DistanceW(API.PlayerCoord(), WPOINT.new(2400, 4843, 1)) < 10) then
        --Click alter
        API.DoAction_Object1(0x3f,0,{ 2486 },50);
        API.RandomSleep2(500, 500, 500)
        API.WaitUntilMovingEnds()
        API.RandomSleep2(2000, 2000, 2000)

        API.DoRandomEvents()

        --Open lode interface
        API.DoAction_Interface(0xffffffff, 0xffffffff, 1, 1465, 18, -1, API.OFF_ACT_GeneralInterface_route)
        API.RandomSleep2(500, 3050, 12000)
    
        --Teleport to edge
        API.DoAction_Interface(0xffffffff, 0xffffffff, 1, 1092, 16, -1, API.OFF_ACT_GeneralInterface_route)
        API.RandomSleep2(500, 500, 500)
        UTILS.waitForAnimation(0, 20)
        API.RandomSleep2(500, 500, 500)
        API.RandomSleep2(500, 3050, 12000)

        --RunesCrafted = RunecraftingLevel + API.InvItemcount_1(561)
    end

    if(API.Math_DistanceW(API.PlayerCoord(), WPOINT.new(3050, 4826, 30)) < 35 and API.IsInCombat_() == true) then
        --Second layer
        API.DoAction_Object1(0x3f,0,{ 7165 },50);
        API.RandomSleep2(500, 500, 500)
        API.WaitUntilMovingEnds()
        API.RandomSleep2(7000, 7000, 7000)
    end

    if(API.Math_DistanceW(API.PlayerCoord(), WPOINT.new(3050, 4826, 30)) < 35 and API.IsInCombat_() == false) then
        print("a")
        --Enter alter
        API.DoAction_Object1(0x3f,0,{ 7133 },50);
        API.RandomSleep2(500, 500, 500)
        API.WaitUntilMovingEnds()
        API.RandomSleep2(500, 500, 500)
    end

    if(API.Math_DistanceW(API.PlayerCoord(), WPOINT.new(3107, 3557, 1)) < 15) then
        --Talk to mage
        API.DoAction_NPC(0x29, API.OFF_ACT_InteractNPC_route, { 2257 }, 50);
        API.RandomSleep2(500, 500, 500)
        API.WaitUntilMovingEnds()
        API.RandomSleep2(500, 500, 500)

        --Teleport to abyss
        API.KeyPress_("\32")
        API.RandomSleep2(500, 500, 500)
        API.KeyPress_("\49")
        API.RandomSleep2(3000, 3000, 3000)

        --Second layer
        API.DoAction_Object1(0x3f,0,{ 7165 },50);
        API.RandomSleep2(500, 500, 500)
        API.WaitUntilMovingEnds()
        API.RandomSleep2(7000, 7000, 7000)

        --Enter alter
        API.DoAction_Object1(0x3f,0,{ 7133 },50);
        API.RandomSleep2(500, 500, 500)
        API.WaitUntilMovingEnds()
        API.RandomSleep2(500, 500, 500)
   end

   if(API.Math_DistanceW(API.PlayerCoord(), WPOINT.new(3099, 3523, 1)) < 1 and API.InvItemcount_1(7936) > 0) then
        print("walking to mage")
        --Walk to mage
        API.DoAction_WalkerW(WPOINT.new(3107, 3557, 0))
        UTILS.waitForPlayerAtCoords(WPOINT.new(3107, 3557, 0), 0, 30)
        API.RandomSleep2(500, 500, 500)
        API.WaitUntilMovingEnds()
        API.RandomSleep2(500, 500, 500)
   end

   if(API.Math_DistanceW(API.PlayerCoord(), WPOINT.new(3099, 3520, 1)) < 1 and API.InvItemcount_1(7936) > 0) then
        --Cross ditch
        API.DoAction_Object1(0x3f,0,{ 65082 },50);
        API.RandomSleep2(2500, 2500, 2500)

        print("walking to mage")
        --Walk to mage
        API.DoAction_WalkerW(WPOINT.new(3107, 3557, 0))
        UTILS.waitForPlayerAtCoords(WPOINT.new(3107, 3557, 0), 0, 30)
        API.RandomSleep2(500, 500, 500)
        API.WaitUntilMovingEnds()
        API.RandomSleep2(500, 500, 500)
    end

    if(API.Math_DistanceW(API.PlayerCoord(), WPOINT.new(3094, 3491, 1)) < 10 and API.InvItemcount_1(7936) > 0) then
        --Walk to ditch
        API.DoAction_WalkerW(WPOINT.new(3099, 3520, 0))
        UTILS.waitForPlayerAtCoords(WPOINT.new(3099, 3520, 0), 0, 30)
        API.RandomSleep2(500, 500, 500)
        API.WaitUntilMovingEnds()
        API.RandomSleep2(500, 500, 500)
    end

    --At bank
    if(API.Math_DistanceW(API.PlayerCoord(), WPOINT.new(3094, 3491, 1)) < 10 and API.InvItemcount_1(7936) == 0) then
        print("opening bank")
        API.DoAction_NPC(0x29, API.OFF_ACT_InteractNPC_route, { 553 }, 50); --Open Bank
        API.RandomSleep2(500, 500, 500)

        --Deposit All
        API.RandomSleep2(500, 500, 500)
        DoAction_Interface(0xffffffff,0xffffffff,1,517,39,-1,5392);
        API.RandomSleep2(500, 500, 500)

        --Withdraw essence
        API.RandomSleep2(500, 500, 500)
        DoAction_Interface(0xffffffff,0x1f00,1,517,195,76,5392);
        API.RandomSleep2(500, 500, 500)

        API.KeyPress_("\27")
        API.RandomSleep2(200, 100, 100)
    end

    --Edge Lodestone
    if(API.Math_DistanceW(API.PlayerCoord(), WPOINT.new(3067, 3505, 1)) < 2) then
        --Walk to bank
        API.RandomSleep2(200, 200, 200)
        API.DoAction_WalkerW(WPOINT.new(3094, 3491, 0))
        UTILS.waitForPlayerAtCoords(WPOINT.new(3094, 3491, 0), 0, 30)
        API.WaitUntilMovingEnds()
        API.RandomSleep2(200, 200, 200)
    end 

end

local function InitGUI()

    IG = API.CreateIG_answer()
    IG.box_start = FFPOINT.new(15, 40, 0)
    IG.box_name = "TASK"
    IG.colour = ImColor.new(255, 255, 255);
    IG.string_value = "Runes Crafted: 0"

    IG3 = API.CreateIG_answer()
    IG3.box_start = FFPOINT.new(20, 5, 0)
    IG3.box_name = "TITLE"
    IG3.colour = ImColor.new(122, 17, 191);
    IG3.string_value = "- procAlterRunner v1.0 -"

    IG4 = API.CreateIG_answer()
    IG4.box_start = FFPOINT.new(80, 65, 0)
    IG4.box_name = "TIME"
    IG4.colour = ImColor.new(255, 255, 255);
    IG4.string_value = "[00:00:00]"

    IG_Back = API.CreateIG_answer();
    IG_Back.box_name = "back";
    IG_Back.box_start = FFPOINT.new(0, 0, 0)
    IG_Back.box_size = FFPOINT.new(220, 80, 0)
    IG_Back.colour = ImColor.new(15, 13, 18, 255)
    IG_Back.string_value = ""

end

local function GUI()
    API.DrawSquareFilled(IG_Back)
    API.DrawTextAt(IG)
    API.DrawTextAt(IG2)
    API.DrawTextAt(IG3)
    API.DrawTextAt(IG4)

    local time = formatElapsedTime(StartTime)
    IG4.string_value = time
    --IG.string_value = "Runes Crafted: " .. RunesCrafted
end

InitGUI()
API.Write_LoopyLoop(true)

while(API.Read_LoopyLoop())
do-----------------------------------------------------------------------------------
    
    GUI()

    if API.GetGameState() == 1 then -- Not Logged in
        Login(accountOne)
    end

    if (API.GetGameState() == 2) then --Lobby
        WriteLog("Detected lobby... logging in")
        API.KeyPress_(" ")
        API.RandomSleep2(200, 200, 200)
    end

    if(API.GetGameState() == 3) then
        LoggedIn = true
        API.DoRandomEvents()

        if(API.Math_DistanceW(coords, WPOINT.new(3103, 3159, 0)) < 1) then
            CurrentStage = "WizardsTowerFirstFloor"
        end

        if(API.Math_DistanceW(coords, WPOINT.new(3103, 3155, 3)) < 1) then
            CurrentStage = "RunespanTopFloor"
        end

        if(API.Math_DistanceW(API.PlayerCoord(), WPOINT.new(3995, 6106, 1)) < 20) then
            CurrentStage = "RunespanFirstFloor"
            InsideRunespan = true
        end 

        if(InsideRunespan == true and API.XPLevelTable(API.GetSkillXP("RUNECRAFTING")) <= 2) then
            Runespan()
        end

        if (API.XPLevelTable(API.GetSkillXP("RUNECRAFTING")) >= 2 and InsideRunespan == true) then
            print("Finished! Leaving runespan")
            LeaveRunespan()
        end

        if(API.XPLevelTable(API.GetSkillXP("RUNECRAFTING")) >= 44) then
            CurrentStage = "Crafting Natures"
            NatureRunner()
        end

    end


    if(API.GetGameState() == 3 and InsideRunespan == false and API.XPLevelTable(API.GetSkillXP("RUNECRAFTING")) < 44) then
        print("Distance to Runespan: " .. API.Math_DistanceW(coords, WPOINT.new(3103, 3159, 0)))
        if(API.Math_DistanceW(coords, WPOINT.new(3103, 3159, 0)) < 10) then
            CurrentStage = "WizardsTowerFirstFloor"
            WizardsTower()
        end
    end

    if(API.GetGameState() == 3 and LoggedIn ~= true) then
        CurrentStage = "Logged in"
        LoggedIn = true
        Staging()
    end


    print(CurrentStage)
    

API.RandomSleep2(500, 3050, 12000)
end----------------------------------------------------------------------------------
