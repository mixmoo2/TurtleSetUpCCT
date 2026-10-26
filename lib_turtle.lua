-- lib_turtle.lua: Core positioning, chest mapping, and safe navigation library
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
    print("[!] GPS signal lost!")
    return nil, nil, nil
end

-- Safe movement toward target coordinates without infinite spin loops
function lib.goTo(targetX, targetY, targetZ)
    print(string.format("[*] Navigating to X:%.1f Y:%.1f Z:%.1f", targetX, targetY, targetZ))
    
    while true do
        local x, y, z = lib.getPosition()
        if not x then 
            sleep(2)
            goto continue 
        end

        if math.abs(x - targetX) < 0.5 and math.abs(y - targetY) < 0.5 and math.abs(z - targetZ) < 0.5 then
            break -- Reached destination
        end

        -- Move Y (Vertical) first
        if y < targetY then
            if not turtle.up() then turtle.digUp() end
        elseif y > targetY then
            if not turtle.down() then turtle.digDown() end
        -- Move X Axis
        elseif x < targetX then
            -- Face +X (East) -> We can infer orientation or just try moving and correcting
            if not turtle.forward() then turtle.dig(); turtle.attack() end
        elseif x > targetX then
            if not turtle.forward() then turtle.dig(); turtle.attack() end
        -- Move Z Axis
        elseif z < targetZ then
            if not turtle.forward() then turtle.dig(); turtle.attack() end
        elseif z > targetZ then
            if not turtle.forward() then turtle.dig(); turtle.attack() end
        end

        ::continue::
        sleep(0.1)
    end
end

function lib.dumpAndRefuel(config, homeX, homeY, homeZ)
    local currentX, currentY, currentZ = lib.getPosition()
    if not currentX then return end
    
    print("[*] Returning to home base...")
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
    
    print("[*] Resuming work at task site...")
    lib.goTo(currentX, currentY, currentZ)
end

return lib