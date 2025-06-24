loadstring(game:HttpGet("https://raw.githubusercontent.com/Pixeluted/adoniscries/main/Source.lua", true))() -- Adonis Bypass

task.wait(0.6)

local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/SiriusSoftwareLtd/Rayfield/main/source.lua'))()

Rayfield:Notify({
   Title = "Welcome To Celvyn!",
   Content = "Thanks for using our script.",
   Duration = 5,
   Image = 119663846201777,
})

local CustomTheme = {
    TextColor = Color3.fromRGB(220, 220, 220),
    Background = Color3.fromRGB(10, 10, 10),
    Topbar = Color3.fromRGB(15, 15, 15),
    Shadow = Color3.fromRGB(5, 5, 5),
    NotificationBackground = Color3.fromRGB(12, 12, 12),
    NotificationActionsBackground = Color3.fromRGB(180, 180, 180),
    TabBackground = Color3.fromRGB(30, 30, 30),
    TabStroke = Color3.fromRGB(40, 40, 40),
    TabBackgroundSelected = Color3.fromRGB(70, 70, 70),
    TabTextColor = Color3.fromRGB(200, 200, 200),
    SelectedTabTextColor = Color3.fromRGB(240, 240, 240),
    ElementBackground = Color3.fromRGB(20, 20, 20),
    ElementBackgroundHover = Color3.fromRGB(30, 30, 30),
    SecondaryElementBackground = Color3.fromRGB(15, 15, 15),
    ElementStroke = Color3.fromRGB(35, 35, 35),
    SecondaryElementStroke = Color3.fromRGB(25, 25, 25),
    SliderBackground = Color3.fromRGB(40, 120, 200),
    SliderProgress = Color3.fromRGB(40, 120, 200),
    SliderStroke = Color3.fromRGB(50, 140, 230),
    ToggleBackground = Color3.fromRGB(20, 20, 20),
    ToggleEnabled = Color3.fromRGB(0, 120, 190),
    ToggleDisabled = Color3.fromRGB(80, 80, 80),
    ToggleEnabledStroke = Color3.fromRGB(0, 140, 220),
    ToggleDisabledStroke = Color3.fromRGB(100, 100, 100),
    ToggleEnabledOuterStroke = Color3.fromRGB(80, 80, 80),
    ToggleDisabledOuterStroke = Color3.fromRGB(50, 50, 50),
    DropdownSelected = Color3.fromRGB(25, 25, 25),
    DropdownUnselected = Color3.fromRGB(15, 15, 15),
    InputBackground = Color3.fromRGB(20, 20, 20),
    InputStroke = Color3.fromRGB(50, 50, 50),
    PlaceholderColor = Color3.fromRGB(140, 140, 140)
}

local Window = Rayfield:CreateWindow({
   Name = "Dig",
   Icon = 119663846201777,
   LoadingTitle = "Celvyn",
   LoadingSubtitle = "by @.03cc",
   ShowText = "Celvyn",
   ToggleUIKeybind = "R",
   Theme = CustomTheme
})

local Tab = Window:CreateTab("Main", "box")

local Section = Tab:CreateSection("Main Section")

local Divider = Tab:CreateDivider()

local selectedOption = "Monk Palace"

local Dropdown = Tab:CreateDropdown({
    Name = "Select Teleport Location",
    Options = {"Monk Palace", "Azure Hollow"},
    CurrentOption = {"Monk Palace"},
    MultipleOptions = false,
    Callback = function(Options)
        selectedOption = Options[1]
    end,
});

local Button = Tab:CreateButton({
    Name = "Teleport",
    Callback = function()
        local pos
        if selectedOption == "Monk Palace" then
            pos = Vector3.new(4545.35, -360.04, -1626.06)
        elseif selectedOption == "Azure Hollow" then
            pos = Vector3.new(4130.15, -672.86, 2552.10)
        end

        if pos then
            local char = game.Players.LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                char.HumanoidRootPart.CFrame = CFrame.new(pos)
            end
        end
    end,
});

local Divider = Tab:CreateDivider()

local Button = Tab:CreateButton({
      Name = "Sell All",
      Callback = function()
local args = {
workspace:WaitForChild("World"):WaitForChild("NPCs"):WaitForChild("Rocky")}
game:GetService("ReplicatedStorage"):WaitForChild("DialogueRemotes"):WaitForChild("SellAllItems"):FireServer(unpack(args))
end,
});
