-- lib_turtle.lua: Coordinate-based navigation and chest management
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

function lib.getPosition()
    if gps then
        local x, y, z = gps.locate(3)
        if x then return x, y, z end
    end
    return nil, nil, nil
end

-- Get current heading by stepping forward/back safely or tracking delta
local function getFacing()
    local x1, y1, z1 = lib.getPosition()
    if not x1 then return nil end
    
    if not turtle.forward() then
        turtle.dig()
        if not turtle.forward() then return nil end
    end
    
    local x2, y2, z2 = lib.getPosition()
    turtle.back()
    
    if not x2 then return nil end
    
    local dx = x2 - x1
    local dz = z2 - z1
    
    if dx > 0 then return "+X" -- East
    elseif dx < 0 then return "-X" -- West
    elseif dz > 0 then return "+Z" -- South
    elseif dz < 0 then return "-Z" -- North
    end
    return nil
end

function lib.faceHeading(targetHeading)
    local current = getFacing()
    local headings = {"+Z", "-X", "-Z", "+X"} -- Clockwise layout relative to standard coordinates
    
    local function getIndex(h)
        for i, v in ipairs(headings) do if v == h then return i end end
        return 1
    end
    
    while current ~= targetHeading do
        turtle.turnRight()
        current = getFacing()
        -- fallback safety turn if getFacing fails momentarily
        if not current then 
            turtle.turnLeft()
            turtle.turnRight()
            break 
        end
    end
end

-- Reliable waypoint navigation using GPS coordinates
function lib.goTo(targetX, targetY, targetZ)
    print(string.format("[*] Navigating to X:%.0f Y:%.0f Z:%.0f", targetX, targetY, targetZ))
    
    while true do
        local x, y, z = lib.getPosition()
        if not x then
            print("[!] GPS signal lost. Waiting...")
            sleep(2)
            goto continue
        end
        
        -- Check if we reached destination (within 0.5 blocks)
        if math.abs(x - targetX) <= 0.5 and math.abs(y - targetY) <= 0.5 and math.abs(z - targetZ) <= 0.5 then
            break
        end
        
        -- Handle Y (height) alignment first
        if math.abs(y - targetY) > 0.5 then
            if y < targetY then
                if not turtle.up() then turtle.digUp(); turtle.up() end
            else
                if not turtle.down() then turtle.digDown(); turtle.down() end
            end
        -- Handle X axis alignment
        elseif math.abs(x - targetX) > 0.5 then
            if x < targetX then
                lib.faceHeading("+X")
            else
                lib.faceHeading("-X")
            end
            if not turtle.forward() then turtle.dig(); turtle.attack(); turtle.forward() end
        -- Handle Z axis alignment
        elseif math.abs(z - targetZ) > 0.5 then
            if z < targetZ then
                lib.faceHeading("+Z")
            else
                lib.faceHeading("-Z")
            end
            if not turtle.forward() then turtle.dig(); turtle.attack(); turtle.forward() end
        end
        
        ::continue::
        sleep(0.05)
    end
end

function lib.dumpAndRefuel(config, homeX, homeY, homeZ)
    local curX, curY, curZ = lib.getPosition()
    if not curX then return end
    
    print("[*] Returning to chest...")
    lib.goTo(homeX, homeY, homeZ)
    
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
    
    turtle.select(1)
    if config.fuelDir == "front" then turtle.suck()
    elseif config.fuelDir == "back" then turtle.suck()
    elseif config.fuelDir == "top" then turtle.suckUp()
    elseif config.fuelDir == "bottom" then turtle.suckDown()
    end
    turtle.refuel()
    
    print("[*] Returning to work area...")
    lib.goTo(curX, curY, curZ)
end

return lib