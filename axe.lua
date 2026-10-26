-- axe.lua: Bounded tree-felling with persistent memory and sapling replanting
local lib = dofile("lib_turtle.lua")
local mem = lib.loadMemory()

print("Enter Logging Zone Corner 1 (Start):")
write("X1: ") local x1 = tonumber(read())
write("Y1: ") local y1 = tonumber(read())
write("Z1: ") local z1 = tonumber(read())

print("Enter Logging Zone Corner 2 (End):")
write("X2: ") local x2 = tonumber(read())
write("Y2: ") local y2 = tonumber(read())
write("Z2: ") local z2 = tonumber(read())

write("Select Sapling Type (1: Oak/Standard, 2: Spruce/2x2 Grid, 3: Jungle/Special): ")
local saplingType = read()

-- Navigate to start of zone
lib.goTo(x1, y1, z1, mem)

while true do
    if turtle.getFuelLevel() < 100 or turtle.getItemCount(16) > 0 then
        lib.dumpAndRefuel(mem)
        lib.goTo(x1, y1, z1, mem)
    end

    if turtle.detect() then
        turtle.dig()
        turtle.forward()
        while turtle.detectUp() do
            turtle.digUp()
            turtle.up()
        end
        while not turtle.detectDown() do
            turtle.down()
        end
        
        -- Plant sapling from slot 2
        turtle.select(2)
        if saplingType == "2" then
            turtle.placeDown()
        else
            turtle.placeDown()
        end
        
        turtle.back()
    else
        -- Scan forward or move along zone
        turtle.forward()
    end
    sleep(1)
end