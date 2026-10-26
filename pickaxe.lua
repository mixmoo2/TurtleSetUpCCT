-- pickaxe.lua: Systematic 3D volume scanning and mining
local lib = dofile("lib_turtle.lua")
local mem = lib.loadMemory()

print("Select Pickaxe Mode:")
print("1. Strip Mine / Volume Clear")
print("2. Quarry")
print("3. Netherite / Ancient Debris (Lava Sealing)")
write("Choice (1-3): ")
local mode = read()
mem.mode = mode
lib.saveMemory(mem)

print("\nEnter Bounding Box Corner 1 (Start):")
write("X1: ") local x1 = tonumber(read())
write("Y1: ") local y1 = tonumber(read())
write("Z1: ") local z1 = tonumber(read())

print("Enter Bounding Box Corner 2 (End):")
write("X2: ") local x2 = tonumber(read())
write("Y2: ") local y2 = tonumber(read())
write("Z2: ") local z2 = tonumber(read())

-- Normalize bounds so it works regardless of which corner you type first
local minX, maxX = math.min(x1, x2), math.max(x1, x2)
local minY, maxY = math.min(y1, y2), math.max(y1, y2)
local minZ, maxZ = math.min(z1, z2), math.max(z1, z2)

local function checkStatus()
    if turtle.getFuelLevel() < 150 or turtle.getItemCount(16) > 0 then
        lib.dumpAndRefuel(mem)
    end
end

-- Systematic 3D grid traversal (visits every block in volume)
for y = minY, maxY do
    for x = minX, maxX do
        for z = minZ, maxZ do
            checkStatus()
            lib.goTo(x, y, z, mem)
            
            if mode == "3" then
                -- Netherite mode: seal lava/gaps before mining
                if turtle.inspect() then turtle.dig() end
                turtle.select(2)
                if turtle.getItemCount(2) > 0 and not turtle.detectUp() then
                    turtle.placeUp()
                end
                turtle.select(1)
            else
                if turtle.detect() then turtle.dig() end
                if turtle.detectDown() then turtle.digDown() end
            end
        end
    end
end

print("[+] Bounding box mining complete!")