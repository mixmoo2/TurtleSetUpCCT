-- lib_turtle.lua: Persistent state, grid tracking, and systematic pathfinding
local lib = {}
local memoryPath = "turtle_memory.lua"

function lib.loadMemory()
    local mem = { initialized = false, clearedBlocks = {} }
    if fs.exists(memoryPath) then
        term.clear()
        term.setCursorPos(1, 1)
        print("=== EXISTING MEMORY FOUND ===")
        print("1. Continue previous task")
        print("2. Reset / Clear memory and reconfigure")
        write("Choice (1-2): ")
        local choice = read()
        
        if choice == "1" then
            local file = fs.open(memoryPath, "r")
            local data = file.readAll()
            file.close()
            local func = load("return " .. data)
            if func then mem = func() end
            if not mem.clearedBlocks then mem.clearedBlocks = {} end
            print("Resuming previous task from memory...")
            return mem
        end
    end
    
    -- Fresh setup
    term.clear()
    term.setCursorPos(1, 1)
    print("=== FIRST TIME SETUP & MAPPING ===")
    write("Fuel Chest Direction (front/back/left/right/top/bottom): ")
    mem.fuelDir = read()
    write("Output Chest Direction (front/back/left/right/top/bottom): ")
    mem.outputDir = read()
    
    if gps then
        local x, y, z = gps.locate(3)
        mem.homeX, mem.homeY, mem.homeZ = x, y, z
        print(string.format("Home base mapped at: X=%.0f Y=%.0f Z=%.0f", x or 0, y or 0, z or 0))
    end
    
    mem.initialized = true
    mem.clearedBlocks = {}
    lib.saveMemory(mem)
    return mem
end

function lib.saveMemory(mem)
    local file = fs.open(memoryPath, "w")
    -- Serialize table state safely
    file.write("return { " ..
        string.format("initialized = %s, fuelDir = %q, outputDir = %q, homeX = %s, homeY = %s, homeZ = %s, currentX = %s, currentY = %s, currentZ = %s, mode = %q",
            tostring(mem.initialized), tostring(mem.fuelDir), tostring(mem.outputDir),
            tostring(mem.homeX), tostring(mem.homeY), tostring(mem.homeZ),
            tostring(mem.currentX), tostring(mem.currentY), tostring(mem.currentZ), tostring(mem.mode)) ..
        " }")
    file.close()
end

function lib.getPosition()
    if gps then
        local x, y, z = gps.locate(3)
        if x then return x, y, z end
    end
    return nil, nil, nil
end

local function getFacing()
    local x1, _, z1 = lib.getPosition()
    if not x1 then return nil end
    if not turtle.forward() then
        turtle.dig()
        if not turtle.forward() then return nil end
    end
    local x2, _, z2 = lib.getPosition()
    turtle.back()
    if not x2 then return nil end
    local dx, dz = x2 - x1, z2 - z1
    if dx > 0 then return "+X"
    elseif dx < 0 then return "-X"
    elseif dz > 0 then return "+Z"
    elseif dz < 0 then return "-Z"
    end
    return nil
end

function lib.faceHeading(targetHeading)
    local current = getFacing()
    while current ~= targetHeading do
        turtle.turnRight()
        current = getFacing()
        if not current then break end
    end
end

-- Absolute waypoint pathfinding that updates current coordinates in memory
function lib.goTo(targetX, targetY, targetZ, mem)
    print(string.format("[*] Moving to X:%.0f Y:%.0f Z:%.0f", targetX, targetY, targetZ))
    
    while true do
        local x, y, z = lib.getPosition()
        if not x then
            print("[!] GPS signal lost. Waiting...")
            sleep(2)
            goto continue
        end
        
        mem.currentX, mem.currentY, mem.currentZ = x, y, z
        
        if math.abs(x - targetX) <= 0.1 and math.abs(y - targetY) <= 0.1 and math.abs(z - targetZ) <= 0.1 then
            break
        end
        
        if math.abs(y - targetY) > 0.1 then
            if y < targetY then
                if not turtle.up() then turtle.digUp(); turtle.up() end
            else
                if not turtle.down() then turtle.digDown(); turtle.down() end
            end
        elseif math.abs(x - targetX) > 0.1 then
            if x < targetX then lib.faceHeading("+X") else lib.faceHeading("-X") end
            if not turtle.forward() then turtle.dig(); turtle.attack(); turtle.forward() end
        elseif math.abs(z - targetZ) > 0.1 then
            if z < targetZ then lib.faceHeading("+Z") else lib.faceHeading("-Z") end
            if not turtle.forward() then turtle.dig(); turtle.attack(); turtle.forward() end
        end
        
        ::continue::
        sleep(0.05)
    end
    lib.saveMemory(mem)
end

function lib.dumpAndRefuel(mem)
    local curX, curY, curZ = lib.getPosition()
    if not curX then return end
    
    print("[*] Returning to chests for fuel/inventory dump...")
    lib.goTo(mem.homeX, mem.homeY, mem.homeZ, mem)
    
    -- Dump inventory (preserving slot 1 fuel)
    for slot = 1, 16 do
        turtle.select(slot)
        if slot > 1 or turtle.getItemCount(slot) > 0 then
            if mem.outputDir == "front" then turtle.drop()
            elseif mem.outputDir == "back" then turtle.drop()
            elseif mem.outputDir == "top" then turtle.dropUp()
            elseif mem.outputDir == "bottom" then turtle.dropDown()
            end
        end
    end
    
    -- Refuel
    turtle.select(1)
    if mem.fuelDir == "front" then turtle.suck()
    elseif mem.fuelDir == "back" then turtle.suck()
    elseif mem.fuelDir == "top" then turtle.suckUp()
    elseif mem.fuelDir == "bottom" then turtle.suckDown()
    end
    turtle.refuel()
    
    print("[*] Resuming task at last position...")
    if mem.currentX then
        lib.goTo(mem.currentX, mem.currentY, mem.currentZ, mem)
    end
end

return lib