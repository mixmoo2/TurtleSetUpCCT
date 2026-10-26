-- hoe.lua
local lib = dofile("lib_turtle.lua")
local config = lib.loadConfig()

print("Enter Farm Zone Corner 1 (Start):")
write("X1: ") local x1 = tonumber(read())
write("Y1: ") local y1 = tonumber(read())
write("Z1: ") local z1 = tonumber(read())

print("Enter Farm Zone Corner 2 (End):")
write("X2: ") local x2 = tonumber(read())
write("Y2: ") local y2 = tonumber(read())
write("Z2: ") local z2 = tonumber(read())

local homeX, homeY, homeZ = lib.getPosition()
lib.goTo(x1, y1, z1)

while true do
    if turtle.getFuelLevel() < 100 or turtle.getItemCount(16) > 0 then
        lib.dumpAndRefuel(config, homeX, homeY, homeZ)
        lib.goTo(x1, y1, z1)
    end

    turtle.suckDown()
    if turtle.detectDown() then
        turtle.digDown()
    end
    lib.goTo(x2, y2, z2)
    sleep(5)
end