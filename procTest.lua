print("Run Lua script procTest.")

local API = require("api")



local searchIDs = {13642, 13643, 13644, 13645, 13646, 13647, 13648}

function FindTree()
    local allObjects = API.ReadAllObjectsArray(false, 0)
    for _, object in ipairs(allObjects) do
        if(object.Id ~= nil and object.Id ~= 0) then
            if(object.Name == "Elder tree") then
                return object.Id
            end 
        end
    end
    return nil
end

--Exported function list is in API
--main loop
API.Write_LoopyLoop(true)
while(API.Read_LoopyLoop())
do-----------------------------------------------------------------------------------

    FindLectern()
    
   
    
API.RandomSleep2(50000, 305000, 1200000)
end----------------------------------------------------------------------------------
