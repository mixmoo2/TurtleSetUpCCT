-- axe.lua
local lib = dofile("lib_turtle.lua")
local config = lib.loadConfig()

write("Enter Logging Zone Width (X): ")
local width = tonumber(read()) or 10
write("Enter Logging Zone Length (Z): ")
local length = tonumber(read()) or 10
write("Select Sapling Type (1: Oak/Standard, 2: Spruce/2x2 Grid, 3: Jungle/Special): ")
local saplingType = read()

local homeX, homeY, homeZ = lib.getPosition()

while true do
    if turtle.getFuelLevel() < 100 or turtle.getItemCount(16) > 0 then
        lib.dumpAndRefuel(config, homeX, homeY, homeZ)
    end

    if turtle.detect() then
        turtle.dig()
        turtle.forward()
        -- Chop vertical trunk
        while turtle.detectUp() do
            turtle.digUp()
            turtle.up()
        end
        -- Return to ground and plant corresponding sapling
        while not turtle.detectDown() do
            turtle.down()
        end
        
        -- Planting behavior based on sapling type
        turtle.select(2) -- slot 2 holds saplings
        if saplingType == "2" then
            -- Spruce / 2x2 planting logic
            turtle.placeDown()
        else
            -- Standard 1x1 planting
            turtle.placeDown()
        end
        
        turtle.back()
    else
        turtle.forward()
    end
    sleep(1)
end