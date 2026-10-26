-- lib_turtle.lua: Core helper library for automated turtles
local lib = {}

function lib.locateSelf()
    if gps then
        local x, y, z = gps.locate(2)
        if x then return x, y, z end
    end
    return nil, nil, nil
end

function lib.loadConfig()
    local configPath = "turtle_config.lua"
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
        print("Config saved!")
    end
    return config
end

function lib.dumpInventory(outputDir)
    for slot = 1, 16 do
        turtle.select(slot)
        -- Keep slot 1 if it contains fuel, or dump everything else
        if slot > 1 or turtle.getItemCount(slot) > 0 then
            if outputDir == "front" then turtle.drop()
            elseif outputDir == "back" then turtle.drop() -- requires turn logic or direct drop if supported
            elseif outputDir == "top" then turtle.dropUp()
            elseif outputDir == "bottom" then turtle.dropDown()
            end
        end
    end
    turtle.select(1)
end

function lib.manageFuel(fuelDir)
    if turtle.getFuelLevel() < 100 then
        turtle.select(1)
        if fuelDir == "front" then turtle.suck()
        elseif fuelDir == "top" then turtle.suckUp()
        elseif fuelDir == "bottom" then turtle.suckDown()
        end
        turtle.refuel()
    end
end

return lib