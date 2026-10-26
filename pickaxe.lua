-- pickaxe.lua: Systematic Quarry, Strip Mine, and Netherite fluid-sealing miner
local lib = dofile("lib_turtle.lua")
local mem = lib.loadMemory()

print("Select Pickaxe Mode:")
print("1. Standard Strip Mine / Volume Clear")
print("2. Quarry (Top to Bottom Layer Scan)")
print("3. Netherite / Fluid Sealing & Clearing")
write("Choice (1-3): ")
local mode = read()
mem.mode = mode
lib.saveMemory(mem)

print("\nEnter Bounding Box Corners (X and Z only):")
write("X Start: ") local x1 = tonumber(read())
write("Z Start: ") local z1 = tonumber(read())
write("X End: ")   local x2 = tonumber(read())
write("Z End: ")   local z2 = tonumber(read())

write("Enter Target Bottom Y Level (e.g. -50): ")
local targetY = tonumber(read()) or -50

local minX, maxX = math.min(x1, x2), math.max(x1, x2)
local minZ, maxZ = math.min(z1, z2), math.max(z1, z2)

local _, startY, _ = lib.getPosition()
if not startY then
    print("[!] GPS unavailable! Cannot determine starting Y level.")
    return
end

print(string.format("[*] Starting quarry from top Y=%.0f down to Y=%d", startY, targetY))

local function checkStatus()
    -- Refuel if fuel is low OR dump inventory as soon as slot 16 has an item
    if turtle.getFuelLevel() < 150 or turtle.getItemCount(16) > 0 then
        lib.dumpAndRefuel(mem)
    end
end

-- Systematic layer-by-layer descending scan from top to bottom
for y = startY, targetY, -1 do
    for x = minX, maxX do
        for z = minZ, maxZ do
            checkStatus()
            lib.goTo(x, y, z, mem)
            
            if mode == "3" or mode == "2" then
                -- Fluid sealing & breaking logic: check if there's fluid/block ahead or down
                if turtle.inspect() then 
                    turtle.dig() 
                end
                
                -- Check for liquids / empty spaces underneath or ahead and place blocks to seal
                turtle.select(2) -- Slot 2 is reserved for building/filling blocks
                if turtle.getItemCount(2) > 0 then
                    if not turtle.detectUp() then turtle.placeUp() end
                    if not turtle.detectDown() then turtle.placeDown() end
                end
                turtle.select(1) -- Keep slot 1 protected for fuel
                
                if turtle.detectDown() then 
                    turtle.digDown() 
                end
            else
                if turtle.detect() then turtle.dig() end
                if turtle.detectDown() then turtle.digDown() end
            end
        end
    end
end

print("[+] Quarry operation complete!")