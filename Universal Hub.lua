--[[
 UNIVERSAL HUB V2
 Client-side utility hub. Use only where you have permission.
 Some actions are local-only and may not replicate to the server.
]]
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local HttpService = game:GetService("HttpService")
local LP = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local FILE = "UniversalHub_Settings.json"

local defaults = {Language="RU", Theme="Purple", Speed=16, Jump=50, FlySpeed=55, FOV=70}
local cfg = table.clone(defaults)
pcall(function()
    if isfile and readfile and isfile(FILE) then
        local saved = HttpService:JSONDecode(readfile(FILE))
        for k in pairs(defaults) do if saved[k] ~= nil then cfg[k] = saved[k] end end
    end
end)
local function save()
    pcall(function() if writefile then writefile(FILE, HttpService:JSONEncode(cfg)) end end)
end
local words = {
 RU={Movement="Движение",Visuals="Визуал",Players="Игроки",Settings="Настройки",Fly="Полёт",FlySpeed="Скорость полёта",Noclip="Проходить сквозь объекты",Speed="Скорость ходьбы",Jump="Сила прыжка",InfiniteJump="Бесконечный прыжок",FOV="Угол обзора",FullBright="Полная яркость",ESP="Подсветка игроков",XRay="Режим X-Ray",AntiAFK="Анти-AFK",Refresh="Обновить список",Teleport="Телепорт к игроку",Language="Язык",Theme="Тема",Save="Сохранить настройки",Reset="Сбросить настройки",Search="Поиск функций...",Welcome="Добро пожаловать в Universal Hub",Disclaimer="Используй только там, где у тебя есть разрешение.",On="ВКЛ",Off="ВЫКЛ",NoPlayers="Других игроков нет",Hide="Скрыть меню"},
 EN={Movement="Movement",Visuals="Visuals",Players="Players",Settings="Settings",Fly="Fly",FlySpeed="Fly speed",Noclip="Noclip",Speed="Walk speed",Jump="Jump power",InfiniteJump="Infinite jump",FOV="Field of view",FullBright="Full bright",ESP="Player ESP",XRay="X-Ray mode",AntiAFK="Anti-AFK",Refresh="Refresh list",Teleport="Teleport to player",Language="Language",Theme="Theme",Save="Save settings",Reset="Reset settings",Search="Search features...",Welcome="Welcome to Universal Hub",Disclaimer="Use only where you have permission.",On="ON",Off="OFF",NoPlayers="No other players",Hide="Hide menu"}
}
local function T(k) return (words[cfg.Language] or words.EN)[k] or k end
local themes = {
 Purple={bg=Color3.fromRGB(18,17,25),panel=Color3.fromRGB(29,25,40),button=Color3.fromRGB(49,39,67),accent=Color3.fromRGB(165,105,235)},
 Blue={bg=Color3.fromRGB(15,20,29),panel=Color3.fromRGB(24,33,48),button=Color3.fromRGB(36,53,76),accent=Color3.fromRGB(85,165,245)},
 Red={bg=Color3.fromRGB(27,17,20),panel=Color3.fromRGB(43,26,31),button=Color3.fromRGB(70,39,46),accent=Color3.fromRGB(235,90,105)},
 Green={bg=Color3.fromRGB(16,25,21),panel=Color3.fromRGB(25,39,31),button=Color3.fromRGB(37,62,49),accent=Color3.fromRGB(85,195,130)},
 Dark={bg=Color3.fromRGB(14,14,16),panel=Color3.fromRGB(26,26,29),button=Color3.fromRGB(44,44,48),accent=Color3.fromRGB(190,190,200)}
}
local state = {fly=false,noclip=false,infjump=false,bright=false,esp=false,afk=false,xray=false}
local conns, highlights, xrayOld = {}, {}, {}
local oldLight
local flyVelocity, flyGyro
local function char() return LP.Character end
local function hum()
    local c=char()
    return c and c:FindFirstChildOfClass("Humanoid")
end
local function root(c)
    c=c or char()
    return c and (c:FindFirstChild("HumanoidRootPart") or c:FindFirstChild("Torso"))
end
local function notify(msg)
    pcall(function() game:GetService("StarterGui"):SetCore("SendNotification",{Title="Universal Hub",Text=msg,Duration=3}) end)
end

local gui=Instance.new("ScreenGui")
gui.Name="UniversalHubV2"
gui.ResetOnSpawn=false
gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
gui.Parent=LP:WaitForChild("PlayerGui")
local main=Instance.new("Frame")
main.Size=UDim2.fromOffset(640,430)
main.Position=UDim2.new(.5,-320,.5,-215)
main.BorderSizePixel=0
main.Parent=gui
Instance.new("UICorner",main).CornerRadius=UDim.new(0,12)
local header=Instance.new("Frame")
header.Size=UDim2.new(1,0,0,46)
header.BorderSizePixel=0
header.Parent=main
Instance.new("UICorner",header).CornerRadius=UDim.new(0,12)
local title=Instance.new("TextLabel")
title.BackgroundTransparency=1
title.Position=UDim2.fromOffset(15,0)
title.Size=UDim2.new(1,-110,1,0)
title.Font=Enum.Font.GothamBold
title.TextSize=16
title.TextXAlignment=Enum.TextXAlignment.Left
title.Text="UNIVERSAL HUB  •  V2"
title.Parent=header
local close=Instance.new("TextButton")
close.Size=UDim2.fromOffset(32,29)
close.Position=UDim2.new(1,-39,0,8)
close.Text="×"
close.Font=Enum.Font.GothamBold
close.TextSize=21
close.Parent=header
Instance.new("UICorner",close).CornerRadius=UDim.new(0,7)
local minimize=Instance.new("TextButton")
minimize.Size=UDim2.fromOffset(32,29)
minimize.Position=UDim2.new(1,-77,0,8)
minimize.Text="—"
minimize.Font=Enum.Font.GothamBold
minimize.TextSize=18
minimize.Parent=header
Instance.new("UICorner",minimize).CornerRadius=UDim.new(0,7)
local sidebar=Instance.new("Frame")
sidebar.Position=UDim2.fromOffset(9,55)
sidebar.Size=UDim2.fromOffset(142,365)
sidebar.BorderSizePixel=0
sidebar.Parent=main
Instance.new("UICorner",sidebar).CornerRadius=UDim.new(0,9)
local sideLayout=Instance.new("UIListLayout")
sideLayout.Padding=UDim.new(0,7)
sideLayout.Parent=sidebar
local sidePad=Instance.new("UIPadding")
sidePad.PaddingTop=UDim.new(0,8); sidePad.PaddingLeft=UDim.new(0,8); sidePad.PaddingRight=UDim.new(0,8)
sidePad.Parent=sidebar
local search=Instance.new("TextBox")
search.Position=UDim2.fromOffset(160,55)
search.Size=UDim2.new(1,-169,0,32)
search.ClearTextOnFocus=false
search.Font=Enum.Font.Gotham
search.TextSize=12
search.Text=""
search.Parent=main
Instance.new("UICorner",search).CornerRadius=UDim.new(0,7)
local content=Instance.new("ScrollingFrame")
content.Position=UDim2.fromOffset(160,95)
content.Size=UDim2.new(1,-169,1,-104)
content.BorderSizePixel=0
content.ScrollBarThickness=4
content.CanvasSize=UDim2.new()
content.Parent=main
Instance.new("UICorner",content).CornerRadius=UDim.new(0,9)
local layout=Instance.new("UIListLayout")
layout.Padding=UDim.new(0,7)
layout.Parent=content
local padding=Instance.new("UIPadding")
padding.PaddingTop=UDim.new(0,9); padding.PaddingLeft=UDim.new(0,9); padding.PaddingRight=UDim.new(0,9); padding.PaddingBottom=UDim.new(0,9)
padding.Parent=content
layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() content.CanvasSize=UDim2.fromOffset(0,layout.AbsoluteContentSize.Y+20) end)

local function palette() return themes[cfg.Theme] or themes.Purple end
local function applyTheme()
    local p=palette()
    main.BackgroundColor3=p.bg; header.BackgroundColor3=p.panel; title.TextColor3=p.accent
    close.BackgroundColor3=Color3.fromRGB(125,45,60); close.TextColor3=Color3.new(1,1,1)
    minimize.BackgroundColor3=p.button; minimize.TextColor3=Color3.new(1,1,1)
    sidebar.BackgroundColor3=p.panel; content.BackgroundColor3=p.panel
    search.BackgroundColor3=p.button; search.TextColor3=Color3.new(1,1,1); search.PlaceholderColor3=Color3.fromRGB(170,170,180)
end
local function clear()
    for _,v in ipairs(content:GetChildren()) do
        if v:IsA("GuiObject") and v~=layout and v~=padding then v:Destroy() end
    end
end
local function section(txt)
    local l=Instance.new("TextLabel")
    l.Size=UDim2.new(1,-4,0,25); l.BackgroundTransparency=1
    l.Font=Enum.Font.GothamBold; l.TextSize=13; l.TextXAlignment=Enum.TextXAlignment.Left
    l.TextColor3=palette().accent; l.Text=txt; l.Parent=content
end
local function button(txt,fn)
    local b=Instance.new("TextButton")
    b.Size=UDim2.new(1,-4,0,35); b.BackgroundColor3=palette().button
    b.TextColor3=Color3.new(1,1,1); b.Font=Enum.Font.Gotham; b.TextSize=12
    b.Text=txt; b.Parent=content
    Instance.new("UICorner",b).CornerRadius=UDim.new(0,7)
    b.MouseButton1Click:Connect(fn)
    return b
end
local function toggle(key,initial,fn)
    local enabled=initial
    local b
    local function paint()
        b.Text=key.."  •  "..(enabled and T("On") or T("Off"))
        b.BackgroundColor3=enabled and palette().accent or palette().button
    end
    b=button("",function() enabled=not enabled; paint(); fn(enabled) end)
    paint()
    return b
end
local function numberBox(key,value,minv,maxv,fn)
    section(key)
    local b=Instance.new("TextBox")
    b.Size=UDim2.new(1,-4,0,33); b.BackgroundColor3=palette().button
    b.TextColor3=Color3.new(1,1,1); b.Font=Enum.Font.Gotham; b.TextSize=12
    b.Text=tostring(value); b.ClearTextOnFocus=false; b.Parent=content
    Instance.new("UICorner",b).CornerRadius=UDim.new(0,7)
    b.FocusLost:Connect(function()
        local n=tonumber(b.Text)
        if n then n=math.clamp(n,minv,maxv); b.Text=tostring(n); fn(n)
        else b.Text=tostring(value) end
    end)
end

local function setFly(on)
    state.fly=on
    if conns.fly then conns.fly:Disconnect(); conns.fly=nil end
    if flyVelocity then flyVelocity:Destroy(); flyVelocity=nil end
    if flyGyro then flyGyro:Destroy(); flyGyro=nil end
    if not on then return end
    local r=root()
    if not r then state.fly=false; notify("Character not ready"); return end
    flyVelocity=Instance.new("BodyVelocity")
    flyVelocity.MaxForce=Vector3.new(1e5,1e5,1e5); flyVelocity.Velocity=Vector3.zero; flyVelocity.Parent=r
    flyGyro=Instance.new("BodyGyro")
    flyGyro.MaxTorque=Vector3.new(1e5,1e5,1e5); flyGyro.P=1e4; flyGyro.CFrame=Camera.CFrame; flyGyro.Parent=r
    conns.fly=RunService.RenderStepped:Connect(function()
        if not state.fly or not r.Parent then return end
        local cf=Camera.CFrame
        local d=Vector3.zero
        if UIS:IsKeyDown(Enum.KeyCode.W) then d+=cf.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then d-=cf.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then d-=cf.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then d+=cf.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then d+=Vector3.yAxis end
        if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then d-=Vector3.yAxis end
        flyVelocity.Velocity=d.Magnitude>0 and d.Unit*cfg.FlySpeed or Vector3.zero
        flyGyro.CFrame=cf
    end)
end
local function setNoclip(on)
    state.noclip=on
    if conns.noclip then conns.noclip:Disconnect(); conns.noclip=nil end
    if on then
        conns.noclip=RunService.Stepped:Connect(function()
            local c=char()
            if c then for _,p in ipairs(c:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide=false end end end
        end)
    end
end
local function clearESP()
    for _,h in pairs(highlights) do pcall(function() h:Destroy() end) end
    highlights={}
end
local function addESP(plr)
    if plr==LP or not state.esp or highlights[plr] then return end
    local c=plr.Character
    if not c or not root(c) then return end
    local h=Instance.new("Highlight")
    h.Adornee=c; h.FillColor=palette().accent; h.OutlineColor=Color3.new(1,1,1)
    h.FillTransparency=.55; h.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop; h.Parent=gui
    highlights[plr]=h
end
local function setESP(on)
    state.esp=on; clearESP()
    if on then for _,p in ipairs(Players:GetPlayers()) do addESP(p) end end
end
local function setBright(on)
    state.bright=on
    if on then
        if not oldLight then oldLight={Brightness=Lighting.Brightness,ClockTime=Lighting.ClockTime,GlobalShadows=Lighting.GlobalShadows,Ambient=Lighting.Ambient,OutdoorAmbient=Lighting.OutdoorAmbient} end
        Lighting.Brightness=3; Lighting.ClockTime=14; Lighting.GlobalShadows=false
        Lighting.Ambient=Color3.new(1,1,1); Lighting.OutdoorAmbient=Color3.new(1,1,1)
    elseif oldLight then
        for k,v in pairs(oldLight) do Lighting[k]=v end
        oldLight=nil
    end
end
local function setXray(on)
    state.xray=on
    if on then
        for _,o in ipairs(workspace:GetDescendants()) do
            if o:IsA("BasePart") and not (char() and o:IsDescendantOf(char())) then
                if xrayOld[o]==nil then xrayOld[o]=o.LocalTransparencyModifier end
                o.LocalTransparencyModifier=.65
            end
        end
    else
        for o,v in pairs(xrayOld) do pcall(function() o.LocalTransparencyModifier=v end) end
        xrayOld={}
    end
end
local function setAFK(on)
    state.afk=on
    if conns.afk then conns.afk:Disconnect(); conns.afk=nil end
    if on then
        conns.afk=LP.Idled:Connect(function()
            pcall(function()
                local vu=game:GetService("VirtualUser")
                vu:CaptureController(); vu:ClickButton2(Vector2.new(0,0))
            end)
        end)
    end
end

local tabs={}
local function addTab(key,fn)
    local b=Instance.new("TextButton")
    b.Size=UDim2.new(1,0,0,34); b.BackgroundColor3=palette().button
    b.TextColor3=Color3.new(1,1,1); b.Font=Enum.Font.GothamBold; b.TextSize=12
    b.Text=T(key); b.Parent=sidebar
    Instance.new("UICorner",b).CornerRadius=UDim.new(0,7)
    b.MouseButton1Click:Connect(function() clear(); fn() end)
    table.insert(tabs,{key=key,button=b,fn=fn})
end
local function pageMovement()
    section(T("Movement"))
    toggle(T("Fly"),state.fly,setFly)
    numberBox(T("FlySpeed"),cfg.FlySpeed,10,200,function(v) cfg.FlySpeed=v; save() end)
    toggle(T("Noclip"),state.noclip,setNoclip)
    numberBox(T("Speed"),cfg.Speed,0,100,function(v) cfg.Speed=v; local h=hum(); if h then h.WalkSpeed=v end; save() end)
    numberBox(T("Jump"),cfg.Jump,0,200,function(v) cfg.Jump=v; local h=hum(); if h then h.UseJumpPower=true; h.JumpPower=v end; save() end)
    toggle(T("InfiniteJump"),state.infjump,function(v) state.infjump=v end)
end
local function pageVisuals()
    section(T("Visuals"))
    numberBox(T("FOV"),cfg.FOV,40,120,function(v) cfg.FOV=v; Camera.FieldOfView=v; save() end)
    toggle(T("FullBright"),state.bright,setBright)
    toggle(T("ESP"),state.esp,setESP)
    toggle(T("XRay"),state.xray,setXray)
end
local function pagePlayers()
    section(T("Players"))
    button(T("Refresh"),function() clear(); pagePlayers() end)
    local count=0
    for _,p in ipairs(Players:GetPlayers()) do
        if p~=LP then
            count+=1
            button(p.DisplayName.."  (@"..p.Name..")  •  "..T("Teleport"),function()
                local a=root(); local b=root(p.Character)
                if a and b then a.CFrame=b.CFrame*CFrame.new(0,0,3) end
            end)
        end
    end
    if count==0 then section(T("NoPlayers")) end
end
local function pageSettings()
    section(T("Settings"))
    button(T("Language")..": "..cfg.Language,function()
        cfg.Language=cfg.Language=="RU" and "EN" or "RU"; save()
        for _,t in ipairs(tabs) do t.button.Text=T(t.key) end
        clear(); pageSettings()
        search.PlaceholderText=T("Search")
    end)
    for _,name in ipairs({"Purple","Blue","Red","Green","Dark"}) do
        button(T("Theme")..": "..name,function()
            cfg.Theme=name; applyTheme(); save()
            for _,t in ipairs(tabs) do t.button.BackgroundColor3=palette().button end
            clear(); pageSettings()
        end)
    end
    button(T("Save"),function() save(); notify("Settings saved") end)
    button(T("Reset"),function()
        for k,v in pairs(defaults) do cfg[k]=v end
        save(); applyTheme()
        local h=hum(); if h then h.WalkSpeed=cfg.Speed; h.UseJumpPower=true; h.JumpPower=cfg.Jump end
        Camera.FieldOfView=cfg.FOV
        clear(); pageSettings()
    end)
    section(T("Disclaimer"))
end
addTab("Movement",pageMovement)
addTab("Visuals",pageVisuals)
addTab("Players",pagePlayers)
addTab("Settings",pageSettings)
search.PlaceholderText=T("Search")
applyTheme()
section(T("Welcome"))
section(T("Disclaimer"))

search:GetPropertyChangedSignal("Text"):Connect(function()
    local q=string.lower(search.Text)
    for _,o in ipairs(content:GetChildren()) do
        if o:IsA("TextButton") or o:IsA("TextLabel") then
            o.Visible=(q=="" or string.find(string.lower(o.Text),q,1,true)~=nil)
        end
    end
end)
UIS.JumpRequest:Connect(function()
    if state.infjump then local h=hum(); if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end end
end)
Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function() task.wait(.8); if state.esp then addESP(p) end end)
end)
Players.PlayerRemoving:Connect(function(p)
    if highlights[p] then highlights[p]:Destroy(); highlights[p]=nil end
end)
for _,p in ipairs(Players:GetPlayers()) do
    p.CharacterAdded:Connect(function() task.wait(.8); if state.esp then addESP(p) end end)
end
LP.CharacterAdded:Connect(function(c)
    task.wait(.7)
    local h=c:FindFirstChildOfClass("Humanoid")
    if h then h.WalkSpeed=cfg.Speed; h.UseJumpPower=true; h.JumpPower=cfg.Jump end
    if state.fly then setFly(true) end
    if state.esp then for _,p in ipairs(Players:GetPlayers()) do addESP(p) end end
end)
local minimized=false
minimize.MouseButton1Click:Connect(function()
    minimized=not minimized
    sidebar.Visible=not minimized; search.Visible=not minimized; content.Visible=not minimized
    main.Size=minimized and UDim2.fromOffset(640,46) or UDim2.fromOffset(640,430)
end)
local dragging,dragStart,startPos=false,nil,nil
header.InputBegan:Connect(function(input)
    if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
        dragging=true; dragStart=input.Position; startPos=main.Position
        input.Changed:Connect(function() if input.UserInputState==Enum.UserInputState.End then dragging=false end end)
    end
end)
UIS.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch) then
        local d=input.Position-dragStart
        main.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+d.X,startPos.Y.Scale,startPos.Y.Offset+d.Y)
    end
end)
local visible=true
UIS.InputBegan:Connect(function(input,processed)
    if not processed and input.KeyCode==Enum.KeyCode.RightShift then visible=not visible; main.Visible=visible end
end)
close.MouseButton1Click:Connect(function()
    for _,c in pairs(conns) do pcall(function() c:Disconnect() end) end
    clearESP(); setFly(false); setBright(false); setXray(false)
    gui:Destroy()
end)
applyTheme()
notify("Universal Hub V2 loaded • RightShift")
print("Universal Hub V2 loaded")
