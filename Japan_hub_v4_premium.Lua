local service = setmetatable({}, {__index=function(self,k) local s=game:GetService(k) rawset(self,k,s) return s end})
local Players = service.Players
local RunService = service.RunService
local ReplicatedStorage = service.ReplicatedStorage
local Workspace = service.Workspace
local LocalPlayer = Players.LocalPlayer
local TweenService = service.TweenService
local CharacterEvents = ReplicatedStorage:WaitForChild("CharacterEvents", 15)
local GrabEvents = ReplicatedStorage:WaitForChild("GrabEvents", 15)
local PlayerEvents = ReplicatedStorage:WaitForChild("PlayerEvents", 15)
local MenuToys = ReplicatedStorage:WaitForChild("MenuToys", 15)
assert(CharacterEvents and GrabEvents and MenuToys, "Japan HUB: game remotes not found (wrong game?)")
local Struggle = CharacterEvents:WaitForChild("Struggle", 10)
local RagdollRemote = CharacterEvents:WaitForChild("RagdollRemote", 10)
local SetNetworkOwner = GrabEvents:WaitForChild("SetNetworkOwner", 10)
local CreateGrabLine = GrabEvents:WaitForChild("CreateGrabLine", 10)
local DestroyGrabLine = GrabEvents:WaitForChild("DestroyGrabLine", 10)
local StickyPartEvent = PlayerEvents and PlayerEvents:WaitForChild("StickyPartEvent", 10)
local SpawnToyRemoteFunction = MenuToys:WaitForChild("SpawnToyRemoteFunction", 10)
local BuyToyRemoteFunction = MenuToys:FindFirstChild("BuyToyRemoteFunction")
local DestroyToy = MenuToys:FindFirstChild("DestroyToy")
local SpawnedInToys = Workspace:FindFirstChild(LocalPlayer.Name .. "SpawnedInToys") or Workspace:WaitForChild(LocalPlayer.Name .. "SpawnedInToys", 10)

local Config = {PlayerList = {}, aa6 = false, aa9 = 25, aa13 = false, aa17 = false, aa73 = nil, running = false}
local function JapanNotify(Message) end -- redefined later
local function spawntoy(name, cframe, vector3) SpawnToyRemoteFunction:InvokeServer(name, cframe, vector3 or Vector3.zero) return SpawnedInToys and SpawnedInToys[name] end
local function GetCharacter() return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait() end

local TextureConfig = {Enabled = false, Size = 45, MouthFrames = {"rbxassetid://75252859666942", "rbxassetid://110474979527548", "rbxassetid://88413342916949", "rbxassetid://102189053362318", "rbxassetid://72775664942814"}, Connections = {}}
local function ProcessMouth(p2)
    if not p2 or not p2.Parent or p2:FindFirstChild("ProcessedMouth") then return end
    local hole = p2:FindFirstChild("Hole") or p2:FindFirstChildWhichIsA("BasePart")
    if not hole then return end
    local processedMouth = Instance.new("BoolValue") processedMouth.Name = "ProcessedMouth" processedMouth.Parent = p2
    for _, v in ipairs(hole:GetChildren()) do v:Destroy() end
    for _, v in ipairs(p2:GetChildren()) do if v ~= hole and (v:IsA("BasePart") or v:IsA("Attachment") or v:IsA("ParticleEmitter")) then v:Destroy() end end
    hole.Transparency = 1
    local monsterMouthGui = Instance.new("BillboardGui") monsterMouthGui.Name = "MonsterMouthGui" monsterMouthGui.AlwaysOnTop = true monsterMouthGui.Size = UDim2.new(TextureConfig.Size, 0, TextureConfig.Size, 0) monsterMouthGui.Parent = hole
    local mouthAnim = Instance.new("ImageLabel") mouthAnim.Name = "MouthAnim" mouthAnim.Size = UDim2.new(1, 0, 1, 0) mouthAnim.BackgroundTransparency = 1 mouthAnim.Image = TextureConfig.MouthFrames[1] mouthAnim.Parent = monsterMouthGui
    task.spawn(function()
        monsterMouthGui.Size = UDim2.new(0, 0, 0, 0)
        TweenService:Create(monsterMouthGui, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(TextureConfig.Size, 0, TextureConfig.Size, 0)}):Play()
        task.wait(0.3)
        for i = 1, #TextureConfig.MouthFrames do mouthAnim.Image = TextureConfig.MouthFrames[i] task.wait(0.08) end
        local part = Instance.new("Part") part.Shape = Enum.PartType.Ball part.Size = Vector3.new(4, 4, 4) part.CFrame = hole.CFrame part.Color = Color3.fromRGB(220, 10, 10) part.Material = Enum.Material.Neon part.Anchored = true part.CanCollide = false part.Parent = workspace
        local create = TweenService:Create(part, TweenInfo.new(0.25), {Size = Vector3.new(45, 45, 45), Transparency = 1})
        create:Play() create.Completed:Connect(function() part:Destroy() end) task.wait(0.05) p2:Destroy()
    end)
end
local function StartTextureSystem()
    if #TextureConfig.Connections > 0 then return end
    for _, v in ipairs(workspace:GetChildren()) do if v.Name:find("BlackHole") or v.Name:find("BlackHoleKick") then ProcessMouth(v) end end
    table.insert(TextureConfig.Connections, workspace.ChildAdded:Connect(function(child) if TextureConfig.Enabled and (child.Name:find("BlackHole") or child.Name:find("BlackHoleKick")) then task.wait(0.05) ProcessMouth(child) end end))
end
local function StopTextureSystem() for _, conn in ipairs(TextureConfig.Connections) do conn:Disconnect() end table.clear(TextureConfig.Connections) end

local CosmicBlackhole = { Enabled = false, Active = {}, Connection = nil, Options = {["EternityHole"] = {Id = "rbxassetid://99340233207059", Scale = 1.0, Type = "model"}} }
local function WipeOriginal(bh)
    if not bh then return end
    for _, desc in ipairs(bh:GetDescendants()) do
        if desc:IsA("BasePart") or desc:IsA("MeshPart") or desc:IsA("UnionOperation") then desc.Transparency = 1 desc.CastShadow = false
        elseif desc:IsA("ParticleEmitter") or desc:IsA("Trail") or desc:IsA("Beam") or desc:IsA("Smoke") or desc:IsA("Fire") or desc:IsA("Sparkles") then desc.Enabled = false
        elseif desc:IsA("PointLight") or desc:IsA("SpotLight") or desc:IsA("SurfaceLight") then desc.Enabled = false
        elseif desc:IsA("Decal") or desc:IsA("Texture") then desc.Transparency = 1
        elseif desc:IsA("BillboardGui") or desc:IsA("SurfaceGui") then desc.Enabled = false end
    end
    if bh:IsA("BasePart") then bh.Transparency = 1 end
    if bh:IsA("Model") and bh.PrimaryPart then bh.PrimaryPart.Transparency = 1 end
end
local function RestoreOriginal(bh)
    if not bh then return end
    for _, desc in ipairs(bh:GetDescendants()) do
        if desc:IsA("BasePart") or desc:IsA("MeshPart") or desc:IsA("UnionOperation") then desc.Transparency = 0
        elseif desc:IsA("ParticleEmitter") or desc:IsA("Trail") or desc:IsA("Beam") or desc:IsA("Smoke") or desc:IsA("Fire") or desc:IsA("Sparkles") then desc.Enabled = true
        elseif desc:IsA("PointLight") or desc:IsA("SpotLight") or desc:IsA("SurfaceLight") then desc.Enabled = true
        elseif desc:IsA("Decal") or desc:IsA("Texture") then desc.Transparency = 0
        elseif desc:IsA("BillboardGui") or desc:IsA("SurfaceGui") then desc.Enabled = true end
    end
    if bh:IsA("BasePart") then bh.Transparency = 0 end
    if bh:IsA("Model") and bh.PrimaryPart then bh.PrimaryPart.Transparency = 0 end
end
local function CleanupCosmic(bh)
    if not bh then return end
    local data = CosmicBlackhole.Active[bh] if not data then return end
    if data.Anim then pcall(function() data.Anim:Disconnect() end) end
    if data.Model then pcall(function() data.Model:Destroy() end) end
    RestoreOriginal(bh) CosmicBlackhole.Active[bh] = nil
end
local function BuildCosmic(bh)
    if not bh or not bh.Parent or CosmicBlackhole.Active[bh] then return end
    local hole = bh:FindFirstChild("Hole") or bh:FindFirstChildWhichIsA("BasePart") if not hole then return end
    WipeOriginal(bh) local pos = hole.Position local option = CosmicBlackhole.Options["EternityHole"]
    local data = {Time = 0, Hole = hole, Anim = nil, Model = nil, SpinSpeed = 0, TargetSpin = 0.8, Scale = 0, TargetScale = option.Scale, StartTime = tick()}
    local assetId = option.Id local model = nil
    local success, result = pcall(function() return game:GetObjects(assetId)[1] end)
    if success and result then model = result end
    if not model then
        local cleanId = tonumber((assetId:gsub("rbxassetid://", "")))
        success, result = pcall(function() return game:GetService("InsertService"):LoadAsset(cleanId) end)
        if success and result then model = result:GetChildren()[1] end
    end
    if not model then RestoreOriginal(bh) return end
    model.Parent = bh model.Name = "CosmicMesh"
    for _, desc in ipairs(model:GetDescendants()) do if desc:IsA("AnimationController") or desc:IsA("Animator") or desc:IsA("Animation") then desc:Destroy() end end
    for _, part in ipairs(model:GetDescendants()) do
        if part:IsA("BasePart") or part:IsA("MeshPart") then part.Anchored = true part.CanCollide = false part.CastShadow = false part.Size = part.Size * 0.01 end
        if part:IsA("Smoke") or part:IsA("ParticleEmitter") then if part.Name:lower():find("smog") or part.Name:lower():find("fog") or part.Name:lower():find("mist") or part.Name:lower():find("haze") or part.Name:lower():find("cloud") then part:Destroy() end end
    end
    if model.PrimaryPart then local offset = pos - model.PrimaryPart.Position model:SetPrimaryPartCFrame(model.PrimaryPart.CFrame + offset)
    else
        local firstPart = nil for _, part in ipairs(model:GetDescendants()) do if part:IsA("BasePart") then firstPart = part break end end
        if firstPart then local offset = pos - firstPart.Position for _, part in ipairs(model:GetDescendants()) do if part:IsA("BasePart") then part.CFrame = part.CFrame + offset end end end
    end
    data.Model = model
    data.Anim = RunService.Heartbeat:Connect(function(dt)
        if not bh or not bh.Parent then CleanupCosmic(bh) return end
        local currentPos = hole.Position data.Time = data.Time + dt * data.SpinSpeed
        if data.Model then
            if data.Model:IsA("Model") then
                if data.Model.PrimaryPart then local cf = CFrame.new(currentPos) * CFrame.Angles(0, data.Time, 0) data.Model:SetPrimaryPartCFrame(cf) end
                for _, part in ipairs(data.Model:GetDescendants()) do if part:IsA("BasePart") or part:IsA("MeshPart") then if not part:GetAttribute("BaseSize") then part:SetAttribute("BaseSize", part.Size / 0.01) end local baseSize = part:GetAttribute("BaseSize") part.Size = baseSize * data.Scale end end
            elseif data.Model:IsA("BasePart") then data.Model.CFrame = CFrame.new(currentPos) * CFrame.Angles(0, data.Time, 0) if not data.Model:GetAttribute("BaseSize") then data.Model:SetAttribute("BaseSize", data.Model.Size / 0.01) end data.Model.Size = data.Model:GetAttribute("BaseSize") * data.Scale end
        end
    end)
    bh.AncestryChanged:Connect(function() if not bh.Parent then CleanupCosmic(bh) end end) CosmicBlackhole.Active[bh] = data
end
local function StartCosmicSystem()
    if CosmicBlackhole.Connection then return end
    CosmicBlackhole.Connection = Workspace.ChildAdded:Connect(function(obj) if not CosmicBlackhole.Enabled then return end if obj.Name:lower():find("blackhole") then task.wait(0.2) BuildCosmic(obj) end end)
end
local function StopCosmicSystem()
    if CosmicBlackhole.Connection then CosmicBlackhole.Connection:Disconnect() CosmicBlackhole.Connection = nil end
    for bh, _ in pairs(CosmicBlackhole.Active) do CleanupCosmic(bh) end
end
local Defense = {
    AntiGrab = false, AntiBurn = false, AntiExplosion = false, AntiBananaSit = false, AntiSticky = false, AntiPaint = false, AntiAFK = false, AntiVoid = false, AntiRagdoll = false, AntiWater = false, AntiInputLag = false, AntiKickGrab = false, AntiKickV2 = false, AutoRespawn = false, SelectedSpawn = "Spawn", AutoAttacker = false, AttackerMode = "Death",
    ragdollCount = 0, antiGrabProce = false, paintPartsBackup = {}, paintConnections = {}, antiKickCoroutine = nil, notifiedNoCoins = false, originalVoidHeight = nil, ragdollConnections = {},
    SpawnLocations = {["Spawn"] = CFrame.new(4, -7, -3), ["Green Safe-House"] = CFrame.new(-584, -6, 93), ["Chinese Safe-House"] = CFrame.new(579, 124, -94), ["Blue Safe-House"] = CFrame.new(538, 96, -372), ["Witch Safe-House"] = CFrame.new(296, -4, 494), ["Red Safe-House"] = CFrame.new(-516, -6, -162)}
}

function ToggleAntiGrab(enabled)
    Defense.AntiGrab = enabled
    if enabled then
        task.spawn(function() while Defense.AntiGrab do pcall(function() Struggle:FireServer(LocalPlayer) end) Defense.ragdollCount = 0 task.wait(0.1) end end)
        local function AntiGrabHandler(character)
            local hrp = character:WaitForChild("HumanoidRootPart", 10) local hum = character:WaitForChild("Humanoid", 10) local head = character:WaitForChild("Head", 10)
            if not (hrp and hum and head) then return end
            head.ChildAdded:Connect(function(child)
                if child.Name ~= "PartOwner" or not Defense.AntiGrab then return end
                hum.Sit = false
                if Defense.ragdollCount < 100 then RagdollRemote:FireServer(hrp, 0) Defense.ragdollCount = Defense.ragdollCount + 1 end
                if not Defense.antiGrabProce then
                    Defense.antiGrabProce = true hrp.Anchored = true
                    local isHeld = LocalPlayer:WaitForChild("IsHeld", 5) while Defense.AntiGrab and (not isHeld or not isHeld.Value) do task.wait() end
                    local renderConnection = service.RunService.RenderStepped:Connect(function() hrp.CFrame = hrp.CFrame + hum.MoveDirection * 0.3 end)
                    while Defense.AntiGrab and isHeld and isHeld.Value do task.wait() end
                    renderConnection:Disconnect() hrp.Anchored = false Defense.antiGrabProce = false
                end
            end)
        end
        if LocalPlayer.Character then task.spawn(AntiGrabHandler, LocalPlayer.Character) end
        LocalPlayer.CharacterAdded:Connect(AntiGrabHandler)
    end
end
function ToggleAntiBurn(enabled)
    Defense.AntiBurn = enabled
    if enabled then
        if not Defense.burnConnection then
            Defense.burnConnection = service.RunService.Heartbeat:Connect(function()
                local char = GetCharacter() local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local fireLight = hrp:FindFirstChild("FireLight") local fireEmitter = hrp:FindFirstChild("FireParticleEmitter")
                    local mapHole = service.Workspace:FindFirstChild("Map") and service.Workspace.Map:FindFirstChild("Hole") and service.Workspace.Map.Hole:FindFirstChild("PoisonBigHole")
                    local extPart = mapHole and mapHole:FindFirstChild("ExtinguishPart") local originalPos = extPart and extPart.Position or Vector3.new()
                    if extPart then if fireLight or fireEmitter then extPart.CFrame = hrp.CFrame else extPart.CFrame = CFrame.new(originalPos) end end
                end
            end)
        end
    else if Defense.burnConnection then Defense.burnConnection:Disconnect() Defense.burnConnection = nil end end
end
function ToggleAntiExplosion(enabled)
    Defense.AntiExplosion = enabled
    local PlayerScripts = LocalPlayer:FindFirstChild("PlayerScripts")
    if PlayerScripts then local handler = PlayerScripts:FindFirstChild("ClientExoplosionHandler") if handler then handler.Enabled = not enabled end end
end
function ToggleAntiBananaSit(enabled)
    Defense.AntiBananaSit = enabled
    if enabled then
        task.spawn(function()
            while Defense.AntiBananaSit do
                task.wait() local char = GetCharacter() local hum = char:FindFirstChildOfClass("Humanoid") local hrp = char:FindFirstChild("HumanoidRootPart")
                if hum and hrp and hum.Health > 0 then hum.Sit = true hum:ChangeState(Enum.HumanoidStateType.Running) local vec = Workspace.CurrentCamera.CFrame.LookVector hrp.CFrame = CFrame.new(hrp.Position, hrp.Position + Vector3.new(vec.X, 0, vec.Z)) task.wait() hum:ChangeState(Enum.HumanoidStateType.Running) end
            end
        end)
    end
end
function ToggleAntiSticky(enabled)
    Defense.AntiSticky = enabled local stickyScript = LocalPlayer.PlayerScripts:FindFirstChild("StickyPartsTouchDetection") if stickyScript then stickyScript.Disabled = enabled end
end
function ToggleAntiPaint(enabled)
    Defense.AntiPaint = enabled
    local function setTouchQuery(state) local char = GetCharacter() if char then for _, v in ipairs(char:GetChildren()) do if v:IsA("BasePart") then v.CanTouch = state v.CanQuery = state end end end end
    if enabled then
        for _, obj in ipairs(service.Workspace:GetDescendants()) do if obj:IsA("BasePart") and obj.Name == "PaintPlayerPart" then local clone = obj:Clone() clone.Archivable = true Defense.paintPartsBackup[obj:GetDebugId()] = { clone = clone, parent = obj.Parent } obj:Destroy() end end
        local conn = service.Workspace.DescendantAdded:Connect(function(obj) if obj:IsA("BasePart") and obj.Name == "PaintPlayerPart" then task.defer(function() if obj and obj.Parent then local clone = obj:Clone() clone.Archivable = true Defense.paintPartsBackup[obj:GetDebugId()] = { clone = clone, parent = obj.Parent } obj:Destroy() end end) end end) table.insert(Defense.paintConnections, conn) setTouchQuery(false)
    else
        for _, conn in ipairs(Defense.paintConnections) do if conn.Connected then conn:Disconnect() end end Defense.paintConnections = {}
        for id, data in pairs(Defense.paintPartsBackup) do if data.clone and data.parent then data.clone.Parent = data.parent end end Defense.paintPartsBackup = {} setTouchQuery(true)
    end
end
function ToggleAntiAFK(enabled)
    Defense.AntiAFK = enabled if not enabled then return end
    LocalPlayer.Idled:Connect(function() if Defense.AntiAFK then service.VirtualUser:CaptureController() service.VirtualUser:ClickButton2(Vector2.new()) end end)
    task.spawn(function() while Defense.AntiAFK do service.VirtualUser:CaptureController() service.VirtualUser:Button1Down(Vector2.new(0,0)) task.wait(0.1) service.VirtualUser:Button1Up(Vector2.new(0,0)) task.wait(600) end end)
end
function ToggleAntiVoid(enabled)
    Defense.AntiVoid = enabled
    if enabled then if not Defense.originalVoidHeight then Defense.originalVoidHeight = service.Workspace.FallenPartsDestroyHeight end service.Workspace.FallenPartsDestroyHeight = -1e95
    else service.Workspace.FallenPartsDestroyHeight = Defense.originalVoidHeight or -500 end
end
function ToggleAntiRagdoll(enabled)
    Defense.AntiRagdoll = enabled
    local function clearConnections() for _, conn in ipairs(Defense.ragdollConnections) do if conn then conn:Disconnect() end end Defense.ragdollConnections = {} end
    local function protectHumanoid(humanoid)
        humanoid.BreakJointsOnDeath = false humanoid.AutoRotate = true humanoid.PlatformStand = false
        table.insert(Defense.ragdollConnections, humanoid.HealthChanged:Connect(function(health) if Defense.AntiRagdoll and health <= 0 then humanoid.Health = 1 end end))
        table.insert(Defense.ragdollConnections, humanoid:GetPropertyChangedSignal("AutoRotate"):Connect(function() if Defense.AntiRagdoll and humanoid.AutoRotate == false then humanoid.AutoRotate = true end end))
        table.insert(Defense.ragdollConnections, humanoid:GetPropertyChangedSignal("PlatformStand"):Connect(function() if Defense.AntiRagdoll and humanoid.PlatformStand == true then humanoid.PlatformStand = false end end))
        table.insert(Defense.ragdollConnections, service.RunService.RenderStepped:Connect(function() if Defense.AntiRagdoll and humanoid.Sit and humanoid.SeatPart == nil then humanoid.Sit = false end end))
    end
    local function onCharacter(char) local humanoid = char:WaitForChild("Humanoid", 5) if humanoid and Defense.AntiRagdoll then protectHumanoid(humanoid) end end
    if enabled then if GetCharacter() then onCharacter(GetCharacter()) end Defense.ragdollCharAddedConn = LocalPlayer.CharacterAdded:Connect(onCharacter)
    else clearConnections() if Defense.ragdollCharAddedConn then Defense.ragdollCharAddedConn:Disconnect() Defense.ragdollCharAddedConn = nil end end
end
function ToggleAntiWater(enabled)
    Defense.AntiWater = enabled
    local oceanPath = service.Workspace:FindFirstChild("Map") and service.Workspace.Map:FindFirstChild("AlwaysHereTweenedObjects") and service.Workspace.Map.AlwaysHereTweenedObjects:FindFirstChild("Ocean") and service.Workspace.Map.AlwaysHereTweenedObjects.Ocean:FindFirstChild("Object") and service.Workspace.Map.AlwaysHereTweenedObjects.Ocean.Object:FindFirstChild("ObjectModel")
    if oceanPath then for _, part in pairs(oceanPath:GetChildren()) do if part:IsA("BasePart") and part.Name == "Ocean" then part.CanCollide = enabled end end end
end
function ToggleAntiInputLag(enabled)
    Defense.AntiInputLag = enabled
    if enabled then
        task.spawn(function()
            local ToyName = "FoodHamburger"
            while Defense.AntiInputLag do
                local char = GetCharacter() local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if not hrp then service.RunService.Heartbeat:Wait() continue end
                local burger = SpawnedInToys and SpawnedInToys:FindFirstChild(ToyName)
                if not burger and Defense.AntiInputLag then pcall(function() SpawnToyRemoteFunction:InvokeServer(ToyName, hrp.CFrame * CFrame.new(0, 5, 0), Vector3.new(0, 0, 0)) end) continue end
                if burger and Defense.AntiInputLag then
                    local holdPart = burger:FindFirstChild("HoldPart", true)
                    if holdPart then
                        local hRemote = holdPart:FindFirstChild("HoldItemRemoteFunction") local dRemote = holdPart:FindFirstChild("DropItemRemoteFunction") local hPlayer = holdPart:FindFirstChild("HoldingPlayer")
                        if hPlayer and hPlayer.Value and hPlayer.Value ~= LocalPlayer then if dRemote then pcall(function() dRemote:InvokeServer(burger, hrp.CFrame * CFrame.new(0, 2000, 0), Vector3.new(0, 0, 0)) end) end burger:Destroy()
                        elseif hRemote and dRemote then pcall(function() hRemote:InvokeServer(burger, char) dRemote:InvokeServer(burger, hrp.CFrame * CFrame.new(0, 2000, 0), Vector3.new(0, 0, 0)) end) end
                    end
                end
                task.wait()
            end
        end)
    end
end
function ToggleAntiKickGrab(enabled)
    Defense.AntiKickGrab = enabled
    if Defense.antiKickCoroutine then Defense.antiKickCoroutine:Disconnect() Defense.antiKickCoroutine = nil end
    if enabled then
        Defense.antiKickCoroutine = service.RunService.Heartbeat:Connect(function()
            local character = GetCharacter()
            if character and character:FindFirstChild("HumanoidRootPart") then
                local fp = character.HumanoidRootPart:FindFirstChild("FirePlayerPart")
                if fp then local partOwner = fp:FindFirstChild("PartOwner") if partOwner and partOwner.Value ~= LocalPlayer.Name then pcall(function() RagdollRemote:FireServer(character.HumanoidRootPart, 0) task.wait(0.1) Struggle:FireServer() end) end end
            end
        end)
    end
end
function ToggleAntiKickV2(enabled)
    Defense.AntiKickV2 = enabled if enabled then Defense.notifiedNoCoins = false end
    local function getCharPart(name) local char = GetCharacter() return char and char:FindFirstChild(name) end
    local function inner_toyspn(toyName, cf) SpawnToyRemoteFunction:InvokeServer(toyName, cf, Vector3.new(0, 0, 0)) end
    local function inner_toyspn2(toyName) local hrp = getCharPart("HumanoidRootPart") if hrp then local cf = hrp.CFrame inner_toyspn(toyName, cf - Vector3.new(cf.LookVector.X * 20, -15, cf.LookVector.Z * 20)) end end
    local function kickLoop()
        local character = GetCharacter() if not character then return end
        local hrp = character:FindFirstChild("HumanoidRootPart") local hum = character:FindFirstChildOfClass("Humanoid") local leg = character:FindFirstChild("Right Leg")
        if not hrp or not hum or not leg or hum.Health <= 0 then return end
        if LocalPlayer.InPlot and LocalPlayer.InPlot.Value then return end
        local ToyContents = LocalPlayer.PlayerGui:WaitForChild("MenuGui"):WaitForChild("Menu"):WaitForChild("TabContents"):WaitForChild("Toys"):WaitForChild("Contents")
        if not ToyContents:FindFirstChild("NinjaKunai") then
            local success = BuyToyRemoteFunction:InvokeServer("NinjaKunai")
            if not success then if not Defense.notifiedNoCoins then JapanNotify("コイン不足でNinjaKunaiを買えません。") Defense.notifiedNoCoins = true end return end
        end
        local kunai = SpawnedInToys:FindFirstChild("NinjaKunai")
        if kunai then
            local sticky = kunai:WaitForChild("StickyPart", 1)
            if sticky then local weld = sticky:FindFirstChild("StickyWeld") local attachedPart = weld and weld.Part1 if not weld or attachedPart ~= leg then DestroyToy:FireServer(kunai) task.wait(0.1) end else DestroyToy:FireServer(kunai) task.wait(0.1) end
        elseif LocalPlayer.CanSpawnToy and LocalPlayer.CanSpawnToy.Value then
            task.spawn(inner_toyspn2, "NinjaKunai")
            local newKunai = SpawnedInToys:WaitForChild("NinjaKunai", 3)
            if newKunai then local sticky = newKunai:WaitForChild("StickyPart", 2) if sticky then local weld = sticky:FindFirstChild("StickyWeld", 2) SetNetworkOwner:FireServer(sticky, sticky.CFrame) local retry = 0 while Defense.AntiKickV2 and weld.Part1 == nil and retry < 20 do StickyPartEvent:FireServer(sticky, leg, CFrame.new(0.0490287527, 0.5, 0, 0, 0.00739139877, -0.999561906, -0.998452604, -0.0478846952, 0.0282763243, -0.0476547107, 0.99882561, 0) * CFrame.Angles(0, 0, 0)) task.wait(0.1) retry = retry + 1 end end end
        end
    end
    if enabled then task.spawn(function() while Defense.AntiKickV2 do pcall(kickLoop) task.wait() end end) end
end
local respawnConnection = nil
function ToggleAutoRespawn(enabled, spawnLocation)
    Defense.AutoRespawn = enabled if spawnLocation then Defense.SelectedSpawn = spawnLocation end
    if respawnConnection then respawnConnection:Disconnect() respawnConnection = nil end
    if enabled then
        respawnConnection = LocalPlayer.CharacterAdded:Connect(function(char)
            local hrp = char:WaitForChild("HumanoidRootPart", 5) if hrp then local targetCFrame = Defense.SpawnLocations[Defense.SelectedSpawn] if targetCFrame then task.wait() hrp.CFrame = targetCFrame end end
        end)
    end
end
local attackerCoroutine = nil
function ToggleAutoAttacker(enabled, mode)
    Defense.AutoAttacker = enabled if mode then Defense.AttackerMode = mode end
    if attackerCoroutine then coroutine.close(attackerCoroutine) attackerCoroutine = nil end
    if not enabled then return end
    attackerCoroutine = coroutine.create(function()
        while Defense.AutoAttacker do
            task.wait(0.02)
            local character = GetCharacter()
            local head = character and character:FindFirstChild("Head")
            local localHRP = character and character:FindFirstChild("HumanoidRootPart")
            if not (character and head and localHRP) then continue end
            local partOwner = head:FindFirstChild("PartOwner") if not partOwner then continue end
            local attacker = service.Players:FindFirstChild(partOwner.Value) if not (attacker and attacker.Character) then continue end
            local targetChar = attacker.Character
            local hrp = targetChar:FindFirstChild("HumanoidRootPart")
            local hum = targetChar:FindFirstChildOfClass("Humanoid")
            local torso = targetChar:FindFirstChild("Torso") or targetChar:FindFirstChild("UpperTorso")
            if not hrp or not hum then continue end
            Struggle:FireServer()
            if Defense.AttackerMode == "Death" then
                pcall(function()
                    SetNetworkOwner:FireServer(hrp, hrp.CFrame)
                    task.wait(0.05)
                    for _, bp in ipairs(targetChar:GetChildren()) do
                        if bp:IsA("BasePart") then bp.CFrame = CFrame.new(0, -1e9, 0) bp.CanCollide = false end
                    end
                    hum.Health = 0
                    hum:ChangeState(Enum.HumanoidStateType.Dead)
                    if GrabEvents:FindFirstChild("DestroyGrabLine") then DestroyGrabLine:FireServer(hrp) end
                end)
            elseif Defense.AttackerMode == "Knockback" then
                local knockback = Instance.new("BodyVelocity") knockback.MaxForce = Vector3.new(1e6, 1e6, 1e6) knockback.Velocity = (localHRP.CFrame.LookVector * 200) + Vector3.new(0, 50, 0) knockback.Parent = hrp service.Debris:AddItem(knockback, 1)
            elseif Defense.AttackerMode == "airSuspend" and torso then
                local velocity = torso:FindFirstChild("l") or Instance.new("BodyVelocity") velocity.Name = "l" velocity.Velocity = Vector3.new(0, 5000, 0) velocity.MaxForce = Vector3.new(0, math.huge, 0) velocity.Parent = torso service.Debris:AddItem(velocity, 1)
            elseif Defense.AttackerMode == "Freeze" then
                local freezeVel = Instance.new("BodyVelocity") freezeVel.MaxForce = Vector3.new(1e6, 1e6, 1e6) freezeVel.Velocity = Vector3.new(0, 0, 0) freezeVel.Parent = hrp service.Debris:AddItem(freezeVel, 2)
            end
        end
    end)
    coroutine.resume(attackerCoroutine)
end
function ToggleAntiLag(enabled)
    local CharacterAndBeamMove = LocalPlayer.PlayerScripts:FindFirstChild("CharacterAndBeamMove") if CharacterAndBeamMove then CharacterAndBeamMove.Disabled = enabled end
end


-- =====================================================
-- Japan HUB - Obsidian Edition (機能拡張版)
-- =====================================================
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/deividcomsono/Obsidian/main/Library.lua"))()
local ThemeManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/deividcomsono/Obsidian/main/addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/deividcomsono/Obsidian/main/addons/SaveManager.lua"))()

ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)

ThemeManager:SetDefaultTheme({
	BackgroundColor = Color3.fromRGB(12, 15, 14),
	MainColor       = Color3.fromRGB(18, 24, 22),
	AccentColor     = Color3.fromRGB(0, 230, 150),
	OutlineColor    = Color3.fromRGB(40, 55, 50),
	FontColor       = Color3.fromRGB(230, 240, 235),
})

function JapanNotify(Message)
	Library:Notify({ Title = "Japan HUB", Description = tostring(Message), Time = 4 })
end

local Window = Library:CreateWindow({
	Title = "Japan HUB",
	Footer = "Obsidian Edition",
	Center = true,
	AutoShow = true,
	ToggleKeybind = Enum.KeyCode.K,
})

local Tabs = {
	Kick     = Window:AddTab("キック", "swords"),
	Plank    = Window:AddTab("板キック", "box"),
	Cam      = Window:AddTab("三人称", "eye"),
	Texture  = Window:AddTab("キックテクスチャ", "image"),
	Plot     = Window:AddTab("プロット破壊", "bomb"),
	Defense  = Window:AddTab("防御", "shield"),
	Player   = Window:AddTab("プレイヤー", "user"),
	Movement = Window:AddTab("移動", "run"),
	Visual   = Window:AddTab("ビジュアル", "eye"),
	Troll    = Window:AddTab("トロール", "smile"),
	Server   = Window:AddTab("サーバー", "server"),
	Utility  = Window:AddTab("ユーティリティ", "wrench"),
	Katsura  = Window:AddTab("拡張機能", "layers"),
	Settings = Window:AddTab("設定", "settings"),
}

-- ========== キック (Drift) ==========
local KickLeft = Tabs.Kick:AddLeftGroupbox("ターゲット")
local KickRight = Tabs.Kick:AddRightGroupbox("Drift Kick")

local TargetOptions, TargetMap = {}, {}
local selectedActionTargetName = ""
local orbitRunning, radius, speed, heightOffset, angle, currentLoopId = false, 19, 12, 0, 0, 0

local function UpdateTargetOptions()
	TargetOptions = {"(なし)"}
	TargetMap = {}
	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= LocalPlayer then
			local display = p.DisplayName .. " (@" .. p.Name .. ")"
			table.insert(TargetOptions, display)
			TargetMap[display] = p.Name
		end
	end
end
UpdateTargetOptions()

local DriftTargetDropdown = KickLeft:AddDropdown("DriftTarget", {
	Text = "ターゲットを選択",
	Values = TargetOptions,
	Default = 1,
	Callback = function(option)
		selectedActionTargetName = TargetMap[option] or ""
	end
})

KickLeft:AddButton({
	Text = "ターゲットリストを更新",
	Func = function()
		UpdateTargetOptions()
		DriftTargetDropdown:SetValues(TargetOptions)
		JapanNotify("リストを更新しました。")
	end
})

KickRight:AddToggle("DriftKick", {
	Text = "Drift Kick (旋回キック + ラインラグ)",
	Default = false,
	Callback = function(v)
        orbitRunning = v currentLoopId = currentLoopId + 1 local myLoopId = currentLoopId
        if not v then return end
        local target = Players:FindFirstChild(selectedActionTargetName)
        if not target or target == LocalPlayer then JapanNotify("有効なターゲットを選んでください。") orbitRunning = false return end
        
        task.spawn(function()
            while orbitRunning and myLoopId == currentLoopId do
                local t = Players:FindFirstChild(selectedActionTargetName)
                if t and t.Character then
                    local spawnLoc = Workspace:FindFirstChild("SpawnLocation") or Workspace:FindFirstChild("Spawn") or (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart"))
                    if spawnLoc then
                        CreateGrabLine:FireServer(spawnLoc, CFrame.new(math.random(-2e9, 2e9), 0, math.random(-2e9, 2e9)))
                        CreateGrabLine:FireServer(spawnLoc, CFrame.new(math.random(-2e9, 2e9), 0, math.random(-2e9, 2e9)))
                        CreateGrabLine:FireServer(spawnLoc, CFrame.new(math.random(-2e9, 2e9), 0, math.random(-2e9, 2e9)))
                    end
                end
                task.wait(0.001)
            end
        end)

        local blobman = nil local spawned = Workspace:FindFirstChild(LocalPlayer.Name .. "SpawnedInToys")
        if spawned then blobman = spawned:FindFirstChild("CreatureBlobman") end
        if not blobman then local mt = ReplicatedStorage:FindFirstChild("MenuToys") local st = mt and mt:FindFirstChild("SpawnToyRemoteFunction") if st then local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") local spawnCF = myRoot and (myRoot.CFrame + Vector3.new(0, 5, 0)) or CFrame.new(0, 50, 0) st:InvokeServer("CreatureBlobman", spawnCF, Vector3.zero) task.wait(0.8) spawned = Workspace:FindFirstChild(LocalPlayer.Name .. "SpawnedInToys") if spawned then blobman = spawned:FindFirstChild("CreatureBlobman") end end end
        if not blobman then for _, obj in ipairs(Workspace:GetChildren()) do if obj.Name == "CreatureBlobman" and obj:FindFirstChild("VehicleSeat") then blobman = obj break end end end
        if blobman then
            local scriptObj = blobman:FindFirstChild("BlobmanSeatAndOwnerScript") local grabRemote = scriptObj and scriptObj:FindFirstChild("CreatureGrab") local dropRemote = scriptObj and scriptObj:FindFirstChild("CreatureDrop")
            local lDet = blobman:FindFirstChild("LeftDetector") local rDet = blobman:FindFirstChild("RightDetector") local lWeld = lDet and (lDet:FindFirstChild("LeftWeld") or lDet:FindFirstChild("RigidConstraint")) local rWeld = rDet and (rDet:FindFirstChild("RightWeld") or rDet:FindFirstChild("RigidConstraint"))
            local seat = blobman:FindFirstChild("VehicleSeat") local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
            if seat and hum and seat.Occupant ~= hum then LocalPlayer.Character.HumanoidRootPart.CFrame = seat.CFrame + Vector3.new(0, 2, 0) task.wait(0.2) seat:Sit(hum) task.wait(0.5) end
            local GE = ReplicatedStorage:FindFirstChild("GrabEvents")
            if GE and grabRemote and dropRemote and ((lDet and lWeld) or (rDet and rWeld)) then
                JapanNotify("drift kick を開始します")
                task.spawn(function()
                    local blobRoot = blobman:FindFirstChild("HumanoidRootPart") or blobman.PrimaryPart local Det = rDet or lDet local Weld = rWeld or lWeld
                    while orbitRunning do
                        if myLoopId ~= currentLoopId then break end if not target or not target.Parent then break end
                        local tChar = target.Character local tHum = tChar and tChar:FindFirstChild("Humanoid") local tRoot = tChar and tChar:FindFirstChild("HumanoidRootPart")
                        if tChar and tRoot and tHum and tHum.Health > 0 then
                            local bringStart = tick()
                            while tick() - bringStart < 0.35 do
                                if myLoopId ~= currentLoopId or not orbitRunning or not blobman or not blobman.Parent then break end
                                if target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                                    local currentTRoot = target.Character.HumanoidRootPart blobRoot.CFrame = currentTRoot.CFrame blobRoot.AssemblyLinearVelocity = Vector3.zero
                                    pcall(function() if Det then grabRemote:FireServer(Det, currentTRoot, Weld) end GE.CreateGrabLine:FireServer(currentTRoot, Vector3.zero, currentTRoot.Position, false) GE.SetNetworkOwner:FireServer(currentTRoot, blobRoot.CFrame) end)
                                end
                                RunService.Heartbeat:Wait()
                            end
                            if myLoopId ~= currentLoopId or not orbitRunning or not blobman or not blobman.Parent then break end
                            tChar = target.Character tRoot = tChar and tChar:FindFirstChild("HumanoidRootPart") tHum = tChar and tChar:FindFirstChild("Humanoid")
                            if tChar and tRoot and tHum and tHum.Health > 0 then
                                local SavedPos = tRoot.CFrame local targetCenterCFrame = SavedPos + Vector3.new(0, 30, 0) local lastTime = tick() local lastDropTime = tick() local dropCount = 0
                                while orbitRunning and blobman and blobman.Parent do
                                    if myLoopId ~= currentLoopId then break end if not target or not target.Parent then break end
                                    tChar = target.Character tRoot = tChar and tChar:FindFirstChild("HumanoidRootPart") tHum = tChar and tChar:FindFirstChild("Humanoid")
                                    if not tChar or not tRoot or not tHum or tHum.Health <= 0 then break end
                                    if dropCount < 2 and (tick() - lastDropTime) > 0.8 then
                                        dropCount = dropCount + 1
                                        pcall(function() local rightWeld = blobman:FindFirstChild("RightDetector") and blobman.RightDetector:FindFirstChild("RightWeld") if rightWeld then dropRemote:FireServer(rightWeld) end GE.DestroyGrabLine:FireServer(tRoot) end)
                                        blobRoot.CFrame = SavedPos blobRoot.AssemblyLinearVelocity = Vector3.zero RunService.Heartbeat:Wait()
                                        if target.Character and target.Character:FindFirstChild("HumanoidRootPart") then local currentTRoot = target.Character.HumanoidRootPart blobRoot.CFrame = currentTRoot.CFrame blobRoot.AssemblyLinearVelocity = Vector3.zero pcall(function() if Det then grabRemote:FireServer(Det, currentTRoot, Weld) end GE.CreateGrabLine:FireServer(currentTRoot, Vector3.zero, currentTRoot.Position, false) GE.SetNetworkOwner:FireServer(currentTRoot, blobRoot.CFrame) end) end
                                        lastTime = tick() lastDropTime = tick() continue
                                    end
                                    if tRoot and tHum and tHum.Health > 0 and blobRoot then
                                        local currentTime = tick() local dt = currentTime - lastTime lastTime = currentTime
                                        angle = angle + (speed * dt) local offsetX = math.cos(angle) * radius local offsetZ = math.sin(angle) * radius
                                        local blobPos = targetCenterCFrame.Position + Vector3.new(offsetX, heightOffset, offsetZ)
                                        blobRoot.CFrame = CFrame.new(blobPos, targetCenterCFrame.Position) blobRoot.AssemblyLinearVelocity = Vector3.zero blobRoot.AssemblyAngularVelocity = Vector3.zero
                                        tRoot.CFrame = targetCenterCFrame tRoot.AssemblyLinearVelocity = Vector3.zero tRoot.AssemblyAngularVelocity = Vector3.zero
                                        pcall(function() tHum.PlatformStand = true tHum.Sit = true GE.SetNetworkOwner:FireServer(tRoot, targetCenterCFrame) local rightWeld = blobman:FindFirstChild("RightDetector") and blobman.RightDetector:FindFirstChild("RightWeld") if rightWeld then dropRemote:FireServer(rightWeld) end GE.DestroyGrabLine:FireServer(tRoot) if Det then grabRemote:FireServer(Det, tRoot, Weld) end GE.CreateGrabLine:FireServer(tRoot, Vector3.zero, targetCenterCFrame.Position, false) end)
                                    else break end
                                    RunService.Heartbeat:Wait()
                                end
                                if not orbitRunning or myLoopId ~= currentLoopId then
                                    if blobRoot and SavedPos then pcall(function() local rightWeld = blobman:FindFirstChild("RightDetector") and blobman.RightDetector:FindFirstChild("RightWeld") if rightWeld then dropRemote:FireServer(rightWeld) end if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then GE.DestroyGrabLine:FireServer(target.Character.HumanoidRootPart) end end) blobRoot.CFrame = SavedPos blobRoot.AssemblyLinearVelocity = Vector3.zero end
                                    break
                                end
                            end
                        end
                        RunService.Heartbeat:Wait()
                    end
                end)
            else JapanNotify("必要なRemoteEventやDetectorが見つかりません") orbitRunning = false end
        else JapanNotify("Blobmanの取得・生成に失敗しました") orbitRunning = false end
    end
})

KickRight:AddSlider("OrbitRadius", {
	Text = "旋回半径 (Radius)",
	Default = 19, Min = 5, Max = 50, Rounding = 0,
	Callback = function(v) radius = v end
})

KickRight:AddSlider("OrbitSpeed", {
	Text = "旋回速度 (Speed)",
	Default = 12, Min = 1, Max = 50, Rounding = 0,
	Callback = function(v) speed = v end
})

-- ========== Katsura由来キック ==========
local KatKick = Tabs.Kick:AddLeftGroupbox("Katsuraキック")
local KatKick2 = Tabs.Kick:AddRightGroupbox("Katsuraキック2")

_G.JapanKat = _G.JapanKat or {}
_G.JapanKat.cons = _G.JapanKat.cons or {}
_G.JapanKat.EnableRagdoll = false

local function KatGetSelected()
	if selectedActionTargetName and selectedActionTargetName ~= "" then
		return Players:FindFirstChild(selectedActionTargetName)
	end
	return nil
end

local function KatSpawntoy(toy, cf)
	local canSpawn = LocalPlayer:FindFirstChild("CanSpawnToy")
	if canSpawn and not canSpawn.Value then
		local t = tick()
		repeat task.wait(0.05) until canSpawn.Value or tick() - t > 3
	end
	local inv = Workspace:FindFirstChild(LocalPlayer.Name .. "SpawnedInToys")
	local result = nil
	local conn
	if inv then
		conn = inv.ChildAdded:Connect(function(c)
			if c.Name == toy then result = c end
		end)
	end
	pcall(function()
		SpawnToyRemoteFunction:InvokeServer(toy, cf, Vector3.zero)
	end)
	local t = tick() + 1.5
	repeat task.wait() until result or tick() > t
	if conn then conn:Disconnect() end
	return result
end

local function KatSno(obj)
	if not obj then return end
	pcall(function() SetNetworkOwner:FireServer(obj, obj.CFrame) end)
end

local function KatGblob()
	local char = LocalPlayer.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	if hum and hum.SeatPart and hum.SeatPart.Parent and hum.SeatPart.Parent.Name == "CreatureBlobman" then
		return hum.SeatPart.Parent
	end
	local inv = Workspace:FindFirstChild(LocalPlayer.Name .. "SpawnedInToys")
	return inv and inv:FindFirstChild("CreatureBlobman")
end

KatKick:AddToggle("KatKickSpamGrab", {
	Text = "Kick Spam Grab (Katsura)",
	Default = false,
	Callback = function(Value)
		_G.JapanKat.EnableRagdoll = Value
		if not Value then
			if _G.JapanKat.kickbp then pcall(function() _G.JapanKat.kickbp:Destroy() end) _G.JapanKat.kickbp = nil end
			JapanNotify("Kick Spam Grab 停止")
			return
		end
		local target = KatGetSelected()
		if not target then
			JapanNotify("先にターゲットを選んでください")
			_G.JapanKat.EnableRagdoll = false
			return
		end
		JapanNotify("Kick Spam Grab 開始")
		task.spawn(function()
			local HRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
			if not HRP then return end
			local PalletForRagdoll = KatSpawntoy("PalletLightBrown", HRP.CFrame * CFrame.new(0, 10, 20))
			if not PalletForRagdoll then JapanNotify("パレット生成失敗") return end
			local t = tick()
			repeat task.wait() until PalletForRagdoll:FindFirstChild("SoundPart") or tick()-t > 3 or not _G.JapanKat.EnableRagdoll
			if not PalletForRagdoll:FindFirstChild("SoundPart") or not _G.JapanKat.EnableRagdoll then return end
			t = tick()
			repeat KatSno(PalletForRagdoll.SoundPart) task.wait()
			until PalletForRagdoll.SoundPart:FindFirstChild("PartOwner") or tick()-t > 3 or not _G.JapanKat.EnableRagdoll
			if not PalletForRagdoll.Parent or not _G.JapanKat.EnableRagdoll then return end
			for _, v in pairs(PalletForRagdoll:GetChildren()) do
				if v:IsA("BasePart") then v.CanCollide = false v.Transparency = 0.8 end
			end
			PalletForRagdoll.Name = "PalletForRagdoll"
			while _G.JapanKat.EnableRagdoll do
				local tt = KatGetSelected()
				if not tt or not tt.Character then task.wait(0.2) continue end
				local tarHRP = tt.Character:FindFirstChild("HumanoidRootPart")
				local tarHum = tt.Character:FindFirstChildOfClass("Humanoid")
				if not tarHRP or not tarHum or tarHum.Health <= 0 then task.wait(0.2) continue end
				local inv = Workspace:FindFirstChild(LocalPlayer.Name .. "SpawnedInToys")
				local currentPallet = inv and inv:FindFirstChild("PalletForRagdoll")
				if currentPallet and currentPallet:FindFirstChild("SoundPart") then
					pcall(function()
						currentPallet.SoundPart.CFrame = tarHRP.CFrame
						KatSno(currentPallet.SoundPart)
						KatSno(tarHRP)
						CreateGrabLine:FireServer(tarHRP, CFrame.new(math.random(-2e9, 2e9), 0, math.random(-2e9, 2e9)))
					end)
				else
					HRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
					if HRP then
						PalletForRagdoll = KatSpawntoy("PalletLightBrown", HRP.CFrame * CFrame.new(0, 10, 20))
						if PalletForRagdoll and PalletForRagdoll:FindFirstChild("SoundPart") then
							for _ = 1, 8 do KatSno(PalletForRagdoll.SoundPart) task.wait() end
							PalletForRagdoll.Name = "PalletForRagdoll"
						end
					end
				end
				local blob = KatGblob()
				if not blob then
					HRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
					if HRP then blob = KatSpawntoy("CreatureBlobman", HRP.CFrame * CFrame.new(5, 5, 20)) end
				end
				if blob then
					local blobRoot = blob.PrimaryPart or blob:FindFirstChild("HumanoidRootPart") or blob:FindFirstChildWhichIsA("BasePart")
					local scriptObj = blob:FindFirstChild("BlobmanSeatAndOwnerScript")
					local grabRemote = scriptObj and scriptObj:FindFirstChild("CreatureGrab")
					local Det = blob:FindFirstChild("RightDetector")
					local Weld = Det and Det:FindFirstChild("RightWeld")
					if blobRoot and tarHRP then
						pcall(function()
							blobRoot.CFrame = CFrame.new(tarHRP.Position + Vector3.new(3, 0, 3), tarHRP.Position)
							if grabRemote and Det and Weld then grabRemote:FireServer(Det, tarHRP, Weld) end
							CreateGrabLine:FireServer(tarHRP, Vector3.zero, tarHRP.Position, false)
						end)
					end
				end
				if not _G.JapanKat.kickbp or _G.JapanKat.kickbp.Parent ~= tarHRP then
					if _G.JapanKat.kickbp then pcall(function() _G.JapanKat.kickbp:Destroy() end) end
					local bp = Instance.new("BodyPosition")
					bp.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
					bp.D = 200
					bp.P = 10000
					bp.Position = tarHRP.Position + Vector3.new(0, 15, 0)
					bp.Parent = tarHRP
					_G.JapanKat.kickbp = bp
				else
					_G.JapanKat.kickbp.Position = tarHRP.Position + Vector3.new(0, 15, 0)
				end
				task.wait(0.05)
			end
			if _G.JapanKat.kickbp then pcall(function() _G.JapanKat.kickbp:Destroy() end) _G.JapanKat.kickbp = nil end
		end)
	end
})

local katBlobKickOn = false
KatKick:AddToggle("KatBlobGrabKick", {
	Text = "BlobGrab Kick (Katsura)",
	Default = false,
	Callback = function(on)
		katBlobKickOn = on
		if not on then JapanNotify("BlobGrab Kick 停止") return end
		if not KatGetSelected() then
			JapanNotify("先にターゲットを選んでください")
			katBlobKickOn = false
			return
		end
		JapanNotify("BlobGrab Kick 開始")
		task.spawn(function()
			local HRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
			if not HRP then return end
			local blob = KatGblob() or KatSpawntoy("CreatureBlobman", HRP.CFrame * CFrame.new(5, 5, 20))
			if not blob then JapanNotify("Blobman生成失敗") katBlobKickOn = false return end
			task.wait(0.5)
			while katBlobKickOn do
				local tt = KatGetSelected()
				if not tt or not tt.Character then task.wait(0.2) continue end
				local tarHRP = tt.Character:FindFirstChild("HumanoidRootPart")
				local tarHum = tt.Character:FindFirstChildOfClass("Humanoid")
				if not tarHRP or not tarHum or tarHum.Health <= 0 then task.wait(0.2) continue end
				if not blob or not blob.Parent then
					blob = KatGblob() or KatSpawntoy("CreatureBlobman", HRP.CFrame * CFrame.new(5, 5, 20))
					if not blob then break end
					task.wait(0.4)
				end
				local blobRoot = blob.PrimaryPart or blob:FindFirstChild("HumanoidRootPart") or blob:FindFirstChildWhichIsA("BasePart")
				local scriptObj = blob:FindFirstChild("BlobmanSeatAndOwnerScript")
				local grabRemote = scriptObj and scriptObj:FindFirstChild("CreatureGrab")
				local dropRemote = scriptObj and scriptObj:FindFirstChild("CreatureDrop")
				local Det = blob:FindFirstChild("RightDetector")
				local Weld = Det and Det:FindFirstChild("RightWeld")
				if blobRoot then
					pcall(function()
						local ang = tick() * 10
						local pos = tarHRP.Position + Vector3.new(math.cos(ang) * 10, 0, math.sin(ang) * 10)
						blobRoot.CFrame = CFrame.new(pos, tarHRP.Position)
						blobRoot.AssemblyLinearVelocity = Vector3.zero
						if tarHum then tarHum.PlatformStand = true tarHum.Sit = true end
						SetNetworkOwner:FireServer(tarHRP, tarHRP.CFrame)
						if dropRemote and Weld then dropRemote:FireServer(Weld) end
						DestroyGrabLine:FireServer(tarHRP)
						if grabRemote and Det and Weld then grabRemote:FireServer(Det, tarHRP, Weld) end
						CreateGrabLine:FireServer(tarHRP, Vector3.zero, tarHRP.Position, false)
						CreateGrabLine:FireServer(tarHRP, CFrame.new(math.random(-2e9, 2e9), 0, math.random(-2e9, 2e9)))
					end)
				end
				task.wait(0.04)
			end
		end)
	end
})

local katSnowKickOn = false
KatKick2:AddToggle("KatSnowballKick", {
	Text = "Ragdoll Snowball Kick",
	Default = false,
	Callback = function(on)
		katSnowKickOn = on
		if not on then JapanNotify("Snowball Kick 停止") return end
		if not KatGetSelected() then
			JapanNotify("先にターゲットを選んでください")
			katSnowKickOn = false
			return
		end
		JapanNotify("Snowball Kick 開始")
		task.spawn(function()
			while katSnowKickOn do
				local tt = KatGetSelected()
				if not tt or not tt.Parent then RunService.Heartbeat:Wait() continue end
				local tChar = tt.Character
				local torso = tChar and (tChar:FindFirstChild("UpperTorso") or tChar:FindFirstChild("Torso") or tChar:FindFirstChild("HumanoidRootPart"))
				if not torso then RunService.Heartbeat:Wait() continue end
				pcall(function()
					local offset = Vector3.new(math.random(-30,30)/100, math.random(-30,30)/100, math.random(-30,30)/100)
					SpawnToyRemoteFunction:InvokeServer("BallSnowball", torso.CFrame * CFrame.new(offset), Vector3.zero)
				end)
				local folder = Workspace:FindFirstChild(LocalPlayer.Name .. "SpawnedInToys")
				if folder then
					for _, snowball in pairs(folder:GetChildren()) do
						if snowball.Name == "BallSnowball" and snowball.Parent then
							local part = snowball.PrimaryPart or snowball:FindFirstChildWhichIsA("BasePart")
							if part then
								local offset = Vector3.new(math.random(-30,30)/100, math.random(-30,30)/100, math.random(-30,30)/100)
								part.CFrame = torso.CFrame * CFrame.new(offset)
								part.AssemblyLinearVelocity = Vector3.zero
								part.AssemblyAngularVelocity = Vector3.zero
							end
						end
					end
				end
				RunService.Heartbeat:Wait()
			end
		end)
	end
})

KatKick2:AddToggle("KatShurikenStick", {
	Text = "Shuriken Stick Kick",
	Default = false,
	Callback = function(on)
		if not on then
			_G.JapanKat.ShurikenStick = false
			JapanNotify("Shuriken Stick 停止")
			return
		end
		if not KatGetSelected() then
			JapanNotify("先にターゲットを選んでください")
			return
		end
		_G.JapanKat.ShurikenStick = true
		JapanNotify("Shuriken Stick 開始")
		task.spawn(function()
			while _G.JapanKat.ShurikenStick do
				local tt = KatGetSelected()
				local tarHRP = tt and tt.Character and tt.Character:FindFirstChild("HumanoidRootPart")
				local HRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
				if not tarHRP or not HRP then task.wait(0.3) continue end
				local inv = Workspace:FindFirstChild(LocalPlayer.Name .. "SpawnedInToys")
				local kunai = nil
				if inv then
					local c = inv.ChildAdded:Connect(function(ch)
						if ch.Name == "NinjaShuriken" then kunai = ch end
					end)
					pcall(function()
						SpawnToyRemoteFunction:InvokeServer("NinjaShuriken", HRP.CFrame * CFrame.new(0, 5, 5), Vector3.zero)
					end)
					local t = tick()
					repeat task.wait(0.05) until kunai or tick()-t > 2 or not _G.JapanKat.ShurikenStick
					c:Disconnect()
				end
				if kunai and _G.JapanKat.ShurikenStick then
					local sound = kunai:FindFirstChild("SoundPart")
					local sticky = kunai:FindFirstChild("StickyPart")
					if sound then
						for _ = 1, 10 do
							KatSno(sound)
							task.wait()
							if sound:FindFirstChild("PartOwner") then break end
						end
					end
					if sticky and tarHRP then
						pcall(function()
							StickyPartEvent:FireServer(sticky, tarHRP, CFrame.new())
							CreateGrabLine:FireServer(tarHRP, CFrame.new(math.random(-1e9,1e9), 0, math.random(-1e9,1e9)))
						end)
					end
				end
				task.wait(0.15)
			end
		end)
	end
})

-- ========== 板キック ==========
local PlankLeft = Tabs.Plank:AddLeftGroupbox("ターゲット")
local PlankRight = Tabs.Plank:AddRightGroupbox("板キック")

local PlankTargetOptions, PlankTargetMap = {}, {}
local function UpdatePlankTargetOptions()
	PlankTargetOptions = {"(なし)"}
	PlankTargetMap = {}
	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= LocalPlayer then
			local display = p.DisplayName .. " (@" .. p.Name .. ")"
			table.insert(PlankTargetOptions, display)
			PlankTargetMap[display] = p
		end
	end
end
UpdatePlankTargetOptions()

local PlankDropdown = PlankLeft:AddDropdown("PlankTarget", {
	Text = "ターゲットを選択",
	Values = PlankTargetOptions,
	Default = 1,
	Callback = function(option)
		local p = PlankTargetMap[option]
		Config.PlayerList = p and {p.Name} or {}
	end
})

PlankLeft:AddButton({
	Text = "ターゲットリストを更新",
	Func = function()
		UpdatePlankTargetOptions()
		PlankDropdown:SetValues(PlankTargetOptions)
		JapanNotify("リストを更新しました。")
	end
})

PlankRight:AddToggle("KickSpam", {
	Text = "キックスパム (ラグドール＆ラグ)",
	Default = false,
	Callback = function(aa61)
        Config.aa6 = aa61 Config.aa13 = aa61
        if aa61 then if not Config.PlayerList or #Config.PlayerList == 0 then JapanNotify("先にターゲットを選んでください。") Config.aa6 = false Config.aa13 = false return end end
        local function aa31(aa32, aa33, aa34) return aa32:FindFirstChild(aa33) or aa32:WaitForChild(aa33, aa34 or 5) end
        local function aa35(aa36) if aa36 and aa36:IsA("BasePart") then SetNetworkOwner:FireServer(aa36, aa36.CFrame) task.wait() end end
        local function aa37(aa38, aa39) return aa38:FindFirstChild(aa39) ~= nil end
        local function aa40(aa41)
            local aa42 = GetCharacter() if not aa42 then return nil end local aa43 = aa42:WaitForChild("HumanoidRootPart") local waitCount = 0
            while (LocalPlayer.InPlot.Value and not LocalPlayer.InOwnedPlot.Value) and waitCount < 50 do task.wait(0.1) waitCount = waitCount + 1 end waitCount = 0
            while not LocalPlayer.CanSpawnToy.Value and waitCount < 50 do task.wait(0.1) waitCount = waitCount + 1 end
            local aa44 = aa43.CFrame * CFrame.new(0, 14, 20) local aa45 = workspace:FindFirstChild(LocalPlayer.Name.."SpawnedInToys")
            if not aa45 then aa45 = workspace:FindFirstChild("PlotItems") if aa45 then aa45 = aa45:FindFirstChild("Plot1") end end if not aa45 then aa45 = workspace end
            local aa46 = nil local aa47 = aa45.ChildAdded:Connect(function(aa48) if aa48.Name == aa41 then aa46 = aa48 end end)
            task.spawn(function() pcall(function() spawntoy(aa41, aa44, Vector3.zero) end) end)
            local aa49 = tick() repeat task.wait(0.05) until aa46 or (tick() - aa49) > 5 aa47:Disconnect() return aa46
        end
        local function aa50()
            if Config.aa17 then return nil end Config.aa17 = true local aa51 = aa40("PalletLightBrown")
            if not aa51 then Config.aa17 = false return nil end local aa52 = aa31(aa51, "SoundPart", 3) if not aa52 then aa51:Destroy() Config.aa17 = false return nil end
            local retryCount = 0 while retryCount < 10 do if not Config.aa13 then aa51:Destroy() Config.aa17 = false return nil end aa35(aa52) task.wait() if aa37(aa52, "PartOwner") then break end retryCount = retryCount + 1 end
            if not aa37(aa52, "PartOwner") then aa51:Destroy() Config.aa17 = false return nil end
            for _, aa54 in pairs(aa51:GetDescendants()) do if aa54:IsA("BasePart") then aa54.CanCollide = false aa54.Transparency = 0.8 end end
            aa51.Name = "RagdollPalete" local aa55 = Instance.new("BodyVelocity") aa55.MaxForce = Vector3.new(0, math.huge, 0) aa55.Velocity = Vector3.new(0, 900, 0) aa55.Parent = aa52 Config.aa17 = false return aa51
        end
        local function aa25(aa26, aa27)
            if not aa26.Character then return end local aa28 = aa26.Character:FindFirstChild("HumanoidRootPart") if not aa28 or not aa27 then return end
            local aa29 = aa27.CFrame aa27.CFrame = aa28.CFrame * CFrame.new(0, 0, 2) for aa30 = 1, 15 do SetNetworkOwner:FireServer(aa28, aa28.CFrame) task.wait() end aa27.CFrame = aa29
        end
        local function startLagSpam()
            if Config.running then return end if not Config.PlayerList or #Config.PlayerList == 0 then return end if not CreateGrabLine then CreateGrabLine = GrabEvents:WaitForChild("CreateGrabLine", 3) if not CreateGrabLine then return end end
            Config.running = true task.spawn(function() while Config.running do local spawnLocation = service.Workspace:FindFirstChild("SpawnLocation") or service.Workspace:FindFirstChild("Spawn") or (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")) if spawnLocation then CreateGrabLine:FireServer(spawnLocation, CFrame.new(math.random(-2010000000, 2000000001), 0, math.random(-2008100000, 2000200000))) end task.wait(0.001) end end)
        end
        local function stopLagSpam() if not Config.running then return end Config.running = false end
        if aa61 then if not Config.PlayerList or #Config.PlayerList == 0 then return end task.wait(0.5) task.defer(function() startLagSpam() end) else stopLagSpam() end
        if Config.aa6 then
            task.spawn(function()
                while Config.aa6 do local targets = type(Config.PlayerList) == "table" and Config.PlayerList or {Config.PlayerList}
                    for _, targetName in ipairs(targets) do local aa62 = service.Players:FindFirstChild(targetName) local aa63 = LocalPlayer.Character local aa64 = aa63 and aa63:FindFirstChild("HumanoidRootPart")
                        if aa62 and aa64 then local aa65 = aa62.Character local aa66 = aa65 and aa65:FindFirstChild("HumanoidRootPart")
                            if aa66 then local aa67 = (aa64.Position - aa66.Position).Magnitude if aa67 > Config.aa9 then aa25(aa62, aa64) end
                                SetNetworkOwner:FireServer(aa66, aa66.CFrame) if DestroyGrabLine then DestroyGrabLine:FireServer(aa66) end aa66.AssemblyLinearVelocity = Vector3.zero aa66.AssemblyAngularVelocity = Vector3.zero
                                local aa68 = aa66:FindFirstChild("ControlBP") if not aa68 then aa68 = Instance.new("BodyPosition") aa68.Name = "ControlBP" aa68.MaxForce = Vector3.new(math.huge, math.huge, math.huge) aa68.P = 800000 aa68.Parent = aa66 end
                                aa68.Position = aa64.Position + Vector3.new(0, 15, 0)
                            end
                        end
                    end task.wait(0.001)
                end
                local targets = type(Config.PlayerList) == "table" and Config.PlayerList or {Config.PlayerList}
                for _, targetName in ipairs(targets) do local aa69 = service.Players:FindFirstChild(targetName) if aa69 and aa69.Character then local aa70 = aa69.Character:FindFirstChild("HumanoidRootPart") if aa70 and aa70:FindFirstChild("ControlBP") then aa70.ControlBP:Destroy() end end end
            end)
        end
        if aa61 then
            local aa71 = workspace:FindFirstChild(LocalPlayer.Name.."SpawnedInToys") local aa72 = nil
            Config.aa73 = service.RunService.RenderStepped:Connect(function()
                if not Config.aa13 then return end if not Config.PlayerList or #Config.PlayerList == 0 then return end
                local targets = type(Config.PlayerList) == "table" and Config.PlayerList or {Config.PlayerList} local targetName = targets[1] if not targetName then return end
                local aa74 = service.Players:FindFirstChild(targetName) if not aa74 or not aa74.Character then return end local aa75 = aa74.Character:FindFirstChild("HumanoidRootPart") local aa76 = aa74.Character:FindFirstChild("Humanoid") if not aa75 or not aa76 then return end
                if aa72 and aa72:IsDescendantOf(workspace) then local aa77 = aa72:FindFirstChild("SoundPart") if aa77 then if not aa37(aa77, "PartOwner") then aa72:Destroy() aa72 = nil end else aa72:Destroy() aa72 = nil end end
                if not Config.aa17 and (not aa72 or not aa72:IsDescendantOf(workspace)) then aa72 = aa71 and aa71:FindFirstChild("RagdollPalete") or aa50() end
                if aa72 and aa72:FindFirstChild("SoundPart") then local aa78 = aa76:FindFirstChild("Ragdolled") if aa78 and not aa78.Value then aa72.SoundPart.Position = aa75.Position end end
            end)
        else if Config.aa73 then Config.aa73:Disconnect() Config.aa73 = nil end end
    end
})

PlankRight:AddSlider("PalletDist", {
	Text = "パレットの距離",
	Default = 25, Min = 5, Max = 100, Rounding = 0,
	Callback = function(v) Config.aa9 = v end
})

-- ========== 三人称 ==========
local CamGroup = Tabs.Cam:AddLeftGroupbox("カメラ")
CamGroup:AddToggle("ThirdPerson", {
	Text = "三人称視点 (Third Person)",
	Default = false,
	Callback = function(Value)
		local char = LocalPlayer.Character
		if Value then
			LocalPlayer.CameraMode = Enum.CameraMode.Classic
			if char then
				local hum = char:FindFirstChildOfClass("Humanoid")
				if hum then workspace.CurrentCamera.CameraSubject = hum end
			end
			LocalPlayer.CameraMaxZoomDistance = 1000
			LocalPlayer.CameraMinZoomDistance = 0.5
		else
			LocalPlayer.CameraMode = Enum.CameraMode.LockFirstPerson
			if char then
				local hum = char:FindFirstChildOfClass("Humanoid")
				if hum then workspace.CurrentCamera.CameraSubject = hum end
			end
			LocalPlayer.CameraMaxZoomDistance = 0
			LocalPlayer.CameraMinZoomDistance = 0
		end
	end
})

-- ========== キックテクスチャ ==========
local TexLeft = Tabs.Texture:AddLeftGroupbox("テクスチャ")
local TexRight = Tabs.Texture:AddRightGroupbox("サイズ")

TexLeft:AddToggle("KickTexture", {
	Text = "HYPER BITE KICK (口のアニメーション)",
	Default = false,
	Callback = function(Value)
		TextureConfig.Enabled = Value
		if Value then StartTextureSystem() JapanNotify("HYPER BITE を有効にしました。")
		else StopTextureSystem() JapanNotify("HYPER BITE を無効にしました。") end
	end
})

TexLeft:AddToggle("CosmicTexture", {
	Text = "Cosmic Blackhole (EternityHoleモデル)",
	Default = false,
	Callback = function(Value)
		CosmicBlackhole.Enabled = Value
		if Value then
			StartCosmicSystem()
			for _, obj in ipairs(Workspace:GetChildren()) do
				if obj.Name:lower():find("blackhole") then BuildCosmic(obj) end
			end
			JapanNotify("Cosmic Blackhole を有効にしました。")
		else
			StopCosmicSystem()
			JapanNotify("Cosmic Blackhole を無効にしました。")
		end
	end
})

TexRight:AddSlider("TextureSize", {
	Text = "口のサイズ (HYPER BITE用)",
	Default = 45, Min = 10, Max = 200, Rounding = 0,
	Callback = function(v) TextureConfig.Size = v end
})

-- ========== プロット破壊 ==========
local PlotGroup = Tabs.Plot:AddLeftGroupbox("破壊")
PlotGroup:AddButton({
	Text = "全プロット破壊 (Plot 1-5)",
	Func = function()
        local inv = workspace:FindFirstChild(LocalPlayer.Name .. "SpawnedInToys")
        if not inv then JapanNotify("インベントリが見つかりません") return end
        local currentHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not currentHRP then JapanNotify("HumanoidRootPartが見つかりません") return end
        JapanNotify("プロット破壊を開始します")
        task.spawn(function()
            for i = 1, 5 do
                local shur = nil
                local conn = inv.ChildAdded:Connect(function(child) if child.Name == "NinjaShuriken" then shur = child conn:Disconnect() end end)
                ReplicatedStorage.MenuToys.SpawnToyRemoteFunction:InvokeServer("NinjaShuriken", currentHRP.CFrame * CFrame.new(5, 8, 20), Vector3.new(0, 0, 0))
                local startTime = tick()
                repeat if shur and shur:FindFirstChild("StickyPart") and shur:FindFirstChild("SoundPart") then break end task.wait(0.01) until tick() - startTime > 0.5
                shur = shur or inv:FindFirstChild("NinjaShuriken")
                if shur then
                    local soundPart = shur:FindFirstChild("SoundPart") local stickyPart = shur:FindFirstChild("StickyPart")
                    if soundPart and stickyPart then
                        local setOwner = ReplicatedStorage:WaitForChild("GrabEvents"):WaitForChild("SetNetworkOwner")
                        for j = 1, 15 do setOwner:FireServer(soundPart, soundPart.CFrame) if soundPart:FindFirstChild("PartOwner") and soundPart.PartOwner.Value == LocalPlayer.Name then break end end
                        for _, obj in pairs(shur:GetChildren()) do if obj:IsA("BasePart") then obj.CanTouch = false obj.CanCollide = false obj.Transparency = 1 end end
                        shur.Name = "Noclipped"
                        local plot = workspace.Plots:FindFirstChild("Plot" .. i)
                        if plot then local plotArea = plot:FindFirstChild("PlotArea") if plotArea then ReplicatedStorage.PlayerEvents.StickyPartEvent:FireServer(stickyPart, plotArea, CFrame.new(1e12, 1e12, 1e12)) end end
                    end
                end
                task.wait(0.1)
            end
            JapanNotify("プロット破壊 完了")
        end)
    end
})

-- ========== 防御 ==========
local DefLeft = Tabs.Defense:AddLeftGroupbox("アンチ系")
local DefRight = Tabs.Defense:AddRightGroupbox("自動系")

DefLeft:AddToggle("AntiGrab", { Text = "アンチグラブ", Default = false, Callback = ToggleAntiGrab })
DefLeft:AddToggle("AntiBurn", { Text = "アンチバーン", Default = false, Callback = ToggleAntiBurn })
DefLeft:AddToggle("AntiExplosion", { Text = "アンチエクスプロージョン", Default = false, Callback = ToggleAntiExplosion })
DefLeft:AddToggle("AntiBananaSit", { Text = "アンチバナナ", Default = false, Callback = ToggleAntiBananaSit })
DefLeft:AddToggle("AntiSticky", { Text = "アンチスティッキー", Default = false, Callback = ToggleAntiSticky })
DefLeft:AddToggle("AntiPaint", { Text = "アンチペイント", Default = false, Callback = ToggleAntiPaint })
DefLeft:AddToggle("AntiAFK", { Text = "アンチAFK", Default = false, Callback = ToggleAntiAFK })
DefLeft:AddToggle("AntiVoid", { Text = "アンチヴォイド", Default = false, Callback = ToggleAntiVoid })
DefLeft:AddToggle("AntiRagdoll", { Text = "アンチラグドール", Default = false, Callback = ToggleAntiRagdoll })
DefLeft:AddToggle("AntiWater", { Text = "アンチウォーター", Default = false, Callback = ToggleAntiWater })
DefLeft:AddToggle("AntiInputLag", { Text = "アンチインプットラグ", Default = false, Callback = ToggleAntiInputLag })
DefLeft:AddToggle("AntiKickGrab", { Text = "アンチキック (グラブ)", Default = false, Callback = ToggleAntiKickGrab })
DefLeft:AddToggle("AntiKickV2", { Text = "アンチキック (手裏剣)", Default = false, Callback = ToggleAntiKickV2 })
DefLeft:AddToggle("AntiLag", { Text = "アンチラグ", Default = false, Callback = ToggleAntiLag })

DefRight:AddToggle("AutoRespawn", {
	Text = "自動リスポーン", Default = false,
	Callback = function(val) ToggleAutoRespawn(val, "Spawn") end
})
DefRight:AddToggle("AutoAttacker", {
	Text = "オートアタッカー", Default = false,
	Callback = function(val) ToggleAutoAttacker(val, "Death") end
})
DefRight:AddDropdown("AttackerMode", {
	Text = "反撃モード",
	Values = {"Death", "Knockback", "airSuspend", "Freeze"},
	Default = 1,
	Callback = function(option) Defense.AttackerMode = option end
})

-- ========== プレイヤー ==========
local PlayerLeft = Tabs.Player:AddLeftGroupbox("操作")
local PlayerRight = Tabs.Player:AddRightGroupbox("テレポート")
local SelectedPlayerName = nil

local function GetPlayerList()
	local list = {}
	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= LocalPlayer then table.insert(list, p.DisplayName .. " (@" .. p.Name .. ")") end
	end
	table.sort(list)
	return list
end

local function ResolvePlayer(display)
	for _, p in ipairs(Players:GetPlayers()) do
		if (p.DisplayName .. " (@" .. p.Name .. ")") == display then return p end
	end
end

local PlayerDropdown = PlayerLeft:AddDropdown("PlayerSelect", {
	Text = "プレイヤーを選択", Values = GetPlayerList(), Default = 1,
	Callback = function(v)
		local p = ResolvePlayer(v)
		SelectedPlayerName = p and p.Name or nil
	end
})

PlayerLeft:AddButton({
	Text = "リスト更新",
	Func = function() PlayerDropdown:SetValues(GetPlayerList()) JapanNotify("更新しました") end
})

PlayerLeft:AddButton({
	Text = "選択プレイヤーにTP",
	Func = function()
		local p = SelectedPlayerName and Players:FindFirstChild(SelectedPlayerName)
		local a = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
		local b = p and p.Character and p.Character:FindFirstChild("HumanoidRootPart")
		if a and b then a.CFrame = b.CFrame * CFrame.new(0,0,3) JapanNotify("TP完了") else JapanNotify("失敗") end
	end
})

PlayerLeft:AddButton({
	Text = "観戦",
	Func = function()
		local p = SelectedPlayerName and Players:FindFirstChild(SelectedPlayerName)
		local hum = p and p.Character and p.Character:FindFirstChildOfClass("Humanoid")
		if hum then workspace.CurrentCamera.CameraSubject = hum JapanNotify("観戦中") end
	end
})

PlayerLeft:AddButton({
	Text = "観戦解除",
	Func = function()
		local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
		if hum then workspace.CurrentCamera.CameraSubject = hum end
	end
})

PlayerRight:AddButton({
	Text = "スポーンへTP",
	Func = function()
		local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
		local spawn = Workspace:FindFirstChild("SpawnLocation") or Workspace:FindFirstChild("Spawn")
		if hrp then hrp.CFrame = spawn and (spawn.CFrame + Vector3.new(0,5,0)) or CFrame.new(0,10,0) end
	end
})

PlayerRight:AddButton({
	Text = "一番近いプレイヤーにTP",
	Func = function()
		local my = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
		if not my then return end
		local best, dist = nil, math.huge
		for _, p in ipairs(Players:GetPlayers()) do
			if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
				local d = (p.Character.HumanoidRootPart.Position - my.Position).Magnitude
				if d < dist then dist, best = d, p end
			end
		end
		if best then my.CFrame = best.Character.HumanoidRootPart.CFrame * CFrame.new(0,0,3) end
	end
})

PlayerRight:AddToggle("ClickTP", {
	Text = "Ctrl+クリックTP",
	Default = false,
	Callback = function(v)
		if _G.JapanClickTP then _G.JapanClickTP:Disconnect() _G.JapanClickTP = nil end
		if v then
			_G.JapanClickTP = game:GetService("UserInputService").InputBegan:Connect(function(input, gpe)
				if gpe then return end
				if input.UserInputType == Enum.UserInputType.MouseButton1 and game:GetService("UserInputService"):IsKeyDown(Enum.KeyCode.LeftControl) then
					local mouse = LocalPlayer:GetMouse()
					local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
					if hrp and mouse.Hit then hrp.CFrame = CFrame.new(mouse.Hit.Position + Vector3.new(0,3,0)) end
				end
			end)
		end
	end
})

-- ========== 移動 ==========
local MoveLeft = Tabs.Movement:AddLeftGroupbox("速度")
local MoveRight = Tabs.Movement:AddRightGroupbox("特殊")
local WalkSpeedValue, JumpPowerValue, FlightSpeed = 16, 50, 50

MoveLeft:AddSlider("WalkSpeed", {
	Text = "歩行速度", Default = 16, Min = 16, Max = 200, Rounding = 0,
	Callback = function(v)
		WalkSpeedValue = v
		local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
		if hum then hum.WalkSpeed = v end
	end
})

MoveLeft:AddToggle("SpeedLoop", {
	Text = "速度を常時適用", Default = false,
	Callback = function(v)
		if _G.JapanSpeedLoop then _G.JapanSpeedLoop:Disconnect() _G.JapanSpeedLoop = nil end
		if v then
			_G.JapanSpeedLoop = RunService.Heartbeat:Connect(function()
				local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
				if hum then hum.WalkSpeed = WalkSpeedValue end
			end)
		end
	end
})

MoveLeft:AddSlider("JumpPower", {
	Text = "ジャンプ力", Default = 50, Min = 50, Max = 300, Rounding = 0,
	Callback = function(v)
		JumpPowerValue = v
		local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
		if hum then hum.UseJumpPower = true hum.JumpPower = v end
	end
})

MoveLeft:AddToggle("JumpLoop", {
	Text = "ジャンプ力を常時適用", Default = false,
	Callback = function(v)
		if _G.JapanJumpLoop then _G.JapanJumpLoop:Disconnect() _G.JapanJumpLoop = nil end
		if v then
			_G.JapanJumpLoop = RunService.Heartbeat:Connect(function()
				local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
				if hum then hum.UseJumpPower = true hum.JumpPower = JumpPowerValue end
			end)
		end
	end
})

MoveLeft:AddToggle("InfiniteJump", {
	Text = "無限ジャンプ", Default = false,
	Callback = function(v)
		if _G.JapanInfJump then _G.JapanInfJump:Disconnect() _G.JapanInfJump = nil end
		if v then
			_G.JapanInfJump = game:GetService("UserInputService").JumpRequest:Connect(function()
				local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
				if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
			end)
		end
	end
})

MoveRight:AddToggle("Noclip", {
	Text = "ノークリップ", Default = false,
	Callback = function(v)
		if _G.JapanNoclip then _G.JapanNoclip:Disconnect() _G.JapanNoclip = nil end
		if v then
			_G.JapanNoclip = RunService.Stepped:Connect(function()
				local char = LocalPlayer.Character
				if not char then return end
				for _, part in ipairs(char:GetDescendants()) do
					if part:IsA("BasePart") then part.CanCollide = false end
				end
			end)
		end
	end
})

MoveRight:AddSlider("FlySpeed", {
	Text = "飛行速度", Default = 50, Min = 10, Max = 200, Rounding = 0,
	Callback = function(v) FlightSpeed = v end
})

MoveRight:AddToggle("Fly", {
	Text = "飛行 (Fly)", Default = false,
	Callback = function(v)
		if _G.JapanFly then _G.JapanFly:Disconnect() _G.JapanFly = nil end
		local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
		if not v then
			if hrp then
				local bv = hrp:FindFirstChild("JapanFlyBV") if bv then bv:Destroy() end
				local bg = hrp:FindFirstChild("JapanFlyBG") if bg then bg:Destroy() end
			end
			return
		end
		if not hrp then return end
		local bv = Instance.new("BodyVelocity")
		bv.Name = "JapanFlyBV" bv.MaxForce = Vector3.new(9e9,9e9,9e9) bv.Velocity = Vector3.zero bv.Parent = hrp
		local bg = Instance.new("BodyGyro")
		bg.Name = "JapanFlyBG" bg.MaxTorque = Vector3.new(9e9,9e9,9e9) bg.P = 9e4 bg.Parent = hrp
		local cam = workspace.CurrentCamera
		local UIS = game:GetService("UserInputService")
		_G.JapanFly = RunService.RenderStepped:Connect(function()
			if not hrp or not hrp.Parent then return end
			bg.CFrame = cam.CFrame
			local dir = Vector3.zero
			if UIS:IsKeyDown(Enum.KeyCode.W) then dir = dir + cam.CFrame.LookVector end
			if UIS:IsKeyDown(Enum.KeyCode.S) then dir = dir - cam.CFrame.LookVector end
			if UIS:IsKeyDown(Enum.KeyCode.A) then dir = dir - cam.CFrame.RightVector end
			if UIS:IsKeyDown(Enum.KeyCode.D) then dir = dir + cam.CFrame.RightVector end
			if UIS:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0,1,0) end
			if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then dir = dir - Vector3.new(0,1,0) end
			if dir.Magnitude > 0 then dir = dir.Unit end
			bv.Velocity = dir * FlightSpeed
		end)
	end
})

MoveRight:AddButton({
	Text = "上にワープ +50",
	Func = function()
		local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
		if hrp then hrp.CFrame = hrp.CFrame + Vector3.new(0,50,0) end
	end
})

-- ========== ビジュアル ==========
local VisLeft = Tabs.Visual:AddLeftGroupbox("ESP")
local VisRight = Tabs.Visual:AddRightGroupbox("画面")
local ESPEnabled, ESPObjects = false, {}

local function ClearESP()
	for _, obj in pairs(ESPObjects) do
		if type(obj) == "table" then for _, o in pairs(obj) do pcall(function() o:Destroy() end) end
		else pcall(function() obj:Destroy() end) end
	end
	table.clear(ESPObjects)
end

local function CreateESP(player)
	if player == LocalPlayer or ESPObjects[player] then return end
	local char = player.Character
	if not char then return end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return end
	local hl = Instance.new("Highlight")
	hl.Adornee = char hl.FillColor = Color3.fromRGB(0,255,150) hl.OutlineColor = Color3.new(1,1,1)
	hl.FillTransparency = 0.6 hl.Parent = char
	local bb = Instance.new("BillboardGui")
	bb.Adornee = hrp bb.Size = UDim2.new(0,200,0,40) bb.StudsOffset = Vector3.new(0,3,0) bb.AlwaysOnTop = true bb.Parent = hrp
	local lb = Instance.new("TextLabel")
	lb.Size = UDim2.new(1,0,1,0) lb.BackgroundTransparency = 1
	lb.Text = player.DisplayName .. "\n@" .. player.Name
	lb.TextColor3 = Color3.fromRGB(0,255,150) lb.TextStrokeTransparency = 0.3
	lb.Font = Enum.Font.GothamBold lb.TextSize = 14 lb.Parent = bb
	ESPObjects[player] = {hl, bb}
end

VisLeft:AddToggle("ESP", {
	Text = "プレイヤーESP", Default = false,
	Callback = function(v)
		ESPEnabled = v
		ClearESP()
		if _G.JapanESPConn then _G.JapanESPConn:Disconnect() _G.JapanESPConn = nil end
		if v then
			for _, p in ipairs(Players:GetPlayers()) do CreateESP(p) end
			_G.JapanESPConn = Players.PlayerAdded:Connect(function(p)
				p.CharacterAdded:Connect(function() task.wait(1) if ESPEnabled then CreateESP(p) end end)
			end)
			for _, p in ipairs(Players:GetPlayers()) do
				if p ~= LocalPlayer then
					p.CharacterAdded:Connect(function() task.wait(1) if ESPEnabled then CreateESP(p) end end)
				end
			end
		end
	end
})

VisRight:AddSlider("FOV", {
	Text = "FOV", Default = 70, Min = 30, Max = 120, Rounding = 0,
	Callback = function(v) workspace.CurrentCamera.FieldOfView = v end
})

VisRight:AddToggle("Fullbright", {
	Text = "フルブライト", Default = false,
	Callback = function(v)
		local lighting = game:GetService("Lighting")
		if v then
			_G.JapanFB = {Brightness=lighting.Brightness, ClockTime=lighting.ClockTime, FogEnd=lighting.FogEnd, GlobalShadows=lighting.GlobalShadows, Ambient=lighting.Ambient}
			lighting.Brightness = 2 lighting.ClockTime = 14 lighting.FogEnd = 1e5 lighting.GlobalShadows = false lighting.Ambient = Color3.new(1,1,1)
		elseif _G.JapanFB then
			lighting.Brightness = _G.JapanFB.Brightness lighting.ClockTime = _G.JapanFB.ClockTime
			lighting.FogEnd = _G.JapanFB.FogEnd lighting.GlobalShadows = _G.JapanFB.GlobalShadows lighting.Ambient = _G.JapanFB.Ambient
		end
	end
})

VisRight:AddToggle("NoFog", {
	Text = "霧削除", Default = false,
	Callback = function(v)
		local lighting = game:GetService("Lighting")
		if v then _G.JapanFog = lighting.FogEnd lighting.FogEnd = 1e6
		elseif _G.JapanFog then lighting.FogEnd = _G.JapanFog end
	end
})

-- ========== トロール ==========
local TrollLeft = Tabs.Troll:AddLeftGroupbox("アクション")
local TrollRight = Tabs.Troll:AddRightGroupbox("チャット")

TrollLeft:AddButton({
	Text = "選択プレイヤーをFling",
	Func = function()
		local p = SelectedPlayerName and Players:FindFirstChild(SelectedPlayerName)
		local my = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
		local th = p and p.Character and p.Character:FindFirstChild("HumanoidRootPart")
		if not my or not th then JapanNotify("失敗") return end
		local bv = Instance.new("BodyAngularVelocity")
		bv.MaxTorque = Vector3.new(0, math.huge, 0) bv.AngularVelocity = Vector3.new(0, 9e5, 0) bv.Parent = my
		local t0 = tick()
		local c
		c = RunService.Heartbeat:Connect(function()
			if tick()-t0 > 3 then c:Disconnect() bv:Destroy() return end
			if th and th.Parent then my.CFrame = th.CFrame end
		end)
	end
})

TrollLeft:AddToggle("Spin", {
	Text = "高速スピン", Default = false,
	Callback = function(v)
		local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
		if _G.JapanSpin then _G.JapanSpin:Destroy() _G.JapanSpin = nil end
		if v and hrp then
			local bv = Instance.new("BodyAngularVelocity")
			bv.Name = "JapanSpin" bv.MaxTorque = Vector3.new(0,math.huge,0) bv.AngularVelocity = Vector3.new(0,50,0) bv.Parent = hrp
			_G.JapanSpin = bv
		end
	end
})

local ChatSpamOn, ChatSpamText, ChatSpamDelay = false, "Japan HUB", 1.5
TrollRight:AddInput("ChatText", {
	Text = "スパム文言", Default = "Japan HUB", Finished = true,
	Callback = function(v) ChatSpamText = v end
})
TrollRight:AddSlider("ChatDelay", {
	Text = "間隔(秒)", Default = 1.5, Min = 0.5, Max = 5, Rounding = 1,
	Callback = function(v) ChatSpamDelay = v end
})
TrollRight:AddToggle("ChatSpam", {
	Text = "チャットスパム", Default = false,
	Callback = function(v)
		ChatSpamOn = v
		if not v then return end
		task.spawn(function()
			while ChatSpamOn do
				pcall(function()
					local chat = game:GetService("TextChatService")
					local ch = chat.TextChannels and (chat.TextChannels.RBXGeneral or chat.TextChannels:FindFirstChildWhichIsA("TextChannel"))
					if ch then ch:SendAsync(ChatSpamText)
					else
						local re = game:GetService("ReplicatedStorage"):FindFirstChild("DefaultChatSystemChatEvents")
						if re then re.SayMessageRequest:FireServer(ChatSpamText, "All") end
					end
				end)
				task.wait(ChatSpamDelay)
			end
		end)
	end
})

-- ========== サーバー ==========
local SrvLeft = Tabs.Server:AddLeftGroupbox("操作")
local SrvRight = Tabs.Server:AddRightGroupbox("情報")

SrvLeft:AddButton({
	Text = "再参加 (Rejoin)",
	Func = function()
		game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
	end
})
SrvLeft:AddButton({
	Text = "サーバーホップ",
	Func = function()
		local ts = game:GetService("TeleportService")
		local http = game:GetService("HttpService")
		local ok, result = pcall(function()
			return http:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100"))
		end)
		if ok and result and result.data then
			for _, s in ipairs(result.data) do
				if s.id ~= game.JobId and s.playing < s.maxPlayers then
					ts:TeleportToPlaceInstance(game.PlaceId, s.id, LocalPlayer) return
				end
			end
		end
		JapanNotify("空きサーバーなし")
	end
})
SrvLeft:AddButton({
	Text = "JobIdコピー",
	Func = function()
		if setclipboard then setclipboard(game.JobId) JapanNotify("コピーした") else JapanNotify(tostring(game.JobId)) end
	end
})
SrvRight:AddButton({
	Text = "プレイヤー数",
	Func = function() JapanNotify(#Players:GetPlayers().." 人") end
})
SrvRight:AddButton({
	Text = "自分の情報",
	Func = function() JapanNotify(LocalPlayer.Name.." / "..LocalPlayer.UserId) end
})

-- ========== ユーティリティ ==========
local UtilLeft = Tabs.Utility:AddLeftGroupbox("キャラ")
local UtilRight = Tabs.Utility:AddRightGroupbox("便利")

UtilLeft:AddButton({
	Text = "リセット",
	Func = function()
		local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
		if hum then hum.Health = 0 end
	end
})
UtilLeft:AddToggle("AntiSit", {
	Text = "アンチシート", Default = false,
	Callback = function(v)
		if _G.JapanAntiSit then _G.JapanAntiSit:Disconnect() _G.JapanAntiSit = nil end
		if v then
			_G.JapanAntiSit = RunService.Heartbeat:Connect(function()
				local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
				if hum and hum.Sit then hum.Sit = false end
			end)
		end
	end
})
UtilLeft:AddToggle("GodTry", {
	Text = "GodMode試行", Default = false,
	Callback = function(v)
		if _G.JapanGod then _G.JapanGod:Disconnect() _G.JapanGod = nil end
		if v then
			_G.JapanGod = RunService.Heartbeat:Connect(function()
				local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
				if hum and hum.Health < hum.MaxHealth then hum.Health = hum.MaxHealth end
			end)
		end
	end
})
UtilLeft:AddToggle("FPSBoost", {
	Text = "軽量化", Default = false,
	Callback = function(v)
		local lighting = game:GetService("Lighting")
		if v then
			lighting.GlobalShadows = false
			pcall(function() settings().Rendering.QualityLevel = Enum.QualityLevel.Level01 end)
			for _, o in ipairs(Workspace:GetDescendants()) do
				if o:IsA("ParticleEmitter") or o:IsA("Trail") or o:IsA("Smoke") or o:IsA("Fire") then o.Enabled = false end
			end
		end
	end
})

UtilRight:AddButton({
	Text = "座標コピー",
	Func = function()
		local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
		if not hrp then return end
		local s = string.format("%.1f, %.1f, %.1f", hrp.Position.X, hrp.Position.Y, hrp.Position.Z)
		if setclipboard then setclipboard(s) end
		JapanNotify(s)
	end
})
UtilRight:AddButton({
	Text = "自分のToy全削除",
	Func = function()
		local inv = Workspace:FindFirstChild(LocalPlayer.Name.."SpawnedInToys")
		if not inv then JapanNotify("なし") return end
		local n = 0
		for _, c in ipairs(inv:GetChildren()) do
			pcall(function() if DestroyToy then DestroyToy:FireServer(c) end c:Destroy() end)
			n = n + 1
		end
		JapanNotify(n.." 削除")
	end
})
UtilRight:AddToggle("FreezeSelf", {
	Text = "自分を固定", Default = false,
	Callback = function(v)
		local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
		if hrp then hrp.Anchored = v end
	end
})


-- ========== Katsura由来 拡張機能 ==========
local KatDef = Tabs.Katsura:AddLeftGroupbox("防御拡張")
local KatAtk = Tabs.Katsura:AddRightGroupbox("攻撃・ツール")
local KatMove = Tabs.Katsura:AddLeftGroupbox("移動拡張")
local KatVis = Tabs.Katsura:AddRightGroupbox("視覚・その他")

-- Anti Blobman
local antiBlobOn = false
KatDef:AddToggle("KatAntiBlob", {
	Text = "Anti Blobman",
	Default = false,
	Callback = function(on)
		antiBlobOn = on
		if on then
			if not _G.JapanAntiBlobConn then
				_G.JapanAntiBlobConn = Workspace.DescendantAdded:Connect(function(toy)
					if toy.Name == "CreatureBlobman" and antiBlobOn then
						pcall(function()
							if toy:FindFirstChild("LeftDetector") then toy.LeftDetector:Destroy() end
							if toy:FindFirstChild("RightDetector") then toy.RightDetector:Destroy() end
						end)
					end
				end)
			end
			-- clean existing
			for _, toy in ipairs(Workspace:GetDescendants()) do
				if toy.Name == "CreatureBlobman" then
					pcall(function()
						if toy:FindFirstChild("LeftDetector") then toy.LeftDetector:Destroy() end
						if toy:FindFirstChild("RightDetector") then toy.RightDetector:Destroy() end
					end)
				end
			end
		end
	end
})

-- Anti Fling
local antiFlingOn = false
KatDef:AddToggle("KatAntiFling", {
	Text = "Anti Fling",
	Default = false,
	Callback = function(Value)
		antiFlingOn = Value
		if _G.JapanAntiFlingConn then _G.JapanAntiFlingConn:Disconnect() _G.JapanAntiFlingConn = nil end
		if not Value then return end
		_G.JapanAntiFlingConn = RunService.Stepped:Connect(function()
			if not antiFlingOn then return end
			local char = LocalPlayer.Character
			if not char then return end
			local root = char:FindFirstChild("HumanoidRootPart")
			if not root then return end
			if root.AssemblyLinearVelocity.Magnitude > 250 or root.AssemblyAngularVelocity.Magnitude > 250 then
				root.AssemblyLinearVelocity = Vector3.zero
				root.AssemblyAngularVelocity = Vector3.zero
			end
			for _, part in pairs(char:GetDescendants()) do
				if part:IsA("BasePart") then
					pcall(function()
						part.CustomPhysicalProperties = PhysicalProperties.new(0.7, 0.3, 0, 1, 1)
					end)
				end
			end
		end)
	end
})

-- Better Anti Grab (IsHeld freeze style)
local BeingHeld = LocalPlayer:FindFirstChild("IsHeld") or LocalPlayer:WaitForChild("IsHeld", 5)
local StruggleEvent = CharacterEvents:FindFirstChild("Struggle")
KatDef:AddToggle("KatAntiGrabPlus", {
	Text = "Anti Grab+ (強化)",
	Default = false,
	Callback = function(Value)
		if _G.JapanAGPlus then _G.JapanAGPlus:Disconnect() _G.JapanAGPlus = nil end
		if not Value then return end
		local savedCF, wasFrozen = nil, false
		_G.JapanAGPlus = RunService.Heartbeat:Connect(function()
			local c = LocalPlayer.Character
			if not c then return end
			local root = c:FindFirstChild("HumanoidRootPart")
			local hum = c:FindFirstChildOfClass("Humanoid")
			if not root or not hum then return end
			local isHeld = BeingHeld and BeingHeld.Value
			if isHeld then
				if not wasFrozen then savedCF = root.CFrame wasFrozen = true end
				hum.Sit = false
				hum.PlatformStand = false
				hum:SetStateEnabled(Enum.HumanoidStateType.GettingUp, true)
				hum:ChangeState(Enum.HumanoidStateType.GettingUp)
				if savedCF then root.CFrame = savedCF end
				root.AssemblyLinearVelocity = Vector3.zero
				root.AssemblyAngularVelocity = Vector3.zero
				pcall(function()
					if StruggleEvent then StruggleEvent:FireServer(LocalPlayer) end
					local ge = ReplicatedStorage:FindFirstChild("GameCorrectionEvents")
					if ge and ge:FindFirstChild("StopAllVelocity") then
						ge.StopAllVelocity:FireServer()
					end
				end)
			else
				if wasFrozen then
					wasFrozen = false
					savedCF = nil
					for _, part in pairs(c:GetChildren()) do
						if part:IsA("BasePart") then part.Anchored = false end
					end
				end
			end
		end)
	end
})

-- Walk on water
local walkOnWaterActive, waterPlatform = false, nil
KatMove:AddToggle("KatWalkWater", {
	Text = "水上歩行 (Walk On Water)",
	Default = false,
	Callback = function(Value)
		walkOnWaterActive = Value
		if Value then
			task.spawn(function()
				waterPlatform = Instance.new("Part")
				waterPlatform.Name = "JapanWaterWalk"
				waterPlatform.Size = Vector3.new(6, 1, 6)
				waterPlatform.Anchored = true
				waterPlatform.CanCollide = true
				waterPlatform.Transparency = 1
				waterPlatform.Parent = Workspace
				while walkOnWaterActive do
					local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
					if hrp and waterPlatform then
						waterPlatform.Position = Vector3.new(hrp.Position.X, hrp.Position.Y - 3.5, hrp.Position.Z)
					elseif waterPlatform then
						waterPlatform.Position = Vector3.new(0, -500, 0)
					end
					RunService.Heartbeat:Wait()
				end
				if waterPlatform then waterPlatform:Destroy() waterPlatform = nil end
			end)
		else
			if waterPlatform then waterPlatform:Destroy() waterPlatform = nil end
		end
	end
})

-- Wall climb
local wallClimbOn = false
KatMove:AddToggle("KatWallClimb", {
	Text = "壁登り (Wall Climb)",
	Default = false,
	Callback = function(v) wallClimbOn = v end
})
task.spawn(function()
	local UIS = game:GetService("UserInputService")
	RunService.Stepped:Connect(function()
		if not wallClimbOn then return end
		local char = LocalPlayer.Character
		if not char then return end
		local hrp = char:FindFirstChild("HumanoidRootPart")
		local hum = char:FindFirstChildOfClass("Humanoid")
		if not hrp or not hum then return end
		if UIS:IsKeyDown(Enum.KeyCode.W) then
			local params = RaycastParams.new()
			params.FilterDescendantsInstances = {char}
			params.FilterType = Enum.RaycastFilterType.Exclude
			local hit = Workspace:Raycast(hrp.Position, hrp.CFrame.LookVector * 3.5, params)
			if hit then
				hum:ChangeState(Enum.HumanoidStateType.Climbing)
				hrp.AssemblyLinearVelocity = Vector3.new(0, 25, 0)
			end
		end
	end)
end)

-- Break barrier snowball
KatAtk:AddButton({
	Text = "バリア破壊 (Snowball)",
	Func = function()
		local done = false
		local startTime = tick()
		local conn
		conn = Workspace.ChildAdded:Connect(function(i)
			if done then conn:Disconnect() return end
			if i.Name == "Part" and (i.Position - Vector3.new(263.4, -4.79, 466.8)).Magnitude <= 2 then
				done = true
				local plots = Workspace:FindFirstChild("Plots")
				if plots then
					for _, plot in pairs(plots:GetChildren()) do
						local barrier = plot:FindFirstChild("Barrier")
						if barrier then
							for _, part in pairs(barrier:GetChildren()) do
								if part:IsA("BasePart") then part.CanCollide = false end
							end
						end
					end
				end
				JapanNotify("バリア破壊完了")
				conn:Disconnect()
			end
		end)
		task.spawn(function()
			repeat
				pcall(function()
					SpawnToyRemoteFunction:InvokeServer("BallSnowball", CFrame.new(263.5, -4.5, 486.9), Vector3.zero)
				end)
				repeat task.wait()
				until (LocalPlayer:FindFirstChild("CanSpawnToy") and LocalPlayer.CanSpawnToy.Value) or done or (tick()-startTime) >= 4
			until done or (tick()-startTime) >= 4
			if not done then JapanNotify("Snowball失敗 / 未所持の可能性") end
		end)
	end
})

-- Bring train
KatAtk:AddButton({
	Text = "電車を呼ぶ (Bring Train)",
	Func = function()
		local char = LocalPlayer.Character
		if not char then return end
		local hrp = char:FindFirstChild("HumanoidRootPart")
		local hum = char:FindFirstChildOfClass("Humanoid")
		if not hrp or not hum then return end
		local pos = hrp.CFrame
		local folder = Workspace:FindFirstChild(LocalPlayer.Name .. "SpawnedInToys")
		local burger
		local conn
		if folder then
			conn = folder.ChildAdded:Connect(function(c)
				if c.Name == "FoodHamburger" then burger = c if conn then conn:Disconnect() end end
			end)
		end
		pcall(function()
			SpawnToyRemoteFunction:InvokeServer("FoodHamburger", hrp.CFrame, Vector3.zero)
		end)
		local t0 = tick()
		repeat task.wait() until burger or tick()-t0 > 2
		if not burger then JapanNotify("Hamburger生成失敗") return end
		repeat task.wait() until burger:FindFirstChild("HoldPart") or tick()-t0 > 3
		pcall(function()
			local train = Workspace.Map.AlwaysHereTweenedObjects.Train
			train.Object.ObjectModel.Seat:Sit(hum)
			train.Object.FollowThisPart.AlignPosition.Enabled = false
			train.Object.FollowThisPart.AlignOrientation.Enabled = false
		end)
		task.wait(0.1)
		pcall(function()
			burger.HoldPart.HoldItemRemoteFunction:InvokeServer(burger, char)
		end)
		task.wait(0.1)
		pcall(function()
			if folder then DestroyToy:FireServer(folder:FindFirstChild("FoodHamburger")) end
		end)
		hrp.CFrame = pos * CFrame.new(0, 5, 0)
		JapanNotify("電車を呼びました")
	end
})

-- Shuriken ESP
local shurikenESPOn = false
local activeShurikens = {}
KatVis:AddToggle("KatShurikenESP", {
	Text = "手裏剣ESP",
	Default = false,
	Callback = function(v)
		shurikenESPOn = v
		if not v then
			for obj in pairs(activeShurikens) do
				local hl = obj:FindFirstChild("JapanShurikenHL")
				if hl then hl:Destroy() end
			end
		end
	end
})
task.spawn(function()
	local function track(obj)
		if obj.Name == "NinjaShuriken" and not activeShurikens[obj] then
			activeShurikens[obj] = true
			obj.AncestryChanged:Connect(function(_, parent)
				if not parent then
					activeShurikens[obj] = nil
					local hl = obj:FindFirstChild("JapanShurikenHL")
					if hl then hl:Destroy() end
				end
			end)
		end
	end
	for _, obj in ipairs(Workspace:GetDescendants()) do track(obj) end
	Workspace.DescendantAdded:Connect(track)
	RunService.RenderStepped:Connect(function()
		if not shurikenESPOn then return end
		local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
		if not root then return end
		for obj in pairs(activeShurikens) do
			if obj and obj.Parent then
				local part = obj:IsA("BasePart") and obj or obj.PrimaryPart
				if part and (root.Position - part.Position).Magnitude <= 800 then
					local hl = obj:FindFirstChild("JapanShurikenHL")
					if not hl then
						hl = Instance.new("Highlight")
						hl.Name = "JapanShurikenHL"
						hl.Adornee = obj
						hl.FillTransparency = 0.3
						hl.OutlineTransparency = 0
						hl.FillColor = Color3.fromRGB(0, 255, 255)
						hl.OutlineColor = Color3.fromRGB(0, 255, 255)
						hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
						hl.Parent = obj
					end
				else
					local hl = obj:FindFirstChild("JapanShurikenHL")
					if hl then hl:Destroy() end
				end
			else
				activeShurikens[obj] = nil
			end
		end
	end)
end)

-- Banana loop (simplified from katsura)
local bananaLoopOn = false
local bananaTargetName = nil
local function getBananaTargets()
	local list = {"(なし)"}
	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= LocalPlayer then
			table.insert(list, p.DisplayName .. " (@" .. p.Name .. ")")
		end
	end
	return list
end
local BananaDrop = KatAtk:AddDropdown("BananaTarget", {
	Text = "Bananaターゲット",
	Values = getBananaTargets(),
	Default = 1,
	Callback = function(v)
		local name = tostring(v):match("@([^%)]+)")
		bananaTargetName = name
	end
})
KatAtk:AddButton({
	Text = "Bananaリスト更新",
	Func = function()
		BananaDrop:SetValues(getBananaTargets())
		JapanNotify("更新しました")
	end
})
KatAtk:AddToggle("BananaLoop", {
	Text = "Banana Loop",
	Default = false,
	Callback = function(v)
		bananaLoopOn = v
		if not v then
			local inv = Workspace:FindFirstChild(LocalPlayer.Name .. "SpawnedInToys")
			if inv then
				for _, obj in pairs(inv:GetChildren()) do
					if obj.Name == "FoodBanana" then
						pcall(function() DestroyToy:FireServer(obj) end)
					end
				end
			end
			JapanNotify("Banana Loop停止")
			return
		end
		JapanNotify("Banana Loop開始")
		task.spawn(function()
			while bananaLoopOn do
				local inv = Workspace:FindFirstChild(LocalPlayer.Name .. "SpawnedInToys")
				local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
				if not inv or not hrp then task.wait(0.4) continue end
				local food = inv:FindFirstChild("FoodBanana")
				if not food then
					local newB
					local c = inv.ChildAdded:Connect(function(ch)
						if ch.Name == "FoodBanana" then newB = ch end
					end)
					pcall(function()
						SpawnToyRemoteFunction:InvokeServer("FoodBanana", hrp.CFrame * CFrame.new(0,2,0), Vector3.zero)
					end)
					local t = tick()
					repeat task.wait(0.05) until newB or tick()-t > 2.5 or not bananaLoopOn
					c:Disconnect()
					food = newB
				end
				if not food or not bananaLoopOn then task.wait(0.5) continue end
				local target = bananaTargetName and Players:FindFirstChild(bananaTargetName)
				local tHRP = target and target.Character and target.Character:FindFirstChild("HumanoidRootPart")
				local hitbox = food:FindFirstChild("HitboxPart")
				local primary = food.PrimaryPart or food:FindFirstChildWhichIsA("BasePart")
				if hitbox then
					pcall(function()
						SetNetworkOwner:FireServer(hitbox, hitbox.CFrame)
						DestroyGrabLine:FireServer(hitbox)
					end)
				end
				if tHRP and primary then
					pcall(function()
						local bp = primary:FindFirstChild("JapanBananaBP") or Instance.new("BodyPosition")
						bp.Name = "JapanBananaBP"
						bp.MaxForce = Vector3.new(125000,125000,125000)
						bp.P = 150000
						bp.Position = tHRP.Position + Vector3.new(0, -3.2, 0)
						bp.Parent = primary
					end)
				end
				task.wait(0.15)
			end
		end)
	end
})

-- Delete paint parts (anti paint quick)
KatDef:AddButton({
	Text = "PaintPart全削除",
	Func = function()
		local n = 0
		for _, obj in ipairs(Workspace:GetDescendants()) do
			if obj:IsA("BasePart") and obj.Name == "PaintPlayerPart" then
				obj:Destroy()
				n = n + 1
			end
		end
		JapanNotify(n .. " 削除")
	end
})

KatVis:AddButton({
	Text = "カメラを自分に戻す",
	Func = function()
		local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
		if hum then Workspace.CurrentCamera.CameraSubject = hum end
	end
})

-- ========== 設定 ==========
local SetGroup = Tabs.Settings:AddLeftGroupbox("UI")
SetGroup:AddButton({
	Text = "UIを閉じる (アンロード)",
	Func = function()
		StopTextureSystem() StopCosmicSystem()
		for _, k in ipairs({"JapanSpeedLoop","JapanJumpLoop","JapanNoclip","JapanFly","JapanInfJump","JapanClickTP","JapanESPConn","JapanAntiSit","JapanGod"}) do
			local c = _G[k]
			if c and typeof(c) == "RBXScriptConnection" then c:Disconnect() end
		end
		ClearESP()
		Library:Unload()
	end
})

ThemeManager:ApplyToTab(Tabs.Settings)
SaveManager:SetFolder("JapanHUB")
SaveManager:BuildConfigSection(Tabs.Settings)
SaveManager:LoadAutoloadConfig()

JapanNotify("Japan HUB (Obsidian) 起動完了")
