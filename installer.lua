-- installer.lua
local repoUser = "mixmoo2"
local repoName = "TurtleSetUpCCT"
local branch = "main"

local function downloadFile(fileName)
    local url = string.format("https://raw.githubusercontent.com/%s/%s/%s/%s", repoUser, repoName, branch, fileName)
    print("Downloading " .. fileName .. "...")
    local response = http.get(url)
    if not response then
        print("[!] Failed to download: " .. fileName)
        return false
    end
    local content = response.readAll()
    response.close()
    
    local file = fs.open(fileName, "w")
    file.write(content)
    file.close()
    print("[+] Saved " .. fileName)
    return true
end

print("=== TURTLE SETUP INSTALLER ===")
if not downloadFile("lib_turtle.lua") then return end

print("\nSelect Tool Type for this Turtle:")
print("1. Pickaxe (Mining / Quarry / Netherite)")
print("2. Axe (Lumberjack)")
print("3. Hoe (Farming)")
print("4. Sword (Combat Guard)")
write("Choice (1-4): ")
local choice = read()

local targetScript = ""
if choice == "1" then targetScript = "pickaxe.lua"
elseif choice == "2" then targetScript = "axe.lua"
elseif choice == "3" then targetScript = "hoe.lua"
elseif choice == "4" then targetScript = "sword.lua"
else targetScript = "pickaxe.lua"
end

if downloadFile(targetScript) then
    if fs.exists("startup.lua") then fs.delete("startup.lua") end
    local file = fs.open(targetScript, "r")
    local code = file.readAll()
    file.close()
    
    local startFile = fs.open("startup.lua", "w")
    startFile.write(code)
    startFile.close()
    
    print("\n[✓] Successfully installed! Rebooting in 2 seconds...")
    sleep(2)
    os.reboot()
end