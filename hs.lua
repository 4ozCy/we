Sliderliderlideribrary = loadstring(game:HttpGet("https://raw.githubusercontent.com/Turtle-Brand/Turtle-Lib/main/source.lua"))()
local w = library:Window("Hypershot")

w:Button("silent aim", function()
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()
local WorldToScreenPoint = Camera.WorldToScreenPoint
local GetPlayers = Players.GetPlayers
local FindFirstChild = game.FindFirstChild
local function GetOnScreenPosition(V3)
local Position, IsVisible = WorldToScreenPoint(Camera, V3)
return Vector2.new(Position.X, Position.Y), IsVisible
end
local function GetDirection(Origin, Position)
 return (Position - Origin).Unit * (Origin - Position).Magnitude
end
local function GetMousePosition()
 return Vector2.new(Mouse.X, Mouse.Y)
end
local function GetClosestPlayer()
local Closest, Distance = nil, 10000
for _, Player in next, GetPlayers(Players) do
if Player ~= LocalPlayer then
local Character = Player.Character
local Head = Character and FindFirstChild(Character, "Head")
local Humanoid = Character and FindFirstChild(Character, 
"Humanoid")
if Head and (Humanoid and Humanoid.Health > 0) then
local ScreenPos, IsVisible = 
GetOnScreenPosition(Head.Position)
if IsVisible then
local _Distance = (GetMousePosition() - 
ScreenPos).Magnitude
if _Distance <= Distance then
Closest = Head
Distance = _Distance
end
end
end
end
end
return Closest, Distance
end
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(...)
local Method = getnamecallmethod()
local Arguments = {...}
if Arguments[1] == workspace and Method == "Raycast" then
if typeof(Arguments[#Arguments]) ~= "RaycastParams" then
return oldNamecall(...)
end
local HitPart = GetClosestPlayer()
if HitPart then
Arguments[3] = GetDirection(Arguments[2], HitPart.Position)
return oldNamecall(unpack(Arguments))
end
end
return oldNamecall(...)
end)
print("??")
end)

w:Button("No Skill Cooldown", function()
for _, v in next, getgc(true) do
    if typeof(v) == 'table' and rawget(v, 'CD') then
        rawset(v, 'CD', 0)
    end
  end
 end)

w:Slider("Hitbox", 1, 100,50, function(value)
    _G.HeadSize = value
    _G.Disabled = false

    local Players = game:GetService('Players')
    local RunService = game:GetService('RunService')
    local LocalPlayer = Players.LocalPlayer
    local MobsFolder = workspace:FindFirstChild("Mobs")

    local function applyPropertiesToPart(part)
        if part then
            part.Size = Vector3.new(_G.HeadSize, _G.HeadSize, _G.HeadSize)
            part.Transparency = 0.7
            part.BrickColor = BrickColor.new("Really blue")
            part.Material = Enum.Material.Neon
            part.CanCollide = false
        end
    end

    local function applyHighlight(model, color)
        if not model:FindFirstChild("HighlightESP") then
            local highlight = Instance.new("Highlight")
            highlight.Name = "HighlightESP"
            highlight.FillColor = color
            highlight.OutlineColor = Color3.new(0, 0, 0)
            highlight.FillTransparency = 0.3
            highlight.OutlineTransparency = 0
            highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            highlight.Parent = model
            highlight.Adornee = model
        end
    end

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            pcall(function()
                applyPropertiesToPart(player.Character.HumanoidRootPart)
                applyHighlight(player.Character, Color3.fromRGB(0, 170, 255))
            end)
        end
    end

    if MobsFolder then
        for _, mob in ipairs(MobsFolder:GetChildren()) do
            if mob:IsA("Model") and mob:FindFirstChild("HumanoidRootPart") then
                pcall(function()
                    applyPropertiesToPart(mob.HumanoidRootPart)
                    applyHighlight(mob, Color3.fromRGB(255, 0, 0))
                end)
            end
        end
    end
end)
