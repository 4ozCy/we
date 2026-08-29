local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Camera = workspace.CurrentCamera

local Settings = {
    ESPEnabled = true,
    TeamCheck = false,
    TeamColor = true,
    MaxDistance = 1000,
    CornerLength = 0.28,
    BoxThickness = 1.5,
    DefaultColor = Color3.fromRGB(255, 255, 255),
    TextColor = Color3.fromRGB(245, 245, 250),
    HealthColor = true
}

local OldGui = PlayerGui:FindFirstChild("CelvynESP")
if OldGui then
    OldGui:Destroy()
end

local ESPObjects = {}

local function CreateLine()
    local Line = Drawing.new("Line")
    Line.Thickness = Settings.BoxThickness
    Line.Transparency = 1
    Line.Visible = false
    return Line
end

local function CreateESP(Player)
    if ESPObjects[Player] then
        return
    end

    local Data = {
        Lines = {},
        HealthBar = CreateLine(),
        HealthBackground = CreateLine(),
        Username = Drawing.new("Text"),
        Distance = Drawing.new("Text"),
        HealthText = Drawing.new("Text")
    }

    for i = 1, 8 do
        Data.Lines[i] = CreateLine()
    end

    Data.Username.Size = 13
    Data.Username.Center = true
    Data.Username.Outline = true
    Data.Username.OutlineColor = Color3.fromRGB(0, 0, 0)
    Data.Username.Color = Settings.TextColor
    Data.Username.Visible = false

    Data.Distance.Size = 12
    Data.Distance.Center = true
    Data.Distance.Outline = true
    Data.Distance.OutlineColor = Color3.fromRGB(0, 0, 0)
    Data.Distance.Color = Settings.TextColor
    Data.Distance.Visible = false

    Data.HealthText.Size = 12
    Data.HealthText.Center = true
    Data.HealthText.Outline = true
    Data.HealthText.OutlineColor = Color3.fromRGB(0, 0, 0)
    Data.HealthText.Color = Settings.TextColor
    Data.HealthText.Visible = false

    ESPObjects[Player] = Data
end

local function HideESP(Data)
    for _, Line in ipairs(Data.Lines) do
        Line.Visible = false
    end

    Data.HealthBar.Visible = false
    Data.HealthBackground.Visible = false
    Data.Username.Visible = false
    Data.Distance.Visible = false
    Data.HealthText.Visible = false
end

local function RemoveESP(Player)
    local Data = ESPObjects[Player]

    if not Data then
        return
    end

    for _, Line in ipairs(Data.Lines) do
        pcall(function()
            Line:Remove()
        end)
    end

    pcall(function()
        Data.HealthBar:Remove()
        Data.HealthBackground:Remove()
        Data.Username:Remove()
        Data.Distance:Remove()
        Data.HealthText:Remove()
    end)

    ESPObjects[Player] = nil
end

local function GetPlayerColor(Player)
    if Settings.TeamColor and Player.TeamColor then
        return Player.TeamColor.Color
    end

    return Settings.DefaultColor
end

local function GetBoundingBox(Character)
    local Parts = {}

    for _, Object in ipairs(Character:GetChildren()) do
        if Object:IsA("BasePart") then
            table.insert(Parts, Object)
        end
    end

    if #Parts == 0 then
        return nil
    end

    local MinX = math.huge
    local MinY = math.huge
    local MaxX = -math.huge
    local MaxY = -math.huge
    local Visible = false

    for _, Part in ipairs(Parts) do
        local Size = Part.Size
        local CF = Part.CFrame

        local Corners = {
            CF * Vector3.new(-Size.X / 2, -Size.Y / 2, -Size.Z / 2),
            CF * Vector3.new(-Size.X / 2, -Size.Y / 2, Size.Z / 2),
            CF * Vector3.new(-Size.X / 2, Size.Y / 2, -Size.Z / 2),
            CF * Vector3.new(-Size.X / 2, Size.Y / 2, Size.Z / 2),
            CF * Vector3.new(Size.X / 2, -Size.Y / 2, -Size.Z / 2),
            CF * Vector3.new(Size.X / 2, -Size.Y / 2, Size.Z / 2),
            CF * Vector3.new(Size.X / 2, Size.Y / 2, -Size.Z / 2),
            CF * Vector3.new(Size.X / 2, Size.Y / 2, Size.Z / 2)
        }

        for _, Corner in ipairs(Corners) do
            local ScreenPosition, OnScreen = Camera:WorldToViewportPoint(Corner)

            if OnScreen and ScreenPosition.Z > 0 then
                Visible = true
            end

            if ScreenPosition.Z > 0 then
                MinX = math.min(MinX, ScreenPosition.X)
                MinY = math.min(MinY, ScreenPosition.Y)
                MaxX = math.max(MaxX, ScreenPosition.X)
                MaxY = math.max(MaxY, ScreenPosition.Y)
            end
        end
    end

    if not Visible or MinX == math.huge then
        return nil
    end

    return MinX, MinY, MaxX, MaxY
end

local function UpdateCornerBox(Data, X, Y, Width, Height, Color)
    local CX = X + Width
    local CY = Y + Height

    local Horizontal = math.max(Width * Settings.CornerLength, 8)
    local Vertical = math.max(Height * Settings.CornerLength, 8)

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

    for _, Line in ipairs(Lines) do
        Line.Color = Color
        Line.Thickness = Settings.BoxThickness
        Line.Visible = true
    end
end

local function UpdatePlayerESP(Player, Data)
    if not Settings.ESPEnabled or Player == LocalPlayer then
        HideESP(Data)
        return
    end

    if Settings.TeamCheck and LocalPlayer.Team and Player.Team == LocalPlayer.Team then
        HideESP(Data)
        return
    end

    local Character = Player.Character

    if not Character then
        HideESP(Data)
        return
    end

    local Humanoid = Character:FindFirstChildOfClass("Humanoid")
    local Root = Character:FindFirstChild("HumanoidRootPart")

    if not Humanoid or not Root or Humanoid.Health <= 0 then
        HideESP(Data)
        return
    end

    local LocalCharacter = LocalPlayer.Character
    local LocalRoot = LocalCharacter and LocalCharacter:FindFirstChild("HumanoidRootPart")

    if not LocalRoot then
        HideESP(Data)
        return
    end

    local Distance = (Root.Position - LocalRoot.Position).Magnitude

    if Distance > Settings.MaxDistance then
        HideESP(Data)
        return
    end

    local X1, Y1, X2, Y2 = GetBoundingBox(Character)

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

    UpdateCornerBox(Data, X1, Y1, Width, Height, Color)

    local HealthPercent = math.clamp(
        Humanoid.Health / math.max(Humanoid.MaxHealth, 1),
        0,
        1
    )

    local HealthHeight = Height * HealthPercent

    Data.HealthBackground.From = Vector2.new(X1 - 6, Y1)
    Data.HealthBackground.To = Vector2.new(X1 - 6, Y2)
    Data.HealthBackground.Color = Color3.fromRGB(30, 30, 35)
    Data.HealthBackground.Thickness = 4
    Data.HealthBackground.Visible = true

    Data.HealthBar.From = Vector2.new(X1 - 6, Y2)
    Data.HealthBar.To = Vector2.new(X1 - 6, Y2 - HealthHeight)
    Data.HealthBar.Color = Settings.HealthColor and Color3.fromRGB(
        math.floor(255 * (1 - HealthPercent)),
        math.floor(255 * HealthPercent),
        60
    ) or Color3.fromRGB(100, 255, 150)
    Data.HealthBar.Thickness = 2
    Data.HealthBar.Visible = true

    Data.Username.Text = Player.DisplayName .. "  @" .. Player.Name
    Data.Username.Position = Vector2.new(X1 + Width / 2, Y1 - 18)
    Data.Username.Visible = true

    Data.Distance.Text = string.format("%dm", math.floor(Distance))
    Data.Distance.Position = Vector2.new(X1 + Width / 2, Y2 + 5)
    Data.Distance.Visible = true

    Data.HealthText.Text = string.format("%d%%", math.floor(HealthPercent * 100))
    Data.HealthText.Position = Vector2.new(X1 - 28, Y1 + Height / 2)
    Data.HealthText.Visible = true
end

for _, Player in ipairs(Players:GetPlayers()) do
    if Player ~= LocalPlayer then
        CreateESP(Player)
    end
end

Players.PlayerAdded:Connect(function(Player)
    CreateESP(Player)
end)

Players.PlayerRemoving:Connect(function(Player)
    RemoveESP(Player)
end)

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CelvynESP"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = PlayerGui

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 350, 0, 380)
Main.Position = UDim2.new(0.5, -175, 0.5, -190)
Main.BackgroundColor3 = Color3.fromRGB(13, 13, 17)
Main.BackgroundTransparency = 0.12
Main.BorderSizePixel = 0
Main.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 18)
MainCorner.Parent = Main

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(255, 255, 255)
MainStroke.Transparency = 0.82
MainStroke.Parent = Main

local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 65)
Header.BackgroundTransparency = 1
Header.Parent = Main

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -80, 0, 30)
Title.Position = UDim2.new(0, 20, 0, 10)
Title.BackgroundTransparency = 1
Title.Text = "Celvyn"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 22
Title.TextColor3 = Color3.fromRGB(245, 245, 250)
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

local Subtitle = Instance.new("TextLabel")
Subtitle.Size = UDim2.new(1, -80, 0, 20)
Subtitle.Position = UDim2.new(0, 20, 0, 36)
Subtitle.BackgroundTransparency = 1
Subtitle.Text = "Corner ESP"
Subtitle.Font = Enum.Font.Gotham
Subtitle.TextSize = 12
Subtitle.TextColor3 = Color3.fromRGB(145, 145, 155)
Subtitle.TextXAlignment = Enum.TextXAlignment.Left
Subtitle.Parent = Header

local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 34, 0, 34)
CloseButton.Position = UDim2.new(1, -48, 0, 15)
CloseButton.BackgroundColor3 = Color3.fromRGB(255, 70, 70)
CloseButton.BackgroundTransparency = 0.2
CloseButton.BorderSizePixel = 0
CloseButton.Text = "×"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.Font = Enum.Font.GothamBold
CloseButton.TextSize = 22
CloseButton.AutoButtonColor = false
CloseButton.Parent = Header

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 10)
CloseCorner.Parent = CloseButton

local Status = Instance.new("TextLabel")
Status.Size = UDim2.new(1, -40, 0, 22)
Status.Position = UDim2.new(0, 20, 0, 70)
Status.BackgroundTransparency = 1
Status.Text = "●  ESP ENABLED"
Status.Font = Enum.Font.GothamMedium
Status.TextSize = 13
Status.TextColor3 = Color3.fromRGB(100, 255, 160)
Status.TextXAlignment = Enum.TextXAlignment.Left
Status.Parent = Main

local function CreateToggle(Text, Position)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, -40, 0, 43)
    Button.Position = Position
    Button.BackgroundColor3 = Color3.fromRGB(45, 45, 53)
    Button.BackgroundTransparency = 0.15
    Button.BorderSizePixel = 0
    Button.Text = Text
    Button.TextColor3 = Color3.fromRGB(235, 235, 240)
    Button.Font = Enum.Font.GothamMedium
    Button.TextSize = 13
    Button.AutoButtonColor = false
    Button.Parent = Main

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 11)
    Corner.Parent = Button

    return Button
end

local ESPButton = CreateToggle("ESP: ON", UDim2.new(0, 20, 0, 100))
local TeamButton = CreateToggle("Team Check: OFF", UDim2.new(0, 20, 0, 151))
local ColorButton = CreateToggle("Team Colors: ON", UDim2.new(0, 20, 0, 202))

local DistanceLabel = Instance.new("TextLabel")
DistanceLabel.Size = UDim2.new(1, -40, 0, 20)
DistanceLabel.Position = UDim2.new(0, 20, 0, 257)
DistanceLabel.BackgroundTransparency = 1
DistanceLabel.Text = "Max Distance: 1000m"
DistanceLabel.Font = Enum.Font.GothamMedium
DistanceLabel.TextSize = 13
DistanceLabel.TextColor3 = Color3.fromRGB(220, 220, 225)
DistanceLabel.TextXAlignment = Enum.TextXAlignment.Left
DistanceLabel.Parent = Main

local DistanceBar = Instance.new("Frame")
DistanceBar.Size = UDim2.new(1, -40, 0, 6)
DistanceBar.Position = UDim2.new(0, 20, 0, 286)
DistanceBar.BackgroundColor3 = Color3.fromRGB(55, 55, 63)
DistanceBar.BorderSizePixel = 0
DistanceBar.Parent = Main

local DistanceCorner = Instance.new("UICorner")
DistanceCorner.CornerRadius = UDim.new(1, 0)
DistanceCorner.Parent = DistanceBar

local DistanceFill = Instance.new("Frame")
DistanceFill.Size = UDim2.new(1, 0, 1, 0)
DistanceFill.BackgroundColor3 = Color3.fromRGB(135, 135, 145)
DistanceFill.BorderSizePixel = 0
DistanceFill.Parent = DistanceBar

local DistanceFillCorner = Instance.new("UICorner")
DistanceFillCorner.CornerRadius = UDim.new(1, 0)
DistanceFillCorner.Parent = DistanceFill

local HealthButton = CreateToggle("Health Colors: ON", UDim2.new(0, 20, 0, 307))

local Footer = Instance.new("TextLabel")
Footer.Size = UDim2.new(1, -40, 0, 20)
Footer.Position = UDim2.new(0, 20, 1, -25)
Footer.BackgroundTransparency = 1
Footer.Text = "Celvyn Hub • Corner ESP"
Footer.Font = Enum.Font.Gotham
Footer.TextSize = 10
Footer.TextColor3 = Color3.fromRGB(100, 100, 110)
Footer.TextXAlignment = Enum.TextXAlignment.Left
Footer.Parent = Main

local OpenButton = Instance.new("TextButton")
OpenButton.Size = UDim2.new(0, 92, 0, 42)
OpenButton.Position = UDim2.new(0, 18, 0.5, -21)
OpenButton.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
OpenButton.BackgroundTransparency = 0.08
OpenButton.BorderSizePixel = 0
OpenButton.Text = "OPEN ESP"
OpenButton.TextColor3 = Color3.fromRGB(245, 245, 250)
OpenButton.Font = Enum.Font.GothamBold
OpenButton.TextSize = 12
OpenButton.Visible = false
OpenButton.AutoButtonColor = false
OpenButton.Parent = ScreenGui

local OpenCorner = Instance.new("UICorner")
OpenCorner.CornerRadius = UDim.new(0, 12)
OpenCorner.Parent = OpenButton

local OpenStroke = Instance.new("UIStroke")
OpenStroke.Color = Color3.fromRGB(255, 255, 255)
OpenStroke.Transparency = 0.72
OpenStroke.Parent = OpenButton

local function UpdateButtons()
    ESPButton.Text = Settings.ESPEnabled and "ESP: ON" or "ESP: OFF"
    ESPButton.BackgroundColor3 = Settings.ESPEnabled and Color3.fromRGB(45, 85, 65) or Color3.fromRGB(65, 45, 48)

    Status.Text = Settings.ESPEnabled and "●  ESP ENABLED" or "●  ESP DISABLED"
    Status.TextColor3 = Settings.ESPEnabled and Color3.fromRGB(100, 255, 160) or Color3.fromRGB(255, 120, 120)

    TeamButton.Text = Settings.TeamCheck and "Team Check: ON" or "Team Check: OFF"
    TeamButton.BackgroundColor3 = Settings.TeamCheck and Color3.fromRGB(45, 85, 65) or Color3.fromRGB(45, 45, 53)

    ColorButton.Text = Settings.TeamColor and "Team Colors: ON" or "Team Colors: OFF"
    ColorButton.BackgroundColor3 = Settings.TeamColor and Color3.fromRGB(45, 85, 65) or Color3.fromRGB(45, 45, 53)

    HealthButton.Text = Settings.HealthColor and "Health Colors: ON" or "Health Colors: OFF"
    HealthButton.BackgroundColor3 = Settings.HealthColor and Color3.fromRGB(45, 85, 65) or Color3.fromRGB(45, 45, 53)
end

ESPButton.MouseButton1Click:Connect(function()
    Settings.ESPEnabled = not Settings.ESPEnabled
    UpdateButtons()
end)

TeamButton.MouseButton1Click:Connect(function()
    Settings.TeamCheck = not Settings.TeamCheck
    UpdateButtons()
end)

ColorButton.MouseButton1Click:Connect(function()
    Settings.TeamColor = not Settings.TeamColor
    UpdateButtons()
end)

HealthButton.MouseButton1Click:Connect(function()
    Settings.HealthColor = not Settings.HealthColor
    UpdateButtons()
end)

local DistanceDragging = false

local function UpdateDistance(Input)
    local X = Input.Position.X
    local Start = DistanceBar.AbsolutePosition.X
    local Width = DistanceBar.AbsoluteSize.X
    local Percent = math.clamp((X - Start) / Width, 0, 1)

    Settings.MaxDistance = math.floor(100 + Percent * 4900)
    DistanceFill.Size = UDim2.new(Percent, 0, 1, 0)
    DistanceLabel.Text = "Max Distance: " .. Settings.MaxDistance .. "m"
end

DistanceBar.InputBegan:Connect(function(Input)
    if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
        DistanceDragging = true
        UpdateDistance(Input)
    end
end)

UserInputService.InputChanged:Connect(function(Input)
    if DistanceDragging and (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch) then
        UpdateDistance(Input)
    end
end)

UserInputService.InputEnded:Connect(function(Input)
    if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
        DistanceDragging = false
    end
end)

CloseButton.MouseButton1Click:Connect(function()
    Main.Visible = false
    OpenButton.Visible = true
end)

OpenButton.MouseButton1Click:Connect(function()
    Main.Visible = true
    OpenButton.Visible = false
end)

local Dragging = false
local DragStart
local StartPosition

Header.InputBegan:Connect(function(Input)
    if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
        Dragging = true
        DragStart = Input.Position
        StartPosition = Main.Position
    end
end)

UserInputService.InputChanged:Connect(function(Input)
    if Dragging and (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch) then
        local Delta = Input.Position - DragStart

        Main.Position = UDim2.new(
            StartPosition.X.Scale,
            StartPosition.X.Offset + Delta.X,
            StartPosition.Y.Scale,
            StartPosition.Y.Offset + Delta.Y
        )
    end
end)

UserInputService.InputEnded:Connect(function(Input)
    if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
        Dragging = false
    end
end)

local OpenDragging = false
local OpenDragStart
local OpenStartPosition

OpenButton.InputBegan:Connect(function(Input)
    if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
        OpenDragging = true
        OpenDragStart = Input.Position
        OpenStartPosition = OpenButton.Position
    end
end)

UserInputService.InputChanged:Connect(function(Input)
    if OpenDragging and (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch) then
        local Delta = Input.Position - OpenDragStart

        OpenButton.Position = UDim2.new(
            OpenStartPosition.X.Scale,
            OpenStartPosition.X.Offset + Delta.X,
            OpenStartPosition.Y.Scale,
            OpenStartPosition.Y.Offset + Delta.Y
        )
    end
end)

UserInputService.InputEnded:Connect(function(Input)
    if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
        OpenDragging = false
    end
end)

UpdateButtons()

RunService.RenderStepped:Connect(function()
    Camera = workspace.CurrentCamera

    if not Camera then
        return
    end

    for Player, Data in pairs(ESPObjects) do
        if Player.Parent ~= Players then
            RemoveESP(Player)
        else
            UpdatePlayerESP(Player, Data)
        end
    end
end)
