local API = require("api")

local UTILS = require("utils")
local startTime = os.time()

local SURGE_KEY_CODE = 50
local LODESTONES = require("lodestones")
local running = true

last_obstacle_id = -1

function random(min, max)
    if min == max then
        return min
    elseif min < max then
        return min + API.Math_RandomNumber3(max - min)
    else
        return max + API.Math_RandomNumber3(min - max)
    end
end

function sleep(min_millis, max_millis)
    if not max_millis then
        API.RandomSleep2(min_millis)
    else
        API.RandomSleep2(random(min_millis, max_millis))
    end
end

function anti_idle()
    if (random(1, 100) <= 3) then
        if (random(1, 100) <= 50) then
            API.PIdle1()
        else
            if last_obstacle_id ~= -1 then
                local next_obstacle = API.GetAllObjArray1({last_obstacle_id + 1}, 50, 0)[1]

                if next_obstacle ~= nil then
                    API.RotateCamera(next_obstacle.Tile_XYZ, API.PlayerCoordfloat(), 5)
                end
            end
        end
    end
end

function run_to_tile(x, y, z)
    local tile = WPOINT.new(x, y, z)

    API.DoAction_Tile(tile)
    local waitTime = 40
    local start = os.time()
    while API.Read_LoopyLoop() and API.Math_DistanceW(API.PlayerCoord(), tile) > 5 do
        sleep(100, 200)

        anti_idle()
        if (os.time() - start >= waitTime) then
            LODESTONES.Anachronia()
            return false
        end
    end
    --API.DoAction_NPC(0x29,3120,{ 23855 },50)
    return true
end

function run_to_tile2(x, y, z)
    local tile = WPOINT.new(x, y, z)

    API.DoAction_Tile(tile)
    local waitTime = 40
    local start = os.time()
    while API.Read_LoopyLoop() and API.Math_DistanceW(API.PlayerCoord(), tile) > 3 do
        sleep(30, 50)

        anti_idle()
        if (os.time() - start >= waitTime) then
            LODESTONES.Anachronia()
            return false
        end
    end
    --API.DoAction_NPC(0x29,3120,{ 23855 },50)
    return true
end

function runToTile(x,y,z)
    local tile = WPOINT.new(x, y, z)
    API.DoAction_Tile(tile)
    local waitTime = 40
    local start = os.time()
    while API.Read_LoopyLoop() and API.Math_DistanceW(API.PlayerCoord(), tile) > 3 do
        sleep(100, 200)

        anti_idle()
        if (os.time() - start >= waitTime) then
            LODESTONES.Anachronia()
            return false
        end
    end
    --API.DoAction_NPC(0x29,3120,{ 23855 },50)
    return true
end

function isAtCoord(x,y,z)
    local tile = WPOINT.new(x, y, z)
    local waitTime = 20
    local start = os.time()
    while API.Read_LoopyLoop() and API.Math_DistanceW(API.PlayerCoord(), tile) > 0 do
        sleep(10, 40)

        --anti_idle()
        if (os.time() - start >= waitTime) then
            LODESTONES.Anachronia()
            return false
        end
    end
    
    
    return true
end

function interact_with_obstacle(id,x,y)
    --API.DoRandomEvents()
    --API.DoAction_NPC(0x29,3120,{ 23855 },50)
    
    API.DoAction_Object1(0xb5, 0, {id}, 50)
    last_obstacle_id = id
    API.DoRandomEvents()
    API.DoAction_NPC(0x29,3120,{ 23855 },50)
    
    if isAtCoord(x,y,0) then
        if UTILS.waitForAnimation(0, 5) then
            
            return true
        end
        --LODESTONES.Anachronia()
        return false
    end
   -- LODESTONES.Anachronia()
    return false
end

function checkGameState()
    local gameState = API.GetGameState()
    if (gameState ~= 3) then
        print('Not ingame with state:', gameState)
        API.Write_LoopyLoop(false)
        return false 
    else
        --LODESTONES.Anachronia()
        return false
    end
end



function interact_with_cave()
    --API.DoRandomEvents()
    --API.DoAction_NPC(0x29,3120,{ 23855 },50)
    
    API.DoAction_Object1(0xb5, 0, {113734}, 50)

    last_obstacle_id = 113734

    while API.Read_LoopyLoop() and API.GetAllObjArray1({113735}, 50, 0)[1] == nil do
        sleep(100, 200)

        anti_idle()
    end

    sleep(2000)
    --API.DoRandomEvents()
    --API.DoAction_NPC(0x29,3120,{ 23855 },50)
end

function activate_surge()
    API.KeyboardPress31(SURGE_KEY_CODE, random(100, 200), 0)
    sleep(30, 45)

    

end

function activate_dive(x, y, z)
    local tile = WPOINT.new(x, y, z)
    API.DoAction_Dive_Tile(tile)

    sleep(30, 45)

    
end

function activate_diveSurge(x, y, z)
    local tile = WPOINT.new(x, y, z)
    API.DoAction_Dive_Tile(tile)
    API.KeyboardPress31(SURGE_KEY_CODE, random(100, 200), 0)
    sleep(20, 35)

    
end


while API.Read_LoopyLoop() do
    ::startOfLoop::
    
    if not run_to_tile(5417, 2324, 0) then
        goto startOfLoop
    end
    
    if not interact_with_obstacle(113687, 5414, 2324) then
        goto startOfLoop
    end
    --break 
    
    if not interact_with_obstacle(113688, 5410, 2325) then
        goto startOfLoop
    end
    if not interact_with_obstacle(113689, 5408, 2323) then
        goto startOfLoop
    end
    activate_dive(5401, 2320, 0)

    if not interact_with_obstacle(113690, 5393, 2320) then
        goto startOfLoop
    end
    --break
    
   
    if not runToTile(5386, 2317, 0) then
        goto startOfLoop
    end
    activate_surge()
    if not interact_with_obstacle(113691, 5367, 2304) then
        goto startOfLoop
    end
    --break

    activate_dive(5356, 2291, 0)
    local tile = WPOINT.new(5360, 2283, 0)
    API.DoAction_Tile(tile)
    sleep(500, 650)
    activate_surge()

    

    if not interact_with_obstacle(113692, 5369, 2282) then
        goto startOfLoop
    end
     
    --break 
    --run_to_tile(5376, 2274, 0)


    if not run_to_tile(5376, 2274, 0) then
        goto startOfLoop
    end
    
    activate_surge()
    activate_dive(5376, 2255, 0)
    --activate_surge()

    
    if not interact_with_obstacle(113693, 5376, 2247) then
        goto startOfLoop
    end
    --break

    if not interact_with_obstacle(113694, 5397, 2240) then
        goto startOfLoop
    end
    if not runToTile(5418, 2230, 0) then
        goto startOfLoop
    end
    activate_surge()
    if not interact_with_obstacle(113695, 5439, 2217) then
        goto startOfLoop
    end

    activate_dive(5456, 2197, 0)
    activate_surge()

    if not interact_with_obstacle(113696, 5456, 2179) then
        goto startOfLoop
    end
    activate_dive(5463, 2171, 0)
    API.DoAction_Object1(0xb5, 0, {113697}, 50)
    sleep(500, 650)
    activate_surge()
    if not interact_with_obstacle(113697, 5475, 2171) then
        goto startOfLoop 
    end
    --break
    activate_surge()
    if not interact_with_obstacle(113698, 5489, 2171) then
        goto startOfLoop
    end
    if not interact_with_obstacle(113699, 5502, 2171) then
        goto startOfLoop
    end
    activate_dive(5510, 2178,0)
    API.DoAction_Object1(0xb5, 0, {113700}, 50)
    sleep(700, 850)
    activate_surge()
    if not interact_with_obstacle(113700, 5527, 2182) then
        goto startOfLoop
    end
    if not runToTile(5533, 2186, 0) then
        goto startOfLoop
    end
    activate_surge()
    sleep(200, 350)
    activate_dive(5548, 2206, 0)
    
    if not interact_with_obstacle(113701, 5548, 2220) then
        goto startOfLoop
    end
    
    activate_surge()
    if not interact_with_obstacle(113702, 5548, 2244) then
        goto startOfLoop
    end
    if not interact_with_obstacle(113703, 5553, 2249) then
        goto startOfLoop
    end
    activate_surge()
    sleep(300, 500)
    activate_dive(5562, 2269, 0)
    if not interact_with_obstacle(113704, 5565, 2272) then
        goto startOfLoop
    end
    if not runToTile(5567, 2277, 0) then
        goto startOfLoop
    end
    activate_surge()
    --sleep(200, 350)
    --activate_dive(5575, 2289, 0)
    if not interact_with_obstacle(113705, 5578, 2289) then
        goto startOfLoop
    end
    activate_dive(5579, 2295, 0)
    if not interact_with_obstacle(113706, 5587, 2295) then
        goto startOfLoop
    end
    if not interact_with_obstacle(113707, 5596, 2295) then
        goto startOfLoop
    end
    activate_surge()
    sleep(200, 350)
    activate_dive(5615, 2286, 0)
    if not interact_with_obstacle(113708, 5629, 2287) then
        goto startOfLoop
    end
    --activate_dive(5656, 2287, 0)
    activate_surge()
    API.DoAction_Object1(0xb5, 0, {113709}, 50)
    sleep(3000, 3100)
    activate_dive(5659, 2288, 0)
    if not interact_with_obstacle(113709, 5669, 2288) then
        goto startOfLoop
    end
    if not interact_with_obstacle(113710, 5680, 2290) then
        goto startOfLoop
    end
    if not interact_with_obstacle(113711, 5684, 2293) then
        goto startOfLoop
    end
    if not interact_with_obstacle(113712, 5686, 2310) then
        goto startOfLoop
    end
    activate_dive(5692, 2317, 0)
    if not interact_with_obstacle(113713, 5695, 2317) then
        goto startOfLoop
    end
    if not runToTile(5699, 2322, 0) then
        goto startOfLoop
    end
    activate_surge()
    if not interact_with_obstacle(113714, 5696, 2346) then
        goto startOfLoop
    end
    if not runToTile(5696, 2353, 0) then
        goto startOfLoop
    end
    activate_dive(5681, 2363, 0)
    if not interact_with_obstacle(113715, 5675, 2363) then
        goto startOfLoop
    end
    activate_surge()
    if not interact_with_obstacle(113716, 5655, 2377) then
        goto startOfLoop
    end
    activate_dive(5645, 2392, 0)
    API.DoAction_Object1(0xb5, 0, {113717}, 50)
    sleep(1150,1200)
    activate_surge()
    if not interact_with_obstacle(113717, 5653, 2405) then
        goto startOfLoop
    end
    activate_surge()
    if not interact_with_obstacle(113718, 5643, 2420) then
        goto startOfLoop
    end
    if not interact_with_obstacle(113719, 5642, 2431) then
        goto startOfLoop
    end
    API.DoAction_Object1(0xb5, 0, {113720}, 50)
    sleep(500, 700)
    activate_dive(5629, 2433, 0)
    if not interact_with_obstacle(113720, 5626, 2433) then
        goto startOfLoop
    end
    activate_surge()
    if not interact_with_obstacle(113721, 5616, 2433) then
        goto startOfLoop
    end
    if not interact_with_obstacle(113722, 5608, 2433) then
        goto startOfLoop
    end
    activate_surge()
    if not interact_with_obstacle(113723, 5601, 2433) then
        goto startOfLoop
    end
    activate_dive(5591, 2446, 0)
    if not interact_with_obstacle(113724, 5591, 2450) then
        goto startOfLoop
    end
    if not interact_with_obstacle(113725, 5584, 2452) then
        goto startOfLoop
    end
    if not interact_with_obstacle(113726, 5574, 2453) then
        goto startOfLoop
    end
    
    if not interact_with_obstacle(113727, 5564, 2452) then
        goto startOfLoop
    end
    if not run_to_tile(5563, 2457, 0) then
        goto startOfLoop
    end
    activate_surge()
    if not run_to_tile(5559, 2477, 0) then
        goto startOfLoop
    end
    activate_surge()
    
    activate_dive(5548, 2492, 0)
    if not interact_with_obstacle(113728, 5536, 2492) then
        goto startOfLoop
    end
    if not interact_with_obstacle(113729, 5528, 2492) then
        goto startOfLoop
    end
    activate_surge()
    --sleep(50, 70)
    API.DoAction_Object1(0xb5, 0, {113730}, 50)
    sleep(500, 650)
    activate_dive(5506, 2481, 0)
    if not interact_with_obstacle(113730, 5505, 2478) then
        goto startOfLoop
    end
    if not interact_with_obstacle(113731, 5505, 2468) then
        goto startOfLoop
    end
    if not interact_with_obstacle(113732, 5505, 2462) then
        goto startOfLoop
    end
    if not runToTile(5501, 2459, 0) then
        goto startOfLoop
    end
    activate_dive(5491, 2456, 0)
    if not interact_with_obstacle(113733, 5484, 2456) then
        goto startOfLoop
    end
    interact_with_cave()
    
    activate_surge()
    if not interact_with_obstacle(113735, 5431, 2407) then
        goto startOfLoop
    end
    activate_dive(5425, 2404, 0)
    if not interact_with_obstacle(113736, 5425, 2397) then
        goto startOfLoop
    end
    activate_surge()
    if not interact_with_obstacle(113737, 5426, 2387) then
        goto startOfLoop
    end
    if not interact_with_obstacle(113738, 5428, 2383) then
        goto startOfLoop
    end
    activate_surge()
    
    --API.DoAction_Tile(tile)
    
    
    

end

print("I'm here now")