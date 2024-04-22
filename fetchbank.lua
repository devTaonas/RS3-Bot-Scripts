os.execute("cls")
local API = require("api")
local player = API.GetLocalPlayerName()
API.Write_ScripCuRunning0("buffs: " .. player)

local seenBuffs = {}

local function remove_after_space_and_number(text)
    local space_one_pos = string.find(text, " 1")
    if space_one_pos then
      return string.sub(text, 1, space_one_pos - 1)
    else
      return text
    end
end

local function ScanBank()
  local bankItems = API.FetchBankArray()
  local processedItems = {}

  for key, value in pairs(bankItems) do
    if value.itemid1 ~= 48447 then
      local cleanedText = remove_after_space_and_number(string.gsub(value.textitem, "<([^>]+)>", ""))
      local itemData = {
        cleanedText = cleanedText,
        size = value.itemid1_size,
        slotId = key - 1
      }
     
      table.insert(processedItems, itemData)
    end
  end

  return processedItems
end

local lastItemScan = {}

local function CheckBankItemExists(targetName)
  local items = ScanBank()  -- Get the list of itemData tables
  lastItemScan = items

  -- Iterate through each itemData table
  for _, itemData in ipairs(items) do
    if itemData.cleanedText == targetName then  -- Compare cleanedText with targetName
      -- Access and store slotId
      local foundSlotId = itemData.slotId
      
      print("found", targetName, "at slot", foundSlotId)  -- Print slotId for reference
      return true, foundSlotId  -- Return both true and slotId
    end
  end

  return false, nil  -- No match found, return false and nil
end

-- Main Loop
while (API.Read_LoopyLoop()) do

    --ScanBank()
    if(API.InvItemcount_1(29285) > 0 and API.InvFull_()) then
      print("Inventory full, using porters...")
      API.DoAction_Interface(0xffffffff,0xae06,6,1464,15,2,4608)
      API.RandomSleep2(4500,500,500)
  end

  --if no porters, teleport to bank
  if(API.InvItemcount_1(29285) == 0 and API.InvFull_()) then
      print("Inventory full, getting porters")
      API.DoAction_Interface(0xffffffff,0xc315,3,1464,15,0,3808)
      API.RandomSleep2(4500,500,500)
  end

  --if at bank withdraw and use porters
  if(API.PInAreaW(WPOINT.new(2409,2824,0), 10) and not API.IsPlayerAnimating_(player, 5) and not API.IsPlayerMoving_(player)) then
      print("At bank area, checking for porters")
      API.DoAction_Object1(0x2e,80,{ 115427 },50)
      API.RandomSleep2(1500,500,500)

      while(API.IsPlayerMoving_(player)) do
          print("Player is moving")
          API.RandomSleep2(1000,500,500)
      end

      if(API.Compare2874Status(24, false)) then
          print("Bank is open, depositing all")
          API.DoAction_Interface(0xffffffff,0xffffffff,1,517,39,-1,3808)
          local found, slotId = CheckBankItemExists("Sign of the porter VI")
          if found then
            print("found porters, withdrawing from slot", slotId)
            API.DoAction_Interface(0xffffffff,0x7265,1,517,195,slotId,3808)
            API.RandomSleep2(500,500,500)
            API.DoAction_Interface(0x24,0xffffffff,1,517,306,-1,3808)
          end
      end
  end
    -- Random sleep to mimic game tick or reduce CPU usage
    MYUTILS.RandomSleepRange(500, 1000)
end

---@class IInfo
---@field x number
---@field xs number
---@field y number
---@field ys number
---@field box_x number
---@field box_y number
---@field scroll_y number
---@field id1 number
---@field id2 number
---@field id3 number
---@field id4 number
---@field itemid1 number
---@field itemid1_size number
---@field itemid2 number
---@field hov boolean
---@field textids string
---@field textitem string
---@field memloc number
---@field memloctop number
---@field index number
---@field fullpath string
---@field fullIDpath string
---@field notvisible boolean
---@field OP number
---@field xy number