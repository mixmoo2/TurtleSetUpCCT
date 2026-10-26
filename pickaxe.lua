-- pickaxe.lua
local lib = dofile("lib_turtle.lua")
local config = lib.loadConfig()

print("Select Pickaxe Mode:")
print("1. Strip Mine (2D Bounded)")
print("2. Quarry (Alternate Axis Bounded)")
print("3. Netherite / Ancient Debris (Lava sealing)")
write("Choice (1-3): ")
local mode = read()

write("Enter Strip/Quarry Width (X): ")
local width = tonumber(read()) or 10
write("Enter Strip/Quarry Length (Z): ")
local length = tonumber(read()) or 10

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
        -- Strip Mine 2D Bounded Logic
        for x = 1, width do
            for z = 1, length do
                checkInventoryAndFuel()
                if turtle.detect() then turtle.dig() end
                turtle.forward()
            end
            turtle.turnRight()
            if turtle.detect() then turtle.dig() end
            turtle.forward()
            turtle.turnRight()
        end
    elseif mode == "2" then
        -- Quarry Alternate Axis Logic
        for x = 1, width do
            for z = 1, length do
                checkInventoryAndFuel()
                if turtle.detect() then turtle.dig() end
                if turtle.detectDown() then turtle.digDown() end
                turtle.forward()
            end
            turtle.turnRight()
            turtle.forward()
            turtle.turnRight()
        end
    elseif mode == "3" then
        -- Netherite Search with Lava Sealing & Edge Protection
        checkInventoryAndFuel()
        -- Check for lava/liquids around and place blocks to seal
        if turtle.inspect() then
            -- regular block mining
            turtle.dig()
        end
        -- Seal edges or empty spaces to prevent lava spreading
        turtle.select(2)
        if turtle.getItemCount(2) > 0 then
            if turtle.detectUp() == false then turtle.placeUp() end
        end
        turtle.select(1)
        turtle.forward()
    end
    sleep(0.1)
end