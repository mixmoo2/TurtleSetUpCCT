-- lib_turtle.lua: Core positioning, chest mapping, and navigation library
local lib = {}

local configPath = "turtle_config.lua"

function lib.loadConfig()
    local config = { initialized = false }
    if fs.exists(configPath) then
        local file = fs.open(configPath, "r")
        local data = file.readAll()
        file.close()
        local func = load("return " .. data)
        if func then config = func() end
    end
    
    if not config.initialized then
        term.clear()
        term.setCursorPos(1, 1)
        print("=== FIRST TIME SETUP ===")
        write("Fuel Chest Direction (front/back/left/right/top/bottom): ")
        config.fuelDir = read()
        write("Output Chest Direction (front/back/left/right/top/bottom): ")
        config.outputDir = read()
        config.initialized = true
        
        local file = fs.open(configPath, "w")
        file.write(string.format("return { initialized = true, fuelDir = %q, outputDir = %q }", config.fuelDir, config.outputDir))
        file.close()
        print("Configuration saved!")
    end
    return config
end

-- Get current GPS position with heading tracking fallback
function lib.getPosition()
    if gps then
        local x, y, z = gps.locate(3)
        if x then return x, y, z end
    end
    return nil, nil, nil
end

-- Navigate safely to target coordinates (x, y, z)
function lib.goTo(targetX, targetY, targetZ)
    local curX, curY, curZ = lib.getPosition()
    if not curX then
        print("[!] GPS unavailable for navigation!")
        return false
    end

    -- Simple axis-aligned movement logic
    while curY < targetY do turtle.up(); curY = curY + 1 end
    while curY > targetY do turtle.down(); curY = curY - 1 end

    while curX < targetX do
        -- Face East (+X)
        while not lib.isFacing(1, 0) do turtle.turnRight() end
        turtle.forward()
        curX, curY, curZ = lib.getPosition()
    end
    while curX > targetX do
        -- Face West (-X)
        while not lib.isFacing(-1, 0) do turtle.turnRight() end
        turtle.forward()
        curX, curY, curZ = lib.getPosition()
    end

    while curZ < targetZ do
        -- Face South (+Z)
        while not lib.isFacing(0, 1) do turtle.turnRight() end
        turtle.forward()
        curX, curY, curZ = lib.getPosition()
    end
    while curZ > targetZ do
        -- Face North (-Z)
        while not lib.isFacing(0, -1) do turtle.turnRight() end
        turtle.forward()
        curX, curY, curZ = lib.getPosition()
    end
    return true
end

function lib.isFacing(targetXDir, targetZDir)
    local x1, _, z1 = lib.getPosition()
    if not x1 then return true end
    turtle.forward()
    local x2, _, z2 = lib.getPosition()
    turtle.back()
    if not x2 then return true end
    local dx, dz = x2 - x1, z2 - z1
    return math.abs(dx - targetXDir) < 0.1 and math.abs(dz - targetZDir) < 0.1
end

function lib.dumpAndRefuel(config, homeX, homeY, homeZ)
    local currentX, currentY, currentZ = lib.getPosition()
    
    print("[*] Returning to base chest...")
    lib.goTo(homeX, homeY, homeZ)
    
    -- Dump inventory into output chest
    for slot = 1, 16 do
        turtle.select(slot)
        if slot > 1 or turtle.getItemCount(slot) > 0 then
            if config.outputDir == "front" then turtle.drop()
            elseif config.outputDir == "back" then turtle.drop()
            elseif config.outputDir == "top" then turtle.dropUp()
            elseif config.outputDir == "bottom" then turtle.dropDown()
            end
        end
    end
    
    -- Refuel from fuel chest
    turtle.select(1)
    if config.fuelDir == "front" then turtle.suck()
    elseif config.fuelDir == "back" then turtle.suck()
    elseif config.fuelDir == "top" then turtle.suckUp()
    elseif config.fuelDir == "bottom" then turtle.suckDown()
    end
    turtle.refuel()
    
    print("[*] Resuming task at previous coordinates...")
    lib.goTo(currentX, currentY, currentZ)
end

return lib