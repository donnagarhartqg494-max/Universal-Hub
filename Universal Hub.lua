--[[
 UNIVERSAL HUB V3 - RAYFIELD EDITION
 Use only in experiences you own or are authorized to test.
 Client-side features may not replicate to the server.
]]
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local LP = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
local Window = Rayfield:CreateWindow({
    Name = "Universal Hub",
    LoadingTitle = "Universal Hub",
    LoadingSubtitle = "Rayfield Edition • V3",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "UniversalHub",
        FileName = "Settings"
    },
    Discord = {Enabled = false},
    KeySystem = false
})

-- Persistent reopen button: this GUI is separate from Rayfield, so it stays visible when the hub is hidden/closed.
local reopenGui = Instance.new("ScreenGui")
reopenGui.Name = "UniversalHubReopen"
reopenGui.ResetOnSpawn = false
reopenGui.IgnoreGuiInset = true
reopenGui.DisplayOrder = 999999
reopenGui.Parent = LP:WaitForChild("PlayerGui")

local reopenButton = Instance.new("TextButton")
reopenButton.Name = "ShowMenu"
reopenButton.Size = UDim2.fromOffset(132, 42)
reopenButton.Position = UDim2.new(0, 18, 0.5, -21)
reopenButton.BackgroundColor3 = Color3.fromRGB(112, 72, 190)
reopenButton.Text = "SHOW MENU"
reopenButton.TextColor3 = Color3.new(1, 1, 1)
reopenButton.TextSize = 14
reopenButton.Font = Enum.Font.GothamBold
reopenButton.Visible = false
reopenButton.Parent = reopenGui
local reopenCorner = Instance.new("UICorner")
reopenCorner.CornerRadius = UDim.new(0, 10)
reopenCorner.Parent = reopenButton
local reopenStroke = Instance.new("UIStroke")
reopenStroke.Color = Color3.fromRGB(190, 155, 255)
reopenStroke.Thickness = 1.5
reopenStroke.Parent = reopenButton

reopenButton.MouseButton1Click:Connect(function()
    pcall(function() Rayfield:SetVisibility(true) end)
    reopenButton.Visible = false
end)

-- Keep the reopen button in sync with Rayfield visibility.
task.spawn(function()
    while reopenGui.Parent do
        task.wait(0.25)
        local visible = true
        pcall(function() visible = Rayfield:IsVisible() end)
        reopenButton.Visible = not visible
    end
end)

local function notify(title, content)
    Rayfield:Notify({Title=title, Content=content, Duration=4, Image=4483362458})
end
local function getChar() return LP.Character end
local function getHumanoid()
    local c=getChar()
    return c and c:FindFirstChildOfClass("Humanoid")
end
local function getRoot(c)
    c=c or getChar()
    return c and (c:FindFirstChild("HumanoidRootPart") or c:FindFirstChild("Torso"))
end

local cfg = {Speed=16, Jump=50, FlySpeed=55, FOV=70}
local state = {Fly=false,Noclip=false,InfiniteJump=false,FullBright=false,ESP=false,AntiAFK=false,XRay=false}
local connections = {}
local highlights = {}
local flyVelocity, flyGyro
local oldLighting
local xrayOriginal = {}

local function setFly(enabled)
    state.Fly=enabled
    if connections.Fly then connections.Fly:Disconnect(); connections.Fly=nil end
    if flyVelocity then flyVelocity:Destroy(); flyVelocity=nil end
    if flyGyro then flyGyro:Destroy(); flyGyro=nil end
    if not enabled then return end

    local root=getRoot()
    if not root then state.Fly=false; notify("Fly","Character is not ready."); return end

    flyVelocity=Instance.new("BodyVelocity")
    flyVelocity.MaxForce=Vector3.new(100000,100000,100000)
    flyVelocity.Velocity=Vector3.zero
    flyVelocity.Parent=root

    flyGyro=Instance.new("BodyGyro")
    flyGyro.MaxTorque=Vector3.new(100000,100000,100000)
    flyGyro.P=10000
    flyGyro.CFrame=Camera.CFrame
    flyGyro.Parent=root

    connections.Fly=RunService.RenderStepped:Connect(function()
        if not state.Fly or not root.Parent then return end
        local cf=Camera.CFrame
        local direction=Vector3.zero
        if UIS:IsKeyDown(Enum.KeyCode.W) then direction+=cf.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then direction-=cf.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then direction-=cf.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then direction+=cf.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then direction+=Vector3.yAxis end
        if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then direction-=Vector3.yAxis end
        flyVelocity.Velocity=direction.Magnitude>0 and direction.Unit*cfg.FlySpeed or Vector3.zero
        flyGyro.CFrame=cf
    end)
end

local function setNoclip(enabled)
    state.Noclip=enabled
    if connections.Noclip then connections.Noclip:Disconnect(); connections.Noclip=nil end
    if enabled then
        connections.Noclip=RunService.Stepped:Connect(function()
            local c=getChar()
            if c then
                for _,part in ipairs(c:GetDescendants()) do
                    if part:IsA("BasePart") then part.CanCollide=false end
                end
            end
        end)
    end
end

local function clearESP()
    for _,highlight in pairs(highlights) do pcall(function() highlight:Destroy() end) end
    highlights={}
end
local function addESP(player)
    if player==LP or not state.ESP or highlights[player] then return end
    local character=player.Character
    if not character or not getRoot(character) then return end
    local highlight=Instance.new("Highlight")
    highlight.Name="UniversalHubESP"
    highlight.Adornee=character
    highlight.FillColor=Color3.fromRGB(160,95,255)
    highlight.OutlineColor=Color3.new(1,1,1)
    highlight.FillTransparency=0.55
    highlight.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent=LP:WaitForChild("PlayerGui")
    highlights[player]=highlight
end
local function setESP(enabled)
    state.ESP=enabled
    clearESP()
    if enabled then
        for _,player in ipairs(Players:GetPlayers()) do addESP(player) end
    end
end

local function setFullBright(enabled)
    state.FullBright=enabled
    if enabled then
        if not oldLighting then
            oldLighting={
                Brightness=Lighting.Brightness,
                ClockTime=Lighting.ClockTime,
                GlobalShadows=Lighting.GlobalShadows,
                Ambient=Lighting.Ambient,
                OutdoorAmbient=Lighting.OutdoorAmbient
            }
        end
        Lighting.Brightness=3
        Lighting.ClockTime=14
        Lighting.GlobalShadows=false
        Lighting.Ambient=Color3.new(1,1,1)
        Lighting.OutdoorAmbient=Color3.new(1,1,1)
    elseif oldLighting then
        for property,value in pairs(oldLighting) do
            pcall(function() Lighting[property]=value end)
        end
        oldLighting=nil
    end
end

local function setXRay(enabled)
    state.XRay=enabled
    if enabled then
        for _,object in ipairs(workspace:GetDescendants()) do
            if object:IsA("BasePart") and not (getChar() and object:IsDescendantOf(getChar())) then
                if xrayOriginal[object]==nil then xrayOriginal[object]=object.LocalTransparencyModifier end
                object.LocalTransparencyModifier=0.65
            end
        end
    else
        for object,value in pairs(xrayOriginal) do
            pcall(function() object.LocalTransparencyModifier=value end)
        end
        xrayOriginal={}
    end
end

local function setAntiAFK(enabled)
    state.AntiAFK=enabled
    if connections.AntiAFK then connections.AntiAFK:Disconnect(); connections.AntiAFK=nil end
    if enabled then
        connections.AntiAFK=LP.Idled:Connect(function()
            pcall(function()
                local virtualUser=game:GetService("VirtualUser")
                virtualUser:CaptureController()
                virtualUser:ClickButton2(Vector2.new(0,0))
            end)
        end)
    end
end

local MovementTab=Window:CreateTab("Movement", "person-standing")
local VisualTab=Window:CreateTab("Visuals", "eye")
local PlayersTab=Window:CreateTab("Players", "users")
local SettingsTab=Window:CreateTab("Settings", "settings")

MovementTab:CreateSection("Character")
MovementTab:CreateToggle({
    Name="Fly",
    CurrentValue=false,
    Flag="Fly",
    Callback=function(value) setFly(value) end
})
MovementTab:CreateSlider({
    Name="Fly Speed",
    Range={10,200},
    Increment=1,
    Suffix=" speed",
    CurrentValue=cfg.FlySpeed,
    Flag="FlySpeed",
    Callback=function(value) cfg.FlySpeed=value end
})
MovementTab:CreateToggle({
    Name="Noclip",
    CurrentValue=false,
    Flag="Noclip",
    Callback=function(value) setNoclip(value) end
})
MovementTab:CreateSlider({
    Name="Walk Speed",
    Range={0,100},
    Increment=1,
    Suffix=" speed",
    CurrentValue=cfg.Speed,
    Flag="WalkSpeed",
    Callback=function(value)
        cfg.Speed=value
        local humanoid=getHumanoid()
        if humanoid then humanoid.WalkSpeed=value end
    end
})
MovementTab:CreateSlider({
    Name="Jump Power",
    Range={0,200},
    Increment=1,
    Suffix=" power",
    CurrentValue=cfg.Jump,
    Flag="JumpPower",
    Callback=function(value)
        cfg.Jump=value
        local humanoid=getHumanoid()
        if humanoid then humanoid.UseJumpPower=true; humanoid.JumpPower=value end
    end
})
MovementTab:CreateToggle({
    Name="Infinite Jump",
    CurrentValue=false,
    Flag="InfiniteJump",
    Callback=function(value) state.InfiniteJump=value end
})

VisualTab:CreateSection("Visual settings")
VisualTab:CreateSlider({
    Name="Field of View",
    Range={40,120},
    Increment=1,
    Suffix="°",
    CurrentValue=cfg.FOV,
    Flag="FOV",
    Callback=function(value) cfg.FOV=value; Camera.FieldOfView=value end
})
VisualTab:CreateToggle({
    Name="Full Bright",
    CurrentValue=false,
    Flag="FullBright",
    Callback=function(value) setFullBright(value) end
})
VisualTab:CreateToggle({
    Name="Player ESP",
    CurrentValue=false,
    Flag="PlayerESP",
    Callback=function(value) setESP(value) end
})
VisualTab:CreateToggle({
    Name="X-Ray",
    CurrentValue=false,
    Flag="XRay",
    Callback=function(value) setXRay(value) end
})

PlayersTab:CreateSection("Player utilities")
local selectedPlayer
local function getPlayerNames()
    local names={}
    for _,player in ipairs(Players:GetPlayers()) do
        if player~=LP then table.insert(names,player.Name) end
    end
    table.sort(names)
    return names
end
PlayersTab:CreateDropdown({
    Name="Select player",
    Options=getPlayerNames(),
    CurrentOption={},
    MultipleOptions=false,
    Flag="SelectedPlayer",
    Callback=function(option)
        if type(option)=="table" then selectedPlayer=option[1] else selectedPlayer=option end
    end
})
PlayersTab:CreateButton({
    Name="Teleport to selected player",
    Callback=function()
        local target=selectedPlayer and Players:FindFirstChild(selectedPlayer)
        local targetRoot=target and getRoot(target.Character)
        local myRoot=getRoot()
        if targetRoot and myRoot then
            myRoot.CFrame=targetRoot.CFrame*CFrame.new(0,0,3)
        else
            notify("Teleport","Select a player who is currently in the game.")
        end
    end
})
PlayersTab:CreateButton({
    Name="Refresh player list",
    Callback=function()
        local names=getPlayerNames()
        pcall(function()
            PlayersTab:CreateDropdown({
                Name="Player list refreshed",
                Options=names,
                CurrentOption={},
                MultipleOptions=false,
                Callback=function(option)
                    if type(option)=="table" then selectedPlayer=option[1] else selectedPlayer=option end
                end
            })
        end)
        notify("Players","Player list refreshed.")
    end
})

SettingsTab:CreateSection("Interface")
SettingsTab:CreateDropdown({
    Name="Rayfield theme",
    Options={"Default","AmberGlow","Amethyst","Bloom","DarkBlue","Green","Light","Ocean","Serenity"},
    CurrentOption={"Default"},
    MultipleOptions=false,
    Flag="RayfieldTheme",
    Callback=function(option)
        local theme=type(option)=="table" and option[1] or option
        pcall(function() Rayfield:ChangeTheme(theme) end)
    end
})
SettingsTab:CreateButton({
    Name="Save configuration",
    Callback=function()
        pcall(function() Rayfield:SaveConfiguration() end)
        notify("Settings","Configuration save requested.")
    end
})
SettingsTab:CreateButton({
    Name="Unload hub",
    Callback=function()
        setFly(false)
        setNoclip(false)
        setESP(false)
        setFullBright(false)
        setXRay(false)
        setAntiAFK(false)
        for _,connection in pairs(connections) do pcall(function() connection:Disconnect() end) end
        Rayfield:Destroy()
    end
})
SettingsTab:CreateParagraph({
    Title="Universal Hub V3",
    Content="Rayfield interface. Use only in experiences you own or are authorized to test. Some client-side effects may not replicate to the server."
})
SettingsTab:CreateKeybind({
    Name="Toggle UI",
    CurrentKeybind="RightShift",
    HoldToInteract=false,
    Flag="ToggleUI",
    Callback=function() Rayfield:SetVisibility(not Rayfield:IsVisible()) end
})

UIS.JumpRequest:Connect(function()
    if state.InfiniteJump then
        local humanoid=getHumanoid()
        if humanoid then humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        task.wait(0.8)
        if state.ESP then addESP(player) end
    end)
end)
Players.PlayerRemoving:Connect(function(player)
    if highlights[player] then highlights[player]:Destroy(); highlights[player]=nil end
end)
for _,player in ipairs(Players:GetPlayers()) do
    player.CharacterAdded:Connect(function()
        task.wait(0.8)
        if state.ESP then addESP(player) end
    end)
end

LP.CharacterAdded:Connect(function(character)
    task.wait(0.7)
    local humanoid=character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.WalkSpeed=cfg.Speed
        humanoid.UseJumpPower=true
        humanoid.JumpPower=cfg.Jump
    end
    if state.Fly then setFly(true) end
    if state.ESP then
        for _,player in ipairs(Players:GetPlayers()) do
            if player~=LP then addESP(player) end
        end
    end
end)

pcall(function() Rayfield:LoadConfiguration() end)
notify("Universal Hub","Rayfield V3 loaded successfully.")
print("Universal Hub V3 - Rayfield Edition loaded")
