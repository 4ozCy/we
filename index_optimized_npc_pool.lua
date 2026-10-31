local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then
    return
end

local PreviousController = rawget(_G, "CelvynAimController")
if type(PreviousController) == "table" and type(PreviousController.Cleanup) == "function" then
    pcall(function()
        PreviousController:Cleanup()
    end)
end

local Settings = {
    Enabled = false,
    TeamCheck = false,
    ShowFOV = false,
    AimPart = "Head",
    FOV = 135,
    AimSpeed = 100
}

local ESPSettings = {
    Enabled = true,
    TeamCheck = false,
    TeamColor = false,
    MaxDistance = 1000,
    CornerLength = 0.28,
    BoxThickness = 1.5,
    DefaultColor = Color3.fromRGB(255, 255, 255),
    TextColor = Color3.fromRGB(245, 245, 250),
    HealthColor = true,
    ShowName = true,
    ShowDistance = true,
    ShowHealth = true,
    LineESP = false,
    LineOrigin = "Middle"
}

local Colors = {
    Accent = Color3.fromRGB(163, 143, 255),
    FOV = Color3.fromRGB(163, 143, 255)
}

local AimParts = {"Head", "UpperTorso", "HumanoidRootPart"}
local CurrentTarget = nil
local SelectionTimer = 0
local Camera = workspace.CurrentCamera
local FOVRing = nil
local Window = nil

pcall(function()
    FOVRing = Drawing.new("Circle")
    FOVRing.Visible = Settings.ShowFOV
    FOVRing.Thickness = 1.5
    FOVRing.Filled = false
    FOVRing.NumSides = 72
    FOVRing.Radius = Settings.FOV
    FOVRing.Color = Colors.FOV
    FOVRing.Transparency = 0.85
end)

local DrawingSupported = false
local testLine, testText
local drawingProbeOK = pcall(function()
    testLine = Drawing.new("Line")
    testText = Drawing.new("Text")
end)
if testLine then pcall(function() testLine:Remove() end) end
if testText then pcall(function() testText:Remove() end) end
DrawingSupported = drawingProbeOK and testLine ~= nil and testText ~= nil

local ESPObjects = {}
local ESPWasActive = false

local function CreateLine()
    local Line = Drawing.new("Line")
    Line.Thickness = ESPSettings.BoxThickness
    Line.Transparency = 1
    Line.Visible = false
    return Line
end

local function CreateText(Size)
    local Text = Drawing.new("Text")
    Text.Size = Size
    Text.Center = true
    Text.Outline = true
    Text.OutlineColor = Color3.fromRGB(0, 0, 0)
    Text.Color = ESPSettings.TextColor
    Text.Visible = false
    return Text
end

local function BuildESPData()
    local Data = {
        Lines = {},
        HealthBackground = CreateLine(),
        HealthBar = CreateLine(),
        Username = CreateText(13),
        Distance = CreateText(12),
        HealthText = CreateText(12),
        Tracer = CreateLine(),
        Hidden = true,
        LastBoxColor = nil,
        LastBoxThickness = nil,
        LastNameText = nil,
        LastDistanceText = nil,
        LastHealthText = nil,
    }

    for i = 1, 8 do
        Data.Lines[i] = CreateLine()
    end

    Data.HealthBackground.Color = Color3.fromRGB(30, 30, 35)
    Data.HealthBackground.Thickness = 4
    Data.HealthBar.Thickness = 2
    Data.Tracer.Transparency = 0.9

    Data.All = {
        Data.HealthBackground, Data.HealthBar, Data.Username,
        Data.Distance, Data.HealthText, Data.Tracer,
    }
    for i = 1, #Data.Lines do
        Data.All[#Data.All + 1] = Data.Lines[i]
    end
    return Data
end

local function CreateESP(Player)
    if not DrawingSupported or ESPObjects[Player] then
        return
    end

    local ok, Data = pcall(BuildESPData)
    if ok and Data then
        ESPObjects[Player] = Data
    end
end

local function HideESP(Data)
    if not Data or Data.Hidden then
        return
    end
    Data.Hidden = true
    for i = 1, #Data.All do
        Data.All[i].Visible = false
    end
end

local function RemoveESP(Player)
    local Data = ESPObjects[Player]
    if not Data then
        return
    end

    for i = 1, #Data.All do
        local Object = Data.All[i]
        pcall(function()
            Object:Remove()
        end)
    end
    ESPObjects[Player] = nil
end

local function RemoveAllESP()
    for Player in pairs(ESPObjects) do
        RemoveESP(Player)
    end
end

local Controller = {
    Connections = {},
    Ring = FOVRing,
    Window = nil,
    Cleaned = false
}

function Controller:Cleanup(skipWindow)
    if self.Cleaned then
        return
    end
    self.Cleaned = true

    pcall(function()
        RunService:UnbindFromRenderStep("CelvynAimLock")
    end)

    for _, connection in ipairs(self.Connections) do
        pcall(function()
            connection:Disconnect()
        end)
    end
    table.clear(self.Connections)

    pcall(RemoveAllESP)
    for part, object in pairs(PoolObjects or {}) do
        pcall(function() object.Line:Remove() end)
        pcall(function() object.Marker:Remove() end)
        PoolObjects[part] = nil
    end

    if self.Ring then
        pcall(function()
            self.Ring.Visible = false
            self.Ring:Remove()
        end)
        self.Ring = nil
    end

    if not skipWindow and self.Window then
        pcall(function()
            self.Window:Destroy()
        end)
    end

    if rawget(_G, "CelvynAimController") == self then
        _G.CelvynAimController = nil
    end
end

_G.CelvynAimController = Controller

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local IsStudio = RunService:IsStudio()
local ImGui

local libraryLoaded, libraryResult = pcall(function()
    if IsStudio then
        return require(ReplicatedStorage:WaitForChild("ImGui"))
    end

    local SourceURL = "https://raw.githubusercontent.com/4ozCy/imgui/refs/heads/main/ImGui.lua"
    return loadstring(game:HttpGet(SourceURL))()
end)

if not libraryLoaded or type(libraryResult) ~= "table" then
    warn("ImGui could not be loaded.")
    Controller:Cleanup(true)
    return
end

ImGui = libraryResult
ImGui.CreateMobileButton = nil

local windowLoaded, windowError = pcall(function()
    Window = ImGui:CreateWindow({
        Title = "AIMBOT.gpt & ESP.claude",
        Size = UDim2.new(0, 420, 0, 470),
        Position = UDim2.new(0.5, 0, 0, 70),
        MobileButton = false,
    })
    assert(Window, "CreateWindow returned nil")
    Controller.Window = Window
    if type(Window.Center) == "function" then
        Window:Center()
    end
end)

if not windowLoaded or not Window then
    warn("ImGui window creation failed: " .. tostring(windowError))
    Controller:Cleanup(true)
    return
end

Controller.Window = Window

local AimTab, ESPTab, PoolTab
local tabsLoaded, tabsError = pcall(function()
    AimTab = Window:CreateTab({Name = "Aimbot"})
    ESPTab = Window:CreateTab({Name = "ESP"})
    PoolTab = Window:CreateTab({Name = "Pool"})
    assert(AimTab, "CreateTab returned nil for Aimbot")
    assert(ESPTab, "CreateTab returned nil for ESP")
    assert(PoolTab, "CreateTab returned nil for Pool")
    Window:ShowTab(AimTab)
end)

if not tabsLoaded then
    warn("ImGui tab creation failed: " .. tostring(tabsError))
    Controller:Cleanup()
    return
end

AimTab:Checkbox({
    Label = "Enable Aimbot",
    Value = Settings.Enabled,
    Callback = function(_, value)
        Settings.Enabled = value == true
        if not Settings.Enabled then
            CurrentTarget = nil
            SelectionTimer = 0
        end
    end,
})

AimTab:Combo({
    Label = "Aim Part",
    Selected = Settings.AimPart,
    Items = AimParts,
    Callback = function(_, value)
        if table.find(AimParts, value) then
            Settings.AimPart = value
            CurrentTarget = nil
            SelectionTimer = 0
        end
    end,
})

AimTab:Slider({
    Label = "Aim Speed",
    Value = Settings.AimSpeed,
    MinValue = 5,
    MaxValue = 100,
    Format = "%.0f",
    ReadOnly = false,
    Callback = function(_, value)
        local number = tonumber(value)
        if number then
            Settings.AimSpeed = math.clamp(math.floor(number + 0.5), 5, 100)
        end
    end,
})

AimTab:Checkbox({
    Label = "Team Check",
    Value = Settings.TeamCheck,
    Callback = function(_, value)
        Settings.TeamCheck = value == true
        CurrentTarget = nil
        SelectionTimer = 0
    end,
})

AimTab:Button({
    Text = "Clear Current Target",
    Callback = function()
        CurrentTarget = nil
        SelectionTimer = 0
    end,
})

AimTab:Keybind({
    Label = "Toggle UI",
    Value = Enum.KeyCode.RightControl,
    Callback = function()
        Window:SetVisible(not Window.Visible)
    end,
})

AimTab:Checkbox({
    Label = "Show FOV",
    Value = Settings.ShowFOV,
    Callback = function(_, value)
        Settings.ShowFOV = value == true
        if FOVRing then
            pcall(function()
                FOVRing.Visible = Settings.ShowFOV
            end)
        end
    end,
})

AimTab:Slider({
    Label = "FOV Radius",
    Value = Settings.FOV,
    MinValue = 35,
    MaxValue = 300,
    Format = "%.0f",
    ReadOnly = false,
    Callback = function(_, value)
        local number = tonumber(value)
        if number then
            Settings.FOV = math.clamp(math.floor(number + 0.5), 35, 300)
            if FOVRing then
                pcall(function()
                    FOVRing.Radius = Settings.FOV
                end)
            end
        end
    end,
})

local FOVColors = {
    Purple = Color3.fromRGB(163, 143, 255),
    White = Color3.fromRGB(255, 255, 255),
    Cyan = Color3.fromRGB(80, 220, 255),
    Red = Color3.fromRGB(255, 80, 80),
    Green = Color3.fromRGB(80, 255, 120),
    Yellow = Color3.fromRGB(255, 220, 80),
}

AimTab:Combo({
    Label = "FOV Color",
    Selected = "White",
    Items = FOVColors,
    Callback = function(_, color)
        if typeof(color) == "Color3" then
            Colors.FOV = color
            if FOVRing then
                pcall(function()
                    FOVRing.Color = color
                end)
            end
        end
    end,
})

ESPTab:Checkbox({
    Label = "Enable ESP",
    Value = ESPSettings.Enabled,
    Callback = function(_, value)
        ESPSettings.Enabled = value == true
    end,
})

ESPTab:Slider({
    Label = "Distance",
    Value = ESPSettings.MaxDistance,
    MinValue = 100,
    MaxValue = 5000,
    Format = "%.0f",
    ReadOnly = false,
    Callback = function(_, value)
        local number = tonumber(value)
        if number then
            ESPSettings.MaxDistance = math.clamp(math.floor(number + 0.5), 100, 5000)
        end
    end,
})

ESPTab:Checkbox({
    Label = "Team Check",
    Value = ESPSettings.TeamCheck,
    Callback = function(_, value)
        ESPSettings.TeamCheck = value == true
    end,
})

ESPTab:Checkbox({
    Label = "Team Colors",
    Value = ESPSettings.TeamColor,
    Callback = function(_, value)
        ESPSettings.TeamColor = value == true
    end,
})

ESPTab:Checkbox({
    Label = "Names",
    Value = ESPSettings.ShowName,
    Callback = function(_, value)
        ESPSettings.ShowName = value == true
    end,
})

ESPTab:Checkbox({
    Label = "Distance",
    Value = ESPSettings.ShowDistance,
    Callback = function(_, value)
        ESPSettings.ShowDistance = value == true
    end,
})

ESPTab:Checkbox({
    Label = "Health Bar",
    Value = ESPSettings.ShowHealth,
    Callback = function(_, value)
        ESPSettings.ShowHealth = value == true
    end,
})

ESPTab:Checkbox({
    Label = "Health Colors",
    Value = ESPSettings.HealthColor,
    Callback = function(_, value)
        ESPSettings.HealthColor = value == true
    end,
})

ESPTab:Checkbox({
    Label = "Line ESP",
    Value = ESPSettings.LineESP,
    Callback = function(_, value)
        ESPSettings.LineESP = value == true
    end,
})

ESPTab:Combo({
    Label = "Line Origin",
    Selected = ESPSettings.LineOrigin,
    Items = {"Top", "Bottom", "Middle"},
    Callback = function(_, value)
        if value == "Top" or value == "Bottom" or value == "Middle" then
            ESPSettings.LineOrigin = value
        end
    end,
})


ESPTab:Slider({
    Label = "Corner Length (%)",
    Value = math.floor(ESPSettings.CornerLength * 100 + 0.5),
    MinValue = 10,
    MaxValue = 50,
    Format = "%.0f",
    ReadOnly = false,
    Callback = function(_, value)
        local number = tonumber(value)
        if number then
            ESPSettings.CornerLength = math.clamp(math.floor(number + 0.5), 10, 50) / 100
        end
    end,
})

local BoxColors = {
    White = Color3.fromRGB(255, 255, 255),
    Purple = Color3.fromRGB(163, 143, 255),
    Cyan = Color3.fromRGB(80, 220, 255),
    Red = Color3.fromRGB(255, 80, 80),
    Green = Color3.fromRGB(80, 255, 120),
    Yellow = Color3.fromRGB(255, 220, 80),
}

ESPTab:Combo({
    Label = "Box Color",
    Selected = "White",
    Items = BoxColors,
    Callback = function(_, selection)
        local color = selection
        if typeof(selection) ~= "Color3" then
            color = BoxColors[tostring(selection)]
        end
        if typeof(color) == "Color3" then
            ESPSettings.DefaultColor = color
        end
    end,
})


-- Automatic pool-ball discovery and velocity-based trajectory overlay.
local PoolSettings = {
    Enabled = false,
    PredictionLength = 18,
    ScanInterval = 1.25,
    MinSpeed = 0.8,
    BallColor = Color3.fromRGB(80, 220, 255),
    CueColor = Color3.fromRGB(255, 255, 255),
}
local PoolObjects = {}
local PoolScanAccumulator = 0
local PoolUpdateAccumulator = 0

local function looksLikePoolBall(part)
    if not part or not part:IsA("BasePart") or not part:IsDescendantOf(workspace) then
        return false
    end
    if part.Transparency >= 1 then return false end

    local name = string.lower(part.Name)
    local nameSuggestsBall = string.find(name, "ball", 1, true)
        or string.find(name, "cue", 1, true)
        or string.find(name, "billiard", 1, true)
        or string.find(name, "pool", 1, true)

    local size = part.Size
    local maxAxis = math.max(size.X, size.Y, size.Z)
    local minAxis = math.min(size.X, size.Y, size.Z)
    if maxAxis < 0.25 or maxAxis > 5 or minAxis <= 0 then return false end

    local sphericalEnough = (maxAxis / minAxis) <= 1.3
    local ballShape = part:IsA("Part") and part.Shape == Enum.PartType.Ball
    return nameSuggestsBall or (sphericalEnough and (ballShape or part:IsA("MeshPart")))
end

local function getPoolBallColor(part)
    local name = string.lower(part.Name)
    if string.find(name, "cue", 1, true)
        or (part.Color.R > 0.88 and part.Color.G > 0.88 and part.Color.B > 0.88) then
        return PoolSettings.CueColor
    end
    return PoolSettings.BallColor
end

local function createPoolDrawing(part)
    if not DrawingSupported or PoolObjects[part] then return end
    local ok, object = pcall(function()
        local line = Drawing.new("Line")
        line.Visible = false
        line.Thickness = 2
        line.Transparency = 1
        local marker = Drawing.new("Circle")
        marker.Visible = false
        marker.Filled = false
        marker.NumSides = 20
        marker.Radius = 4
        marker.Thickness = 1.5
        return {Line = line, Marker = marker}
    end)
    if ok and object then PoolObjects[part] = object end
end

local function removePoolDrawing(part)
    local object = PoolObjects[part]
    if not object then return end
    pcall(function() object.Line:Remove() end)
    pcall(function() object.Marker:Remove() end)
    PoolObjects[part] = nil
end

local function clearPoolDrawings()
    for part in pairs(PoolObjects) do removePoolDrawing(part) end
end

PoolTab:Checkbox({
    Label = "Pool Trajectory ESP",
    Value = PoolSettings.Enabled,
    Callback = function(_, value)
        PoolSettings.Enabled = value == true
        if not PoolSettings.Enabled then
            for _, object in pairs(PoolObjects) do
                pcall(function()
                    object.Line.Visible = false
                    object.Marker.Visible = false
                end)
            end
        end
    end,
})

PoolTab:Slider({
    Label = "Trajectory Length",
    Value = PoolSettings.PredictionLength,
    MinValue = 5,
    MaxValue = 60,
    Format = "%.0f",
    ReadOnly = false,
    Callback = function(_, value)
        local number = tonumber(value)
        if number then
            PoolSettings.PredictionLength = math.clamp(math.floor(number + 0.5), 5, 60)
        end
    end,
})

PoolTab:Button({
    Text = "Rescan Pool Balls",
    Callback = function()
        PoolScanAccumulator = PoolSettings.ScanInterval
    end,
})

local HumanoidCache = setmetatable({}, { __mode = "k" })
local RootPartCache = setmetatable({}, { __mode = "k" })
local AimPartCache = setmetatable({}, { __mode = "k" })
local HeadCache = setmetatable({}, { __mode = "k" })

local RootPartNames = {"HumanoidRootPart", "RootPart", "LowerTorso", "Torso", "UpperTorso"}
local AimPartFallbacks = {"Head", "HumanoidRootPart", "RootPart", "UpperTorso", "Torso", "LowerTorso"}

local function getHumanoid(character)
    if not character then
        return nil
    end

    local cached = HumanoidCache[character]
    if cached and cached.Parent then
        return cached
    end

    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then
        humanoid = character:FindFirstChildWhichIsA("Humanoid", true)
    end
    if humanoid then
        HumanoidCache[character] = humanoid
    end
    return humanoid
end

local function isPlayerTarget(target)
    return typeof(target) == "Instance" and target:IsA("Player")
end

local function getTargetCharacter(target)
    if isPlayerTarget(target) then
        return target.Character
    end
    if typeof(target) == "Instance" and target:IsA("Model") then
        return target
    end
    return nil
end

local function getTargetName(target)
    if isPlayerTarget(target) then
        return target.DisplayName .. "  @" .. target.Name
    end
    return target and target.Name or "NPC"
end

local function getRootPart(character)
    if not character then
        return nil
    end

    local cached = RootPartCache[character]
    if cached and cached:IsA("BasePart") and cached:IsDescendantOf(character) then
        return cached
    end

    for i = 1, #RootPartNames do
        local name = RootPartNames[i]
        local part = character:FindFirstChild(name) or character:FindFirstChild(name, true)
        if part and part:IsA("BasePart") then
            RootPartCache[character] = part
            return part
        end
    end

    if character:IsA("Model") then
        local primary = character.PrimaryPart
        if primary and primary:IsA("BasePart") and primary:IsDescendantOf(character) then
            RootPartCache[character] = primary
            return primary
        end
    end
    return nil
end

local function getHeadPart(character)
    if not character then
        return nil
    end
    local cached = HeadCache[character]
    if cached and cached:IsA("BasePart") and cached:IsDescendantOf(character) then
        return cached
    end
    local head = character:FindFirstChild("Head") or character:FindFirstChild("Head", true)
    if head and head:IsA("BasePart") then
        HeadCache[character] = head
        return head
    end
    return nil
end

local function getAimPart(character)
    if not character then
        return nil
    end

    local cached = AimPartCache[character]
    if cached and cached.Name == Settings.AimPart and cached.Part
        and cached.Part:IsA("BasePart") and cached.Part:IsDescendantOf(character) then
        return cached.Part
    end

    local preferred = character:FindFirstChild(Settings.AimPart) or character:FindFirstChild(Settings.AimPart, true)
    if not (preferred and preferred:IsA("BasePart")) then
        preferred = nil
        for i = 1, #AimPartFallbacks do
            local part = character:FindFirstChild(AimPartFallbacks[i]) or character:FindFirstChild(AimPartFallbacks[i], true)
            if part and part:IsA("BasePart") then
                preferred = part
                break
            end
        end
    end
    preferred = preferred or getRootPart(character)
    AimPartCache[character] = {Name = Settings.AimPart, Part = preferred}
    return preferred
end

local function BuildAimContext()
    Camera = workspace.CurrentCamera or Camera
    if not Camera then
        return nil
    end

    local character = LocalPlayer.Character
    local humanoid = getHumanoid(character)
    local root = getRootPart(character)
    if not humanoid or humanoid.Health <= 0 or not root then
        return nil
    end

    local viewport = Camera.ViewportSize
    return {
        Camera = Camera,
        LocalRoot = root,
        LocalTeam = LocalPlayer.Team,
        CenterX = viewport.X * 0.5,
        CenterY = viewport.Y * 0.5,
        FOVSquared = Settings.FOV * Settings.FOV,
    }
end

local NPCCache = setmetatable({}, {__mode = "k"})

local function RefreshNPCCache()
    local found = {}
    for _, instance in ipairs(workspace:GetDescendants()) do
        if instance:IsA("Model") and not Players:GetPlayerFromCharacter(instance) then
            local humanoid = getHumanoid(instance)
            if humanoid and humanoid.Health > 0 and getRootPart(instance) then
                found[instance] = true
            end
        end
    end
    for model in pairs(NPCCache) do
        if not found[model] or not model.Parent then
            NPCCache[model] = nil
        end
    end
    for model in pairs(found) do
        NPCCache[model] = true
    end
end

task.spawn(function()
    while not Controller.Cleaned do
        pcall(RefreshNPCCache)
        task.wait(2)
    end
end)

local function isValidTarget(target, context)
    if not target or not context then
        return false
    end
    if isPlayerTarget(target) and target == LocalPlayer then
        return false
    end

    local character = getTargetCharacter(target)
    if not character or not character.Parent then
        return false
    end

    if isPlayerTarget(target) then
        if target.Character ~= character then
            return false
        end
        if Settings.TeamCheck and context.LocalTeam ~= nil and target.Team == context.LocalTeam then
            return false
        end
    elseif not target:IsA("Model") or Players:GetPlayerFromCharacter(character) then
        return false
    end

    local humanoid = getHumanoid(character)
    if not humanoid or humanoid.Health <= 0 then
        return false
    end
    local aimPart = getAimPart(character)
    if not aimPart then
        return false
    end

    local screenPoint, onScreen = context.Camera:WorldToViewportPoint(aimPart.Position)
    if not onScreen or screenPoint.Z <= 0 then
        return false
    end

    local dx = screenPoint.X - context.CenterX
    local dy = screenPoint.Y - context.CenterY
    local distanceSquared = dx * dx + dy * dy
    if distanceSquared > context.FOVSquared then
        return false
    end
    return true, distanceSquared, aimPart
end

local function getClosestTarget(context)
    local bestTarget, bestAimPart
    local bestDistanceSquared = math.huge

    for _, target in ipairs(Players:GetPlayers()) do
        if target ~= LocalPlayer then
            local valid, distanceSquared, aimPart = isValidTarget(target, context)
            if valid and distanceSquared < bestDistanceSquared then
                bestDistanceSquared = distanceSquared
                bestTarget = target
                bestAimPart = aimPart
            end
        end
    end

    for target in pairs(NPCCache) do
        local valid, distanceSquared, aimPart = isValidTarget(target, context)
        if valid and distanceSquared < bestDistanceSquared then
            bestDistanceSquared = distanceSquared
            bestTarget = target
            bestAimPart = aimPart
        end
    end
    return bestTarget, bestAimPart
end

local LastFOVViewportX, LastFOVViewportY = -1, -1
local function updateFOVRing()
    if not FOVRing or not Settings.ShowFOV then
        return
    end
    Camera = workspace.CurrentCamera or Camera
    if not Camera then
        return
    end
    local viewport = Camera.ViewportSize
    if viewport.X == LastFOVViewportX and viewport.Y == LastFOVViewportY then
        return
    end
    LastFOVViewportX, LastFOVViewportY = viewport.X, viewport.Y
    pcall(function()
        FOVRing.Position = Vector2.new(viewport.X * 0.5, viewport.Y * 0.5)
    end)
end

local AimErrorLastWarn = 0
local function updateAimAndFOV(deltaTime)
    local ok, err = pcall(function()
        Camera = workspace.CurrentCamera or Camera
        if not Camera then
            CurrentTarget = nil
            return
        end

        updateFOVRing()

        if not Settings.Enabled then
            CurrentTarget = nil
            SelectionTimer = 0
            return
        end

        local context = BuildAimContext()
        if not context then
            CurrentTarget = nil
            return
        end

        local frameTime = math.clamp(tonumber(deltaTime) or 0, 0, 0.1)
        SelectionTimer += frameTime

        -- Validate the lock every frame. Reacquire immediately if an NPC is
        -- removed, respawned, or moves outside the configured FOV.
        local valid, _, aimPart = false, nil, nil
        if CurrentTarget ~= nil then
            valid, _, aimPart = isValidTarget(CurrentTarget, context)
        end

        if not valid then
            CurrentTarget, aimPart = getClosestTarget(context)
            valid = CurrentTarget ~= nil and aimPart ~= nil
            SelectionTimer = 0
        elseif SelectionTimer >= 0.25 then
            -- Periodically refresh the best target instead of keeping an old
            -- target indefinitely when NPCs are replaced or new ones appear.
            SelectionTimer = 0
            local bestTarget, bestAimPart = getClosestTarget(context)
            if bestTarget and bestAimPart then
                CurrentTarget, aimPart = bestTarget, bestAimPart
                valid = true
            end
        end

        if valid and CurrentTarget and aimPart and aimPart.Parent then
            local goal = CFrame.lookAt(context.Camera.CFrame.Position, aimPart.Position)
            local aimSpeed = math.clamp(tonumber(Settings.AimSpeed) or 30, 5, 100)
            local alpha = 1 - math.exp(-(aimSpeed * 0.66) * frameTime)
            context.Camera.CFrame = context.Camera.CFrame:Lerp(goal, math.clamp(alpha, 0, 1))
        else
            CurrentTarget = nil
        end
    end)

    if not ok then
        CurrentTarget = nil
        -- Do not silently hide a recurring error; throttle warnings to avoid
        -- flooding the executor console if the game changes character models.
        local now = os.clock()
        if now - AimErrorLastWarn >= 3 then
            AimErrorLastWarn = now
            warn("[Aimbot] Recovered from update error: " .. tostring(err))
        end
    end
end

local boundAimStep = pcall(function()
    RunService:BindToRenderStep("CelvynAimLock", Enum.RenderPriority.Last.Value + 1, updateAimAndFOV)
end)

if not boundAimStep then
    local renderConnection = RunService.RenderStepped:Connect(updateAimAndFOV)
    table.insert(Controller.Connections, renderConnection)
end

table.insert(Controller.Connections, Players.PlayerRemoving:Connect(function(player)
    if player == CurrentTarget then
        CurrentTarget = nil
        SelectionTimer = 0
    end
end))

local function GetPlayerColor(Target)
    if isPlayerTarget(Target) and ESPSettings.TeamColor and Target.Team ~= nil and Target.TeamColor then
        return Target.TeamColor.Color
    end
    return ESPSettings.DefaultColor
end
local function IsFiniteNumber(value)
    return value == value and value ~= math.huge and value ~= -math.huge
end

local function GetBoundingBox(Character, Humanoid, Root, ActiveCamera, Viewport)
    if not Character or not Humanoid or not Root or not ActiveCamera or not Viewport then
        return nil
    end

    local Head = getHeadPart(Character)
    if not Humanoid or not Root or not Head then
        return nil
    end

    if Viewport.X <= 0 or Viewport.Y <= 0 then
        return nil
    end

    local TopWorld = Head.Position + Vector3.new(0, Head.Size.Y * 0.5, 0)
    local FootDrop = math.max(Humanoid.HipHeight + Root.Size.Y * 0.5, Root.Size.Y * 1.5)
    local BottomWorld = Root.Position - Vector3.new(0, FootDrop, 0)
    local TopScreen = ActiveCamera:WorldToViewportPoint(TopWorld)
    local BottomScreen = ActiveCamera:WorldToViewportPoint(BottomWorld)

    if TopScreen.Z <= 0 or BottomScreen.Z <= 0 then
        return nil
    end
    if not IsFiniteNumber(TopScreen.X) or not IsFiniteNumber(TopScreen.Y)
        or not IsFiniteNumber(TopScreen.Z) or not IsFiniteNumber(BottomScreen.X)
        or not IsFiniteNumber(BottomScreen.Y) or not IsFiniteNumber(BottomScreen.Z) then
        return nil
    end

    local Height = math.abs(BottomScreen.Y - TopScreen.Y)
    if Height < 2 or Height > Viewport.Y * 0.95 then
        return nil
    end
    local Width = math.clamp(Height * 0.45, 2, Viewport.X * 0.95)
    local CenterX = (TopScreen.X + BottomScreen.X) * 0.5
    local MinX = CenterX - Width * 0.5
    local MaxX = CenterX + Width * 0.5
    local MinY = math.min(TopScreen.Y, BottomScreen.Y)
    local MaxY = math.max(TopScreen.Y, BottomScreen.Y)
    if MaxX < 0 or MinX > Viewport.X or MaxY < 0 or MinY > Viewport.Y then
        return nil
    end

    MinX = math.clamp(MinX, 0, Viewport.X)
    MaxX = math.clamp(MaxX, 0, Viewport.X)
    MinY = math.clamp(MinY, 0, Viewport.Y)
    MaxY = math.clamp(MaxY, 0, Viewport.Y)
    if MaxX <= MinX or MaxY <= MinY then
        return nil
    end
    return MinX, MinY, MaxX, MaxY
end

local function UpdateCornerBox(Data, X, Y, Width, Height, Color)
    local CX = X + Width
    local CY = Y + Height
    local Horizontal = math.clamp(Width * ESPSettings.CornerLength, 2, math.max(Width / 2, 2))
    local Vertical = math.clamp(Height * ESPSettings.CornerLength, 2, math.max(Height / 2, 2))
    local Lines = Data.Lines

    Lines[1].From = Vector2.new(X, Y)
    Lines[1].To = Vector2.new(X + Horizontal, Y)
    Lines[2].From = Vector2.new(X, Y)
    Lines[2].To = Vector2.new(X, Y + Vertical)
    Lines[3].From = Vector2.new(CX, Y)
    Lines[3].To = Vector2.new(CX - Horizontal, Y)
    Lines[4].From = Vector2.new(CX, Y)
    Lines[4].To = Vector2.new(CX, Y + Vertical)
    Lines[5].From = Vector2.new(X, CY)
    Lines[5].To = Vector2.new(X + Horizontal, CY)
    Lines[6].From = Vector2.new(X, CY)
    Lines[6].To = Vector2.new(X, CY - Vertical)
    Lines[7].From = Vector2.new(CX, CY)
    Lines[7].To = Vector2.new(CX - Horizontal, CY)
    Lines[8].From = Vector2.new(CX, CY)
    Lines[8].To = Vector2.new(CX, CY - Vertical)

    local thickness = ESPSettings.BoxThickness
    if Data.LastBoxColor ~= Color or Data.LastBoxThickness ~= thickness then
        for i = 1, #Lines do
            local Line = Lines[i]
            if Data.LastBoxColor ~= Color then Line.Color = Color end
            if Data.LastBoxThickness ~= thickness then Line.Thickness = thickness end
        end
        Data.LastBoxColor = Color
        Data.LastBoxThickness = thickness
    end
    for i = 1, #Lines do
        if not Lines[i].Visible then
            Lines[i].Visible = true
        end
    end
end

local function UpdateEntityESP(Player, Data, LocalRoot, ActiveCamera, Viewport)
    if isPlayerTarget(Player) and Player == LocalPlayer then
        HideESP(Data)
        return
    end

    if isPlayerTarget(Player) then
        if Player.Parent ~= Players or not Player.Character then
            HideESP(Data)
            return
        end
        if ESPSettings.TeamCheck and LocalPlayer.Team ~= nil and Player.Team == LocalPlayer.Team then
            HideESP(Data)
            return
        end
    elseif not Player:IsA("Model") or Players:GetPlayerFromCharacter(Player) then
        HideESP(Data)
        return
    end

    local Character = getTargetCharacter(Player)
    if not Character then
        HideESP(Data)
        return
    end

    local Humanoid = getHumanoid(Character)
    local Root = getRootPart(Character)
    if not Humanoid or not Root or Humanoid.Health <= 0 then
        HideESP(Data)
        return
    end

    if not LocalRoot or not ActiveCamera or not Viewport then
        HideESP(Data)
        return
    end

    local Offset = Root.Position - LocalRoot.Position
    local DistanceSquared = Offset:Dot(Offset)
    local MaxDistance = ESPSettings.MaxDistance
    if DistanceSquared > MaxDistance * MaxDistance then
        HideESP(Data)
        return
    end

    local X1, Y1, X2, Y2 = GetBoundingBox(Character, Humanoid, Root, ActiveCamera, Viewport)
    if not X1 then
        HideESP(Data)
        return
    end

    local Width = X2 - X1
    local Height = Y2 - Y1
    if Width <= 1 or Height <= 1 then
        HideESP(Data)
        return
    end

    local Color = GetPlayerColor(Player)
    Data.Hidden = false
    UpdateCornerBox(Data, X1, Y1, Width, Height, Color)

    if ESPSettings.LineESP and Data.Tracer then
        local OriginY = Viewport.Y * 0.5
        if ESPSettings.LineOrigin == "Top" then
            OriginY = 0
        elseif ESPSettings.LineOrigin == "Bottom" then
            OriginY = Viewport.Y
        end
        Data.Tracer.From = Vector2.new(Viewport.X * 0.5, OriginY)
        Data.Tracer.To = Vector2.new(X1 + Width * 0.5, Y2)
        if Data.LastTracerColor ~= Color then
            Data.Tracer.Color = Color
            Data.LastTracerColor = Color
        end
        if Data.LastTracerThickness ~= ESPSettings.BoxThickness then
            Data.Tracer.Thickness = ESPSettings.BoxThickness
            Data.LastTracerThickness = ESPSettings.BoxThickness
        end
        if not Data.Tracer.Visible then
            Data.Tracer.Visible = true
        end
    elseif Data.Tracer and Data.Tracer.Visible then
        Data.Tracer.Visible = false
    end

    if ESPSettings.ShowHealth then
        local HealthPercent = math.clamp(Humanoid.Health / math.max(Humanoid.MaxHealth, 1), 0, 1)
        local HealthHeight = Height * HealthPercent
        Data.HealthBackground.From = Vector2.new(X1 - 6, Y1)
        Data.HealthBackground.To = Vector2.new(X1 - 6, Y2)
        if not Data.HealthBackground.Visible then
            Data.HealthBackground.Visible = true
        end
        Data.HealthBar.From = Vector2.new(X1 - 6, Y2)
        Data.HealthBar.To = Vector2.new(X1 - 6, Y2 - HealthHeight)

        local HealthText = math.floor(HealthPercent * 100)
        if Data.LastHealthColorPercent ~= HealthText or Data.LastHealthColorMode ~= ESPSettings.HealthColor then
            if ESPSettings.HealthColor then
                local ColorPercent = HealthText / 100
                Data.HealthBar.Color = Color3.new(1 - ColorPercent, ColorPercent, 60 / 255)
            else
                Data.HealthBar.Color = Color3.fromRGB(100, 255, 150)
            end
            Data.LastHealthColorPercent = HealthText
            Data.LastHealthColorMode = ESPSettings.HealthColor
        end
        if not Data.HealthBar.Visible then
            Data.HealthBar.Visible = true
        end

        if Data.LastHealthText ~= HealthText then
            Data.HealthText.Text = string.format("%d%%", HealthText)
            Data.LastHealthText = HealthText
        end
        Data.HealthText.Position = Vector2.new(X1 - 28, Y1 + Height * 0.5)
        if not Data.HealthText.Visible then
            Data.HealthText.Visible = true
        end
    else
        Data.HealthBackground.Visible = false
        Data.HealthBar.Visible = false
        Data.HealthText.Visible = false
    end

    if ESPSettings.ShowName then
        local NameText = getTargetName(Player)
        if Data.LastNameText ~= NameText then
            Data.Username.Text = NameText
            Data.LastNameText = NameText
        end
        Data.Username.Position = Vector2.new(X1 + Width * 0.5, Y1 - 18)
        if not Data.Username.Visible then
            Data.Username.Visible = true
        end
    else
        Data.Username.Visible = false
    end

    if ESPSettings.ShowDistance then
        local Distance = math.sqrt(DistanceSquared)
        local DistanceText = string.format("%dm", math.floor(Distance))
        if Data.LastDistanceText ~= DistanceText then
            Data.Distance.Text = DistanceText
            Data.LastDistanceText = DistanceText
        end
        Data.Distance.Position = Vector2.new(X1 + Width * 0.5, Y2 + 5)
        if not Data.Distance.Visible then
            Data.Distance.Visible = true
        end
    else
        Data.Distance.Visible = false
    end
end

if DrawingSupported then
    for _, Player in ipairs(Players:GetPlayers()) do
        if Player ~= LocalPlayer then
            CreateESP(Player)
        end
    end
    pcall(RefreshNPCCache)
    for NPC in pairs(NPCCache) do
        CreateESP(NPC)
    end

    table.insert(Controller.Connections, Players.PlayerAdded:Connect(function(Player)
        if Player ~= LocalPlayer then
            CreateESP(Player)
        end
    end))

    -- NPC ESP is registered on a slower scan to keep the per-frame path lightweight.
    task.spawn(function()
        while not Controller.Cleaned do
            for NPC in pairs(NPCCache) do
                if NPC.Parent and not ESPObjects[NPC] then
                    CreateESP(NPC)
                end
            end
            task.wait(2)
        end
    end)

    table.insert(Controller.Connections, Players.PlayerRemoving:Connect(function(Player)
        RemoveESP(Player)
    end))


    table.insert(Controller.Connections, RunService.RenderStepped:Connect(function(dt)
        if not PoolSettings.Enabled then return end
        Camera = workspace.CurrentCamera or Camera
        if not Camera then return end

        PoolScanAccumulator += dt or 0
        if PoolScanAccumulator >= PoolSettings.ScanInterval then
            PoolScanAccumulator = 0
            local found = {}
            local ok = pcall(function()
                for _, instance in ipairs(workspace:GetDescendants()) do
                    if looksLikePoolBall(instance) then
                        found[instance] = true
                        createPoolDrawing(instance)
                    end
                end
            end)
            if ok then
                for part in pairs(PoolObjects) do
                    if not part or not part.Parent or not found[part] then
                        removePoolDrawing(part)
                    end
                end
            end
        end

        PoolUpdateAccumulator += dt or 0
        if PoolUpdateAccumulator < 1 / 30 then return end
        PoolUpdateAccumulator = 0

        local activeCamera = Camera
        for part, object in pairs(PoolObjects) do
            local success = pcall(function()
                if not part.Parent then
                    object.Line.Visible = false
                    object.Marker.Visible = false
                    return
                end

                local screen, onScreen = activeCamera:WorldToViewportPoint(part.Position)
                if not onScreen or screen.Z <= 0 then
                    object.Line.Visible = false
                    object.Marker.Visible = false
                    return
                end

                object.Marker.Position = Vector2.new(screen.X, screen.Y)
                object.Marker.Color = getPoolBallColor(part)
                object.Marker.Visible = true

                local velocity = part.AssemblyLinearVelocity
                local horizontalVelocity = Vector3.new(velocity.X, 0, velocity.Z)
                if horizontalVelocity.Magnitude < PoolSettings.MinSpeed then
                    object.Line.Visible = false
                    return
                end

                local predictedWorld = part.Position
                    + horizontalVelocity.Unit * PoolSettings.PredictionLength
                local endScreen, endOnScreen = activeCamera:WorldToViewportPoint(predictedWorld)
                if endOnScreen and endScreen.Z > 0 then
                    object.Line.From = Vector2.new(screen.X, screen.Y)
                    object.Line.To = Vector2.new(endScreen.X, endScreen.Y)
                    object.Line.Color = getPoolBallColor(part)
                    object.Line.Visible = true
                else
                    object.Line.Visible = false
                end
            end)
            if not success then
                pcall(function()
                    object.Line.Visible = false
                    object.Marker.Visible = false
                end)
            end
        end
    end))

    local ESPAccumulator = 0
    local ESPUpdateInterval = 1 / 30
    local ESPMaxAccumulator = ESPUpdateInterval * 2
    table.insert(Controller.Connections, RunService.RenderStepped:Connect(function(DeltaTime)
        Camera = workspace.CurrentCamera or Camera
        if not Camera then
            return
        end

        if not ESPSettings.Enabled then
            if ESPWasActive then
                for _, Data in pairs(ESPObjects) do
                    HideESP(Data)
                end
                ESPWasActive = false
            end
            ESPAccumulator = 0
            return
        end

        ESPAccumulator = math.min(ESPAccumulator + (DeltaTime or 0), ESPMaxAccumulator)
        if ESPAccumulator < ESPUpdateInterval then
            return
        end
        ESPAccumulator %= ESPUpdateInterval
        ESPWasActive = true

        local ActiveCamera = Camera
        local Viewport = ActiveCamera.ViewportSize
        local LocalRoot = getRootPart(LocalPlayer.Character)
        for Target, Data in pairs(ESPObjects) do
            local IsPlayer = isPlayerTarget(Target)
            local IsAlive = IsPlayer
                and Target.Parent == Players
                or (not IsPlayer and Target.Parent ~= nil and Target:IsA("Model"))
            if not IsAlive then
                RemoveESP(Target)
            else
                local ok, err = pcall(UpdateEntityESP, Target, Data, LocalRoot, ActiveCamera, Viewport)
                if not ok then
                    pcall(HideESP, Data)
                    if not Data.ErrorReported then
                        Data.ErrorReported = true
                        warn("ESP update failed for " .. getTargetName(Target) .. ": " .. tostring(err))
                    end
                elseif Data.ErrorReported then
                    Data.ErrorReported = nil
                end
            end
        end
    end))
end
