os.execute("cls")
local API = require("api")

local function InitGUI()
    guiBackPlate = API.CreateIG_answer();
    guiBackPlate.box_name = "backplate";
    guiBackPlate.box_start = FFPOINT.new(400, 350, 0)
    guiBackPlate.box_size = FFPOINT.new(800, 100, 0)
    guiBackPlate.colour = ImColor.new(15, 13, 18, 255)
    guiBackPlate.string_value = ""

    title = API.CreateIG_answer()
    title.box_start = FFPOINT.new(525, 107, 0)
    title.box_name = "title"
    title.colour = ImColor.new(255, 255, 255);
    title.string_value = "taonasRunecrafting v1.0"

    sep = API.CreateIG_answer()
    sep.box_start = FFPOINT.new(415, 125, 0)
    sep.box_name = "sep"
    sep.colour = ImColor.new(255, 255, 255);
    sep.string_value = "-----------------------------------------------------"
end

local function DrawGUI()
    API.DrawSquareFilled(guiBackPlate)
    API.DrawTextAt(title)
    API.DrawTextAt(sep)
end

local function AirRune()

    local player = API.GetLocalPlayerName()

    if(API.InvItemcount_1(1436) == 0) then
        print("No rune ess.. deciding path bank")

        --In the bank area, load preset
        if(API.PInAreaW(WPOINT.new(3182,3436,0), 10) and API.IsPlayerMoving_(player) == false) then
            print("In bank area")
            API.DoAction_Object1(0x33,240,{ 782 },50)
        end

            --outside the alter, run to bank
            if(API.Math_DistanceW(API.PlayerCoord(), WPOINT.new(3128, 3407, 0)) < 10 and API.IsPlayerMoving_(player) == false) then
                print("Moving to bank")
                API.DoAction_WalkerW(WPOINT.new(3182,3436,0))
            end
        --in the alter, leave
        if(API.PInAreaW(WPOINT.new(2843,4832,0), 5) and API.IsPlayerMoving_(player) == false) then
            print("In alter")
            API.DoAction_Object1(0x39,0,{ 2465 },50)
        end
    end

    if(API.InvItemcount_1(1436) > 0) then

        print("got rune ess.. deciding path to alter")
        --at bank, run to alter
        if(API.PInAreaW(WPOINT.new(3182,3436,0), 10) and API.IsPlayerMoving_(player) == false) then
            print("In bank area, moving to alter")
            API.DoAction_WalkerW(WPOINT.new(3128, 3407, 0))
        end

        --outside the alter, enter alter
        if(API.Math_DistanceW(API.PlayerCoord(), WPOINT.new(3128, 3407, 0)) < 10 and API.IsPlayerMoving_(player) == false) then
            print("outside the alter, entering alter")
            API.DoAction_Object1(0x39,0,{ 2452 },50)
        end

        --in the alter, craft runes
        if(API.PInAreaW(WPOINT.new(2843,4832,0), 5) and API.IsPlayerMoving_(player) == false) then
            print("In alter, crafting")
            API.DoAction_Object1(0x42,0,{ 2478 },50)
        end

    end

end

local function MindRunes()
    local player = API.GetLocalPlayerName()

    if(API.InvItemcount_1(1436) == 0) then
        print("No rune ess.. deciding path bank")

        --In the bank area, load preset
        if(API.PInAreaW(WPOINT.new(2875,3416,0), 10) and API.IsPlayerMoving_(player) == false) then
            print("In bank area")
            API.DoAction_Object1(0x33,240,{ 66665 },50)
        end
        
        --in the alter, leave
        if(API.PInAreaW(WPOINT.new(2787,4839,0), 5) and API.IsPlayerMoving_(player) == false) then
            print("In alter")
            API.KeyPress_("1")
            API.RandomSleep2(7500,500,500)
        end

        --at lode, move to bank
        if(API.PInAreaW(WPOINT.new(2878,3442,0), 5) and API.IsPlayerMoving_(player) == false) then
            print("Moving to bank")
            API.DoAction_WalkerW(WPOINT.new(2875,3416,0))
        end
    end

    if(API.InvItemcount_1(1436) > 0) then

        print("got rune ess.. deciding path to alter")
        --at bank, run to alter
        if(API.PInAreaW(WPOINT.new(2875,3416,0), 10) and API.IsPlayerMoving_(player) == false) then
            print("In bank area, moving to alter")
             --tele to fally
            API.KeyPress_("2")
            API.RandomSleep2(7500,500,500)
        end

        --at lode, moving to alter
        if(API.PInAreaW(WPOINT.new(2967,3403,0), 5) and API.IsPlayerMoving_(player) == false) then
            print("moving to alter")
            API.DoAction_WalkerW(WPOINT.new(2980,3512,0))
        end

        --outside the alter, enter alter
        if(API.PInAreaW(WPOINT.new(2980, 3512, 0), 10) and API.IsPlayerMoving_(player) == false) then
            print("outside the alter, entering alter")
            API.DoAction_Object1(0x39,0,{ 2453 },50)
        end

        --in the alter, craft runes
        if(API.PInAreaW(WPOINT.new(2793,4832,0), 10) and API.IsPlayerMoving_(player) == false) then
            print("In alter, crafting")
            API.DoAction_Object1(0x42,0,{ 2479 },50)
        end

    end
end

API.Write_LoopyLoop(true)
while(API.Read_LoopyLoop())
do
    
    if (API.GetGameState2() == 2) then
        API.KeyPress_(" ")
        API.RandomSleep2(200, 200, 200)
    end

    if(API.GetGameState2() == 3) then
        API.DoRandomEvents()
        MindRunes()
    end

API.RandomSleep2(500, 3050, 12000)
end