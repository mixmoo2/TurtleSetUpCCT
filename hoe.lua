-- hoe.lua
local lib = dofile("lib_turtle.lua")
local config = lib.loadConfig()

write("Enter Farm Zone Width (X): ")
local width = tonumber(read()) or 10
write("Enter Farm Zone Length (Z): ")
local length = tonumber(read()) or 10

local homeX, homeY, homeZ = lib.getPosition()

while true do
    if turtle.getFuelLevel() < 100 or turtle.getItemCount(16) > 0 then
        lib.dumpAndRefuel(config, homeX, homeY, homeZ)
    end

    for x = 1, width do
        for z = 1, length do
            turtle.suckDown()
            if turtle.detectDown() then
                turtle.digDown() -- harvest crop
            end
            if z < length then
                turtle.forward()
            end
        end
        if x < width then
            turtle.turnRight()
            turtle.forward()
            turtle.turnRight()
        end
    end
    sleep(5)
end