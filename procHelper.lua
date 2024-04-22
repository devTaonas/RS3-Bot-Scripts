local Helper = {}

local API = require("api")
local UTILS = require("utils")

local USERNAME_BOX_VARBIT_STR = "00000000000000000000000001100100"
local PASSWORD_BOX_VARBIT_STR = "00000000000000000000000001100101"
local INVALID_BOX_VARBIT_STR = "00000000000000000000000001100110"
local CURSOR_LOCATION_VARBIT_ID = 174
local BACKSPACE_KEY = 8
local USERNAME = false
local PASSWORD = false

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

function Helper.Login(userPass)
    if(api.GetGameState() == 1) then
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

function Helper.Lobby_Enter()
    if (API.GetGameState() == 2) then --Lobby
        WriteLog("Chracter in lobby, entering game...")
        API.KeyPress_(" ")
        API.RandomSleep2(200, 200, 200)
    end
end

function Helper.Lobby_Hop()

end