library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Turtle-Brand/Turtle-Lib/main/source.lua"))()
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

w:Button("Gun Mod", function()
getgenv().ToggleNoSpread = true
getgenv().ToggleInfiniteAmmo = true
getgenv().ToggleNoRecoil = true
getgenv().ToggleInstantReload = true

getgenv().BaseSpread = 0
getgenv().Spread = 0
getgenv().Ammo = 10000
getgenv().FillAmmo = 10000
getgenv().Debounce = 0.1
getgenv().ReloadTime = 0.1
getgenv().Auto = true

getgenv().MinCamRecoil = Vector3.new(0,0,0)
getgenv().MaxCamRecoil = Vector3.new(0,0,0)
getgenv().CamRecoilConstant = 0

getgenv().MinRotRecoil = Vector3.new(0,0,0)
getgenv().MaxRotRecoil = Vector3.new(0,0,0)
getgenv().RotRecoilConstant = 0

getgenv().MinTransRecoil = Vector3.new(0,0,0)
getgenv().MaxTransRecoil = Vector3.new(0,0,0)
getgenv().TransRecoilConstant = 0

local function deepCopy(tbl)
    if type(tbl) ~= "table" then return tbl end
    local copy = {}
    for k, v in pairs(tbl) do
        copy[k] = type(v) == "table" and deepCopy(v) or v
    end
    return copy
end

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ModulesFolder = ReplicatedStorage:WaitForChild("Weapons"):WaitForChild("Modules")

getgenv()._OriginalWeaponData = getgenv()._OriginalWeaponData or {}

local function getGlobalOrDefault(name, default)
    local val = getgenv()[name]
    if val == nil then
        return default
    end
    return val
end

for _, module in pairs(ModulesFolder:GetChildren()) do
    if module:IsA("ModuleScript") then
        local success, weaponData = pcall(require, module)
        if success and type(weaponData) == "table" then
            local name = module.Name
            if not getgenv()._OriginalWeaponData[name] then
                getgenv()._OriginalWeaponData[name] = deepCopy(weaponData)
            end

            local original = getgenv()._OriginalWeaponData[name]

            if getgenv().ToggleNoSpread then
                weaponData.BaseSpread = getGlobalOrDefault("BaseSpread", weaponData.BaseSpread)
                weaponData.Spread = getGlobalOrDefault("Spread", weaponData.Spread)
            else
                weaponData.BaseSpread = original.BaseSpread
                weaponData.Spread = original.Spread
            end

            if getgenv().ToggleInfiniteAmmo then
                weaponData.Ammo = getGlobalOrDefault("Ammo", weaponData.Ammo)
                weaponData.FillAmmo = getGlobalOrDefault("FillAmmo", weaponData.FillAmmo)
            else
                weaponData.Ammo = original.Ammo
                weaponData.FillAmmo = original.FillAmmo
            end

            if getgenv().ToggleInstantReload then
                weaponData.ReloadTime = getGlobalOrDefault("ReloadTime", weaponData.ReloadTime)
                weaponData.Debounce = getGlobalOrDefault("Debounce", weaponData.Debounce)
            else
                weaponData.ReloadTime = original.ReloadTime
                weaponData.Debounce = original.Debounce
            end

            if getgenv().ToggleNoRecoil then
                weaponData.MinCamRecoil = getGlobalOrDefault("MinCamRecoil", weaponData.MinCamRecoil)
                weaponData.MaxCamRecoil = getGlobalOrDefault("MaxCamRecoil", weaponData.MaxCamRecoil)
                weaponData.CamRecoilConstant = getGlobalOrDefault("CamRecoilConstant", weaponData.CamRecoilConstant)

                weaponData.MinRotRecoil = getGlobalOrDefault("MinRotRecoil", weaponData.MinRotRecoil)
                weaponData.MaxRotRecoil = getGlobalOrDefault("MaxRotRecoil", weaponData.MaxRotRecoil)
                weaponData.RotRecoilConstant = getGlobalOrDefault("RotRecoilConstant", weaponData.RotRecoilConstant)

                weaponData.MinTransRecoil = getGlobalOrDefault("MinTransRecoil", weaponData.MinTransRecoil)
                weaponData.MaxTransRecoil = getGlobalOrDefault("MaxTransRecoil", weaponData.MaxTransRecoil)
                weaponData.TransRecoilConstant = getGlobalOrDefault("TransRecoilConstant", weaponData.TransRecoilConstant)
            else
                weaponData.MinCamRecoil = original.MinCamRecoil
                weaponData.MaxCamRecoil = original.MaxCamRecoil
                weaponData.CamRecoilConstant = original.CamRecoilConstant

                weaponData.MinRotRecoil = original.MinRotRecoil
                weaponData.MaxRotRecoil = original.MaxRotRecoil
                weaponData.RotRecoilConstant = original.RotRecoilConstant

                weaponData.MinTransRecoil = original.MinTransRecoil
                weaponData.MaxTransRecoil = original.MaxTransRecoil
                weaponData.TransRecoilConstant = original.TransRecoilConstant
            end

            weaponData.Auto = true
        end
    end
end
end)

w:Box("Hitbox", function(text, focuslost)
    if not focuslost then return end
    local value = tonumber(text)
    if not value then return end
    _G.HeadSize = math.clamp(value, 1, 50)
    _G.Disabled = false

    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
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
