local lib = dofile("lib_turtle.lua")
local mem = lib.loadMemory()

print("Select Pickaxe Mode:")
print("1. Strip Mine (Coordinate Bounded)")
print("2. Quarry (Coordinate Bounded)")
print("3. Netherite / Ancient Debris (Lava Sealing)")
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

local function checkStatus()
    if turtle.getFuelLevel() < 150 or turtle.getItemCount(16) > 0 then
        lib.dumpAndRefuel(mem)
    end
end

while true do
    checkStatus()
    if mode == "1" or mode == "2" then
        lib.goTo(x1, y1, z1, mem)
        checkStatus()
        lib.goTo(x2, y2, z2, mem)
    elseif mode == "3" then
        checkStatus()
        if turtle.inspect() then turtle.dig() end
        turtle.select(2)
        if turtle.getItemCount(2) > 0 and not turtle.detectUp() then
            turtle.placeUp()
        end
        turtle.select(1)
        lib.goTo(x2, y2, z2, mem)
    end
    sleep(0.1)
end