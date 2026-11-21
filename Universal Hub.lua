--[[
 UNIVERSAL HUB V6 - PLAYER TROLLING
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
    LoadingSubtitle = "Rayfield Edition • V6",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "UniversalHub",
        FileName = "Settings"
    },
    Discord = {Enabled = false},
    KeySystem = false
})

-- Persistent reopen button: kept in PlayerGui independently from Rayfield.
local reopenGui = Instance.new("ScreenGui")
reopenGui.Name = "UniversalHubReopen"
reopenGui.ResetOnSpawn = false
reopenGui.IgnoreGuiInset = true
reopenGui.DisplayOrder = 999999
reopenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
reopenGui.Parent = LP:WaitForChild("PlayerGui")

local reopenButton = Instance.new("TextButton")
reopenButton.Name = "ShowMenu"
reopenButton.Size = UDim2.fromOffset(142, 46)
reopenButton.Position = UDim2.new(0, 18, 0.5, -23)
reopenButton.BackgroundColor3 = Color3.fromRGB(112, 72, 190)
reopenButton.Text = "SHOW MENU"
reopenButton.TextColor3 = Color3.new(1, 1, 1)
reopenButton.TextSize = 15
reopenButton.Font = Enum.Font.GothamBold
reopenButton.Visible = true
reopenButton.ZIndex = 1000
reopenButton.Parent = reopenGui
local reopenCorner = Instance.new("UICorner")
reopenCorner.CornerRadius = UDim.new(0, 10)
reopenCorner.Parent = reopenButton
local reopenStroke = Instance.new("UIStroke")
reopenStroke.Color = Color3.fromRGB(190, 155, 255)
reopenStroke.Thickness = 1.5
reopenStroke.Parent = reopenButton

local function showRayfield()
    -- Rayfield versions differ: restore its ScreenGui directly, then call its public API if available.
    for _, container in ipairs({LP:FindFirstChildOfClass("PlayerGui"), game:GetService("CoreGui")}) do
        if container then
            for _, item in ipairs(container:GetDescendants()) do
                if item:IsA("ScreenGui") and (string.find(string.lower(item.Name), "rayfield") or string.find(string.lower(item.Name), "universal")) then
                    item.Enabled = true
                end
            end
        end
    end
    pcall(function() Rayfield:SetVisibility(true) end)
end

reopenButton.MouseButton1Click:Connect(function()
    showRayfield()
end)

-- The reopen control intentionally remains visible: no dependency on IsVisible(),
-- which is not present in every Rayfield build.
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

-- PLAYER TROLLING: harmless client-side visual pranks only; nothing is sent to other players.
local TrollTab = Window:CreateTab("Trolling", "smile")
local trollObjects = {}
local trollConnections = {}
local trollEffects = {}
local function selectedCharacter()
    local p = selectedPlayer and Players:FindFirstChild(selectedPlayer)
    return p and p.Character
end
local function clearTrollObject(key)
    if trollObjects[key] then pcall(function() trollObjects[key]:Destroy() end); trollObjects[key]=nil end
end
local function makeTrollScreen(name, textValue, color, duration)
    local gui = Instance.new("ScreenGui")
    gui.Name = "UHTroll_" .. name
    gui.ResetOnSpawn = false
    gui.DisplayOrder = 1000000
    gui.Parent = LP:WaitForChild("PlayerGui")
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0, 360, 0, 74)
    label.Position = UDim2.new(0.5, -180, 0.18, 0)
    label.BackgroundColor3 = color or Color3.fromRGB(90, 40, 140)
    label.BackgroundTransparency = 0.08
    label.TextColor3 = Color3.new(1,1,1)
    label.Text = textValue
    label.TextScaled = true
    label.Font = Enum.Font.GothamBlack
    label.Parent = gui
    local corner = Instance.new("UICorner"); corner.CornerRadius = UDim.new(0,14); corner.Parent = label
    if duration then task.delay(duration, function() if gui.Parent then gui:Destroy() end end) end
    return gui
end
local function addTargetHighlight(rainbow)
    clearTrollObject("highlight")
    local ch = selectedCharacter()
    if not ch then notify("Trolling","Select a player who is in the game."); return end
    local h = Instance.new("Highlight")
    h.Name = "UHTrollHighlight"; h.Adornee = ch
    h.FillTransparency = 0.72; h.OutlineTransparency = 0
    h.FillColor = Color3.fromRGB(190,80,255); h.OutlineColor = Color3.fromRGB(255,255,255)
    h.Parent = LP:WaitForChild("PlayerGui")
    trollObjects.highlight = h
    if rainbow then
        trollConnections.rainbow = RunService.RenderStepped:Connect(function()
            if h.Parent then
                local hue = (os.clock() % 3) / 3
                h.OutlineColor = Color3.fromHSV(hue,1,1)
                h.FillColor = Color3.fromHSV((hue+0.35)%1,0.8,1)
            end
        end)
    end
end
local function addTargetBillboard(textValue, key)
    clearTrollObject(key)
    local ch = selectedCharacter()
    local head = ch and ch:FindFirstChild("Head")
    if not head then notify("Trolling","Selected player has no visible Head."); return end
    local gui = Instance.new("BillboardGui")
    gui.Name = "UHTroll_"..key; gui.Size = UDim2.fromOffset(220,55)
    gui.StudsOffset = Vector3.new(0,3.5,0); gui.AlwaysOnTop = true; gui.Adornee = head
    gui.Parent = LP:WaitForChild("PlayerGui")
    local label = Instance.new("TextLabel")
    label.Size = UDim2.fromScale(1,1); label.BackgroundTransparency = 1
    label.Text = textValue; label.TextColor3 = Color3.fromRGB(255,220,80)
    label.TextStrokeTransparency = 0; label.TextScaled = true
    label.Font = Enum.Font.GothamBlack; label.Parent = gui
    trollObjects[key] = gui
end
local function setCameraEffect(key, enabled, effectName)
    local existing = trollEffects[key]
    if existing then existing:Destroy(); trollEffects[key]=nil end
    if enabled then
        local effect = Instance.new(effectName)
        effect.Name = "UHTroll_"..key
        effect.Parent = Lighting
        trollEffects[key] = effect
    end
end
local function setScreenOverlay(key, enabled, color, transparency)
    clearTrollObject(key)
    if not enabled then return end
    local gui = Instance.new("ScreenGui"); gui.Name = "UHTroll_"..key
    gui.IgnoreGuiInset = true; gui.ResetOnSpawn = false; gui.DisplayOrder = 999998
    gui.Parent = LP:WaitForChild("PlayerGui")
    local frame = Instance.new("Frame"); frame.Size = UDim2.fromScale(1,1)
    frame.BackgroundColor3 = color; frame.BackgroundTransparency = transparency
    frame.BorderSizePixel = 0; frame.Parent = gui
    trollObjects[key] = gui
end

TrollTab:CreateSection("Selected player — local visual pranks")
TrollTab:CreateToggle({Name="Target highlight",CurrentValue=false,Callback=function(v)
    if v then addTargetHighlight(false) else clearTrollObject("highlight") end
end})
TrollTab:CreateToggle({Name="Rainbow target outline",CurrentValue=false,Callback=function(v)
    if trollConnections.rainbow then trollConnections.rainbow:Disconnect(); trollConnections.rainbow=nil end
    if v then addTargetHighlight(true) else clearTrollObject("highlight") end
end})
TrollTab:CreateToggle({Name="Funny nameplate",CurrentValue=false,Callback=function(v)
    if v then addTargetBillboard("CERTIFIED TROLL 😂","nameplate") else clearTrollObject("nameplate") end
end})
TrollTab:CreateToggle({Name="Emoji above target",CurrentValue=false,Callback=function(v)
    if v then addTargetBillboard("🤡 😂 💀","emoji") else clearTrollObject("emoji") end
end})
TrollTab:CreateToggle({Name="Target warning sign",CurrentValue=false,Callback=function(v)
    if v then addTargetBillboard("WARNING: TOO FUNNY","warning") else clearTrollObject("warning") end
end})
TrollTab:CreateButton({Name="Confetti message",Callback=function()
    local ch=selectedCharacter(); local head=ch and ch:FindFirstChild("Head")
    if not head then notify("Trolling","Select a player first."); return end
    addTargetBillboard("🎉 PARTY TIME 🎉","confetti")
    task.delay(5,function() clearTrollObject("confetti") end)
end})
TrollTab:CreateButton({Name="Fake warning popup",Callback=function()
    makeTrollScreen("Warning","⚠ YOU HAVE BEEN TROLLED ⚠",Color3.fromRGB(170,95,20),4)
end})
TrollTab:CreateButton({Name="Fake ban notice (local joke)",Callback=function()
    makeTrollScreen("BanJoke","BAN CHECK: JUST KIDDING 😂",Color3.fromRGB(155,35,45),4)
end})
TrollTab:CreateButton({Name="Fake connection alert",Callback=function()
    makeTrollScreen("Connection","Connection unstable... probably your luck 💀",Color3.fromRGB(55,65,85),4)
end})
TrollTab:CreateButton({Name="Fake countdown",Callback=function()
    local gui=makeTrollScreen("Countdown","3",Color3.fromRGB(65,45,120))
    task.spawn(function()
        local label=gui:FindFirstChildWhichIsA("TextLabel")
        for i=3,1,-1 do if not gui.Parent then return end; label.Text=tostring(i); task.wait(1) end
        if gui.Parent then label.Text="PRANKED 😂"; task.wait(1); gui:Destroy() end
    end)
end})
TrollTab:CreateToggle({Name="Screen shake",CurrentValue=false,Callback=function(v)
    if trollConnections.shake then trollConnections.shake:Disconnect(); trollConnections.shake=nil end
    if v then trollConnections.shake=RunService.RenderStepped:Connect(function()
        local cam=workspace.CurrentCamera
        if cam then cam.CFrame=cam.CFrame*CFrame.new(math.random(-2,2)/100,math.random(-2,2)/100,0) end
    end) end
end})
TrollTab:CreateToggle({Name="Upside-down camera",CurrentValue=false,Callback=function(v)
    if trollConnections.flip then trollConnections.flip:Disconnect(); trollConnections.flip=nil end
    if v then trollConnections.flip=RunService.RenderStepped:Connect(function()
        local cam=workspace.CurrentCamera
        if cam then cam.CFrame=cam.CFrame*CFrame.Angles(0,0,math.pi) end
    end) end
end})
TrollTab:CreateToggle({Name="Fish-eye style FOV",CurrentValue=false,Callback=function(v)
    if v then
        trollEffects.oldFov = workspace.CurrentCamera.FieldOfView
        workspace.CurrentCamera.FieldOfView = 110
    elseif trollEffects.oldFov then
        workspace.CurrentCamera.FieldOfView = trollEffects.oldFov; trollEffects.oldFov=nil
    end
end})
TrollTab:CreateToggle({Name="Grayscale screen",CurrentValue=false,Callback=function(v)
    if v then
        local e=Instance.new("ColorCorrectionEffect"); e.Saturation=-1; e.Parent=Lighting; trollEffects.gray=e
    elseif trollEffects.gray then trollEffects.gray:Destroy(); trollEffects.gray=nil end
end})
TrollTab:CreateToggle({Name="Extra blur",CurrentValue=false,Callback=function(v)
    if v then local e=Instance.new("BlurEffect"); e.Size=18; e.Parent=Lighting; trollEffects.blur=e
    elseif trollEffects.blur then trollEffects.blur:Destroy(); trollEffects.blur=nil end
end})
TrollTab:CreateToggle({Name="Cartoon colors",CurrentValue=false,Callback=function(v)
    if v then
        local e=Instance.new("ColorCorrectionEffect"); e.Saturation=0.8; e.Contrast=0.25; e.Parent=Lighting; trollEffects.cartoon=e
    elseif trollEffects.cartoon then trollEffects.cartoon:Destroy(); trollEffects.cartoon=nil end
end})
TrollTab:CreateToggle({Name="Red alert overlay",CurrentValue=false,Callback=function(v)
    setScreenOverlay("redalert",v,Color3.fromRGB(255,0,0),0.88)
end})
TrollTab:CreateButton({Name="Emoji rain",Callback=function()
    local gui=Instance.new("ScreenGui"); gui.Name="UHTroll_EmojiRain"; gui.IgnoreGuiInset=true; gui.Parent=LP:WaitForChild("PlayerGui")
    for i=1,24 do
        local label=Instance.new("TextLabel"); label.BackgroundTransparency=1
        label.Size=UDim2.fromOffset(42,42); label.Position=UDim2.new(math.random(),0,-0.1,0)
        label.Text=({"😂","🤡","💀","🎉","🗿"})[math.random(1,5)]; label.TextScaled=true; label.Parent=gui
        task.spawn(function()
            for step=1,35 do if not label.Parent then return end
                label.Position=label.Position+UDim2.new(0,0,0,0.035); task.wait(0.04)
            end
        end)
    end
    task.delay(3,function() if gui.Parent then gui:Destroy() end end)
end})
TrollTab:CreateButton({Name="Big prank text",Callback=function()
    local gui=makeTrollScreen("BigText","SKILL ISSUE 😭",Color3.fromRGB(95,35,150),3)
    local label=gui:FindFirstChildWhichIsA("TextLabel"); label.Size=UDim2.new(0,520,0,110); label.Position=UDim2.new(0.5,-260,0.45,0)
end})
TrollTab:CreateButton({Name="Fake loading screen",Callback=function()
    local gui=makeTrollScreen("Loading","Loading player skills... 0%",Color3.fromRGB(30,35,55),5)
    task.spawn(function()
        local label=gui:FindFirstChildWhichIsA("TextLabel")
        for n=0,100,20 do if not gui.Parent then return end; label.Text="Loading player skills... "..n.."%"; task.wait(0.8) end
        if gui.Parent then label.Text="FAILED: SKILL NOT FOUND 😂" end
    end)
end})
TrollTab:CreateSection("Emergency")
TrollTab:CreateButton({Name="PANIC — clear all trolling effects",Color=Color3.fromRGB(190,55,65),Callback=function()
    for _,obj in pairs(trollObjects) do pcall(function() obj:Destroy() end) end
    trollObjects={}
    for _,con in pairs(trollConnections) do pcall(function() con:Disconnect() end) end
    trollConnections={}
    for key,effect in pairs(trollEffects) do if typeof(effect)=="Instance" then pcall(function() effect:Destroy() end) end; trollEffects[key]=nil end
    local cam=workspace.CurrentCamera
    if cam and trollEffects.oldFov then cam.FieldOfView=trollEffects.oldFov end
    notify("Trolling","All local prank effects cleared.")
end})
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
    Title="Universal Hub V6",
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
notify("Universal Hub","Rayfield V6 loaded successfully.")
print("Universal Hub V6 - Rayfield Edition loaded")
