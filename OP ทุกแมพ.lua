loadstring(game:HttpGet('https://raw.githubusercontent.com/GhostPlayer352/UI-Library/refs/heads/main/Ghost%20Gui'))()

game.CoreGui.GhostGui.MainFrame.Title.Text = "NAOSCRIPT"

AddContent("TextButton", "วิ่งเร็ว ⚡", 

[[ loadstring(game:HttpGet("https://pastefy.app/i77XBf9D/raw",true))() ]])

AddContent("TextButton", "กระโดดไม่จำกัด 💪", 

[[ game:GetService("UserInputService").JumpRequest:connect(function()

        game:GetService"Players".LocalPlayer.Character:FindFirstChildOfClass'Humanoid':ChangeState("Jumping")       

    end) ]])


AddContent("TextButton", "มองทะลุ 👀", 

[[ loadstring(game:HttpGet("https://pastebin.com/raw/8mX3D6xp"))() ]])

AddContent("TextButton", "วาปหาคน 🌊", 

[[ loadstring(game:HttpGet("https://gist.githubusercontent.com/mewber/de2f65b1b408216461a73d7d2cee0057/raw/73d01cc9464fe61df1a6835c447df8e2e0571f53/Teleport"))() ]])

AddContent("TextButton", "เพิ่มแสง 🌞", 

[[ pcall(function()

    local lighting = game:GetService("Lighting");

    lighting.Ambient = Color3.fromRGB(255, 255, 255);

    lighting.Brightness = 1;

    lighting.FogEnd = 1e10;

    for i, v in pairs(lighting:GetDescendants()) do

        if v:IsA("BloomEffect") or v:IsA("BlurEffect") or v:IsA("ColorCorrectionEffect") or v:IsA("SunRaysEffect") then

            v.Enabled = false;

        end;

    end;

    lighting.Changed:Connect(function()

        lighting.Ambient = Color3.fromRGB(255, 255, 255);

        lighting.Brightness = 1;

        lighting.FogEnd = 1e10;

    end);

    spawn(function()

        local character = game:GetService("Players").LocalPlayer.Character;

        while wait() do

            repeat wait() until character ~= nil;

            if not character.HumanoidRootPart:FindFirstChildWhichIsA("PointLight") then

                local headlight = Instance.new("PointLight", character.HumanoidRootPart);

                headlight.Brightness = 1;

                headlight.Range = 60;

            end;

        end;

    end);

end) ]])

AddContent("TextButton", "แก้แลค 🍃", 

[[ local ToDisable = {

    Textures = true,

    VisualEffects = true,

    Parts = true,

    Particles = true,

    Sky = true

}

local ToEnable = {

    FullBright = false

}

local Stuff = {}

for _, v in next, game:GetDescendants() do

    if ToDisable.Parts then

        if v:IsA("Part") or v:IsA("Union") or v:IsA("BasePart") then

            v.Material = Enum.Material.SmoothPlastic

            table.insert(Stuff, 1, v)

        end

    end

    

    if ToDisable.Particles then

        if v:IsA("ParticleEmitter") or v:IsA("Smoke") or v:IsA("Explosion") or v:IsA("Sparkles") or v:IsA("Fire") then

            v.Enabled = false

            table.insert(Stuff, 1, v)

        end

    end

    

    if ToDisable.VisualEffects then

        if v:IsA("BloomEffect") or v:IsA("BlurEffect") or v:IsA("DepthOfFieldEffect") or v:IsA("SunRaysEffect") then

            v.Enabled = false

            table.insert(Stuff, 1, v)

        end

    end

    

    if ToDisable.Textures then

        if v:IsA("Decal") or v:IsA("Texture") then

            v.Texture = ""

            table.insert(Stuff, 1, v)

        end

    end

    

    if ToDisable.Sky then

        if v:IsA("Sky") then

            v.Parent = nil

            table.insert(Stuff, 1, v)

        end

    end

end

game:GetService("TestService"):Message("Effects Disabler Script : Successfully disabled "..#Stuff.." assets / effects. Settings :")

for i, v in next, ToDisable do

    print(tostring(i)..": "..tostring(v))

end

if ToEnable.FullBright then

    local Lighting = game:GetService("Lighting")

    

    Lighting.FogColor = Color3.fromRGB(255, 255, 255)

    Lighting.FogEnd = math.huge

    Lighting.FogStart = math.huge

    Lighting.Ambient = Color3.fromRGB(255, 255, 255)

    Lighting.Brightness = 5

    Lighting.ColorShift_Bottom = Color3.fromRGB(255, 255, 255)

    Lighting.ColorShift_Top = Color3.fromRGB(255, 255, 255)

    Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)

    Lighting.Outlines = true

end ]])

AddContent("TextButton", "ชิปล็อก 🔗", 

[[ loadstring(game:HttpGet("https://gist.githubusercontent.com/mewber/d38dfdf9043d2f7b282128496ca14aae/raw/67de2e03868f7de4c0d6e261912a7eef21d25719/Lock"))() ]])