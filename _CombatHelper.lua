os.execute("cls")
local API = require("api")
local player = API.GetLocalPlayerName()
API.Write_ScripCuRunning0("_CombatHelper: " .. player)

local lowHpPercentThreshold = 25
local lowPrayerPercentThreshold = 25;

local enablePrayer = false;

local function FindBuffs(targetId, tolerance)
    local allBuffs = API.Buffbar_GetAllIDs()
  
    for _, buff in ipairs(allBuffs) do
      if buff.id == targetId then
        local buffValue = tonumber(buff.text)

        local toleranceNum = 0

        if type(tolerance) == "string" then
            toleranceNum = tonumber(tolerance:match("%d+"))
        else
            toleranceNum = tolerance
        end


        if(tolerance == 0 and buffValue) then
            return true
        end

        if buffValue and buffValue < toleranceNum then
          return false
        end
  
        if buffValue and buffValue > toleranceNum then
          return true
        end
      end
    end
  
    return false
  end
  
  

local function Main()

    if(API.GetHPrecent() <= lowHpPercentThreshold) then
        print("Eating")
        API.KeyPress_("-")
        API.RandomSleep2(1000, 1000, 1000)
        API.KeyPress_("-")
        API.RandomSleep2(1000, 1000, 1000)
        API.KeyPress_("-")
        API.RandomSleep2(1000, 1000, 1000)
    end

    if(API.IsInCombat_(player)) then

        if(API.GetHPrecent() <= 2) then
            print("EMERGENCY TP")
            API.KeyPress_("]")
            API.RandomSleep2(5000, 5000, 5000)
        end

        if(FindBuffs(25825, 3) == false) then
            print("Drinking Super Strength")
            API.KeyPress_("=")
            API.RandomSleep2(1000, 1000, 1000)
        end

        -- if(FindBuffs(37969, 0) == false) then
        --     print("drinking aggression")
        --     API.KeyPress_(".")
        --     API.RandomSleep2(1000, 1000, 1000)
        -- end

        if(enablePrayer == true) then
            if(FindBuffs(14695, "1m") == false) then
                print("Drinking Prayer Renewal")
                API.KeyPress_(",")
                API.RandomSleep2(1000, 1000, 1000)
            end

            if(API.GetPrayPrecent() <= lowPrayerPercentThreshold) then
                print("Drinking Super Restore")
                API.KeyPress_("[")
                API.RandomSleep2(1000, 1000, 1000)
            end
        end

    end

end


API.Write_LoopyLoop(true)
while(API.Read_LoopyLoop())
do
    if(API.GetGameState2() == 3) then
        API.DoRandomEvents()
        Main()
    end
API.RandomSleep2(500, 3050, 12000)
end