--[[
    Enhanced Fluent Library - Complete Version
    Mobile + PC Dragging, Transparency, Working Buttons
    INCLUDES: Input, Paragraph, Keybind, Colorpicker, Slider, Toggle, Dropdown, Button, Section elements
    FIXED: Responsive Toggle and Dropdown sizes
]]--

local RunService = game:GetService("RunService")
local LocalPlayer = game:GetService("Players").LocalPlayer
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

-- Create GUI
local GUI = Instance.new("ScreenGui")
GUI.Name = "FluentLib_" .. math.random(1000,9999)
GUI.ResetOnSpawn = false

-- Protection
if gethui then
    GUI.Parent = gethui()
elseif syn and syn.protect_gui then
    syn.protect_gui(GUI)
    GUI.Parent = game:GetService("CoreGui")
elseif protectgui then 
    protectgui(GUI)
    GUI.Parent = game:GetService("CoreGui")
else
    GUI.Parent = game:GetService("CoreGui")
end

-- Theme with transparency
local Theme = {
    Background = Color3.fromRGB(20, 20, 20),
    Element = Color3.fromRGB(35, 35, 35),
    ElementBorder = Color3.fromRGB(55, 55, 55),
    Text = Color3.fromRGB(240, 240, 240),
    SubText = Color3.fromRGB(180, 180, 180),
    Accent = Color3.fromRGB(100, 150, 255),
    Hover = Color3.fromRGB(45, 45, 45),
    BackgroundTransparency = 0.1,
    ElementTransparency = 0.2
}

-- Library
local Library = {
    GUI = GUI,
    Connections = {},
    Windows = {},
    Options = {}
}

function Library:Round(Number, Factor)
    local Result = math.floor(Number/Factor + 0.5) * Factor
    return Factor == 1 and math.floor(Result) or Result
end

function Library:Tween(obj, props, time)
    time = time or 0.2
    local tween = TweenService:Create(obj, TweenInfo.new(time, Enum.EasingStyle.Quad), props)
    tween:Play()
    return tween
end

function Library:Connect(signal, callback)
    local connection = signal:Connect(callback)
    table.insert(self.Connections, connection)
    return connection
end

function Library:SafeCallback(callback, ...)
    if callback then
        local success, err = pcall(callback, ...)
        if not success then
            warn("Callback error:", err)
        end
    end
end

function Library:Destroy()
    for _, connection in pairs(self.Connections) do
        if connection then connection:Disconnect() end
    end
    if self.GUI then
        self.GUI:Destroy()
    end
end

-- Mobile + PC Drag Handler
local function MakeDraggable(frame, dragHandle)
    local dragging = false
    local dragStart = nil
    local startPos = nil

    local function startDrag(input)
        dragging = true
        dragStart = input.Position
        startPos = frame.Position
    end

    local function updateDrag(input)
        if dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end

    local function endDrag()
        dragging = false
    end

    -- Mouse support
    Library:Connect(dragHandle.InputBegan, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            startDrag(input)
        end
    end)

    -- Touch support
    Library:Connect(dragHandle.InputBegan, function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            startDrag(input)
        end
    end)

    -- Movement tracking
    Library:Connect(UserInputService.InputChanged, function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            updateDrag(input)
        end
    end)

    -- End tracking
    Library:Connect(UserInputService.InputEnded, function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            endDrag()
        end
    end)
end

function Library:CreateWindow(config)
    local Window = {}
    
    -- Main frame with transparency
    local Main = Instance.new("Frame")
    Main.Name = "Main"
    Main.Size = config.Size or UDim2.fromOffset(500, 400)
    Main.Position = UDim2.fromScale(0.5, 0.5)
    Main.AnchorPoint = Vector2.new(0.5, 0.5)
    Main.BackgroundColor3 = Theme.Background
    Main.BackgroundTransparency = Theme.BackgroundTransparency
    Main.BorderSizePixel = 0
    Main.Parent = GUI
    
    -- Corner
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 12)
    Corner.Parent = Main
    
    -- Stroke
    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Theme.ElementBorder
    Stroke.Thickness = 1
    Stroke.Transparency = 0.3
    Stroke.Parent = Main
    
    -- Title bar
    local TitleBar = Instance.new("Frame")
    TitleBar.Name = "TitleBar"
    TitleBar.Size = UDim2.new(1, 0, 0, 45)
    TitleBar.BackgroundTransparency = 1
    TitleBar.Parent = Main
    
    -- Title
    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Text = config.Title or "Window"
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 16
    Title.TextColor3 = Theme.Text
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Size = UDim2.new(1, -60, 1, 0)
    Title.Position = UDim2.fromOffset(20, 0)
    Title.BackgroundTransparency = 1
    Title.Parent = TitleBar
    
    -- Close button
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Name = "Close"
    CloseBtn.Size = UDim2.fromOffset(32, 32)
    CloseBtn.Position = UDim2.new(1, -40, 0, 6)
    CloseBtn.BackgroundColor3 = Theme.Element
    CloseBtn.BackgroundTransparency = Theme.ElementTransparency
    CloseBtn.Text = "×"
    CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseBtn.TextSize = 20
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.BorderSizePixel = 0
    CloseBtn.Parent = TitleBar
    
    local CloseBtnCorner = Instance.new("UICorner")
    CloseBtnCorner.CornerRadius = UDim.new(0, 8)
    CloseBtnCorner.Parent = CloseBtn
    
    -- Squircle button at top of screen (hidden initially)
local SquircleBtn = Instance.new("TextButton")
SquircleBtn.Name = "SquircleOpen"
SquircleBtn.Size = UDim2.fromOffset(100, 30)
SquircleBtn.Position = UDim2.new(0.5, -50, 0, 10)
SquircleBtn.BackgroundColor3 = Theme.Background
SquircleBtn.BackgroundTransparency = Theme.BackgroundTransparency
SquircleBtn.Text = "Open"
SquircleBtn.TextColor3 = Theme.Text
SquircleBtn.TextSize = 14
SquircleBtn.Font = Enum.Font.GothamMedium
SquircleBtn.BorderSizePixel = 0
SquircleBtn.Visible = false
SquircleBtn.Parent = GUI

local SquircleCorner = Instance.new("UICorner")
SquircleCorner.CornerRadius = UDim.new(0, 15)
SquircleCorner.Parent = SquircleBtn

-- Close functionality (now minimizes to squircle)
Library:Connect(CloseBtn.MouseButton1Click, function()
    Main.Visible = false
    SquircleBtn.Visible = true
end)

-- Squircle click to restore window
Library:Connect(SquircleBtn.MouseButton1Click, function()
    SquircleBtn.Visible = false
    Main.Visible = true
end)
    
    -- Make draggable (Mobile + PC)
    MakeDraggable(Main, TitleBar)
    
    -- Tab container with transparency
    local TabContainer = Instance.new("Frame")
    TabContainer.Name = "TabContainer"
    TabContainer.Size = UDim2.new(0, 160, 1, -55)
    TabContainer.Position = UDim2.fromOffset(10, 50)
    TabContainer.BackgroundTransparency = 1
    TabContainer.Parent = Main
    
    local TabList = Instance.new("UIListLayout")
    TabList.Padding = UDim.new(0, 6)
    TabList.Parent = TabContainer
    
    local TabPadding = Instance.new("UIPadding")
    TabPadding.PaddingTop = UDim.new(0, 5)
    TabPadding.PaddingBottom = UDim.new(0, 5)
    TabPadding.PaddingLeft = UDim.new(0, 5)
    TabPadding.PaddingRight = UDim.new(0, 5)
    TabPadding.Parent = TabContainer
    
    -- Content area with transparency
    local ContentArea = Instance.new("Frame")
    ContentArea.Name = "ContentArea"
    ContentArea.Size = UDim2.new(1, -190, 1, -90)
    ContentArea.Position = UDim2.fromOffset(180, 70)
    ContentArea.BackgroundTransparency = 1
    ContentArea.Parent = Main
    
    -- Tab display
    local TabDisplay = Instance.new("TextLabel")
    TabDisplay.Name = "TabDisplay"
    TabDisplay.Text = "Tab"
    TabDisplay.Font = Enum.Font.GothamBold
    TabDisplay.TextSize = 20
    TabDisplay.TextColor3 = Theme.Text
    TabDisplay.TextXAlignment = Enum.TextXAlignment.Left
    TabDisplay.Size = UDim2.new(1, 0, 0, 25)
    TabDisplay.Position = UDim2.fromOffset(180, 50)
    TabDisplay.BackgroundTransparency = 1
    TabDisplay.Parent = Main
    
    Window.Main = Main
    Window.TabContainer = TabContainer
    Window.ContentArea = ContentArea
    Window.TabDisplay = TabDisplay
    Window.Tabs = {}
    Window.CurrentTab = nil
    
    function Window:AddTab(config)
        local Tab = {}
        local TabName = config.Title or "Tab"
        
        -- Tab button with transparency
        local TabBtn = Instance.new("TextButton")
        TabBtn.Name = TabName
        TabBtn.Size = UDim2.new(1, 0, 0, 38)
        TabBtn.BackgroundColor3 = Theme.Element
        TabBtn.BackgroundTransparency = Theme.ElementTransparency
        TabBtn.Text = TabName
        TabBtn.TextColor3 = Theme.Text
        TabBtn.TextSize = 13
        TabBtn.Font = Enum.Font.GothamMedium
        TabBtn.BorderSizePixel = 0
        TabBtn.Parent = self.TabContainer
        
        local TabCorner = Instance.new("UICorner")
        TabCorner.CornerRadius = UDim.new(0, 8)
        TabCorner.Parent = TabBtn
        
        local TabStroke = Instance.new("UIStroke")
        TabStroke.Color = Theme.ElementBorder
        TabStroke.Transparency = 0.6
        TabStroke.Parent = TabBtn
        
        -- Tab content with transparency
        local TabContent = Instance.new("ScrollingFrame")
        TabContent.Name = TabName .. "Content"
        TabContent.Size = UDim2.fromScale(1, 1)
        TabContent.BackgroundTransparency = 1
        TabContent.BorderSizePixel = 0
        TabContent.ScrollBarThickness = 6
        TabContent.ScrollBarImageColor3 = Theme.Accent
        TabContent.ScrollBarImageTransparency = 0.3
        TabContent.CanvasSize = UDim2.fromScale(0, 0)
        TabContent.Visible = false
        TabContent.Parent = self.ContentArea
        
        local ContentList = Instance.new("UIListLayout")
        ContentList.Padding = UDim.new(0, 10)
        ContentList.Parent = TabContent
        
        local ContentPadding = Instance.new("UIPadding")
        ContentPadding.PaddingTop = UDim.new(0, 12)
        ContentPadding.PaddingBottom = UDim.new(0, 12)
        ContentPadding.PaddingLeft = UDim.new(0, 12)
        ContentPadding.PaddingRight = UDim.new(0, 12)
        ContentPadding.Parent = TabContent
        
        -- Auto resize content
        Library:Connect(ContentList:GetPropertyChangedSignal("AbsoluteContentSize"), function()
            TabContent.CanvasSize = UDim2.new(0, 0, 0, ContentList.AbsoluteContentSize.Y + 30)
        end)
        
        -- Tab click functionality
        Library:Connect(TabBtn.MouseButton1Click, function()
            -- Hide all tabs
            for _, tab in pairs(self.Tabs) do
                tab.Content.Visible = false
                tab.Button.BackgroundColor3 = Theme.Element
                tab.Button.BackgroundTransparency = Theme.ElementTransparency
            end
            
            -- Show this tab
            TabContent.Visible = true
            TabBtn.BackgroundColor3 = Theme.Hover
            TabBtn.BackgroundTransparency = 0.1
            self.TabDisplay.Text = TabName
            self.CurrentTab = Tab
        end)
        
        -- Hover effects
        Library:Connect(TabBtn.MouseEnter, function()
            if self.CurrentTab ~= Tab then
                Library:Tween(TabBtn, {BackgroundTransparency = 0.1}, 0.15)
            end
        end)
        
        Library:Connect(TabBtn.MouseLeave, function()
            if self.CurrentTab ~= Tab then
                Library:Tween(TabBtn, {BackgroundTransparency = Theme.ElementTransparency}, 0.15)
            end
        end)
        
        Tab.Button = TabBtn
        Tab.Content = TabContent
        Tab.Name = TabName
        Tab.Container = TabContent
        Tab.Library = Library
        
        -- ADD KEYBIND FUNCTION TO TAB
        function Tab:AddKeybind(config)
            local Keybind = {}
            local Idx = config.Title or "Keybind_" .. math.random(1000, 9999)
            
            assert(config.Title, "Keybind - Missing Title")
            assert(config.Default, "Keybind - Missing default value.")
            config.Mode = config.Mode or "Toggle"
            config.Callback = config.Callback or function() end
            
            -- Keybind frame
            local KeybindFrame = Instance.new("Frame")
            KeybindFrame.Name = config.Title or "Keybind"
            KeybindFrame.Size = UDim2.new(1, 0, 0, config.Description and 70 or 50)
            KeybindFrame.BackgroundColor3 = Theme.Element
            KeybindFrame.BackgroundTransparency = Theme.ElementTransparency
            KeybindFrame.BorderSizePixel = 0
            KeybindFrame.Parent = TabContent
            
            local KeybindCorner = Instance.new("UICorner")
            KeybindCorner.CornerRadius = UDim.new(0, 8)
            KeybindCorner.Parent = KeybindFrame
            
            local KeybindStroke = Instance.new("UIStroke")
            KeybindStroke.Color = Theme.ElementBorder
            KeybindStroke.Transparency = 0.5
            KeybindStroke.Parent = KeybindFrame
            
            -- Title
            local KeybindTitle = Instance.new("TextLabel")
            KeybindTitle.Text = config.Title or "Keybind"
            KeybindTitle.Font = Enum.Font.GothamMedium
            KeybindTitle.TextSize = 14
            KeybindTitle.TextColor3 = Theme.Text
            KeybindTitle.TextXAlignment = Enum.TextXAlignment.Left
            KeybindTitle.Size = UDim2.new(1, -120, 0, 18)
            KeybindTitle.Position = UDim2.fromOffset(12, config.Description and 8 or 16)
            KeybindTitle.BackgroundTransparency = 1
            KeybindTitle.Parent = KeybindFrame
            
            -- Description
            if config.Description then
                local KeybindDesc = Instance.new("TextLabel")
                KeybindDesc.Text = config.Description
                KeybindDesc.Font = Enum.Font.Gotham
                KeybindDesc.TextSize = 12
                KeybindDesc.TextColor3 = Theme.SubText
                KeybindDesc.TextXAlignment = Enum.TextXAlignment.Left
                KeybindDesc.Size = UDim2.new(1, -120, 0, 16)
                KeybindDesc.Position = UDim2.fromOffset(12, 28)
                KeybindDesc.BackgroundTransparency = 1
                KeybindDesc.TextWrapped = true
                KeybindDesc.Parent = KeybindFrame
            end
            
            -- Keybind display button
            local KeybindDisplay = Instance.new("TextButton")
            KeybindDisplay.Size = UDim2.fromOffset(100, 30)
            KeybindDisplay.Position = UDim2.new(1, -110, 0.5, -15)
            KeybindDisplay.BackgroundColor3 = Theme.Background
            KeybindDisplay.BackgroundTransparency = 0.2
            KeybindDisplay.Text = config.Default or "None"
            KeybindDisplay.TextColor3 = Theme.Text
            KeybindDisplay.TextSize = 12
            KeybindDisplay.Font = Enum.Font.Gotham
            KeybindDisplay.BorderSizePixel = 0
            KeybindDisplay.Parent = KeybindFrame
            
            local DisplayCorner = Instance.new("UICorner")
            DisplayCorner.CornerRadius = UDim.new(0, 6)
            DisplayCorner.Parent = KeybindDisplay
            
            local DisplayStroke = Instance.new("UIStroke")
            DisplayStroke.Color = Theme.ElementBorder
            DisplayStroke.Transparency = 0.6
            DisplayStroke.Parent = KeybindDisplay
            
            -- Keybind object
            Keybind = {
                Value = config.Default,
                Toggled = false,
                Mode = config.Mode,
                Type = "Keybind",
                Callback = config.Callback,
                ChangedCallback = config.ChangedCallback or function() end,
                Changed = nil,
                Frame = KeybindFrame
            }
            
            local Picking = false
            
            -- Get state function
            function Keybind:GetState()
                if UserInputService:GetFocusedTextBox() and Keybind.Mode ~= "Always" then
                    return false
                end
                
                if Keybind.Mode == "Always" then
                    return true
                elseif Keybind.Mode == "Hold" then
                    if Keybind.Value == "None" then
                        return false
                    end
                    
                    local Key = Keybind.Value
                    
                    if Key == "MouseLeft" or Key == "MouseRight" then
                        return Key == "MouseLeft" and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)
                            or Key == "MouseRight" and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
                    else
                        return UserInputService:IsKeyDown(Enum.KeyCode[Keybind.Value])
                    end
                else
                    return Keybind.Toggled
                end
            end
            
            -- Set value function
            function Keybind:SetValue(Key, Mode)
                Key = Key or Keybind.Value
                Mode = Mode or Keybind.Mode
                
                KeybindDisplay.Text = Key
                Keybind.Value = Key
                Keybind.Mode = Mode
            end
            
            function Keybind:OnClick(Callback)
                Keybind.Clicked = Callback
            end
            
            function Keybind:OnChanged(Callback)
                Keybind.Changed = Callback
                Callback(Keybind.Value)
            end
            
            function Keybind:DoClick()
                Library:SafeCallback(Keybind.Callback, Keybind.Toggled)
                if Keybind.Clicked then
                    Library:SafeCallback(Keybind.Clicked, Keybind.Toggled)
                end
            end
            
            function Keybind:Destroy()
                KeybindFrame:Destroy()
                Library.Options[Idx] = nil
            end
            
            -- Key picking functionality
            Library:Connect(KeybindDisplay.MouseButton1Click, function()
                Picking = true
                KeybindDisplay.Text = "..."
                
                wait(0.2)
                
                local Event
                Event = UserInputService.InputBegan:Connect(function(Input)
                    local Key
                    
                    if Input.UserInputType == Enum.UserInputType.Keyboard then
                        Key = Input.KeyCode.Name
                    elseif Input.UserInputType == Enum.UserInputType.MouseButton1 then
                        Key = "MouseLeft"
                    elseif Input.UserInputType == Enum.UserInputType.MouseButton2 then
                        Key = "MouseRight"
                    end
                    
                    local EndedEvent
                    EndedEvent = UserInputService.InputEnded:Connect(function(Input)
                        if (Input.KeyCode.Name == Key) or 
                           (Key == "MouseLeft" and Input.UserInputType == Enum.UserInputType.MouseButton1) or
                           (Key == "MouseRight" and Input.UserInputType == Enum.UserInputType.MouseButton2) then
                            Picking = false
                            
                            KeybindDisplay.Text = Key
                            Keybind.Value = Key
                            
                            Library:SafeCallback(Keybind.ChangedCallback, Input.KeyCode or Input.UserInputType)
                            if Keybind.Changed then
                                Library:SafeCallback(Keybind.Changed, Input.KeyCode or Input.UserInputType)
                            end
                            
                            Event:Disconnect()
                            EndedEvent:Disconnect()
                        end
                    end)
                end)
            end)
            
            -- Key activation functionality
            Library:Connect(UserInputService.InputBegan, function(Input)
                if not Picking and not UserInputService:GetFocusedTextBox() then
                    if Keybind.Mode == "Toggle" then
                        local Key = Keybind.Value
                        
                        if Key == "MouseLeft" or Key == "MouseRight" then
                            if (Key == "MouseLeft" and Input.UserInputType == Enum.UserInputType.MouseButton1) or
                               (Key == "MouseRight" and Input.UserInputType == Enum.UserInputType.MouseButton2) then
                                Keybind.Toggled = not Keybind.Toggled
                                Keybind:DoClick()
                            end
                        elseif Input.UserInputType == Enum.UserInputType.Keyboard then
                            if Input.KeyCode.Name == Key then
                                Keybind.Toggled = not Keybind.Toggled
                                Keybind:DoClick()
                            end
                        end
                    end
                end
            end)
            
            -- Focus effects
            Library:Connect(KeybindDisplay.MouseEnter, function()
                Library:Tween(DisplayStroke, {Color = Theme.Accent, Transparency = 0.3}, 0.2)
            end)
            
            Library:Connect(KeybindDisplay.MouseLeave, function()
                Library:Tween(DisplayStroke, {Color = Theme.ElementBorder, Transparency = 0.6}, 0.2)
            end)
            
            Library.Options[Idx] = Keybind
            return Keybind
        end
        
        -- ADD COLORPICKER FUNCTION TO TAB
        function Tab:AddColorpicker(config)
            local Colorpicker = {}
            local Idx = config.Title or "Colorpicker_" .. math.random(1000, 9999)
            
            assert(config.Title, "Colorpicker - Missing Title")
            assert(config.Default, "Colorpicker - Missing default value.")
            config.Transparency = config.Transparency or 0
            config.Callback = config.Callback or function() end
            
            -- Colorpicker frame
            local ColorpickerFrame = Instance.new("TextButton")
            ColorpickerFrame.Name = config.Title or "Colorpicker"
            ColorpickerFrame.Size = UDim2.new(1, 0, 0, config.Description and 70 or 50)
            ColorpickerFrame.BackgroundColor3 = Theme.Element
            ColorpickerFrame.BackgroundTransparency = Theme.ElementTransparency
            ColorpickerFrame.Text = ""
            ColorpickerFrame.BorderSizePixel = 0
            ColorpickerFrame.Parent = TabContent
            
            local ColorpickerCorner = Instance.new("UICorner")
            ColorpickerCorner.CornerRadius = UDim.new(0, 8)
            ColorpickerCorner.Parent = ColorpickerFrame
            
            local ColorpickerStroke = Instance.new("UIStroke")
            ColorpickerStroke.Color = Theme.ElementBorder
            ColorpickerStroke.Transparency = 0.5
            ColorpickerStroke.Parent = ColorpickerFrame
            
            -- Title
            local ColorpickerTitle = Instance.new("TextLabel")
            ColorpickerTitle.Text = config.Title or "Colorpicker"
            ColorpickerTitle.Font = Enum.Font.GothamMedium
            ColorpickerTitle.TextSize = 14
            ColorpickerTitle.TextColor3 = Theme.Text
            ColorpickerTitle.TextXAlignment = Enum.TextXAlignment.Left
            ColorpickerTitle.Size = UDim2.new(1, -80, 0, 18)
            ColorpickerTitle.Position = UDim2.fromOffset(12, config.Description and 8 or 16)
            ColorpickerTitle.BackgroundTransparency = 1
            ColorpickerTitle.Parent = ColorpickerFrame
            
            -- Description
            if config.Description then
                local ColorpickerDesc = Instance.new("TextLabel")
                ColorpickerDesc.Text = config.Description
                ColorpickerDesc.Font = Enum.Font.Gotham
                ColorpickerDesc.TextSize = 12
                ColorpickerDesc.TextColor3 = Theme.SubText
                ColorpickerDesc.TextXAlignment = Enum.TextXAlignment.Left
                ColorpickerDesc.Size = UDim2.new(1, -80, 0, 16)
                ColorpickerDesc.Position = UDim2.fromOffset(12, 28)
                ColorpickerDesc.BackgroundTransparency = 1
                ColorpickerDesc.TextWrapped = true
                ColorpickerDesc.Parent = ColorpickerFrame
            end
            
            -- Color display
            local ColorDisplayChecker = Instance.new("ImageLabel")
            ColorDisplayChecker.Size = UDim2.fromOffset(60, 30)
            ColorDisplayChecker.Position = UDim2.new(1, -70, 0.5, -15)
            ColorDisplayChecker.Image = "http://www.roblox.com/asset/?id=14204231522"
            ColorDisplayChecker.ImageTransparency = 0.45
            ColorDisplayChecker.ScaleType = Enum.ScaleType.Tile
            ColorDisplayChecker.TileSize = UDim2.fromOffset(40, 40)
            ColorDisplayChecker.BackgroundTransparency = 1
            ColorDisplayChecker.Parent = ColorpickerFrame
            
            local ColorDisplayCorner = Instance.new("UICorner")
            ColorDisplayCorner.CornerRadius = UDim.new(0, 6)
            ColorDisplayCorner.Parent = ColorDisplayChecker
            
            local ColorDisplay = Instance.new("Frame")
            ColorDisplay.Size = UDim2.fromScale(1, 1)
            ColorDisplay.BackgroundColor3 = config.Default
            ColorDisplay.BackgroundTransparency = config.Transparency
            ColorDisplay.BorderSizePixel = 0
            ColorDisplay.Parent = ColorDisplayChecker
            
            local ColorDisplayCornerInner = Instance.new("UICorner")
            ColorDisplayCornerInner.CornerRadius = UDim.new(0, 6)
            ColorDisplayCornerInner.Parent = ColorDisplay
            
            -- Colorpicker object
            Colorpicker = {
                Value = config.Default,
                Transparency = config.Transparency,
                Type = "Colorpicker",
                Title = config.Title,
                Callback = config.Callback,
                Changed = nil,
                Frame = ColorpickerFrame,
                Hue = 0,
                Sat = 0,
                Vib = 0
            }
            
            function Colorpicker:SetHSVFromRGB(Color)
                local H, S, V = Color3.toHSV(Color)
                Colorpicker.Hue = H
                Colorpicker.Sat = S
                Colorpicker.Vib = V
            end
            
            Colorpicker:SetHSVFromRGB(Colorpicker.Value)
            
            function Colorpicker:Display()
                Colorpicker.Value = Color3.fromHSV(Colorpicker.Hue, Colorpicker.Sat, Colorpicker.Vib)
                
                ColorDisplay.BackgroundColor3 = Colorpicker.Value
                ColorDisplay.BackgroundTransparency = Colorpicker.Transparency
                
                Library:SafeCallback(Colorpicker.Callback, Colorpicker.Value)
                if Colorpicker.Changed then
                    Library:SafeCallback(Colorpicker.Changed, Colorpicker.Value)
                end
            end
            
            function Colorpicker:SetValue(HSV, Transparency)
                local Color = Color3.fromHSV(HSV[1], HSV[2], HSV[3])
                
                Colorpicker.Transparency = Transparency or 0
                Colorpicker:SetHSVFromRGB(Color)
                Colorpicker:Display()
            end
            
            function Colorpicker:SetValueRGB(Color, Transparency)
                Colorpicker.Transparency = Transparency or 0
                Colorpicker:SetHSVFromRGB(Color)
                Colorpicker:Display()
            end
            
            function Colorpicker:OnChanged(Func)
                Colorpicker.Changed = Func
                Func(Colorpicker.Value)
            end
            
            function Colorpicker:Destroy()
                ColorpickerFrame:Destroy()
                Library.Options[Idx] = nil
            end
            
            -- Create color dialog function
            local function CreateColorDialog()
                -- Simple color dialog implementation
                local Dialog = Instance.new("Frame")
                Dialog.Name = "ColorDialog"
                Dialog.Size = UDim2.fromOffset(300, 250)
                Dialog.Position = UDim2.fromScale(0.5, 0.5)
                Dialog.AnchorPoint = Vector2.new(0.5, 0.5)
                Dialog.BackgroundColor3 = Theme.Background
                Dialog.BackgroundTransparency = Theme.BackgroundTransparency
                Dialog.BorderSizePixel = 0
                Dialog.Parent = GUI
                Dialog.ZIndex = 1000
                
                local DialogCorner = Instance.new("UICorner")
                DialogCorner.CornerRadius = UDim.new(0, 12)
                DialogCorner.Parent = Dialog
                
                local DialogStroke = Instance.new("UIStroke")
                DialogStroke.Color = Theme.ElementBorder
                DialogStroke.Thickness = 1
                DialogStroke.Transparency = 0.3
                DialogStroke.Parent = Dialog
                
                -- Dialog title
                local DialogTitle = Instance.new("TextLabel")
                DialogTitle.Text = Colorpicker.Title
                DialogTitle.Font = Enum.Font.GothamBold
                DialogTitle.TextSize = 16
                DialogTitle.TextColor3 = Theme.Text
                DialogTitle.TextXAlignment = Enum.TextXAlignment.Left
                DialogTitle.Size = UDim2.new(1, -60, 0, 30)
                DialogTitle.Position = UDim2.fromOffset(15, 10)
                DialogTitle.BackgroundTransparency = 1
                DialogTitle.Parent = Dialog
                
                -- Close button
                local CloseDialogBtn = Instance.new("TextButton")
                CloseDialogBtn.Size = UDim2.fromOffset(25, 25)
                CloseDialogBtn.Position = UDim2.new(1, -35, 0, 10)
                CloseDialogBtn.BackgroundColor3 = Color3.fromRGB(255, 85, 85)
                CloseDialogBtn.BackgroundTransparency = 0.1
                CloseDialogBtn.Text = "×"
                CloseDialogBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                CloseDialogBtn.TextSize = 16
                CloseDialogBtn.Font = Enum.Font.GothamBold
                CloseDialogBtn.BorderSizePixel = 0
                CloseDialogBtn.Parent = Dialog
                
                local CloseDialogCorner = Instance.new("UICorner")
                CloseDialogCorner.CornerRadius = UDim.new(0, 6)
                CloseDialogCorner.Parent = CloseDialogBtn
                
                -- Color presets
                local PresetColors = {
                    Color3.fromRGB(255, 0, 0),   -- Red
                    Color3.fromRGB(255, 165, 0), -- Orange
                    Color3.fromRGB(255, 255, 0), -- Yellow
                    Color3.fromRGB(0, 255, 0),   -- Green
                    Color3.fromRGB(0, 255, 255), -- Cyan
                    Color3.fromRGB(0, 0, 255),   -- Blue
                    Color3.fromRGB(128, 0, 128), -- Purple
                    Color3.fromRGB(255, 192, 203), -- Pink
                }
                
                local ColorGrid = Instance.new("Frame")
                ColorGrid.Size = UDim2.new(1, -30, 0, 100)
                ColorGrid.Position = UDim2.fromOffset(15, 50)
                ColorGrid.BackgroundTransparency = 1
                ColorGrid.Parent = Dialog
                
                local GridLayout = Instance.new("UIGridLayout")
                GridLayout.CellSize = UDim2.fromOffset(30, 30)
                GridLayout.CellPadding = UDim2.fromOffset(5, 5)
                GridLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
                GridLayout.Parent = ColorGrid
                
                for _, color in pairs(PresetColors) do
                    local ColorBtn = Instance.new("TextButton")
                    ColorBtn.Size = UDim2.fromOffset(30, 30)
                    ColorBtn.BackgroundColor3 = color
                    ColorBtn.Text = ""
                    ColorBtn.BorderSizePixel = 0
                    ColorBtn.Parent = ColorGrid
                    
                    local ColorBtnCorner = Instance.new("UICorner")
                    ColorBtnCorner.CornerRadius = UDim.new(0, 6)
                    ColorBtnCorner.Parent = ColorBtn
                    
                    Library:Connect(ColorBtn.MouseButton1Click, function()
                        Colorpicker:SetHSVFromRGB(color)
                        Colorpicker:Display()
                        Dialog:Destroy()
                    end)
                end
                
                -- Done button
                local DoneBtn = Instance.new("TextButton")
                DoneBtn.Size = UDim2.fromOffset(80, 30)
                DoneBtn.Position = UDim2.new(1, -95, 1, -40)
                DoneBtn.BackgroundColor3 = Theme.Accent
                DoneBtn.BackgroundTransparency = 0.1
                DoneBtn.Text = "Done"
                DoneBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                DoneBtn.TextSize = 14
                DoneBtn.Font = Enum.Font.GothamMedium
                DoneBtn.BorderSizePixel = 0
                DoneBtn.Parent = Dialog
                
                local DoneBtnCorner = Instance.new("UICorner")
                DoneBtnCorner.CornerRadius = UDim.new(0, 6)
                DoneBtnCorner.Parent = DoneBtn
                
                Library:Connect(DoneBtn.MouseButton1Click, function()
                    Dialog:Destroy()
                end)
                
                Library:Connect(CloseDialogBtn.MouseButton1Click, function()
                    Dialog:Destroy()
                end)
                
                -- Make dialog draggable
                MakeDraggable(Dialog, Dialog)
            end
            
            -- Click to open dialog
            Library:Connect(ColorpickerFrame.MouseButton1Click, function()
                CreateColorDialog()
            end)
            
            -- Hover effects
            Library:Connect(ColorpickerFrame.MouseEnter, function()
                Library:Tween(ColorpickerFrame, {BackgroundTransparency = 0.05}, 0.15)
            end)
            
            Library:Connect(ColorpickerFrame.MouseLeave, function()
                Library:Tween(ColorpickerFrame, {BackgroundTransparency = Theme.ElementTransparency}, 0.15)
            end)
            
            Colorpicker:Display()
            
            Library.Options[Idx] = Colorpicker
            return Colorpicker
        end
        
        -- ADD SLIDER FUNCTION TO TAB
        function Tab:AddSlider(config)
            local Slider = {}
            local Idx = config.Title or "Slider_" .. math.random(1000, 9999)
            
            assert(config.Title, "Slider - Missing Title.")
            assert(config.Default, "Slider - Missing default value.")
            assert(config.Min, "Slider - Missing minimum value.")
            assert(config.Max, "Slider - Missing maximum value.")
            assert(config.Rounding, "Slider - Missing rounding value.")
            config.Callback = config.Callback or function() end
            
            -- Slider frame
            local SliderFrame = Instance.new("Frame")
            SliderFrame.Name = config.Title or "Slider"
            SliderFrame.Size = UDim2.new(1, 0, 0, config.Description and 70 or 50)
            SliderFrame.BackgroundColor3 = Theme.Element
            SliderFrame.BackgroundTransparency = Theme.ElementTransparency
            SliderFrame.BorderSizePixel = 0
            SliderFrame.Parent = TabContent
            
            local SliderCorner = Instance.new("UICorner")
            SliderCorner.CornerRadius = UDim.new(0, 8)
            SliderCorner.Parent = SliderFrame
            
            local SliderStroke = Instance.new("UIStroke")
            SliderStroke.Color = Theme.ElementBorder
            SliderStroke.Transparency = 0.5
            SliderStroke.Parent = SliderFrame
            
            -- Title
            local SliderTitle = Instance.new("TextLabel")
            SliderTitle.Text = config.Title or "Slider"
            SliderTitle.Font = Enum.Font.GothamMedium
            SliderTitle.TextSize = 14
            SliderTitle.TextColor3 = Theme.Text
            SliderTitle.TextXAlignment = Enum.TextXAlignment.Left
            SliderTitle.Size = UDim2.new(1, -170, 0, 18)
            SliderTitle.Position = UDim2.fromOffset(12, config.Description and 8 or 16)
            SliderTitle.BackgroundTransparency = 1
            SliderTitle.Parent = SliderFrame
            
            -- Description
            if config.Description then
                local SliderDesc = Instance.new("TextLabel")
                SliderDesc.Text = config.Description
                SliderDesc.Font = Enum.Font.Gotham
                SliderDesc.TextSize = 12
                SliderDesc.TextColor3 = Theme.SubText
                SliderDesc.TextXAlignment = Enum.TextXAlignment.Left
                SliderDesc.Size = UDim2.new(1, -170, 0, 16)
                SliderDesc.Position = UDim2.fromOffset(12, 28)
                SliderDesc.BackgroundTransparency = 1
                SliderDesc.TextWrapped = true
                SliderDesc.Parent = SliderFrame
            end
            
            -- Value display
            local ValueDisplay = Instance.new("TextLabel")
            ValueDisplay.Text = tostring(config.Default)
            ValueDisplay.Font = Enum.Font.Gotham
            ValueDisplay.TextSize = 12
            ValueDisplay.TextColor3 = Theme.SubText
            ValueDisplay.TextXAlignment = Enum.TextXAlignment.Right
            ValueDisplay.Size = UDim2.fromOffset(50, 14)
            ValueDisplay.Position = UDim2.new(1, -60, 0, config.Description and 8 or 16)
            ValueDisplay.BackgroundTransparency = 1
            ValueDisplay.Parent = SliderFrame
            
            -- Slider container
            local SliderContainer = Instance.new("Frame")
            SliderContainer.Size = UDim2.fromOffset(150, 4)
            SliderContainer.Position = UDim2.new(1, -160, 1, config.Description and -15 or -17)
            SliderContainer.BackgroundColor3 = Theme.ElementBorder
            SliderContainer.BackgroundTransparency = 0.4
            SliderContainer.BorderSizePixel = 0
            SliderContainer.Parent = SliderFrame
            
            local SliderContainerCorner = Instance.new("UICorner")
            SliderContainerCorner.CornerRadius = UDim.new(1, 0)
            SliderContainerCorner.Parent = SliderContainer
            
            -- Slider fill
            local SliderFill = Instance.new("Frame")
            SliderFill.Size = UDim2.fromScale(0, 1)
            SliderFill.BackgroundColor3 = Theme.Accent
            SliderFill.BorderSizePixel = 0
            SliderFill.Parent = SliderContainer
            
            local SliderFillCorner = Instance.new("UICorner")
            SliderFillCorner.CornerRadius = UDim.new(1, 0)
            SliderFillCorner.Parent = SliderFill
            
            -- Slider dot
            local SliderDot = Instance.new("Frame")
            SliderDot.Size = UDim2.fromOffset(12, 12)
            SliderDot.Position = UDim2.new(0, -6, 0.5, -6)
            SliderDot.BackgroundColor3 = Theme.Accent
            SliderDot.BorderSizePixel = 0
            SliderDot.Parent = SliderContainer
            
            local SliderDotCorner = Instance.new("UICorner")
            SliderDotCorner.CornerRadius = UDim.new(1, 0)
            SliderDotCorner.Parent = SliderDot
            
            -- Slider object
            Slider = {
                Value = config.Default,
                Min = config.Min,
                Max = config.Max,
                Rounding = config.Rounding,
                Callback = config.Callback,
                Type = "Slider",
                Changed = nil,
                Frame = SliderFrame
            }
            
            local Dragging = false
            
            function Slider:OnChanged(Func)
                Slider.Changed = Func
                Func(Slider.Value)
            end
            
            function Slider:SetValue(Value)
                self.Value = Library:Round(math.clamp(Value, Slider.Min, Slider.Max), Slider.Rounding)
                
                local Percent = (self.Value - Slider.Min) / (Slider.Max - Slider.Min)
                SliderDot.Position = UDim2.new(Percent, -6, 0.5, -6)
                SliderFill.Size = UDim2.fromScale(Percent, 1)
                ValueDisplay.Text = tostring(self.Value)
                
                Library:SafeCallback(Slider.Callback, self.Value)
                if Slider.Changed then
                    Library:SafeCallback(Slider.Changed, self.Value)
                end
            end
            
            function Slider:Destroy()
                SliderFrame:Destroy()
                Library.Options[Idx] = nil
            end
            
            -- Dragging functionality
            Library:Connect(SliderContainer.InputBegan, function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                    Dragging = true
                    
                    -- Update immediately on click
                    local Percent = math.clamp((Input.Position.X - SliderContainer.AbsolutePosition.X) / SliderContainer.AbsoluteSize.X, 0, 1)
                    Slider:SetValue(Slider.Min + ((Slider.Max - Slider.Min) * Percent))
                end
            end)
            
            Library:Connect(SliderDot.InputBegan, function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                    Dragging = true
                end
            end)
            
            Library:Connect(UserInputService.InputChanged, function(Input)
                if Dragging and (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch) then
                    local Percent = math.clamp((Input.Position.X - SliderContainer.AbsolutePosition.X) / SliderContainer.AbsoluteSize.X, 0, 1)
                    Slider:SetValue(Slider.Min + ((Slider.Max - Slider.Min) * Percent))
                end
            end)
            
            Library:Connect(UserInputService.InputEnded, function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
                    Dragging = false
                end
            end)
            
            -- Hover effects
            Library:Connect(SliderFrame.MouseEnter, function()
                Library:Tween(SliderFrame, {BackgroundTransparency = 0.05}, 0.15)
            end)
            
            Library:Connect(SliderFrame.MouseLeave, function()
                Library:Tween(SliderFrame, {BackgroundTransparency = Theme.ElementTransparency}, 0.15)
            end)
            
            -- Set initial value
            Slider:SetValue(config.Default)
            
            Library.Options[Idx] = Slider
            return Slider
        end
        
        -- ADD INPUT FUNCTION TO TAB
        function Tab:AddInput(config)
            local Input = {}
            local Idx = config.Title or "Input_" .. math.random(1000, 9999)
            
            assert(config.Title, "Input - Missing Title")
            config.Callback = config.Callback or function() end
            
            -- Input frame with transparency
            local InputFrame = Instance.new("Frame")
            InputFrame.Name = config.Title or "Input"
            InputFrame.Size = UDim2.new(1, 0, 0, config.Description and 70 or 50)
            InputFrame.BackgroundColor3 = Theme.Element
            InputFrame.BackgroundTransparency = Theme.ElementTransparency
            InputFrame.BorderSizePixel = 0
            InputFrame.Parent = TabContent
            
            local InputCorner = Instance.new("UICorner")
            InputCorner.CornerRadius = UDim.new(0, 8)
            InputCorner.Parent = InputFrame
            
            local InputStroke = Instance.new("UIStroke")
            InputStroke.Color = Theme.ElementBorder
            InputStroke.Transparency = 0.5
            InputStroke.Parent = InputFrame
            
            -- Title
            local InputTitle = Instance.new("TextLabel")
            InputTitle.Text = config.Title or "Input"
            InputTitle.Font = Enum.Font.GothamMedium
            InputTitle.TextSize = 14
            InputTitle.TextColor3 = Theme.Text
            InputTitle.TextXAlignment = Enum.TextXAlignment.Left
            InputTitle.Size = UDim2.new(1, -180, 0, 18)
            InputTitle.Position = UDim2.fromOffset(12, config.Description and 8 or 16)
            InputTitle.BackgroundTransparency = 1
            InputTitle.Parent = InputFrame
            
            -- Description
            if config.Description then
                local InputDesc = Instance.new("TextLabel")
                InputDesc.Text = config.Description
                InputDesc.Font = Enum.Font.Gotham
                InputDesc.TextSize = 12
                InputDesc.TextColor3 = Theme.SubText
                InputDesc.TextXAlignment = Enum.TextXAlignment.Left
                InputDesc.Size = UDim2.new(1, -180, 0, 16)
                InputDesc.Position = UDim2.fromOffset(12, 28)
                InputDesc.BackgroundTransparency = 1
                InputDesc.TextWrapped = true
                InputDesc.Parent = InputFrame
            end
            
            -- Textbox container
            local TextboxFrame = Instance.new("Frame")
            TextboxFrame.Size = UDim2.fromOffset(160, 30)
            TextboxFrame.Position = UDim2.new(1, -170, 0.5, -15)
            TextboxFrame.BackgroundColor3 = Theme.Background
            TextboxFrame.BackgroundTransparency = 0.2
            TextboxFrame.BorderSizePixel = 0
            TextboxFrame.Parent = InputFrame
            
            local TextboxCorner = Instance.new("UICorner")
            TextboxCorner.CornerRadius = UDim.new(0, 6)
            TextboxCorner.Parent = TextboxFrame
            
            local TextboxStroke = Instance.new("UIStroke")
            TextboxStroke.Color = Theme.ElementBorder
            TextboxStroke.Transparency = 0.6
            TextboxStroke.Parent = TextboxFrame
            
            -- Textbox
            local Textbox = Instance.new("TextBox")
            Textbox.Size = UDim2.new(1, -16, 1, 0)
            Textbox.Position = UDim2.fromOffset(8, 0)
            Textbox.BackgroundTransparency = 1
            Textbox.Text = config.Default or ""
            Textbox.PlaceholderText = config.Placeholder or ""
            Textbox.TextColor3 = Theme.Text
            Textbox.PlaceholderColor3 = Theme.SubText
            Textbox.TextSize = 13
            Textbox.Font = Enum.Font.Gotham
            Textbox.ClearTextOnFocus = false
            Textbox.Parent = TextboxFrame
            
            -- Input object
            Input = {
                Value = config.Default or "",
                Numeric = config.Numeric or false,
                Finished = config.Finished or false,
                Callback = config.Callback or function(Value) end,
                Type = "Input",
                Frame = InputFrame,
                Changed = nil
            }
            
            -- Set title and description functions
            Input.SetTitle = function(title)
                InputTitle.Text = title
            end
            
            Input.SetDesc = function(desc)
                if config.Description then
                    InputDesc.Text = desc or ""
                end
            end
            
            -- Set value function with validation
            function Input:SetValue(Text)
                if config.MaxLength and #Text > config.MaxLength then
                    Text = Text:sub(1, config.MaxLength)
                end
                
                if Input.Numeric then
                    if (not tonumber(Text)) and Text:len() > 0 then
                        Text = Input.Value
                    end
                end
                
                Input.Value = Text
                Textbox.Text = Text
                
                Library:SafeCallback(Input.Callback, Input.Value)
                if Input.Changed then
                    Library:SafeCallback(Input.Changed, Input.Value)
                end
            end
            
            -- Connect input events
            if Input.Finished then
                Library:Connect(Textbox.FocusLost, function(enter)
                    if not enter then
                        return
                    end
                    Input:SetValue(Textbox.Text)
                end)
            else
                Library:Connect(Textbox:GetPropertyChangedSignal("Text"), function()
                    Input:SetValue(Textbox.Text)
                end)
            end
            
            -- On changed callback
            function Input:OnChanged(Func)
                Input.Changed = Func
                Func(Input.Value)
            end
            
            -- Destroy function
            function Input:Destroy()
                InputFrame:Destroy()
                Library.Options[Idx] = nil
            end
            
            -- Focus effects
            Library:Connect(Textbox.Focused, function()
                Library:Tween(TextboxStroke, {Color = Theme.Accent, Transparency = 0.3}, 0.2)
            end)
            
            Library:Connect(Textbox.FocusLost, function()
                Library:Tween(TextboxStroke, {Color = Theme.ElementBorder, Transparency = 0.6}, 0.2)
            end)
            
            Library.Options[Idx] = Input
            return Input
        end
        
        -- ADD PARAGRAPH FUNCTION TO TAB
        function Tab:AddParagraph(config)
            assert(config.Title, "Paragraph - Missing Title")
            config.Content = config.Content or ""
            
            -- Paragraph frame with transparency
            local ParagraphFrame = Instance.new("Frame")
            ParagraphFrame.Name = config.Title or "Paragraph"
            ParagraphFrame.Size = UDim2.new(1, 0, 0, 0)
            ParagraphFrame.AutomaticSize = Enum.AutomaticSize.Y
            ParagraphFrame.BackgroundColor3 = Theme.Element
            ParagraphFrame.BackgroundTransparency = 0.92
            ParagraphFrame.BorderSizePixel = 0
            ParagraphFrame.Parent = TabContent
            
            local ParagraphCorner = Instance.new("UICorner")
            ParagraphCorner.CornerRadius = UDim.new(0, 8)
            ParagraphCorner.Parent = ParagraphFrame
            
            local ParagraphStroke = Instance.new("UIStroke")
            ParagraphStroke.Color = Theme.ElementBorder
            ParagraphStroke.Transparency = 0.6
            ParagraphStroke.Parent = ParagraphFrame
            
            -- Padding
            local ParagraphPadding = Instance.new("UIPadding")
            ParagraphPadding.PaddingTop = UDim.new(0, 12)
            ParagraphPadding.PaddingBottom = UDim.new(0, 12)
            ParagraphPadding.PaddingLeft = UDim.new(0, 12)
            ParagraphPadding.PaddingRight = UDim.new(0, 12)
            ParagraphPadding.Parent = ParagraphFrame
            
            -- List layout for organizing title and content
            local ParagraphList = Instance.new("UIListLayout")
            ParagraphList.Padding = UDim.new(0, 8)
            ParagraphList.Parent = ParagraphFrame
            
            -- Title
            local ParagraphTitle = Instance.new("TextLabel")
            ParagraphTitle.Text = config.Title
            ParagraphTitle.Font = Enum.Font.GothamBold
            ParagraphTitle.TextSize = 16
            ParagraphTitle.TextColor3 = Theme.Text
            ParagraphTitle.TextXAlignment = Enum.TextXAlignment.Left
            ParagraphTitle.Size = UDim2.new(1, 0, 0, 20)
            ParagraphTitle.BackgroundTransparency = 1
            ParagraphTitle.Parent = ParagraphFrame
            ParagraphTitle.LayoutOrder = 1
            
            -- Content
            local ParagraphContent = Instance.new("TextLabel")
            ParagraphContent.Text = config.Content
            ParagraphContent.Font = Enum.Font.Gotham
            ParagraphContent.TextSize = 14
            ParagraphContent.TextColor3 = Theme.SubText
            ParagraphContent.TextXAlignment = Enum.TextXAlignment.Left
            ParagraphContent.TextYAlignment = Enum.TextYAlignment.Top
            ParagraphContent.Size = UDim2.new(1, 0, 0, 0)
            ParagraphContent.AutomaticSize = Enum.AutomaticSize.Y
            ParagraphContent.BackgroundTransparency = 1
            ParagraphContent.TextWrapped = true
            ParagraphContent.Parent = ParagraphFrame
            ParagraphContent.LayoutOrder = 2
            
            local Paragraph = {
                Frame = ParagraphFrame,
                Title = ParagraphTitle,
                Content = ParagraphContent,
                SetTitle = function(title)
                    ParagraphTitle.Text = title
                end,
                SetContent = function(content)
                    ParagraphContent.Text = content
                end
            }
            
            return Paragraph
        end
        
        function Tab:AddSection(title)
            local Section = {}
            
            -- Section frame with transparency
            local SectionFrame = Instance.new("Frame")
            SectionFrame.Name = title or "Section"
            SectionFrame.Size = UDim2.new(1, 0, 0, 0)
            SectionFrame.AutomaticSize = Enum.AutomaticSize.Y
            SectionFrame.BackgroundTransparency = 1
            SectionFrame.Parent = TabContent
            
            local SectionList = Instance.new("UIListLayout")
            SectionList.Padding = UDim.new(0, 8)
            SectionList.Parent = SectionFrame
            
            local SectionPadding = Instance.new("UIPadding")
            SectionPadding.PaddingTop = UDim.new(0, 8)
            SectionPadding.PaddingBottom = UDim.new(0, 8)
            SectionPadding.PaddingLeft = UDim.new(0, 8)
            SectionPadding.PaddingRight = UDim.new(0, 8)
            SectionPadding.Parent = SectionFrame
            
            -- Section title
            if title and title ~= "" then
                local SectionTitle = Instance.new("TextLabel")
                SectionTitle.Name = "Title"
                SectionTitle.Text = title
                SectionTitle.Font = Enum.Font.GothamBold
                SectionTitle.TextSize = 16
                SectionTitle.TextColor3 = Theme.Text
                SectionTitle.TextXAlignment = Enum.TextXAlignment.Left
                SectionTitle.Size = UDim2.new(1, 0, 0, 28)
                SectionTitle.BackgroundTransparency = 1
                SectionTitle.Parent = SectionFrame
                SectionTitle.LayoutOrder = -1
            end
            
            Section.Frame = SectionFrame
            Section.Container = SectionFrame
            Section.Library = Library
            
            -- Copy all the section methods
            function Section:AddKeybind(config)
                return Tab:AddKeybind(config)
            end
            
            function Section:AddColorpicker(config)
                return Tab:AddColorpicker(config)
            end
            
            function Section:AddSlider(config)
                return Tab:AddSlider(config)
            end
            
            function Section:AddInput(config)
                return Tab:AddInput(config)
            end
            
            function Section:AddParagraph(config)
                return Tab:AddParagraph(config)
            end
            
            function Section:AddToggle(config)
                local Toggle = {}
                
                -- Toggle frame with transparency
                local ToggleFrame = Instance.new("TextButton")
                ToggleFrame.Name = config.Title or "Toggle"
                ToggleFrame.Size = UDim2.new(1, 0, 0, config.Description and 55 or 40)
                ToggleFrame.BackgroundColor3 = Theme.Element
                ToggleFrame.BackgroundTransparency = Theme.ElementTransparency
                ToggleFrame.Text = ""
                ToggleFrame.BorderSizePixel = 0
                ToggleFrame.Parent = SectionFrame
                
                local ToggleCorner = Instance.new("UICorner")
                ToggleCorner.CornerRadius = UDim.new(0, 8)
                ToggleCorner.Parent = ToggleFrame
                
                local ToggleStroke = Instance.new("UIStroke")
                ToggleStroke.Color = Theme.ElementBorder
                ToggleStroke.Transparency = 0.5
                ToggleStroke.Parent = ToggleFrame
                
                -- Title
                local ToggleTitle = Instance.new("TextLabel")
                ToggleTitle.Text = config.Title or "Toggle"
                ToggleTitle.Font = Enum.Font.GothamMedium
                ToggleTitle.TextSize = 14
                ToggleTitle.TextColor3 = Theme.Text
                ToggleTitle.TextXAlignment = Enum.TextXAlignment.Left
                ToggleTitle.Size = UDim2.new(1, -60, 0, 18)
                ToggleTitle.Position = UDim2.fromOffset(12, config.Description and 8 or 11)
                ToggleTitle.BackgroundTransparency = 1
                ToggleTitle.Parent = ToggleFrame
                
                -- Description
                if config.Description then
                    local ToggleDesc = Instance.new("TextLabel")
                    ToggleDesc.Text = config.Description
                    ToggleDesc.Font = Enum.Font.Gotham
                    ToggleDesc.TextSize = 12
                    ToggleDesc.TextColor3 = Theme.SubText
                    ToggleDesc.TextXAlignment = Enum.TextXAlignment.Left
                    ToggleDesc.Size = UDim2.new(1, -60, 0, 16)
                    ToggleDesc.Position = UDim2.fromOffset(12, 28)
                    ToggleDesc.BackgroundTransparency = 1
                    ToggleDesc.TextWrapped = true
                    ToggleDesc.Parent = ToggleFrame
                end
                
                -- Toggle switch
                local ToggleSlider = Instance.new("Frame")
                ToggleSlider.Size = UDim2.fromOffset(38, 20)
                ToggleSlider.Position = UDim2.new(1, -50, 0.5, -10)
                ToggleSlider.BackgroundColor3 = Theme.ElementBorder
                ToggleSlider.BackgroundTransparency = 0.3
                ToggleSlider.BorderSizePixel = 0
                ToggleSlider.Parent = ToggleFrame
                
                local SliderCorner = Instance.new("UICorner")
                SliderCorner.CornerRadius = UDim.new(0, 10)
                SliderCorner.Parent = ToggleSlider
                
                -- Toggle circle
                local ToggleCircle = Instance.new("Frame")
                ToggleCircle.Size = UDim2.fromOffset(16, 16)
                ToggleCircle.Position = UDim2.fromOffset(2, 2)
                ToggleCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                ToggleCircle.BorderSizePixel = 0
                ToggleCircle.Parent = ToggleSlider
                
                local CircleCorner = Instance.new("UICorner")
                CircleCorner.CornerRadius = UDim.new(0, 8)
                CircleCorner.Parent = ToggleCircle
                
                -- Toggle state
                local ToggleState = config.Default or false
                
                local function UpdateToggle()
                    local TargetColor = ToggleState and Theme.Accent or Theme.ElementBorder
                    local TargetPos = ToggleState and UDim2.fromOffset(20, 2) or UDim2.fromOffset(2, 2)
                    
                    Library:Tween(ToggleSlider, {BackgroundColor3 = TargetColor}, 0.25)
                    Library:Tween(ToggleCircle, {Position = TargetPos}, 0.25)
                end
                
                -- Click functionality
                Library:Connect(ToggleFrame.MouseButton1Click, function()
                    ToggleState = not ToggleState
                    UpdateToggle()
                    Library:SafeCallback(config.Callback, ToggleState)
                end)
                
                -- Hover effects
                Library:Connect(ToggleFrame.MouseEnter, function()
                    Library:Tween(ToggleFrame, {BackgroundTransparency = 0.05}, 0.15)
                end)
                
                Library:Connect(ToggleFrame.MouseLeave, function()
                    Library:Tween(ToggleFrame, {BackgroundTransparency = Theme.ElementTransparency}, 0.15)
                end)
                
                UpdateToggle()
                
                Toggle.Frame = ToggleFrame
                Toggle.SetValue = function(value)
                    ToggleState = value
                    UpdateToggle()
                    Library:SafeCallback(config.Callback, ToggleState)
                end
                Toggle.GetValue = function()
                    return ToggleState
                end
                
                return Toggle
            end
            
            function Section:AddDropdown(config)
                local Dropdown = {}
                
                -- Dropdown frame
                local DropdownFrame = Instance.new("TextButton")
                DropdownFrame.Name = config.Title or "Dropdown"
                DropdownFrame.Size = UDim2.new(1, 0, 0, config.Description and 55 or 40)
                DropdownFrame.BackgroundColor3 = Theme.Element
                DropdownFrame.BackgroundTransparency = Theme.ElementTransparency
                DropdownFrame.Text = ""
                DropdownFrame.BorderSizePixel = 0
                DropdownFrame.Parent = SectionFrame
                
                local DropdownCorner = Instance.new("UICorner")
                DropdownCorner.CornerRadius = UDim.new(0, 8)
                DropdownCorner.Parent = DropdownFrame
                
                local DropdownStroke = Instance.new("UIStroke")
                DropdownStroke.Color = Theme.ElementBorder
                DropdownStroke.Transparency = 0.5
                DropdownStroke.Parent = DropdownFrame
                
                -- Title
                local DropdownTitle = Instance.new("TextLabel")
                DropdownTitle.Text = config.Title or "Dropdown"
                DropdownTitle.Font = Enum.Font.GothamMedium
                DropdownTitle.TextSize = 14
                DropdownTitle.TextColor3 = Theme.Text
                DropdownTitle.TextXAlignment = Enum.TextXAlignment.Left
                DropdownTitle.Size = UDim2.new(1, -40, 0, 18)
                DropdownTitle.Position = UDim2.fromOffset(12, config.Description and 8 or 11)
                DropdownTitle.BackgroundTransparency = 1
                DropdownTitle.Parent = DropdownFrame
                
                -- Description
                if config.Description then
                    local DropdownDesc = Instance.new("TextLabel")
                    DropdownDesc.Text = config.Description
                    DropdownDesc.Font = Enum.Font.Gotham
                    DropdownDesc.TextSize = 12
                    DropdownDesc.TextColor3 = Theme.SubText
                    DropdownDesc.TextXAlignment = Enum.TextXAlignment.Left
                    DropdownDesc.Size = UDim2.new(1, -40, 0, 16)
                    DropdownDesc.Position = UDim2.fromOffset(12, 28)
                    DropdownDesc.BackgroundTransparency = 1
                    DropdownDesc.TextWrapped = true
                    DropdownDesc.Parent = DropdownFrame
                end
                
                -- Dropdown display
                local DropdownDisplay = Instance.new("TextButton")
                DropdownDisplay.Size = UDim2.fromOffset(120, 28)
                DropdownDisplay.Position = UDim2.new(1, -130, 0.5, -14)
                DropdownDisplay.BackgroundColor3 = Theme.Background
                DropdownDisplay.BackgroundTransparency = 0.2
                DropdownDisplay.Text = config.Default or "Select..."
                DropdownDisplay.TextColor3 = Theme.Text
                DropdownDisplay.TextSize = 12
                DropdownDisplay.Font = Enum.Font.Gotham
                DropdownDisplay.BorderSizePixel = 0
                DropdownDisplay.Parent = DropdownFrame
                
                local DisplayCorner = Instance.new("UICorner")
                DisplayCorner.CornerRadius = UDim.new(0, 6)
                DisplayCorner.Parent = DropdownDisplay
                
                local DisplayStroke = Instance.new("UIStroke")
                DisplayStroke.Color = Theme.ElementBorder
                DisplayStroke.Transparency = 0.6
                DisplayStroke.Parent = DropdownDisplay
                
                -- Arrow
                local Arrow = Instance.new("TextLabel")
                Arrow.Text = "▼"
                Arrow.Font = Enum.Font.GothamBold
                Arrow.TextSize = 10
                Arrow.TextColor3 = Theme.SubText
                Arrow.Size = UDim2.fromOffset(16, 16)
                Arrow.Position = UDim2.new(1, -20, 0.5, -8)
                Arrow.BackgroundTransparency = 1
                Arrow.Parent = DropdownDisplay
                
                -- Dropdown list
                local DropdownList = Instance.new("Frame")
                DropdownList.Size = UDim2.fromOffset(120, 0)
                DropdownList.Position = UDim2.new(1, -130, 1, 5)
                DropdownList.BackgroundColor3 = Theme.Background
                DropdownList.BackgroundTransparency = 0.1
                DropdownList.BorderSizePixel = 0
                DropdownList.Visible = false
                DropdownList.Parent = DropdownFrame
                DropdownList.ZIndex = 100
                
                local ListCorner = Instance.new("UICorner")
                ListCorner.CornerRadius = UDim.new(0, 6)
                ListCorner.Parent = DropdownList
                
                local ListStroke = Instance.new("UIStroke")
                ListStroke.Color = Theme.ElementBorder
                ListStroke.Transparency = 0.4
                ListStroke.Parent = DropdownList
                
                local ListLayout = Instance.new("UIListLayout")
                ListLayout.Padding = UDim.new(0, 2)
                ListLayout.Parent = DropdownList
                
                local ListPadding = Instance.new("UIPadding")
                ListPadding.PaddingTop = UDim.new(0, 4)
                ListPadding.PaddingBottom = UDim.new(0, 4)
                ListPadding.PaddingLeft = UDim.new(0, 4)
                ListPadding.PaddingRight = UDim.new(0, 4)
                ListPadding.Parent = DropdownList
                
                -- State
                local IsOpen = false
                local SelectedValue = config.Default
                
                local function UpdateList()
                    -- Clear existing options
                    for _, child in pairs(DropdownList:GetChildren()) do
                        if child:IsA("TextButton") then
                            child:Destroy()
                        end
                    end
                    
                    -- Add options
                    for _, option in pairs(config.Values or {}) do
                        local OptionBtn = Instance.new("TextButton")
                        OptionBtn.Size = UDim2.new(1, 0, 0, 24)
                        OptionBtn.BackgroundColor3 = Theme.Element
                        OptionBtn.BackgroundTransparency = 0.8
                        OptionBtn.Text = option
                        OptionBtn.TextColor3 = Theme.Text
                        OptionBtn.TextSize = 11
                        OptionBtn.Font = Enum.Font.Gotham
                        OptionBtn.TextXAlignment = Enum.TextXAlignment.Left
                        OptionBtn.BorderSizePixel = 0
                        OptionBtn.Parent = DropdownList
                        
                        local OptionCorner = Instance.new("UICorner")
                        OptionCorner.CornerRadius = UDim.new(0, 4)
                        OptionCorner.Parent = OptionBtn
                        
                        local OptionPadding = Instance.new("UIPadding")
                        OptionPadding.PaddingLeft = UDim.new(0, 8)
                        OptionPadding.Parent = OptionBtn
                        
                        Library:Connect(OptionBtn.MouseButton1Click, function()
                            SelectedValue = option
                            DropdownDisplay.Text = option
                            IsOpen = false
                            DropdownList.Visible = false
                            Arrow.Text = "▼"
                            Library:SafeCallback(config.Callback, option)
                        end)
                        
                        Library:Connect(OptionBtn.MouseEnter, function()
                            Library:Tween(OptionBtn, {BackgroundTransparency = 0.5}, 0.1)
                        end)
                        
                        Library:Connect(OptionBtn.MouseLeave, function()
                            Library:Tween(OptionBtn, {BackgroundTransparency = 0.8}, 0.1)
                        end)
                    end
                    
                    -- Update list size
                    DropdownList.Size = UDim2.fromOffset(120, ListLayout.AbsoluteContentSize.Y + 8)
                end
                
                -- Toggle dropdown
                Library:Connect(DropdownDisplay.MouseButton1Click, function()
                    IsOpen = not IsOpen
                    DropdownList.Visible = IsOpen
                    Arrow.Text = IsOpen and "▲" or "▼"
                    
                    if IsOpen then
                        UpdateList()
                    end
                end)
                
                -- Hover effects
                Library:Connect(DropdownFrame.MouseEnter, function()
                    Library:Tween(DropdownFrame, {BackgroundTransparency = 0.05}, 0.15)
                end)
                
                Library:Connect(DropdownFrame.MouseLeave, function()
                    Library:Tween(DropdownFrame, {BackgroundTransparency = Theme.ElementTransparency}, 0.15)
                end)
                
                Dropdown.Frame = DropdownFrame
                Dropdown.SetValues = function(values)
                    config.Values = values
                    UpdateList()
                end
                Dropdown.GetValue = function()
                    return SelectedValue
                end
                Dropdown.SetValue = function(value)
                    if table.find(config.Values or {}, value) then
                        SelectedValue = value
                        DropdownDisplay.Text = value
                        Library:SafeCallback(config.Callback, value)
                    end
                end
                
                UpdateList()
                return Dropdown
            end

            function Section:AddButton(config)
                local Button = {}
                
                -- Button frame with transparency
                local BtnFrame = Instance.new("TextButton")
                BtnFrame.Name = config.Title or "Button"
                BtnFrame.Size = UDim2.new(1, 0, 0, config.Description and 55 or 40)
                BtnFrame.BackgroundColor3 = Theme.Element
                BtnFrame.BackgroundTransparency = Theme.ElementTransparency
                BtnFrame.Text = ""
                BtnFrame.BorderSizePixel = 0
                BtnFrame.Parent = SectionFrame
                
                local BtnCorner = Instance.new("UICorner")
                BtnCorner.CornerRadius = UDim.new(0, 8)
                BtnCorner.Parent = BtnFrame
                
                local BtnStroke = Instance.new("UIStroke")
                BtnStroke.Color = Theme.ElementBorder
                BtnStroke.Transparency = 0.5
                BtnStroke.Parent = BtnFrame
                
                -- Title
                local BtnTitle = Instance.new("TextLabel")
                BtnTitle.Text = config.Title or "Button"
                BtnTitle.Font = Enum.Font.GothamMedium
                BtnTitle.TextSize = 14
                BtnTitle.TextColor3 = Theme.Text
                BtnTitle.TextXAlignment = Enum.TextXAlignment.Left
                BtnTitle.Size = UDim2.new(1, -40, 0, 18)
                BtnTitle.Position = UDim2.fromOffset(12, config.Description and 8 or 11)
                BtnTitle.BackgroundTransparency = 1
                BtnTitle.Parent = BtnFrame
                
                -- Description
                if config.Description then
                    local BtnDesc = Instance.new("TextLabel")
                    BtnDesc.Text = config.Description
                    BtnDesc.Font = Enum.Font.Gotham
                    BtnDesc.TextSize = 12
                    BtnDesc.TextColor3 = Theme.SubText
                    BtnDesc.TextXAlignment = Enum.TextXAlignment.Left
                    BtnDesc.Size = UDim2.new(1, -40, 0, 16)
                    BtnDesc.Position = UDim2.fromOffset(12, 28)
                    BtnDesc.BackgroundTransparency = 1
                    BtnDesc.TextWrapped = true
                    BtnDesc.Parent = BtnFrame
                end
                
                -- Arrow icon
                local Arrow = Instance.new("TextLabel")
                Arrow.Text = "→"
                Arrow.Font = Enum.Font.GothamBold
                Arrow.TextSize = 18
                Arrow.TextColor3 = Theme.Accent
                Arrow.Size = UDim2.fromOffset(24, 24)
                Arrow.Position = UDim2.new(1, -30, 0.5, -12)
                Arrow.BackgroundTransparency = 1
                Arrow.Parent = BtnFrame
                
                -- Click functionality
                Library:Connect(BtnFrame.MouseButton1Click, function()
                    -- Visual feedback
                    Library:Tween(Arrow, {TextColor3 = Color3.fromRGB(255, 255, 255)}, 0.1)
                    wait(0.1)
                    Library:Tween(Arrow, {TextColor3 = Theme.Accent}, 0.1)
                    
                    -- Execute callback
                    Library:SafeCallback(config.Callback)
                end)
                
                -- Hover effects
                Library:Connect(BtnFrame.MouseEnter, function()
                    Library:Tween(BtnFrame, {BackgroundTransparency = 0.05}, 0.15)
                    Library:Tween(Arrow, {TextColor3 = Color3.fromRGB(255, 255, 255)}, 0.15)
                end)
                
                Library:Connect(BtnFrame.MouseLeave, function()
                    Library:Tween(BtnFrame, {BackgroundTransparency = Theme.ElementTransparency}, 0.15)
                    Library:Tween(Arrow, {TextColor3 = Theme.Accent}, 0.15)
                end)
                
                Button.Frame = BtnFrame
                Button.SetTitle = function(title)
                    BtnTitle.Text = title
                end
                Button.SetDescription = function(desc)
                    if BtnDesc then
                        BtnDesc.Text = desc or ""
                    end
                end
                
                return Button
            end
            
            return Section
        end
        
        -- Direct tab functions for non-section elements
        function Tab:AddButton(config)
            local Button = {}
            
            -- Button frame with transparency
            local BtnFrame = Instance.new("TextButton")
            BtnFrame.Name = config.Title or "Button"
            BtnFrame.Size = UDim2.new(1, 0, 0, config.Description and 55 or 40)
            BtnFrame.BackgroundColor3 = Theme.Element
            BtnFrame.BackgroundTransparency = Theme.ElementTransparency
            BtnFrame.Text = ""
            BtnFrame.BorderSizePixel = 0
            BtnFrame.Parent = TabContent
            
            local BtnCorner = Instance.new("UICorner")
            BtnCorner.CornerRadius = UDim.new(0, 8)
            BtnCorner.Parent = BtnFrame
            
            local BtnStroke = Instance.new("UIStroke")
            BtnStroke.Color = Theme.ElementBorder
            BtnStroke.Transparency = 0.5
            BtnStroke.Parent = BtnFrame
            
            -- Title
            local BtnTitle = Instance.new("TextLabel")
            BtnTitle.Text = config.Title or "Button"
            BtnTitle.Font = Enum.Font.GothamMedium
            BtnTitle.TextSize = 14
            BtnTitle.TextColor3 = Theme.Text
            BtnTitle.TextXAlignment = Enum.TextXAlignment.Left
            BtnTitle.Size = UDim2.new(1, -40, 0, 18)
            BtnTitle.Position = UDim2.fromOffset(12, config.Description and 8 or 11)
            BtnTitle.BackgroundTransparency = 1
            BtnTitle.Parent = BtnFrame
            
            -- Description
            if config.Description then
                local BtnDesc = Instance.new("TextLabel")
                BtnDesc.Text = config.Description
                BtnDesc.Font = Enum.Font.Gotham
                BtnDesc.TextSize = 12
                BtnDesc.TextColor3 = Theme.SubText
                BtnDesc.TextXAlignment = Enum.TextXAlignment.Left
                BtnDesc.Size = UDim2.new(1, -40, 0, 16)
                BtnDesc.Position = UDim2.fromOffset(12, 28)
                BtnDesc.BackgroundTransparency = 1
                BtnDesc.TextWrapped = true
                BtnDesc.Parent = BtnFrame
            end
            
            -- Arrow icon
            local Arrow = Instance.new("TextLabel")
            Arrow.Text = "→"
            Arrow.Font = Enum.Font.GothamBold
            Arrow.TextSize = 18
            Arrow.TextColor3 = Theme.Accent
            Arrow.Size = UDim2.fromOffset(24, 24)
            Arrow.Position = UDim2.new(1, -30, 0.5, -12)
            Arrow.BackgroundTransparency = 1
            Arrow.Parent = BtnFrame
            
            -- Click functionality
            Library:Connect(BtnFrame.MouseButton1Click, function()
                -- Visual feedback
                Library:Tween(Arrow, {TextColor3 = Color3.fromRGB(255, 255, 255)}, 0.1)
                wait(0.1)
                Library:Tween(Arrow, {TextColor3 = Theme.Accent}, 0.1)
                
                -- Execute callback
                Library:SafeCallback(config.Callback)
            end)
            
            -- Hover effects
            Library:Connect(BtnFrame.MouseEnter, function()
                Library:Tween(BtnFrame, {BackgroundTransparency = 0.05}, 0.15)
                Library:Tween(Arrow, {TextColor3 = Color3.fromRGB(255, 255, 255)}, 0.15)
            end)
            
            Library:Connect(BtnFrame.MouseLeave, function()
                Library:Tween(BtnFrame, {BackgroundTransparency = Theme.ElementTransparency}, 0.15)
                Library:Tween(Arrow, {TextColor3 = Theme.Accent}, 0.15)
            end)
            
            Button.Frame = BtnFrame
            Button.SetTitle = function(title)
                BtnTitle.Text = title
            end
            Button.SetDescription = function(desc)
                if BtnDesc then
                    BtnDesc.Text = desc or ""
                end
            end
            
            return Button
        end
        
        function Tab:AddToggle(config)
            local Toggle = {}
            
            -- Toggle frame with transparency
            local ToggleFrame = Instance.new("TextButton")
            ToggleFrame.Name = config.Title or "Toggle"
            ToggleFrame.Size = UDim2.new(1, 0, 0, config.Description and 55 or 40)
            ToggleFrame.BackgroundColor3 = Theme.Element
            ToggleFrame.BackgroundTransparency = Theme.ElementTransparency
            ToggleFrame.Text = ""
            ToggleFrame.BorderSizePixel = 0
            ToggleFrame.Parent = TabContent
            
            local ToggleCorner = Instance.new("UICorner")
            ToggleCorner.CornerRadius = UDim.new(0, 8)
            ToggleCorner.Parent = ToggleFrame
            
            local ToggleStroke = Instance.new("UIStroke")
            ToggleStroke.Color = Theme.ElementBorder
            ToggleStroke.Transparency = 0.5
            ToggleStroke.Parent = ToggleFrame
            
            -- Title
            local ToggleTitle = Instance.new("TextLabel")
            ToggleTitle.Text = config.Title or "Toggle"
            ToggleTitle.Font = Enum.Font.GothamMedium
            ToggleTitle.TextSize = 14
            ToggleTitle.TextColor3 = Theme.Text
            ToggleTitle.TextXAlignment = Enum.TextXAlignment.Left
            ToggleTitle.Size = UDim2.new(1, -60, 0, 18)
            ToggleTitle.Position = UDim2.fromOffset(12, config.Description and 8 or 11)
            ToggleTitle.BackgroundTransparency = 1
            ToggleTitle.Parent = ToggleFrame
            
            -- Description
            if config.Description then
                local ToggleDesc = Instance.new("TextLabel")
                ToggleDesc.Text = config.Description
                ToggleDesc.Font = Enum.Font.Gotham
                ToggleDesc.TextSize = 12
                ToggleDesc.TextColor3 = Theme.SubText
                ToggleDesc.TextXAlignment = Enum.TextXAlignment.Left
                ToggleDesc.Size = UDim2.new(1, -60, 0, 16)
                ToggleDesc.Position = UDim2.fromOffset(12, 28)
                ToggleDesc.BackgroundTransparency = 1
                ToggleDesc.TextWrapped = true
                ToggleDesc.Parent = ToggleFrame
            end
            
            -- Toggle switch
            local ToggleSlider = Instance.new("Frame")
            ToggleSlider.Size = UDim2.fromOffset(38, 20)
            ToggleSlider.Position = UDim2.new(1, -50, 0.5, -10)
            ToggleSlider.BackgroundColor3 = Theme.ElementBorder
            ToggleSlider.BackgroundTransparency = 0.3
            ToggleSlider.BorderSizePixel = 0
            ToggleSlider.Parent = ToggleFrame
            
            local SliderCorner = Instance.new("UICorner")
            SliderCorner.CornerRadius = UDim.new(0, 10)
            SliderCorner.Parent = ToggleSlider
            
            -- Toggle circle
            local ToggleCircle = Instance.new("Frame")
            ToggleCircle.Size = UDim2.fromOffset(16, 16)
            ToggleCircle.Position = UDim2.fromOffset(2, 2)
            ToggleCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            ToggleCircle.BorderSizePixel = 0
            ToggleCircle.Parent = ToggleSlider
            
            local CircleCorner = Instance.new("UICorner")
            CircleCorner.CornerRadius = UDim.new(0, 8)
            CircleCorner.Parent = ToggleCircle
            
            -- Toggle state
            local ToggleState = config.Default or false
            
            local function UpdateToggle()
                local TargetColor = ToggleState and Theme.Accent or Theme.ElementBorder
                local TargetPos = ToggleState and UDim2.fromOffset(20, 2) or UDim2.fromOffset(2, 2)
                
                Library:Tween(ToggleSlider, {BackgroundColor3 = TargetColor}, 0.25)
                Library:Tween(ToggleCircle, {Position = TargetPos}, 0.25)
            end
            
            -- Click functionality
            Library:Connect(ToggleFrame.MouseButton1Click, function()
                ToggleState = not ToggleState
                UpdateToggle()
                Library:SafeCallback(config.Callback, ToggleState)
            end)
            
            -- Hover effects
            Library:Connect(ToggleFrame.MouseEnter, function()
                Library:Tween(ToggleFrame, {BackgroundTransparency = 0.05}, 0.15)
            end)
            
            Library:Connect(ToggleFrame.MouseLeave, function()
                Library:Tween(ToggleFrame, {BackgroundTransparency = Theme.ElementTransparency}, 0.15)
            end)
            
            UpdateToggle()
            
            Toggle.Frame = ToggleFrame
            Toggle.SetValue = function(value)
                ToggleState = value
                UpdateToggle()
                Library:SafeCallback(config.Callback, ToggleState)
            end
            Toggle.GetValue = function()
                return ToggleState
            end
            
            return Toggle
        end
        
        function Tab:AddDropdown(config)
            local Dropdown = {}
            
            -- Dropdown frame
            local DropdownFrame = Instance.new("TextButton")
            DropdownFrame.Name = config.Title or "Dropdown"
            DropdownFrame.Size = UDim2.new(1, 0, 0, config.Description and 55 or 40)
            DropdownFrame.BackgroundColor3 = Theme.Element
            DropdownFrame.BackgroundTransparency = Theme.ElementTransparency
            DropdownFrame.Text = ""
            DropdownFrame.BorderSizePixel = 0
            DropdownFrame.Parent = TabContent
            
            local DropdownCorner = Instance.new("UICorner")
            DropdownCorner.CornerRadius = UDim.new(0, 8)
            DropdownCorner.Parent = DropdownFrame
            
            local DropdownStroke = Instance.new("UIStroke")
            DropdownStroke.Color = Theme.ElementBorder
            DropdownStroke.Transparency = 0.5
            DropdownStroke.Parent = DropdownFrame
            
            -- Title
            local DropdownTitle = Instance.new("TextLabel")
            DropdownTitle.Text = config.Title or "Dropdown"
            DropdownTitle.Font = Enum.Font.GothamMedium
            DropdownTitle.TextSize = 14
            DropdownTitle.TextColor3 = Theme.Text
            DropdownTitle.TextXAlignment = Enum.TextXAlignment.Left
            DropdownTitle.Size = UDim2.new(1, -40, 0, 18)
            DropdownTitle.Position = UDim2.fromOffset(12, config.Description and 8 or 11)
            DropdownTitle.BackgroundTransparency = 1
            DropdownTitle.Parent = DropdownFrame
            
            -- Description
            if config.Description then
                local DropdownDesc = Instance.new("TextLabel")
                DropdownDesc.Text = config.Description
                DropdownDesc.Font = Enum.Font.Gotham
                DropdownDesc.TextSize = 12
                DropdownDesc.TextColor3 = Theme.SubText
                DropdownDesc.TextXAlignment = Enum.TextXAlignment.Left
                DropdownDesc.Size = UDim2.new(1, -40, 0, 16)
                DropdownDesc.Position = UDim2.fromOffset(12, 28)
                DropdownDesc.BackgroundTransparency = 1
                DropdownDesc.TextWrapped = true
                DropdownDesc.Parent = DropdownFrame
            end
            
            -- Dropdown display
            local DropdownDisplay = Instance.new("TextButton")
            DropdownDisplay.Size = UDim2.fromOffset(120, 28)
            DropdownDisplay.Position = UDim2.new(1, -130, 0.5, -14)
            DropdownDisplay.BackgroundColor3 = Theme.Background
            DropdownDisplay.BackgroundTransparency = 0.2
            DropdownDisplay.Text = config.Default or "Select..."
            DropdownDisplay.TextColor3 = Theme.Text
            DropdownDisplay.TextSize = 12
            DropdownDisplay.Font = Enum.Font.Gotham
            DropdownDisplay.BorderSizePixel = 0
            DropdownDisplay.Parent = DropdownFrame
            
            local DisplayCorner = Instance.new("UICorner")
            DisplayCorner.CornerRadius = UDim.new(0, 6)
            DisplayCorner.Parent = DropdownDisplay
            
            local DisplayStroke = Instance.new("UIStroke")
            DisplayStroke.Color = Theme.ElementBorder
            DisplayStroke.Transparency = 0.6
            DisplayStroke.Parent = DropdownDisplay
            
            -- Arrow
            local Arrow = Instance.new("TextLabel")
            Arrow.Text = "▼"
            Arrow.Font = Enum.Font.GothamBold
            Arrow.TextSize = 10
            Arrow.TextColor3 = Theme.SubText
            Arrow.Size = UDim2.fromOffset(16, 16)
            Arrow.Position = UDim2.new(1, -20, 0.5, -8)
            Arrow.BackgroundTransparency = 1
            Arrow.Parent = DropdownDisplay
            
            -- Dropdown list
            local DropdownList = Instance.new("Frame")
            DropdownList.Size = UDim2.fromOffset(120, 0)
            DropdownList.Position = UDim2.new(1, -130, 1, 5)
            DropdownList.BackgroundColor3 = Theme.Background
            DropdownList.BackgroundTransparency = 0.1
            DropdownList.BorderSizePixel = 0
            DropdownList.Visible = false
            DropdownList.Parent = DropdownFrame
            DropdownList.ZIndex = 100
            
            local ListCorner = Instance.new("UICorner")
            ListCorner.CornerRadius = UDim.new(0, 6)
            ListCorner.Parent = DropdownList
            
            local ListStroke = Instance.new("UIStroke")
            ListStroke.Color = Theme.ElementBorder
            ListStroke.Transparency = 0.4
            ListStroke.Parent = DropdownList
            
            local ListLayout = Instance.new("UIListLayout")
            ListLayout.Padding = UDim.new(0, 2)
            ListLayout.Parent = DropdownList
            
            local ListPadding = Instance.new("UIPadding")
            ListPadding.PaddingTop = UDim.new(0, 4)
            ListPadding.PaddingBottom = UDim.new(0, 4)
            ListPadding.PaddingLeft = UDim.new(0, 4)
            ListPadding.PaddingRight = UDim.new(0, 4)
            ListPadding.Parent = DropdownList
            
            -- State
            local IsOpen = false
            local SelectedValue = config.Default
            
            local function UpdateList()
                -- Clear existing options
                for _, child in pairs(DropdownList:GetChildren()) do
                    if child:IsA("TextButton") then
                        child:Destroy()
                    end
                end
                
                -- Add options
                for _, option in pairs(config.Values or {}) do
                    local OptionBtn = Instance.new("TextButton")
                    OptionBtn.Size = UDim2.new(1, 0, 0, 24)
                    OptionBtn.BackgroundColor3 = Theme.Element
                    OptionBtn.BackgroundTransparency = 0.8
                    OptionBtn.Text = option
                    OptionBtn.TextColor3 = Theme.Text
                    OptionBtn.TextSize = 11
                    OptionBtn.Font = Enum.Font.Gotham
                    OptionBtn.TextXAlignment = Enum.TextXAlignment.Left
                    OptionBtn.BorderSizePixel = 0
                    OptionBtn.Parent = DropdownList
                    
                    local OptionCorner = Instance.new("UICorner")
                    OptionCorner.CornerRadius = UDim.new(0, 4)
                    OptionCorner.Parent = OptionBtn
                    
                    local OptionPadding = Instance.new("UIPadding")
                    OptionPadding.PaddingLeft = UDim.new(0, 8)
                    OptionPadding.Parent = OptionBtn
                    
                    Library:Connect(OptionBtn.MouseButton1Click, function()
                        SelectedValue = option
                        DropdownDisplay.Text = option
                        IsOpen = false
                        DropdownList.Visible = false
                        Arrow.Text = "▼"
                        Library:SafeCallback(config.Callback, option)
                    end)
                    
                    Library:Connect(OptionBtn.MouseEnter, function()
                        Library:Tween(OptionBtn, {BackgroundTransparency = 0.5}, 0.1)
                    end)
                    
                    Library:Connect(OptionBtn.MouseLeave, function()
                        Library:Tween(OptionBtn, {BackgroundTransparency = 0.8}, 0.1)
                    end)
                end
                
                -- Update list size
                DropdownList.Size = UDim2.fromOffset(120, ListLayout.AbsoluteContentSize.Y + 8)
            end
            
            -- Toggle dropdown
            Library:Connect(DropdownDisplay.MouseButton1Click, function()
                IsOpen = not IsOpen
                DropdownList.Visible = IsOpen
                Arrow.Text = IsOpen and "▲" or "▼"
                
                if IsOpen then
                    UpdateList()
                end
            end)
            
            -- Hover effects
            Library:Connect(DropdownFrame.MouseEnter, function()
                Library:Tween(DropdownFrame, {BackgroundTransparency = 0.05}, 0.15)
            end)
            
            Library:Connect(DropdownFrame.MouseLeave, function()
                Library:Tween(DropdownFrame, {BackgroundTransparency = Theme.ElementTransparency}, 0.15)
            end)
            
            Dropdown.Frame = DropdownFrame
            Dropdown.SetValues = function(values)
                config.Values = values
                UpdateList()
            end
            Dropdown.GetValue = function()
                return SelectedValue
            end
            Dropdown.SetValue = function(value)
                if table.find(config.Values or {}, value) then
                    SelectedValue = value
                    DropdownDisplay.Text = value
                    Library:SafeCallback(config.Callback, value)
                end
            end
            
            UpdateList()
            return Dropdown
        end
        
        self.Tabs[TabName] = Tab
        
        -- Auto-select first tab
        if next(self.Tabs) and not self.CurrentTab then
            TabBtn.BackgroundColor3 = Theme.Hover
            TabBtn.BackgroundTransparency = 0.1
            TabContent.Visible = true
            self.TabDisplay.Text = TabName
            self.CurrentTab = Tab
        end
        
        return Tab
    end
    
    table.insert(Library.Windows, Window)
    return Window
end

return Library