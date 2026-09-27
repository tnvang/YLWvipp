local P=game:GetService("Players")
local UIS=game:GetService("UserInputService")
local RS=game:GetService("RunService")
local WS=game:GetService("Workspace")
local TS=game:GetService("TweenService")

local LP=P.LocalPlayer
local PG=LP:WaitForChild("PlayerGui")
local old=PG:FindFirstChild("TerritoryTeleportGUI")
if old then old:Destroy() end

local G=Instance.new("ScreenGui")
G.Name="TerritoryTeleportGUI"
G.ResetOnSpawn=false
G.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
G.Parent=PG

local function corner(o,r)
    Instance.new("UICorner",o).CornerRadius=UDim.new(0,r)
end

local function label(parent,text,pos,size,font,ts,color,z)
    local o=Instance.new("TextLabel",parent)
    o.BackgroundTransparency=1
    o.Position=pos
    o.Size=size
    o.Text=text
    o.Font=font or Enum.Font.Gotham
    o.TextSize=ts or 9
    o.TextColor3=color or Color3.new(1,1,1)
    o.ZIndex=z or 1
    return o
end

local M=Instance.new("Frame",G)
M.Size=UDim2.fromOffset(390,330)
M.Position=UDim2.new(.5,-195,.5,-165)
M.BackgroundColor3=Color3.fromRGB(12,15,21)
M.BorderSizePixel=0
corner(M,14)

local MS=Instance.new("UIStroke",M)
MS.Color=Color3.fromRGB(55,65,82)
MS.Transparency=.2

local T=Instance.new("Frame",M)
T.Size=UDim2.new(1,0,0,52)
T.BackgroundColor3=Color3.fromRGB(18,22,30)
T.BorderSizePixel=0
T.ZIndex=3
corner(T,14)

label(T,"Menu Học Làm script",UDim2.fromOffset(14,7),UDim2.new(1,-225,0,20),Enum.Font.GothamBold,12,Color3.fromRGB(240,244,250),3)
local Status=label(T,"Đang quét...",UDim2.fromOffset(15,28),UDim2.new(1,-225,0,15),Enum.Font.Gotham,8,Color3.fromRGB(120,133,153),3)

local function btn(txt,x,w)
    local b=Instance.new("TextButton",T)
    b.Size=UDim2.fromOffset(w,28)
    b.Position=UDim2.new(1,x,0,11)
    b.BackgroundColor3=Color3.fromRGB(30,35,46)
    b.BorderSizePixel=0
    b.Text=txt
    b.Font=Enum.Font.GothamBold
    b.TextSize=8
    b.TextColor3=Color3.fromRGB(225,230,240)
    b.AutoButtonColor=false
    b.ZIndex=4
    corner(b,8)
    return b
end

local Auto=btn("AUTO",-213,48)
local Skip=btn("SKIP",-160,48)
local Lock=btn("LOCK",-107,48)
local Refresh=btn("↻",-54,30)
Refresh.TextSize=16

local Min=Instance.new("TextButton",M)
Min.Size=UDim2.fromOffset(30,30)
Min.Position=UDim2.new(1,-42,0,11)
Min.BackgroundColor3=Color3.fromRGB(30,35,46)
Min.BorderSizePixel=0
Min.Text="−"
Min.Font=Enum.Font.GothamBold
Min.TextSize=16
Min.TextColor3=Color3.fromRGB(225,230,240)
Min.AutoButtonColor=false
Min.ZIndex=5
corner(Min,8)

local L=Instance.new("ScrollingFrame",M)
L.Size=UDim2.new(1,-24,1,-112)
L.Position=UDim2.fromOffset(12,63)
L.BackgroundTransparency=1
L.BorderSizePixel=0
L.ScrollBarThickness=3
L.ScrollBarImageColor3=Color3.fromRGB(75,105,150)
L.AutomaticCanvasSize=Enum.AutomaticSize.Y
L.ZIndex=2

local LL=Instance.new("UIListLayout",L)
LL.Padding=UDim.new(0,6)
LL.SortOrder=Enum.SortOrder.LayoutOrder

local LPAD=Instance.new("UIPadding",L)
LPAD.PaddingBottom=UDim.new(0,7)

local Footer=label(
    M,
    "TikTok: Viet69xhamter",
    UDim2.new(0,12,1,-38),
    UDim2.new(1,-24,0,22),
    Enum.Font.GothamMedium,
    8,
    Color3.fromRGB(105,117,137),
    3
)
Footer.TextXAlignment=Enum.TextXAlignment.Center

local FX=Instance.new("Folder",G)
FX.Name="TVANDZ_EFFECTS"

local function clearFX()
    for _,v in ipairs(FX:GetChildren()) do
        v:Destroy()
    end
end

local fx=false

local function spawnFX()
    if not fx or #FX:GetChildren()>=18 then return end

    local x,y=math.random(3,97),math.random(7,93)
    local t=Instance.new("TextLabel",FX)

    t.BackgroundTransparency=1
    t.AnchorPoint=Vector2.new(.5,.5)
    t.Position=UDim2.fromScale(x/100,y/100)
    t.Size=UDim2.fromOffset(math.random(70,110),24)
    t.Text="TVÀN DZ"
    t.Font=Enum.Font.GothamBold
    t.TextSize=math.random(9,13)
    t.TextColor3=Color3.fromRGB(math.random(180,255),math.random(180,255),math.random(180,255))
    t.TextTransparency=1
    t.Rotation=math.random(-12,12)
    t.ZIndex=1

    local s=Instance.new("UIStroke",t)
    s.Color=Color3.fromRGB(10,10,15)
    s.Thickness=1
    s.Transparency=.25

    TS:Create(t,TweenInfo.new(.35),{TextTransparency=.18}):Play()

    task.spawn(function()
        local life=math.random(20,35)/10
        local tx=math.clamp(x/100+math.random(-8,8)/100,.03,.97)
        local ty=math.clamp(y/100+math.random(-7,7)/100,.05,.95)

        task.wait(.15)
        if not fx or not t.Parent then
            if t.Parent then t:Destroy() end
            return
        end

        local tw=TS:Create(
            t,
            TweenInfo.new(life,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut),
            {
                Position=UDim2.fromScale(tx,ty),
                TextTransparency=.55
            }
        )

        tw:Play()
        tw.Completed:Wait()

        if t.Parent then
            TS:Create(t,TweenInfo.new(.45),{TextTransparency=1}):Play()
            task.wait(.45)
            if t.Parent then t:Destroy() end
        end
    end)
end

local function startFX()
    if fx then return end
    fx=true

    task.spawn(function()
        while fx do
            spawnFX()
            task.wait(.18)
        end
    end)
end

local function stopFX()
    fx=false
    clearFX()
end

local drag,ds,dp=false,nil,nil

T.InputBegan:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1
        or i.UserInputType==Enum.UserInputType.Touch then
        drag=true
        ds=i.Position
        dp=M.Position

        i.Changed:Connect(function()
            if i.UserInputState==Enum.UserInputState.End then
                drag=false
            end
        end)
    end
end)

UIS.InputChanged:Connect(function(i)
    if drag and (
        i.UserInputType==Enum.UserInputType.MouseMovement
        or i.UserInputType==Enum.UserInputType.Touch
    ) then
        local d=i.Position-ds
        M.Position=UDim2.new(
            dp.X.Scale,dp.X.Offset+d.X,
            dp.Y.Scale,dp.Y.Offset+d.Y
        )
    end
end)

local minimized=false

Min.MouseButton1Click:Connect(function()
    minimized=not minimized
    L.Visible=not minimized
    Footer.Visible=not minimized
    M.Size=minimized and UDim2.fromOffset(390,52) or UDim2.fromOffset(390,330)
    Min.Text=minimized and "+" or "−"
end)

local function getPos(o)
    if not o or not o.Parent then return end
    if o:IsA("BasePart") then return o.Position end

    if o:IsA("Model") then
        local ok,cf=pcall(o.GetPivot,o)
        if ok and cf then return cf.Position end
        if o.PrimaryPart then return o.PrimaryPart.Position end
    end

    local p=o:FindFirstChildWhichIsA("BasePart",true)
    return p and p.Position
end

local territoryNames={
    "territory","territories","territ","zone",
    "area","region","land","claim"
}

local territoryAttrs={
    "Territory","IsTerritory","Zone",
    "IsZone","Region","Area"
}

local ownerAttrs={
    "Owner","OwnerName","OwnerId","OwnerUserId",
    "ClaimedBy","ClaimedByUserId","Player",
    "PlayerName","PlayerId","UserId"
}

local function isTerritory(o)
    local n=o.Name:lower()

    for _,v in ipairs(territoryNames) do
        if n:find(v,1,true) then return true end
    end

    for _,v in ipairs(territoryAttrs) do
        if o:GetAttribute(v)~=nil then return true end
    end

    return false
end

local function isOwned(o)
    if not o then return false end

    local uid=tostring(LP.UserId)
    local name=LP.Name:lower()

    local function match(v)
        return v~=nil and (
            tostring(v)==uid or
            tostring(v):lower()==name
        )
    end

    for _,a in ipairs(ownerAttrs) do
        if match(o:GetAttribute(a)) then return true end
    end

    for _,a in ipairs({"IsOwned","Owned"}) do
        if o:GetAttribute(a)==true then
            local found=false

            for _,b in ipairs(ownerAttrs) do
                local v=o:GetAttribute(b)
                if v~=nil then
                    found=true
                    if match(v) then return true end
                end
            end

            if not found then return true end
        end
    end

    for _,d in ipairs(o:GetDescendants()) do
        if d:IsA("ObjectValue") then
            if d.Value==LP then return true end

        elseif d:IsA("StringValue") then
            local v=d.Value:lower()
            if v==name or v==uid then return true end

        elseif d:IsA("IntValue") or d:IsA("NumberValue") then
            if tostring(d.Value)==uid then return true end

        elseif d:IsA("BoolValue") then
            if d.Value and (
                d.Name=="IsOwned" or
                d.Name=="Owned" or
                d.Name=="Claimed"
            ) then
                return true
            end
        end
    end

    return false
end

local function findTerritories()
    local r,seen={},{}

    for _,o in ipairs(WS:GetDescendants()) do
        if (o:IsA("Model") or o:IsA("BasePart"))
            and not seen[o]
            and isTerritory(o) then

            local p=getPos(o)

            if p then
                seen[o]=true
                r[#r+1]={Object=o,Position=p}
            end
        end
    end

    table.sort(r,function(a,b)
        return a.Object.Name:lower()<b.Object.Name:lower()
    end)

    return r
end

local territories={}
local auto=false
local skipOwned=false
local manualLock=false
local token=0
local frozen=false
local freezeCF
local heartbeat

local oldWS,oldJP,oldJH,oldAR

local function setLock()
    Lock.Text=manualLock and "LOCK ✓" or "LOCK"
    Lock.BackgroundColor3=manualLock
        and Color3.fromRGB(42,120,78)
        or Color3.fromRGB(30,35,46)
end

local function unfreeze()
    frozen=false
    freezeCF=nil

    if heartbeat then
        heartbeat:Disconnect()
        heartbeat=nil
    end

    local h=LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")

    if h then
        h.WalkSpeed=oldWS or 16
        h.JumpPower=oldJP or 50
        h.JumpHeight=oldJH or 7.2
        h.AutoRotate=oldAR~=false
    end
end

local function freeze(cf)
    local c=LP.Character
    local h=c and c:FindFirstChildOfClass("Humanoid")
    local r=c and c:FindFirstChild("HumanoidRootPart")

    if not r then return false end

    if not frozen and h then
        oldWS,oldJP,oldJH,oldAR=
            h.WalkSpeed,h.JumpPower,h.JumpHeight,h.AutoRotate
    end

    frozen=true
    freezeCF=cf

    if h then
        h.WalkSpeed=0
        h.JumpPower=0
        h.JumpHeight=0
        h.AutoRotate=false
    end

    if heartbeat then heartbeat:Disconnect() end

    heartbeat=RS.Heartbeat:Connect(function()
        if not frozen or not freezeCF then return end

        local c2=LP.Character
        local r2=c2 and c2:FindFirstChild("HumanoidRootPart")

        if r2 then
            r2.CFrame=freezeCF
            r2.AssemblyLinearVelocity=Vector3.zero
            r2.AssemblyAngularVelocity=Vector3.zero
        end
    end)

    r.CFrame=cf
    r.AssemblyLinearVelocity=Vector3.zero
    r.AssemblyAngularVelocity=Vector3.zero

    return true
end

local function teleport(p)
    local c=LP.Character
    local r=c and c:FindFirstChild("HumanoidRootPart")

    if not r then return false end

    manualLock=false
    setLock()
    unfreeze()

    c:PivotTo(CFrame.new(p+Vector3.new(0,5,0)))
    task.wait()

    r=c:FindFirstChild("HumanoidRootPart")
    return r and freeze(r.CFrame) or false
end

local function clearList()
    for _,v in ipairs(L:GetChildren()) do
        if v:IsA("Frame") or v:IsA("TextLabel") then
            v:Destroy()
        end
    end
end

local function createEntry(d,i)
    local C=Instance.new("Frame",L)
    C.Size=UDim2.new(1,-3,0,49)
    C.BackgroundColor3=Color3.fromRGB(18,22,30)
    C.BorderSizePixel=0
    corner(C,9)

    local st=Instance.new("UIStroke",C)
    st.Color=Color3.fromRGB(43,51,66)
    st.Transparency=.2

    local N=Instance.new("TextLabel",C)
    N.Size=UDim2.fromOffset(34,32)
    N.Position=UDim2.fromOffset(7,8)
    N.BackgroundColor3=Color3.fromRGB(25,38,55)
    N.Text=string.format("%02d",i)
    N.Font=Enum.Font.GothamBold
    N.TextSize=9
    N.TextColor3=Color3.fromRGB(100,175,255)
    corner(N,8)

    label(
        C,
        "Lãnh thổ "..i,
        UDim2.fromOffset(48,6),
        UDim2.new(1,-125,0,18),
        Enum.Font.GothamBold,
        10,
        Color3.fromRGB(238,242,248),
        1
    )

    label(
        C,
        string.format(
            "X %.0f  Y %.0f  Z %.0f",
            d.Position.X,d.Position.Y,d.Position.Z
        ),
        UDim2.fromOffset(48,25),
        UDim2.new(1,-125,0,14),
        Enum.Font.Gotham,
        8,
        Color3.fromRGB(105,117,137),
        1
    )

    local B=Instance.new("TextButton",C)
    B.Size=UDim2.fromOffset(60,30)
    B.Position=UDim2.new(1,-67,.5,-15)
    B.BackgroundColor3=Color3.fromRGB(43,105,205)
    B.BorderSizePixel=0
    B.Text="TELE"
    B.Font=Enum.Font.GothamBold
    B.TextSize=9
    B.TextColor3=Color3.new(1,1,1)
    B.AutoButtonColor=false
    corner(B,8)

    B.MouseButton1Click:Connect(function()
        if auto then return end

        local p=getPos(d.Object)
        if not p then
            Status.Text="Không tìm thấy vị trí"
            return
        end

        d.Position=p
        token+=1
        local t=token

        if teleport(p) then
            for s=11,1,-1 do
                if t~=token or auto or not frozen then return end

                Status.Text=string.format(
                    "Lãnh thổ %d  •  KHÓA  •  %ds",i,s
                )

                task.wait(1)
            end

            if t==token and not auto and not manualLock then
                unfreeze()
                Status.Text="Lãnh thổ "..i.."  •  Hoàn tất"
            end
        end
    end)
end

local function render()
    clearList()

    for i,d in ipairs(territories) do
        createEntry(d,i)
    end

    if #territories==0 then
        label(
            L,
            "Không tìm thấy lãnh thổ",
            UDim2.new(),
            UDim2.new(1,0,0,55),
            Enum.Font.GothamMedium,
            10,
            Color3.fromRGB(105,115,132)
        )
    end

    if not auto and not frozen and not manualLock then
        Status.Text=#territories.." lãnh thổ"
    end
end

local function refresh()
    auto=false
    stopFX()
    token+=1
    manualLock=false
    setLock()
    unfreeze()

    Auto.Text="AUTO"
    Auto.BackgroundColor3=Color3.fromRGB(30,35,46)
    Status.Text="Đang quét..."

    task.wait()

    territories=findTerritories()
    render()
end

Skip.MouseButton1Click:Connect(function()
    skipOwned=not skipOwned

    Skip.Text=skipOwned and "SKIP ✓" or "SKIP"
    Skip.BackgroundColor3=skipOwned
        and Color3.fromRGB(42,120,78)
        or Color3.fromRGB(30,35,46)

    Status.Text=skipOwned
        and "Skip lãnh thổ đã chiếm: BẬT"
        or "Skip lãnh thổ đã chiếm: TẮT"
end)

Lock.MouseButton1Click:Connect(function()
    if auto then
        Status.Text="Hãy STOP AUTO trước"
        return
    end

    if manualLock then
        manualLock=false
        unfreeze()
        setLock()
        Status.Text="Khoá: TẮT"
        return
    end

    local c=LP.Character
    local r=c and c:FindFirstChild("HumanoidRootPart")

    if not r then
        Status.Text="Không tìm thấy nhân vật"
        return
    end

    manualLock=true

    if freeze(r.CFrame) then
        setLock()
        Status.Text="LOCK: BẬT  •  Nhân vật đã khóa"
    else
        manualLock=false
        setLock()
        Status.Text="Không thể khóa nhân vật"
    end
end)

local function stop()
    auto=false
    token+=1
    stopFX()

    manualLock=false
    setLock()
    unfreeze()

    Auto.Text="Tự động"
    Auto.BackgroundColor3=Color3.fromRGB(30,35,46)
    Status.Text="Auto đã dừng"
end

local function start()
    if auto then
        stop()
        return
    end

    if #territories==0 then
        Status.Text="Không còn lãnh thổ"
        return
    end

    if manualLock then
        manualLock=false
        setLock()
        unfreeze()
    end

    auto=true
    token+=1

    local t=token

    Auto.Text="Dừng"
    Auto.BackgroundColor3=Color3.fromRGB(175,55,65)
    startFX()

    task.spawn(function()
        local i=1

        while auto and t==token do
            if i>#territories then i=1 end

            local d=territories[i]

            if skipOwned and isOwned(d.Object) then
                Status.Text=string.format(
                    "Lãnh thổ %d  •  CỦA BẠN  •  BỎ QUA",i
                )

                i+=1
                task.wait(.08)
                continue
            end

            local p=getPos(d.Object)

            if p then
                d.Position=p

                if teleport(p) then
                    for s=11,1,-1 do
                        if not auto or t~=token then
                            unfreeze()
                            return
                        end

                        Status.Text=string.format(
                            "Lãnh thổ %d  •  KHÓA  •  %ds",i,s
                        )

                        task.wait(1)
                    end
                end
            end

            i+=1
            task.wait(.1)
        end

        if not manualLock then
            unfreeze()
        end
    end)
end

Auto.MouseButton1Click:Connect(start)
Refresh.MouseButton1Click:Connect(refresh)

LP.CharacterAdded:Connect(function()
    auto=false
    stopFX()
    manualLock=false
    frozen=false
    freezeCF=nil

    if heartbeat then
        heartbeat:Disconnect()
        heartbeat=nil
    end

    setLock()

    Auto.Text="Tự động"
    Auto.BackgroundColor3=Color3.fromRGB(30,35,46)

    task.wait(1)

    territories=findTerritories()
    render()
end)

setLock()
task.wait(.3)
refresh()
