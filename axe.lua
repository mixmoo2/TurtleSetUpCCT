-- axe.lua
local lib = dofile("lib_turtle.lua")
local config = lib.loadConfig()

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

local homeX, homeY, homeZ = lib.getPosition()
lib.goTo(x1, y1, z1)

while true do
    if turtle.getFuelLevel() < 100 or turtle.getItemCount(16) > 0 then
        lib.dumpAndRefuel(config, homeX, homeY, homeZ)
        lib.goTo(x1, y1, z1)
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
        
        turtle.select(2) -- slot 2 holds saplings
        if saplingType == "2" then
            turtle.placeDown()
        else
            turtle.placeDown()
        end
        
        turtle.back()
    else
        turtle.forward()
    end
    sleep(1)
end