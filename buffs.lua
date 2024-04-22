os.execute("cls")
local API = require("api")
local player = API.GetLocalPlayerName()
API.Write_ScripCuRunning0("buffs: " .. player)

local seenBuffs = {}

-- Function to print buff details
local function printBuffDetails(buff)
    print("ID:", buff.id, "Found:", tostring(buff.found), "Text:", buff.text, "Converted Text:", buff.conv_text)
end

-- Main Loop
while (API.Read_LoopyLoop()) do
    -- Retrieve all current buffs
    local allBuffs = API.Buffbar_GetAllIDs()

    -- Iterate through all buffs
    for _, buff in ipairs(allBuffs) do
        -- Check if the buff is already seen
        if not seenBuffs[buff.id] then
            -- New buff found, print details and store it
            printBuffDetails(buff)
            seenBuffs[buff.id] = true
        end
    end

    -- Random sleep to mimic game tick or reduce CPU usage
    MYUTILS.RandomSleepRange(500, 1000)
end