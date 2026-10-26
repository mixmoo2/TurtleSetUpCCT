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
    
    if dx > 0 then return "+X"
    elseif dx < 0 then return "-X"
    elseif dz > 0 then return "+Z"
    elseif dz < 0 then return "-Z"
    end
    return nil
end

function lib.faceHeading(targetHeading)
    local current = getFacing()
    local headings = {"+Z", "-X", "-Z", "+X"}
    
    while current ~= targetHeading do
        turtle.turnRight()
        current = getFacing()
        if not current then 
            turtle.turnLeft()
            turtle.turnRight()
            break 
        end
    end
end

function lib.goTo(targetX, targetY, targetZ)
    print(string.format("[*] Navigating to X:%.0f Y:%.0f Z:%.0f", targetX, targetY, targetZ))
    
    while true do
        local x, y, z = lib.getPosition()
        if not x then
            print("[!] GPS signal lost. Waiting...")
            sleep(2)
            goto continue
        end
        
        if math.abs(x - targetX) <= 0.5 and math.abs(y - targetY) <= 0.5 and math.abs(z - targetZ) <= 0.5 then
            break
        end
        
        if math.abs(y - targetY) > 0.5 then
            if y < targetY then
                if not turtle.up() then turtle.digUp(); turtle.up() end
            else
                if not turtle.down() then turtle.digDown(); turtle.down() end
            end
        elseif math.abs(x - targetX) > 0.5 then
            if x < targetX then lib.faceHeading("+X") else lib.faceHeading("-X") end
            if not turtle.forward() then turtle.dig(); turtle.attack(); turtle.forward() end
        elseif math.abs(z - targetZ) > 0.5 then
            if z < targetZ then lib.faceHeading("+Z") else lib.faceHeading("-Z") end
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