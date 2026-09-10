--========================================================--
--                 SAKI SCRIPTS UI (MASTER EDITION)
--          STEAL AN EGG • FULL AUTOMATION & MOVEMENT
--========================================================--

local GAME_NAME = "STEAL AN EGG AUTO"
local CREDIT    = "SAKI SCRIPTS"

-- 1. Services
local Players           = game:GetService("Players")
local Workspace         = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService        = game:GetService("RunService")
local UserInputService  = game:GetService("UserInputService")
local TweenService      = game:GetService("TweenService")
local CoreGui           = game:GetService("CoreGui")
local StarterGui        = game:GetService("StarterGui")
local VirtualUser       = game:GetService("VirtualUser")

local LocalPlayer = Players.LocalPlayer
while not LocalPlayer do
    task.wait(0.05)
    LocalPlayer = Players.LocalPlayer
end

-- Safe Parent GUI Selection
local function getGuiParent()
    local success, result = pcall(function() return (gethui and gethui()) or CoreGui end)
    if success and result then return result end
    return LocalPlayer:WaitForChild("PlayerGui")
end

-- Cleanup Old UI Instances
pcall(function()
    for _, name in ipairs({"SakiScriptsStealAnEggAutoUI", "SakiScriptsMasterUI", "Rayfield"}) do
        local parent = getGuiParent()
        if parent and parent:FindFirstChild(name) then parent[name]:Destroy() end
        if CoreGui:FindFirstChild(name) then CoreGui[name]:Destroy() end
        if LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild(name) then
            LocalPlayer.PlayerGui[name]:Destroy()
        end
    end
end)

-- Colors & Design System
local RED   = Color3.fromRGB(255, 25, 35)
local DARK  = Color3.fromRGB(12, 12, 12)
local DARK2 = Color3.fromRGB(18, 18, 18)
local WHITE = Color3.fromRGB(255, 255, 255)
local GRAY  = Color3.fromRGB(30, 30, 30)

--------------------------------------------------------------------------------
-- SCRIPT VARIABLES & BASE POSITION SETUP
--------------------------------------------------------------------------------
local AutoSteal        = false
local AutoTeleportBase = false
local AutoHatch        = false
local FastWalkToggle   = false
local SpeedValue       = 50
local InfJump          = false

local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local PrimaryPart = Character:WaitForChild("HumanoidRootPart", 5) or Character:FindFirstChildWhichIsA("BasePart")
local SavedBaseCFrame = PrimaryPart and PrimaryPart.CFrame or CFrame.new(0, 5, 0)

LocalPlayer.CharacterAdded:Connect(function(newChar)
    Character = newChar
    local hrp = newChar:WaitForChild("HumanoidRootPart", 5)
    if hrp and not SavedBaseCFrame then
        SavedBaseCFrame = hrp.CFrame
    end
end)

-- Anti-AFK Engine
pcall(function()
    LocalPlayer.Idled:Connect(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end)
end)

--------------------------------------------------------------------------------
-- GAME AUTOMATION LOOPS (100% UNTOUCHED LOGIC)
--------------------------------------------------------------------------------

-- 1. FAST WALK SPEED LOOP (Clean Vector Velocity)
RunService.Stepped:Connect(function()
    if FastWalkToggle then
        pcall(function()
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("Humanoid") and char:FindFirstChild("HumanoidRootPart") then
                char.Humanoid.WalkSpeed = SpeedValue
                if char.Humanoid.MoveDirection.Magnitude > 0 then
                    char.HumanoidRootPart.AssemblyLinearVelocity = Vector3.new(
                        char.Humanoid.MoveDirection.X * SpeedValue,
                        char.HumanoidRootPart.AssemblyLinearVelocity.Y,
                        char.Humanoid.MoveDirection.Z * SpeedValue
                    )
                end
            end
        end)
    end
end)

-- 2. AUTO STEAL & TELEPORT BASE LOOP
task.spawn(function()
    while task.wait(0.05) do
        if AutoSteal then
            pcall(function()
                for _, prompt in pairs(Workspace:GetDescendants()) do
                    if prompt:IsA("ProximityPrompt") and (prompt.ObjectText:lower():find("egg") or prompt.ActionText:lower():find("steal") or prompt.ActionText:lower():find("take")) then
                        prompt.HoldDuration = 0
                        if fireproximityprompt then
                            fireproximityprompt(prompt)
                        end
                        
                        if AutoTeleportBase and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                            task.wait(0.1)
                            LocalPlayer.Character.HumanoidRootPart.CFrame = SavedBaseCFrame
                        end
                    end
                end
                
                for _, v in pairs(ReplicatedStorage:GetDescendants()) do
                    if v:IsA("RemoteEvent") and (v.Name:lower():find("steal") or v.Name:lower():find("takeegg")) then
                        v:FireServer()
                    end
                end
            end)
        end
    end
end)

-- 3. AUTO HATCH LOOP
task.spawn(function()
    while task.wait(0.3) do
        if AutoHatch then
            pcall(function()
                for _, prompt in pairs(Workspace:GetDescendants()) do
                    if prompt:IsA("ProximityPrompt") and (prompt.ActionText:lower():find("hatch") or prompt.ActionText:lower():find("place")) then
                        if fireproximityprompt then
                            fireproximityprompt(prompt)
                        end
                    end
                end
                
                for _, v in pairs(ReplicatedStorage:GetDescendants()) do
                    if v:IsA("RemoteEvent") and (v.Name:lower():find("hatch") or v.Name:lower():find("placeegg") or v.Name:lower():find("openegg")) then
                        v:FireServer()
                    end
                end
            end)
        end
    end
end)

-- 4. Infinite Jump Engine
UserInputService.JumpRequest:Connect(function()
    if InfJump then
        pcall(function()
            local char = LocalPlayer.Character
            if char and char:FindFirstChildOfClass("Humanoid") then
                char:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end)
    end
end)

--------------------------------------------------------------------------------
-- SAKI SCRIPTS MASTER RED/DARK GUI
--------------------------------------------------------------------------------

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SakiScriptsStealAnEggAutoUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = getGuiParent()

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Parent = ScreenGui
Main.Size = UDim2.fromOffset(235, 275)
Main.Position = UDim2.new(0.5, -117, 0.5, -137)
Main.BackgroundColor3 = DARK
Main.BorderSizePixel = 0
Main.Active = true

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 14)
MainCorner.Parent = Main

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = RED
MainStroke.Thickness = 1.8
MainStroke.Parent = Main

-- Top Bar
local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Parent = Main
TopBar.Size = UDim2.new(1, 0, 0, 32)
TopBar.BackgroundTransparency = 1

local GameNameLabel = Instance.new("TextLabel")
GameNameLabel.Name = "GameName"
GameNameLabel.Parent = TopBar
GameNameLabel.BackgroundTransparency = 1
GameNameLabel.Position = UDim2.fromOffset(10, 0)
GameNameLabel.Size = UDim2.new(1, -65, 1, 0)
GameNameLabel.Text = GAME_NAME
GameNameLabel.TextColor3 = RED
GameNameLabel.TextSize = 13
GameNameLabel.Font = Enum.Font.Bangers
GameNameLabel.TextXAlignment = Enum.TextXAlignment.Left

local Minimize = Instance.new("TextButton")
Minimize.Name = "Minimize"
Minimize.Parent = TopBar
Minimize.Size = UDim2.fromOffset(22, 20)
Minimize.Position = UDim2.new(1, -50, 0.5, -10)
Minimize.BackgroundColor3 = DARK2
Minimize.BorderSizePixel = 0
Minimize.Text = "−"
Minimize.TextColor3 = WHITE
Minimize.TextSize = 14
Minimize.Font = Enum.Font.GothamBold
Minimize.AutoButtonColor = false

local MinCorner = Instance.new("UICorner")
MinCorner.CornerRadius = UDim.new(0, 5)
MinCorner.Parent = Minimize

local MinStroke = Instance.new("UIStroke")
MinStroke.Color = RED
MinStroke.Thickness = 1
MinStroke.Parent = Minimize

local Close = Instance.new("TextButton")
Close.Name = "Close"
Close.Parent = TopBar
Close.Size = UDim2.fromOffset(22, 20)
Close.Position = UDim2.new(1, -25, 0.5, -10)
Close.BackgroundColor3 = DARK2
Close.BorderSizePixel = 0
Close.Text = "X"
Close.TextColor3 = RED
Close.TextSize = 11
Close.Font = Enum.Font.GothamBold
Close.AutoButtonColor = false

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 5)
CloseCorner.Parent = Close

local CloseStroke = Instance.new("UIStroke")
CloseStroke.Color = RED
CloseStroke.Thickness = 1
CloseStroke.Parent = Close

local TopDivider = Instance.new("Frame")
TopDivider.Name = "TopDivider"
TopDivider.Parent = Main
TopDivider.Position = UDim2.fromOffset(0, 32)
TopDivider.Size = UDim2.new(1, 0, 0, 1.5)
TopDivider.BackgroundColor3 = RED
TopDivider.BorderSizePixel = 0

-- Content & Scroll Frame
local Content = Instance.new("Frame")
Content.Name = "Content"
Content.Parent = Main
Content.Position = UDim2.fromOffset(0, 34)
Content.Size = UDim2.new(1, 0, 1, -58)
Content.BackgroundTransparency = 1

local Scroll = Instance.new("ScrollingFrame")
Scroll.Name = "Scroll"
Scroll.Parent = Content
Scroll.Size = UDim2.new(1, 0, 1, 0)
Scroll.BackgroundTransparency = 1
Scroll.BorderSizePixel = 0
Scroll.ScrollBarThickness = 3
Scroll.ScrollBarImageColor3 = RED
Scroll.ScrollingDirection = Enum.ScrollingDirection.Y
Scroll.ElasticBehavior = Enum.ElasticBehavior.Never
Scroll.ScrollingEnabled = false
Scroll.CanvasSize = UDim2.new(0, 0, 0, 240)

local ListLayout = Instance.new("UIListLayout")
ListLayout.Parent = Scroll
ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
ListLayout.Padding = UDim.new(0, 6)
ListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local TopPadding = Instance.new("UIPadding")
TopPadding.PaddingTop = UDim.new(0, 4)
TopPadding.Parent = Scroll

ListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    Scroll.CanvasSize = UDim2.new(0, 0, 0, ListLayout.AbsoluteContentSize.Y + 14)
end)

-- Smooth Scrolling Dampener Engine
local currentScrollY = 0
local targetScrollY = 0
local isDragging = false
local dragStartY = 0
local dragStartScrollY = 0

RunService.RenderStepped:Connect(function()
    if not ScreenGui.Enabled or not Main.Visible then return end
    local maxScroll = math.max(0, Scroll.CanvasSize.Y.Offset - Scroll.AbsoluteSize.Y)
    targetScrollY = math.clamp(targetScrollY, 0, maxScroll)
    
    if math.abs(currentScrollY - targetScrollY) > 0.05 then
        currentScrollY = currentScrollY + (targetScrollY - currentScrollY) * 0.15
        if math.abs(currentScrollY - targetScrollY) <= 0.05 then
            currentScrollY = targetScrollY
        end
        Scroll.CanvasPosition = Vector2.new(0, currentScrollY)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseWheel and ScreenGui.Enabled and Main.Visible then
        local mousePos = input.Position
        local scrollPos = Scroll.AbsolutePosition
        local scrollSize = Scroll.AbsoluteSize
        
        if mousePos.X >= scrollPos.X and mousePos.X <= (scrollPos.X + scrollSize.X)
           and mousePos.Y >= scrollPos.Y and mousePos.Y <= (scrollPos.Y + scrollSize.Y) then
            
            local maxScroll = math.max(0, Scroll.CanvasSize.Y.Offset - Scroll.AbsoluteSize.Y)
            local scrollStep = 14
            
            if input.Position.Z > 0 then
                targetScrollY = math.clamp(targetScrollY - scrollStep, 0, maxScroll)
            else
                targetScrollY = math.clamp(targetScrollY + scrollStep, 0, maxScroll)
            end
        end
    end
end)

Scroll.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        isDragging = true
        dragStartY = input.Position.Y
        dragStartScrollY = targetScrollY
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if isDragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
        local deltaY = input.Position.Y - dragStartY
        local maxScroll = math.max(0, Scroll.CanvasSize.Y.Offset - Scroll.AbsoluteSize.Y)
        targetScrollY = math.clamp(dragStartScrollY - (deltaY * 0.75), 0, maxScroll)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        isDragging = false
    end
end)

-- Component Helper: Action Button
local function CreateButton(name, layoutOrder, callback)
    local BtnFrame = Instance.new("Frame")
    BtnFrame.Name = name
    BtnFrame.Parent = Scroll
    BtnFrame.Size = UDim2.new(1, -12, 0, 30)
    BtnFrame.BackgroundColor3 = DARK2
    BtnFrame.BorderSizePixel = 0
    BtnFrame.LayoutOrder = layoutOrder

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 6)
    Corner.Parent = BtnFrame

    local Stroke = Instance.new("UIStroke")
    Stroke.Color = RED
    Stroke.Thickness = 1
    Stroke.Parent = BtnFrame

    local ActionBtn = Instance.new("TextButton")
    ActionBtn.Name = "ActionBtn"
    ActionBtn.Parent = BtnFrame
    ActionBtn.Size = UDim2.new(1, 0, 1, 0)
    ActionBtn.BackgroundTransparency = 1
    ActionBtn.Text = name
    ActionBtn.TextColor3 = WHITE
    ActionBtn.TextSize = 12
    ActionBtn.Font = Enum.Font.Bangers
    ActionBtn.AutoButtonColor = false

    ActionBtn.MouseButton1Click:Connect(function()
        TweenService:Create(BtnFrame, TweenInfo.new(0.1), {BackgroundColor3 = RED}):Play()
        task.wait(0.1)
        TweenService:Create(BtnFrame, TweenInfo.new(0.15), {BackgroundColor3 = DARK2}):Play()
        if callback then
            callback()
        end
    end)

    return BtnFrame
end

-- Component Helper: Toggle Feature
local function CreateToggle(name, layoutOrder, defaultState, callback)
    local Feature = Instance.new("Frame")
    Feature.Name = name
    Feature.Parent = Scroll
    Feature.Size = UDim2.new(1, -12, 0, 30)
    Feature.BackgroundColor3 = DARK2
    Feature.BorderSizePixel = 0
    Feature.LayoutOrder = layoutOrder

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 6)
    Corner.Parent = Feature

    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Color3.fromRGB(40, 40, 40)
    Stroke.Thickness = 1
    Stroke.Parent = Feature

    local Label = Instance.new("TextLabel")
    Label.Name = "Label"
    Label.Parent = Feature
    Label.BackgroundTransparency = 1
    Label.Position = UDim2.fromOffset(8, 0)
    Label.Size = UDim2.new(1, -46, 1, 0)
    Label.Text = name
    Label.TextColor3 = WHITE
    Label.TextSize = 12
    Label.Font = Enum.Font.Bangers
    Label.TextXAlignment = Enum.TextXAlignment.Left

    local Toggle = Instance.new("TextButton")
    Toggle.Name = "Toggle"
    Toggle.Parent = Feature
    Toggle.Size = UDim2.fromOffset(30, 20)
    Toggle.Position = UDim2.new(1, -36, 0.5, -10)
    Toggle.BackgroundColor3 = defaultState and Color3.fromRGB(80, 255, 100) or RED
    Toggle.BorderSizePixel = 0
    Toggle.Text = ""
    Toggle.AutoButtonColor = false

    local ToggleCorner = Instance.new("UICorner")
    ToggleCorner.CornerRadius = UDim.new(0, 5)
    ToggleCorner.Parent = Toggle

    local Enabled = defaultState or false

    Toggle.MouseButton1Click:Connect(function()
        Enabled = not Enabled
        if Enabled then
            TweenService:Create(Toggle, TweenInfo.new(0.15), {
                BackgroundColor3 = Color3.fromRGB(80, 255, 100)
            }):Play()
        else
            TweenService:Create(Toggle, TweenInfo.new(0.15), {
                BackgroundColor3 = RED
            }):Play()
        end

        if callback then
            callback(Enabled)
        end
    end)

    return Feature
end

-- Component Helper: Interactive Slider
local function CreateSlider(name, minVal, maxVal, defaultVal, layoutOrder, callback)
    local SliderFrame = Instance.new("Frame")
    SliderFrame.Name = name
    SliderFrame.Parent = Scroll
    SliderFrame.Size = UDim2.new(1, -12, 0, 42)
    SliderFrame.BackgroundColor3 = DARK2
    SliderFrame.BorderSizePixel = 0
    SliderFrame.LayoutOrder = layoutOrder

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 6)
    Corner.Parent = SliderFrame

    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Color3.fromRGB(40, 40, 40)
    Stroke.Thickness = 1
    Stroke.Parent = SliderFrame

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Name = "Title"
    TitleLabel.Parent = SliderFrame
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Position = UDim2.fromOffset(8, 2)
    TitleLabel.Size = UDim2.new(1, -60, 0, 18)
    TitleLabel.Text = name
    TitleLabel.TextColor3 = WHITE
    TitleLabel.TextSize = 11
    TitleLabel.Font = Enum.Font.Bangers
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

    local ValueLabel = Instance.new("TextLabel")
    ValueLabel.Name = "Value"
    ValueLabel.Parent = SliderFrame
    ValueLabel.BackgroundTransparency = 1
    ValueLabel.Position = UDim2.new(1, -55, 0, 2)
    ValueLabel.Size = UDim2.fromOffset(48, 18)
    ValueLabel.Text = tostring(defaultVal)
    ValueLabel.TextColor3 = RED
    ValueLabel.TextSize = 11
    ValueLabel.Font = Enum.Font.Bangers
    ValueLabel.TextXAlignment = Enum.TextXAlignment.Right

    local SliderBar = Instance.new("Frame")
    SliderBar.Name = "SliderBar"
    SliderBar.Parent = SliderFrame
    SliderBar.Position = UDim2.new(0, 8, 0, 24)
    SliderBar.Size = UDim2.new(1, -16, 0, 8)
    SliderBar.BackgroundColor3 = GRAY
    SliderBar.BorderSizePixel = 0

    local BarCorner = Instance.new("UICorner")
    BarCorner.CornerRadius = UDim.new(1, 0)
    BarCorner.Parent = SliderBar

    local Fill = Instance.new("Frame")
    Fill.Name = "Fill"
    Fill.Parent = SliderBar
    local initialPct = math.clamp((defaultVal - minVal) / (maxVal - minVal), 0, 1)
    Fill.Size = UDim2.new(initialPct, 0, 1, 0)
    Fill.BackgroundColor3 = RED
    Fill.BorderSizePixel = 0

    local FillCorner = Instance.new("UICorner")
    FillCorner.CornerRadius = UDim.new(1, 0)
    FillCorner.Parent = Fill

    local isSliding = false
    local function update(input)
        local barPos = SliderBar.AbsolutePosition.X
        local barSize = SliderBar.AbsoluteSize.X
        local ratio = math.clamp((input.Position.X - barPos) / barSize, 0, 1)
        local value = math.floor(minVal + (maxVal - minVal) * ratio)
        Fill.Size = UDim2.new(ratio, 0, 1, 0)
        ValueLabel.Text = tostring(value)
        if callback then
            callback(value)
        end
    end

    SliderBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isSliding = true
            update(input)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if isSliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            update(input)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isSliding = false
        end
    end)

    return SliderFrame
end

--========================================================--
-- RENDER FEATURES INTO SAKI SCRIPTS UI
--========================================================--

-- 1. Set Base Position Button
CreateButton("📍 SET BASE POSITION", 1, function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        SavedBaseCFrame = LocalPlayer.Character.HumanoidRootPart.CFrame
        pcall(function()
            StarterGui:SetCore("SendNotification", {
                Title = "BASE POSITION SAVED",
                Text = "Teleport position updated to your coordinates!",
                Duration = 3
            })
        end)
    end
end)

-- 2. Auto Steal (Instant Interaction)
CreateToggle("AUTO STEAL (INSTANT)", 2, false, function(v)
    AutoSteal = v
end)

-- 3. Auto Teleport to Base (On Egg Steal)
CreateToggle("TP TO BASE ON STEAL", 3, false, function(v)
    AutoTeleportBase = v
end)

-- 4. Auto Hatch Eggs
CreateToggle("AUTO HATCH EGGS", 4, false, function(v)
    AutoHatch = v
end)

-- 5. Enable Fast Walk Speed
CreateToggle("ENABLE FAST WALK", 5, false, function(v)
    FastWalkToggle = v
    if not v and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = 16
    end
end)

-- 6. Walk Speed Multiplier Slider
CreateSlider("SPEED MULTIPLIER", 16, 150, 50, 6, function(val)
    SpeedValue = val
end)

-- 7. Infinite Jump
CreateToggle("INFINITE JUMP", 7, false, function(v)
    InfJump = v
end)

-- Footer
local FooterDivider = Instance.new("Frame")
FooterDivider.Name = "FooterDivider"
FooterDivider.Parent = Main
FooterDivider.Position = UDim2.new(0, 0, 1, -24)
FooterDivider.Size = UDim2.new(1, 0, 0, 1.5)
FooterDivider.BackgroundColor3 = RED
FooterDivider.BorderSizePixel = 0

local MadeBy = Instance.new("TextLabel")
MadeBy.Name = "MadeBy"
MadeBy.Parent = Main
MadeBy.BackgroundTransparency = 1
MadeBy.Position = UDim2.new(0, 0, 1, -23)
MadeBy.Size = UDim2.new(1, 0, 0, 22)
MadeBy.RichText = true
MadeBy.Text = 'MADE BY: <font color="rgb(255,25,35)">' .. CREDIT .. '</font>'
MadeBy.TextColor3 = WHITE
MadeBy.TextSize = 11
MadeBy.Font = Enum.Font.Bangers
MadeBy.TextXAlignment = Enum.TextXAlignment.Center
MadeBy.TextYAlignment = Enum.TextYAlignment.Center

-- Minimize Mechanism
local Minimized = false
Minimize.MouseButton1Click:Connect(function()
    Minimized = not Minimized
    if Minimized then
        Content.Visible = false
        FooterDivider.Visible = false
        MadeBy.Visible = false
        TweenService:Create(Main, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.fromOffset(235, 32)
        }):Play()
    else
        TweenService:Create(Main, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.fromOffset(235, 275)
        }):Play()
        task.wait(0.18)
        Content.Visible = true
        FooterDivider.Visible = true
        MadeBy.Visible = true
    end
end)

-- Close Mechanism
Close.MouseButton1Click:Connect(function()
    ScreenGui.Enabled = false
end)

-- Draggable Main Frame
local Dragging = false
local DragStart
local StartPosition

TopBar.InputBegan:Connect(function(Input)
    if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
        Dragging = true
        DragStart = Input.Position
        StartPosition = Main.Position
    end
end)

TopBar.InputEnded:Connect(function(Input)
    if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
        Dragging = false
    end
end)

UserInputService.InputChanged:Connect(function(Input)
    if not Dragging then return end
    if Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch then
        local Delta = Input.Position - DragStart
        Main.Position = UDim2.new(
            StartPosition.X.Scale,
            StartPosition.X.Offset + Delta.X,
            StartPosition.Y.Scale,
            StartPosition.Y.Offset + Delta.Y
        )
    end
end)

-- Floating Mobile Button
local FloatingBtn = Instance.new("TextButton")
FloatingBtn.Name = "FloatingBtn"
FloatingBtn.Size = UDim2.fromOffset(40, 40)
FloatingBtn.Position = UDim2.new(0, 15, 0.5, -20)
FloatingBtn.BackgroundColor3 = DARK
FloatingBtn.Text = "🥚"
FloatingBtn.TextColor3 = RED
FloatingBtn.TextSize = 18
FloatingBtn.Font = Enum.Font.Bangers
FloatingBtn.Parent = ScreenGui
FloatingBtn.Active = true
FloatingBtn.Draggable = true

local FloatCorner = Instance.new("UICorner")
FloatCorner.CornerRadius = UDim.new(1, 0)
FloatCorner.Parent = FloatingBtn

local FloatStroke = Instance.new("UIStroke")
FloatStroke.Color = RED
FloatStroke.Thickness = 1.8
FloatStroke.Parent = FloatingBtn

FloatingBtn.MouseButton1Click:Connect(function()
    ScreenGui.Enabled = true
    Main.Visible = not Main.Visible
end)

-- Notification
pcall(function()
    StarterGui:SetCore("SendNotification", {
        Title = "SAKI SCRIPTS",
        Text = "Steal An Egg Automation Hub Loaded!",
        Duration = 4
    })
end)
