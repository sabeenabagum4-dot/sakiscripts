--========================================================--
--                 SAKI SCRIPTS UI (MASTER EDITION)
--               STEAL AN EGG • FARM & AUTO SUITE
--========================================================--

local GAME_NAME = "STEAL AN EGG"
local CREDIT    = "SAKI SCRIPTS"

local Players           = game:GetService("Players")
local Workspace         = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService  = game:GetService("UserInputService")
local RunService        = game:GetService("RunService")
local TweenService      = game:GetService("TweenService")
local CoreGui           = game:GetService("CoreGui")
local StarterGui        = game:GetService("StarterGui")

local LocalPlayer = Players.LocalPlayer
while not LocalPlayer do
    task.wait(0.05)
    LocalPlayer = Players.LocalPlayer
end

local Camera = Workspace.CurrentCamera

-- Safe Parent Selection
local function getGuiParent()
    local success, result = pcall(function() return (gethui and gethui()) or CoreGui end)
    if success and result then return result end
    return LocalPlayer:WaitForChild("PlayerGui")
end

-- Clean previous instances
pcall(function()
    for _, name in ipairs({"SakiScriptsStealAnEggUI", "RobloxScriptUI_Badshah", "SakiScriptsMasterUI"}) do
        local parent = getGuiParent()
        if parent and parent:FindFirstChild(name) then parent[name]:Destroy() end
        if CoreGui:FindFirstChild(name) then CoreGui[name]:Destroy() end
        if LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild(name) then
            LocalPlayer.PlayerGui[name]:Destroy()
        end
    end
end)

--========================================================================
-- ⚡ STATE MANAGEMENT & CORE ENGINES
--========================================================================
local State = {
    AutoSteal    = false,
    AutoTreadmill = false,
    AutoHatch    = false,
    WalkSpeed    = 16,
    InfiniteJump = false
}

local SavedBaseCFrame = nil

-- Helper: Trigger Proximity Prompts
local function triggerPrompt(prompt)
    if not prompt or not prompt:IsA("ProximityPrompt") then return end
    pcall(function()
        if fireproximityprompt then
            fireproximityprompt(prompt, 0)
        else
            prompt:InputHoldBegin()
            task.wait(prompt.HoldDuration or 0.1)
            prompt:InputHoldEnd()
        end
    end)
end

-- 1. Auto Steal & Safe Teleport Engine
task.spawn(function()
    while true do
        task.wait(0.3)
        if State.AutoSteal then
            pcall(function()
                local char = LocalPlayer.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                if root then
                    if not SavedBaseCFrame then
                        SavedBaseCFrame = root.CFrame
                    end

                    for _, obj in ipairs(Workspace:GetDescendants()) do
                        if not State.AutoSteal then break end
                        if obj:IsA("ProximityPrompt") then
                            local parentName = string.lower(obj.Parent and obj.Parent.Name or "")
                            local actionText = string.lower(obj.ActionText or "")
                            local objText = string.lower(obj.ObjectText or "")

                            if string.find(parentName, "egg") or string.find(actionText, "steal") or string.find(actionText, "take") or string.find(objText, "egg") then
                                local eggPart = obj.Parent:IsA("BasePart") and obj.Parent or obj.Parent:FindFirstChildWhichIsA("BasePart")
                                if eggPart then
                                    root.CFrame = eggPart.CFrame + Vector3.new(0, 3, 0)
                                    task.wait(0.1)
                                    triggerPrompt(obj)
                                    task.wait(0.1)
                                    if SavedBaseCFrame then
                                        root.CFrame = SavedBaseCFrame
                                    end
                                end
                            end
                        end
                    end
                end
            end)
        end
    end
end)

-- 2. Auto Treadmill Train Engine
task.spawn(function()
    while true do
        task.wait(0.1)
        if State.AutoTreadmill then
            pcall(function()
                local char = LocalPlayer.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                if root then
                    for _, obj in ipairs(Workspace:GetDescendants()) do
                        if not State.AutoTreadmill then break end
                        local oName = string.lower(obj.Name)
                        if string.find(oName, "treadmill") or string.find(oName, "train") or string.find(oName, "speedpad") then
                            if obj:IsA("TouchTransmitter") and obj.Parent then
                                if firetouchinterest then
                                    firetouchinterest(obj.Parent, root, 0)
                                    task.wait()
                                    firetouchinterest(obj.Parent, root, 1)
                                end
                            elseif obj:IsA("ProximityPrompt") then
                                triggerPrompt(obj)
                            end
                        end
                    end

                    for _, container in ipairs({ReplicatedStorage, LocalPlayer:FindFirstChild("PlayerGui")}) do
                        if container then
                            for _, remote in ipairs(container:GetDescendants()) do
                                if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") then
                                    local rName = string.lower(remote.Name)
                                    if string.find(rName, "train") or string.find(rName, "treadmill") or string.find(rName, "addspeed") or string.find(rName, "speed") then
                                        pcall(function()
                                            if remote:IsA("RemoteEvent") then
                                                remote:FireServer()
                                                remote:FireServer(true)
                                            else
                                                remote:InvokeServer()
                                            end
                                        end)
                                    end
                                end
                            end
                        end
                    end
                end
            end)
        end
    end
end)

-- 3. Auto Hatch & Place Engine
task.spawn(function()
    while true do
        task.wait(0.4)
        if State.AutoHatch then
            pcall(function()
                for _, container in ipairs({ReplicatedStorage, LocalPlayer:FindFirstChild("PlayerGui"), Workspace}) do
                    if container then
                        for _, remote in ipairs(container:GetDescendants()) do
                            if not State.AutoHatch then break end
                            if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") then
                                local rName = string.lower(remote.Name)
                                if string.find(rName, "hatch") or string.find(rName, "place") or string.find(rName, "openegg") or string.find(rName, "egghatch") then
                                    pcall(function()
                                        if remote:IsA("RemoteEvent") then
                                            remote:FireServer()
                                            remote:FireServer(true)
                                            remote:FireServer(1)
                                        else
                                            remote:InvokeServer()
                                            remote:InvokeServer(true)
                                        end
                                    end)
                                end
                            end
                        end
                    end
                end

                for _, obj in ipairs(Workspace:GetDescendants()) do
                    if not State.AutoHatch then break end
                    if obj:IsA("ProximityPrompt") then
                        local aText = string.lower(obj.ActionText or "")
                        local oText = string.lower(obj.ObjectText or "")
                        if string.find(aText, "hatch") or string.find(aText, "place") or string.find(oText, "hatch") then
                            triggerPrompt(obj)
                        end
                    end
                end
            end)
        end
    end
end)

-- 4. WalkSpeed Modifier Loop
RunService.RenderStepped:Connect(function()
    pcall(function()
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum and State.WalkSpeed and State.WalkSpeed ~= 16 then
            hum.WalkSpeed = State.WalkSpeed
        end
    end)
end)

-- 5. Infinite Air Jump System
UserInputService.JumpRequest:Connect(function()
    if State.InfiniteJump then
        pcall(function()
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end)
    end
end)

--========================================================--
-- 🎨 SAKI SCRIPTS MASTER RED-DARK UI SYSTEM
--========================================================--
local RED   = Color3.fromRGB(255, 25, 35)
local DARK  = Color3.fromRGB(12, 12, 12)
local DARK2 = Color3.fromRGB(18, 18, 18)
local WHITE = Color3.fromRGB(255, 255, 255)
local GRAY  = Color3.fromRGB(30, 30, 30)

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SakiScriptsStealAnEggUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = getGuiParent()

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Parent = ScreenGui
Main.Size = UDim2.fromOffset(235, 265)
Main.Position = UDim2.new(0.5, -117, 0.5, -132)
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

local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Parent = Main
TopBar.Size = UDim2.new(1, 0, 0, 32)
TopBar.BackgroundTransparency = 1
TopBar.BorderSizePixel = 0

local GameTitle = Instance.new("TextLabel")
GameTitle.Name = "GameTitle"
GameTitle.Parent = TopBar
GameTitle.BackgroundTransparency = 1
GameTitle.Position = UDim2.fromOffset(10, 0)
GameTitle.Size = UDim2.new(1, -65, 1, 0)
GameTitle.Text = GAME_NAME
GameTitle.TextColor3 = RED
GameTitle.TextSize = 13
GameTitle.Font = Enum.Font.Bangers
GameTitle.TextXAlignment = Enum.TextXAlignment.Left
GameTitle.TextYAlignment = Enum.TextYAlignment.Center

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
Instance.new("UICorner", Minimize).CornerRadius = UDim.new(0, 5)

local MinStroke = Instance.new("UIStroke", Minimize)
MinStroke.Color = RED
MinStroke.Thickness = 1

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
Instance.new("UICorner", Close).CornerRadius = UDim.new(0, 5)

local CloseStroke = Instance.new("UIStroke", Close)
CloseStroke.Color = RED
CloseStroke.Thickness = 1

local TopDivider = Instance.new("Frame")
TopDivider.Name = "TopDivider"
TopDivider.Parent = Main
TopDivider.Position = UDim2.fromOffset(0, 32)
TopDivider.Size = UDim2.new(1, 0, 0, 1.5)
TopDivider.BackgroundColor3 = RED
TopDivider.BorderSizePixel = 0

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
Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
Scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y

local ListLayout = Instance.new("UIListLayout", Scroll)
ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
ListLayout.Padding = UDim.new(0, 5)
ListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local TopPadding = Instance.new("UIPadding", Scroll)
TopPadding.PaddingTop = UDim.new(0, 4)
TopPadding.PaddingBottom = UDim.new(0, 6)

local FooterDivider = Instance.new("Frame", Main)
FooterDivider.Name = "FooterDivider"
FooterDivider.Position = UDim2.new(0, 0, 1, -24)
FooterDivider.Size = UDim2.new(1, 0, 0, 1.5)
FooterDivider.BackgroundColor3 = RED
FooterDivider.BorderSizePixel = 0

local MadeBy = Instance.new("TextLabel", Main)
MadeBy.Name = "MadeBy"
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
Instance.new("UICorner", FloatingBtn).CornerRadius = UDim.new(1, 0)

local FloatStroke = Instance.new("UIStroke", FloatingBtn)
FloatStroke.Color = RED
FloatStroke.Thickness = 1.8

FloatingBtn.MouseButton1Click:Connect(function()
    ScreenGui.Enabled = true
    Main.Visible = not Main.Visible
end)

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
        Minimize.Text = "+"
    else
        TweenService:Create(Main, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.fromOffset(235, 265)
        }):Play()
        task.wait(0.18)
        Content.Visible = true
        FooterDivider.Visible = true
        MadeBy.Visible = true
        Minimize.Text = "−"
    end
end)

Close.MouseButton1Click:Connect(function()
    ScreenGui.Enabled = false
end)

local Dragging = false
local DragStart, StartPosition

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

local itemOrder = 0

local function AddSection(title)
    itemOrder = itemOrder + 1
    local Sec = Instance.new("Frame", Scroll)
    Sec.Size = UDim2.new(1, -12, 0, 18)
    Sec.BackgroundTransparency = 1
    Sec.LayoutOrder = itemOrder

    local lbl = Instance.new("TextLabel", Sec)
    lbl.Size = UDim2.new(1, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = "-- " .. string.upper(title) .. " --"
    lbl.TextColor3 = RED
    lbl.TextSize = 11
    lbl.Font = Enum.Font.Bangers
    lbl.TextXAlignment = Enum.TextXAlignment.Center
end

local function CreateToggle(name, default, callback)
    itemOrder = itemOrder + 1
    local Feature = Instance.new("Frame", Scroll)
    Feature.Name = name
    Feature.Size = UDim2.new(1, -12, 0, 30)
    Feature.BackgroundColor3 = DARK2
    Feature.BorderSizePixel = 0
    Feature.LayoutOrder = itemOrder
    Instance.new("UICorner", Feature).CornerRadius = UDim.new(0, 6)

    local Stroke = Instance.new("UIStroke", Feature)
    Stroke.Color = Color3.fromRGB(40, 40, 40)
    Stroke.Thickness = 1

    local Label = Instance.new("TextLabel", Feature)
    Label.BackgroundTransparency = 1
    Label.Position = UDim2.fromOffset(8, 0)
    Label.Size = UDim2.new(1, -46, 1, 0)
    Label.Text = name
    Label.TextColor3 = WHITE
    Label.TextSize = 12
    Label.Font = Enum.Font.Bangers
    Label.TextXAlignment = Enum.TextXAlignment.Left

    local Toggle = Instance.new("TextButton", Feature)
    Toggle.Size = UDim2.fromOffset(30, 20)
    Toggle.Position = UDim2.new(1, -36, 0.5, -10)
    Toggle.BackgroundColor3 = default and Color3.fromRGB(80, 255, 100) or RED
    Toggle.BorderSizePixel = 0
    Toggle.Text = ""
    Toggle.AutoButtonColor = false
    Instance.new("UICorner", Toggle).CornerRadius = UDim.new(0, 5)

    local Enabled = default or false

    local function update(state)
        Enabled = state
        TweenService:Create(Toggle, TweenInfo.new(0.15), {
            BackgroundColor3 = Enabled and Color3.fromRGB(80, 255, 100) or RED
        }):Play()
        if callback then callback(Enabled) end
    end

    Toggle.MouseButton1Click:Connect(function() update(not Enabled) end)

    local ClickCover = Instance.new("TextButton", Feature)
    ClickCover.Size = UDim2.new(1, -38, 1, 0)
    ClickCover.BackgroundTransparency = 1
    ClickCover.Text = ""
    ClickCover.MouseButton1Click:Connect(function() update(not Enabled) end)

    return update
end

local function CreateSlider(name, min, max, default, callback)
    itemOrder = itemOrder + 1
    local val = default or min
    local Feature = Instance.new("Frame", Scroll)
    Feature.Size = UDim2.new(1, -12, 0, 42)
    Feature.BackgroundColor3 = DARK2
    Feature.BorderSizePixel = 0
    Feature.LayoutOrder = itemOrder
    Instance.new("UICorner", Feature).CornerRadius = UDim.new(0, 6)

    local Stroke = Instance.new("UIStroke", Feature)
    Stroke.Color = Color3.fromRGB(40, 40, 40)
    Stroke.Thickness = 1

    local Label = Instance.new("TextLabel", Feature)
    Label.BackgroundTransparency = 1
    Label.Position = UDim2.fromOffset(8, 2)
    Label.Size = UDim2.new(1, -50, 0, 18)
    Label.Text = name
    Label.TextColor3 = WHITE
    Label.TextSize = 11.5
    Label.Font = Enum.Font.Bangers
    Label.TextXAlignment = Enum.TextXAlignment.Left

    local ValLabel = Instance.new("TextLabel", Feature)
    ValLabel.BackgroundTransparency = 1
    ValLabel.Position = UDim2.new(1, -45, 0, 2)
    ValLabel.Size = UDim2.new(0, 38, 0, 18)
    ValLabel.Text = tostring(val)
    ValLabel.TextColor3 = RED
    ValLabel.TextSize = 11.5
    ValLabel.Font = Enum.Font.Bangers
    ValLabel.TextXAlignment = Enum.TextXAlignment.Right

    local SliderBar = Instance.new("TextButton", Feature)
    SliderBar.Size = UDim2.new(1, -16, 0, 6)
    SliderBar.Position = UDim2.new(0, 8, 0, 26)
    SliderBar.BackgroundColor3 = GRAY
    SliderBar.Text = ""
    SliderBar.AutoButtonColor = false
    Instance.new("UICorner", SliderBar).CornerRadius = UDim.new(1, 0)

    local Fill = Instance.new("Frame", SliderBar)
    local initRatio = math.clamp((val - min) / (max - min), 0, 1)
    Fill.Size = UDim2.new(initRatio, 0, 1, 0)
    Fill.BackgroundColor3 = RED
    Fill.BorderSizePixel = 0
    Instance.new("UICorner", Fill).CornerRadius = UDim.new(1, 0)

    local dragging = false
    local function updateInput(input)
        local relX = math.clamp(input.Position.X - SliderBar.AbsolutePosition.X, 0, SliderBar.AbsoluteSize.X)
        local ratio = relX / SliderBar.AbsoluteSize.X
        val = math.floor(min + (max - min) * ratio)
        Fill.Size = UDim2.new(ratio, 0, 1, 0)
        ValLabel.Text = tostring(val)
        if callback then callback(val) end
    end

    SliderBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            updateInput(input)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            updateInput(input)
        end
    end)
end

--========================================================--
-- 📋 POPULATE SAKI STEAL AN EGG FEATURES
--========================================================--

AddSection("Auto Farm & Steal")
CreateToggle("Auto Steal & Return", false, function(v)
    State.AutoSteal = v
    if v and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        SavedBaseCFrame = LocalPlayer.Character.HumanoidRootPart.CFrame
    end
end)
CreateToggle("Auto Treadmill Train", false, function(v) State.AutoTreadmill = v end)
CreateToggle("Auto Hatch & Place", false, function(v) State.AutoHatch = v end)

AddSection("Movement & Utilities")
CreateSlider("WalkSpeed Boost", 16, 150, State.WalkSpeed, function(v)
    State.WalkSpeed = v
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then hum.WalkSpeed = v end
end)
CreateToggle("Infinite Jump", false, function(v) State.InfiniteJump = v end)

pcall(function()
    StarterGui:SetCore("SendNotification", {
        Title = "[SAKI SCRIPTS]",
        Text = "Steal An Egg Master Hub Loaded!",
        Duration = 3.5
    })
end)
print("[SAKI SCRIPTS] Steal An Egg Master Hub Loaded Successfully!")
