--[[
    Ultimate Menu v4.1 - Premium Edition (Modificado por Gemini)
    ✨ ¡NUEVO! Añadida pestaña "Misc" con sliders para WalkSpeed y JumpPower.
    🔧 ¡MODIFICADO! Añadido un campo para el "Argumento del Arma" en la pestaña Aura.
    🐛 ¡CORREGIDO! La función "Bring" ahora simula un agarre para evitar que los items se queden pegados.
    📱 ¡NUEVO! Detección automática de plataforma. Se añade un botón de menú para dispositivos móviles.
     draggable ¡MODIFICADO! El botón de menú para móviles ahora es arrastrable.
    🎨 Diseño completamente renovado con animaciones fluidas
    🌟 Interfaz moderna con efectos visuales premium
]]

--// Servicios
local Players = game:GetService('Players')
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local StarterGui = game:GetService('StarterGui')
local CoreGui = game:GetService('CoreGui')
local Workspace = game:GetService('Workspace')
local TweenService = game:GetService('TweenService')
local UserInputService = game:GetService('UserInputService')
local RunService = game:GetService('RunService')
local Debris = game:GetService('Debris')

local LocalPlayer = Players.LocalPlayer

--// ======================== CONFIGURACIÓN PREMIUM ========================
local Config = {
    Theme = {
        Primary = Color3.fromRGB(1, 1, 1),
        Secondary = Color3.fromRGB(1, 1, 1),
        Background = Color3.fromRGB(1, 1, 1),
        Surface = Color3.fromRGB(1, 1, 1),
        Text = Color3.fromRGB(255, 255, 255),
        TextSecondary = Color3.fromRGB(170, 175, 185),
        Success = Color3.fromRGB(1, 1, 1),
        Error = Color3.fromRGB(1, 1, 1),
        Warning = Color3.fromRGB(1, 1, 1),
        Accent = Color3.fromRGB(1, 1, 1),
    },

    KillAura = {
        IsEnabled = false,
        Interval = 0.2,
        Range = 800,
        TargetFolder = Workspace:WaitForChild('Characters', 5),
        WeaponName = 'Old Axe',
        StaticArg3 = '1_7652771370',
        VisualEffects = true,
    },

    ItemsList = {
        FolderName = 'Items',
    },

    UI = {
        NotificationDuration = 3,
        EnableNotifications = true,
        AnimationSpeed = 0.3,
    },
}

--// ======================== SISTEMA DE NOTIFICACIONES PREMIUM ========================
local NotificationContainer

local function createNotificationSystem()
    local NotifGui = Instance.new('ScreenGui', CoreGui)
    NotifGui.Name = 'PremiumNotifications'
    NotifGui.ResetOnSpawn = false
    NotifGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    NotificationContainer = Instance.new('Frame', NotifGui)
    NotificationContainer.Size = UDim2.new(0, 320, 1, -20)
    NotificationContainer.Position = UDim2.new(1, -330, 0, 10)
    NotificationContainer.BackgroundTransparency = 1

    local Layout = Instance.new('UIListLayout', NotificationContainer)
    Layout.Padding = UDim.new(0, 10)
    Layout.SortOrder = Enum.SortOrder.LayoutOrder
    Layout.VerticalAlignment = Enum.VerticalAlignment.Bottom
end

local function notify(type, text, duration)
    if not Config.UI.EnableNotifications or not NotificationContainer then
        return
    end

    local colors = {
        success = Config.Theme.Success,
        error = Config.Theme.Error,
        warning = Config.Theme.Warning,
        info = Config.Theme.Primary,
    }
    local icons =
        { success = '✅', error = '❌', warning = '⚠️', info = 'ℹ️' }

    local Notif = Instance.new('Frame')
    Notif.Size = UDim2.new(1, 0, 0, 60)
    Notif.BackgroundColor3 = Config.Theme.Surface
    Notif.BackgroundTransparency = 0.1
    Notif.LayoutOrder = -tick()
    Notif.ClipsDescendants = true
    Notif.Parent = NotificationContainer

    local Corner = Instance.new('UICorner', Notif)
    Corner.CornerRadius = UDim.new(0, 8)
    local Stroke = Instance.new('UIStroke', Notif)
    Stroke.Color = colors[type] or Config.Theme.Primary
    Stroke.Thickness = 1.5

    local IconLabel = Instance.new('TextLabel', Notif)
    IconLabel.Size = UDim2.new(0, 30, 1, 0)
    IconLabel.Position = UDim2.new(0, 10, 0, 0)
    IconLabel.Text = icons[type] or '📢'
    IconLabel.Font = Enum.Font.GothamBold
    IconLabel.TextSize = 24
    IconLabel.BackgroundTransparency = 1
    IconLabel.TextColor3 = colors[type] or Config.Theme.Primary

    local TextLabel = Instance.new('TextLabel', Notif)
    TextLabel.Size = UDim2.new(1, -50, 1, -10)
    TextLabel.Position = UDim2.new(0, 45, 0, 5)
    TextLabel.Text = text
    TextLabel.TextWrapped = true
    TextLabel.BackgroundTransparency = 1
    TextLabel.TextColor3 = Config.Theme.Text
    TextLabel.Font = Enum.Font.Gotham
    TextLabel.TextSize = 14
    TextLabel.TextXAlignment = Enum.TextXAlignment.Left
    TextLabel.TextYAlignment = Enum.TextYAlignment.Top

    local initialPos =
        UDim2.new(1.2, 0, Notif.Position.Y.Scale, Notif.Position.Y.Offset)
    Notif.Position = initialPos

    TweenService:Create(
        Notif,
        TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
        {
            Position = UDim2.new(
                0,
                0,
                Notif.Position.Y.Scale,
                Notif.Position.Y.Offset
            ),
        }
    ):Play()

    task.delay(duration or Config.UI.NotificationDuration, function()
        if not Notif or not Notif.Parent then
            return
        end
        local tween = TweenService:Create(
            Notif,
            TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
            { Position = initialPos }
        )
        tween.Completed:Connect(function()
            Notif:Destroy()
        end)
        tween:Play()
    end)
end

--// ======================== CREACIÓN DE LA INTERFAZ PREMIUM ========================
pcall(createNotificationSystem)

local ScreenGui = Instance.new('ScreenGui', CoreGui)
ScreenGui.Name = 'UltimateMenuPremium_v4'
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local MainFrame = Instance.new('Frame', ScreenGui)
MainFrame.Size = UDim2.new(0, 208, 0, 420)
MainFrame.Position = UDim2.new(0.5, -250, 1.5, 0)
MainFrame.BackgroundColor3 = Config.Theme.Background
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Visible = false
local MainCorner = Instance.new('UICorner', MainFrame)
MainCorner.CornerRadius = UDim.new(0, 16)
local MainStroke = Instance.new('UIStroke', MainFrame)
MainStroke.Color = Config.Theme.Primary
MainStroke.Thickness = 1.5
MainStroke.Transparency = 0.5
local MainGradient = Instance.new('UIGradient', MainFrame)
MainGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Config.Theme.Background),
    ColorSequenceKeypoint.new(0.5, Config.Theme.Surface),
    ColorSequenceKeypoint.new(1, Config.Theme.Background),
})
MainGradient.Rotation = 45

local Header = Instance.new('Frame', MainFrame)
Header.Size = UDim2.new(1, 0, 0, 60)
Header.BackgroundColor3 = Config.Theme.Surface
Header.BorderSizePixel = 0
local HeaderCorner = Instance.new('UICorner', Header)
HeaderCorner.CornerRadius = UDim.new(0, 16)
local HeaderBottomCorner = Instance.new('UICorner', Header)
HeaderBottomCorner.CornerRadius = UDim.new(0, 0)

local Title = Instance.new('TextLabel', Header)
Title.Size = UDim2.new(1, -50, 1, 0)
Title.Position = UDim2.new(0, 20, 0, 0)
Title.Text = '⚡Bring Hub'
Title.Font = Enum.Font.GothamBlack
Title.TextSize = 20
Title.TextColor3 = Config.Theme.Text
Title.BackgroundTransparency = 1
Title.TextXAlignment = Enum.TextXAlignment.Left

local CloseButton = Instance.new('TextButton', Header)
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Position = UDim2.new(1, -45, 0.5, -15)
CloseButton.Text = '❌'
CloseButton.TextSize = 20
CloseButton.Font = Enum.Font.GothamBold
CloseButton.TextColor3 = Config.Theme.Text
CloseButton.BackgroundColor3 = Config.Theme.Error
CloseButton.BackgroundTransparency = 0.4
local CloseCorner = Instance.new('UICorner', CloseButton)
CloseCorner.CornerRadius = UDim.new(0, 8)

local TabContainer = Instance.new('Frame', MainFrame)
TabContainer.Size = UDim2.new(1, -20, 0, 40)
TabContainer.Position = UDim2.new(0, 10, 0, 70)
TabContainer.BackgroundTransparency = 1
local TabLayout = Instance.new('UIListLayout', TabContainer)
TabLayout.FillDirection = Enum.FillDirection.Horizontal
TabLayout.Padding = UDim.new(0, 8)

local ContentContainer = Instance.new('Frame', MainFrame)
ContentContainer.Size = UDim2.new(1, -20, 1, -185)
ContentContainer.Position = UDim2.new(0, 10, 0, 120)
ContentContainer.BackgroundColor3 = Config.Theme.Surface
ContentContainer.BackgroundTransparency = 0.5
local ContentCorner = Instance.new('UICorner', ContentContainer)
ContentCorner.CornerRadius = UDim.new(0, 12)

local UserPanel = Instance.new('Frame', MainFrame)
UserPanel.Size = UDim2.new(1, -20, 0, 55)
UserPanel.Position = UDim2.new(0, 10, 1, -65)
UserPanel.BackgroundColor3 = Config.Theme.Surface
local UserCorner = Instance.new('UICorner', UserPanel)
UserCorner.CornerRadius = UDim.new(0, 12)
local UserStroke = Instance.new('UIStroke', UserPanel)
UserStroke.Color = Config.Theme.Primary
UserStroke.Thickness = 1
UserStroke.Transparency = 0.7

local AvatarFrame = Instance.new('Frame', UserPanel)
AvatarFrame.Size = UDim2.new(0, 45, 0, 45)
AvatarFrame.Position = UDim2.new(0, 5, 0.5, -22.5)
AvatarFrame.BackgroundColor3 = Config.Theme.Primary
local AvatarCorner = Instance.new('UICorner', AvatarFrame)
AvatarCorner.CornerRadius = UDim.new(1, 0)
local Avatar = Instance.new('ImageLabel', AvatarFrame)
Avatar.Size = UDim2.new(1, -4, 1, -4)
Avatar.Position = UDim2.new(0, 2, 0, 2)
Avatar.BackgroundTransparency = 1
local content, isReady = Players:GetUserThumbnailAsync(
    LocalPlayer.UserId,
    Enum.ThumbnailType.HeadShot,
    Enum.ThumbnailSize.Size150x150
)
Avatar.Image = content
local AvatarInnerCorner = Instance.new('UICorner', Avatar)
AvatarInnerCorner.CornerRadius = UDim.new(1, 0)

local UserName = Instance.new('TextLabel', UserPanel)
UserName.Size = UDim2.new(1, -70, 0, 20)
UserName.Position = UDim2.new(0, 55, 0, 8)
UserName.Text = LocalPlayer.DisplayName
UserName.Font = Enum.Font.GothamBold
UserName.TextSize = 15
UserName.TextColor3 = Config.Theme.Text
UserName.BackgroundTransparency = 1
UserName.TextXAlignment = Enum.TextXAlignment.Left
local UserId = Instance.new('TextLabel', UserPanel)
UserId.Size = UDim2.new(1, -70, 0, 18)
UserId.Position = UDim2.new(0, 55, 0, 28)
UserId.Text = '@' .. LocalPlayer.Name
UserId.Font = Enum.Font.Gotham
UserId.TextSize = 12
UserId.TextColor3 = Config.Theme.TextSecondary
UserId.BackgroundTransparency = 1
UserId.TextXAlignment = Enum.TextXAlignment.Left

local StatusDot = Instance.new('Frame', UserPanel)
StatusDot.Size = UDim2.new(0, 10, 0, 10)
StatusDot.Position = UDim2.new(1, -25, 0.5, -5)
StatusDot.BackgroundColor3 = Config.Theme.Success
local StatusCorner = Instance.new('UICorner', StatusDot)
StatusCorner.CornerRadius = UDim.new(1, 0)
local pulseConnection
pulseConnection = RunService.Heartbeat:Connect(function()
    if StatusDot and StatusDot.Parent then
        local time = tick()
        local pulse = math.sin(time * 5) * 0.3 + 0.7
        StatusDot.BackgroundTransparency = 1 - pulse
    else
        pulseConnection:Disconnect()
    end
end)
ScreenGui.Destroying:Connect(function()
    if pulseConnection then
        pulseConnection:Disconnect()
    end
end)

--// ======================== SISTEMA DE PESTAÑAS PREMIUM ========================
local tabs = {}
local activeTab = nil
function switchTab(tabName)
    if activeTab == tabName then
        return
    end
    for name, data in pairs(tabs) do
        local isActive = (name == tabName)
        TweenService
            :Create(data.button, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {
                BackgroundColor3 = isActive and Config.Theme.Primary
                    or Config.Theme.Surface,
                TextColor3 = isActive and Config.Theme.Text
                    or Config.Theme.TextSecondary,
            })
            :Play()
        TweenService:Create(data.stroke, TweenInfo.new(0.3), {
            Thickness = isActive and 1.5 or 0,
            Transparency = isActive and 0 or 1,
        }):Play()
        if isActive then
            data.content.Visible = true
            TweenService:Create(
                data.content,
                TweenInfo.new(0.3, Enum.EasingStyle.Quart),
                { GroupTransparency = 0 }
            ):Play()
        else
            local tween = TweenService:Create(
                data.content,
                TweenInfo.new(0.2, Enum.EasingStyle.Quart),
                { GroupTransparency = 1 }
            )
            tween.Completed:Connect(function()
                if activeTab ~= name then
                    data.content.Visible = false
                end
            end)
            tween:Play()
        end
    end
    activeTab = tabName
end
local function createTab(name, icon)
    local content = Instance.new('CanvasGroup', ContentContainer)
    content.Size = UDim2.fromScale(1, 1)
    content.BackgroundTransparency = 1
    content.Visible = false
    content.GroupTransparency = 1
    -- [FIX] Resized buttons to fit 5 tabs
    local button = Instance.new('TextButton', TabContainer)
    button.Size = UDim2.new(0, 89, 1, 0)
    button.Text = icon .. ' ' .. name
    button.Font = Enum.Font.GothamBold
    button.TextSize = 14
    button.TextColor3 = Config.Theme.TextSecondary
    button.BackgroundColor3 = Config.Theme.Surface
    local btnCorner = Instance.new('UICorner', button)
    btnCorner.CornerRadius = UDim.new(0, 8)
    local btnStroke = Instance.new('UIStroke', button)
    btnStroke.Color = Config.Theme.Primary
    btnStroke.Thickness = 0
    btnStroke.Transparency = 1
    button.MouseButton1Click:Connect(function()
        switchTab(name)
    end)
    tabs[name] = { button = button, content = content, stroke = btnStroke }
    return content
end

local bringTab = createTab('Bring', '🎯')
local settingsTab = createTab('Settings', '⚙️')
local function createInput(parent, placeholder, yPos)
    local search = Instance.new('TextBox', parent)
    search.Size = UDim2.new(1, -20, 0, 40)
    search.Position = UDim2.new(0, 10, 0, yPos)
    search.PlaceholderText = placeholder
    search.Font = Enum.Font.Gotham
    search.TextSize = 14
    search.TextColor3 = Config.Theme.Text
    search.BackgroundColor3 = Config.Theme.Background
    search.PlaceholderColor3 = Config.Theme.TextSecondary
    local corner = Instance.new('UICorner', search)
    corner.CornerRadius = UDim.new(0, 10)
    return search
end
local function createItemContainer(parent)
    local scroll = Instance.new('ScrollingFrame', parent)
    scroll.Size = UDim2.new(1, 0, 1, -105)
    scroll.Position = UDim2.new(0, 0, 0, 60)
    scroll.BackgroundTransparency = 1
    scroll.BorderSizePixel = 0
    scroll.ScrollBarThickness = 5
    scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    local layout = Instance.new('UIListLayout', scroll)
    layout.Padding = UDim.new(0, 8)
    layout.SortOrder = Enum.SortOrder.Name
    return scroll
end

--// ======================== CONTENIDO DE PESTAÑAS ========================
local BringSearch = createInput(bringTab, '🔍 Buscar items...', 10)
local BringContainer = createItemContainer(bringTab)
local BringAllBtn = Instance.new('TextButton', bringTab)
BringAllBtn.Size = UDim2.new(1, -20, 0, 45)
BringAllBtn.Position = UDim2.new(0, 10, 1, -45)
BringAllBtn.Text = '⚡ ดึงของที่ค้นหา'
BringAllBtn.Font = Enum.Font.GothamBold
BringAllBtn.TextSize = 15
BringAllBtn.TextColor3 = Config.Theme.Text
BringAllBtn.BackgroundColor3 = Config.Theme.Primary
BringAllBtn.Visible = false
local BringAllCorner = Instance.new('UICorner', BringAllBtn)
BringAllCorner.CornerRadius = UDim.new(0, 10)

local TpSearch = createInput(tpTab, '🔍 Buscar destino...', 10)
local TpContainer = createItemContainer(tpTab)
local ScrapperBtn = Instance.new('TextButton', tpTab)
ScrapperBtn.Size = UDim2.new(1, -20, 0, 45)
ScrapperBtn.Position = UDim2.new(0, 10, 1, -45)
ScrapperBtn.Text = '🏭 Teleport al Scrapper'
ScrapperBtn.Font = Enum.Font.GothamBold
ScrapperBtn.TextSize = 16
ScrapperBtn.TextColor3 = Config.Theme.Text
ScrapperBtn.BackgroundColor3 = Config.Theme.Secondary
local ScrapperCorner = Instance.new('UICorner', ScrapperBtn)
ScrapperCorner.CornerRadius = UDim.new(0, 10)

local AuraToggle = Instance.new('TextButton', auraTab)
AuraToggle.Size = UDim2.new(1, -20, 0, 45)
AuraToggle.Position = UDim2.new(0, 10, 0, 10)
AuraToggle.Text = '🔴 AURA DESACTIVADA'
AuraToggle.Font = Enum.Font.GothamBold
AuraToggle.TextSize = 16
AuraToggle.TextColor3 = Config.Theme.Text
AuraToggle.BackgroundColor3 = Config.Theme.Error
local AuraToggleCorner = Instance.new('UICorner', AuraToggle)
AuraToggleCorner.CornerRadius = UDim.new(0, 10)
local function createAuraInput(parent, yPos, labelText, defaultValue)
    local frame = Instance.new('Frame', parent)
    frame.Size = UDim2.new(1, -20, 0, 40)
    frame.Position = UDim2.new(0, 10, 0, yPos)
    frame.BackgroundTransparency = 1
    local label = Instance.new('TextLabel', frame)
    label.Size = UDim2.new(0.6, 0, 1, 0)
    label.Text = labelText
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.TextColor3 = Config.Theme.TextSecondary
    label.BackgroundTransparency = 1
    label.TextXAlignment = Enum.TextXAlignment.Left
    local input = Instance.new('TextBox', frame)
    input.Size = UDim2.new(0.4, -10, 1, 0)
    input.Position = UDim2.new(0.6, 10, 0, 0)
    input.Text = tostring(defaultValue)
    input.Font = Enum.Font.GothamBold
    input.TextSize = 14
    input.TextColor3 = Config.Theme.Text
    input.BackgroundColor3 = Config.Theme.Background
    local c = Instance.new('UICorner', input)
    c.CornerRadius = UDim.new(0, 8)
    return input
end

local RangeInput =
    createAuraInput(auraTab, 65, '📏 Rango (studs)', Config.KillAura.Range)
local SpeedInput = createAuraInput(
    auraTab,
    110,
    '⚡ Velocidad de Ataque (s)',
    Config.KillAura.Interval
)

-- [MODIFICADO] Se crean los inputs para el arma y el argumento.
local WeaponInput = createInput(auraTab, '🗡️ Nombre del Arma...', 155)
WeaponInput.Text = Config.KillAura.WeaponName

local ArgInput =
    createInput(auraTab, '🔑 Argumento del Arma (Avanzado)...', 205)
ArgInput.Text = Config.KillAura.StaticArg3

local WeaponApply = Instance.new('TextButton', auraTab)
WeaponApply.Size = UDim2.new(1, -20, 0, 40)
WeaponApply.Position = UDim2.new(0, 10, 0, 255)
WeaponApply.Text = '✅ APLICAR Y GUARDAR ARMA'
WeaponApply.Font = Enum.Font.GothamBold
WeaponApply.TextSize = 14
WeaponApply.TextColor3 = Config.Theme.Text
WeaponApply.BackgroundColor3 = Config.Theme.Success
local wac = Instance.new('UICorner', WeaponApply)
wac.CornerRadius = UDim.new(0, 8)

local function createSettingToggle(
    parent,
    yPos,
    textOn,
    textOff,
    configTable,
    configKey,
    colorOn,
    colorOff
)
    local button = Instance.new('TextButton', parent)
    button.Size = UDim2.new(1, -20, 0, 45)
    button.Position = UDim2.new(0, 10, 0, yPos)
    button.Font = Enum.Font.GothamBold
    button.TextSize = 15
    button.TextColor3 = Config.Theme.Text
    local function update()
        button.Text = configTable[configKey] and textOn or textOff
        button.BackgroundColor3 = configTable[configKey] and colorOn or colorOff
    end
    button.MouseButton1Click:Connect(function()
        configTable[configKey] = not configTable[configKey]
        update()
    end)
    local corner = Instance.new('UICorner', button)
    corner.CornerRadius = UDim.new(0, 10)
    update()
    return button
end
createSettingToggle(
    settingsTab,
    10,
    '🔔 การแจ้งเตือน: เปิด',
    '🔔 การแจ้งเตือน: ปิด',
    Config.UI,
    'EnableNotifications',
    Config.Theme.Success,
    Config.Theme.Error
)
createSettingToggle(
    settingsTab,
    65,
    '✨ เอฟเฟกต์ภาพ: เปิด',
    '✨ เอฟเฟกต์ภาพ: ปิด',
    Config.KillAura,
    'VisualEffects',
    Config.Theme.Success,
    Config.Theme.Error
)
local DiscordBtn = Instance.new('TextButton', settingsTab)
DiscordBtn.Size = UDim2.new(1, -20, 0, 45)
DiscordBtn.Position = UDim2.new(0, 10, 0, 120)
DiscordBtn.Text = '💬 ไม่ต้องกดหรอก'
DiscordBtn.Font = Enum.Font.GothamBold
DiscordBtn.TextSize = 15
DiscordBtn.TextColor3 = Config.Theme.Text
DiscordBtn.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
local DiscordCorner = Instance.new('UICorner', DiscordBtn)
DiscordCorner.CornerRadius = UDim.new(0, 10)

--// ======================== LÓGICA DE FUNCIONALIDAD ========================
local BringButtons = {}
local TpButtons = {}
local function getObjectPosition(object)
    if object:IsA('Model') and object.PrimaryPart then
        return object.PrimaryPart.CFrame
    elseif object:IsA('BasePart') then
        return object.CFrame
    end
    return nil
end
local function moveObject(object, cframe)
    if object:IsA('Model') and object.PrimaryPart then
        object:SetPrimaryPartCFrame(cframe)
    elseif object:IsA('BasePart') then
        object.CFrame = cframe
    end
end

local function bringItem(targetItem)
    local char = LocalPlayer.Character
    local rootPart = char and char:FindFirstChild('HumanoidRootPart')
    if not rootPart then
        notify('error', 'Personaje no encontrado.')
        return
    end
    local originalCFrame = getObjectPosition(targetItem)
    if not originalCFrame then
        return
    end

    moveObject(targetItem, rootPart.CFrame * CFrame.new(0, 3, -5))
    notify('success', "ดึงไอเท็ม '" .. targetItem.Name .. "'...")

    -- [FIX] Fire events to "unstuck" the item by simulating a quick grab and release
    pcall(function()
        local startDragEvent = ReplicatedStorage:WaitForChild('RemoteEvents')
            :WaitForChild('RequestStartDraggingItem')
        local stopDragEvent = ReplicatedStorage:WaitForChild('RemoteEvents')
            :WaitForChild('StopDraggingItem')
        startDragEvent:FireServer(targetItem)
        task.wait(0.1) -- Small delay to ensure server processes the start event
        stopDragEvent:FireServer(targetItem)
    end)

    task.delay(1.5, function()
        if not targetItem or not targetItem.Parent then
            return
        end
        local currentCFrame = getObjectPosition(targetItem)
        if
            currentCFrame
            and (currentCFrame.Position - originalCFrame.Position).Magnitude
                < 2
        then
            notify(
                'warning',
                "ตรวจพบโปรแกรมป้องกันการโกงใน '" .. targetItem.Name .. "'!"
            )
        end
    end)
end
local function teleportToItem(targetItem)
    local char = LocalPlayer.Character
    local rootPart = char and char:FindFirstChild('HumanoidRootPart')
    local itemPos = getObjectPosition(targetItem)
    if rootPart and itemPos then
        rootPart.CFrame = itemPos * CFrame.new(0, 4, 0)
        notify('success', "Teletransportado a '" .. targetItem.Name .. "'")
    else
        notify('error', 'No se pudo teletransportar.')
    end
end

-- [NEW] Helper function to create a player stat slider
local function createSlider(
    parent,
    yPos,
    title,
    minVal,
    maxVal,
    defaultVal,
    property
)
    local frame = Instance.new('Frame', parent)
    frame.Size = UDim2.new(1, -20, 0, 60)
    frame.Position = UDim2.new(0, 10, 0, yPos)
    frame.BackgroundTransparency = 1

    local label = Instance.new('TextLabel', frame)
    label.Size = UDim2.new(0.7, 0, 0, 25)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.Font = Enum.Font.GothamBold
    label.TextSize = 15
    label.TextColor3 = Config.Theme.Text
    label.BackgroundTransparency = 1
    label.TextXAlignment = Enum.TextXAlignment.Left

    local resetButton = Instance.new('TextButton', frame)
    resetButton.Size = UDim2.new(0.3, -10, 0, 25)
    resetButton.Position = UDim2.new(0.7, 10, 0, 0)
    resetButton.Text = 'Reset'
    resetButton.Font = Enum.Font.Gotham
    resetButton.TextSize = 13
    resetButton.TextColor3 = Config.Theme.Text
    resetButton.BackgroundColor3 = Config.Theme.Secondary
    local resetCorner = Instance.new('UICorner', resetButton)
    resetCorner.CornerRadius = UDim.new(0, 6)

    local sliderBg = Instance.new('Frame', frame)
    sliderBg.Size = UDim2.new(1, 0, 0, 8)
    sliderBg.Position = UDim2.new(0, 0, 0, 35)
    sliderBg.BackgroundColor3 = Config.Theme.Background
    local bgCorner = Instance.new('UICorner', sliderBg)
    bgCorner.CornerRadius = UDim.new(1, 0)

    local sliderFill = Instance.new('Frame', sliderBg)
    sliderFill.Size = UDim2.new(0, 0, 1, 0)
    sliderFill.BackgroundColor3 = Config.Theme.Primary
    local fillCorner = Instance.new('UICorner', sliderFill)
    fillCorner.CornerRadius = UDim.new(1, 0)

    local humanoid
    local function setHumanoid(char)
        humanoid = char and char:FindFirstChildOfClass('Humanoid')
    end
    setHumanoid(LocalPlayer.Character)

    local function updateProperty(value)
        if humanoid then
            humanoid[property] = value
            label.Text = string.format('%s: %.0f', title, value)
        end
    end

    local function updateSliderFromValue(value)
        local percentage = (value - minVal) / (maxVal - minVal)
        sliderFill.Size = UDim2.new(math.clamp(percentage, 0, 1), 0, 1, 0)
        updateProperty(value)
    end

    updateSliderFromValue(humanoid and humanoid[property] or defaultVal)

    resetButton.MouseButton1Click:Connect(function()
        updateSliderFromValue(defaultVal)
    end)

    local dragging = false
    local function onInput(input)
        if dragging then
            local mouseX = input.Position.X
            local bgAbsPos = sliderBg.AbsolutePosition.X
            local bgAbsSize = sliderBg.AbsoluteSize.X
            local percentage = math.clamp((mouseX - bgAbsPos) / bgAbsSize, 0, 1)
            local value = minVal + (maxVal - minVal) * percentage
            sliderFill.Size = UDim2.new(percentage, 0, 1, 0)
            updateProperty(value)
        end
    end

    sliderBg.InputBegan:Connect(function(input)
        if
            input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch
        then
            dragging = true
            onInput(input)
        end
    end)
    sliderBg.InputEnded:Connect(function(input)
        if
            input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch
        then
            dragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if
            input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch
        then
            onInput(input)
        end
    end)

    LocalPlayer.CharacterAdded:Connect(function(char)
        setHumanoid(char)
        updateSliderFromValue(humanoid and humanoid[property] or defaultVal)
    end)
end

-- [NEW] Add content to Misc tab
createSlider(miscTab, 10, '🏃 WalkSpeed', 16, 100, 16, 'WalkSpeed')
createSlider(miscTab, 80, '🤸 JumpPower', 50, 200, 50, 'JumpPower')

local function createItemButton(item, text, parent, callback, type)
    local btn = Instance.new('TextButton', parent)
    btn.Name = text
    btn.Size = UDim2.new(1, 0, 0, 40)
    btn.Text = '  ' .. (type == 'bring' and '🎯 ' or '🚀 ') .. text
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 14
    btn.TextColor3 = Config.Theme.Text
    btn.BackgroundColor3 = Config.Theme.Surface
    btn.TextXAlignment = Enum.TextXAlignment.Left
    local btnCorner = Instance.new('UICorner', btn)
    btnCorner.CornerRadius = UDim.new(0, 8)
    btn.MouseButton1Click:Connect(function()
        callback(item)
    end)
    return btn
end
local function setupSearch(searchBox, buttonDict, allButton)
    return function()
        local query = string.lower(searchBox.Text)
        local visible = 0
        for item, btn in pairs(buttonDict) do
            local isVisible = (query == '')
                or string.find(string.lower(item.Name), query, 1, true)
            btn.Visible = isVisible
            if isVisible then
                visible += 1
            end
        end
        if allButton then
            allButton.Visible = (query ~= '' and visible > 0)
        end
    end
end
local updateBringSearch = setupSearch(BringSearch, BringButtons, BringAllBtn)
local updateTpSearch = setupSearch(TpSearch, TpButtons, nil)
BringSearch:GetPropertyChangedSignal('Text'):Connect(updateBringSearch)
TpSearch:GetPropertyChangedSignal('Text'):Connect(updateTpSearch)

local function onItemAdded(item)
    pcall(function()
        if not getObjectPosition(item) or BringButtons[item] then
            return
        end
        BringButtons[item] = createItemButton(
            item,
            item.Name,
            BringContainer,
            bringItem,
            'bring'
        )
        TpButtons[item] =
            createItemButton(item, item.Name, TpContainer, teleportToItem, 'tp')
        updateBringSearch()
        updateTpSearch()
    end)
end
local function onItemRemoved(item)
    pcall(function()
        if BringButtons[item] then
            BringButtons[item]:Destroy()
            BringButtons[item] = nil
        end
        if TpButtons[item] then
            TpButtons[item]:Destroy()
            TpButtons[item] = nil
        end
        updateBringSearch()
        updateTpSearch()
    end)
end

BringAllBtn.MouseButton1Click:Connect(function()
    local count = 0
    for item, btn in pairs(BringButtons) do
        if btn.Visible then
            count += 1
            bringItem(item)
            task.wait(0.1)
        end
    end
    notify('success', 'Trayendo ' .. count .. ' items.')
end)
ScrapperBtn.MouseButton1Click:Connect(function()
    pcall(function()
        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild('HumanoidRootPart')
        local target = Workspace.Map.Campground.Scrapper.DashedLine
        if root and target then
            root.CFrame = target.CFrame * CFrame.new(0, 5, 0)
            notify('success', 'Teletransportado al Scrapper.')
        else
            notify('error', 'Scrapper no encontrado.')
        end
    end)
end)
AuraToggle.MouseButton1Click:Connect(function()
    Config.KillAura.IsEnabled = not Config.KillAura.IsEnabled
    local enabled = Config.KillAura.IsEnabled
    AuraToggle.Text = enabled and '🟢 AURA ACTIVADA'
        or '🔴 AURA DESACTIVADA'
    AuraToggle.BackgroundColor3 = enabled and Config.Theme.Success
        or Config.Theme.Error
    if enabled then
        local i = LocalPlayer:FindFirstChild('Inventory')
        if not (i and i:FindFirstChild(Config.KillAura.WeaponName)) then
            Config.KillAura.IsEnabled = false
            AuraToggle.Text = '🔴 AURA DESACTIVADA'
            AuraToggle.BackgroundColor3 = Config.Theme.Error
            notify(
                'error',
                "Arma '" .. Config.KillAura.WeaponName .. "' no encontrada."
            )
            return
        end
        notify(
            'success',
            "Aura activada con '" .. Config.KillAura.WeaponName .. "'"
        )
    else
        notify('info', 'Aura desactivada.')
    end
end)
local function handleInput(inputBox, configKey, name, isNumeric)
    inputBox.FocusLost:Connect(function(enter)
        if not enter then
            return
        end
        local text = inputBox.Text
        local value = isNumeric and tonumber(text)
        if isNumeric and (not value or value <= 0) then
            notify('error', 'Valor inválido para ' .. name)
            inputBox.Text = tostring(Config.KillAura[configKey])
            return
        end
        Config.KillAura[configKey] = isNumeric and value or text
        notify('success', name .. ' actualizado a ' .. text)
    end)
end
handleInput(RangeInput, 'Range', 'Rango', true)
handleInput(SpeedInput, 'Interval', 'Velocidad', true)

-- [MODIFICADO] El botón ahora guarda el nombre del arma y el nuevo argumento.
WeaponApply.MouseButton1Click:Connect(function()
    local weaponName = WeaponInput.Text
    local weaponArg = ArgInput.Text

    if not weaponName or weaponName == '' then
        notify('error', 'El nombre del arma no puede estar vacío.')
        return
    end

    local i = LocalPlayer:FindFirstChild('Inventory')
    if i and i:FindFirstChild(weaponName) then
        Config.KillAura.WeaponName = weaponName
        Config.KillAura.StaticArg3 = weaponArg
        notify('success', "Arma actualizada a '" .. weaponName .. "'")
        notify('info', "Argumento actualizado a '" .. weaponArg .. "'")
    else
        notify(
            'error',
            "Arma '" .. weaponName .. "' no encontrada en el inventario."
        )
    end
end)

DiscordBtn.MouseButton1Click:Connect(function()
    pcall(function()
        setclipboard('No disponible')
    end)
    notify('success', 'กดทำไมจ๊ะ ไม่มีไรหรอก อิอิ!!')
end)

task.spawn(function()
    local remoteEvent = ReplicatedStorage:WaitForChild('RemoteEvents')
        :WaitForChild('ToolDamageObject')
    while true do
        task.wait(Config.KillAura.Interval)
        if Config.KillAura.IsEnabled then
            local char = LocalPlayer.Character
            local root = char and char:FindFirstChild('HumanoidRootPart')
            local inv = LocalPlayer:FindFirstChild('Inventory')
            local weapon = inv
                and inv:FindFirstChild(Config.KillAura.WeaponName)
            if not (root and weapon) then
                if Config.KillAura.IsEnabled then
                    Config.KillAura.IsEnabled = false
                    AuraToggle.Text = '🔴 AURA DESACTIVADA'
                    AuraToggle.BackgroundColor3 = Config.Theme.Error
                    notify('warning', 'Aura desactivada, arma perdida.')
                end
                continue
            end
            for _, target in ipairs(Config.KillAura.TargetFolder:GetChildren()) do
                if target:IsA('Model') and target ~= char then
                    local h = target:FindFirstChildOfClass('Humanoid')
                    local tr = target:FindFirstChild('HumanoidRootPart')
                    if
                        h
                        and tr
                        and h.Health > 0
                        and (root.Position - tr.Position).Magnitude
                            <= Config.KillAura.Range
                    then
                        pcall(function()
                            remoteEvent:InvokeServer(
                                target,
                                weapon,
                                Config.KillAura.StaticArg3, -- Ahora usa el valor guardado
                                tr.CFrame
                            )
                        end)
                    end
                end
            end
        end
    end
end)

local isOpen = false
local function toggleMenu()
    isOpen = not isOpen
    local targetPos = isOpen and UDim2.new(0.5, -250, 0.5, -260)
        or UDim2.new(0.5, -250, 1.5, 0)
    local tweenInfo =
        TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    if isOpen then
        MainFrame.Visible = true
    end
    local tween =
        TweenService:Create(MainFrame, tweenInfo, { Position = targetPos })
    tween.Completed:Connect(function()
        if not isOpen then
            MainFrame.Visible = false
        end
    end)
    tween:Play()
end

CloseButton.MouseButton1Click:Connect(toggleMenu)

--// ======================== GESTIÓN DE ENTRADA (PC & MÓVIL) ========================
if UserInputService.TouchEnabled then
    -- Es un dispositivo móvil, crear un botón dedicado para abrir/cerrar el menú.
    local MobileToggleButton = Instance.new('TextButton', ScreenGui)
    MobileToggleButton.Name = "MobileToggle"
    MobileToggleButton.Size = UDim2.new(0, 60, 0, 60)
    MobileToggleButton.Position = UDim2.new(1, -75, 1, -75) -- Esquina inferior derecha
    MobileToggleButton.ZIndex = 10
    MobileToggleButton.Text = "⭕"
    MobileToggleButton.Font = Enum.Font.GothamBold
    MobileToggleButton.TextSize = 32
    MobileToggleButton.TextColor3 = Config.Theme.Text
    MobileToggleButton.BackgroundColor3 = Config.Theme.Primary
    MobileToggleButton.AutoButtonColor = false

    local mtCorner = Instance.new("UICorner", MobileToggleButton)
    mtCorner.CornerRadius = UDim.new(0, 12)
    local mtStroke = Instance.new("UIStroke", MobileToggleButton)
    mtStroke.Color = Config.Theme.Text
    mtStroke.Thickness = 1.5

    -- [NUEVO] Lógica para que el botón sea arrastrable y maneje clics.
    local dragConnection = nil
    local endConnection = nil

    MobileToggleButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
            local startPosition = input.Position
            local startFramePosition = MobileToggleButton.Position
            local wasDragged = false

            -- Desconectar cualquier conexión previa para evitar duplicados
            if dragConnection then dragConnection:Disconnect() end
            if endConnection then endConnection:Disconnect() end

            dragConnection = UserInputService.InputChanged:Connect(function(changedInput)
                if changedInput.UserInputType == input.UserInputType then
                    local delta = changedInput.Position - startPosition
                    MobileToggleButton.Position = UDim2.new(startFramePosition.X.Scale, startFramePosition.X.Offset + delta.X, startFramePosition.Y.Scale, startFramePosition.Y.Offset + delta.Y)
                    
                    if not wasDragged and delta.Magnitude > 5 then -- Umbral para considerar arrastre
                        wasDragged = true
                    end
                end
            end)

            endConnection = UserInputService.InputEnded:Connect(function(endedInput)
                if endedInput.UserInputType == input.UserInputType then
                    dragConnection:Disconnect()
                    endConnection:Disconnect()
                    
                    if not wasDragged then
                        toggleMenu()
                    end
                end
            end)
        end
    end)
else
    -- Es PC, usar la tecla 'G' como antes.
    UserInputService.InputBegan:Connect(function(input, gp)
        if gp or UserInputService:GetFocusedTextBox() then
            return
        end
        if input.KeyCode == Enum.KeyCode.G then
            toggleMenu()
        end
    end)
end

local function Initialize()
    notify('success', 'ยินดีต้อนรับคุณ, ' .. LocalPlayer.DisplayName .. '!')
    
    -- Muestra la notificación de cómo abrir el menú según la plataforma
    if UserInputService.TouchEnabled then
        notify('info', 'แตะปุ่ม ⭕ เพื่อเปิดเมนู')
    else
        notify('info', 'ขอบคุณที่ใช่สคริป')
    end
    local itemsFolder = Workspace:FindFirstChild(Config.ItemsList.FolderName)
    if itemsFolder then
        itemsFolder.ChildAdded:Connect(onItemAdded)
        itemsFolder.ChildRemoved:Connect(onItemRemoved)
        for _, item in ipairs(itemsFolder:GetChildren()) do
            onItemAdded(item)
        end
        notify('success', #itemsFolder:GetChildren() .. ' items โหลดแล้ว.')
    else
        notify('warning', 'ไม่พบโฟลเดอร์รายการ')
    end
    switchTab('Bring')
    task.spawn(function()
        while MainFrame and MainFrame.Parent do
            for i = 0, 360, 2 do
                MainGradient.Rotation = i
                task.wait()
            end
        end
    end)
end

pcall(Initialize)

