--========================================================--
--                 SAKI SCRIPTS UI (MASTER EDITION)
--        BLOX STRIKE • ULTIMATE COMBAT & SKIN SUITE
--========================================================--

local GAME_NAME = "BLOX STRIKE"
local CREDIT    = "SAKI SCRIPTS"

local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService  = game:GetService("UserInputService")
local RunService        = game:GetService("RunService")
local TweenService      = game:GetService("TweenService")
local CAS               = game:GetService("ContextActionService")
local Workspace         = game:GetService("Workspace")
local Lighting          = game:GetService("Lighting")
local CoreGui           = game:GetService("CoreGui")
local StarterGui        = game:GetService("StarterGui")

local LocalPlayer = Players.LocalPlayer
while not LocalPlayer do
    task.wait(0.05)
    LocalPlayer = Players.LocalPlayer
end

local camera = Workspace.CurrentCamera
local CharactersFolder = Workspace:WaitForChild("Characters", 10)

-- Safe Parent Selection
local function getGuiParent()
    local success, result = pcall(function() return (gethui and gethui()) or CoreGui end)
    if success and result then return result end
    return LocalPlayer:WaitForChild("PlayerGui")
end

-- Clean previous instances
pcall(function()
    for _, name in ipairs({"SakiScriptsBloxStrikeUI", "AjizBloxStrikeHub", "SakiScriptsMasterUI"}) do
        local parent = getGuiParent()
        if parent and parent:FindFirstChild(name) then parent[name]:Destroy() end
        if CoreGui:FindFirstChild(name) then CoreGui[name]:Destroy() end
        if LocalPlayer:FindFirstChild("PlayerGui") and LocalPlayer.PlayerGui:FindFirstChild(name) then
            LocalPlayer.PlayerGui[name]:Destroy()
        end
    end
end)

--========================================================================
-- 🎯 TEAM & PLAYER LOGIC
--========================================================================
local function getTFolder() return CharactersFolder and CharactersFolder:FindFirstChild("Terrorists") end
local function getCTFolder() return CharactersFolder and CharactersFolder:FindFirstChild("Counter-Terrorists") end

local function isAlive()
    local t, ct = getTFolder(), getCTFolder()
    return (t and t:FindFirstChild(LocalPlayer.Name)) or (ct and ct:FindFirstChild(LocalPlayer.Name))
end

local function getEnemyFolder()
    if not isAlive() then return nil end
    local t, ct = getTFolder(), getCTFolder()
    if t and t:FindFirstChild(LocalPlayer.Name) then return ct end
    if ct and ct:FindFirstChild(LocalPlayer.Name) then return t end
    return nil
end

--========================================================================
-- ⚡ STATE MANAGEMENT
--========================================================================
local State = {
    -- Combat
    AimbotEnabled    = false,
    ShowFOV          = false,
    FOV_Radius       = 100,
    Smoothing        = 3,
    AimKey           = Enum.UserInputType.MouseButton2,
    isAiming         = false,
    
    TriggerBot       = false,
    TriggerBotDelay  = 0,
    
    HitboxEnabled    = false,
    HitboxSize       = 3,
    
    NoRecoil         = false,
    NoSpread         = false,
    Bhop             = false,

    -- Skins
    CustomKnife      = false,
    SelectedKnife    = "Butterfly Knife",
    SkinChanger      = false,

    -- Visuals
    EspEnabled       = false,
    EspBox           = true,
    EspHealth        = true,
    EspName          = true,
    EspDistance      = true,
    EspSkeleton      = false,
    EspTracers       = false,
    EspHeadDot       = false,
    ChamsEnabled     = false,
    WeaponChams      = false,
    RainbowESP       = false,

    -- World
    AntiFlash        = false,
    AntiSmoke        = false,
}

--========================================================================
-- 🔫 NO RECOIL & NO SPREAD (INTERNAL CONTROLLER HOOKS)
--========================================================================
pcall(function()
    local CameraController = require(ReplicatedStorage.Controllers.CameraController)
    if CameraController then
        local rawKick = CameraController.weaponKick
        local rawRecoil = CameraController.setWeaponRecoil
        
        CameraController.weaponKick = function(...)
            if State.NoRecoil then return end
            if rawKick then return rawKick(...) end
        end
        CameraController.setWeaponRecoil = function(...)
            if State.NoRecoil then return end
            if rawRecoil then return rawRecoil(...) end
        end
    end
end)

pcall(function()
    local InventoryController = require(ReplicatedStorage.Controllers.InventoryController)
    if InventoryController and InventoryController.ShootWeapon then
        local OriginalShoot = InventoryController.ShootWeapon
        InventoryController.ShootWeapon = function(Self, Data)
            if State.NoSpread and Data and Data.Bullets then
                local LookVector = camera.CFrame.LookVector
                for _, Bullet in ipairs(Data.Bullets) do 
                    Bullet.Direction = LookVector 
                end
            end
            return OriginalShoot(Self, Data)
        end
    end
end)

--========================================================================
-- 🎯 AIMBOT & FOV SYSTEM
--========================================================================
local FOVCircle = nil
pcall(function()
    if Drawing and Drawing.new then
        FOVCircle = Drawing.new("Circle")
        FOVCircle.Position = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
        FOVCircle.Radius = State.FOV_Radius
        FOVCircle.Filled = false
        FOVCircle.Color = Color3.fromRGB(255, 25, 35)
        FOVCircle.Visible = false
        FOVCircle.Thickness = 1.2
    end
end)

local function getClosestEnemyToMouse()
    local closestEnemy = nil
    local shortestDistance = State.FOV_Radius
    local enemyFolder = getEnemyFolder()
    if not enemyFolder or not State.AimbotEnabled then return nil end
    
    local mousePos = UserInputService:GetMouseLocation()
    for _, enemy in ipairs(enemyFolder:GetChildren()) do
        local hum = enemy:FindFirstChildOfClass("Humanoid")
        local head = enemy:FindFirstChild("Head")
        if hum and hum.Health > 0 and head then
            local headPos, onScreen = camera:WorldToViewportPoint(head.Position)
            if onScreen then
                local distance = (Vector2.new(headPos.X, headPos.Y) - mousePos).Magnitude
                if distance < shortestDistance then
                    shortestDistance = distance
                    closestEnemy = head
                end
            end
        end
    end
    return closestEnemy
end

UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == State.AimKey or input.UserInputType == Enum.UserInputType.Touch then 
        State.isAiming = true 
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == State.AimKey or input.UserInputType == Enum.UserInputType.Touch then 
        State.isAiming = false 
    end
end)

RunService.RenderStepped:Connect(function()
    if FOVCircle then
        if State.ShowFOV then
            FOVCircle.Position = UserInputService:GetMouseLocation()
            FOVCircle.Radius = State.FOV_Radius
            FOVCircle.Visible = true
        else
            FOVCircle.Visible = false
        end
    end

    if State.isAiming and isAlive() and State.AimbotEnabled then
        local targetHead = getClosestEnemyToMouse()
        if targetHead then
            local headPos = camera:WorldToViewportPoint(targetHead.Position)
            local mousePos = UserInputService:GetMouseLocation()
            local moveX = (headPos.X - mousePos.X) / math.max(State.Smoothing, 1)
            local moveY = (headPos.Y - mousePos.Y) / math.max(State.Smoothing, 1)
            if mousemoverel then 
                mousemoverel(moveX, moveY) 
            else
                camera.CFrame = CFrame.lookAt(camera.CFrame.Position, targetHead.Position)
            end
        end
    end
end)

--========================================================================
-- ⚡ TRIGGERBOT & HITBOX & BHOP
--========================================================================
task.spawn(function()
    while true do
        if State.TriggerBot and isAlive() then
            local viewportSize = camera.ViewportSize
            local ray = camera:ViewportPointToRay(viewportSize.X / 2, viewportSize.Y / 2)
            local raycastParams = RaycastParams.new()
            raycastParams.FilterType = Enum.RaycastFilterType.Exclude
            
            local ignoreList = { camera }
            if LocalPlayer.Character then table.insert(ignoreList, LocalPlayer.Character) end
            raycastParams.FilterDescendantsInstances = ignoreList
            
            local result = Workspace:Raycast(ray.Origin, ray.Direction * 1000, raycastParams)
            if result and result.Instance then
                local hitPart = result.Instance
                local model = hitPart:FindFirstAncestorOfClass("Model")
                if model and model:FindFirstChildOfClass("Humanoid") then
                    local enemyFolder = getEnemyFolder()
                    if enemyFolder and model.Parent == enemyFolder then
                        local hum = model:FindFirstChildOfClass("Humanoid")
                        if hum and hum.Health > 0 then
                            if State.TriggerBotDelay > 0 then task.wait(State.TriggerBotDelay / 1000) end
                            if mouse1click then mouse1click() end
                            task.wait(0.05)
                        end
                    end
                end
            end
        end
        task.wait(0.01)
    end
end)

local originalHeadSizes = {}
task.spawn(function()
    while true do
        local enemyFolder = getEnemyFolder()
        if enemyFolder then
            for _, enemy in ipairs(enemyFolder:GetChildren()) do
                local head = enemy:FindFirstChild("Head")
                local hum = enemy:FindFirstChildOfClass("Humanoid")
                if head and hum and hum.Health > 0 then
                    if not originalHeadSizes[head] then originalHeadSizes[head] = head.Size end
                    if State.HitboxEnabled then
                        head.Size = Vector3.new(State.HitboxSize, State.HitboxSize, State.HitboxSize)
                        head.CanCollide = false
                        head.Transparency = 0.5
                    else
                        if originalHeadSizes[head] and head.Size ~= originalHeadSizes[head] then
                            head.Size = originalHeadSizes[head]
                            head.Transparency = 0
                        end
                    end
                end
            end
        end
        task.wait(0.5)
    end
end)

RunService.RenderStepped:Connect(function()
    if State.Bhop and UserInputService:IsKeyDown(Enum.KeyCode.Space) and isAlive() then
        if LocalPlayer.Character then
            local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum and hum:GetState() ~= Enum.HumanoidStateType.Jumping and hum:GetState() ~= Enum.HumanoidStateType.Freefall then
                hum.Jump = true
            end
        end
    end
end)

--========================================================================
-- 🗡️ CUSTOM KNIFE & WEAPON SKIN CHANGER
--========================================================================
local knifeSpawned = false
local knifeInspecting = false
local knifeSwinging = false
local lastAttackTime = 0
local ATTACK_COOLDOWN = 1
local ACTION_INSPECT = "SakiInspectKnifeAction"
local ACTION_ATTACK  = "SakiAttackKnifeAction"

pcall(function() ReplicatedStorage.Assets.Weapons.Karambit.Camera.ViewmodelLight.Transparency = 1 end)

local knivesConfig = {
    ["Karambit"]        = { Offset = CFrame.new(0, -1.5, 1.5) },
    ["Butterfly Knife"] = { Offset = CFrame.new(0, -1.5, 1.5) },
    ["M9 Bayonet"]      = { Offset = CFrame.new(0, -1.5, 1) },
    ["Flip Knife"]      = { Offset = CFrame.new(0, -1.5, 1.25) },
    ["Gut Knife"]       = { Offset = CFrame.new(0, -1.5, 0.5) },
}

local vm, animator
local equipAnim, idleAnim, inspectAnim, HeavySwingAnim, Swing1Anim, Swing2Anim

local function getKnifeInCamera()
    return camera:FindFirstChild("T Knife") or camera:FindFirstChild("CT Knife")
end

local function cleanPart(part)
    if not part:IsA("BasePart") then return end
    part.CanCollide, part.Anchored, part.CastShadow, part.CanTouch, part.CanQuery = false, false, false, false, false
end

local function disableCollisions(model)
    for _, part in model:GetDescendants() do cleanPart(part) end
end

local function hideOriginalKnife(knife)
    for _, part in knife:GetDescendants() do
        if part:IsA("BasePart") or part:IsA("MeshPart") or part:IsA("Texture") then part.Transparency = 1 end
    end
end

local function playKnifeSound(folder, name)
    local weaponSounds = ReplicatedStorage.Sounds:FindFirstChild(State.SelectedKnife)
    if not weaponSounds then return end
    local sound = weaponSounds:WaitForChild(folder):WaitForChild(name):Clone()
    sound.Parent = camera
    sound:Play()
    sound.Ended:Once(function() sound:Destroy() end)
    return sound
end

local function attachAsset(folder, armPartName, assetModelName, finalName, offset)
    local targetArm = vm:FindFirstChild(armPartName)
    if not targetArm then return end
    local assetMesh = folder:WaitForChild(assetModelName):Clone()
    cleanPart(assetMesh)
    assetMesh.Name = finalName
    assetMesh.Parent = targetArm
    local motor = Instance.new("Motor6D")
    motor.Part0, motor.Part1, motor.C0, motor.Parent = targetArm, assetMesh, offset, targetArm
end

local function handleKnifeAction(actionName, inputState, inputObject)
    if inputState ~= Enum.UserInputState.Begin or not knifeSpawned or not animator or not isAlive() then 
        return Enum.ContextActionResult.Pass 
    end

    if actionName == ACTION_INSPECT then
        if (equipAnim and equipAnim.IsPlaying) or knifeInspecting or knifeSwinging then return Enum.ContextActionResult.Pass end
        knifeInspecting = true
        if idleAnim then idleAnim:Stop() end
        inspectAnim:Play()
        inspectAnim.Stopped:Once(function() knifeInspecting = false end)
    elseif actionName == ACTION_ATTACK then
        local currentTime = os.clock()
        if (equipAnim and equipAnim.IsPlaying) or (currentTime - lastAttackTime < ATTACK_COOLDOWN) then return Enum.ContextActionResult.Pass end
        lastAttackTime = currentTime
        if knifeInspecting then knifeInspecting = false; if inspectAnim then inspectAnim:Stop() end end
        knifeSwinging = true
        if idleAnim then idleAnim:Stop() end
        local anims = { HeavySwingAnim, Swing1Anim, Swing2Anim }
        local chosenAnim = anims[math.random(1, #anims)]
        local soundFolder = (chosenAnim == HeavySwingAnim and "HitOne") or (chosenAnim == Swing1Anim and "HitTwo") or "HitThree"
        chosenAnim:Play()
        local s = playKnifeSound(soundFolder, "1")
        if s then s.Volume = 5 end
        chosenAnim.Stopped:Once(function() knifeSwinging = false end)
    end
    return Enum.ContextActionResult.Pass
end

local function removeKnifeViewmodel()
    knifeSpawned = false
    CAS:UnbindAction(ACTION_INSPECT)
    CAS:UnbindAction(ACTION_ATTACK)
    if vm then vm:Destroy(); vm = nil end
    animator, knifeInspecting, knifeSwinging = nil, false, false
end

local function spawnKnifeViewmodel(knife)
    if knifeSpawned or not State.CustomKnife then return end
    local myModel = isAlive()
    if not myModel then return end
    knifeSpawned = true

    local knifeTemplate = ReplicatedStorage.Assets.Weapons:WaitForChild(State.SelectedKnife)
    local knifeOffset = knivesConfig[State.SelectedKnife].Offset
    vm = knifeTemplate:WaitForChild("Camera"):Clone()
    vm.Name, vm.Parent = State.SelectedKnife, camera

    disableCollisions(vm)
    hideOriginalKnife(knife)

    if myModel.Parent.Name == "Terrorists" then
        local tGloves = ReplicatedStorage.Assets.Weapons:WaitForChild("T Glove")
        attachAsset(tGloves, "Left Arm", "Left Arm", "Glove", CFrame.new(0, 0, -1.5))
        attachAsset(tGloves, "Right Arm", "Right Arm", "Glove", CFrame.new(0, 0, -1.5))
    else
        local sleeves = ReplicatedStorage.Assets.Sleeves:WaitForChild("IDF")
        local ctGloves = ReplicatedStorage.Assets.Weapons:WaitForChild("CT Glove")
        attachAsset(sleeves, "Left Arm", "Left Arm", "Sleeve", CFrame.new(0, 0, 0.5))
        attachAsset(ctGloves, "Left Arm", "Left Arm", "Glove", CFrame.new(0, 0, -1.5))
        attachAsset(sleeves, "Right Arm", "Right Arm", "Sleeve", CFrame.new(0, 0, 0.5))
        attachAsset(ctGloves, "Right Arm", "Right Arm", "Glove", CFrame.new(0, 0, -1.5))
    end

    local animController = vm:FindFirstChildOfClass("AnimationController") or vm:FindFirstChildOfClass("Animator")
    animator = animController:FindFirstChildWhichIsA("Animator") or animController
    local animFolder = ReplicatedStorage.Assets.WeaponAnimations:WaitForChild(State.SelectedKnife):WaitForChild("CameraAnimations")

    equipAnim = animator:LoadAnimation(animFolder:WaitForChild("Equip"))
    idleAnim = animator:LoadAnimation(animFolder:WaitForChild("Idle"))
    inspectAnim = animator:LoadAnimation(animFolder:WaitForChild("Inspect"))
    HeavySwingAnim = animator:LoadAnimation(animFolder:WaitForChild("Heavy Swing"))
    Swing1Anim = animator:LoadAnimation(animFolder:WaitForChild("Swing1"))
    Swing2Anim = animator:LoadAnimation(animFolder:WaitForChild("Swing2"))

    vm:SetPrimaryPartCFrame(camera.CFrame * CFrame.new(0, -1.5, 5))
    TweenService:Create(vm.PrimaryPart, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        CFrame = camera.CFrame * knifeOffset
    }):Play()

    equipAnim:Play()
    playKnifeSound("Equip", "1")

    CAS:BindAction(ACTION_INSPECT, handleKnifeAction, false, Enum.KeyCode.F)
    CAS:BindAction(ACTION_ATTACK, handleKnifeAction, false, Enum.UserInputType.MouseButton1)
end

RunService.RenderStepped:Connect(function()
    if not State.CustomKnife or not vm or not vm.PrimaryPart then return end
    vm.PrimaryPart.CFrame = camera.CFrame * knivesConfig[State.SelectedKnife].Offset
    if not (equipAnim and equipAnim.IsPlaying) and not knifeInspecting and not knifeSwinging then
        if idleAnim and not idleAnim.IsPlaying then idleAnim:Play() end
    end
end)

task.spawn(function()
    while true do
        local living = isAlive()
        local currentKnife = getKnifeInCamera()
        if State.CustomKnife and living and currentKnife and not knifeSpawned then
            spawnKnifeViewmodel(currentKnife)
        elseif (not State.CustomKnife or not currentKnife or not living) and knifeSpawned then
            removeKnifeViewmodel()
        end
        task.wait(0.1)
    end
end)

-- Gun & Glove Skin Changer
local SelectedSkins = {}
local SkinOptions = {}
local WEAR = "Factory New"
local SkinsFolder = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Skins")

local function applyWeaponSkin(model)
    if not model or not State.SkinChanger or not isAlive() then return end
    local skinName = SelectedSkins[model.Name]
    if not skinName then return end

    pcall(function()
        local skinFolder = SkinsFolder:FindFirstChild(model.Name)
        if not skinFolder then return end
        local skinType = skinFolder:FindFirstChild(skinName)
        local sourceFolder = skinType and skinType:FindFirstChild("Camera") and skinType.Camera:FindFirstChild(WEAR)
        if not sourceFolder then return end

        for _, obj in camera:GetChildren() do
            local left, right = obj:FindFirstChild("Left Arm"), obj:FindFirstChild("Right Arm")
            if left or right then
                local gloveFolder = SkinsFolder:FindFirstChild("Sports Gloves")
                local gloveSkin = gloveFolder and gloveFolder:FindFirstChild(SelectedSkins["Sports Gloves"])
                local gloveSource = gloveSkin and gloveSkin:FindFirstChild("Camera") and gloveSkin.Camera:FindFirstChild(WEAR)
                if gloveSource then
                    for _, side in { "Left Arm", "Right Arm" } do
                        local arm, src = obj:FindFirstChild(side), gloveSource:FindFirstChild(side)
                        if arm and src then
                            local gloveMesh = arm:FindFirstChild("Glove")
                            if gloveMesh then
                                local existing = gloveMesh:FindFirstChildOfClass("SurfaceAppearance")
                                if existing then existing:Destroy() end
                                local clone = src:Clone()
                                clone.Name, clone.Parent = "SurfaceAppearance", gloveMesh
                            end
                        end
                    end
                end
            end
        end

        local weaponFolder = model:FindFirstChild("Weapon")
        if weaponFolder then
            for _, part in weaponFolder:GetDescendants() do
                if part:IsA("BasePart") then
                    local newSkin = sourceFolder:FindFirstChild(part.Name)
                    if newSkin then
                        local existing = part:FindFirstChildOfClass("SurfaceAppearance")
                        if existing then existing:Destroy() end
                        local clone = newSkin:Clone()
                        clone.Name, clone.Parent = "SurfaceAppearance", part
                    end
                end
            end
        end
        model:SetAttribute("SkinApplied", skinName)
    end)
end

-- Initialize Skin Options
pcall(function()
    for _, folder in ipairs(SkinsFolder:GetChildren()) do
        local options = {}
        for _, skin in ipairs(folder:GetChildren()) do table.insert(options, skin.Name) end
        if #options > 0 then
            SkinOptions[folder.Name] = options
            SelectedSkins[folder.Name] = options[1]
        end
    end
end)

camera.ChildAdded:Connect(function(obj)
    if not State.SkinChanger or not isAlive() then return end
    task.wait(0.1)
    applyWeaponSkin(obj)
end)

task.spawn(function()
    while true do
        if State.SkinChanger and isAlive() then
            for _, obj in ipairs(camera:GetChildren()) do
                if SelectedSkins[obj.Name] and obj:GetAttribute("SkinApplied") ~= SelectedSkins[obj.Name] then
                    applyWeaponSkin(obj)
                end
            end
        end
        task.wait(0.5)
    end
end)

--========================================================================
-- 👁️ DRAWING ESP & CHAMS SUITE
--========================================================================
local espCache = {}

local function createESP()
    local esp = {
        boxOutline = Drawing.new("Square"),
        box        = Drawing.new("Square"),
        name       = Drawing.new("Text"),
        distance   = Drawing.new("Text"),
        healthOut  = Drawing.new("Line"),
        healthBar  = Drawing.new("Line"),
        headDot    = Drawing.new("Circle"),
        tracer     = Drawing.new("Line"),
        skeleton   = {
            headNeck  = Drawing.new("Line"),
            neckTorso = Drawing.new("Line"),
            leftArm   = Drawing.new("Line"),
            rightArm  = Drawing.new("Line"),
            leftLeg   = Drawing.new("Line"),
            rightLeg  = Drawing.new("Line"),
        }
    }
    esp.boxOutline.Thickness = 3; esp.boxOutline.Filled = false; esp.boxOutline.Color = Color3.new(0, 0, 0)
    esp.box.Thickness = 1.5; esp.box.Filled = false; esp.box.Color = Color3.fromRGB(255, 25, 35)
    esp.name.Center = true; esp.name.Outline = true; esp.name.Color = Color3.new(1, 1, 1); esp.name.Size = 14
    esp.distance.Center = true; esp.distance.Outline = true; esp.distance.Color = Color3.fromRGB(200, 200, 200); esp.distance.Size = 12
    esp.healthOut.Thickness = 3; esp.healthOut.Color = Color3.new(0, 0, 0)
    esp.healthBar.Thickness = 1.5
    esp.headDot.Radius = 3; esp.headDot.Filled = true; esp.headDot.Color = Color3.fromRGB(255, 255, 255)
    esp.tracer.Thickness = 1.2; esp.tracer.Color = Color3.fromRGB(255, 25, 35)
    for _, l in pairs(esp.skeleton) do l.Thickness = 1.2; l.Color = Color3.fromRGB(255, 255, 255) end
    return esp
end

local function getRainbowColor()
    return Color3.fromHSV((tick() * 1.5) % 1, 1, 1)
end

RunService.RenderStepped:Connect(function()
    if not State.EspEnabled or not isAlive() then
        for _, e in pairs(espCache) do
            for k, d in pairs(e) do
                if type(d) == "table" then
                    for _, line in pairs(d) do line.Visible = false end
                else
                    d.Visible = false
                end
            end
        end
        return
    end

    local enemyFolder = getEnemyFolder()
    if not enemyFolder then return end

    local currentAlive = {}
    local activeColor = State.RainbowESP and getRainbowColor() or Color3.fromRGB(255, 25, 35)
    local screenBottom = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y)

    for _, enemy in ipairs(enemyFolder:GetChildren()) do
        local hum  = enemy:FindFirstChildOfClass("Humanoid")
        local root = enemy:FindFirstChild("HumanoidRootPart")
        local head = enemy:FindFirstChild("Head")

        if hum and hum.Health > 0 and root and head then
            currentAlive[enemy] = true
            if not espCache[enemy] then
                pcall(function() espCache[enemy] = createESP() end)
            end
            local esp = espCache[enemy]

            if esp then
                local rootPos, onScreen = camera:WorldToViewportPoint(root.Position)
                local headPos = camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
                local legPos  = camera:WorldToViewportPoint(root.Position - Vector3.new(0, 3, 0))

                if onScreen then
                    local boxH = math.abs(headPos.Y - legPos.Y)
                    local boxW = boxH / 2
                    local dist = math.floor((camera.CFrame.Position - root.Position).Magnitude)

                    -- Box
                    if State.EspBox then
                        esp.boxOutline.Size = Vector2.new(boxW, boxH)
                        esp.boxOutline.Position = Vector2.new(rootPos.X - boxW / 2, headPos.Y)
                        esp.boxOutline.Visible = true

                        esp.box.Size = Vector2.new(boxW, boxH)
                        esp.box.Position = Vector2.new(rootPos.X - boxW / 2, headPos.Y)
                        esp.box.Color = activeColor
                        esp.box.Visible = true
                    else
                        esp.boxOutline.Visible, esp.box.Visible = false, false
                    end

                    -- Health Bar
                    if State.EspHealth then
                        local hpPct = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
                        local barX = rootPos.X - boxW / 2 - 6
                        esp.healthOut.From = Vector2.new(barX, headPos.Y - 1)
                        esp.healthOut.To   = Vector2.new(barX, headPos.Y + boxH + 1)
                        esp.healthOut.Visible = true

                        esp.healthBar.From = Vector2.new(barX, headPos.Y + boxH)
                        esp.healthBar.To   = Vector2.new(barX, headPos.Y + boxH - (boxH * hpPct))
                        esp.healthBar.Color = Color3.new(1 - hpPct, hpPct, 0)
                        esp.healthBar.Visible = true
                    else
                        esp.healthOut.Visible, esp.healthBar.Visible = false, false
                    end

                    -- Name
                    if State.EspName then
                        esp.name.Text = enemy.Name
                        esp.name.Position = Vector2.new(rootPos.X, headPos.Y - 18)
                        esp.name.Visible = true
                    else
                        esp.name.Visible = false
                    end

                    -- Distance
                    if State.EspDistance then
                        esp.distance.Text = "[" .. dist .. "m]"
                        esp.distance.Position = Vector2.new(rootPos.X, headPos.Y + boxH + 2)
                        esp.distance.Visible = true
                    else
                        esp.distance.Visible = false
                    end

                    -- Head Dot
                    if State.EspHeadDot then
                        esp.headDot.Position = Vector2.new(headPos.X, headPos.Y + 6)
                        esp.headDot.Visible = true
                    else
                        esp.headDot.Visible = false
                    end

                    -- Tracer
                    if State.EspTracers then
                        esp.tracer.From = screenBottom
                        esp.tracer.To = Vector2.new(rootPos.X, headPos.Y + boxH)
                        esp.tracer.Color = activeColor
                        esp.tracer.Visible = true
                    else
                        esp.tracer.Visible = false
                    end

                    -- Skeleton
                    if State.EspSkeleton then
                        local lArm = enemy:FindFirstChild("Left Arm") or enemy:FindFirstChild("LeftUpperArm")
                        local rArm = enemy:FindFirstChild("Right Arm") or enemy:FindFirstChild("RightUpperArm")
                        local lLeg = enemy:FindFirstChild("Left Leg") or enemy:FindFirstChild("LeftUpperLeg")
                        local rLeg = enemy:FindFirstChild("Right Leg") or enemy:FindFirstChild("RightUpperLeg")

                        if lArm and rArm and lLeg and rLeg then
                            local lArmPos = camera:WorldToViewportPoint(lArm.Position)
                            local rArmPos = camera:WorldToViewportPoint(rArm.Position)
                            local lLegPos = camera:WorldToViewportPoint(lLeg.Position)
                            local rLegPos = camera:WorldToViewportPoint(rLeg.Position)

                            esp.skeleton.headNeck.From  = Vector2.new(headPos.X, headPos.Y)
                            esp.skeleton.headNeck.To    = Vector2.new(rootPos.X, rootPos.Y - 8)
                            esp.skeleton.headNeck.Visible = true

                            esp.skeleton.leftArm.From   = Vector2.new(rootPos.X, rootPos.Y - 8)
                            esp.skeleton.leftArm.To     = Vector2.new(lArmPos.X, lArmPos.Y)
                            esp.skeleton.leftArm.Visible = true

                            esp.skeleton.rightArm.From  = Vector2.new(rootPos.X, rootPos.Y - 8)
                            esp.skeleton.rightArm.To    = Vector2.new(rArmPos.X, rArmPos.Y)
                            esp.skeleton.rightArm.Visible = true

                            esp.skeleton.leftLeg.From   = Vector2.new(rootPos.X, rootPos.Y + 8)
                            esp.skeleton.leftLeg.To     = Vector2.new(lLegPos.X, lLegPos.Y)
                            esp.skeleton.leftLeg.Visible = true

                            esp.skeleton.rightLeg.From  = Vector2.new(rootPos.X, rootPos.Y + 8)
                            esp.skeleton.rightLeg.To    = Vector2.new(rLegPos.X, rLegPos.Y)
                            esp.skeleton.rightLeg.Visible = true
                        end
                    else
                        for _, line in pairs(esp.skeleton) do line.Visible = false end
                    end

                else
                    for k, d in pairs(esp) do
                        if type(d) == "table" then
                            for _, l in pairs(d) do l.Visible = false end
                        else
                            d.Visible = false
                        end
                    end
                end
            end
        end
    end

    for cEnemy, e in pairs(espCache) do
        if not currentAlive[cEnemy] then
            for _, d in pairs(e) do
                if type(d) == "table" then for _, l in pairs(d) do l:Remove() end else d:Remove() end
            end
            espCache[cEnemy] = nil
        end
    end
end)

-- Chams (Player & Weapon)
task.spawn(function()
    while true do
        local enemyFolder = getEnemyFolder()
        if enemyFolder and State.ChamsEnabled and isAlive() then
            for _, enemy in ipairs(enemyFolder:GetChildren()) do
                local hum = enemy:FindFirstChildOfClass("Humanoid")
                if hum and hum.Health > 0 then
                    local hl = enemy:FindFirstChild("SakiChams")
                    if not hl then
                        hl = Instance.new("Highlight")
                        hl.Name = "SakiChams"
                        hl.FillColor = Color3.fromRGB(255, 25, 35)
                        hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                        hl.FillTransparency = 0.5
                        hl.OutlineTransparency = 0
                        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                        hl.Parent = enemy
                    end
                end
            end
        else
            if enemyFolder then
                for _, enemy in ipairs(enemyFolder:GetChildren()) do
                    local hl = enemy:FindFirstChild("SakiChams")
                    if hl then hl:Destroy() end
                end
            end
        end

        -- Weapon Chams
        if State.WeaponChams and isAlive() then
            for _, obj in ipairs(camera:GetChildren()) do
                if obj:IsA("Model") and not obj:FindFirstChild("SakiWeaponChams") then
                    local hl = Instance.new("Highlight")
                    hl.Name = "SakiWeaponChams"
                    hl.FillColor = Color3.fromRGB(255, 50, 60)
                    hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                    hl.FillTransparency = 0.4
                    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    hl.Parent = obj
                end
            end
        else
            for _, obj in ipairs(camera:GetChildren()) do
                local hl = obj:FindFirstChild("SakiWeaponChams")
                if hl then hl:Destroy() end
            end
        end

        task.wait(0.5)
    end
end)

-- Anti-Flash & Anti-Smoke
task.spawn(function()
    while true do
        if State.AntiFlash then
            local gui = LocalPlayer.PlayerGui:FindFirstChild("FlashbangEffect")
            local fx = Lighting:FindFirstChild("FlashbangColorCorrection")
            if gui then gui:Destroy() end
            if fx then fx:Destroy() end
        end
        task.wait(0.2)
    end
end)

task.spawn(function()
    while true do
        if State.AntiSmoke then
            local debris = Workspace:FindFirstChild("Debris")
            if debris then
                for _, folder in ipairs(debris:GetChildren()) do
                    if string.match(folder.Name, "Voxel") then
                        folder:ClearAllChildren()
                        folder:Destroy()
                    end
                end
            end
        end
        task.wait(0.5)
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
ScreenGui.Name = "SakiScriptsBloxStrikeUI"
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
FloatingBtn.Text = "🔫"
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

local function CreateButton(name, callback)
    itemOrder = itemOrder + 1
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
    Label.Size = UDim2.new(1, -16, 1, 0)
    Label.Text = name
    Label.TextColor3 = RED
    Label.TextSize = 12
    Label.Font = Enum.Font.Bangers
    Label.TextXAlignment = Enum.TextXAlignment.Center

    local Btn = Instance.new("TextButton", Feature)
    Btn.Size = UDim2.new(1, 0, 1, 0)
    Btn.BackgroundTransparency = 1
    Btn.Text = ""

    Btn.MouseButton1Click:Connect(function()
        TweenService:Create(Feature, TweenInfo.new(0.08), { BackgroundColor3 = RED }):Play()
        Label.TextColor3 = WHITE
        task.wait(0.08)
        TweenService:Create(Feature, TweenInfo.new(0.15), { BackgroundColor3 = DARK2 }):Play()
        Label.TextColor3 = RED
        if callback then task.spawn(callback) end
    end)
end

--========================================================--
-- 📋 POPULATE SAKI BLOX STRIKE FEATURES
--========================================================--

AddSection("Combat & Accuracy")
CreateToggle("Hold Right Click Aimbot", false, function(on) State.AimbotEnabled = on end)
CreateToggle("Show FOV Circle", false, function(on) State.ShowFOV = on end)
CreateSlider("FOV Radius", 10, 500, State.FOV_Radius, function(v) State.FOV_Radius = v end)
CreateSlider("Aimbot Smoothing", 1, 10, State.Smoothing, function(v) State.Smoothing = v end)

CreateToggle("Auto TriggerBot", false, function(on) State.TriggerBot = on end)
CreateSlider("TriggerBot Delay (ms)", 0, 500, State.TriggerBotDelay, function(v) State.TriggerBotDelay = v end)

CreateToggle("Hitbox Expander", false, function(on) State.HitboxEnabled = on end)
CreateSlider("Hitbox Head Size", 1, 5, State.HitboxSize, function(v) State.HitboxSize = v end)

CreateToggle("100% No Recoil", true, function(on) State.NoRecoil = on end)
CreateToggle("100% No Spread (Laser)", true, function(on) State.NoSpread = on end)
CreateToggle("Auto Bunny Hop (Space)", false, function(on) State.Bhop = on end)

AddSection("Skins & Viewmodels")
CreateToggle("Enable Custom Knife", false, function(on)
    State.CustomKnife = on
    if not on then removeKnifeViewmodel() end
end)
CreateSelector("Select Knife", { "Butterfly Knife", "Karambit", "M9 Bayonet", "Flip Knife", "Gut Knife" }, "Butterfly Knife", function(opt)
    State.SelectedKnife = opt
    if knifeSpawned then removeKnifeViewmodel() end
end)
CreateToggle("Enable Weapon & Glove Skins", false, function(on)
    State.SkinChanger = on
    if not on then
        for _, obj in ipairs(camera:GetChildren()) do obj:SetAttribute("SkinApplied", nil) end
    end
end)
CreateButton("🎲 Randomize All Gun Skins", function()
    for weaponName, optionsList in pairs(SkinOptions) do
        if #optionsList > 0 then
            SelectedSkins[weaponName] = optionsList[math.random(1, #optionsList)]
        end
    end
    for _, obj in ipairs(camera:GetChildren()) do
        obj:SetAttribute("SkinApplied", nil)
        applyWeaponSkin(obj)
    end
end)

AddSection("Visuals (ESP Suite)")
CreateToggle("Master Player ESP", false, function(on) State.EspEnabled = on end)
CreateToggle("Box ESP", true, function(on) State.EspBox = on end)
CreateToggle("Health Bar", true, function(on) State.EspHealth = on end)
CreateToggle("Player Names", true, function(on) State.EspName = on end)
CreateToggle("Distance ESP", true, function(on) State.EspDistance = on end)
CreateToggle("Skeleton ESP", false, function(on) State.EspSkeleton = on end)
CreateToggle("Tracers", false, function(on) State.EspTracers = on end)
CreateToggle("Head Dot", false, function(on) State.EspHeadDot = on end)
CreateToggle("Player Chams / Highlight", false, function(on) State.ChamsEnabled = on end)
CreateToggle("Weapon Chams", false, function(on) State.WeaponChams = on end)
CreateToggle("Rainbow Colors Mode", false, function(on) State.RainbowESP = on end)

AddSection("World & Removals")
CreateToggle("Anti-Flashbang Effect", false, function(on) State.AntiFlash = on end)
CreateToggle("Anti-Smoke Voxel", false, function(on) State.AntiSmoke = on end)

pcall(function()
    StarterGui:SetCore("SendNotification", {
        Title = "[SAKI SCRIPTS]",
        Text = "Blox Strike Master Suite Loaded!",
        Duration = 3.5
    })
end)
print("[SAKI SCRIPTS] Blox Strike Master Suite Loaded Successfully!")
