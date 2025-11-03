-- PSF Remake 4.1 — Complete with Smooth Collapse/Expand + Color Shift
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")

-- Ensure data folder
if not player:FindFirstChild("PSFRemakeData") then
    local folder = Instance.new("Folder", player)
    folder.Name = "PSFRemakeData"
    local scriptsVal = Instance.new("StringValue", folder)
    scriptsVal.Name = "Scripts"
    scriptsVal.Value = "[]"
    local settingsVal = Instance.new("StringValue", folder)
    settingsVal.Name = "Settings"
    settingsVal.Value = "{}"
end

local dataFolder = player:FindFirstChild("PSFRemakeData")
local scriptsValue = dataFolder:FindFirstChild("Scripts")
local settingsValue = dataFolder:FindFirstChild("Settings")

-- JSON decode helper
local function decodeJSON(s, fallback)
    local ok, res = pcall(function() return HttpService:JSONDecode(s) end)
    if ok and type(res) == "table" then return res end
    return fallback
end

local savedScripts = decodeJSON(scriptsValue.Value, nil)
local demoScripts = savedScripts and #savedScripts>0 and savedScripts or {
    { name = "Hello", code = "print('Hello from PSF')" },
    { name = "Timer", code = "for i=1,5 do print('tick', i) wait(1) end" },
}

local savedSettings = decodeJSON(settingsValue.Value, {selected = 1})

-- UI Root
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "PSFRemakeUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = PlayerGui

-- Auto scale for mobile
local uiScale = Instance.new("UIScale", screenGui)
uiScale.Name = "AutoUIScale"
local function updateScale()
    local s = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize.X or 800
    local scale = math.clamp(s / 900, 0.8, 1.2)
    uiScale.Scale = scale
end
RunService.RenderStepped:Connect(updateScale)
updateScale()

-- Main container
local main = Instance.new("Frame", screenGui)
main.Name = "Main"
main.AnchorPoint = Vector2.new(0.5,0.5)
main.Position = UDim2.new(0.5,0,0.5,0)
main.Size = UDim2.new(0.92,0,0.78,0)
main.BackgroundColor3 = Color3.fromRGB(18,18,18)
main.BorderSizePixel = 0
main.ClipsDescendants = true
local mainCorner = Instance.new("UICorner", main)
mainCorner.CornerRadius = UDim.new(0,12)

-- Header
local header = Instance.new("Frame", main)
header.Name = "Header"
header.Size = UDim2.new(1,0,0,46)
header.Position = UDim2.new(0,0,0,0)
header.BackgroundTransparency = 1

local title = Instance.new("TextLabel", header)
title.Text = "PSF Remake 4.1"
title.Font = Enum.Font.GothamBold
title.TextSize = 20
title.TextColor3 = Color3.fromRGB(240,240,240)
title.BackgroundTransparency = 1
title.Position = UDim2.new(0,16,0,6)
title.Size = UDim2.new(0.5,0,1,0)
title.TextXAlignment = Enum.TextXAlignment.Left

-- Toolbar buttons
local toolbar = Instance.new("Frame", header)
toolbar.AnchorPoint = Vector2.new(1,0)
toolbar.Position = UDim2.new(1,-12,0,6)
toolbar.BackgroundTransparency = 1
toolbar.Size = UDim2.new(0,360,1,0)
local function makeBtn(parent,text,sizeX)
    local b = Instance.new("TextButton",parent)
    b.Text=text
    b.Font=Enum.Font.Gotham
    b.TextSize=14
    b.TextColor3=Color3.fromRGB(255,255,255)
    b.AutoButtonColor=true
    b.BackgroundColor3=Color3.fromRGB(38,38,38)
    b.Size=UDim2.new(0,sizeX or 72,0,30)
    b.BorderSizePixel=0
    Instance.new("UICorner",b).CornerRadius=UDim.new(0,6)
    return b
end
local runBtn = makeBtn(toolbar,"Run",72)
local newBtn = makeBtn(toolbar,"New",72)
local delBtn = makeBtn(toolbar,"Delete",72)
local clearConsoleBtn = makeBtn(toolbar,"Clear",72)
local exportBtn = makeBtn(toolbar,"Export",72)
local tbLayout = Instance.new("UIListLayout",toolbar)
tbLayout.FillDirection=Enum.FillDirection.Horizontal
tbLayout.HorizontalAlignment=Enum.HorizontalAlignment.Right
tbLayout.SortOrder=Enum.SortOrder.LayoutOrder
tbLayout.Padding=UDim.new(0,8)
toolbar.Size=UDim2.new(0,(72+8)*5,1,0)

-- Body
local body = Instance.new("Frame", main)
body.Position = UDim2.new(0,12,0,56)
body.Size = UDim2.new(1,-24,1,-68)
body.BackgroundTransparency=1

-- Left panel: script list
local left = Instance.new("Frame",body)
left.Size=UDim2.new(0.32,-8,1,0)
left.Position=UDim2.new(0,0,0,0)
left.BackgroundTransparency=1
local leftHeader = Instance.new("TextLabel", left)
leftHeader.Text="Scripts"
leftHeader.Font=Enum.Font.GothamSemibold
leftHeader.TextSize=16
leftHeader.TextColor3=Color3.fromRGB(230,230,230)
leftHeader.BackgroundTransparency=1
leftHeader.Size=UDim2.new(1,0,0,0.06*body.AbsoluteSize.Y)
leftHeader.Position=UDim2.new(0,0,0,0)
local listFrame = Instance.new("ScrollingFrame", left)
listFrame.Position=UDim2.new(0,0,0.06,8)
listFrame.Size=UDim2.new(1,0,0.94,-8)
listFrame.BackgroundColor3=Color3.fromRGB(24,24,24)
listFrame.BorderSizePixel=0
listFrame.ScrollBarThickness=8
local listCorner = Instance.new("UICorner",listFrame)
listCorner.CornerRadius=UDim.new(0,8)
local listUI = Instance.new("UIListLayout",listFrame)
listUI.Padding=UDim.new(0,8)
listUI.SortOrder=Enum.SortOrder.LayoutOrder
listUI.HorizontalAlignment=Enum.HorizontalAlignment.Center

-- Right panel: editor + console
local right = Instance.new("Frame", body)
right.Size=UDim2.new(0.68,0,1,0)
right.Position=UDim2.new(0.32,8,0,0)
right.BackgroundTransparency=1
local editorBox = Instance.new("TextBox", right)
editorBox.MultiLine=true
editorBox.ClearTextOnFocus=false
editorBox.TextWrapped=false
editorBox.TextXAlignment=Enum.TextXAlignment.Left
editorBox.TextYAlignment=Enum.TextYAlignment.Top
editorBox.Font=Enum.Font.Code
editorBox.TextSize=16
editorBox.Text="-- Выберите или создайте скрипт\n"
editorBox.BackgroundColor3=Color3.fromRGB(14,14,14)
editorBox.TextColor3=Color3.fromRGB(240,240,240)
editorBox.Size=UDim2.new(1,0,0.64,0)
editorBox.Position=UDim2.new(0,0,0.06,8)
Instance.new("UICorner",editorBox).CornerRadius=UDim.new(0,8)
local consoleFrame = Instance.new("ScrollingFrame", right)
consoleFrame.Position=UDim2.new(0,0,0.73,8)
consoleFrame.Size=UDim2.new(1,0,0.27,-8)
consoleFrame.BackgroundColor3=Color3.fromRGB(12,12,12)
consoleFrame.BorderSizePixel=0
consoleFrame.ScrollBarThickness=8
local consoleCorner = Instance.new("UICorner",consoleFrame)
consoleCorner.CornerRadius=UDim.new(0,8)
local consoleLabelInside = Instance.new("TextLabel", consoleFrame)
consoleLabelInside.Size=UDim2.new(1,-16,0,0)
consoleLabelInside.Position=UDim2.new(0,8,0,8)
consoleLabelInside.BackgroundTransparency=1
consoleLabelInside.TextXAlignment=Enum.TextXAlignment.Left
consoleLabelInside.TextYAlignment=Enum.TextYAlignment.Top
consoleLabelInside.Font=Enum.Font.Code
consoleLabelInside.TextSize=14
consoleLabelInside.TextColor3=Color3.fromRGB(220,220,220)
consoleLabelInside.Text=""
consoleLabelInside.TextWrapped=true
consoleLabelInside.AutomaticSize=Enum.AutomaticSize.Y

-- Collapse/Expand Button (bottom-left)
local collapsed = false
local rotateBtn = Instance.new("ImageButton", screenGui)
rotateBtn.Size = UDim2.new(0,40,0,40)
rotateBtn.Position = UDim2.new(0,10,1,-50)
rotateBtn.AnchorPoint = Vector2.new(0,0)
rotateBtn.Image = "rbxassetid://93738238823550"
rotateBtn.BackgroundTransparency = 1
rotateBtn.Rotation = 0

rotateBtn.MouseButton1Click:Connect(function()
    collapsed = not collapsed
end)

-- Animation variables
local animSpeed = 5
local colorTime = 0

-- Main loop
RunService.RenderStepped:Connect(function(dt)
    -- Rotate button
    rotateBtn.Rotation = (rotateBtn.Rotation + dt*90) % 360

    -- Collapse/Expand main UI
    local targetScale = collapsed and 0 or 1
    local currentScaleX = main.Size.X.Scale
    local currentScaleY = main.Size.Y.Scale
    local scaleX = currentScaleX + (targetScale - currentScaleX)*dt*animSpeed
    local scaleY = currentScaleY + (targetScale - currentScaleY)*dt*animSpeed
    main.Size = UDim2.new(scaleX,0,scaleY,0)
    main.ClipsDescendants = scaleY < 0.01
    body.Visible = scaleY > 0.01
    main.BackgroundTransparency = 1 - scaleY

    -- Smooth color transition (white ↔ black)
    colorTime = colorTime + dt
    local colorVal = (math.sin(colorTime) + 1)/2 -- 0..1
    local r = 18 + (240-18)*colorVal
    local g = 18 + (240-18)*colorVal
    local b = 18 + (240-18)*colorVal
    main.BackgroundColor3 = Color3.fromRGB(r,g,b)
end)
