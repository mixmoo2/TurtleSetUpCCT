-- pickaxe.lua
local lib = dofile("lib_turtle.lua")
local config = lib.loadConfig()

print("Select Pickaxe Mode:")
print("1. Strip Mine (Coordinate Bounded)")
print("2. Quarry (Coordinate Bounded)")
print("3. Netherite / Ancient Debris (Lava Sealing & Edge Protection)")
write("Choice (1-3): ")
local mode = read()

print("\nEnter Bounding Box Corner 1 (Start):")
write("X1: ") local x1 = tonumber(read())
write("Y1: ") local y1 = tonumber(read())
write("Z1: ") local z1 = tonumber(read())

print("Enter Bounding Box Corner 2 (End):")
write("X2: ") local x2 = tonumber(read())
write("Y2: ") local y2 = tonumber(read())
write("Z2: ") local z2 = tonumber(read())

local homeX, homeY, homeZ = lib.getPosition()
print(string.format("Home Registered at: X=%.1f, Y=%.1f, Z=%.1f", homeX or 0, homeY or 0, homeZ or 0))

local function checkInventoryAndFuel()
    if turtle.getFuelLevel() < 150 or turtle.getItemCount(16) > 0 then
        lib.dumpAndRefuel(config, homeX, homeY, homeZ)
    end
end

while true do
    checkInventoryAndFuel()

    if mode == "1" then
        lib.goTo(x1, y1, z1)
        lib.goTo(x2, y2, z2)
    elseif mode == "2" then
        lib.goTo(x1, y1, z1)
        if turtle.detectDown() then turtle.digDown() end
        lib.goTo(x2, y2, z2)
    elseif mode == "3" then
        -- Netherite mode: fill gaps/edges against lava, then mine
        checkInventoryAndFuel()
        if turtle.inspect() then turtle.dig() end
        turtle.select(2)
        if turtle.getItemCount(2) > 0 then
            if not turtle.detectUp() then turtle.placeUp() end
        end
        turtle.select(1)
        turtle.forward()
    end
    sleep(0.1)
end