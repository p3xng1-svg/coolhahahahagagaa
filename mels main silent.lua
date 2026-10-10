--// MELS MAIN - DaHood UNDETECTED (WHITELIST EDITION)
--// Place in StarterPlayer > StarterPlayerScripts

local APPROVED_USERS = {
    1886967799, 3634382316, 4464060250
}

local services = {
    Players = game:GetService("Players"),
    TweenService = game:GetService("TweenService"),
    UIS = game:GetService("UserInputService"),
    RunService = game:GetService("RunService"),
    Lighting = game:GetService("Lighting"),
    CoreGui = game:GetService("CoreGui"),
    StarterGui = game:GetService("StarterGui"),
    ReplicatedStorage = game:GetService("ReplicatedStorage"),
    SoundService = game:GetService("SoundService"),
    ContentProvider = game:GetService("ContentProvider"),
    Debris = game:GetService("Debris"),
    HttpService = game:GetService("HttpService"),
    MarketplaceService = game:GetService("MarketplaceService"),
    Stats = game:GetService("Stats"),
}

local LocalPlayer = services.Players.LocalPlayer

local function IsApproved(userId)
    for _, id in ipairs(APPROVED_USERS) do
        if id == userId then return true end
    end
    return false
end

if not IsApproved(LocalPlayer.UserId) then
    local inviteLink = "https://discord.gg/hB7Uz6xyX"
    if setclipboard then
        pcall(setclipboard, inviteLink)
    elseif toclipboard then
        pcall(toclipboard, inviteLink)
    elseif set_clipboard then
        pcall(set_clipboard, inviteLink)
    end
    LocalPlayer:Kick("tried stealing my script https://discord.gg/hB7Uz6xyX XO.")
    return
end
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")
local StarterGui = game:GetService("StarterGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")

--==================================================
-- UI SOUNDS
--==================================================
local ContentProvider = game:GetService("ContentProvider")

local _hoverSound = Instance.new("Sound")
_hoverSound.Name = "MelsUIHover"
_hoverSound.SoundId = "rbxassetid://9120299506"
_hoverSound.Volume = 0.18
_hoverSound.PlaybackSpeed = 2.0
_hoverSound.Parent = SoundService

local _clickSound = Instance.new("Sound")
_clickSound.Name = "MelsUIClick"
_clickSound.SoundId = "rbxassetid://113397864512278"
_clickSound.Volume = 0.28
_clickSound.PlaybackSpeed = 1.0
_clickSound.Parent = SoundService

task.spawn(function()
    pcall(function()
        ContentProvider:PreloadAsync({_hoverSound, _clickSound})
    end)
end)

local function _playUISound(sound, duration)
    if not sound or sound.SoundId == "" then return end
    sound:Stop()
    sound.TimePosition = 0
    SoundService:PlayLocalSound(sound)
    if duration then
        task.delay(duration, function()
            if sound.IsPlaying then
                sound:Stop()
            end
        end)
    end
end

local function _playHover()
    _playUISound(_hoverSound, 0.12)
end

local function _playClick()
    _playUISound(_clickSound, 0.08)
end

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local mouse = Player:GetMouse()
local camera = workspace.CurrentCamera

local oldGui = CoreGui:FindFirstChild("_ui")
if oldGui then oldGui:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "_ui"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = CoreGui

--==================================================
-- WHITELIST STATE
--==================================================
local _whitelisted = {}
local _whitelistRows = {}

local function _isWhitelisted(plr)
    if not plr then return false end
    return _whitelisted[plr.UserId] == true
end

--==================================================
-- TIME CHANGER VARIABLES
--==================================================

local _timeOverride = false
local _timeTarget = Lighting.ClockTime
local _timeOverrideConnection = nil

--==================================================
-- ORIGINAL MELS VARIABLES
--==================================================

local _silent = true
local _fov = 1000
local _spread = 100
local _exclude = false
local _wall = false
local _knock = false
local _aimPart = "Head"
local _menuKey = "RightShift"
local _uiVisible = true

local _esp = false
local _espBind = "P"
local _espActive = false
local _espBox = false
local _espName = false
local _espColor = Color3.fromRGB(145, 100, 220)

local _headSize = 1
local _hitTrans = 0.7
local _hitColor = Color3.fromRGB(145, 100, 220)
local _headless = false
local _korblox = false
local _hitbox = false

local _fogColor = Color3.fromRGB(200, 195, 215)
local _fogIntensity = 500

--==================================================
-- ORIGINAL FUNCTIONS
--==================================================

local function _checkKnock(char)
    if not _knock then return false end
    local effects = char:FindFirstChild("Bodyeffects") or char:FindFirstChild("BodyEffects")
    if not effects then return false end
    local ko = effects:FindFirstChild("K.O") or effects:FindFirstChild("KO")
    local dead = effects:FindFirstChild("Dead")
    if ko and ko.Value == true then return true end
    if dead and dead.Value == true then return true end
    return false
end

local function _getPart(char)
    local closest = nil
    local shortest = math.huge
    local mpos = Vector2.new(mouse.X, mouse.Y)
    local parts = {"Head", "HumanoidRootPart", "LeftUpperLeg", "LeftLowerLeg", "LeftFoot", "RightUpperLeg", "RightLowerLeg", "RightFoot", "LeftUpperArm", "LeftLowerArm", "LeftHand", "RightUpperArm", "RightLowerArm", "RightHand"}
    for _, pName in pairs(parts) do
        local p = char:FindFirstChild(pName)
        if p then
            local pos, on = camera:WorldToScreenPoint(p.Position)
            if on then
                local dist = (Vector2.new(pos.X, pos.Y) - mpos).Magnitude
                if dist < shortest then
                    shortest = dist
                    closest = p
                end
            end
        end
    end
    return closest or char:FindFirstChild("Head")
end

local function _getTarget()
    if not _silent then return nil end
    local mpos = Vector2.new(mouse.X, mouse.Y)
    local best = nil
    local bestDist = _fov
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= Player and v.Character and v.Character:FindFirstChild("Humanoid") and v.Character.Humanoid.Health > 0 then
            if not _isWhitelisted(v) then
                if not _checkKnock(v.Character) then
                    local part
                    if _aimPart == "Closest Part" then
                        part = _getPart(v.Character)
                    elseif _aimPart == "Body" then
                        part = v.Character:FindFirstChild("HumanoidRootPart")
                    elseif _aimPart == "Left Leg" then
                        part = v.Character:FindFirstChild("LeftUpperLeg") or v.Character:FindFirstChild("LeftLeg")
                    elseif _aimPart == "Right Leg" then
                        part = v.Character:FindFirstChild("RightUpperLeg") or v.Character:FindFirstChild("RightLeg")
                    elseif _aimPart == "Left Arm" then
                        part = v.Character:FindFirstChild("LeftUpperArm") or v.Character:FindFirstChild("LeftArm")
                    elseif _aimPart == "Right Arm" then
                        part = v.Character:FindFirstChild("RightUpperArm") or v.Character:FindFirstChild("RightArm")
                    else
                        part = v.Character:FindFirstChild("Head")
                    end
                    if part then
                        local pos, on = camera:WorldToScreenPoint(part.Position)
                        if on then
                            local vec = Vector2.new(pos.X, pos.Y)
                            local dist = (vec - mpos).Magnitude
                            if dist < bestDist then
                                if _wall then
                                    local ray = Ray.new(camera.CFrame.Position, (part.Position - camera.CFrame.Position).Unit * 500)
                                    local hit = workspace:FindPartOnRayWithIgnoreList(ray, {Player.Character, camera})
                                    if hit and hit:IsDescendantOf(v.Character) then
                                        bestDist = dist
                                        best = part
                                    end
                                else
                                    bestDist = dist
                                    best = part
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    return best
end

local _gh, _old
local _ok, _res = pcall(function()
    return require(game:GetService("ReplicatedStorage").Modules.GunHandler)
end)
if _ok then
    _gh = _res
    _old = _gh.getAim
    _gh.getAim = function(origin, maxDist)
        if _exclude then
            local tool = Player.Character and Player.Character:FindFirstChildOfClass("Tool")
            if tool and (tool.Name == "[Revolver]" or tool.Name == "Revolver") then
                return _old(origin, maxDist)
            end
        end
        if _silent then
            local target = _getTarget()
            if target then
                local dir = (target.Position - origin).Unit
                local dist = (target.Position - origin).Magnitude
                return dir, math.min(dist, maxDist or 200)
            end
        end
        return _old(origin, maxDist)
    end
end

--==================================================
-- THEMES (static, single theme)
--==================================================

local _themes = {
    Pink = {
        Main = Color3.fromRGB(255, 230, 240),
        Sidebar = Color3.fromRGB(255, 190, 215),
        Content = Color3.fromRGB(255, 245, 250),
        Panel = Color3.fromRGB(255, 235, 245),
        Accent = Color3.fromRGB(255, 130, 180),
        AccentLight = Color3.fromRGB(255, 220, 235),
        Text = Color3.fromRGB(255, 110, 165),
        Stroke = Color3.fromRGB(255, 150, 190),
        DarkText = Color3.fromRGB(200, 80, 130)
    }
}

local _currTheme = "Pink"

--==================================================
-- GUI CREATION
--==================================================

local _main = Instance.new("Frame")
_main.Name = "_main"
_main.Size = UDim2.fromOffset(680, 480)
_main.Position = UDim2.fromScale(0.5, 0.5)
_main.AnchorPoint = Vector2.new(0.5, 0.5)
_main.BackgroundColor3 = _themes.Pink.Main
_main.BorderSizePixel = 0
_main.Parent = ScreenGui

local _mainCorner = Instance.new("UICorner")
_mainCorner.CornerRadius = UDim.new(0, 18)
_mainCorner.Parent = _main

local _mainStroke = Instance.new("UIStroke")
_mainStroke.Name = "_mainStroke"
_mainStroke.Color = _themes.Pink.Stroke
_mainStroke.Thickness = 2
_mainStroke.Parent = _main

local _dragBar = Instance.new("Frame")
_dragBar.Name = "_dragBar"
_dragBar.Size = UDim2.new(1, 0, 0, 44)
_dragBar.Position = UDim2.new(0, 0, 0, 0)
_dragBar.BackgroundTransparency = 1
_dragBar.ZIndex = 100
_dragBar.Parent = _main

local _sidebar = Instance.new("Frame")
_sidebar.Name = "_sidebar"
_sidebar.Size = UDim2.new(0, 195, 1, 0)
_sidebar.BackgroundColor3 = _themes.Pink.Sidebar
_sidebar.BorderSizePixel = 0
_sidebar.Parent = _main

local _sidebarCorner = Instance.new("UICorner")
_sidebarCorner.CornerRadius = UDim.new(0, 18)
_sidebarCorner.Parent = _sidebar

local _sidebarFill = Instance.new("Frame")
_sidebarFill.Name = "_sidebarFill"
_sidebarFill.Size = UDim2.new(0, 30, 1, 0)
_sidebarFill.Position = UDim2.new(1, -30, 0, 0)
_sidebarFill.BackgroundColor3 = _themes.Pink.Sidebar
_sidebarFill.BorderSizePixel = 0
_sidebarFill.Parent = _sidebar

local _title = Instance.new("TextLabel")
_title.Name = "_title"
_title.Size = UDim2.new(1, 0, 0, 45)
_title.Position = UDim2.new(0, 0, 0, 8)
_title.BackgroundTransparency = 1
_title.Text = "/mels"
_title.TextColor3 = _themes.Pink.Accent
_title.TextXAlignment = Enum.TextXAlignment.Center
_title.TextYAlignment = Enum.TextYAlignment.Center
_title.Font = Enum.Font.FredokaOne
_title.TextSize = 26
_title.Parent = _sidebar

local _tabHolder = Instance.new("ScrollingFrame")
_tabHolder.Name = "_tabs"
_tabHolder.Size = UDim2.new(1, -16, 1, -155)
_tabHolder.Position = UDim2.new(0, 8, 0, 58)
_tabHolder.BackgroundTransparency = 1
_tabHolder.BorderSizePixel = 0
_tabHolder.ScrollBarThickness = 3
_tabHolder.ScrollBarImageTransparency = 0.4
_tabHolder.AutomaticCanvasSize = Enum.AutomaticSize.Y
_tabHolder.CanvasSize = UDim2.new(0, 0, 0, 0)
_tabHolder.Parent = _sidebar

local _tabLayout = Instance.new("UIListLayout")
_tabLayout.Padding = UDim.new(0, 6)
_tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
_tabLayout.Parent = _tabHolder

local _profile = Instance.new("Frame")
_profile.Name = "_profile"
_profile.Size = UDim2.new(1, -16, 0, 70)
_profile.Position = UDim2.new(0, 8, 1, -78)
_profile.BackgroundColor3 = _themes.Pink.AccentLight
_profile.BorderSizePixel = 0
_profile.ZIndex = 10
_profile.Parent = _sidebar

local _profileCorner = Instance.new("UICorner")
_profileCorner.CornerRadius = UDim.new(0, 10)
_profileCorner.Parent = _profile

local _avatar = Instance.new("ImageLabel")
_avatar.Name = "_avatar"
_avatar.Size = UDim2.fromOffset(46, 46)
_avatar.Position = UDim2.new(0, 8, 0.5, -23)
_avatar.BackgroundTransparency = 1
_avatar.ZIndex = 11
_avatar.Parent = _profile

local _avatarCorner = Instance.new("UICorner")
_avatarCorner.CornerRadius = UDim.new(1, 0)
_avatarCorner.Parent = _avatar

local _displayName = Instance.new("TextLabel")
_displayName.Name = "_display"
_displayName.Size = UDim2.new(1, -65, 0, 26)
_displayName.Position = UDim2.new(0, 60, 0.5, -18)
_displayName.BackgroundTransparency = 1
_displayName.Text = Player.DisplayName
_displayName.TextColor3 = _themes.Pink.Text
_displayName.Font = Enum.Font.FredokaOne
_displayName.TextSize = 14
_displayName.TextXAlignment = Enum.TextXAlignment.Left
_displayName.TextTruncate = Enum.TextTruncate.AtEnd
_displayName.ZIndex = 11
_displayName.Parent = _profile

local _username = Instance.new("TextLabel")
_username.Name = "_username"
_username.Size = UDim2.new(1, -65, 0, 18)
_username.Position = UDim2.new(0, 60, 0.5, 8)
_username.BackgroundTransparency = 1
_username.Text = "@" .. Player.Name
_username.TextColor3 = _themes.Pink.Text
_username.Font = Enum.Font.Gotham
_username.TextSize = 10
_username.TextXAlignment = Enum.TextXAlignment.Left
_username.TextTruncate = Enum.TextTruncate.AtEnd
_username.ZIndex = 11
_username.Parent = _profile

task.spawn(function()
    local ok, img = pcall(function()
        return Players:GetUserThumbnailAsync(Player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
    end)
    if ok then _avatar.Image = img end
end)

local _content = Instance.new("Frame")
_content.Name = "_content"
_content.Size = UDim2.new(1, -215, 1, -30)
_content.Position = UDim2.new(0, 205, 0, 15)
_content.BackgroundColor3 = _themes.Pink.Content
_content.BorderSizePixel = 0
_content.Parent = _main

local _contentCorner = Instance.new("UICorner")
_contentCorner.CornerRadius = UDim.new(0, 14)
_contentCorner.Parent = _content

local _pageHolder = Instance.new("Frame")
_pageHolder.Name = "_pages"
_pageHolder.Size = UDim2.new(1, -30, 1, -65)
_pageHolder.Position = UDim2.new(0, 15, 0, 55)
_pageHolder.BackgroundTransparency = 1
_pageHolder.Parent = _content

local _tabList = {
    "Silent Aim",
    "Fog",
    "Hitbox",
    "Avatar",
    "Time Changer",
    "Whitelist",
    "Settings"
}
local _pages = {}
local _buttons = {}
local _killBtn = nil
local _uiElements = {}

--==================================================
-- UI HELPERS
--==================================================

local function _makeToggle(parent, y, text, val, cb)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -20, 0, 34)
    row.Position = UDim2.new(0, 10, 0, y)
    row.BackgroundTransparency = 1
    row.Parent = parent

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.55, 0, 1, 0)
    label.Text = text
    label.TextColor3 = _themes[_currTheme].Text
    label.TextSize = 13
    label.Font = Enum.Font.GothamBold
    label.BackgroundTransparency = 1
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = row

    local container = Instance.new("Frame")
    container.Size = UDim2.new(0, 44, 0, 24)
    container.Position = UDim2.new(1, -52, 0.5, -12)
    container.BackgroundColor3 = val and _themes[_currTheme].Accent or Color3.fromRGB(200, 200, 210)
    container.BackgroundTransparency = val and 0.3 or 0.4
    container.BorderSizePixel = 0
    container.Parent = row
    local corner = Instance.new("UICorner", container)
    corner.CornerRadius = UDim.new(1, 0)

    local thumb = Instance.new("Frame")
    thumb.Size = UDim2.new(0, 18, 0, 18)
    thumb.Position = val and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
    thumb.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    thumb.BorderSizePixel = 0
    thumb.Parent = container
    local tCorner = Instance.new("UICorner", thumb)
    tCorner.CornerRadius = UDim.new(1, 0)

    local isOn = val

    table.insert(_uiElements, {
        type = "toggle",
        container = container,
        label = label,
        thumb = thumb,
        isOn = isOn
    })

    local function anim(target)
        local color = target and _themes[_currTheme].Accent or Color3.fromRGB(200, 200, 210)
        local trans = target and 0.3 or 0.4
        local pos = target and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
        TweenService:Create(container, TweenInfo.new(0.2), {BackgroundColor3 = color, BackgroundTransparency = trans}):Play()
        TweenService:Create(thumb, TweenInfo.new(0.2), {Position = pos}):Play()
    end

    local function toggle()
        isOn = not isOn
        _playClick()
        anim(isOn)
        if cb then cb(isOn) end
    end

    container.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then toggle() end
    end)
    thumb.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then toggle() end
    end)
    return row
end

local function _makeSlider(parent, y, text, val, min, max, step, cb)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -20, 0, 34)
    row.Position = UDim2.new(0, 10, 0, y)
    row.BackgroundTransparency = 1
    row.Parent = parent

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.2, 0, 1, 0)
    label.Text = text
    label.TextColor3 = _themes[_currTheme].Text
    label.TextSize = 13
    label.Font = Enum.Font.GothamBold
    label.BackgroundTransparency = 1
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = row

    local valLabel = Instance.new("TextLabel")
    valLabel.Size = UDim2.new(0.08, 0, 1, 0)
    valLabel.Position = UDim2.new(0.92, 0, 0, 0)
    if step and step < 0.01 then
        valLabel.Text = string.format("%.3f", val)
    elseif step and step < 1 then
        valLabel.Text = string.format("%.2f", val)
    else
        valLabel.Text = tostring(val)
    end
    valLabel.TextColor3 = _themes[_currTheme].Accent
    valLabel.TextSize = 13
    valLabel.Font = Enum.Font.GothamBold
    valLabel.BackgroundTransparency = 1
    valLabel.TextXAlignment = Enum.TextXAlignment.Right
    valLabel.Parent = row

    local trackC = Instance.new("Frame")
    trackC.Size = UDim2.new(0.68, 0, 1, 0)
    trackC.Position = UDim2.new(0.22, 0, 0, 0)
    trackC.BackgroundTransparency = 1
    trackC.Parent = row

    local track = Instance.new("Frame")
    track.Size = UDim2.new(1, 0, 0.3, 0)
    track.Position = UDim2.new(0, 0, 0.5, -0.15)
    track.BackgroundColor3 = Color3.fromRGB(200, 200, 210)
    track.BackgroundTransparency = 0.5
    track.BorderSizePixel = 0
    track.Parent = trackC
    Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

    local fill = Instance.new("Frame")
    local p = (val - min) / (max - min)
    fill.Size = UDim2.new(p, 0, 1, 0)
    fill.BackgroundColor3 = _themes[_currTheme].Accent
    fill.BackgroundTransparency = 0.3
    fill.BorderSizePixel = 0
    fill.Parent = track
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

    local thumb = Instance.new("Frame")
    thumb.Size = UDim2.new(0, 16, 0, 16)
    thumb.Position = UDim2.new(p, -8, 0.5, -8)
    thumb.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    thumb.BorderSizePixel = 2
    thumb.BorderColor3 = _themes[_currTheme].Accent
    thumb.Parent = trackC
    Instance.new("UICorner", thumb).CornerRadius = UDim.new(1, 0)

    table.insert(_uiElements, {
        type = "slider",
        label = label,
        valLabel = valLabel,
        fill = fill,
        thumb = thumb
    })

    local conn, dragging
    local function update(input)
        local tPos = track.AbsolutePosition
        local tSize = track.AbsoluteSize
        local pos = input.Position.X - tPos.X
        local perc = math.clamp(pos / tSize.X, 0, 1)
        local value = min + (perc * (max - min))
        if step then
            value = math.round(value / step) * step
        else
            value = math.round(value)
        end
        value = math.max(min, math.min(max, value))
        local np = (value - min) / (max - min)
        fill.Size = UDim2.new(np, 0, 1, 0)
        thumb.Position = UDim2.new(np, -8, 0.5, -8)
        if step and step < 0.01 then
            valLabel.Text = string.format("%.3f", value)
        elseif step and step < 1 then
            valLabel.Text = string.format("%.2f", value)
        else
            valLabel.Text = tostring(value)
        end
        cb(value)
    end

    thumb.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            _playClick()
            dragging = true
            if conn then conn:Disconnect() end
            conn = UIS.InputChanged:Connect(function(move)
                if dragging and move.UserInputType == Enum.UserInputType.MouseMovement then
                    update(move)
                end
            end)
        end
    end)

    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
            if conn then conn:Disconnect() conn = nil end
        end
    end)
    return row
end

local function _makeDropdown(parent, y, text, items, def, cb)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -20, 0, 34)
    row.Position = UDim2.new(0, 10, 0, y)
    row.BackgroundTransparency = 1
    row.Parent = parent

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.25, 0, 1, 0)
    label.Text = text
    label.TextColor3 = _themes[_currTheme].Text
    label.TextSize = 13
    label.Font = Enum.Font.GothamBold
    label.BackgroundTransparency = 1
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = row

    local main = Instance.new("TextButton")
    main.Size = UDim2.new(0, 160, 0, 30)
    main.Position = UDim2.new(1, -170, 0.5, -15)
    main.BackgroundColor3 = _themes[_currTheme].AccentLight
    main.BackgroundTransparency = 0.4
    main.Text = items[def or 1]
    main.TextColor3 = _themes[_currTheme].Text
    main.Font = Enum.Font.Gotham
    main.TextSize = 12
    main.ZIndex = 5
    main.Parent = row
    Instance.new("UICorner", main).CornerRadius = UDim.new(0, 6)

    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(0, 160, 0, math.min(#items * 28, 120))
    scroll.Position = UDim2.new(1, -170, 0, 34)
    scroll.BackgroundColor3 = _themes[_currTheme].Panel
    scroll.BackgroundTransparency = 0.1
    scroll.BorderSizePixel = 0
    scroll.Visible = false
    scroll.ZIndex = 6
    scroll.CanvasSize = UDim2.new(0, 0, 0, #items * 28)
    scroll.ScrollBarThickness = 2
    scroll.ScrollBarImageColor3 = _themes[_currTheme].Accent
    scroll.Parent = row
    Instance.new("UICorner", scroll).CornerRadius = UDim.new(0, 6)

    local scrollItems = {}
    for i, item in ipairs(items) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 26)
        btn.Position = UDim2.new(0, 0, 0, (i-1) * 28)
        btn.BackgroundColor3 = _themes[_currTheme].Panel
        btn.BackgroundTransparency = 0.2
        btn.Text = "  " .. item
        btn.TextColor3 = _themes[_currTheme].Text
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 12
        btn.ZIndex = 7
        btn.Parent = scroll
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
        btn.MouseEnter:Connect(function()
            _playHover()
        end)
        table.insert(scrollItems, btn)
        btn.MouseButton1Click:Connect(function()
            _playClick()
            main.Text = item
            scroll.Visible = false
            cb(i, item)
        end)
    end

    table.insert(_uiElements, {
        type = "dropdown",
        label = label,
        main = main,
        scroll = scroll,
        items = scrollItems
    })

    main.MouseButton1Click:Connect(function()
        _playClick()
        scroll.Visible = not scroll.Visible
    end)
    return row
end

local function _makeKeybind(parent, y, text, def, cb)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -20, 0, 34)
    row.Position = UDim2.new(0, 10, 0, y)
    row.BackgroundTransparency = 1
    row.Parent = parent

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.4, 0, 1, 0)
    label.Text = text
    label.TextColor3 = _themes[_currTheme].Text
    label.TextSize = 13
    label.Font = Enum.Font.GothamBold
    label.BackgroundTransparency = 1
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = row

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 90, 0, 30)
    btn.Position = UDim2.new(1, -100, 0.5, -15)
    btn.BackgroundColor3 = _themes[_currTheme].AccentLight
    btn.BackgroundTransparency = 0.4
    btn.Text = def
    btn.TextColor3 = _themes[_currTheme].Text
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 13
    btn.Parent = row
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

    table.insert(_uiElements, {
        type = "keybind",
        label = label,
        btn = btn
    })

    local binding = false
    btn.MouseButton1Click:Connect(function()
        binding = true
        btn.BackgroundColor3 = _themes[_currTheme].Accent
        btn.BackgroundTransparency = 0.2
        btn.Text = "..."
    end)

    UIS.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if binding and input.UserInputType == Enum.UserInputType.Keyboard then
            local name = input.KeyCode.Name
            btn.Text = name
            btn.BackgroundColor3 = _themes[_currTheme].AccentLight
            btn.BackgroundTransparency = 0.4
            binding = false
            if cb then cb(name) end
        end
    end)
    return row
end

--==================================================
-- TIME CHANGER FUNCTIONS
--==================================================

local function _formatTime(hour)
    hour = hour % 24
    local h = math.floor(hour)
    local m = math.floor((hour - h) * 60)
    return string.format("%02d:%02d", h, m)
end

local function _setTime(hour)
    hour = math.clamp(hour, 0, 24)
    _timeTarget = hour
    local timeString = _formatTime(hour)
    Lighting.ClockTime = hour
    Lighting.TimeOfDay = timeString .. ":00"
    if _timeOverride then
        _startTimeOverride()
    end
end

local function _startTimeOverride()
    if _timeOverrideConnection then
        _timeOverrideConnection:Disconnect()
    end
    _timeOverrideConnection = RunService.Heartbeat:Connect(function()
        if _timeTarget ~= nil and _timeOverride then
            local current = Lighting.ClockTime
            local diff = math.abs(current - _timeTarget)
            if diff > 0.01 then
                Lighting.ClockTime = _timeTarget
                Lighting.TimeOfDay = _formatTime(_timeTarget) .. ":00"
            end
        end
    end)
end

local function _stopTimeOverride()
    if _timeOverrideConnection then
        _timeOverrideConnection:Disconnect()
        _timeOverrideConnection = nil
    end
end

--==================================================
-- KILL FUNCTION
--==================================================

local function _kill()
    if Player and Player.Character then
        local hum = Player.Character:FindFirstChild("Humanoid")
        if hum then
            hum.WalkSpeed = 16
            hum.JumpPower = 50
        end
    end
    _espActive = false
    _espBox = false
    _espName = false
    _hitbox = false
    _esp = false
    _timeOverride = false
    _stopTimeOverride()
    Lighting.FogColor = Color3.fromRGB(130, 120, 150)
    if Lighting:FindFirstChild("Atmosphere") then
        Lighting.Atmosphere.FogColor = Color3.fromRGB(130, 120, 150)
    end
    Lighting.FogEnd = 500
    Lighting.FogStart = 50
    if _gh and _old then
        _gh.getAim = _old
    end
    if ScreenGui then
        ScreenGui:Destroy()
    end
    for _, c in pairs(PlayerGui:GetChildren()) do
        if c.Name == "_ui" then
            c:Destroy()
        end
    end
end

--==================================================
-- UI THEME UPDATER (static, no theme tab)
--==================================================

local function _updateUITheme()
    local theme = _themes[_currTheme]
    for _, elem in pairs(_uiElements) do
        if elem.type == "toggle" then
            elem.label.TextColor3 = theme.Text
        elseif elem.type == "slider" then
            elem.label.TextColor3 = theme.Text
            elem.valLabel.TextColor3 = theme.Accent
            elem.fill.BackgroundColor3 = theme.Accent
            elem.thumb.BorderColor3 = theme.Accent
        elseif elem.type == "dropdown" then
            elem.label.TextColor3 = theme.Text
            elem.main.BackgroundColor3 = theme.AccentLight
            elem.main.TextColor3 = theme.Text
            if elem.scroll then
                elem.scroll.BackgroundColor3 = theme.Panel
                elem.scroll.ScrollBarImageColor3 = theme.Accent
            end
            if elem.items then
                for _, item in pairs(elem.items) do
                    item.BackgroundColor3 = theme.Panel
                    item.TextColor3 = theme.Text
                end
            end
        elseif elem.type == "keybind" then
            elem.label.TextColor3 = theme.Text
            elem.btn.BackgroundColor3 = theme.AccentLight
            elem.btn.TextColor3 = theme.Text
        elseif elem.type == "text" then
            elem.label.TextColor3 = theme.Text
        end
    end
end

local _pageTransitionId = 0

local function _showPage(name)
    _pageTransitionId += 1
    local transitionId = _pageTransitionId

    for n, page in pairs(_pages) do
        if n ~= name then
            page.Visible = false
            page.Position = UDim2.new(0, 0, 0, 0)
        end
    end

    local newPage = _pages[name]
    if newPage then
        newPage.Position = UDim2.new(0, 8, 0, 0)
        newPage.Visible = true

        local tween = TweenService:Create(
            newPage,
            TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {Position = UDim2.new(0, 0, 0, 0)}
        )
        tween:Play()

        task.delay(0.16, function()
            if transitionId == _pageTransitionId and newPage.Parent then
                newPage.Position = UDim2.new(0, 0, 0, 0)
            end
        end)
    end

    local theme = _themes[_currTheme]
    for n, btn in pairs(_buttons) do
        local selected = (n == name)
        TweenService:Create(btn, TweenInfo.new(0.2), {
            BackgroundColor3 = selected and theme.Accent or theme.AccentLight
        }):Play()
        btn.TextColor3 = selected and Color3.fromRGB(255,255,255) or theme.Text
    end
end

--==================================================
-- WHITELIST TAB HELPERS
--==================================================

local _wlListFrame
local _wlCountLabel

local function _wlApplyRowVisual(plr)
    local row = _whitelistRows[plr.UserId]
    if not row then return end
    local hl = row:FindFirstChild("_highlight")
    local dot = row:FindFirstChild("_dot")
    local status = row:FindFirstChild("_status")
    local on = _isWhitelisted(plr)
    if hl then hl.Visible = on end
    if dot then
        dot.BackgroundColor3 = on and Color3.fromRGB(80, 220, 140) or Color3.fromRGB(180, 180, 190)
    end
    if status then
        status.Text = on and "WHITELISTED" or "Not whitelisted"
        status.TextColor3 = on and Color3.fromRGB(60, 200, 120) or _themes[_currTheme].Text
    end
end

local function _wlRefreshCount()
    if not _wlCountLabel then return end
    local n = 0
    for _ in pairs(_whitelisted) do n += 1 end
    _wlCountLabel.Text = "Whitelisted: " .. tostring(n) .. " player" .. (n == 1 and "" or "s")
end

local function _wlToggle(plr)
    if plr == Player then return end
    if _whitelisted[plr.UserId] then
        _whitelisted[plr.UserId] = nil
    else
        _whitelisted[plr.UserId] = true
    end
    _wlApplyRowVisual(plr)
    _wlRefreshCount()
end

local function _wlBuildRow(plr, order)
    if _whitelistRows[plr.UserId] then return end

    local row = Instance.new("TextButton")
    row.Name = "WL_" .. plr.UserId
    row.Size = UDim2.new(1, -16, 0, 46)
    row.BackgroundColor3 = _themes[_currTheme].AccentLight
    row.BackgroundTransparency = 0.45
    row.BorderSizePixel = 0
    row.Text = ""
    row.AutoButtonColor = false
    row.LayoutOrder = order or 0
    row.Parent = _wlListFrame
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 10)

    local hl = Instance.new("Frame")
    hl.Name = "_highlight"
    hl.Size = UDim2.fromScale(1, 1)
    hl.BackgroundColor3 = _themes[_currTheme].Accent
    hl.BackgroundTransparency = 0.55
    hl.BorderSizePixel = 0
    hl.Visible = false
    hl.ZIndex = 0
    hl.Parent = row
    Instance.new("UICorner", hl).CornerRadius = UDim.new(0, 10)

    local avatar = Instance.new("ImageLabel")
    avatar.Name = "_avatar"
    avatar.Size = UDim2.fromOffset(34, 34)
    avatar.Position = UDim2.new(0, 8, 0.5, -17)
    avatar.BackgroundTransparency = 1
    avatar.ZIndex = 2
    avatar.Parent = row
    Instance.new("UICorner", avatar).CornerRadius = UDim.new(1, 0)
    task.spawn(function()
        local ok, img = pcall(function()
            return Players:GetUserThumbnailAsync(plr.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
        end)
        if ok and avatar.Parent then avatar.Image = img end
    end)

    local dot = Instance.new("Frame")
    dot.Name = "_dot"
    dot.Size = UDim2.fromOffset(10, 10)
    dot.Position = UDim2.new(0, 48, 0, 12)
    dot.BackgroundColor3 = Color3.fromRGB(180, 180, 190)
    dot.BorderSizePixel = 0
    dot.ZIndex = 2
    dot.Parent = row
    Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)

    local nameLbl = Instance.new("TextLabel")
    nameLbl.Name = "_name"
    nameLbl.Size = UDim2.new(1, -110, 0, 20)
    nameLbl.Position = UDim2.new(0, 62, 0, 5)
    nameLbl.BackgroundTransparency = 1
    nameLbl.Text = plr.DisplayName .. "  (@" .. plr.Name .. ")"
    nameLbl.TextColor3 = _themes[_currTheme].Text
    nameLbl.Font = Enum.Font.GothamBold
    nameLbl.TextSize = 13
    nameLbl.TextXAlignment = Enum.TextXAlignment.Left
    nameLbl.TextTruncate = Enum.TextTruncate.AtEnd
    nameLbl.ZIndex = 2
    nameLbl.Parent = row

    local status = Instance.new("TextLabel")
    status.Name = "_status"
    status.Size = UDim2.new(1, -110, 0, 16)
    status.Position = UDim2.new(0, 62, 0, 25)
    status.BackgroundTransparency = 1
    status.Text = "Not whitelisted"
    status.TextColor3 = _themes[_currTheme].Text
    status.Font = Enum.Font.Gotham
    status.TextSize = 11
    status.TextXAlignment = Enum.TextXAlignment.Left
    status.ZIndex = 2
    status.Parent = row

    row.MouseButton1Click:Connect(function()
        _playClick()
        _wlToggle(plr)
    end)
    row.MouseEnter:Connect(function()
        _playHover()
        TweenService:Create(row, TweenInfo.new(0.12), {BackgroundTransparency = 0.25}):Play()
    end)
    row.MouseLeave:Connect(function()
        TweenService:Create(row, TweenInfo.new(0.12), {BackgroundTransparency = 0.45}):Play()
    end)

    _whitelistRows[plr.UserId] = row
    _wlApplyRowVisual(plr)
end

local function _wlRemoveRow(plr)
    local row = _whitelistRows[plr.UserId]
    if row then
        row:Destroy()
        _whitelistRows[plr.UserId] = nil
    end
    _wlRefreshCount()
end

local function _wlRebuildAll()
    if not _wlListFrame then return end
    for _, row in pairs(_whitelistRows) do
        if row and row.Parent then row:Destroy() end
    end
    _whitelistRows = {}
    local order = 0
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= Player then
            order += 1
            _wlBuildRow(plr, order)
        end
    end
    _wlRefreshCount()
end

Players.PlayerAdded:Connect(function(plr)
    if _wlListFrame then
        task.defer(function()
            _wlBuildRow(plr, 999)
        end)
    end
end)

Players.PlayerRemoving:Connect(function(plr)
    _whitelisted[plr.UserId] = nil
    _wlRemoveRow(plr)
end)

--==================================================
-- BUILD TABS
--==================================================

for _, tabName in ipairs(_tabList) do
    local btn = Instance.new("TextButton")
    btn.Name = tabName .. "_btn"
    btn.Size = UDim2.new(1, 0, 0, 42)
    btn.BackgroundColor3 = _themes.Pink.AccentLight
    btn.BorderSizePixel = 0
    btn.Text = tabName
    btn.TextColor3 = _themes.Pink.Text
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 13
    btn.Parent = _tabHolder

    local bCorner = Instance.new("UICorner")
    bCorner.CornerRadius = UDim.new(0, 9)
    bCorner.Parent = btn
    _buttons[tabName] = btn

    local page = Instance.new("Frame")
    page.Name = tabName .. "_page"
    page.Size = UDim2.fromScale(1, 1)
    page.BackgroundTransparency = 1
    page.Visible = false
    page.Parent = _pageHolder
    _pages[tabName] = page

    local pTitle = Instance.new("TextLabel")
    pTitle.Name = "_pageTitle"
    pTitle.Size = UDim2.new(1, 0, 0, 38)
    pTitle.BackgroundTransparency = 1
    pTitle.Text = tabName
    pTitle.TextColor3 = _themes.Pink.Accent
    pTitle.Font = Enum.Font.FredokaOne
    pTitle.TextSize = 24
    pTitle.TextXAlignment = Enum.TextXAlignment.Left
    pTitle.Parent = page

    if tabName == "Time Changer" then
        local panel = Instance.new("ScrollingFrame")
        panel.Name = "_panel"
        panel.Size = UDim2.new(1, 0, 1, -48)
        panel.Position = UDim2.new(0, 0, 0, 45)
        panel.BackgroundColor3 = _themes.Pink.Panel
        panel.BorderSizePixel = 0
        panel.ScrollBarThickness = 0
        panel.ScrollBarImageColor3 = _themes.Pink.Accent
        panel.AutomaticCanvasSize = Enum.AutomaticSize.Y
        panel.CanvasSize = UDim2.new(0, 0, 0, 0)
        panel.ScrollingDirection = Enum.ScrollingDirection.Y
        panel.Parent = page

        local pCorner = Instance.new("UICorner")
        pCorner.CornerRadius = UDim.new(0, 12)
        pCorner.Parent = panel

        local padding = Instance.new("UIPadding")
        padding.PaddingTop = UDim.new(0, 10)
        padding.PaddingBottom = UDim.new(0, 10)
        padding.PaddingLeft = UDim.new(0, 5)
        padding.PaddingRight = UDim.new(0, 5)
        padding.Parent = panel

        local yOff = 0

        local timeDisplay = Instance.new("TextLabel")
        timeDisplay.Size = UDim2.new(1, 0, 0, 50)
        timeDisplay.Position = UDim2.new(0, 0, 0, yOff)
        timeDisplay.BackgroundTransparency = 1
        timeDisplay.Text = _formatTime(Lighting.ClockTime)
        timeDisplay.TextColor3 = _themes.Pink.Accent
        timeDisplay.TextSize = 40
        timeDisplay.Font = Enum.Font.FredokaOne
        timeDisplay.Parent = panel
        table.insert(_uiElements, {type = "text", label = timeDisplay})
        yOff = yOff + 55

        local sliderRow = Instance.new("Frame")
        sliderRow.Size = UDim2.new(1, -20, 0, 44)
        sliderRow.Position = UDim2.new(0, 10, 0, yOff)
        sliderRow.BackgroundTransparency = 1
        sliderRow.Parent = panel
        yOff = yOff + 48

        local sliderLabel = Instance.new("TextLabel")
        sliderLabel.Size = UDim2.new(0.15, 0, 1, 0)
        sliderLabel.Text = "Time"
        sliderLabel.TextColor3 = _themes.Pink.Text
        sliderLabel.TextSize = 13
        sliderLabel.Font = Enum.Font.GothamBold
        sliderLabel.BackgroundTransparency = 1
        sliderLabel.TextXAlignment = Enum.TextXAlignment.Left
        sliderLabel.Parent = sliderRow

        local valLabel = Instance.new("TextLabel")
        valLabel.Size = UDim2.new(0.1, 0, 1, 0)
        valLabel.Position = UDim2.new(0.9, 0, 0, 0)
        valLabel.Text = string.format("%.1fh", Lighting.ClockTime)
        valLabel.TextColor3 = _themes.Pink.Accent
        valLabel.TextSize = 13
        valLabel.Font = Enum.Font.GothamBold
        valLabel.BackgroundTransparency = 1
        valLabel.TextXAlignment = Enum.TextXAlignment.Right
        valLabel.Parent = sliderRow

        local trackC = Instance.new("Frame")
        trackC.Size = UDim2.new(0.7, 0, 1, 0)
        trackC.Position = UDim2.new(0.17, 0, 0, 0)
        trackC.BackgroundTransparency = 1
        trackC.Parent = sliderRow

        local track = Instance.new("Frame")
        track.Size = UDim2.new(1, 0, 0.3, 0)
        track.Position = UDim2.new(0, 0, 0.5, -0.15)
        track.BackgroundColor3 = Color3.fromRGB(200, 200, 210)
        track.BackgroundTransparency = 0.5
        track.BorderSizePixel = 0
        track.Parent = trackC
        Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

        local fill = Instance.new("Frame")
        local p = Lighting.ClockTime / 24
        fill.Size = UDim2.new(p, 0, 1, 0)
        fill.BackgroundColor3 = _themes.Pink.Accent
        fill.BackgroundTransparency = 0.3
        fill.BorderSizePixel = 0
        fill.Parent = track
        Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

        local thumb = Instance.new("Frame")
        thumb.Size = UDim2.new(0, 18, 0, 18)
        thumb.Position = UDim2.new(p, -9, 0.5, -9)
        thumb.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        thumb.BorderSizePixel = 2
        thumb.BorderColor3 = _themes.Pink.Accent
        thumb.Parent = trackC
        Instance.new("UICorner", thumb).CornerRadius = UDim.new(1, 0)

        table.insert(_uiElements, {
            type = "slider",
            label = sliderLabel,
            valLabel = valLabel,
            fill = fill,
            thumb = thumb
        })

        local conn, dragging
        local function updateTime(input)
            local tPos = track.AbsolutePosition
            local tSize = track.AbsoluteSize
            local pos = input.Position.X - tPos.X
            local perc = math.clamp(pos / tSize.X, 0, 1)
            local value = perc * 24
            value = math.round(value / 0.1) * 0.1
            value = math.max(0, math.min(24, value))
            local np = value / 24
            fill.Size = UDim2.new(np, 0, 1, 0)
            thumb.Position = UDim2.new(np, -9, 0.5, -9)
            valLabel.Text = string.format("%.1fh", value)
            timeDisplay.Text = _formatTime(value)
            _setTime(value)
        end

        thumb.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                if conn then conn:Disconnect() end
                conn = UIS.InputChanged:Connect(function(move)
                    if dragging and move.UserInputType == Enum.UserInputType.MouseMovement then
                        updateTime(move)
                    end
                end)
            end
        end)

        track.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                updateTime(input)
            end
        end)

        UIS.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
                if conn then conn:Disconnect() conn = nil end
            end
        end)

        yOff = yOff + 10

        _makeToggle(panel, yOff, "Override Server Time", _timeOverride, function(v)
            _timeOverride = v
            if v then
                _startTimeOverride()
            else
                _stopTimeOverride()
            end
        end)
        yOff = yOff + 38

        local presetRow = Instance.new("Frame")
        presetRow.Size = UDim2.new(1, -20, 0, 34)
        presetRow.Position = UDim2.new(0, 10, 0, yOff)
        presetRow.BackgroundTransparency = 1
        presetRow.Parent = panel
        yOff = yOff + 38

        local presetLabel = Instance.new("TextLabel")
        presetLabel.Size = UDim2.new(0.25, 0, 1, 0)
        presetLabel.Text = "Presets"
        presetLabel.TextColor3 = _themes.Pink.Text
        presetLabel.TextSize = 13
        presetLabel.Font = Enum.Font.GothamBold
        presetLabel.BackgroundTransparency = 1
        presetLabel.TextXAlignment = Enum.TextXAlignment.Left
        presetLabel.Parent = presetRow
        table.insert(_uiElements, {type = "text", label = presetLabel})

        local presetNames = {"Dawn", "Morning", "Noon", "Sunset", "Night", "Blue"}
        local presetTimes = {5.5, 9, 12, 19, 22, 20.5}

        for i = 1, 6 do
            local pBtn = Instance.new("TextButton")
            pBtn.Size = UDim2.new(0.11, 0, 0, 28)
            pBtn.Position = UDim2.new(0.26 + ((i-1) * 0.12), 0, 0, 0)
            pBtn.BackgroundColor3 = _themes.Pink.AccentLight
            pBtn.BackgroundTransparency = 0.3
            pBtn.BorderSizePixel = 0
            pBtn.Text = presetNames[i]
            pBtn.TextColor3 = _themes.Pink.Text
            pBtn.TextSize = 10
            pBtn.Font = Enum.Font.GothamBold
            pBtn.Parent = presetRow

            local pCorner = Instance.new("UICorner")
            pCorner.CornerRadius = UDim.new(0, 6)
            pCorner.Parent = pBtn

            pBtn.MouseEnter:Connect(function()
                pBtn.BackgroundTransparency = 0
                pBtn.BackgroundColor3 = _themes.Pink.Accent
                pBtn.BackgroundTransparency = 0.2
            end)
            pBtn.MouseLeave:Connect(function()
                pBtn.BackgroundTransparency = 0.3
                pBtn.BackgroundColor3 = _themes.Pink.AccentLight
            end)

            pBtn.MouseButton1Click:Connect(function()
                _playClick()
                _setTime(presetTimes[i])
                timeDisplay.Text = _formatTime(presetTimes[i])
                valLabel.Text = string.format("%.1fh", presetTimes[i])
                local np = presetTimes[i] / 24
                fill.Size = UDim2.new(np, 0, 1, 0)
                thumb.Position = UDim2.new(np, -9, 0.5, -9)
            end)
        end

        yOff = yOff + 44

        local currentTimeLabel = Instance.new("TextLabel")
        currentTimeLabel.Size = UDim2.new(1, -20, 0, 30)
        currentTimeLabel.Position = UDim2.new(0, 10, 0, yOff)
        currentTimeLabel.BackgroundTransparency = 1
        currentTimeLabel.Text = "Current: " .. _formatTime(Lighting.ClockTime)
        currentTimeLabel.TextColor3 = _themes.Pink.Text
        currentTimeLabel.TextSize = 13
        currentTimeLabel.Font = Enum.Font.Gotham
        currentTimeLabel.TextXAlignment = Enum.TextXAlignment.Center
        currentTimeLabel.Parent = panel
        table.insert(_uiElements, {type = "text", label = currentTimeLabel})
        yOff = yOff + 40

        Lighting:GetPropertyChangedSignal("ClockTime"):Connect(function()
            timeDisplay.Text = _formatTime(Lighting.ClockTime)
            currentTimeLabel.Text = "Current: " .. _formatTime(Lighting.ClockTime)
        end)

        panel.CanvasSize = UDim2.new(0, 0, 0, yOff + 20)

    elseif tabName == "Whitelist" then
        local panel = Instance.new("Frame")
        panel.Name = "_panel"
        panel.Size = UDim2.new(1, 0, 1, -48)
        panel.Position = UDim2.new(0, 0, 0, 45)
        panel.BackgroundColor3 = _themes.Pink.Panel
        panel.BorderSizePixel = 0
        panel.Parent = page

        local pCorner = Instance.new("UICorner")
        pCorner.CornerRadius = UDim.new(0, 12)
        pCorner.Parent = panel

        local header = Instance.new("TextLabel")
        header.Name = "_wlHeader"
        header.Size = UDim2.new(1, -20, 0, 26)
        header.Position = UDim2.new(0, 10, 0, 8)
        header.BackgroundTransparency = 1
        header.Text = "Click a player to whitelist / unwhitelist them"
        header.TextColor3 = _themes.Pink.Text
        header.Font = Enum.Font.GothamBold
        header.TextSize = 13
        header.TextXAlignment = Enum.TextXAlignment.Left
        header.Parent = panel
        table.insert(_uiElements, {type = "text", label = header})

        local count = Instance.new("TextLabel")
        count.Name = "_wlCount"
        count.Size = UDim2.new(1, -20, 0, 22)
        count.Position = UDim2.new(0, 10, 0, 32)
        count.BackgroundTransparency = 1
        count.Text = "Whitelisted: 0 players"
        count.TextColor3 = _themes.Pink.Accent
        count.Font = Enum.Font.GothamBold
        count.TextSize = 12
        count.TextXAlignment = Enum.TextXAlignment.Left
        count.Parent = panel
        table.insert(_uiElements, {type = "text", label = count})
        _wlCountLabel = count

        local list = Instance.new("ScrollingFrame")
        list.Name = "_wlList"
        list.Size = UDim2.new(1, -16, 1, -66)
        list.Position = UDim2.new(0, 8, 0, 58)
        list.BackgroundTransparency = 1
        list.BorderSizePixel = 0
        list.ScrollBarThickness = 3
        list.ScrollBarImageColor3 = _themes.Pink.Accent
        list.AutomaticCanvasSize = Enum.AutomaticSize.Y
        list.CanvasSize = UDim2.new(0, 0, 0, 0)
        list.ScrollingDirection = Enum.ScrollingDirection.Y
        list.Parent = panel
        _wlListFrame = list

        local layout = Instance.new("UIListLayout")
        layout.Padding = UDim.new(0, 6)
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Parent = list

        _wlRebuildAll()
        _wlRefreshCount()

    else
        local panel = Instance.new("ScrollingFrame")
        panel.Name = "_panel"
        panel.Size = UDim2.new(1, 0, 1, -48)
        panel.Position = UDim2.new(0, 0, 0, 45)
        panel.BackgroundColor3 = _themes.Pink.Panel
        panel.BorderSizePixel = 0
        panel.ScrollBarThickness = 0
        panel.ScrollBarImageColor3 = _themes.Pink.Accent
        panel.AutomaticCanvasSize = Enum.AutomaticSize.Y
        panel.CanvasSize = UDim2.new(0, 0, 0, 0)
        panel.ScrollingDirection = Enum.ScrollingDirection.Y
        panel.Parent = page

        local pCorner = Instance.new("UICorner")
        pCorner.CornerRadius = UDim.new(0, 12)
        pCorner.Parent = panel

        local padding = Instance.new("UIPadding")
        padding.PaddingTop = UDim.new(0, 10)
        padding.PaddingBottom = UDim.new(0, 10)
        padding.PaddingLeft = UDim.new(0, 5)
        padding.PaddingRight = UDim.new(0, 5)
        padding.Parent = panel

        local yOff = 0

        if tabName == "Silent Aim" then
            _makeToggle(panel, yOff, "Silent Aim", true, function(v) _silent = v end)
            yOff = yOff + 38
            _makeToggle(panel, yOff, "Exclude Revolver", false, function(v) _exclude = v end)
            yOff = yOff + 38
            _makeToggle(panel, yOff, "Wall Check", false, function(v) _wall = v end)
            yOff = yOff + 38
            _makeToggle(panel, yOff, "Knock Check", false, function(v) _knock = v end)
            yOff = yOff + 40
            _makeSlider(panel, yOff, "FOV Radius", 100, 0, 1000, 1, function(v) _fov = v end)
            yOff = yOff + 38
            _makeSlider(panel, yOff, "Bullet Spread", 100, 0, 100, 1, function(v) _spread = v end)
            yOff = yOff + 40
            _makeDropdown(panel, yOff, "Aim Part", {"Head","Body","Left Leg","Right Leg","Left Arm","Right Arm","Closest Part"}, 1, function(i,v) _aimPart = v end)
            yOff = yOff + 40
            panel.CanvasSize = UDim2.new(0, 0, 0, yOff + 20)

        elseif tabName == "Fog" then
            local colors = {"Pink","Purple","Yellow","Green","Blue","Orange"}
            _makeDropdown(panel, yOff, "Fog Color", colors, 1, function(i,n)
                local map = {
                    Pink = Color3.fromRGB(255, 200, 220),
                    Purple = Color3.fromRGB(200, 180, 240),
                    Yellow = Color3.fromRGB(255, 240, 180),
                    Green = Color3.fromRGB(180, 240, 200),
                    Blue = Color3.fromRGB(180, 220, 255),
                    Orange = Color3.fromRGB(255, 210, 180)
                }
                _fogColor = map[n] or Color3.fromRGB(200, 195, 215)
                Lighting.FogColor = _fogColor
                if Lighting:FindFirstChild("Atmosphere") then
                    Lighting.Atmosphere.FogColor = _fogColor
                end
            end)
            yOff = yOff + 40

            local hexRow = Instance.new("Frame")
            hexRow.Size = UDim2.new(1, -20, 0, 34)
            hexRow.Position = UDim2.new(0, 10, 0, yOff)
            hexRow.BackgroundTransparency = 1
            hexRow.Parent = panel

            local hexLabel = Instance.new("TextLabel")
            hexLabel.Size = UDim2.new(0.25, 0, 1, 0)
            hexLabel.Text = "Hex Color"
            hexLabel.TextColor3 = _themes[_currTheme].Text
            hexLabel.TextSize = 13
            hexLabel.Font = Enum.Font.GothamBold
            hexLabel.BackgroundTransparency = 1
            hexLabel.TextXAlignment = Enum.TextXAlignment.Left
            hexLabel.Parent = hexRow

            local hexBox = Instance.new("TextBox")
            hexBox.Size = UDim2.new(0, 160, 0, 30)
            hexBox.Position = UDim2.new(1, -170, 0.5, -15)
            hexBox.BackgroundColor3 = _themes[_currTheme].AccentLight
            hexBox.BackgroundTransparency = 0.4
            hexBox.Text = "#C8C3D7"
            hexBox.TextColor3 = _themes[_currTheme].Text
            hexBox.Font = Enum.Font.Gotham
            hexBox.TextSize = 12
            hexBox.Parent = hexRow
            Instance.new("UICorner", hexBox).CornerRadius = UDim.new(0, 6)

            hexBox.FocusLost:Connect(function()
                local hex = hexBox.Text:gsub("#", "")
                if #hex == 6 and hex:match("^[%x]+$") then
                    local r = tonumber(hex:sub(1,2), 16)
                    local g = tonumber(hex:sub(3,4), 16)
                    local b = tonumber(hex:sub(5,6), 16)
                    _fogColor = Color3.fromRGB(r,g,b)
                    Lighting.FogColor = _fogColor
                    if Lighting:FindFirstChild("Atmosphere") then
                        Lighting.Atmosphere.FogColor = _fogColor
                    end
                end
            end)

            table.insert(_uiElements, {
                type = "text",
                label = hexLabel
            })

            yOff = yOff + 40
            _makeSlider(panel, yOff, "Fog Intensity", 50, 0, 2000, 1, function(v)
                _fogIntensity = v
                Lighting.FogEnd = v
                Lighting.FogStart = math.round(v * 0.1)
            end)
            yOff = yOff + 44
            local reset = Instance.new("TextButton")
            reset.Size = UDim2.new(0.5, 0, 0, 32)
            reset.Position = UDim2.new(0.25, 0, 0, yOff)
            reset.BackgroundColor3 = _themes.Pink.AccentLight
            reset.BackgroundTransparency = 0.4
            reset.Text = "Reset Fog"
            reset.TextColor3 = _themes.Pink.Text
            reset.Font = Enum.Font.GothamBold
            reset.TextSize = 13
            reset.Parent = panel
            Instance.new("UICorner", reset).CornerRadius = UDim.new(0, 6)
            reset.MouseButton1Click:Connect(function()
                _fogColor = Color3.fromRGB(200, 195, 215)
                Lighting.FogColor = _fogColor
                if Lighting:FindFirstChild("Atmosphere") then
                    Lighting.Atmosphere.FogColor = _fogColor
                end
                Lighting.FogEnd = 500
                Lighting.FogStart = 50
                _fogIntensity = 500
                hexBox.Text = "#C8C3D7"
            end)
            yOff = yOff + 42
            panel.CanvasSize = UDim2.new(0, 0, 0, yOff + 20)

        elseif tabName == "Hitbox" then
            _makeToggle(panel, yOff, "Hitbox Expander", false, function(v) _hitbox = v end)
            yOff = yOff + 38
            _makeSlider(panel, yOff, "Head Size", 1, 0.01, 30, 0.01, function(v) _headSize = v end)
            yOff = yOff + 38
            _makeSlider(panel, yOff, "Transparency", 0.7, 0, 1, 0.01, function(v) _hitTrans = v end)
            yOff = yOff + 40
            _makeDropdown(panel, yOff, "Visual Color", {"Pink","Purple","Yellow","Green","Blue","Orange"}, 2, function(i,n)
                local map = {
                    Pink = Color3.fromRGB(255, 130, 180),
                    Purple = Color3.fromRGB(145, 100, 220),
                    Yellow = Color3.fromRGB(235, 175, 45),
                    Green = Color3.fromRGB(75, 175, 105),
                    Blue = Color3.fromRGB(70, 145, 220),
                    Orange = Color3.fromRGB(235, 120, 50)
                }
                _hitColor = map[n] or Color3.fromRGB(145, 100, 220)
            end)
            yOff = yOff + 40
            panel.CanvasSize = UDim2.new(0, 0, 0, yOff + 20)

        elseif tabName == "Avatar" then
            _makeToggle(panel, yOff, "Headless", false, function(v)
                _headless = v
                if Player and Player.Character then
                    local head = Player.Character:FindFirstChild("Head")
                    local face = Player.Character:FindFirstChild("Face")
                    if head then head.Transparency = v and 1 or 0 end
                    if face then face.Transparency = v and 1 or 0 end
                end
            end)
            yOff = yOff + 40
            _makeToggle(panel, yOff, "Korblox (Left Leg)", false, function(v) _korblox = v end)
            yOff = yOff + 40
            panel.CanvasSize = UDim2.new(0, 0, 0, yOff + 20)

        elseif tabName == "Settings" then
            _makeKeybind(panel, yOff, "Menu Toggle", _menuKey, function(v)
                _menuKey = v
            end)
            yOff = yOff + 44

            local kill = Instance.new("TextButton")
            kill.Name = "_kill"
            kill.Size = UDim2.new(0.6, 0, 0, 48)
            kill.Position = UDim2.new(0.2, 0, 0, yOff)
            kill.BackgroundColor3 = _themes.Pink.Accent
            kill.BackgroundTransparency = 0.15
            kill.Text = "KILL SWITCH"
            kill.TextColor3 = Color3.fromRGB(255, 255, 255)
            kill.Font = Enum.Font.GothamBold
            kill.TextSize = 18
            kill.Parent = panel

            local kCorner = Instance.new("UICorner")
            kCorner.CornerRadius = UDim.new(0, 12)
            kCorner.Parent = kill

            local kStroke = Instance.new("UIStroke")
            kStroke.Name = "_stroke"
            kStroke.Color = _themes.Pink.Accent:Lerp(Color3.fromRGB(255, 255, 255), 0.3)
            kStroke.Thickness = 2
            kStroke.Transparency = 0.5
            kStroke.Parent = kill

            _killBtn = kill

            kill.MouseButton1Click:Connect(function()
                _playClick()
                _kill()
            end)

            kill.MouseEnter:Connect(function()
                TweenService:Create(kill, TweenInfo.new(0.15), {BackgroundTransparency = 0.05}):Play()
                TweenService:Create(kStroke, TweenInfo.new(0.15), {Transparency = 0.1}):Play()
            end)
            kill.MouseLeave:Connect(function()
                TweenService:Create(kill, TweenInfo.new(0.15), {BackgroundTransparency = 0.15}):Play()
                TweenService:Create(kStroke, TweenInfo.new(0.15), {Transparency = 0.5}):Play()
            end)

            yOff = yOff + 58

            local info = Instance.new("TextLabel")
            info.Size = UDim2.new(0.9, 0, 0, 30)
            info.Position = UDim2.new(0.05, 0, 0, yOff)
            info.BackgroundTransparency = 1
            info.Text = "Completely uninjects and restores defaults."
            info.TextColor3 = _themes.Pink.Text
            info.Font = Enum.Font.Gotham
            info.TextSize = 12
            info.TextWrapped = true
            info.TextXAlignment = Enum.TextXAlignment.Center
            info.Parent = panel
            table.insert(_uiElements, {type = "text", label = info})

            yOff = yOff + 40
            panel.CanvasSize = UDim2.new(0, 0, 0, yOff + 20)
        end
    end

    btn.MouseEnter:Connect(function()
        _playHover()
    end)

    btn.MouseButton1Click:Connect(function()
        _playClick()
        _showPage(tabName)
    end)
end

--==================================================
-- RUN LOOPS
--==================================================

RunService.RenderStepped:Connect(function()
    if _hitbox then
        for _, v in pairs(Players:GetPlayers()) do
            if v ~= Player and v.Character then
                pcall(function()
                    local root = v.Character:FindFirstChild("HumanoidRootPart")
                    if root then
                        root.Size = Vector3.new(_headSize, _headSize, _headSize)
                        root.Transparency = _hitTrans
                        root.BrickColor = BrickColor.new(_hitColor)
                        root.Material = "Neon"
                        root.CanCollide = false
                    end
                end)
            end
        end
    end
end)

RunService.RenderStepped:Connect(function()
    if Player and Player.Character then
        local char = Player.Character
        local lul = char:FindFirstChild("LeftUpperLeg")
        local lll = char:FindFirstChild("LeftLowerLeg")
        local lf = char:FindFirstChild("LeftFoot")

        if _korblox then
            if lul then lul.Transparency = 1 end
            if lll then lll.Transparency = 1 end
            if lf then lf.Transparency = 1 end
        else
            if lul then lul.Transparency = 0 end
            if lll then lll.Transparency = 0 end
            if lf then lf.Transparency = 0 end
        end
    end
end)

mouse.Button1Down:Connect(function()
    -- teleport removed
end)

UIS.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.UserInputType == Enum.UserInputType.Keyboard then
        local key = input.KeyCode.Name

        if key == _menuKey then
            _main.Visible = not _main.Visible
            _uiVisible = _main.Visible
            return
        end
    end
end)

Player.CharacterAdded:Connect(function(char)
    task.wait(0.5)
    if _headless then
        local head = char:FindFirstChild("Head")
        local face = char:FindFirstChild("Face")
        if head then head.Transparency = 1 end
        if face then face.Transparency = 1 end
    end
end)

local _origRandom
local _n1=100; local _n8=1; local _n9=0; local _n11=2
local _n14=0.05; local _n15=-0.1; local _n16=-0.05

pcall(function()
    _origRandom = hookfunction(math.random, function(...)
        local a = {...}
        if checkcaller() then return _origRandom(...) end
        if (#a==_n9) or (a[_n8]==_n16 and a[_n11]==_n14)
            or (a[_n8]==_n15) or (a[_n8]==_n16) then
            if _spread then
                return _origRandom(...) * (_spread / _n1)
            end
        end
        return _origRandom(...)
    end)
end)

--==================================================
-- DRAGGING
--==================================================

_showPage("Settings")

local _dragging = false
local _dragStart, _startPos

_dragBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        _dragging = true
        _dragStart = input.Position
        _startPos = _main.Position
    end
end)

UIS.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement and _dragging then
        local delta = input.Position - _dragStart
        _main.Position = UDim2.new(
            _startPos.X.Scale, _startPos.X.Offset + delta.X,
            _startPos.Y.Scale, _startPos.Y.Offset + delta.Y
        )
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        _dragging = false
    end
end)

StarterGui:SetCore("SendNotification", {
    Title = "mels main",
    Text = "Camlock, Misc, Theme, Skin Changer & Teleport removed.",
    Duration = 3
})

print("")
print("═══════════════════════════════════════════")
print("  ✨ MELS MAIN - WHITELIST EDITION")
print("═══════════════════════════════════════════")
print("  ❌ Camlock tab removed")
print("  ❌ Misc tab removed")
print("  ❌ Theme tab removed")
print("  ❌ Skin Changer tab + all skin code removed")
print("  ❌ Teleport tab removed")
print("  ✅ Whitelist tab intact")
print("  ✅ Silent Aim skips whitelisted players")
print("═══════════════════════════════════════════")
