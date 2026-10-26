-- sword.lua
local lib = dofile("lib_turtle.lua")
local config = lib.loadConfig()

write("Enter facing cardinal direction for killing (north/south/east/west): ")
local killDir = string.lower(read() or "north")

local homeX, homeY, homeZ = lib.getPosition()
print("Guard active facing: " .. killDir)

while true do
    if turtle.getItemCount(16) > 0 then
        lib.dumpAndRefuel(config, homeX, homeY, homeZ)
    end
    
    turtle.attack()
    sleep(0.5)
end