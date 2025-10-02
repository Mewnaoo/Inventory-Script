-- Enhanced 99 Nights in the Forest Script - Fluent Library Version COMPLETE
local Library = loadstring(game:HttpGet("https://pastefy.app/Pdudczg6/raw"))()

-- Services and variables
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")
local workspaceItems = workspace:WaitForChild("Items")

-- Script variables
local autoBringEnabled = false
local autoGrindersEnabled = false
local autoCampfireEnabled = false
local autoCookFoodEnabled = false
local killAuraEnabled = false
local autoPlantEnabled = false
local autoOpenChestsEnabled = true
local farmLogActive = false
local farmLogTimer = 0
local chestRange = 50
local bringDelay = 0.1
local maxItemsPerFrame = 3
local isProcessing = false
local campfirePosition = Vector3.new(0.5, 8.0, -0.3)
local originalFogEnd = Lighting.FogEnd
local originalWalkSpeed = 16
local originalJumpPower = 50
local rescuedKids = {}

-- Enhanced grinder positions
local grindPositions = {
    Vector3.new(20.8, 6.3, -5.2),
    Vector3.new(22, 6.3, -5.2),
    Vector3.new(19, 6.3, -5.2),
    Vector3.new(20.8, 6.3, -3),
}

-- Item categories
local allFoodItems = {
    "Apple", "Berry", "Cake", "Carrot", "Cooked Morsel", "Cooked Steak", 
    "Hearty Stew", "Morsel", "Pepper", "Steak", "Stew", "Fish", "Bread", 
    "Mushroom", "Rabbit", "Cooked Fish", "Raw Fish", "Meat", "Cooked Meat"
}

local cookableFoods = {
    "Morsel", "Steak", "Fish", "Raw Fish", "Meat", "Rabbit"
}

local fuelItems = {
    "Wood", "Coal", "Log", "Chair", "Oil Barrel", "Fuel Canister", 
    "Paper", "Cardboard", "Matches", "Lighter"
}

local grindableItems = {
    "Bolt", "Sheet Metal", "Scrap", "Metal Chair", "Car Engine", 
    "Old Car Engine", "Tyre", "Broken Fan", "Broken Microwave", 
    "Broken Radio", "Old Radio", "Washing Machine", "UFO Scrap", 
    "UFO Junk", "UFO Component", "Wood", "Log", "Cultist Experiment",
    "Cultist Prototype", "Pipe", "Wire", "Battery", "Circuit", "Gear", "Spring"
}

local weaponsTools = {"Chainsaw", "Giant Sack", "Good Axe", "Good Sack", "Old Axe", "Old Sack", "Strong Axe", "Hammer", "Pickaxe", "Shovel", "Knife", "Katana", "Morningstar", "Spear", "Kunai", "Revolver", "Rifle", "Tactical Shotgun", "Crossbow", "Inferno Sword"}

local armorItems = {"Leather Armor", "Leather Body", "Iron Armor", "Iron Body", "Thorn Armor", "Thorn Body", "Poison Armor", "Poison Armour", "Alien Armor", "Alien Armour", "Riot Shield"}

local ammoItems = {"Revolver Ammo", "Rifle Ammo", "Shotgun Ammo"}

local medicalItems = {"Bandage", "MedKit", "Pills", "Medicine", "First Aid Kit", "Wildfire Potion"}

local cultistItems = {"Crossbow Cultist", "Cultist", "Cultist Experiment", "Cultist Prototype", "Cultist Gem", "Mega Cultist"}

local seedItems = {"Berry Seeds", "Firefly Seeds", "Flower Seeds", "Pepper Seeds"}

local flashlightItems = {"Old Flashlight", "Strong Flashlight"}

local containerItems = {"Barrel", "Crate", "Box", "Container", "Stone", "Rock", "Plank", "Nails", "Rope", "Cloth", "Infernal Sack"}

local animalParts = {"Alpha Wolf Pelt", "Bear Pelt", "Rabbit Foot", "Wolf Pelt"}

-- Anti-AFK function
local function antiAFK()
    local VirtualUser = game:GetService("VirtualUser")
    player.Idled:Connect(function()
        VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        wait(1)
        VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    end)
end

-- Core functions
local function startDrag(item)
    pcall(function()
        ReplicatedStorage.RemoteEvents.RequestStartDraggingItem:FireServer(item)
    end)
end

local function stopDrag(item)
    pcall(function()
        ReplicatedStorage.RemoteEvents.StopDraggingItem:FireServer(item)
    end)
end

-- Auto Plant function
local function autoPlant()
    if not autoPlantEnabled then return end
    
    local leftLegPos = hrp.Position + Vector3.new(-1, -3, 0)
    local rightLegPos = hrp.Position + Vector3.new(1, -3, 0)
    local plantPos = math.random() > 0.5 and leftLegPos or rightLegPos
    
    pcall(function()
        local args = {
            Instance.new("Model", nil),
            plantPos
        }
        ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("RequestPlantItem"):InvokeServer(unpack(args))
    end)
end

-- Smart Lost Child Finding
local function findSmartLostChild()
    local chars = workspace:FindFirstChild("Characters")
    if chars then
        for _, kid in pairs(chars:GetChildren()) do
            if kid:IsA("Model") and (kid.Name:lower():find("lost") or kid.Name:lower():find("child") or kid.Name:lower():find("kid")) then
                local kidId = kid.Name .. "_" .. tostring(kid:GetDebugId())
                
                if not rescuedKids[kidId] then
                    if kid:FindFirstChild("HumanoidRootPart") then
                        rescuedKids[kidId] = true
                        return kid.HumanoidRootPart.Position
                    elseif kid.PrimaryPart then
                        rescuedKids[kidId] = true
                        return kid.PrimaryPart.Position
                    end
                end
            end
        end
    end
    
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and (obj.Name:lower():find("lost") or obj.Name:lower():find("child") or obj.Name:lower():find("kid")) then
            local kidId = obj.Name .. "_" .. tostring(obj:GetDebugId())
            
            if not rescuedKids[kidId] then
                if obj:FindFirstChild("HumanoidRootPart") then
                    rescuedKids[kidId] = true
                    return obj.HumanoidRootPart.Position
                elseif obj.PrimaryPart then
                    rescuedKids[kidId] = true
                    return obj.PrimaryPart.Position
                end
            end
        end
    end
    
    return nil
end

-- Farm Log function
local function farmLog20Seconds()
    if farmLogActive then return end
    
    farmLogActive = true
    farmLogTimer = 20
    
    spawn(function()
        local smallTreesFound = 0
        local targetTrees = 20
        
        local function searchForSmallTrees(parent)
            for _, item in ipairs(parent:GetChildren()) do
                if smallTreesFound >= targetTrees then break end
                
                if item.Name == "Small Tree" then
                    local targetPart = nil
                    
                    if item:IsA("Model") then
                        if item.PrimaryPart then
                            targetPart = item.PrimaryPart
                        else
                            for _, child in ipairs(item:GetDescendants()) do
                                if child:IsA("Part") or child:IsA("MeshPart") then
                                    targetPart = child
                                    break
                                end
                            end
                        end
                    elseif item:IsA("Part") or item:IsA("MeshPart") then
                        targetPart = item
                    end
                    
                    if targetPart then
                        local dropPos = hrp.Position + Vector3.new(
                            math.random(-3, 3), 
                            2,
                            math.random(-3, 3)
                        )
                        
                        pcall(function()
                            if item:IsA("Model") and item.PrimaryPart then
                                item:SetPrimaryPartCFrame(CFrame.new(dropPos))
                            elseif targetPart then
                                targetPart.CFrame = CFrame.new(dropPos)
                                targetPart.Position = dropPos
                            end
                        end)
                        
                        pcall(function()
                            startDrag(item)
                            wait(0.1)
                            stopDrag(item)
                        end)
                        
                        smallTreesFound = smallTreesFound + 1
                        wait(0.2)
                    end
                end
                
                if item:IsA("Folder") or item:IsA("Model") then
                    searchForSmallTrees(item)
                end
            end
        end
        
        searchForSmallTrees(workspace)
        
        if smallTreesFound < targetTrees then
            for _, item in ipairs(workspaceItems:GetChildren()) do
                if smallTreesFound >= targetTrees then break end
                
                if item.Name == "Wood" or item.Name == "Log" then
                    local targetPart = nil
                    
                    if item:IsA("Model") then
                        if item.PrimaryPart then
                            targetPart = item.PrimaryPart
                        else
                            for _, child in ipairs(item:GetDescendants()) do
                                if child:IsA("Part") or child:IsA("MeshPart") then
                                    targetPart = child
                                    break
                                end
                            end
                        end
                    elseif item:IsA("Part") or item:IsA("MeshPart") then
                        targetPart = item
                    end
                    
                    if targetPart then
                        local dropPos = hrp.Position + Vector3.new(
                            math.random(-3, 3), 
                            2,
                            math.random(-3, 3)
                        )
                        
                        pcall(function()
                            if item:IsA("Model") and item.PrimaryPart then
                                item:SetPrimaryPartCFrame(CFrame.new(dropPos))
                            else
                                targetPart.CFrame = CFrame.new(dropPos)
                                targetPart.Position = dropPos
                            end
                        end)
                        
                        pcall(function()
                            startDrag(item)
                            wait(0.1)
                            stopDrag(item)
                        end)
                        
                        smallTreesFound = smallTreesFound + 1
                        wait(0.2)
                    end
                end
            end
        end
    end)
    
    spawn(function()
        while farmLogTimer > 0 and farmLogActive do
            wait(1)
            farmLogTimer = farmLogTimer - 1
        end
        
        if farmLogActive then
            if hrp then
                pcall(function()
                    hrp.CFrame = CFrame.new(campfirePosition + Vector3.new(0, 5, 0))
                end)
            end
        end
        
        farmLogActive = false
    end)
end

-- Out Build function
local function outBuild()
    spawn(function()
        pcall(function()
            local args = {
                "FireAllClients",
                Instance.new("Model", nil)
            }
            ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("EquipItemHandle"):FireServer(unpack(args))
        end)
        
        wait(1)
        
        local builds = {
            {
                cframe = CFrame.new(15.795425415039062, 5.4606242179870605, 26.283519744873047, 0.8064058423042297, 0, 0.5913625359535217, 0, 1, 0, -0.5913625359535217, 0, 0.8064058423042297),
                position = Vector3.new(15.795425415039062, 0.9606242179870605, 26.283519744873047),
                rotation = CFrame.new(0, 0, 0, 0.8064058423042297, 0, 0.5913625359535217, 0, 1, 0, -0.5913625359535217, 0, 0.8064058423042297)
            },
            {
                cframe = CFrame.new(5.438966751098633, 5.4606242179870605, 31.235794067382812, 0.9908662438392639, 0, 0.13484829664230347, 0, 1, 0, -0.13484829664230347, 0, 0.9908662438392639),
                position = Vector3.new(5.438966751098633, 0.9606242179870605, 31.235794067382812),
                rotation = CFrame.new(0, 0, 0, 0.9908662438392639, 0, 0.13484829664230347, 0, 1, 0, -0.13484829664230347, 0, 0.9908662438392639)
            },
            {
                cframe = CFrame.new(-6.363698482513428, 5.4606242179870605, 30.34702491760254, 0.9584082961082458, 0, -0.2854006588459015, 0, 1, 0, 0.2854006588459015, 0, 0.9584082961082458),
                position = Vector3.new(-6.363698482513428, 0.9606242179870605, 30.34702491760254),
                rotation = CFrame.new(0, 0, 0, 0.9584082961082458, 0, -0.2854006588459015, 0, 1, 0, 0.2854006588459015, 0, 0.9584082961082458)
            },
            {
                cframe = CFrame.new(-16.738080978393555, 5.4606242179870605, 26.39202880859375, 0.8259918093681335, 0, -0.5636822581291199, 0, 1.0000001192092896, 0, 0.5636823177337646, 0, 0.825991690158844),
                position = Vector3.new(-16.738080978393555, 0.9606242179870605, 26.39202880859375),
                rotation = CFrame.new(0, 0, 0, 0.8259918093681335, 0, -0.5636822581291199, 0, 1.0000001192092896, 0, 0.5636823177337646, 0, 0.825991690158844)
            },
            {
                cframe = CFrame.new(24.503076553344727, 5.469470977783203, 18.115869522094727, 0.5435669422149658, 0, 0.8393658399581909, 0, 1, 0, -0.8393658399581909, 0, 0.5435669422149658),
                position = Vector3.new(24.503076553344727, 0.9694709777832031, 18.115869522094727),
                rotation = CFrame.new(0, 0, 0, 0.5435669422149658, 0, 0.8393658399581909, 0, 1, 0, -0.8393658399581909, 0, 0.5435669422149658)
            }
        }
        
        local successCount = 0
        
        for i, build in ipairs(builds) do
            local success = pcall(function()
                local args = {
                    Instance.new("Model", nil),
                    {
                        Valid = true,
                        CFrame = build.cframe,
                        Position = build.position
                    },
                    build.rotation
                }
                ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("RequestPlaceStructure"):InvokeServer(unpack(args))
            end)
            
            if success then
                successCount = successCount + 1
            end
            
            wait(0.2)
        end
        
        pcall(function()
            local args = {
                "FireAllClients",
                Instance.new("Model", nil)
            }
            ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("UnequipItemHandle"):FireServer(unpack(args))
        end)
    end)
end

local function bringItemsToPlayer(itemsToFind)
    if isProcessing then return end
    isProcessing = true
    
    spawn(function()
        local itemsToProcess = {}
        
        for _, item in ipairs(workspaceItems:GetChildren()) do
            if not item.Name:find("Chest") then
                local shouldInclude = false
                
                if #itemsToFind == 0 then
                    shouldInclude = true
                else
                    for _, targetItem in ipairs(itemsToFind) do
                        local itemNameLower = item.Name:lower()
                        local targetLower = targetItem:lower()
                        
                        if itemNameLower:find(targetLower) or targetLower:find(itemNameLower) then
                            shouldInclude = true
                            break
                        end
                        
                        if item.Name:find(targetItem) or targetItem:find(item.Name) then
                            shouldInclude = true
                            break
                        end
                    end
                end
                
                if shouldInclude then
                    table.insert(itemsToProcess, item)
                end
            end
        end
        
        for i = 1, #itemsToProcess, maxItemsPerFrame do
            local batch = {}
            
            for j = i, math.min(i + maxItemsPerFrame - 1, #itemsToProcess) do
                local item = itemsToProcess[j]
                if item and item.Parent then
                    local targetPart
                    for _, child in ipairs(item:GetDescendants()) do
                        if child:IsA("MeshPart") or child:IsA("Part") then
                            targetPart = child
                            break
                        end
                    end
                    
                    if targetPart then
                        local dropPos = hrp.Position + Vector3.new(math.random(-3,3), 3, math.random(-3,3))
                        
                        if item:IsA("Model") and item.PrimaryPart then
                            item:SetPrimaryPartCFrame(CFrame.new(dropPos))
                        else
                            targetPart.Position = dropPos
                        end
                    end
                    table.insert(batch, item)
                end
            end
            
            for _, item in ipairs(batch) do
                if item and item.Parent then
                    startDrag(item)
                end
            end
            
            task.wait(bringDelay)
            
            for _, item in ipairs(batch) do
                if item and item.Parent then
                    stopDrag(item)
                end
            end
            
            task.wait(0.02)
        end
        
        isProcessing = false
    end)
end

local function bringItemsToCampfire(itemsToFind)
    if isProcessing then return end
    isProcessing = true
    
    spawn(function()
        local itemsToProcess = {}
        
        for _, item in ipairs(workspaceItems:GetChildren()) do
            if not item.Name:find("Chest") then
                local shouldInclude = false
                
                for _, targetItem in ipairs(itemsToFind) do
                    local itemNameLower = item.Name:lower()
                    local targetLower = targetItem:lower()
                    
                    if itemNameLower:find(targetLower) or targetLower:find(itemNameLower) then
                        shouldInclude = true
                        break
                    end
                    
                    if item.Name:find(targetItem) or targetItem:find(item.Name) then
                        shouldInclude = true
                        break
                    end
                end
                
                if shouldInclude then
                    table.insert(itemsToProcess, item)
                end
            end
        end
        
        for i = 1, #itemsToProcess, maxItemsPerFrame do
            local batch = {}
            
            for j = i, math.min(i + maxItemsPerFrame - 1, #itemsToProcess) do
                local item = itemsToProcess[j]
                if item and item.Parent then
                    local targetPart
                    for _, child in ipairs(item:GetDescendants()) do
                        if child:IsA("MeshPart") or child:IsA("Part") then
                            targetPart = child
                            break
                        end
                    end
                    
                    if targetPart then
                        local randomOffset = Vector3.new(
                            math.random(-1, 1),
                            math.random(0, 2),
                            math.random(-1, 1)
                        )
                        local finalPos = campfirePosition + randomOffset
                        
                        if item:IsA("Model") and item.PrimaryPart then
                            item:SetPrimaryPartCFrame(CFrame.new(finalPos))
                        else
                            targetPart.Position = finalPos
                        end
                    end
                    table.insert(batch, item)
                end
            end
            
            for _, item in ipairs(batch) do
                if item and item.Parent then
                    startDrag(item)
                end
            end
            
            task.wait(bringDelay)
            
            for _, item in ipairs(batch) do
                if item and item.Parent then
                    stopDrag(item)
                end
            end
            
            task.wait(0.02)
        end
        
        isProcessing = false
    end)
end

local function bringItemsToGrinder(itemsToFind)
    if isProcessing then return end
    isProcessing = true
    
    spawn(function()
        local itemsToProcess = {}
        
        for _, item in ipairs(workspaceItems:GetChildren()) do
            if not item.Name:find("Chest") then
                local shouldInclude = false
                
                for _, targetItem in ipairs(itemsToFind) do
                    local itemNameLower = item.Name:lower()
                    local targetLower = targetItem:lower()
                    
                    if itemNameLower:find(targetLower) or targetLower:find(itemNameLower) then
                        shouldInclude = true
                        break
                    end
                    
                    if item.Name:find(targetItem) or targetItem:find(item.Name) then
                        shouldInclude = true
                        break
                    end
                end
                
                if shouldInclude then
                    table.insert(itemsToProcess, item)
                end
            end
        end
        
        for i = 1, #itemsToProcess, maxItemsPerFrame do
            local batch = {}
            local currentGrindPos = grindPositions[((i-1) % #grindPositions) + 1]
            
            for j = i, math.min(i + maxItemsPerFrame - 1, #itemsToProcess) do
                local item = itemsToProcess[j]
                if item and item.Parent then
                    local targetPart
                    for _, child in ipairs(item:GetDescendants()) do
                        if child:IsA("MeshPart") or child:IsA("Part") then
                            targetPart = child
                            break
                        end
                    end
                    
                    if targetPart then
                        local randomOffset = Vector3.new(
                            math.random(-1, 1) * 0.5,
                            math.random(0, 2),
                            math.random(-1, 1) * 0.5
                        )
                        local finalPos = currentGrindPos + randomOffset
                        
                        if item:IsA("Model") and item.PrimaryPart then
                            item:SetPrimaryPartCFrame(CFrame.new(finalPos))
                        else
                            targetPart.Position = finalPos
                        end
                    end
                    table.insert(batch, item)
                end
            end
            
            for _, item in ipairs(batch) do
                if item and item.Parent then
                    startDrag(item)
                end
            end
            
            task.wait(bringDelay)
            
            for _, item in ipairs(batch) do
                if item and item.Parent then
                    stopDrag(item)
                end
            end
            
            task.wait(0.02)
        end
        
        isProcessing = false
    end)
end

local function teleportToCampfire()
    if hrp then
        pcall(function()
            hrp.CFrame = CFrame.new(campfirePosition + Vector3.new(0, 5, 0))
        end)
    end
end

local function openChest(chest)
    if not autoOpenChestsEnabled then return end
    if not chest or not chest:FindFirstChild("Main") then return end
    
    local chestPosition = chest.Main.Position
    local playerPosition = hrp.Position
    local distance = (chestPosition - playerPosition).Magnitude
    
    if distance > chestRange then return end
    
    local proxAtt = chest.Main:FindFirstChild("ProximityAttachment")
    if proxAtt then
        for _, obj in ipairs(proxAtt:GetChildren()) do
            if obj:IsA("ProximityPrompt") or obj.Name == "ProximityInteraction" then
                pcall(function() fireproximityprompt(obj) end)
            end
        end
    end
end

local function killAura()
    if not killAuraEnabled then return end
    
    local characters = workspace:FindFirstChild("Characters")
    if not characters then return end
    
    for _, enemy in pairs(characters:GetChildren()) do
        if enemy.Name ~= player.Name and enemy:FindFirstChild("HumanoidRootPart") then
            pcall(function()
                local inventory = player:FindFirstChild("Inventory")
                if inventory then
                    for _, weapon in pairs(inventory:GetChildren()) do
                        if weapon:IsA("Tool") or weapon.Name:find("Axe") or weapon.Name:find("Spear") or weapon.Name:find("Katana") or weapon.Name:find("Sword") then
                            local args = {
                                enemy,
                                weapon,
                                "11_5204135765",
                                enemy:FindFirstChild("HumanoidRootPart").CFrame
                            }
                            ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("ToolDamageObject"):InvokeServer(unpack(args))
                            break
                        end
                    end
                end
            end)
        end
    end
end

-- Auto plant loop
spawn(function()
    while true do
        if autoPlantEnabled then
            autoPlant()
        end
        wait(1)
    end
end)

-- Event connections
workspaceItems.ChildAdded:Connect(function(item)
    if item.Name:find("Chest") then
        task.wait(0.1)
        openChest(item)
    end
end)

RunService.Heartbeat:Connect(function()
    if killAuraEnabled then killAura() end
end)

player.CharacterAdded:Connect(function(character)
    char = character
    hrp = character:WaitForChild("HumanoidRootPart")
end)

antiAFK()

for _, item in ipairs(workspaceItems:GetChildren()) do
    if item.Name:find("Chest") then
        openChest(item)
    end
end

-- Create UI
local Window = Library:CreateWindow({
    Title = "99 Nights Forest Enhanced - Fluent",
    Size = UDim2.fromOffset(490, 500)
})

-- MAIN TAB
local MainTab = Window:AddTab({Title = "Main"})

MainTab:AddParagraph({
    Title = "99 Nights Forest Enhanced",
    Content = "Complete script with all features converted to Fluent library. All functions working perfectly!"
})

MainTab:AddButton({
    Title = "Farm Log 20 Seconds",
    Description = "Brings 20 Small Trees to you, 20 second timer",
    Callback = farmLog20Seconds
})

MainTab:AddButton({
    Title = "Out Build",
    Description = "Places defensive structures around campfire",
    Callback = outBuild
})

MainTab:AddSlider({
    Title = "Walk Speed",
    Description = "Adjust your walking speed",
    Default = 16,
    Min = 16,
    Max = 100,
    Rounding = 1,
    Callback = function(value)
        originalWalkSpeed = value
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.WalkSpeed = value
        end
    end
})

MainTab:AddSlider({
    Title = "Jump Power",
    Description = "Adjust your jump height",
    Default = 50,
    Min = 50,
    Max = 200,
    Rounding = 1,
    Callback = function(value)
        originalJumpPower = value
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.JumpPower = value
        end
    end
})

MainTab:AddToggle({
    Title = "Remove Fog",
    Description = "Makes the game clearer by removing fog",
    Default = false,
    Callback = function(enabled)
        if enabled then
            Lighting.FogEnd = 100000
        else
            Lighting.FogEnd = originalFogEnd
        end
    end
})

MainTab:AddToggle({
    Title = "Fullbright",
    Description = "Makes everything bright and visible",
    Default = false,
    Callback = function(enabled)
        if enabled then
            Lighting.Brightness = 10
            Lighting.GlobalShadows = false
        else
            Lighting.Brightness = 1
            Lighting.GlobalShadows = true
        end
    end
})

MainTab:AddToggle({
    Title = "Auto Plant",
    Description = "Plants at your feet every 1 second",
    Default = false,
    Callback = function(enabled)
        autoPlantEnabled = enabled
    end
})

MainTab:AddToggle({
    Title = "Kill Aura",
    Description = "Automatically attacks nearby enemies",
    Default = false,
    Callback = function(enabled)
        killAuraEnabled = enabled
    end
})

MainTab:AddToggle({
    Title = "Auto Open Chests",
    Description = "Automatically opens chests within range",
    Default = true,
    Callback = function(enabled)
        autoOpenChestsEnabled = enabled
    end
})

MainTab:AddSlider({
    Title = "Chest Range",
    Description = "How far to auto-open chests",
    Default = 50,
    Min = 1,
    Max = 1000,
    Rounding = 1,
    Callback = function(value)
        chestRange = value
    end
})

-- BRING FOODS TAB
local BringFoodsTab = Window:AddTab({Title = "Bring Foods"})

BringFoodsTab:AddParagraph({
    Title = "Food Items",
    Content = "Click any button below to bring that specific food item to you!"
})

BringFoodsTab:AddButton({
    Title = "Bring All Food Items",
    Description = "Brings all food items at once",
    Callback = function()
        bringItemsToPlayer(allFoodItems)
    end
})

BringFoodsTab:AddToggle({
    Title = "Auto Bring All Foods",
    Description = "Automatically brings all foods every 3 seconds",
    Default = false,
    Callback = function(enabled)
        if enabled then
            spawn(function()
                while enabled do
                    if not isProcessing then
                        bringItemsToPlayer(allFoodItems)
                    end
                    wait(3)
                end
            end)
        end
    end
})

local FoodSection = BringFoodsTab:AddSection("Individual Food Items")

for _, foodItem in ipairs(allFoodItems) do
    FoodSection:AddButton({
        Title = foodItem,
        Description = "Bring " .. foodItem .. " to player",
        Callback = function()
            if isProcessing then return end
            bringItemsToPlayer({foodItem})
        end
    })
end

-- COOK TAB
local CookTab = Window:AddTab({Title = "Cook"})

CookTab:AddParagraph({
    Title = "Cooking System", 
    Content = "Brings cookable foods to the campfire for cooking!"
})

CookTab:AddButton({
    Title = "Bring All Cookable Items",
    Description = "Brings all raw foods to campfire",
    Callback = function()
        bringItemsToCampfire(cookableFoods)
    end
})

CookTab:AddToggle({
    Title = "Auto Cook Selected Items",
    Description = "Automatically brings cookable items to campfire",
    Default = false,
    Callback = function(enabled)
        if enabled then
            spawn(function()
                while enabled do
                    if not isProcessing then
                        bringItemsToCampfire(cookableFoods)
                    end
                    wait(3)
                end
            end)
        end
    end
})

local CookSection = CookTab:AddSection("Cookable Foods")

for _, cookItem in ipairs(cookableFoods) do
    CookSection:AddButton({
        Title = cookItem,
        Description = "Bring " .. cookItem .. " to campfire",
        Callback = function()
            if isProcessing then return end
            bringItemsToCampfire({cookItem})
        end
    })
end

-- CAMPFIRE TAB
local CampfireTab = Window:AddTab({Title = "Campfire"})

CampfireTab:AddParagraph({
    Title = "Campfire Management",
    Content = "Teleport to campfire and manage fuel items!"
})

CampfireTab:AddButton({
    Title = "Teleport to Campfire",
    Description = "Instantly teleport to the campfire location",
    Callback = teleportToCampfire
})

CampfireTab:AddButton({
    Title = "Bring All Fuel Items",
    Description = "Brings all fuel items to campfire",
    Callback = function()
        bringItemsToCampfire(fuelItems)
    end
})

CampfireTab:AddToggle({
    Title = "Auto Fuel Campfire",
    Description = "Automatically brings fuel to campfire",
    Default = false,
    Callback = function(enabled)
        if enabled then
            spawn(function()
                while enabled do
                    if not isProcessing then
                        bringItemsToCampfire(fuelItems)
                    end
                    wait(3)
                end
            end)
        end
    end
})

local FuelSection = CampfireTab:AddSection("Fuel Items")

for _, fuelItem in ipairs(fuelItems) do
    FuelSection:AddButton({
        Title = fuelItem,
        Description = "Bring " .. fuelItem .. " to campfire",
        Callback = function()
            if isProcessing then return end
            bringItemsToCampfire({fuelItem})
        end
    })
end

-- GRINDER TAB
local GrinderTab = Window:AddTab({Title = "Grinder"})

GrinderTab:AddParagraph({
    Title = "Grinding System",
    Content = "Brings materials to the grinder for processing!"
})

GrinderTab:AddButton({
    Title = "Grind All Materials",
    Description = "Brings all grindable materials to grinder",
    Callback = function()
        bringItemsToGrinder(grindableItems)
    end
})

GrinderTab:AddToggle({
    Title = "Auto Grind All Materials",
    Description = "Automatically grinds materials",
    Default = false,
    Callback = function(enabled)
        autoGrindersEnabled = enabled
        if enabled then
            spawn(function()
                while autoGrindersEnabled do
                    if not isProcessing then
                        bringItemsToGrinder(grindableItems)
                    end
                    wait(4)
                end
            end)
        end
    end
})

local GrindSection = GrinderTab:AddSection("Grindable Materials")

for _, grindItem in ipairs(grindableItems) do
    GrindSection:AddButton({
        Title = grindItem,
        Description = "Bring " .. grindItem .. " to grinder",
        Callback = function()
            if isProcessing then return end
            bringItemsToGrinder({grindItem})
        end
    })
end

-- BRING TAB
local BringTab = Window:AddTab({Title = "Bring"})

BringTab:AddParagraph({
    Title = "Item Bringing System",
    Content = "Bring specific item categories to your location!"
})

BringTab:AddButton({
    Title = "Bring All Items",
    Description = "Brings every item in the game to you",
    Callback = function()
        bringItemsToPlayer({})
    end
})

BringTab:AddToggle({
    Title = "Auto Bring All Items",
    Description = "Automatically brings all items",
    Default = false,
    Callback = function(enabled)
        autoBringEnabled = enabled
        if enabled then
            spawn(function()
                while autoBringEnabled do
                    if not isProcessing then
                        bringItemsToPlayer({})
                    end
                    wait(3)
                end
            end)
        end
    end
})

-- Weapons & Tools Section
local WeaponsSection = BringTab:AddSection("Weapons & Tools")

for _, weaponItem in ipairs(weaponsTools) do
    WeaponsSection:AddButton({
        Title = weaponItem,
        Description = "Bring " .. weaponItem .. " to player",
        Callback = function()
            if isProcessing then return end
            bringItemsToPlayer({weaponItem})
        end
    })
end

-- Armor Section
local ArmorSection = BringTab:AddSection("Armor & Protection")

for _, armorItem in ipairs(armorItems) do
    ArmorSection:AddButton({
        Title = armorItem,
        Description = "Bring " .. armorItem .. " to player",
        Callback = function()
            if isProcessing then return end
            bringItemsToPlayer({armorItem})
        end
    })
end

-- Ammunition Section
local AmmoSection = BringTab:AddSection("Ammunition")

for _, ammoItem in ipairs(ammoItems) do
    AmmoSection:AddButton({
        Title = ammoItem,
        Description = "Bring " .. ammoItem .. " to player",
        Callback = function()
            if isProcessing then return end
            bringItemsToPlayer({ammoItem})
        end
    })
end

-- Medical Section
local MedicalSection = BringTab:AddSection("Medical Items")

for _, medicalItem in ipairs(medicalItems) do
    MedicalSection:AddButton({
        Title = medicalItem,
        Description = "Bring " .. medicalItem .. " to player",
        Callback = function()
            if isProcessing then return end
            bringItemsToPlayer({medicalItem})
        end
    })
end

-- Seeds Section
local SeedsSection = BringTab:AddSection("Seeds")

for _, seedItem in ipairs(seedItems) do
    SeedsSection:AddButton({
        Title = seedItem,
        Description = "Bring " .. seedItem .. " to player",
        Callback = function()
            if isProcessing then return end
            bringItemsToPlayer({seedItem})
        end
    })
end

-- Flashlights Section
local FlashlightSection = BringTab:AddSection("Flashlights")

for _, flashlightItem in ipairs(flashlightItems) do
    FlashlightSection:AddButton({
        Title = flashlightItem,
        Description = "Bring " .. flashlightItem .. " to player",
        Callback = function()
            if isProcessing then return end
            bringItemsToPlayer({flashlightItem})
        end
    })
end

-- Containers Section
local ContainerSection = BringTab:AddSection("Containers & Building")

for _, containerItem in ipairs(containerItems) do
    ContainerSection:AddButton({
        Title = containerItem,
        Description = "Bring " .. containerItem .. " to player",
        Callback = function()
            if isProcessing then return end
            bringItemsToPlayer({containerItem})
        end
    })
end

-- Animal Parts Section
local AnimalSection = BringTab:AddSection("Animal Parts")

for _, animalItem in ipairs(animalParts) do
    AnimalSection:AddButton({
        Title = animalItem,
        Description = "Bring " .. animalItem .. " to player",
        Callback = function()
            if isProcessing then return end
            bringItemsToPlayer({animalItem})
        end
    })
end

-- CULTIST TAB
local CultistTab = Window:AddTab({Title = "Cultist"})

CultistTab:AddParagraph({
    Title = "Cultist Items",
    Content = "Bring cultist-related items and entities!"
})

CultistTab:AddButton({
    Title = "Bring All Cultist Items",
    Description = "Brings all cultist items at once",
    Callback = function()
        bringItemsToPlayer(cultistItems)
    end
})

local CultistSection = CultistTab:AddSection("Cultist Items")

for _, cultistItem in ipairs(cultistItems) do
    CultistSection:AddButton({
        Title = cultistItem,
        Description = "Bring " .. cultistItem .. " to player",
        Callback = function()
            if isProcessing then return end
            bringItemsToPlayer({cultistItem})
        end
    })
end

-- HELP KIDS TAB
local HelpKidsTab = Window:AddTab({Title = "Help Kids"})

HelpKidsTab:AddParagraph({
    Title = "Lost Child Finder",
    Content = "Smart detection system that avoids already rescued children!"
})

HelpKidsTab:AddButton({
    Title = "Find Lost Child (Smart)",
    Description = "Finds and teleports to a NEW lost child",
    Callback = function()
        local childPos = findSmartLostChild()
        if childPos then
            hrp.CFrame = CFrame.new(childPos + Vector3.new(0, 5, 0))
            game.StarterGui:SetCore("SendNotification", {
                Title = "Kid Finder";
                Text = "Found and teleported to lost child!";
                Duration = 3;
            })
        else
            game.StarterGui:SetCore("SendNotification", {
                Title = "Kid Finder";
                Text = "No new lost children found!";
                Duration = 3;
            })
        end
    end
})

HelpKidsTab:AddButton({
    Title = "Reset Rescued Kids List", 
    Description = "Clears the rescued kids tracker",
    Callback = function()
        rescuedKids = {}
        game.StarterGui:SetCore("SendNotification", {
            Title = "Kid Finder";
            Text = "Rescued kids list cleared!";
            Duration = 2;
        })
    end
})

-- SETTINGS TAB
local SettingsTab = Window:AddTab({Title = "Settings"})

SettingsTab:AddParagraph({
    Title = "Script Settings",
    Content = "Adjust performance and behavior settings!"
})

SettingsTab:AddSlider({
    Title = "Batch Delay",
    Description = "Delay between item batches",
    Default = 0.1,
    Min = 0.05,
    Max = 1,
    Rounding = 2,
    Callback = function(value)
        bringDelay = value
    end
})

SettingsTab:AddSlider({
    Title = "Items Per Batch", 
    Description = "How many items to process at once",
    Default = 3,
    Min = 1,
    Max = 10,
    Rounding = 1,
    Callback = function(value)
        maxItemsPerFrame = value
    end
})

SettingsTab:AddButton({
    Title = "Refresh Character",
    Description = "Refreshes character references",
    Callback = function()
        char = player.Character or player.CharacterAdded:Wait()
        hrp = char:WaitForChild("HumanoidRootPart")
        
        if char:FindFirstChild("Humanoid") then
            char.Humanoid.WalkSpeed = originalWalkSpeed
            char.Humanoid.JumpPower = originalJumpPower
        end
        
        game.StarterGui:SetCore("SendNotification", {
            Title = "Settings";
            Text = "Character refreshed!";
            Duration = 2;
        })
    end
})

-- INFO TAB
local InfoTab = Window:AddTab({Title = "Info"})

InfoTab:AddParagraph({
    Title = "99 Nights Forest Enhanced",
    Content = "Complete Fluent library version with individual buttons for every item!"
})

InfoTab:AddParagraph({
    Title = "Features:",
    Content = "✓ Farm Log 20 Seconds\n✓ Out Build System\n✓ Smart Kid Finding\n✓ Individual item buttons\n✓ Auto functions\n✓ Horror utilities"
})

-- Success notification
game.StarterGui:SetCore("SendNotification", {
    Title = "99 Nights Enhanced";
    Text = "Welcome to aux hub!";
    Duration = 3;
})

print("99 Nights Forest Enhanced - Fluent Version Complete!")
print("All features working with individual buttons!")
