local API = require("api")
local UTILS = require("utils")
local procLib = {}

local USERNAME_BOX_VARBIT_STR = "00000000000000000000000001100100"
local PASSWORD_BOX_VARBIT_STR = "00000000000000000000000001100101"
local INVALID_BOX_VARBIT_STR = "00000000000000000000000001100110"
local CURSOR_LOCATION_VARBIT_ID = 174
local BACKSPACE_KEY = 8
local USERNAME = false
local PASSWORD = false

local startTime = os.time()
local idleTimeThreshold = math.random(120, 260)

local specialChars = {
    ["!"] = true, ["@"] = true, ["#"] = true, ["$"] = true, ["%"] = true, ["^"] = true,
    ["&"] = true, ["*"] = true, ["("] = true, [")"] = true, ["_"] = true, ["-"] = true,
    ["+"] = true, ["="] = true, ["{"] = true, ["}"] = true, ["["] = true, ["]"] = true,
    ["|"] = true, ["\\"] = true, [":"] = true, [";"] = true, ['"'] = true, ["'"] = true,
    ["<"] = true, [">"] = true, [","] = true, ["."] = true, ["/"] = true, ["?"] = true, ["~"] = true
}

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

function procLib.FormatElapsedTime(startTime)
    local currentTime = os.time()
    local elapsedTime = currentTime - startTime
    local hours = math.floor(elapsedTime / 3600)
    local minutes = math.floor((elapsedTime % 3600) / 60)
    local seconds = elapsedTime % 60
    return string.format("[%02d:%02d:%02d]", hours, minutes, seconds)
end

local function IsEmpty(s)
    return s == nil or s == ''
  end

function procLib.RoundNumber(val, decimal)
    if decimal then
        return math.floor((val * 10 ^ decimal) + 0.5) / (10 ^ decimal)
    else
        return math.floor(val + 0.5)
    end
end

function procLib.FormatNumber(num)
    if num >= 1e6 then
        return string.format("%.1fM", num / 1e6)
    elseif num >= 1e3 then
        return string.format("%.1fK", num / 1e3)
    else
        return tostring(num)
    end
end

function procLib.ProgressBarPercentage(skill, currentExp)
    local currentLevel = API.XPLevelTable(API.GetSkillXP(skill))
    if currentLevel == 120 then return 100 end
    local nextLevelExp = XPForLevel(currentLevel + 1)
    local currentLevelExp = XPForLevel(currentLevel)
    local progressPercentage = (currentExp - currentLevelExp) / (nextLevelExp - currentLevelExp) * 100
    return math.floor(progressPercentage)
end

local startTime = os.time()
local startTimeAFK = os.time()
local fishingStartXP = API.GetSkillXP("FISHING")

function procLib.InitFishingGUI()

    guiBackPlate = API.CreateIG_answer();
    guiBackPlate.box_name = "back";
    guiBackPlate.box_start = FFPOINT.new(0, 0, 0)
    guiBackPlate.box_size = FFPOINT.new(530, 45, 0)
    guiBackPlate.colour = ImColor.new(15, 13, 18, 255)
    guiBackPlate.string_value = ""
     
    progressBar = API.CreateIG_answer()
    progressBar.box_start = FFPOINT.new(120, 4, 0)
    progressBar.box_name = "ProgressBar"
    progressBar.colour = ImColor.new(15, 82, 186);
    progressBar.string_value = "Fishing XP"

    starting = API.InvStackSize(1762)
end

function procLib.DrawFishingGUI()

    API.DrawSquareFilled(guiBackPlate)

    local skill = "FISHING"
    local currentXp = API.GetSkillXP(skill)
    local elapsedMinutes = (os.time() - startTime) / 60
    local diffXp = math.abs(currentXp - fishingStartXP);
    local xpPH = RoundNumber((diffXp * 60) / elapsedMinutes);
    local time = FormatElapsedTime(startTime)
    local currentLevel = API.XPLevelTable(API.GetSkillXP(skill))
    progressBar.radius = ProgressBarPercentage(skill, API.GetSkillXP(skill)) / 100
    progressBar.string_value = time .. " | " .. string.lower(skill):gsub("^%l", string.upper) .. ": " .. currentLevel .. " | XP/H: " .. FormatNumber(xpPH) .. " | Gathered: 0"
    API.DrawProgressBar(progressBar)
end

function procLib.WriteLog(inputLog)
    local time = os.date('%Y-%m-%d %H:%M:%S')
    print(time .. ": " .. inputLog)
end

function procLib.Login(userPass)

    if(API.GetGameState() == 1 and IsEmpty(userPass) == false) then
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
end

function procLib.Lobby()
    if(API.GetGameState() == 2) then
        procLib.WriteLog("Lobby detected, logging in")
        API.KeyPress_(" ")
        API.RandomSleep2(200, 200, 200)
    end
end

function procLib.FindBankItemID(itemName) 
    
    local bankData = API.FetchBankArray()
    local item = 0

    for i, v in ipairs(bankData) do
     if not API.Read_LoopyLoop() then break end
        if v.textitem and not string.find(v.textitem, "Empty slot") then
            if(string.find(v.textitem, itemName)) then
                WriteLog("Found " .. itemName .. " with ID " .. v.itemid1 .. " in bank")
                item = v.itemid1
            end
        end
    end

    return item
end

function procLib.AntiAFK() 
    if(API.GetGameState() == 3) then
        local currentTime = os.time()
        local elapsedTime = os.difftime(currentTime, startTimeAFK)
    
        if elapsedTime >= idleTimeThreshold then
            API.PIdle2()
            startTimeAFK = os.time()
            idleTimeThreshold = math.random(200, 280)
            print("Reset Timer & Threshhold")
        end
    end
end

function procLib.FindEntity(type, entityName)
    local allNPCS = API.ReadAllObjectsArray(false, type)
    local entity = {}
    if #allNPCS > 0 then
        for _, a in pairs(allNPCS) do
            if(a.Id > 0) then
                local distance = API.Math_DistanceF(a.Tile_XYZ, API.PlayerCoordfloat())
            a.Distance = distance;
            if a.Id ~= 0 and distance < 50 then
                --print(a.Name .. " : " .. a.Id)
                if a.Name == entityName then
                    print(a.Name .. " : " .. a.Id)
                    table.insert(entity, a.Id)
                end
            end
            end
            
        end
        
        return { npcs = entity }
    end
end

function procLib.FindEntityLikeID(type, entityIDLike)
    local allNPCS2 = API.ReadAllObjectsArray(false, type)
    local entity2 = {}
    if #allNPCS2 > 0 then
        for _, a in pairs(allNPCS2) do
            if(a.Id > 0) then
                local distance = API.Math_DistanceF(a.Tile_XYZ, API.PlayerCoordfloat())
                a.Distance = distance;
                if a.Id ~= 0 and distance < 10 then
                    if a.ID > entityIDLike and a.Id <= entityIDLike + 10 then
                        table.insert(entity2, a.Id)
                    end
                end
            end
        end
        
        return { npcs = entity2 }
    end
end

function procLib.WebWalker(x, y, z)
    API.DoAction_WalkerW(WPOINT.new(x, y, z))
    UTILS.waitForPlayerAtCoords(WPOINT.new(x, y, z), 0, 60)
    API.RandomSleep2(500, 500, 500)
    API.WaitUntilMovingEnds()
    API.RandomSleep2(500, 500, 500)
end

function procLib.Lodestone(dest)
    API.DoAction_Interface(0xffffffff, 0xffffffff, 1, 1465, 18, -1, API.OFF_ACT_GeneralInterface_route)
    API.RandomSleep2(500, 3050, 12000)
    API.DoAction_Interface(0xffffffff, 0xffffffff, 1, 1092, dest, -1, API.OFF_ACT_GeneralInterface_route)
    API.RandomSleep2(500, 500, 500)
    UTILS.waitForAnimation(0, 20)
    API.RandomSleep2(500, 500, 500)
end

function procLib.IncenseSticks()
    if (API.InvItemcount_1(53093) > 0) then
        if (not API.Buffbar_GetIDstatus(47715,false).found) then
            API.DoAction_Interface(0x41,0xba63,2,1473,5,24,5392)
            print("Buff not found")
        end
    
        buffOverloadValue = API.Buffbar_GetIDstatus(47715, false).text
        buffOverloadValue = buffOverloadValue:sub(1, -2)
    
        if(buffOverloadValue:match("1$")) then
            print(API.Buffbar_GetIDstatus(47715, false).text)
            API.DoAction_Interface(0x41,0xba63,2,1473,5,24,5392)
            print("Buff not overloaded")
        end
    
        if(API.Buffbar_GetIDstatus(47715, false).conv_text < 5 and string.find(API.Buffbar_GetIDstatus(47715, false).text,"(4)")) then
            API.DoAction_Interface(0x41,0xba63,1,1473,5,24,5392)
            API.RandomSleep2(500, 1500, 1500)
            API.DoAction_Interface(0x41,0xba63,1,1473,5,24,5392)
            API.RandomSleep2(500, 1500, 1500)
            API.DoAction_Interface(0x41,0xba63,1,1473,5,24,5392)
            API.RandomSleep2(500, 1500, 1500)
            API.DoAction_Interface(0x41,0xba63,1,1473,5,24,5392)
            API.RandomSleep2(500, 1500, 1500)
            API.DoAction_Interface(0x41,0xba63,1,1473,5,24,5392)
        end
    end
end

return procLib