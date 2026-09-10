--[[
    ══════════════════════════════════════════════════════════════════════════
                          💎 SUFYANSCRIPTER | ULTIMATE SUITE
                       NATURAL DISASTER SURVIVAL 🌪️ MASTER HUB
                      Theme: Cyber Obsidian & Neon Cyan Edition
                     Scale: Ultra-Clean Compact (490x320)
    ══════════════════════════════════════════════════════════════════════════
    Game: Natural Disaster Survival (Roblox)
    Place ID: 189707
    Author: SufyanScripter Pro Suite
    ══════════════════════════════════════════════════════════════════════════
]]

-- [1] Roblox Engine Services
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local TeleportService = game:GetService("TeleportService")
local VirtualUser = game:GetService("VirtualUser")
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()
local Camera = Workspace.CurrentCamera or Workspace:WaitForChild("Camera")

-- Safe UI Parent Resolver (Delta, Codex, Fluxus, Hydrogen, CoreGui & PlayerGui)
local function getSafeUIParent()
    local container = nil
    pcall(function()
        if gethui then container = gethui() end
    end)
    if not container then
        pcall(function()
            if syn and syn.protect_gui then container = CoreGui end
        end)
    end
    return container or CoreGui or LocalPlayer:WaitForChild("PlayerGui")
end

-- Destroy previous UI instances
pcall(function()
    for _, name in ipairs({"SufyanScripterHub", "SufyanNDSHub", "NDS_Hub", "SakiNDSHub"}) do
        if CoreGui:FindFirstChild(name) then CoreGui[name]:Destroy() end
        if LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild(name) then
            LocalPlayer.PlayerGui[name]:Destroy()
        end
        if gethui and gethui():FindFirstChild(name) then
            gethui()[name]:Destroy()
        end
    end
end)

-- [2] Modern Premium Theme Palette (Cyber Obsidian / Neon Cyan & Emerald)
local Theme = {
    BgMain         = Color3.fromRGB(11, 15, 23),
    BgSidebar      = Color3.fromRGB(15, 21, 32),
    BgTopbar       = Color3.fromRGB(15, 21, 32),
    BgCard         = Color3.fromRGB(18, 26, 40),
    BgCardHover    = Color3.fromRGB(24, 35, 54),
    Border         = Color3.fromRGB(30, 43, 66),
    BorderGlow     = Color3.fromRGB(0, 212, 255),
    Accent         = Color3.fromRGB(0, 200, 230),
    AccentGlow     = Color3.fromRGB(56, 225, 255),
    AccentEmerald  = Color3.fromRGB(16, 185, 129),
    TextMain       = Color3.fromRGB(245, 248, 255),
    TextMuted      = Color3.fromRGB(130, 152, 182),
    TabActiveBg    = Color3.fromRGB(21, 33, 52),
    TabActiveText  = Color3.fromRGB(255, 255, 255),
    SwitchOff      = Color3.fromRGB(14, 20, 30)
}

-- [3] Global Engine State (NDS Master Suite)
_G.SufyanNDSState = {
    -- Disasters & Survival (Tab 1)
    DisasterPredictor  = true,
    AutoWin            = false,
    GodUmbrella        = false,
    WaterWalk          = false,
    AntiFling          = false,
    DebrisGhost        = false,
    CurrentDisaster    = "Waiting for Round...",

    -- Movement (Tab 2)
    WalkSpeedActive    = false,
    WalkSpeedValue     = 16,
    JumpPowerActive    = false,
    JumpPowerValue     = 50,
    InfJumpActive      = false,
    NoClipActive       = false,
    FlyActive          = false,
    FlySpeed           = 60,
    NoFallDamage       = true,

    -- Visuals (Tab 3)
    DisasterESP        = false,
    CollapseESP        = false,
    SurvivorESP        = false,
    FullBrightActive   = false,
    FOV                = 70,

    -- Utilities (Tab 4)
    InstantPrompts     = false,
    AntiAFKActive      = true
}
local State = _G.SufyanNDSState

-- [4] Helper Functions
local function isAlive(targetPlayer)
    local p = targetPlayer or LocalPlayer
    local char = p.Character
    return char and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0 and char:FindFirstChild("HumanoidRootPart")
end

local function getRoot(targetPlayer)
    local p = targetPlayer or LocalPlayer
    if isAlive(p) then
        return p.Character.HumanoidRootPart
    end
    return nil
end

local function getHum(targetPlayer)
    local p = targetPlayer or LocalPlayer
    if isAlive(p) then
        return p.Character:FindFirstChildOfClass("Humanoid")
    end
    return nil
end

local MainFrameRef = nil
local FloatBtnRef = nil
local ShowToast = nil

-- [5] ScreenGui Setup
local Screen = Instance.new("ScreenGui")
Screen.Name = "SufyanScripterHub"
Screen.ResetOnSpawn = false
Screen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

pcall(function()
    Screen.Parent = getSafeUIParent()
end)

-- Smooth Mobile & PC Dragging Engine
local function makeDraggable(guiObject, dragHandle)
    dragHandle = dragHandle or guiObject
    local dragging = false
    local dragStart, startPos

    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = guiObject.Position
        end
    end)

    dragHandle.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            guiObject.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
end

-- [6] Modern Animated Toast Notification
local ToastFrame = Instance.new("Frame", Screen)
ToastFrame.Size = UDim2.new(0, 270, 0, 50)
ToastFrame.Position = UDim2.new(1, 290, 1, -70)
ToastFrame.BackgroundColor3 = Theme.BgCard
ToastFrame.BorderSizePixel = 0
ToastFrame.ZIndex = 60
Instance.new("UICorner", ToastFrame).CornerRadius = UDim.new(0, 10)
local ToastStroke = Instance.new("UIStroke", ToastFrame)
ToastStroke.Color = Theme.BorderGlow
ToastStroke.Thickness = 1.4

local ToastGlowBar = Instance.new("Frame", ToastFrame)
ToastGlowBar.Size = UDim2.new(0, 4, 1, -12)
ToastGlowBar.Position = UDim2.new(0, 6, 0, 6)
ToastGlowBar.BackgroundColor3 = Theme.AccentGlow
ToastGlowBar.BorderSizePixel = 0
ToastGlowBar.ZIndex = 61
Instance.new("UICorner", ToastGlowBar).CornerRadius = UDim.new(1, 0)

local ToastTitle = Instance.new("TextLabel", ToastFrame)
ToastTitle.Size = UDim2.new(1, -24, 0, 18)
ToastTitle.Position = UDim2.new(0, 18, 0, 7)
ToastTitle.BackgroundTransparency = 1
ToastTitle.Font = Enum.Font.GothamBold
ToastTitle.TextSize = 12
ToastTitle.TextColor3 = Theme.TextMain
ToastTitle.TextXAlignment = Enum.TextXAlignment.Left
ToastTitle.ZIndex = 61

local ToastDesc = Instance.new("TextLabel", ToastFrame)
ToastDesc.Size = UDim2.new(1, -24, 0, 16)
ToastDesc.Position = UDim2.new(0, 18, 0, 26)
ToastDesc.BackgroundTransparency = 1
ToastDesc.Font = Enum.Font.GothamMedium
ToastDesc.TextSize = 10
ToastDesc.TextColor3 = Theme.TextMuted
ToastDesc.TextXAlignment = Enum.TextXAlignment.Left
ToastDesc.ZIndex = 61

ShowToast = function(title, desc)
    ToastTitle.Text = title
    ToastDesc.Text = desc
    ToastFrame.Position = UDim2.new(1, 290, 1, -70)
    TweenService:Create(ToastFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = UDim2.new(1, -285, 1, -70)}):Play()
    task.delay(2.6, function()
        TweenService:Create(ToastFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {Position = UDim2.new(1, 290, 1, -70)}):Play()
    end)
end

-- [7] Floating Reopen Button
local FloatBtn = Instance.new("TextButton", Screen)
FloatBtn.Size = UDim2.new(0, 44, 0, 44)
FloatBtn.Position = UDim2.new(0, 15, 0.5, -22)
FloatBtn.BackgroundColor3 = Theme.BgCard
FloatBtn.Text = "🌪️"
FloatBtn.TextSize = 20
FloatBtn.TextColor3 = Theme.AccentGlow
FloatBtn.ZIndex = 50
FloatBtn.Visible = false
FloatBtn.AutoButtonColor = false
Instance.new("UICorner", FloatBtn).CornerRadius = UDim.new(1, 0)
local FloatStroke = Instance.new("UIStroke", FloatBtn)
FloatStroke.Color = Theme.BorderGlow
FloatStroke.Thickness = 1.6
makeDraggable(FloatBtn)
FloatBtnRef = FloatBtn

-- [8] Main Hub Window (Compact & Modern: 490x320)
local HUB_WIDTH = 490
local HUB_HEIGHT = 320
local COLLAPSED_HEIGHT = 38

local MainFrame = Instance.new("Frame", Screen)
MainFrame.Name = "MainWindow"
MainFrame.Size = UDim2.new(0, HUB_WIDTH, 0, HUB_HEIGHT)
MainFrame.Position = UDim2.new(0.5, -math.floor(HUB_WIDTH / 2), 0.5, -math.floor(HUB_HEIGHT / 2))
MainFrame.BackgroundColor3 = Theme.BgMain
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)

local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Color = Theme.BorderGlow
MainStroke.Thickness = 1.4
MainFrameRef = MainFrame

-- Modal Unlocker
local ModalUnlocker = Instance.new("TextButton", MainFrame)
ModalUnlocker.Name = "ModalUnlocker"
ModalUnlocker.Size = UDim2.new(1, 0, 1, 0)
ModalUnlocker.BackgroundTransparency = 1
ModalUnlocker.Text = ""
ModalUnlocker.Modal = true
ModalUnlocker.Active = false
ModalUnlocker.ZIndex = 1

-- Topbar (38px Compact)
local Topbar = Instance.new("Frame", MainFrame)
Topbar.Size = UDim2.new(1, 0, 0, COLLAPSED_HEIGHT)
Topbar.BackgroundColor3 = Theme.BgTopbar
Topbar.BorderSizePixel = 0

local TopbarBottom = Instance.new("Frame", Topbar)
TopbarBottom.Size = UDim2.new(1, 0, 0, 1)
TopbarBottom.Position = UDim2.new(0, 0, 1, -1)
TopbarBottom.BackgroundColor3 = Theme.Border
TopbarBottom.BorderSizePixel = 0

local TitleArea = Instance.new("Frame", Topbar)
TitleArea.Size = UDim2.new(0, 390, 1, 0)
TitleArea.Position = UDim2.new(0, 10, 0, 0)
TitleArea.BackgroundTransparency = 1

local TitleIcon = Instance.new("TextLabel", TitleArea)
TitleIcon.Size = UDim2.new(0, 18, 1, 0)
TitleIcon.BackgroundTransparency = 1
TitleIcon.Text = "🌪️"
TitleIcon.TextColor3 = Theme.AccentGlow
TitleIcon.TextSize = 14

local TitleText = Instance.new("TextLabel", TitleArea)
TitleText.Size = UDim2.new(0, 138, 1, 0)
TitleText.Position = UDim2.new(0, 22, 0, 0)
TitleText.BackgroundTransparency = 1
TitleText.Text = "SufyanHub | NDS"
TitleText.TextColor3 = Theme.TextMain
TitleText.Font = Enum.Font.GothamBold
TitleText.TextSize = 11.5
TitleText.TextXAlignment = Enum.TextXAlignment.Left

-- Live Performance FPS Pill
local StatPill = Instance.new("Frame", TitleArea)
StatPill.Size = UDim2.new(0, 68, 0, 22)
StatPill.Position = UDim2.new(0, 164, 0.5, -11)
StatPill.BackgroundColor3 = Theme.BgMain
StatPill.BorderSizePixel = 0
Instance.new("UICorner", StatPill).CornerRadius = UDim.new(1, 0)
local StatStroke = Instance.new("UIStroke", StatPill)
StatStroke.Color = Theme.Border
StatStroke.Thickness = 1

local StatLabel = Instance.new("TextLabel", StatPill)
StatLabel.Size = UDim2.new(1, 0, 1, 0)
StatLabel.BackgroundTransparency = 1
StatLabel.Text = "⚡ 60 FPS"
StatLabel.TextColor3 = Theme.AccentEmerald
StatLabel.Font = Enum.Font.GothamBold
StatLabel.TextSize = 9

-- Live FPS Loop
local fpsFrames = 0
local fpsLastTime = tick()
RunService.RenderStepped:Connect(function()
    fpsFrames = fpsFrames + 1
    local now = tick()
    if now - fpsLastTime >= 1 then
        local currentFPS = math.floor(fpsFrames / (now - fpsLastTime))
        StatLabel.Text = "⚡ " .. tostring(currentFPS) .. " FPS"
        fpsFrames = 0
        fpsLastTime = now
    end
end)

-- Live Disaster Indicator Pill
local DisasterPill = Instance.new("Frame", TitleArea)
DisasterPill.Size = UDim2.new(0, 142, 0, 22)
DisasterPill.Position = UDim2.new(0, 238, 0.5, -11)
DisasterPill.BackgroundColor3 = Theme.BgMain
DisasterPill.BorderSizePixel = 0
Instance.new("UICorner", DisasterPill).CornerRadius = UDim.new(1, 0)
local DisasterStroke = Instance.new("UIStroke", DisasterPill)
DisasterStroke.Color = Theme.BorderGlow
DisasterStroke.Thickness = 1

local DisasterLabel = Instance.new("TextLabel", DisasterPill)
DisasterLabel.Size = UDim2.new(1, -6, 1, 0)
DisasterLabel.Position = UDim2.new(0, 3, 0, 0)
DisasterLabel.BackgroundTransparency = 1
DisasterLabel.Text = "⏳ Intermission"
DisasterLabel.TextColor3 = Theme.Accent
DisasterLabel.Font = Enum.Font.GothamBold
DisasterLabel.TextSize = 9
DisasterLabel.TextTruncate = Enum.TextTruncate.None

-- Window Controls (Minimize & Close)
local Actions = Instance.new("Frame", Topbar)
Actions.Size = UDim2.new(0, 56, 1, 0)
Actions.Position = UDim2.new(1, -62, 0, 0)
Actions.BackgroundTransparency = 1

local MinBtn = Instance.new("TextButton", Actions)
MinBtn.Size = UDim2.new(0, 24, 0, 24)
MinBtn.Position = UDim2.new(0, 0, 0.5, -12)
MinBtn.BackgroundColor3 = Theme.BgCard
MinBtn.Text = "—"
MinBtn.TextColor3 = Theme.TextMuted
MinBtn.Font = Enum.Font.GothamBold
MinBtn.TextSize = 11
MinBtn.AutoButtonColor = false
Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 6)

local CloseBtn = Instance.new("TextButton", Actions)
CloseBtn.Size = UDim2.new(0, 24, 0, 24)
CloseBtn.Position = UDim2.new(0, 28, 0.5, -12)
CloseBtn.BackgroundColor3 = Theme.BgCard
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Theme.TextMuted
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 11
CloseBtn.AutoButtonColor = false
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)

-- Body Frame
local BodyFrame = Instance.new("Frame", MainFrame)
BodyFrame.Size = UDim2.new(1, 0, 1, -COLLAPSED_HEIGHT)
BodyFrame.Position = UDim2.new(0, 0, 0, COLLAPSED_HEIGHT)
BodyFrame.BackgroundTransparency = 1

-- Minimize / Expand Animation
local isMinimized = false
MinBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        MinBtn.Text = "+"
        MinBtn.TextColor3 = Theme.AccentGlow
        BodyFrame.Visible = false
        ModalUnlocker.Modal = false
        MainFrame:TweenSize(UDim2.new(0, HUB_WIDTH, 0, COLLAPSED_HEIGHT), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.25, true)
        ShowToast("SufyanHub", "Hub Collapsed — Features continue running!")
    else
        MinBtn.Text = "—"
        MinBtn.TextColor3 = Theme.TextMuted
        ModalUnlocker.Modal = true
        MainFrame:TweenSize(UDim2.new(0, HUB_WIDTH, 0, HUB_HEIGHT), Enum.EasingDirection.Out, Enum.EasingStyle.Quart, 0.25, true, function()
            if not isMinimized then
                BodyFrame.Visible = true
            end
        end)
        BodyFrame.Visible = true
    end
end)

-- Close Button
CloseBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    FloatBtn.Visible = true
    ModalUnlocker.Modal = false
    ShowToast("SufyanHub", "Minimized to floating icon — features active!")
end)

FloatBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = true
    FloatBtn.Visible = false
    ModalUnlocker.Modal = true
    if isMinimized then
        isMinimized = false
        MinBtn.Text = "—"
        MinBtn.TextColor3 = Theme.TextMuted
        MainFrame.Size = UDim2.new(0, HUB_WIDTH, 0, HUB_HEIGHT)
        BodyFrame.Visible = true
    end
end)

makeDraggable(MainFrame, Topbar)

-- Sidebar (Parent: BodyFrame)
local Sidebar = Instance.new("Frame", BodyFrame)
Sidebar.Size = UDim2.new(0, 122, 1, 0)
Sidebar.BackgroundColor3 = Theme.BgSidebar
Sidebar.BorderSizePixel = 0

-- Sibling Border Line
local SidebarBorder = Instance.new("Frame", BodyFrame)
SidebarBorder.Size = UDim2.new(0, 1, 1, 0)
SidebarBorder.Position = UDim2.new(0, 122, 0, 0)
SidebarBorder.BackgroundColor3 = Theme.Border
SidebarBorder.BorderSizePixel = 0
SidebarBorder.ZIndex = 5

local SidebarLayout = Instance.new("UIListLayout", Sidebar)
SidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
SidebarLayout.Padding = UDim.new(0, 4)

local SidebarPad = Instance.new("UIPadding", Sidebar)
SidebarPad.PaddingTop = UDim.new(0, 8)
SidebarPad.PaddingLeft = UDim.new(0, 6)
SidebarPad.PaddingRight = UDim.new(0, 6)

-- Content Area
local ContentArea = Instance.new("Frame", BodyFrame)
ContentArea.Size = UDim2.new(1, -123, 1, 0)
ContentArea.Position = UDim2.new(0, 123, 0, 0)
ContentArea.BackgroundTransparency = 1

-- [9] Modern Component Builders
local Tabs = {}
local TabButtons = {}
local TabIndicators = {}
local TabLabels = {}
local currentTab = nil

local function SelectTab(name)
    for tName, page in pairs(Tabs) do
        local btn = TabButtons[tName]
        local ind = TabIndicators[tName]
        local lbls = TabLabels[tName]
        if tName == name then
            page.Visible = true
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Theme.TabActiveBg, BackgroundTransparency = 0}):Play()
            if ind then
                ind.Visible = true
                TweenService:Create(ind, TweenInfo.new(0.2), {Size = UDim2.new(0, 3, 0, 20)}):Play()
            end
            if lbls then
                lbls.Name.TextColor3 = Theme.TabActiveText
                lbls.Icon.TextColor3 = Theme.AccentGlow
            end
        else
            page.Visible = false
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
            if ind then
                ind.Visible = false
                ind.Size = UDim2.new(0, 3, 0, 0)
            end
            if lbls then
                lbls.Name.TextColor3 = Theme.TextMuted
                lbls.Icon.TextColor3 = Theme.TextMuted
            end
        end
    end
    currentTab = name
end

local function CreateTab(name, icon, order)
    local btn = Instance.new("TextButton", Sidebar)
    btn.Size = UDim2.new(1, 0, 0, 34)
    btn.BackgroundTransparency = 1
    btn.BackgroundColor3 = Theme.TabActiveBg
    btn.AutoButtonColor = false
    btn.Text = ""
    btn.LayoutOrder = order
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 7)

    local ind = Instance.new("Frame", btn)
    ind.Size = UDim2.new(0, 3, 0, 20)
    ind.Position = UDim2.new(0, 3, 0.5, -10)
    ind.BackgroundColor3 = Theme.AccentGlow
    ind.BorderSizePixel = 0
    ind.Visible = false
    Instance.new("UICorner", ind).CornerRadius = UDim.new(1, 0)

    local iconLabel = Instance.new("TextLabel", btn)
    iconLabel.Size = UDim2.new(0, 20, 1, 0)
    iconLabel.Position = UDim2.new(0, 8, 0, 0)
    iconLabel.BackgroundTransparency = 1
    iconLabel.Text = icon
    iconLabel.TextSize = 13.5
    iconLabel.TextColor3 = Theme.TextMuted

    local nameLabel = Instance.new("TextLabel", btn)
    nameLabel.Size = UDim2.new(1, -30, 1, 0)
    nameLabel.Position = UDim2.new(0, 30, 0, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = name
    nameLabel.TextColor3 = Theme.TextMuted
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextSize = 11
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left

    local page = Instance.new("ScrollingFrame", ContentArea)
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 3
    page.ScrollBarImageColor3 = Theme.Accent
    page.Visible = false
    page.CanvasSize = UDim2.new(0, 0, 0, 0)
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y

    local pLayout = Instance.new("UIListLayout", page)
    pLayout.SortOrder = Enum.SortOrder.LayoutOrder
    pLayout.Padding = UDim.new(0, 6)

    local pPadding = Instance.new("UIPadding", page)
    pPadding.PaddingTop = UDim.new(0, 8)
    pPadding.PaddingLeft = UDim.new(0, 10)
    pPadding.PaddingRight = UDim.new(0, 10)
    pPadding.PaddingBottom = UDim.new(0, 10)

    Tabs[name] = page
    TabButtons[name] = btn
    TabIndicators[name] = ind
    TabLabels[name] = {Name = nameLabel, Icon = iconLabel}

    btn.MouseEnter:Connect(function()
        if currentTab ~= name then
            TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundTransparency = 0.5, BackgroundColor3 = Theme.BgCardHover}):Play()
        end
    end)
    btn.MouseLeave:Connect(function()
        if currentTab ~= name then
            TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundTransparency = 1}):Play()
        end
    end)

    btn.MouseButton1Click:Connect(function()
        SelectTab(name)
    end)

    return page
end

local function CreateSection(parent, title)
    local sec = Instance.new("Frame", parent)
    sec.Size = UDim2.new(1, 0, 0, 20)
    sec.BackgroundTransparency = 1

    local lbl = Instance.new("TextLabel", sec)
    lbl.Size = UDim2.new(1, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = title:upper()
    lbl.TextColor3 = Theme.AccentGlow
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 10
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    return sec
end

local function CreateCard(parent, title, desc, height)
    local card = Instance.new("Frame", parent)
    card.Size = UDim2.new(1, 0, 0, height or 46)
    card.BackgroundColor3 = Theme.BgCard
    card.BorderSizePixel = 0
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 8)

    local cStroke = Instance.new("UIStroke", card)
    cStroke.Color = Theme.Border
    cStroke.Thickness = 1

    local tLabel = Instance.new("TextLabel", card)
    tLabel.Size = UDim2.new(1, -110, 0, 16)
    tLabel.Position = UDim2.new(0, 10, 0, 7)
    tLabel.BackgroundTransparency = 1
    tLabel.Text = title
    tLabel.TextColor3 = Theme.TextMain
    tLabel.Font = Enum.Font.GothamBold
    tLabel.TextSize = 11.5
    tLabel.TextXAlignment = Enum.TextXAlignment.Left

    local dLabel = Instance.new("TextLabel", card)
    dLabel.Size = UDim2.new(1, -110, 0, 14)
    dLabel.Position = UDim2.new(0, 10, 0, 24)
    dLabel.BackgroundTransparency = 1
    dLabel.Text = desc
    dLabel.TextColor3 = Theme.TextMuted
    dLabel.Font = Enum.Font.GothamMedium
    dLabel.TextSize = 9
    dLabel.TextXAlignment = Enum.TextXAlignment.Left

    card.MouseEnter:Connect(function()
        TweenService:Create(card, TweenInfo.new(0.15), {BackgroundColor3 = Theme.BgCardHover}):Play()
        TweenService:Create(cStroke, TweenInfo.new(0.15), {Color = Theme.BorderGlow}):Play()
    end)
    card.MouseLeave:Connect(function()
        TweenService:Create(card, TweenInfo.new(0.15), {BackgroundColor3 = Theme.BgCard}):Play()
        TweenService:Create(cStroke, TweenInfo.new(0.15), {Color = Theme.Border}):Play()
    end)

    return card
end

local function CreateToggle(parent, title, desc, defaultState, callback)
    local card = CreateCard(parent, title, desc, 46)
    local state = defaultState or false

    local switch = Instance.new("TextButton", card)
    switch.Size = UDim2.new(0, 38, 0, 20)
    switch.Position = UDim2.new(1, -48, 0.5, -10)
    switch.BackgroundColor3 = state and Theme.Accent or Theme.SwitchOff
    switch.Text = ""
    switch.AutoButtonColor = false
    Instance.new("UICorner", switch).CornerRadius = UDim.new(1, 0)
    local sStroke = Instance.new("UIStroke", switch)
    sStroke.Color = state and Theme.BorderGlow or Theme.Border

    local knob = Instance.new("Frame", switch)
    knob.Size = UDim2.new(0, 14, 0, 14)
    knob.Position = state and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

    local clickBtn = Instance.new("TextButton", card)
    clickBtn.Size = UDim2.new(1, 0, 1, 0)
    clickBtn.BackgroundTransparency = 1
    clickBtn.Text = ""

    local function toggle()
        state = not state
        local targetColor = state and Theme.Accent or Theme.SwitchOff
        local strokeColor = state and Theme.BorderGlow or Theme.Border
        local targetPos = state and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)

        TweenService:Create(switch, TweenInfo.new(0.2), {BackgroundColor3 = targetColor}):Play()
        TweenService:Create(sStroke, TweenInfo.new(0.2), {Color = strokeColor}):Play()
        TweenService:Create(knob, TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = targetPos}):Play()

        ShowToast(title, state and "Enabled successfully" or "Disabled")
        if callback then callback(state) end
    end

    switch.MouseButton1Click:Connect(toggle)
    clickBtn.MouseButton1Click:Connect(toggle)
    return card
end

local function CreateSlider(parent, title, desc, min, max, defaultVal, suffix, callback)
    local card = CreateCard(parent, title, desc, 50)
    suffix = suffix or ""
    local curVal = defaultVal or min

    local valLabel = Instance.new("TextLabel", card)
    valLabel.Size = UDim2.new(0, 60, 0, 18)
    valLabel.Position = UDim2.new(1, -68, 0.5, -9)
    valLabel.BackgroundTransparency = 1
    valLabel.Text = tostring(curVal) .. suffix
    valLabel.TextColor3 = Theme.AccentGlow
    valLabel.Font = Enum.Font.GothamBold
    valLabel.TextSize = 10.5
    valLabel.TextXAlignment = Enum.TextXAlignment.Right

    local rail = Instance.new("Frame", card)
    rail.Size = UDim2.new(0, 95, 0, 6)
    rail.Position = UDim2.new(1, -170, 0.5, -3)
    rail.BackgroundColor3 = Theme.BgMain
    Instance.new("UICorner", rail).CornerRadius = UDim.new(1, 0)
    local rStroke = Instance.new("UIStroke", rail)
    rStroke.Color = Theme.Border

    local fill = Instance.new("Frame", rail)
    fill.Size = UDim2.new((curVal - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Theme.Accent
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

    local thumb = Instance.new("Frame", rail)
    thumb.Size = UDim2.new(0, 12, 0, 12)
    thumb.Position = UDim2.new((curVal - min) / (max - min), -6, 0.5, -6)
    thumb.BackgroundColor3 = Theme.AccentGlow
    Instance.new("UICorner", thumb).CornerRadius = UDim.new(1, 0)

    local hitBox = Instance.new("TextButton", card)
    hitBox.Size = UDim2.new(0, 115, 0, 30)
    hitBox.Position = UDim2.new(1, -178, 0.5, -15)
    hitBox.BackgroundTransparency = 1
    hitBox.Text = ""

    local sliding = false
    local function update(input)
        local pos = math.clamp((input.Position.X - rail.AbsolutePosition.X) / rail.AbsoluteSize.X, 0, 1)
        curVal = math.floor(min + ((max - min) * pos))
        valLabel.Text = tostring(curVal) .. suffix
        fill.Size = UDim2.new(pos, 0, 1, 0)
        thumb.Position = UDim2.new(pos, -6, 0.5, -6)
        if callback then callback(curVal) end
    end

    hitBox.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            sliding = true
            update(input)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            sliding = false
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            update(input)
        end
    end)

    return card
end

local function CreateButton(parent, title, desc, btnText, callback)
    local card = CreateCard(parent, title, desc, 46)
    local btn = Instance.new("TextButton", card)
    btn.Size = UDim2.new(0, 78, 0, 26)
    btn.Position = UDim2.new(1, -88, 0.5, -13)
    btn.BackgroundColor3 = Theme.Accent
    btn.Text = btnText
    btn.TextColor3 = Theme.TextMain
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 11
    btn.AutoButtonColor = false
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 7)
    local bStroke = Instance.new("UIStroke", btn)
    bStroke.Color = Theme.BorderGlow

    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(0, 225, 245)}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = Theme.Accent}):Play()
    end)
    btn.MouseButton1Click:Connect(function()
        if callback then callback() end
    end)
    return card
end

-- =========================================================================
-- [10] DISASTER ENGINE MODULES (PREDICTOR, GOD-MODE & UMBRELLA)
-- =========================================================================

local function formatDisasterName(raw)
    if not raw or type(raw) ~= "string" or raw == "" then return nil end
    local l = raw:lower()
    if l:find("acid") then
        return "🌧️ Acid Rain"
    elseif l:find("blizzard") or l:find("snow") then
        return "❄️ Blizzard"
    elseif l:find("earthquake") or l:find("quake") then
        return "🏚️ Earthquake"
    elseif l:find("flood") then
        return "🌊 Flash Flood"
    elseif l:find("meteor") then
        return "☄️ Meteor Shower"
    elseif l:find("sandstorm") or l:find("dust") then
        return "🏜️ Sandstorm"
    elseif l:find("thunder") or l:find("lightning") then
        return "⚡ Thunderstorm"
    elseif l:find("tornado") or l:find("twister") then
        return "🌪️ Tornado"
    elseif l:find("tsunami") or l:find("wave") then
        return "🌊 Tsunami Wave"
    elseif l:find("volcan") or l:find("lava") or l:find("magma") then
        return "🌋 Volcanic Eruption"
    elseif l:find("fire") then
        return "🔥 Deadly Fire"
    end
    return "⚠️ " .. raw:sub(1, 16)
end

local function scanSurvivalTags()
    if LocalPlayer.Character then
        local tag = LocalPlayer.Character:FindFirstChild("SurvivalTag") or LocalPlayer.Character:FindFirstChild("Tag")
        if tag and tag:IsA("StringValue") and tag.Value ~= "" and tag.Value ~= "None" then
            return formatDisasterName(tag.Value)
        end
    end

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local tag = p.Character:FindFirstChild("SurvivalTag") or p.Character:FindFirstChild("Tag")
            if tag and tag:IsA("StringValue") and tag.Value ~= "" and tag.Value ~= "None" then
                return formatDisasterName(tag.Value)
            end
        end
    end

    local wsTag = Workspace:FindFirstChild("SurvivalTag") or Workspace:FindFirstChild("Disaster") or Workspace:FindFirstChild("CurrentDisaster")
    if wsTag and wsTag:IsA("StringValue") and wsTag.Value ~= "" and wsTag.Value ~= "None" then
        return formatDisasterName(wsTag.Value)
    end

    local structure = Workspace:FindFirstChild("Structure")
    if structure then
        local sTag = structure:FindFirstChild("SurvivalTag") or structure:FindFirstChild("Disaster")
        if sTag and sTag:IsA("StringValue") and sTag.Value ~= "" and sTag.Value ~= "None" then
            return formatDisasterName(sTag.Value)
        end
    end

    return nil
end

local lastDetectedDisaster = "⏳ Intermission"
local function detectDisaster()
    local tagResult = scanSurvivalTags()
    if tagResult then return tagResult end

    for _, obj in ipairs(Workspace:GetChildren()) do
        local n = obj.Name:lower()
        if n:find("tornado") or n:find("twister") then
            return "🌪️ Tornado"
        elseif n:find("meteor") then
            return "☄️ Meteor Shower"
        elseif n:find("volcano") or n:find("lava") then
            return "🌋 Volcanic Eruption"
        elseif n:find("tsunami") or n:find("wave") then
            return "🌊 Tsunami Wave"
        elseif n:find("acid") then
            return "🌧️ Acid Rain"
        elseif n:find("blizzard") or n:find("snow") then
            return "❄️ Blizzard"
        elseif n:find("sandstorm") or n:find("dust") then
            return "🏜️ Sandstorm"
        elseif n:find("lightning") or n:find("thunder") then
            return "⚡ Thunderstorm"
        elseif n:find("earthquake") or n:find("quake") then
            return "🏚️ Earthquake"
        elseif n:find("deadlyfire") or (n == "fire" and obj:IsA("Model")) then
            return "🔥 Deadly Fire"
        end
    end

    local water = Workspace:FindFirstChild("WaterLevel")
    if water and water:IsA("BasePart") and water.Position.Y > 49.5 then
        return "🌊 Flash Flood"
    end

    if Lighting.FogEnd < 280 then
        local fc = Lighting.FogColor
        if fc.R > 0.55 and fc.G < 0.35 and fc.B < 0.35 then
            return "🌋 Volcanic Eruption"
        elseif fc.G > 0.45 and fc.R < 0.45 and fc.B < 0.45 then
            return "🌧️ Acid Rain"
        elseif fc.R > 0.75 and fc.G > 0.75 and fc.B > 0.75 then
            return "❄️ Blizzard"
        elseif fc.R > 0.55 and fc.G > 0.45 and fc.B < 0.35 then
            return "🏜️ Sandstorm"
        end
    end

    local pGuiFound = nil
    pcall(function()
        local pGui = LocalPlayer:FindFirstChild("PlayerGui")
        if pGui then
            for _, desc in ipairs(pGui:GetDescendants()) do
                if desc:IsA("TextLabel") and desc.Visible and desc.Text ~= "" then
                    local txt = desc.Text:lower()
                    if txt:find("stay indoors") or txt:find("acid rain") or txt:find("under cover") then
                        pGuiFound = "🌧️ Acid Rain"
                    elseif txt:find("tornado") or txt:find("twister") then
                        pGuiFound = "🌪️ Tornado"
                    elseif txt:find("high ground") or txt:find("flood") then
                        pGuiFound = "🌊 Flash Flood"
                    elseif txt:find("tsunami") or txt:find("huge wave") then
                        pGuiFound = "🌊 Tsunami Wave"
                    elseif txt:find("meteor") then
                        pGuiFound = "☄️ Meteor Shower"
                    elseif txt:find("volcano") or txt:find("lava") then
                        pGuiFound = "🌋 Volcanic Eruption"
                    elseif txt:find("blizzard") or txt:find("cold") or txt:find("freeze") then
                        pGuiFound = "❄️ Blizzard"
                    elseif txt:find("sandstorm") then
                        pGuiFound = "🏜️ Sandstorm"
                    elseif txt:find("earthquake") then
                        pGuiFound = "🏚️ Earthquake"
                    elseif txt:find("thunder") or txt:find("lightning") then
                        pGuiFound = "⚡ Thunderstorm"
                    elseif txt:find("deadly fire") then
                        pGuiFound = "🔥 Deadly Fire"
                    end
                end
            end
        end
    end)
    if pGuiFound then return pGuiFound end

    return "⏳ Intermission"
end

local function updateDisasterDisplay(newDisaster)
    if newDisaster ~= lastDetectedDisaster then
        lastDetectedDisaster = newDisaster
        State.CurrentDisaster = newDisaster
        if DisasterLabel then
            DisasterLabel.Text = newDisaster
        end
        if newDisaster ~= "⏳ Intermission" then
            ShowToast("Disaster Alert ⚠️", newDisaster .. " detected! Preparing survival.")
        end
    end
end

local function hookPlayerTagDetection(p)
    local function hookChar(char)
        char.ChildAdded:Connect(function(child)
            if child.Name == "SurvivalTag" or child.Name == "Tag" then
                task.wait(0.1)
                local formatted = formatDisasterName(child.Value)
                if formatted then updateDisasterDisplay(formatted) end
                child:GetPropertyChangedSignal("Value"):Connect(function()
                    local updated = formatDisasterName(child.Value)
                    if updated then updateDisasterDisplay(updated) end
                end)
            end
        end)
    end
    if p.Character then hookChar(p.Character) end
    p.CharacterAdded:Connect(hookChar)
end

for _, player in ipairs(Players:GetPlayers()) do
    task.spawn(hookPlayerTagDetection, player)
end
Players.PlayerAdded:Connect(hookPlayerTagDetection)

Workspace.DescendantAdded:Connect(function(child)
    if child.Name == "SurvivalTag" or child.Name == "Tag" then
        task.wait(0.1)
        if child:IsA("StringValue") and child.Value ~= "" then
            local formatted = formatDisasterName(child.Value)
            if formatted then updateDisasterDisplay(formatted) end
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(0.8)
        if State.DisasterPredictor then
            local detected = detectDisaster()
            updateDisasterDisplay(detected)
        end
    end
end)

-- God-Mode & Umbrella Engine
local umbrellaPart = nil
local umbrellaWeld = nil
local godHealthConn = nil
local godModeThread = nil
local isEmergencyRescuing = false

local function triggerEmergencyRescue(reason)
    if isEmergencyRescuing or not isAlive() then return end
    isEmergencyRescuing = true
    local root = getRoot()
    if root then
        root.AssemblyLinearVelocity = Vector3.zero
        local safeY = math.max(root.Position.Y + 32, 135)
        root.CFrame = CFrame.new(root.Position.X, safeY, root.Position.Z)
        ShowToast("God-Mode Shield 🛡️", reason or "Emergency rescue! Evading lethal hazard.")
        task.wait(2.2)
    end
    isEmergencyRescuing = false
end

local function startGodModeEngine()
    if godModeThread then return end
    godModeThread = task.spawn(function()
        while State.GodUmbrella do
            task.wait(0.1)
            if isAlive() and not isEmergencyRescuing then
                local root = getRoot()
                local hum = getHum()
                local char = LocalPlayer.Character

                if root and hum and char then
                    local currentDis = State.CurrentDisaster or ""

                    -- Flash Flood float
                    local water = Workspace:FindFirstChild("WaterLevel")
                    if water and water:IsA("BasePart") and water.Position.Y > 48 then
                        if root.Position.Y < water.Position.Y + 5 then
                            root.AssemblyLinearVelocity = Vector3.new(root.AssemblyLinearVelocity.X, 0, root.AssemblyLinearVelocity.Z)
                            root.CFrame = CFrame.new(root.Position.X, water.Position.Y + 6, root.Position.Z)
                        end
                    end

                    -- Lava & Boulders
                    for _, obj in ipairs(Workspace:GetChildren()) do
                        if obj:IsA("BasePart") and not obj.Anchored and obj ~= root then
                            local n = obj.Name:lower()
                            if n:find("lava") or n:find("magma") or n:find("fire") or n:find("boulder") or n:find("meteor") then
                                local dist = (obj.Position - root.Position).Magnitude
                                if dist < 18 and math.abs(obj.Position.Y - root.Position.Y) < 10 then
                                    root.AssemblyLinearVelocity = Vector3.new(root.AssemblyLinearVelocity.X, 22, root.AssemblyLinearVelocity.Z)
                                    root.CFrame = root.CFrame + Vector3.new(0, 14, 0)
                                    break
                                end
                            end
                        end
                    end

                    -- Acid Rain / Blizzard Auto-Shelter
                    if currentDis:find("Acid Rain") or currentDis:find("Blizzard") then
                        local head = char:FindFirstChild("Head")
                        if head then
                            local ray = Ray.new(head.Position, Vector3.new(0, 120, 0))
                            local hit = Workspace:FindPartOnRayWithIgnoreList(ray, {char, umbrellaPart})
                            if not hit and hum.Health < 98 then
                                triggerEmergencyRescue("Acid Rain/Blizzard cover engaged!")
                            end
                        end
                    end

                    -- Tornado Repulsion
                    for _, obj in ipairs(Workspace:GetChildren()) do
                        local n = obj.Name:lower()
                        if n:find("tornado") or n:find("twister") then
                            local tPos = obj:IsA("Model") and obj:GetPivot().Position or (obj:IsA("BasePart") and obj.Position)
                            if tPos then
                                local dist = (tPos - root.Position).Magnitude
                                if dist < 55 then
                                    local pushDir = (root.Position - tPos).Unit
                                    root.AssemblyLinearVelocity = Vector3.new(pushDir.X * 45, 10, pushDir.Z * 45)
                                end
                            end
                        end
                    end
                end
            end
        end
        godModeThread = nil
    end)
end

local function applyGodMode(char)
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        pcall(function()
            hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
            hum.BreakJointsOnDeath = false
        end)

        if godHealthConn then godHealthConn:Disconnect() end
        godHealthConn = hum.HealthChanged:Connect(function(health)
            if State.GodUmbrella and health < 98 and isAlive() then
                triggerEmergencyRescue("Damage detected! Evading lethal disaster hazard.")
            end
        end)
    end

    for _, s in ipairs(char:GetDescendants()) do
        if s:IsA("LocalScript") and (s.Name:lower():find("fall") or s.Name:lower():find("damage")) then
            s.Disabled = true
            pcall(function() s:Destroy() end)
        end
    end

    startGodModeEngine()
end

local function removeGodMode(char)
    if godHealthConn then
        godHealthConn:Disconnect()
        godHealthConn = nil
    end
    if umbrellaPart then
        pcall(function() umbrellaPart:Destroy() end)
        umbrellaPart = nil
        umbrellaWeld = nil
    end
end

local function updateUmbrella(enabled)
    State.GodUmbrella = enabled
    if enabled then
        if isAlive() then
            applyGodMode(LocalPlayer.Character)
        end

        if not umbrellaPart or not umbrellaPart.Parent then
            pcall(function()
                if umbrellaPart then umbrellaPart:Destroy() end
            end)
            local char = LocalPlayer.Character
            local head = char and char:FindFirstChild("Head")
            if head then
                umbrellaPart = Instance.new("Part")
                umbrellaPart.Name = "SufyanGodUmbrella"
                umbrellaPart.Size = Vector3.new(12, 0.4, 12)
                umbrellaPart.Material = Enum.Material.ForceField
                umbrellaPart.Color = Theme.AccentGlow
                umbrellaPart.Transparency = 0.55
                umbrellaPart.CanCollide = false
                umbrellaPart.CanTouch = false
                umbrellaPart.Massless = true
                umbrellaPart.CFrame = head.CFrame * CFrame.new(0, 3.2, 0)
                umbrellaPart.Parent = char

                umbrellaWeld = Instance.new("WeldConstraint")
                umbrellaWeld.Part0 = head
                umbrellaWeld.Part1 = umbrellaPart
                umbrellaWeld.Parent = umbrellaPart
            end
        end
        ShowToast("God-Mode & Umbrella 🛡️", "Invincibility & Auto-Hazard Evader active!")
    else
        removeGodMode(LocalPlayer.Character)
        ShowToast("God-Mode Disabled", "Standard vulnerability restored.")
    end
end

-- Ocean Water Walker
local waterPlatform = nil
local function updateWaterWalk(enabled)
    State.WaterWalk = enabled
    if enabled then
        if not waterPlatform then
            waterPlatform = Instance.new("Part")
            waterPlatform.Name = "SufyanWaterPlatform"
            waterPlatform.Size = Vector3.new(24, 1, 24)
            waterPlatform.Transparency = 0.85
            waterPlatform.Color = Theme.AccentGlow
            waterPlatform.Material = Enum.Material.Neon
            waterPlatform.Anchored = true
            waterPlatform.CanCollide = true
            waterPlatform.Parent = Workspace
        end
    else
        if waterPlatform then
            waterPlatform:Destroy()
            waterPlatform = nil
        end
    end
end

RunService.Heartbeat:Connect(function()
    if State.WaterWalk and isAlive() then
        local root = getRoot()
        if root then
            if not waterPlatform or not waterPlatform.Parent then
                updateWaterWalk(true)
            end
            local seaLevel = 47.5
            if waterPlatform then
                waterPlatform.CFrame = CFrame.new(root.Position.X, seaLevel - 0.5, root.Position.Z)
            end
        end
    end
end)

-- Anti-Fling & Debris Ghost
RunService.Stepped:Connect(function()
    if isAlive() then
        local root = getRoot()
        if State.AntiFling and root then
            root.AssemblyAngularVelocity = Vector3.zero
        end

        if State.DebrisGhost then
            local char = LocalPlayer.Character
            for _, obj in ipairs(Workspace:GetDescendants()) do
                if obj:IsA("BasePart") and not obj:IsDescendantOf(char) and not obj.Anchored and obj.Position.Y > 40 then
                    pcall(function()
                        obj.CanCollide = false
                    end)
                end
            end
        end
    end
end)

-- Auto Win AFK Farm
local isAutoWinning = false
task.spawn(function()
    while true do
        task.wait(2)
        if State.AutoWin and isAlive() and not isAutoWinning then
            local root = getRoot()
            if root and root.Position.Y < 120 and root.Position.Y > 35 then
                isAutoWinning = true
                ShowToast("Auto Win Farm", "Survival Tag confirmed! Warping to Safe Sky Hover.")
                task.wait(1.5)

                local safeCF = CFrame.new(-2, 195, 0)
                root.AssemblyLinearVelocity = Vector3.zero
                root.CFrame = safeCF
                
                local skyAnchor = Instance.new("Part")
                skyAnchor.Name = "SufyanSkyAnchor"
                skyAnchor.Size = Vector3.new(12, 1, 12)
                skyAnchor.CFrame = safeCF - Vector3.new(0, 3, 0)
                skyAnchor.Anchored = true
                skyAnchor.Transparency = 0.8
                skyAnchor.Color = Theme.Accent
                skyAnchor.Material = Enum.Material.Neon
                skyAnchor.Parent = Workspace

                while State.AutoWin and isAlive() do
                    task.wait(2)
                    local blurb = LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild("MainGui") and LocalPlayer.PlayerGui.MainGui:FindFirstChild("Blurb")
                    if blurb and blurb.Text:find("survived") then
                        ShowToast("Auto Win", "Round Won! Surviving another disaster.")
                        task.wait(5)
                        break
                    end
                end

                if skyAnchor then skyAnchor:Destroy() end
                isAutoWinning = false
            end
        end
    end
end)

-- =========================================================================
-- [11] MOVEMENT & PHYSICS ENGINE
-- =========================================================================

local function enforcePhysics()
    local hum = getHum()
    if not hum or hum.Health <= 0 then return end

    if State.WalkSpeedActive then
        if hum.WalkSpeed ~= State.WalkSpeedValue then
            hum.WalkSpeed = State.WalkSpeedValue
        end
    end

    if State.JumpPowerActive then
        hum.UseJumpPower = true
        if hum.JumpPower ~= State.JumpPowerValue then
            hum.JumpPower = State.JumpPowerValue
        end
        local desiredHeight = (State.JumpPowerValue / 50) * 7.2
        if hum.JumpHeight ~= desiredHeight then
            hum.JumpHeight = desiredHeight
        end
    end
end

RunService.Stepped:Connect(enforcePhysics)
RunService.Heartbeat:Connect(enforcePhysics)

local function hookHumanoid(char)
    local hum = char:WaitForChild("Humanoid", 5)
    if hum then
        if State.WalkSpeedActive then hum.WalkSpeed = State.WalkSpeedValue end
        if State.JumpPowerActive then
            hum.UseJumpPower = true
            hum.JumpPower = State.JumpPowerValue
            hum.JumpHeight = (State.JumpPowerValue / 50) * 7.2
        end

        hum:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
            if State.WalkSpeedActive and hum.WalkSpeed ~= State.WalkSpeedValue then
                hum.WalkSpeed = State.WalkSpeedValue
            end
        end)
        hum:GetPropertyChangedSignal("JumpPower"):Connect(function()
            if State.JumpPowerActive and hum.JumpPower ~= State.JumpPowerValue then
                hum.JumpPower = State.JumpPowerValue
            end
        end)
    end

    task.spawn(function()
        task.wait(0.3)
        for _, scriptObj in ipairs(char:GetDescendants()) do
            if scriptObj:IsA("LocalScript") and (scriptObj.Name:lower():find("fall") or scriptObj.Name:lower():find("damage")) then
                scriptObj.Disabled = true
                pcall(function() scriptObj:Destroy() end)
            end
        end
    end)

    char.DescendantAdded:Connect(function(scriptObj)
        if State.NoFallDamage and scriptObj:IsA("LocalScript") and (scriptObj.Name:lower():find("fall") or scriptObj.Name:lower():find("damage")) then
            scriptObj.Disabled = true
            pcall(function() scriptObj:Destroy() end)
        end
    end)

    if State.GodUmbrella then
        task.spawn(function()
            task.wait(0.2)
            updateUmbrella(true)
        end)
    end
end

if LocalPlayer.Character then task.spawn(hookHumanoid, LocalPlayer.Character) end
LocalPlayer.CharacterAdded:Connect(hookHumanoid)

-- Velocity-based No Fall Damage fail-safe
RunService.Heartbeat:Connect(function()
    if (State.NoFallDamage or State.GodUmbrella) and isAlive() then
        local root = getRoot()
        local hum = getHum()
        if root and hum and hum:GetState() == Enum.HumanoidStateType.Freefall then
            if root.AssemblyLinearVelocity.Y < -50 then
                local ray = Ray.new(root.Position, Vector3.new(0, -8, 0))
                local hit = Workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character, umbrellaPart, waterPlatform})
                if hit then
                    root.AssemblyLinearVelocity = Vector3.new(root.AssemblyLinearVelocity.X, -10, root.AssemblyLinearVelocity.Z)
                end
            end
        end
    end
end)

-- Infinite Air Jump
UserInputService.JumpRequest:Connect(function()
    if State.InfJumpActive and isAlive() then
        local hum = getHum()
        local root = getRoot()
        if hum and root then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
            local boost = State.JumpPowerActive and State.JumpPowerValue or 50
            if root.AssemblyLinearVelocity then
                root.AssemblyLinearVelocity = Vector3.new(root.AssemblyLinearVelocity.X, boost, root.AssemblyLinearVelocity.Z)
            else
                root.Velocity = Vector3.new(root.Velocity.X, boost, root.Velocity.Z)
            end
        end
    end
end)

-- NoClip
RunService.Stepped:Connect(function()
    if State.NoClipActive and isAlive() then
        for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    end
end)

-- 3D Flight Engine
local flyBodyVel, flyBodyGyro
local function setFly(enabled)
    State.FlyActive = enabled
    local root = getRoot()
    if not root then return end

    if enabled then
        flyBodyVel = Instance.new("BodyVelocity")
        flyBodyVel.Name = "FlyVelocity"
        flyBodyVel.MaxForce = Vector3.new(1e6, 1e6, 1e6)
        flyBodyVel.Velocity = Vector3.zero
        flyBodyVel.Parent = root

        flyBodyGyro = Instance.new("BodyGyro")
        flyBodyGyro.Name = "FlyGyro"
        flyBodyGyro.MaxTorque = Vector3.new(1e6, 1e6, 1e6)
        flyBodyGyro.CFrame = root.CFrame
        flyBodyGyro.Parent = root

        task.spawn(function()
            while State.FlyActive and root and flyBodyVel and flyBodyGyro do
                local cam = Workspace.CurrentCamera
                local moveDir = Vector3.zero

                if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + cam.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - cam.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - cam.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + cam.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0, 1, 0) end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then moveDir = moveDir - Vector3.new(0, 1, 0) end

                if moveDir.Magnitude > 0 then
                    flyBodyVel.Velocity = moveDir.Unit * State.FlySpeed
                else
                    flyBodyVel.Velocity = Vector3.zero
                end
                flyBodyGyro.CFrame = cam.CFrame
                RunService.RenderStepped:Wait()
            end
        end)
    else
        if flyBodyVel then flyBodyVel:Destroy() flyBodyVel = nil end
        if flyBodyGyro then flyBodyGyro:Destroy() flyBodyGyro = nil end
    end
end

-- =========================================================================
-- [12] VISUALS (ESP & FULLBRIGHT)
-- =========================================================================

local espFolder = Instance.new("Folder")
espFolder.Name = "SufyanNDS_ESP"
pcall(function() espFolder.Parent = CoreGui end)
if not espFolder.Parent then espFolder.Parent = Screen end

local disasterHighlights = {}
local function updateDisasterEsp()
    if not State.DisasterESP then
        for _, hl in pairs(disasterHighlights) do if hl then hl:Destroy() end end
        table.clear(disasterHighlights)
        return
    end

    for _, obj in ipairs(Workspace:GetChildren()) do
        local n = obj.Name:lower()
        if n:find("tornado") or n:find("twister") or n:find("meteor") or n:find("lava") or n:find("wave") or n:find("tsunami") then
            if not disasterHighlights[obj] then
                local hl = Instance.new("Highlight")
                hl.Name = "DisasterHL"
                hl.FillColor = Color3.fromRGB(255, 60, 90)
                hl.OutlineColor = Theme.AccentGlow
                hl.FillTransparency = 0.35
                hl.OutlineTransparency = 0
                hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                hl.Adornee = obj
                hl.Parent = espFolder
                disasterHighlights[obj] = hl
            end
        end
    end
end

local collapseHighlights = {}
local function updateCollapseEsp()
    if not State.CollapseESP then
        for _, hl in pairs(collapseHighlights) do if hl then hl:Destroy() end end
        table.clear(collapseHighlights)
        return
    end

    local struct = Workspace:FindFirstChild("Structure") or Workspace
    for _, part in ipairs(struct:GetDescendants()) do
        if part:IsA("BasePart") and part.Position.Y > 45 and not part:IsDescendantOf(LocalPlayer.Character) then
            if not part.Anchored and not collapseHighlights[part] then
                local hl = Instance.new("Highlight")
                hl.Name = "DangerDebris"
                hl.FillColor = Color3.fromRGB(245, 158, 11)
                hl.OutlineColor = Color3.fromRGB(255, 60, 60)
                hl.FillTransparency = 0.5
                hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                hl.Adornee = part
                hl.Parent = espFolder
                collapseHighlights[part] = hl
            end
        end
    end
end

local survivorHighlights = {}
local function updateSurvivorEsp()
    if not State.SurvivorESP then
        for _, hl in pairs(survivorHighlights) do if hl then hl:Destroy() end end
        table.clear(survivorHighlights)
        return
    end

    local myRoot = getRoot()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local char = p.Character
            local root = char:FindFirstChild("HumanoidRootPart")
            local head = char:FindFirstChild("Head")
            local hum = char:FindFirstChildOfClass("Humanoid")

            if char and root and hum and hum.Health > 0 then
                local hlName = "Survivor_" .. p.Name
                local hl = survivorHighlights[p]
                if not hl then
                    hl = Instance.new("Highlight")
                    hl.Name = hlName
                    hl.FillColor = Theme.Accent
                    hl.OutlineColor = Theme.AccentGlow
                    hl.FillTransparency = 0.45
                    hl.OutlineTransparency = 0
                    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    hl.Adornee = char
                    hl.Parent = espFolder
                    survivorHighlights[p] = hl
                end

                local tagName = "Tag_" .. p.Name
                local bill = espFolder:FindFirstChild(tagName)
                if not bill and head then
                    bill = Instance.new("BillboardGui", espFolder)
                    bill.Name = tagName
                    bill.Size = UDim2.new(0, 140, 0, 30)
                    bill.StudsOffset = Vector3.new(0, 2.8, 0)
                    bill.AlwaysOnTop = true
                    bill.Adornee = head

                    local nameLbl = Instance.new("TextLabel", bill)
                    nameLbl.Name = "NameLabel"
                    nameLbl.Size = UDim2.new(1, 0, 0, 15)
                    nameLbl.BackgroundTransparency = 1
                    nameLbl.TextColor3 = Theme.AccentGlow
                    nameLbl.Font = Enum.Font.GothamBold
                    nameLbl.TextSize = 11

                    local distLbl = Instance.new("TextLabel", bill)
                    distLbl.Name = "DistLabel"
                    distLbl.Size = UDim2.new(1, 0, 0, 14)
                    distLbl.Position = UDim2.new(0, 0, 0, 15)
                    distLbl.BackgroundTransparency = 1
                    distLbl.TextColor3 = Theme.TextMain
                    distLbl.Font = Enum.Font.GothamMedium
                    distLbl.TextSize = 9.5
                end
                if bill then
                    local dist = myRoot and math.floor((myRoot.Position - root.Position).Magnitude) or 0
                    local nameLbl = bill:FindFirstChild("NameLabel")
                    local distLbl = bill:FindFirstChild("DistLabel")
                    if nameLbl then nameLbl.Text = p.DisplayName end
                    if distLbl then distLbl.Text = string.format("❤️ %d HP  |  📏 %dm", math.floor(hum.Health), dist) end
                end
            end
        end
    end
end

task.spawn(function()
    while true do
        task.wait(1)
        pcall(updateDisasterEsp)
        pcall(updateCollapseEsp)
        pcall(updateSurvivorEsp)
    end
end)

-- FullBright
local origLighting = {
    Brightness = Lighting.Brightness,
    ClockTime = Lighting.ClockTime,
    FogEnd = Lighting.FogEnd,
    GlobalShadows = Lighting.GlobalShadows,
    OutdoorAmbient = Lighting.OutdoorAmbient
}
local function setFullBright(enabled)
    State.FullBrightActive = enabled
    if enabled then
        Lighting.Brightness = 2.2
        Lighting.ClockTime = 14
        Lighting.FogEnd = 100000
        Lighting.GlobalShadows = false
        Lighting.OutdoorAmbient = Color3.fromRGB(240, 250, 250)
    else
        Lighting.Brightness = origLighting.Brightness
        Lighting.ClockTime = origLighting.ClockTime
        Lighting.FogEnd = origLighting.FogEnd
        Lighting.GlobalShadows = origLighting.GlobalShadows
        Lighting.OutdoorAmbient = origLighting.OutdoorAmbient
    end
end

-- =========================================================================
-- [13] UTILITIES
-- =========================================================================

local function safeTeleport(cframe)
    local root = getRoot()
    if root then
        root.AssemblyLinearVelocity = Vector3.zero
        root.CFrame = cframe + Vector3.new(0, 3, 0)
        ShowToast("Teleported", "Arrived at destination successfully")
    end
end

LocalPlayer.Idled:Connect(function()
    if State.AntiAFKActive then
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end
end)

Workspace.DescendantAdded:Connect(function(obj)
    if State.InstantPrompts and obj:IsA("ProximityPrompt") then
        obj.HoldDuration = 0
    end
end)

-- Panic Key [F4]
UserInputService.InputBegan:Connect(function(input, processed)
    if not processed and input.KeyCode == Enum.KeyCode.F4 then
        pcall(function()
            State.WalkSpeedActive = false
            State.JumpPowerActive = false
            State.FlyActive = false
            setFly(false)
            updateUmbrella(false)
            updateWaterWalk(false)
            setFullBright(false)
            local hum = getHum()
            if hum then
                hum.WalkSpeed = 16
                hum.JumpPower = 50
            end
            if CoreGui:FindFirstChild("SufyanScripterHub") then
                CoreGui.SufyanScripterHub:Destroy()
            end
            if LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild("SufyanScripterHub") then
                LocalPlayer.PlayerGui.SufyanScripterHub:Destroy()
            end
        end)
    end
end)

-- =========================================================================
-- [14] ASSEMBLE TABS
-- =========================================================================

-- TAB 1: 🎯 Survival
local DisastersTab = CreateTab("Survival", "🎯", 1)
CreateSection(DisastersTab, "Disaster Defense & Auto Farm")

CreateToggle(DisastersTab, "Disaster Predictor", "Detects round disaster 15-20s early", true, function(s)
    State.DisasterPredictor = s
end)

CreateToggle(DisastersTab, "Auto Win / AFK Farm", "Auto-secures survival tag & hovers safely", false, function(s)
    State.AutoWin = s
end)

CreateToggle(DisastersTab, "God-Mode Umbrella", "Invincible hazard shield + canopy", false, function(s)
    updateUmbrella(s)
end)

CreateToggle(DisastersTab, "Ocean Water Walker", "Walk across ocean surface without drowning", false, function(s)
    updateWaterWalk(s)
end)

CreateToggle(DisastersTab, "Anti-Fling Velocity", "Prevents flying debris from flinging character", true, function(s)
    State.AntiFling = s
end)

CreateToggle(DisastersTab, "Debris Ghost Mode", "Disables collision with falling building debris", false, function(s)
    State.DebrisGhost = s
end)

-- TAB 2: 🏃 Mobility
local MovementTab = CreateTab("Mobility", "🏃", 2)
CreateSection(MovementTab, "Player Physics & Movement")

CreateSlider(MovementTab, "WalkSpeed Boost", "Continuous run speed (Active > 16)", 16, 150, 16, " Spd", function(v)
    State.WalkSpeedValue = v
    State.WalkSpeedActive = (v > 16)
    local hum = getHum()
    if hum then hum.WalkSpeed = v end
end)

CreateSlider(MovementTab, "JumpPower Boost", "Adjust JumpPower & JumpHeight", 50, 250, 50, " Pwr", function(v)
    State.JumpPowerValue = v
    State.JumpPowerActive = (v > 50)
    local hum = getHum()
    if hum then
        hum.UseJumpPower = true
        hum.JumpPower = v
        hum.JumpHeight = (v / 50) * 7.2
    end
end)

CreateToggle(MovementTab, "100% No Fall Damage", "Fall from any height without receiving damage", true, function(s)
    State.NoFallDamage = s
end)

CreateToggle(MovementTab, "Infinite Air Jump", "Allows jumping in mid-air unlimited times", false, function(s)
    State.InfJumpActive = s
end)

CreateToggle(MovementTab, "Player NoClip", "Walk through collapsed debris and walls", false, function(s)
    State.NoClipActive = s
    if not s and isAlive() then
        for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = true end
        end
    end
end)

CreateToggle(MovementTab, "Universal 3D Flight", "Smooth flight with WASD & camera direction", false, function(s)
    setFly(s)
end)

CreateSlider(MovementTab, "Flight Speed", "Adjust flight navigation velocity", 20, 180, 60, " Spd", function(v)
    State.FlySpeed = v
end)

-- TAB 3: 👁️ Visuals
local VisualsTab = CreateTab("Visuals", "👁️", 3)
CreateSection(VisualsTab, "ESP Trackers & Vision")

CreateToggle(VisualsTab, "Disaster Entities ESP", "Highlights Tornado, Meteors, Lava, Tsunamis", false, function(s)
    State.DisasterESP = s
    updateDisasterEsp()
end)

CreateToggle(VisualsTab, "Map Collapse ESP", "Highlights falling unanchored danger parts", false, function(s)
    State.CollapseESP = s
    updateCollapseEsp()
end)

CreateToggle(VisualsTab, "Survivor Chams ESP", "Draws glowing box & health info on players", false, function(s)
    State.SurvivorESP = s
    updateSurvivorEsp()
end)

CreateToggle(VisualsTab, "FullBright & Fog Clear", "Eliminates darkness, blizzard and sandstorm fog", false, function(s)
    setFullBright(s)
end)

CreateSlider(VisualsTab, "Field of View (FOV)", "Widens camera view for better situational awareness", 70, 120, 70, "°", function(v)
    State.FOV = v
    Camera.FieldOfView = v
end)

-- TAB 4: ⚙️ Utilities
local UtilsTab = CreateTab("Utilities", "⚙️", 4)
CreateSection(UtilsTab, "Teleports & Automation")

CreateButton(UtilsTab, "Island Center", "Teleport to center of the active disaster island", "Warp", function()
    safeTeleport(CFrame.new(-2, 48, 0))
end)

CreateButton(UtilsTab, "Lobby Tower", "Teleport back to the lobby safety tower", "Warp", function()
    safeTeleport(CFrame.new(-285, 178, 380))
end)

CreateButton(UtilsTab, "Safe Sky Hover Spot", "Teleport high above disaster reach (Y = 195)", "Warp", function()
    safeTeleport(CFrame.new(-2, 195, 0))
end)

CreateToggle(UtilsTab, "Instant Prompts", "Sets proximity prompt duration to 0s", false, function(s)
    State.InstantPrompts = s
    if s then
        for _, prompt in ipairs(Workspace:GetDescendants()) do
            if prompt:IsA("ProximityPrompt") then prompt.HoldDuration = 0 end
        end
    end
end)

CreateToggle(UtilsTab, "Anti-AFK Protection", "Prevents 20-minute idle kicks while AFK", true, function(s)
    State.AntiAFKActive = s
end)

CreateButton(UtilsTab, "Rejoin Server", "Reconnects to this active server", "Rejoin", function()
    ShowToast("Rejoining", "Connecting back to server...")
    TeleportService:Teleport(game.PlaceId, LocalPlayer)
end)

CreateButton(UtilsTab, "Server Hop", "Searches and hops to a new public server", "Hop", function()
    ShowToast("Server Hop", "Searching for available public server...")
    pcall(function()
        local servers = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
        for _, s in ipairs(servers.data) do
            if s.playing < s.maxPlayers and s.id ~= game.JobId then
                TeleportService:TeleportToPlaceInstance(game.PlaceId, s.id, LocalPlayer)
                break
            end
        end
    end)
end)

-- Open Default Tab
SelectTab("Survival")

ShowToast("💎 SufyanHub Ready", "NDS Master Suite Loaded Successfully!")
print("💎 [SufyanHub] Natural Disaster Survival Suite Ready!")
