--========================================================--
--                 SAKI SCRIPTS UI (MASTER EDITION)
--               BALL VS BALL • COMBAT & QUEUE SUITE
--========================================================--

local GAME_NAME = "BALL VS BALL"
local CREDIT    = "SAKI SCRIPTS"

local Players           = game:GetService("Players")
local Workspace         = game:GetService("Workspace")
local RunService        = game:GetService("RunService")
local UserInputService  = game:GetService("UserInputService")
local TweenService      = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui           = game:GetService("CoreGui")
local VirtualUser       = game:GetService("VirtualUser")
local StarterGui        = game:GetService("StarterGui")

local LocalPlayer = Players.LocalPlayer
while not LocalPlayer do
    task.wait(0.05)
    LocalPlayer = Players.LocalPlayer
end

local Camera = Workspace.CurrentCamera

local function getGuiParent()
    local success, result = pcall(function() return (gethui and gethui()) or CoreGui end)
    if success and result then return result end
    return LocalPlayer:WaitForChild("PlayerGui")
end

-- Clean previous instances
pcall(function()
    for _, name in ipairs({"SakiScriptsBallVsBallUI", "HamiHub_BallVsBall_UI", "SakiScriptsMasterUI"}) do
        local parent = getGuiParent()
        if parent and parent:FindFirstChild(name) then parent[name]:Destroy() end
        if CoreGui:FindFirstChild(name) then CoreGui[name]:Destroy() end
        if LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild(name) then
            LocalPlayer.PlayerGui[name]:Destroy()
        end
    end
end)

--------------------------------------------------------------------------------
-- GLOBAL STATE
--------------------------------------------------------------------------------
local State = {
    -- Smart Queue Engine
    AutoQueue = false,
    PrioritizeInstantMatches = true, -- Prioritize 1/2 over 0/2

    -- Combat Engine
    CombatRamActive = false,
    RamSpeed = 110,
    WindUpDistance = 14,

    -- RNG Automation
    AutoReroll = false,
    TargetRarity = "Legendary",

    -- Farm & Drops
    AutoCollectCoins = false,
    CollectRadius = 80,

    -- Visual Recon
    OpponentESP = false,

    -- Movement / Toggles
    WalkSpeedBoost = 16,
    InfJump = false,
    AntiAFK = true
}

local RarityList = {"Mythic", "Legendary", "Epic", "Rare"}
local currentlyQueuedPad = nil

--------------------------------------------------------------------------------
-- CHARACTER RESOLUTION & ZONE DETECTION
--------------------------------------------------------------------------------

local function isAlive(char)
    char = char or LocalPlayer.Character
    if not char then return false end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Ball") or char.PrimaryPart
    return (hum ~= nil and hum.Health > 0 and root ~= nil) or (root ~= nil and hum == nil)
end

local function getRoot(char)
    char = char or LocalPlayer.Character
    if not char then return nil end
    return char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Ball") or char:FindFirstChildWhichIsA("BasePart") or char.PrimaryPart
end

-- Detect active combat arena
local cachedArena = nil
local function getArenaInstance()
    if cachedArena and cachedArena.Parent then return cachedArena end
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") or obj:IsA("Folder") or obj:IsA("BasePart") then
            local n = string.lower(obj.Name)
            if (n:find("arena") or n:find("duel") or n:find("battleground") or n:find("ring")) and not obj:IsDescendantOf(LocalPlayer.Character) then
                cachedArena = obj
                return obj
            end
        end
    end
    return nil
end

local function isInsideArena(part)
    if not part then return false end
    local arena = getArenaInstance()
    if arena then
        local arenaPart = arena:IsA("BasePart") and arena or arena:FindFirstChildWhichIsA("BasePart") or arena.PrimaryPart
        if arenaPart then
            local dist = (part.Position - arenaPart.Position).Magnitude
            return dist < 140
        end
    end
    local spawn = Workspace:FindFirstChildWhichIsA("SpawnLocation", true)
    if spawn then
        return (part.Position - spawn.Position).Magnitude > 90
    end
    return false
end

-- Resolves the active 1v1 opponent inside the arena
local function getActiveDuelOpponent()
    local myRoot = getRoot()
    if not myRoot then return nil end

    local closestTarget = nil
    local minDistance = math.huge

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and isAlive(player.Character) then
            local targetPart = getRoot(player.Character)
            if targetPart and isInsideArena(targetPart) then
                local dist = (targetPart.Position - myRoot.Position).Magnitude
                if dist < minDistance then
                    minDistance = dist
                    closestTarget = targetPart
                end
            end
        end
    end
    return closestTarget, minDistance
end

local function fireGameRemote(keywords, ...)
    local args = { ... }
    for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            local name = obj.Name:lower()
            for _, kw in ipairs(keywords) do
                if name:find(kw:lower()) then
                    pcall(function()
                        if obj:IsA("RemoteEvent") then
                            obj:FireServer(unpack(args))
                        else
                            obj:InvokeServer(unpack(args))
                        end
                    end)
                    return true
                end
            end
        end
    end
    return false
end

--------------------------------------------------------------------------------
-- SMART 2-PLAYER STATION SCANNER & AUTO QUEUE
--------------------------------------------------------------------------------

local function isPlayerStandingNear(pos, radius)
    radius = radius or 4.5
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and isAlive(player.Character) then
            local root = getRoot(player.Character)
            if root and (root.Position - pos).Magnitude <= radius then
                return true
            end
        end
    end
    return false
end

-- Finds all 2-player pads matching the image structure
local function scanAllQueueStations()
    local candidate1v1 = {} -- 1/2 players (ready for immediate start)
    local candidate0v2 = {} -- 0/2 players (empty stations)

    for _, gui in ipairs(Workspace:GetDescendants()) do
        if gui:IsA("BillboardGui") then
            for _, label in ipairs(gui:GetDescendants()) do
                if label:IsA("TextLabel") and label.Text:find("PLAYERS") then
                    local cur, max = label.Text:match("(%d+)%s*/%s*(%d+)")
                    cur = tonumber(cur)
                    max = tonumber(max)

                    if cur and max and max == 2 then
                        local stationModel = gui.Adornee or gui.Parent
                        while stationModel and not stationModel:IsA("Model") and stationModel.Parent ~= Workspace do
                            stationModel = stationModel.Parent
                        end

                        if stationModel and cur < 2 then
                            local data = {
                                model = stationModel,
                                current = cur,
                                billboard = label
                            }
                            if cur == 1 then
                                table.insert(candidate1v1, data)
                            elseif cur == 0 then
                                table.insert(candidate0v2, data)
                            end
                        end
                    end
                end
            end
        end
    end

    return candidate1v1, candidate0v2
end

-- Locates the specific Pink/Blue open square inside the station
local function findOpenPadSquare(stationModel)
    local leftSquare, rightSquare
    local pads = {}

    for _, part in ipairs(stationModel:GetDescendants()) do
        if part:IsA("BasePart") then
            local n = part.Name:lower()
            if n:find("pad") or n:find("stand") or n:find("square") or n:find("plate") or n:find("button") then
                table.insert(pads, part)
            end
        end
    end

    -- Pick from candidate parts based on spacing
    if #pads >= 2 then
        table.sort(pads, function(a, b) return a.Position.X < b.Position.X end)
        leftSquare = pads[1]
        rightSquare = pads[#pads]
    end

    -- If no explicitly named child pads exist, calculate left/right offsets from the station center
    local centerPart = stationModel:IsA("BasePart") and stationModel or stationModel.PrimaryPart or stationModel:FindFirstChildWhichIsA("BasePart")
    if centerPart then
        local cf = centerPart.CFrame
        local leftPos = (cf * CFrame.new(-3.2, 1.2, 0)).Position
        local rightPos = (cf * CFrame.new(3.2, 1.2, 0)).Position

        if leftSquare and isPlayerStandingNear(leftSquare.Position) then
            return rightSquare or rightPos
        elseif rightSquare and isPlayerStandingNear(rightSquare.Position) then
            return leftSquare or leftPos
        elseif isPlayerStandingNear(leftPos) then
            return rightPos
        else
            return leftPos
        end
    end

    return nil
end

-- Smart Queue Loop
task.spawn(function()
    while true do
        task.wait(1.0)
        if State.AutoQueue and isAlive() then
            local myRoot = getRoot()

            -- Only look for stations if we're currently outside the arena (in the lobby)
            if myRoot and not isInsideArena(myRoot) then
                -- Check if we are already comfortably standing on a valid waiting pad
                local isAlreadyStandingOnPad = false
                if currentlyQueuedPad and isPlayerStandingNear(currentlyQueuedPad, 3) then
                    isAlreadyStandingOnPad = true
                end

                if not isAlreadyStandingOnPad then
                    local readyStations, emptyStations = scanAllQueueStations()
                    local chosenStation = nil

                    -- Priority 1: Match with 1 player waiting for immediate duel
                    if State.PrioritizeInstantMatches and #readyStations > 0 then
                        chosenStation = readyStations[1]
                    elseif #emptyStations > 0 then
                        chosenStation = emptyStations[1]
                    elseif #readyStations > 0 then
                        chosenStation = readyStations[1]
                    end

                    -- If a station is found, walk/teleport directly into the open square
                    if chosenStation then
                        local targetSquarePos = findOpenPadSquare(chosenStation.model)
                        if targetSquarePos then
                            local dest = typeof(targetSquarePos) == "Vector3" and targetSquarePos or targetSquarePos.Position
                            currentlyQueuedPad = dest

                            myRoot.AssemblyLinearVelocity = Vector3.zero
                            myRoot.CFrame = CFrame.new(dest + Vector3.new(0, 2.5, 0))
                            task.wait(0.5)
                        end
                    end
                end
            else
                -- Inside match: clear queue memory
                currentlyQueuedPad = nil
            end
        end
    end
end)

--------------------------------------------------------------------------------
-- COMBAT ENGINE: RAM & MOMENTUM KNOCKBACK
--------------------------------------------------------------------------------

local ramPhase = "Charge"
local lastPhaseShift = tick()

RunService.Heartbeat:Connect(function()
    if State.CombatRamActive and isAlive() then
        local myRoot = getRoot()
        local enemyPart, dist = getActiveDuelOpponent()

        if myRoot and enemyPart then
            -- Phase 1: Ram forward into the enemy ball
            if ramPhase == "Charge" then
                local attackVector = (enemyPart.Position - myRoot.Position).Unit
                local currentY = myRoot.AssemblyLinearVelocity.Y
                myRoot.AssemblyLinearVelocity = Vector3.new(
                    attackVector.X * State.RamSpeed,
                    currentY,
                    attackVector.Z * State.RamSpeed
                )

                if dist <= 5.5 or (tick() - lastPhaseShift > 1.2) then
                    ramPhase = "WindUp"
                    lastPhaseShift = tick()
                end

            -- Phase 2: Pull back slightly to re-engage with full knockback speed
            elseif ramPhase == "WindUp" then
                local retreatVector = (myRoot.Position - enemyPart.Position).Unit
                myRoot.AssemblyLinearVelocity = Vector3.new(
                    retreatVector.X * (State.RamSpeed * 0.7),
                    myRoot.AssemblyLinearVelocity.Y,
                    retreatVector.Z * (State.RamSpeed * 0.7)
                )

                if dist >= State.WindUpDistance or (tick() - lastPhaseShift > 0.4) then
                    ramPhase = "Charge"
                    lastPhaseShift = tick()
                end
            end
        end
    end
end)

--------------------------------------------------------------------------------
-- REROLL & DROP ENGINES
--------------------------------------------------------------------------------

task.spawn(function()
    while true do
        task.wait(0.3)
        if State.AutoReroll and isAlive() then
            local char = LocalPlayer.Character
            local currentRarity = char and char:GetAttribute("Rarity") or ""

            if tostring(currentRarity):lower() ~= State.TargetRarity:lower() then
                fireGameRemote({"Reroll", "Roll", "ChangeBall", "SpinBall", "ReRollBall"}, State.TargetRarity)
            end
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(0.25)
        if State.AutoCollectCoins and isAlive() then
            local myRoot = getRoot()
            if myRoot then
                for _, obj in ipairs(Workspace:GetDescendants()) do
                    if not State.AutoCollectCoins then break end
                    if obj:IsA("BasePart") then
                        local n = obj.Name:lower()
                        if n:find("coin") or n:find("reward") or n:find("gem") or n:find("drop") or n:find("token") then
                            if (obj.Position - myRoot.Position).Magnitude <= State.CollectRadius then
                                if firetouchinterest then
                                    firetouchinterest(myRoot, obj, 0)
                                    task.wait(0.01)
                                    firetouchinterest(myRoot, obj, 1)
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end)

RunService.Heartbeat:Connect(function(deltaTime)
    if isAlive() and State.WalkSpeedBoost > 16 and not State.CombatRamActive then
        local char = LocalPlayer.Character
        local hum = char:FindFirstChildOfClass("Humanoid")
        local hrp = getRoot(char)
        if hum and hrp and hum.MoveDirection.Magnitude > 0 then
            local speedBoost = (State.WalkSpeedBoost - 16) * deltaTime
            hrp.CFrame = hrp.CFrame + (hum.MoveDirection * speedBoost)
        end
    end
end)

UserInputService.JumpRequest:Connect(function()
    if State.InfJump and isAlive() then
        local char = LocalPlayer.Character
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

LocalPlayer.Idled:Connect(function()
    if State.AntiAFK then
        local vu = game:GetService("VirtualUser")
        if vu then
            pcall(function()
                vu:CaptureController()
                vu:ClickButton2(Vector2.new())
            end)
        end
    end
end)

--------------------------------------------------------------------------------
-- VISUALS: OPPONENT ESP
--------------------------------------------------------------------------------

local espCache = {}
local function clearESP()
    for _, hl in pairs(espCache) do if hl then hl:Destroy() end end
    table.clear(espCache)
end

RunService.RenderStepped:Connect(function()
    if State.OpponentESP then
        local enemyPart, _ = getActiveDuelOpponent()
        if enemyPart and enemyPart.Parent then
            local model = enemyPart.Parent
            if not espCache[model] then
                clearESP()
                local hl = Instance.new("Highlight")
                hl.Name = "Saki_ArenaOpponent_ESP"
                hl.FillColor = Color3.fromRGB(255, 25, 35)
                hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                hl.FillTransparency = 0.35
                hl.Parent = model
                espCache[model] = hl
            end
        else
            clearESP()
        end
    else
        if next(espCache) ~= nil then clearESP() end
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
ScreenGui.Name = "SakiScriptsBallVsBallUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = getGuiParent()

-- MAIN FRAME (MINI COMPACT: 235 x 265)
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

-- TOP BAR
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

-- CONTENT SCROLL CONTAINER
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

-- FOOTER
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

-- FLOATING MOBILE TOGGLE BUTTON
local FloatingBtn = Instance.new("TextButton")
FloatingBtn.Name = "FloatingBtn"
FloatingBtn.Size = UDim2.fromOffset(40, 40)
FloatingBtn.Position = UDim2.new(0, 15, 0.5, -20)
FloatingBtn.BackgroundColor3 = DARK
FloatingBtn.Text = "⚡"
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

-- MINIMIZE & CLOSE BEHAVIOR
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

-- PC & TOUCH DRAGGING
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

--========================================================--
-- SAKI COMPONENT CREATORS
--========================================================--
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

local function CreateSelector(name, options, default, callback)
    itemOrder = itemOrder + 1
    local items = options or {}
    local currentIndex = 1
    if default then
        for i, v in ipairs(items) do
            if v == default then currentIndex = i break end
        end
    end
    if #items == 0 then items = {"None"} end

    local Feature = Instance.new("Frame", Scroll)
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
    Label.Size = UDim2.new(1, -38, 1, 0)
    Label.Text = name .. ": " .. tostring(items[currentIndex])
    Label.TextColor3 = WHITE
    Label.TextSize = 11.5
    Label.Font = Enum.Font.Bangers
    Label.TextXAlignment = Enum.TextXAlignment.Left

    local Btn = Instance.new("TextButton", Feature)
    Btn.Size = UDim2.new(1, 0, 1, 0)
    Btn.BackgroundTransparency = 1
    Btn.Text = ""

    Btn.MouseButton1Click:Connect(function()
        currentIndex = currentIndex + 1
        if currentIndex > #items then currentIndex = 1 end
        local selected = items[currentIndex]
        Label.Text = name .. ": " .. tostring(selected)
        if callback then callback(selected) end
    end)
end

--========================================================--
-- 📋 POPULATE SAKI BALL VS BALL FEATURES
--========================================================--

AddSection("Smart 2-Player Queue")
CreateToggle("Auto Queue Station Pads", false, function(v) State.AutoQueue = v end)
CreateToggle("Prioritize 1/2 Match Pads", true, function(v) State.PrioritizeInstantMatches = v end)

AddSection("Combat & Ramming Engine")
CreateToggle("Combat Ram (Arena Ring Out)", false, function(v) State.CombatRamActive = v end)
CreateSlider("Ramming Speed", 60, 160, State.RamSpeed, function(v) State.RamSpeed = v end)

AddSection("RNG & Reroll Sniper")
CreateToggle("Auto Reroll Sniper", false, function(v) State.AutoReroll = v end)
CreateSelector("Target Rarity", RarityList, "Legendary", function(v) State.TargetRarity = v end)

AddSection("Farm & Drops")
CreateToggle("Auto Collect Arena Coins", false, function(v) State.AutoCollectCoins = v end)
CreateToggle("Opponent Highlight ESP", false, function(v) State.OpponentESP = v end)

AddSection("Movement & Utilities")
CreateSlider("WalkSpeed Boost", 16, 120, State.WalkSpeedBoost, function(v) State.WalkSpeedBoost = v end)
CreateToggle("Infinite Jump", false, function(v) State.InfJump = v end)
CreateToggle("Anti-AFK Idle Protection", true, function(v) State.AntiAFK = v end)

pcall(function()
    StarterGui:SetCore("SendNotification", {
        Title = "[SAKI SCRIPTS]",
        Text = "Ball VS Ball Master Hub Loaded!",
        Duration = 3.5
    })
end)
print("[SAKI SCRIPTS] Ball VS Ball Master Hub Loaded Successfully!")
