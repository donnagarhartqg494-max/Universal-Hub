
--[[
    UNIVERSAL HUB V1
    Rayfield-inspired interface
    Client-side utilities
]]

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")

local Player = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local Settings = {
    Speed = 16,
    JumpPower = 50,
    FOV = 70,
    FlySpeed = 50,
    Language = "RU",
    Theme = "Purple"
}

local State = {
    Fly = false,
    InfiniteJump = false,
    FullBright = false
}

local function getCharacter()
    return Player.Character
end

local function getHumanoid()
    local char = getCharacter()
    return char and char:FindFirstChildOfClass("Humanoid")
end

-- GUI
local Gui = Instance.new("ScreenGui")
Gui.Name = "UniversalHub"
Gui.ResetOnSpawn = false
Gui.Parent = Player:WaitForChild("PlayerGui")

local Main = Instance.new("Frame")
Main.Size = UDim2.fromOffset(570, 390)
Main.Position = UDim2.new(0.5, -285, 0.5, -195)
Main.BackgroundColor3 = Color3.fromRGB(18, 18, 25)
Main.BorderSizePixel = 0
Main.Parent = Gui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 12)
Corner.Parent = Main

local Header = Instance.new("TextLabel")
Header.Size = UDim2.new(1, 0, 0, 48)
Header.BackgroundColor3 = Color3.fromRGB(28, 23, 43)
Header.Text = "  UNIVERSAL HUB  |  V1"
Header.TextColor3 = Color3.fromRGB(190, 130, 255)
Header.Font = Enum.Font.GothamBold
Header.TextSize = 17
Header.TextXAlignment = Enum.TextXAlignment.Left
Header.Parent = Main

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 12)
HeaderCorner.Parent = Header

local Close = Instance.new("TextButton")
Close.Size = UDim2.fromOffset(35, 30)
Close.Position = UDim2.new(1, -42, 0, 9)
Close.Text = "X"
Close.TextColor3 = Color3.new(1,1,1)
Close.BackgroundColor3 = Color3.fromRGB(120, 45, 65)
Close.Font = Enum.Font.GothamBold
Close.Parent = Header

Close.MouseButton1Click:Connect(function()
    Gui:Destroy()
end)

-- Drag
local dragging = false
local dragStart, startPos

Header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = Main.Position
    end
end)

UIS.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        Main.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

-- Sidebar
local Sidebar = Instance.new("Frame")
Sidebar.Position = UDim2.fromOffset(10, 60)
Sidebar.Size = UDim2.fromOffset(125, 320)
Sidebar.BackgroundColor3 = Color3.fromRGB(25, 24, 34)
Sidebar.Parent = Main

local SideLayout = Instance.new("UIListLayout")
SideLayout.Padding = UDim.new(0, 7)
SideLayout.Parent = Sidebar

-- Content
local Content = Instance.new("ScrollingFrame")
Content.Position = UDim2.fromOffset(145, 60)
Content.Size = UDim2.fromOffset(415, 320)
Content.BackgroundColor3 = Color3.fromRGB(23, 23, 31)
Content.BorderSizePixel = 0
Content.ScrollBarThickness = 4
Content.CanvasSize = UDim2.new(0, 0, 0, 0)
Content.Parent = Main

local Layout = Instance.new("UIListLayout")
Layout.Padding = UDim.new(0, 8)
Layout.Parent = Content

Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    Content.CanvasSize = UDim2.fromOffset(0, Layout.AbsoluteContentSize.Y + 15)
end)

local function clearContent()
    for _, child in ipairs(Content:GetChildren()) do
        if child:IsA("GuiObject") and child ~= Layout then
            child:Destroy()
        end
    end
end

local function label(text)
    local L = Instance.new("TextLabel")
    L.Size = UDim2.new(1, -12, 0, 30)
    L.BackgroundTransparency = 1
    L.Text = text
    L.TextColor3 = Color3.fromRGB(195, 155, 255)
    L.Font = Enum.Font.GothamBold
    L.TextSize = 15
    L.Parent = Content
end

local function button(text, callback)
    local B = Instance.new("TextButton")
    B.Size = UDim2.new(1, -12, 0, 35)
    B.BackgroundColor3 = Color3.fromRGB(48, 38, 65)
    B.TextColor3 = Color3.new(1,1,1)
    B.Text = text
    B.Font = Enum.Font.Gotham
    B.TextSize = 13
    B.Parent = Content

    local C = Instance.new("UICorner")
    C.CornerRadius = UDim.new(0, 7)
    C.Parent = B

    B.MouseButton1Click:Connect(callback)
end

local function toggle(text, initial, callback)
    local enabled = initial

    local B = Instance.new("TextButton")
    B.Size = UDim2.new(1, -12, 0, 35)
    B.BackgroundColor3 = Color3.fromRGB(42, 42, 53)
    B.TextColor3 = Color3.new(1,1,1)
    B.Font = Enum.Font.Gotham
    B.TextSize = 13
    B.Parent = Content

    local function update()
        B.Text = text .. (enabled and "  [ON]" or "  [OFF]")
        B.BackgroundColor3 = enabled
            and Color3.fromRGB(100, 55, 145)
            or Color3.fromRGB(42, 42, 53)
        callback(enabled)
    end

    B.MouseButton1Click:Connect(function()
        enabled = not enabled
        update()
    end)

    update()
end

local function slider(text, min, max, initial, callback)
    label(text .. ": " .. initial)

    local Box = Instance.new("TextBox")
    Box.Size = UDim2.new(1, -12, 0, 35)
    Box.BackgroundColor3 = Color3.fromRGB(42, 42, 53)
    Box.TextColor3 = Color3.new(1,1,1)
    Box.Text = tostring(initial)
    Box.PlaceholderText = min .. " - " .. max
    Box.Font = Enum.Font.Gotham
    Box.TextSize = 13
    Box.Parent = Content

    Box.FocusLost:Connect(function()
        local n = tonumber(Box.Text)
        if n then
            n = math.clamp(n, min, max)
            Box.Text = tostring(n)
            callback(n)
        else
            Box.Text = tostring(initial)
        end
    end)
end

-- Tabs
local function tab(name, callback)
    local B = Instance.new("TextButton")
    B.Size = UDim2.new(1, 0, 0, 35)
    B.BackgroundColor3 = Color3.fromRGB(50, 37, 69)
    B.TextColor3 = Color3.new(1,1,1)
    B.Text = name
    B.Font = Enum.Font.GothamBold
    B.TextSize = 12
    B.Parent = Sidebar

    B.MouseButton1Click:Connect(function()
        clearContent()
        callback()
    end)
end

-- MOVEMENT
tab("Movement", function()
    label("MOVEMENT")

    slider("Walk Speed", 0, 100, 16, function(v)
        Settings.Speed = v
        local h = getHumanoid()
        if h then h.WalkSpeed = v end
    end)

    slider("Jump Power", 0, 200, 50, function(v)
        Settings.JumpPower = v
        local h = getHumanoid()
        if h then
            h.UseJumpPower = true
            h.JumpPower = v
        end
    end)

    toggle("Infinite Jump", false, function(v)
        State.InfiniteJump = v
    end)
end)

UIS.JumpRequest:Connect(function()
    if State.InfiniteJump then
        local h = getHumanoid()
        if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

-- VISUALS
tab("Visuals", function()
    label("VISUAL SETTINGS")

    slider("Camera FOV", 40, 120, 70, function(v)
        Settings.FOV = v
        Camera.FieldOfView = v
    end)

    toggle("Full Bright", false, function(v)
        State.FullBright = v

        if v then
            Lighting.Brightness = 3
            Lighting.ClockTime = 14
            Lighting.GlobalShadows = false
        else
            Lighting.Brightness = 1
            Lighting.ClockTime = 14
            Lighting.GlobalShadows = true
        end
    end)
end)

-- PLAYER
tab("Player", function()
    label("PLAYER SETTINGS")

    button("Reset Character", function()
        local h = getHumanoid()
        if h then h.Health = 0 end
    end)

    button("Restore Defaults", function()
        local h = getHumanoid()
        if h then
            h.WalkSpeed = 16
            h.UseJumpPower = true
            h.JumpPower = 50
        end

        Camera.FieldOfView = 70
        Settings.Speed = 16
        Settings.JumpPower = 50
        Settings.FOV = 70
    end)
end)

-- SETTINGS
tab("Settings", function()
    label("UNIVERSAL HUB SETTINGS")

    button("Hide GUI (RightShift)", function()
        Main.Visible = false
    end)

    button("Theme: Purple", function()
        Main.BackgroundColor3 = Color3.fromRGB(18,18,25)
        Header.BackgroundColor3 = Color3.fromRGB(28,23,43)
    end)

    button("Theme: Blue", function()
        Header.BackgroundColor3 = Color3.fromRGB(20,45,75)
    end)

    label("Version 1.0")
    label("Universal Hub")
end)

-- Toggle GUI
UIS.InputBegan:Connect(function(input, processed)
    if not processed and input.KeyCode == Enum.KeyCode.RightShift then
        Main.Visible = not Main.Visible
    end
end)

-- Character respawn support
Player.CharacterAdded:Connect(function(character)
    task.wait(1)

    local h = character:FindFirstChildOfClass("Humanoid")
    if h then
        h.WalkSpeed = Settings.Speed
        h.UseJumpPower = true
        h.JumpPower = Settings.JumpPower
    end
end)

-- Default page
label("WELCOME TO UNIVERSAL HUB")
label("Select a tab on the left.")
label("Press RightShift to hide/show GUI.")

print("Universal Hub V1 loaded!")
