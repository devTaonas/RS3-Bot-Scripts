print("Run Lua script procAbyssNatureRunes.")

local API = require("api")
local UTILS = require("utils")

local USERNAME_BOX_VARBIT_STR = "00000000000000000000000001100100"
local PASSWORD_BOX_VARBIT_STR = "00000000000000000000000001100101"
local INVALID_BOX_VARBIT_STR = "00000000000000000000000001100110"
local CURSOR_LOCATION_VARBIT_ID = 174
local BACKSPACE_KEY = 8
local USERNAME = false
local PASSWORD = false


local function WriteLog(inputLog)
    local time = os.date('%Y-%m-%d %H:%M:%S')

    print(time .. ": " .. inputLog)
end

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

local function Startup() 
    if API.GetGameState() == 1 then -- Not Logged in
        Login("")
    end

    if (API.GetGameState() == 2) then --Lobby
        WriteLog("Detected lobby... logging in")
        API.KeyPress_(" ")
        API.RandomSleep2(200, 200, 200)
    end
end

local function NatureRunes() 

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

    if(API.Math_DistanceW(API.PlayerCoord(), WPOINT.new(3050, 4826, 30)) < 35 and API.LocalPlayer_IsInCombat_() == false) then
        --Enter alter
        API.DoAction_Object1(0x3f,0,{ 7133 },50);
        API.RandomSleep2(500, 500, 500)
        API.WaitUntilMovingEnds()
        API.RandomSleep2(500, 500, 500)
    end

    local hp = API.GetHPrecent()

    if(API.LocalPlayer_IsInCombat_() and hp <= 30) then
        --Panic TP
        API.RandomSleep2(500, 500, 500)
        API.DoAction_Interface(0xffffffff,0x6ae,2,1464,15,2,5392)
        API.RandomSleep2(1500, 1500, 1500)
    end

    if(API.LocalPlayer_IsInCombat_() and API.Math_DistanceW(API.PlayerCoord(), WPOINT.new(3050, 4826, 30)) < 50) then
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
   end

    if(API.Math_DistanceW(API.PlayerCoord(), WPOINT.new(3099, 3523, 1)) < 1 and API.InvItemcount_1(7936) > 0) then
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
    end

    if(API.Math_DistanceW(API.PlayerCoord(), WPOINT.new(3094, 3491, 1)) < 10 and API.InvItemcount_1(7936) > 0) then
        --Walk to ditch
        API.DoAction_WalkerW(WPOINT.new(3099, 3520, 0))
        UTILS.waitForPlayerAtCoords(WPOINT.new(3099, 3520, 0), 0, 30)
        API.RandomSleep2(500, 500, 500)
        API.WaitUntilMovingEnds()
        API.RandomSleep2(500, 500, 500)
    end

    if(API.Math_DistanceW(API.PlayerCoord(), WPOINT.new(3094, 3491, 1)) < 10 and API.InvItemcount_1(7936) == 0) then
        API.DoAction_NPC(0x29, API.OFF_ACT_InteractNPC_route, { 553 }, 50); --Open Bank
        API.RandomSleep2(700, 1000, 1000)

        --Deposit All
        API.RandomSleep2(1000, 1000, 1000)
        API.DoAction_Interface(0xffffffff,0xffffffff,1,517,39,-1,5392);

        --Withdraw essence
        API.RandomSleep2(1000, 1000, 1500)
        API.DoAction_Interface(0xffffffff,0x1f00,1,517,195,75,5392);

        --Leave bank interface
        API.RandomSleep2(500, 500, 500)
        API.KeyPress_("\27")
        API.RandomSleep2(200, 100, 100)
    end

    --Edge lodestone
    if(API.Math_DistanceW(API.PlayerCoord(), WPOINT.new(3067, 3505, 1)) < 2) then
        API.RandomSleep2(200, 200, 200)
        API.DoAction_WalkerW(WPOINT.new(3094, 3491, 0))
        UTILS.waitForPlayerAtCoords(WPOINT.new(3094, 3491, 0), 0, 30)
        API.WaitUntilMovingEnds()
        API.RandomSleep2(200, 200, 200)
    end 

end

--Exported function list is in API
--main loop
API.Write_LoopyLoop(true)
while(API.Read_LoopyLoop())
do-----------------------------------------------------------------------------------

    if(API.GetGameState() ~= 3) then
        Startup()
    else
        API.RandomEvents()
        NatureRunes()
    end

API.RandomSleep2(500, 3050, 12000)
end----------------------------------------------------------------------------------
