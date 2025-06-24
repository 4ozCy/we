loadstring(game:HttpGet("https://raw.githubusercontent.com/Pixeluted/adoniscries/main/Source.lua", true))() -- Adonis Bypass

task.wait(0.6)

local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/SiriusSoftwareLtd/Rayfield/main/source.lua'))()

Rayfield:Notify({
   Title = "Welcome To Celvyn!",
   Content = "Thanks for using our script.",
   Duration = 5,
   Image = 119663846201777,
})

local Window = Rayfield:CreateWindow({
   Name = "Celvyn | Beta",
   Icon = 119663846201777,
   LoadingTitle = "Celvyn",
   LoadingSubtitle = "by @.03cc",
   ShowText = "Celvyn",
   ToggleUIKeybind = "R",
   Theme = "Default",
   }
})

local Tab = Window:CreateTab("Main", "box")

local Section = Tab:CreateSection("Main Section")

local Button = Tab:CreateButton({
      Name = "Sell All",
      Callback = function()
local args = {
workspace:WaitForChild("World"):WaitForChild("NPCs"):WaitForChild("Rocky")}
game:GetService("ReplicatedStorage"):WaitForChild("DialogueRemotes"):WaitForChild("SellAllItems"):FireServer(unpack(args))
end,
});

local selectedOption = "Monk Palace"

local Dropdown = Tab:CreateDropdown({
    Name = "Select Teleport Location",
    Options = {"Monk Palace", "Azure Hollow"},
    CurrentOption = {"Monk Palace"},
    MultipleOptions = false,
    Flag = "TeleportDropdown",
    Callback = function(Options)
        selectedOption = Options[1]
    end,
})

local Butto= Tab:CreateButton({
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
