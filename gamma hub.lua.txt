local function _try(fn, ...) local ok, err = pcall(fn, ...); return ok, err end

_try(function() if setthreadidentity then setthreadidentity(8) end end)
_try(function() if setidentity then setidentity(8) end end)
_try(function() if set_thread_identity then set_thread_identity(8) end end)
_try(function() if syn and syn.set_thread_identity then syn.set_thread_identity(8) end end)
_try(function() if secure_call then end end)
_try(function() if setthreadcontext then setthreadcontext(8) end end)
_try(function() if setcontext then setcontext(8) end end)
_try(function() if set_thread_capability then set_thread_capability("Plugin") end end)
_try(function() if setthreadcapability then setthreadcapability("Plugin") end end)

if type(cloneref) ~= "function" then
    local _cr = rawget(getfenv(), "cloneref")
        or rawget(getfenv(), "clonereference")
        or (syn and syn.cloneref)
        or (getrenv and getrenv().cloneref)
    if type(_cr) == "function" then
        cloneref = _cr
    else
        cloneref = function(o) return o end
    end
end

do
    local _origGetService = game.GetService
    local _safeGetService = function(self, name)
        local ok, svc = pcall(_origGetService, self, name)
        if ok then return svc end

        task.wait()
        return _origGetService(self, name)
    end

    _G.__SafeGetService = _safeGetService
end

-- Inject immediately regardless of game load state.
pcall(function() if type(setfpscap) == "function" then setfpscap(9999) end end)
local _cloneref_safe = (type(cloneref) == "function") and cloneref or function(o) return o end
Services = setmetatable({}, {
	__index = function(self, name)
		local success, cache = pcall(function()
			return _cloneref_safe(game:GetService(name))
		end)
		if success then
			rawset(self, name, cache)
			return cache
		else
			error("Invalid Service: " .. tostring(name))
		end
	end
})

task.spawn(function()
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")
local Players          = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LPH_NO_VIRTUALIZE = function(f) return f end

-- Force-load: do not wait for game:IsLoaded(). Proceed immediately.

if not Players.LocalPlayer then
    local _t1 = tick()
    repeat task.wait(0.05) until Players.LocalPlayer or (tick() - _t1 > 5)
end
do
    local lp = Players.LocalPlayer
    if lp and not lp:FindFirstChildOfClass("PlayerGui") then
        lp:WaitForChild("PlayerGui", 5)
    end
end

if not _G._FH_NET then
    _G._FH_NET = {}
    task.spawn(function()
        local ok0, _ = pcall(function()
            local cloneref       = cloneref or function(o) return o end
            local RS             = cloneref(game:GetService("ReplicatedStorage"))
            local getconstants   = (debug and debug.getconstants) or getconstants

            local ok1, netFolder = pcall(function()
                return RS:WaitForChild("Packages", 20):WaitForChild("Net", 20)
            end)
            if not ok1 or not netFolder then return end

            pcall(function()
                if not (getconnections and getconstants) then return end
                for _, r in ipairs(netFolder:GetChildren()) do
                    if r:IsA("RemoteEvent") then
                        local okC, conns = pcall(getconnections, r.OnClientEvent)
                        if okC then
                            for _, c in ipairs(conns) do
                                if type(c.Function) == "function" then
                                    local okK, consts = pcall(getconstants, c.Function)
                                    if okK and consts then
                                        for _, k in ipairs(consts) do
                                            if k == "PaintballHitted" then _G._FH_NET.UseItem = r; break end
                                        end
                                    end
                                end
                                if _G._FH_NET.UseItem then break end
                            end
                        end
                    end
                    if _G._FH_NET.UseItem then break end
                end
            end)

        end)
    end)
end
_G._FH_GAMMA_GEN = (_G._FH_GAMMA_GEN or 0) + 1
local _GEN = _G._FH_GAMMA_GEN
_G._FH_SHUTDOWN = false
_G._FH_SHUTDOWN_DONE = false
local function _isShuttingDown()
    if _G._FH_SHUTDOWN then return true end
    if _GEN ~= _G._FH_GAMMA_GEN then return true end
    local lp = Players.LocalPlayer
    if not lp or lp.Parent == nil then return true end
    return false
end
_G._FH_IS_SHUTDOWN = _isShuttingDown
_G._FH_TEARDOWN = {}
local function _doTeardown()
    if _G._FH_SHUTDOWN_DONE then return end
    _G._FH_SHUTDOWN_DONE = true
    _G._FH_SHUTDOWN = true
    for _, fn in ipairs(_G._FH_TEARDOWN) do pcall(fn) end
end
pcall(function()
    local lp = Players.LocalPlayer
    if lp then
        lp.AncestryChanged:Connect(function(_, parent)
            if parent == nil then _doTeardown() end
        end)
    end
end)
pcall(function()
    Players.PlayerRemoving:Connect(function(p)
        if p == Players.LocalPlayer then _doTeardown() end
    end)
end)
pcall(function()
    game:BindToClose(function() _doTeardown() end)
end)
pcall(function()
    local gs = game:GetService("GuiService")
    if gs and gs.MenuOpened then

    end
end)
pcall(function()
    local seen = {}
    local function purge(parent)
        if not parent or seen[parent] then return end
        seen[parent] = true
        for _, ch in ipairs(parent:GetChildren()) do
            if ch:IsA("ScreenGui") and ch.Name == "GammaHub" then
                pcall(function() ch:Destroy() end)
            end
        end
    end
    if typeof(gethui) == "function" then pcall(function() purge(gethui()) end) end
    pcall(function() purge(game:GetService("CoreGui")) end)
    local lp = Players.LocalPlayer
    if lp then pcall(function() purge(lp:FindFirstChildOfClass("PlayerGui")) end) end
    if _G._FH_GAMMA_GUI then pcall(function() _G._FH_GAMMA_GUI:Destroy() end) end
end)
_G._FH_GAMMA_GUI = nil

local _deepStack  = {}
local function _deepChildren(root)
    local result = {}
    local stack  = _deepStack
    local ri, si = 0, 1
    stack[1] = root
    while si > 0 do
        local cur = stack[si]; stack[si] = nil; si = si - 1
        local ch = cur:GetChildren()
        for i = 1, #ch do
            local c = ch[i]
            ri = ri + 1; result[ri] = c
            si = si + 1; stack[si]  = c
        end
    end
    return result, ri
end
local T = {
    Bg          = Color3.fromRGB(10,  10,  15),
    BgDeep      = Color3.fromRGB(6,   6,   10),
    Side        = Color3.fromRGB(14,  14,  20),
    SideHover   = Color3.fromRGB(22,  22,  32),
    SideActive  = Color3.fromRGB(22,  22,  32),
    Card        = Color3.fromRGB(18,  18,  26),
    CardHover   = Color3.fromRGB(24,  24,  34),
    Line        = Color3.fromRGB(32,  32,  48),
    Soft        = Color3.fromRGB(22,  22,  34),
    Text        = Color3.fromRGB(235, 235, 245),
    TextDim     = Color3.fromRGB(120, 120, 145),
    TextMute    = Color3.fromRGB(75,  78,  100),
    Primary     = Color3.fromRGB(109, 40,  217),
    White       = Color3.fromRGB(255, 255, 255),
    Green       = Color3.fromRGB(34,  197, 94),
}
local F  = TweenInfo.new(0.12, Enum.EasingStyle.Quad)
local M  = TweenInfo.new(0.2,  Enum.EasingStyle.Quad)
local PG = TweenInfo.new(0.18, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
local Theme = {
    c1 = Color3.fromRGB(109, 40, 217),
    c2 = Color3.fromRGB(50,  20, 100),
}
local ThemeGrads  = {}
local ThemeSolids   = {}
local ThemeBgFrames = {}

local function trackBgFrame(frame, role)
    table.insert(ThemeBgFrames, {frame = frame, role = role})
end

local function RepaintBgs()
    for _, e in ipairs(ThemeBgFrames) do
        if e.frame and e.frame.Parent then
            pcall(function() e.frame.BackgroundColor3 = T[e.role] end)
        end
    end
end

local function SetGuiColor(col)
    local _h, _s, _v = Color3.toHSV(col)
    T.Bg         = Color3.fromHSV(_h, _s,           _v)
    T.BgDeep     = Color3.fromHSV(_h, _s,           math.max(_v * 0.65, 0))
    T.Side       = Color3.fromHSV(_h, _s * 0.9,     math.min(_v * 1.35, 1))
    T.SideHover  = Color3.fromHSV(_h, _s * 0.75,    math.min(_v * 1.90, 1))
    T.SideActive = Color3.fromHSV(_h, _s * 0.75,    math.min(_v * 1.90, 1))
    T.Card       = Color3.fromHSV(_h, _s * 0.85,    math.min(_v * 1.60, 1))
    T.CardHover  = Color3.fromHSV(_h, _s * 0.75,    math.min(_v * 2.00, 1))
    T.Line       = Color3.fromHSV(_h, _s * 0.55,    math.min(_v * 2.80, 0.45))
    T.Soft       = Color3.fromHSV(_h, _s * 0.80,    math.min(_v * 1.70, 1))
    RepaintBgs()
end
local function themeSeq()
    local _h, _s, _v = Color3.toHSV(Theme.c1)
    local _dark = Color3.fromHSV(_h, _s * 0.55, math.max(_v * 0.30, 0))
    return ColorSequence.new({
        ColorSequenceKeypoint.new(0,    Theme.c1),
        ColorSequenceKeypoint.new(0.5,  _dark),
        ColorSequenceKeypoint.new(1,    Theme.c1),
    })
end
local function trackSolid(frame, slot)
    table.insert(ThemeSolids, {frame = frame, slot = slot})
    frame.BackgroundColor3 = (slot == 1) and Theme.c1 or Theme.c2
end
local function Tween(o, i, p) TweenService:Create(o, i, p):Play() end
local function Corner(p, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 6)
    c.Parent = p
    return c
end
local function Stroke(p, col, th, trans)
    local s = Instance.new("UIStroke")
    s.Color           = col or T.Line
    s.Thickness       = th or 1
    s.Transparency    = trans or 0
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent          = p
    return s
end
local function Pad(p, t, b, l, r)
    local u = Instance.new("UIPadding")
    u.PaddingTop    = UDim.new(0, t or 0)
    u.PaddingBottom = UDim.new(0, b or 0)
    u.PaddingLeft   = UDim.new(0, l or 0)
    u.PaddingRight  = UDim.new(0, r or 0)
    u.Parent = p
end
local function Grad(p, _c1, _c2, rot)
    local g = Instance.new("UIGradient")
    g.Color    = themeSeq()
    g.Rotation = rot or 0
    g.Parent   = p
    table.insert(ThemeGrads, {grad = g, baseRot = rot or 0, speed = 1})
    return g
end
local function GradTint(p, alpha, rot)
    local g = Instance.new("UIGradient")
    g.Color = themeSeq()
    g.Transparency = NumberSequence.new(alpha or 0.7)
    g.Rotation = rot or 0
    g.Parent = p
    table.insert(ThemeGrads, {grad = g, baseRot = rot or 0, speed = 1})
    return g
end
local function GradStroke(p, th, trans, rot)
    local s = Stroke(p, Theme.c1, th or 1, trans or 0.4)
    local g = Instance.new("UIGradient")
    g.Color    = themeSeq()
    g.Rotation = rot or 0
    g.Parent   = s
    table.insert(ThemeGrads, {grad = g, baseRot = rot or 0, speed = 1})
    return s
end
local function Repaint()
    local seq = themeSeq()
    for _, e in ipairs(ThemeGrads) do e.grad.Color = seq end
    for _, e in ipairs(ThemeSolids) do
        e.frame.BackgroundColor3 = (e.slot == 1) and Theme.c1 or Theme.c2
    end
end
local _gradPhase       = 0
local _gradAccum       = 0
local _GRAD_TICK       = 1/15
local _sharedFps       = 0
local _sharedFc        = 0
local _sharedFt        = 0
local _bannerStatsRef  = nil
local _bannerLast      = ""
local _sharedFlowPhase = 0
local _sharedFlowSeq   = nil
local function _computeFlowSeq(phase)
    local kp, n, freq = {}, 12, 1.6
    for i = 0, n do
        local x = i / n
        local a = (math.cos((x * freq - phase) * math.pi * 2) + 1) / 2
        kp[#kp + 1] = ColorSequenceKeypoint.new(x, Theme.c1:Lerp(Theme.c2, a))
    end
    return ColorSequence.new(kp)
end
local function Lbl(p, txt, sz, col, font, align)
    local l = Instance.new("TextLabel")
    l.Text                   = txt or ""
    l.TextSize               = sz or 12
    l.TextColor3             = col or T.Text
    l.Font                   = font or Enum.Font.Gotham
    l.BackgroundTransparency = 1
    l.TextXAlignment         = align or Enum.TextXAlignment.Left
    l.Parent                 = p
    return l
end
local GUI = Instance.new("ScreenGui")
GUI.Name           = "GammaHub"
GUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
GUI.ResetOnSpawn   = false
GUI.IgnoreGuiInset = true
GUI.Enabled        = true
GUI.DisplayOrder   = 999999
do
    local parented = false
    local function tryParent(p)
        if parented or not p then return end
        local ok = pcall(function() GUI.Parent = p end)
        if ok and GUI.Parent == p then parented = true end
    end
    local _exec = ""
    pcall(function() if type(identifyexecutor) == "function" then _exec = (identifyexecutor() or ""):lower() end end)
    local _isMaddium = _exec:find("maddium") ~= nil

    if _isMaddium then
        pcall(function()
            local lp = Players.LocalPlayer or Players.PlayerAdded:Wait()
            local pg = lp:FindFirstChildOfClass("PlayerGui") or lp:WaitForChild("PlayerGui", 10)
            tryParent(pg)
        end)
    end
    if not parented then
        pcall(function()
            if type(gethui) == "function" then tryParent(gethui()) end
        end)
    end
    pcall(function()
        if     type(protect_gui) == "function" then protect_gui(GUI)
        elseif syn and syn.protect_gui         then syn.protect_gui(GUI) end
    end)
    if not parented then
        pcall(function()
            local _cr = (type(cloneref) == "function") and cloneref or function(x) return x end
            tryParent(_cr(game:GetService("CoreGui")))
        end)
    end
    if not parented then
        local lp = Players.LocalPlayer or Players.PlayerAdded:Wait()
        local pg = lp:FindFirstChildOfClass("PlayerGui") or lp:WaitForChild("PlayerGui", 10)
        tryParent(pg)
    end
    GUI.AncestryChanged:Connect(function()
        if GUI.Parent ~= nil then return end
        parented = false
        task.defer(function()
            pcall(function() if typeof(gethui) == "function" then tryParent(gethui()) end end)
            if not parented then
                pcall(function()
                    local _cr = typeof(cloneref) == "function" and cloneref or function(x) return x end
                    tryParent(_cr(game:GetService("CoreGui")))
                end)
            end
            if not parented then
                local lp2 = Players.LocalPlayer
                if lp2 then
                    local pg2 = lp2:FindFirstChildOfClass("PlayerGui")
                    if pg2 then tryParent(pg2) end
                end
            end
        end)
    end)
end
_G._FH_GAMMA_GUI = GUI
do
    local _espGui = Instance.new("ScreenGui")
    _espGui.Name           = "GammaHub_ESP"
    _espGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    _espGui.ResetOnSpawn   = false
    _espGui.IgnoreGuiInset = true
    _espGui.Enabled        = true
    _espGui.DisplayOrder   = 999998
    local _parented = false
    local function _tryP(p)
        if _parented or not p then return end
        local ok = pcall(function() _espGui.Parent = p end)
        if ok and _espGui.Parent == p then _parented = true end
    end
    pcall(function() if typeof(gethui) == "function" then _tryP(gethui()) end end)
    pcall(function()
        if typeof(protect_gui) == "function" then protect_gui(_espGui)
        elseif syn and syn.protect_gui then syn.protect_gui(_espGui) end
    end)
    if not _parented then
        pcall(function()
            local _cr = typeof(cloneref) == "function" and cloneref or function(x) return x end
            _tryP(_cr(game:GetService("CoreGui")))
        end)
    end
    if not _parented then
        local lp = Players.LocalPlayer or Players.PlayerAdded:Wait()
        local pg = lp:FindFirstChildOfClass("PlayerGui") or lp:WaitForChild("PlayerGui", 10)
        _tryP(pg)
    end
    _G._FH_ESP_GUI = _espGui
end

local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
local isPhone = false
if isMobile then
    local _vp = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(800, 600)
    local _short = math.min(_vp.X, _vp.Y)
    isPhone = _short < 600
end
local isTablet = isMobile and not isPhone

local _UI = { userPct = 100, desiredScale = 1 }
local _gScaleList = {}
local function _newScale(frame, factor)
    local f = factor or 1
    local sc = Instance.new("UIScale")
    sc.Scale = (_UI.desiredScale or 1) * f
    sc.Parent = frame
    table.insert(_gScaleList, {sc = sc, f = f})
    return sc
end

if not isMobile then
(function()
    local vp = (workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize) or Vector2.new(800, 600)
    if vp.X < 100 then vp = Vector2.new(800, 600) end
    local INFO_W = isMobile and math.min(math.floor(vp.X * 0.68), 270) or 460
    local INFO_H = isMobile and 38 or 62
    local ACCENT = Color3.fromRGB(168, 110, 255)
    local AMBER  = Color3.fromRGB(255, 200, 80)
    local RED    = Color3.fromRGB(255, 90, 90)
    local GREENP = Color3.fromRGB(120, 255, 160)
    local D1   = isMobile and math.floor(INFO_W * 0.13) or 60
    local D2   = isMobile and math.floor(INFO_W * 0.58) or 270
    local D3   = isMobile and math.floor(INFO_W * 0.81) or 368
    local LOGO = isMobile and math.floor(INFO_W * 0.02) or 8
    local HUB  = isMobile and math.floor(INFO_W * 0.16) or 68
    local STAT = isMobile and math.floor(INFO_W * 0.84) or 376
    local FPSX = isMobile and math.floor(INFO_W * 0.61) or 278
    local MED  = isMobile and 9 or 12

    local banner = Instance.new("Frame")
    banner.Name                   = "GammaHubBanner"
    banner.AnchorPoint            = Vector2.new(0.5, 0)
    banner.Size                   = UDim2.new(0, INFO_W, 0, INFO_H)
    banner.Position               = UDim2.new(0.5, 0, 0, -(INFO_H + 30))
    banner.BackgroundColor3       = Color3.fromRGB(10, 10, 12)
    banner.BackgroundTransparency = 0.08
    banner.BorderSizePixel        = 0
    banner.ZIndex                 = 100000
    banner.Active                 = false
    banner.Parent                 = GUI
    _newScale(banner)
    Corner(banner, 14)
    GradStroke(banner, isMobile and 1.2 or 1.6, 0, 90)

    local logoSize = isMobile and 22 or 44
    local LogoBox = Instance.new("Frame")
    LogoBox.Size             = UDim2.new(0, logoSize, 0, logoSize)
    LogoBox.Position         = UDim2.new(0, LOGO + 4, 0.5, -logoSize / 2)
    LogoBox.BorderSizePixel  = 0
    LogoBox.ZIndex           = 100001
    LogoBox.Parent           = banner
    Corner(LogoBox, isMobile and 7 or 10)
    Stroke(LogoBox, ACCENT, 0.8, 0.25)
    trackSolid(LogoBox, 1)
    local bnLogoLetter = Lbl(LogoBox, "G", isMobile and 15 or 24, T.White, Enum.Font.GothamBlack, Enum.TextXAlignment.Center)
    bnLogoLetter.Size           = UDim2.new(1, 0, 1, 0)
    bnLogoLetter.TextYAlignment = Enum.TextYAlignment.Center
    bnLogoLetter.ZIndex         = 100002
    Grad(bnLogoLetter, nil, nil, 115)
    GradStroke(bnLogoLetter, isMobile and 1 or 1.4, 0.15, 115)
    local function bnPaintLogoLetter()
        local c = LogoBox.BackgroundColor3
        local lum = 0.299 * c.R + 0.587 * c.G + 0.114 * c.B
        bnLogoLetter.TextColor3 = (lum > 0.6) and Color3.fromRGB(0, 0, 0) or Color3.fromRGB(255, 255, 255)
    end
    bnPaintLogoLetter()
    LogoBox:GetPropertyChangedSignal("BackgroundColor3"):Connect(bnPaintLogoLetter)

    local function bnDivider(x)
        local d = Instance.new("Frame")
        d.Size             = UDim2.new(0, 1, 0, isMobile and 28 or 36)
        d.Position         = UDim2.new(0, x, 0.5, isMobile and -14 or -18)
        d.BackgroundColor3 = Color3.fromRGB(58, 42, 92)
        d.BorderSizePixel  = 0
        d.ZIndex           = 100001
        d.Parent           = banner
    end
    bnDivider(D1) bnDivider(D2) bnDivider(D3)

    local HubLabel = Lbl(banner, "Gamma Hub", isMobile and 9 or 13, T.White, Enum.Font.GothamBold)
    HubLabel.Size           = UDim2.new(0, D2 - HUB - 8, 0.55, 0)
    HubLabel.Position       = UDim2.new(0, HUB + 4, 0, isMobile and 1 or 4)
    HubLabel.TextYAlignment = Enum.TextYAlignment.Center
    HubLabel.TextTruncate   = Enum.TextTruncate.AtEnd
    HubLabel.ZIndex         = 100001
    local DevLabel = Lbl(banner, isMobile and "@avidevvv & @sheeshfn" or "Credits: @avidevvv & @sheeshfn", isMobile and 8 or 11, Color3.fromRGB(225, 215, 245), Enum.Font.GothamBold)
    DevLabel.Size           = UDim2.new(0, D2 - HUB - 8, 0.4, 0)
    DevLabel.Position       = UDim2.new(0, HUB + 4, 0.52, 0)
    DevLabel.TextYAlignment = Enum.TextYAlignment.Center
    DevLabel.TextTruncate   = Enum.TextTruncate.AtEnd
    DevLabel.ZIndex         = 100001

    local FPSLabel = Lbl(banner, "FPS: --", MED, ACCENT, Enum.Font.GothamBold)
    FPSLabel.Size           = UDim2.new(0, D3 - FPSX - 4, 0.5, 0)
    FPSLabel.Position       = UDim2.new(0, FPSX + 4, 0, isMobile and 2 or 4)
    FPSLabel.TextYAlignment = Enum.TextYAlignment.Center
    FPSLabel.ZIndex         = 100001
    local PINGLabel = Lbl(banner, "PING: --ms", MED, GREENP, Enum.Font.GothamBold)
    PINGLabel.Size           = UDim2.new(0, D3 - FPSX - 4, 0.5, 0)
    PINGLabel.Position       = UDim2.new(0, FPSX + 4, 0.5, isMobile and -2 or -4)
    PINGLabel.TextYAlignment = Enum.TextYAlignment.Center
    PINGLabel.ZIndex         = 100001

    local badgeW = isMobile and 34 or 72
    local StatusBadge = Instance.new("Frame")
    StatusBadge.Size             = UDim2.new(0, badgeW, 0, isMobile and 22 or 28)
    StatusBadge.Position         = UDim2.new(0, STAT + 2, 0.5, isMobile and -11 or -14)
    StatusBadge.BackgroundColor3 = Color3.fromRGB(30, 18, 56)
    StatusBadge.BorderSizePixel  = 0
    StatusBadge.ZIndex           = 100001
    StatusBadge.Parent           = banner
    Corner(StatusBadge, 8)
    Stroke(StatusBadge, ACCENT, 0.8, 0.25)
    local StatusLbl = Lbl(StatusBadge, "\226\151\143 LIVE", isMobile and 8 or 12, ACCENT, Enum.Font.GothamBold, Enum.TextXAlignment.Center)
    StatusLbl.Size           = UDim2.new(1, 0, 1, 0)
    StatusLbl.TextYAlignment = Enum.TextYAlignment.Center
    StatusLbl.ZIndex         = 100002

    local function _safeSaveBanner()
        local cfg = _G._FH_BannerCfg or {}
        cfg.y      = banner.Position.Y.Offset
        _G._FH_BannerCfg = cfg
        if Config and Config.set then
            pcall(function() Config.set("banner_pos_y",  cfg.y) end)
        end
    end

    banner.Active = true
    local bannerDragging = false
    local _bDragStartY = 0
    local _bOffStartY  = 0
    if _G._FH_DragClearers then
        table.insert(_G._FH_DragClearers, function() bannerDragging = false end)
    end
    banner.InputBegan:Connect(function(input)
        if _G._FH_GuiLocked ~= false then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            bannerDragging = true
            _bDragStartY = input.Position.Y
            _bOffStartY  = banner.Position.Y.Offset
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    bannerDragging = false
                    _safeSaveBanner()
                end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if not bannerDragging or _G._FH_GuiLocked ~= false then return end
        if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then
            local p = banner.Position
            banner.Position = UDim2.new(p.X.Scale, p.X.Offset, 0, _bOffStartY + (input.Position.Y - _bDragStartY))
        end
    end)

    task.spawn(function()
        local t0 = tick()
        while (not Config or not Config.get) and tick() - t0 < 10 do task.wait(0.1) end
        if not (Config and Config.get) then return end
        local py = Config.get("banner_pos_y", nil)
        if py then
            local p = banner.Position
            banner.Position = UDim2.new(p.X.Scale, p.X.Offset, 0, py)
        end
    end)

    _bannerStatsRef = function(fps, ping)
        FPSLabel.Text = "FPS: " .. fps
        FPSLabel.TextColor3 =
            (fps >= 55 and ACCENT) or
            (fps >= 30 and AMBER) or RED
        PINGLabel.Text = "PING: " .. ping .. "ms"
        PINGLabel.TextColor3 =
            (ping <= 80 and GREENP) or
            (ping <= 150 and AMBER) or RED
    end

    task.spawn(function()
        task.wait(0.15)
        TweenService:Create(banner, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = UDim2.new(0.5, 0, 0, isMobile and 6 or 12)}):Play()
        task.wait(0.5)
        TweenService:Create(banner, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.new(0.5, 0, 0, isMobile and 10 or 16)}):Play()
    end)
end)()
end
local UIRoot = Instance.new("Frame")
UIRoot.Name                   = "UIRoot"
UIRoot.Size                   = UDim2.new(1, 0, 1, 0)
UIRoot.Position               = UDim2.new(0, 0, 0, 0)
UIRoot.BackgroundTransparency = 1
UIRoot.BorderSizePixel        = 0
UIRoot.Active                 = false
UIRoot.ZIndex                 = 1
UIRoot.Parent                 = GUI
local WIN_W, WIN_H
if isPhone then
    WIN_W = 230
    WIN_H = 250
elseif isMobile then
    WIN_W = 260
    WIN_H = 270
else
    WIN_W = 410
    WIN_H = 360
end
local rootScale

local function _applyUiScale()
    local cam = workspace.CurrentCamera
    if not cam then
        local _t = 0
        repeat task.wait(0.05); _t = _t + 0.05; cam = workspace.CurrentCamera until cam or _t > 3
    end
    local vp  = (cam and cam.ViewportSize) or Vector2.new(1280, 720)
    local gsz = GUI.AbsoluteSize
    if gsz and gsz.X > 1 and gsz.Y > 1 then vp = gsz end
    if vp.X < 1 or vp.Y < 1 then vp = Vector2.new(1280, 720) end
    local pct = (_UI.userPct or 100) / 100
    local scale
    if isMobile then

        local _short = math.min(vp.X, vp.Y)
        local _long  = math.max(vp.X, vp.Y)
        local _curPhone = _short < 600
        local base = math.clamp(math.min(_long / 1366, _short / 768), 0.50, 1.20)
        scale = base * (_curPhone and 0.78 or 0.95) * pct
    else
        local base = math.clamp(math.min(vp.X / 1920, vp.Y / 1080), 0.63, 1.62)
        scale = base * pct * 0.91
    end
    local fitW = (vp.X * 0.96) / WIN_W
    local fitH = (vp.Y * 0.94) / WIN_H
    local cap  = math.max(0.40, math.min(fitW, fitH))
    _UI.desiredScale = math.clamp(math.min(scale, cap), 0.40, 2.25)
    if rootScale then rootScale.Scale = _UI.desiredScale end
    for _, e in ipairs(_gScaleList) do
        e.sc.Scale = _UI.desiredScale * e.f
    end
end
local _uiScalePending = false
local function _scheduleUiScale()
    if _uiScalePending then return end
    _uiScalePending = true
    task.delay(0.06, function()
        _uiScalePending = false
        _applyUiScale()
    end)
end
task.spawn(function()
    _applyUiScale()
    local cam = workspace.CurrentCamera
    if not cam then
        repeat task.wait(0.05); cam = workspace.CurrentCamera until cam
    end
    local function _connectCam(c)
        if c then pcall(function() c:GetPropertyChangedSignal("ViewportSize"):Connect(_scheduleUiScale) end) end
    end
    _connectCam(cam)

    pcall(function()
        workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
            _connectCam(workspace.CurrentCamera)
            _scheduleUiScale()
        end)
    end)
    pcall(function() GUI:GetPropertyChangedSignal("AbsoluteSize"):Connect(_scheduleUiScale) end)

    for _ = 1, 10 do task.wait(0.25); _scheduleUiScale() end
end)
local SIDE_W = isMobile and 78 or 120
local Root = Instance.new("Frame")
Root.Name             = "Root"
Root.Size             = UDim2.new(0, WIN_W, 0, WIN_H)
Root.AnchorPoint      = Vector2.new(0.5, 0.5)
Root.Position         = UDim2.new(0.5, 0, 0.5, 0)
Root.BackgroundColor3 = T.Bg
Root.BackgroundTransparency = 0.35
trackBgFrame(Root, "Bg")
Root.BorderSizePixel  = 0
Root.ZIndex           = 2
Root.Parent           = GUI
Corner(Root, 10)
local rootStroke = GradStroke(Root, 2.5, 0, 0)
local Shadow = Instance.new("ImageLabel")
Shadow.Size                   = UDim2.new(1, 40, 1, 40)
Shadow.Position               = UDim2.new(0, -20, 0, -20)
Shadow.BackgroundTransparency = 1
Shadow.Image                  = "rbxassetid://5028857084"
Shadow.ImageColor3            = Color3.fromRGB(0, 0, 0)
Shadow.ImageTransparency      = 0.6
Shadow.ScaleType              = Enum.ScaleType.Slice
Shadow.SliceCenter            = Rect.new(24, 24, 276, 276)
Shadow.ZIndex                 = 1
Shadow.Parent                 = Root
local Side = Instance.new("Frame")
Side.Size             = UDim2.new(0, SIDE_W, 1, 0)
Side.BackgroundColor3 = T.Side
Side.BackgroundTransparency = 0.25
trackBgFrame(Side, "Side")
Side.BorderSizePixel  = 0
Side.ZIndex           = 3
Side.Parent           = Root
Corner(Side, 10)
local SideCover = Instance.new("Frame")
SideCover.Size             = UDim2.new(0, 10, 1, 0)
SideCover.Position         = UDim2.new(1, -10, 0, 0)
SideCover.BackgroundColor3 = T.Side
SideCover.BackgroundTransparency = 0.25
trackBgFrame(SideCover, "Side")
SideCover.BorderSizePixel  = 0
SideCover.ZIndex           = 3
SideCover.Parent           = Side
local SideLine = Instance.new("Frame")
SideLine.Size                   = UDim2.new(0, 1, 1, -20)
SideLine.Position               = UDim2.new(1, 0, 0, 10)
SideLine.BackgroundColor3       = T.White
SideLine.BackgroundTransparency = 0.7
SideLine.BorderSizePixel        = 0
SideLine.ZIndex                 = 4
SideLine.Parent                 = Side
local Logo = Instance.new("Frame")
Logo.Size                   = UDim2.new(1, -14, 0, isMobile and 36 or 44)
Logo.Position               = UDim2.new(0, 7, 0, isMobile and 7 or 10)
Logo.BackgroundTransparency = 1
Logo.ZIndex                 = 4
Logo.Parent                 = Side
local LogoBadge = Instance.new("Frame")
LogoBadge.Size             = UDim2.new(0, isMobile and 22 or 30, 0, isMobile and 22 or 30)
LogoBadge.Position         = UDim2.new(0, 0, 0.5, (isMobile and -11 or -15))
LogoBadge.BackgroundColor3 = T.Primary
LogoBadge.BorderSizePixel  = 0
LogoBadge.ZIndex           = 5
LogoBadge.Parent           = Logo
Corner(LogoBadge, 7)
local LogoLetter = Lbl(LogoBadge, "G", isMobile and 13 or 18, T.White, Enum.Font.GothamBlack, Enum.TextXAlignment.Center)
LogoLetter.Size           = UDim2.new(1, 0, 1, 0)
LogoLetter.TextYAlignment = Enum.TextYAlignment.Center
LogoLetter.ZIndex         = 6
Grad(LogoLetter, nil, nil, 115)
GradStroke(LogoLetter, isMobile and 0.9 or 1.2, 0.15, 115)
local LogoTitle = Lbl(Logo, "GAMMA", isMobile and 9 or 11, T.Text, Enum.Font.GothamBold)
LogoTitle.Size     = UDim2.new(1, -38, 0, 13)
LogoTitle.Position = UDim2.new(0, 38, 0, 6)
LogoTitle.ZIndex   = 5
local LogoSub = Lbl(Logo, "Hub  V3.8", isMobile and 7 or 9, T.TextDim, Enum.Font.GothamMedium)
LogoSub.Size     = UDim2.new(1, -38, 0, 11)
LogoSub.Position = UDim2.new(0, 38, 0, 22)
LogoSub.ZIndex   = 5
local LogoDiv = Instance.new("Frame")
LogoDiv.Size                   = UDim2.new(1, -16, 0, 1)
LogoDiv.Position               = UDim2.new(0, 8, 0, isMobile and 50 or 64)
LogoDiv.BackgroundColor3       = T.White
LogoDiv.BackgroundTransparency = 0.8
LogoDiv.BorderSizePixel        = 0
LogoDiv.ZIndex                 = 4
LogoDiv.Parent                 = Side
local NavList = Instance.new("Frame")
NavList.Size                   = UDim2.new(1, -14, 1, isMobile and -66 or -82)
NavList.Position               = UDim2.new(0, 7, 0, isMobile and 57 or 72)
NavList.BackgroundTransparency = 1
NavList.ZIndex                 = 4
NavList.Parent                 = Side
local NavLayout = Instance.new("UIListLayout")
NavLayout.FillDirection = Enum.FillDirection.Vertical
NavLayout.Padding       = UDim.new(0, 3)
NavLayout.Parent        = NavList
local Content = Instance.new("Frame")
Content.Size                   = UDim2.new(1, -SIDE_W, 1, 0)
Content.Position               = UDim2.new(0, SIDE_W, 0, 0)
Content.BackgroundTransparency = 1
Content.ZIndex                 = 3
Content.Parent                 = Root
local guiLocked = false
_G._FH_GuiLocked = false
_G._FH_DragClearers = _G._FH_DragClearers or {}
_G._FH_ClearAllDrags = function()
    for _, fn in ipairs(_G._FH_DragClearers) do pcall(fn) end
end
if not _G._FH_LockWatchdog then
    _G._FH_LockWatchdog = true
    task.spawn(function()
        local RunService = game:GetService("RunService")
        RunService.Heartbeat:Connect(function()
            if _G._FH_GuiLocked and _G._FH_ClearAllDrags then
                _G._FH_ClearAllDrags()
            end
        end)
    end)
end
local TopBar = Instance.new("Frame")
TopBar.Size                   = UDim2.new(1, 0, 0, isMobile and 34 or 42)
TopBar.BackgroundTransparency = 1
TopBar.ZIndex                 = 4
TopBar.Parent                 = Content
local TopBarLine = Instance.new("Frame")
TopBarLine.Size                   = UDim2.new(1, -14, 0, 1)
TopBarLine.Position               = UDim2.new(0, 7, 1, -1)
TopBarLine.BackgroundColor3       = T.White
TopBarLine.BackgroundTransparency = 0.7
TopBarLine.BorderSizePixel        = 0
TopBarLine.ZIndex                 = 5
TopBarLine.Parent                 = TopBar
local PageTitle = Lbl(TopBar, "Main", isMobile and 10 or 12, T.Text, Enum.Font.GothamBold)
PageTitle.Size           = UDim2.new(0, 90, 1, 0)
PageTitle.Position       = UDim2.new(0, 10, 0, 0)
PageTitle.TextYAlignment = Enum.TextYAlignment.Center
PageTitle.ZIndex         = 5

local function makeColorDot(parent, xOffset, slot)
    local c = Instance.new("Frame")
    c.Size             = UDim2.new(0, 16, 0, 16)
    c.Position         = UDim2.new(1, xOffset, 0.5, -8)
    c.BackgroundColor3 = (slot == 1) and Theme.c1 or T.Bg
    c.BorderSizePixel  = 0
    c.ZIndex           = 6
    c.Parent           = parent
    Corner(c, 8)
    local ring = Instance.new("UIStroke")
    ring.Color        = T.White
    ring.Thickness    = 1.2
    ring.Transparency = 0.35
    ring.Parent       = c
    local btn = Instance.new("TextButton")
    btn.Size                   = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text                   = ""
    btn.AutoButtonColor        = false
    btn.ZIndex                 = 7
    btn.Parent                 = c
    btn.MouseEnter:Connect(function() Tween(ring, F, {Transparency = 0.1}) end)
    btn.MouseLeave:Connect(function() Tween(ring, F, {Transparency = 0.35}) end)
    return c, btn
end
local Dot1, Dot1Btn = makeColorDot(TopBar, isMobile and -88 or -48, 1)
local Dot2, Dot2Btn = makeColorDot(TopBar, isMobile and -68 or -28, 2)

do
    local LockBtn = Instance.new("TextButton")

    local btnSize = isMobile and 28 or 22
    local btnOff  = isMobile and -36 or -76
    LockBtn.Size                   = UDim2.new(0, btnSize, 0, btnSize)
    LockBtn.Position               = UDim2.new(1, btnOff, 0.5, -btnSize/2)
    LockBtn.BackgroundColor3       = T.BgDeep
    LockBtn.BorderSizePixel        = 0
    LockBtn.Text                   = "🔓"
    LockBtn.Font                   = Enum.Font.GothamBold
    LockBtn.TextSize               = isMobile and 15 or 13
    LockBtn.TextColor3             = T.Text
    LockBtn.AutoButtonColor        = false
    LockBtn.ZIndex                 = 6
    LockBtn.Parent                 = TopBar
    Corner(LockBtn, isMobile and 8 or 6)
    _G._FH_LockBtn = LockBtn

    LockBtn.Activated:Connect(function()
        guiLocked = not guiLocked
        _G._FH_GuiLocked = guiLocked
        LockBtn.Text = guiLocked and "🔒" or "🔓"
        LockBtn.TextColor3 = guiLocked and Color3.fromRGB(255, 200, 60) or T.Text
        if guiLocked and _G._FH_ClearAllDrags then _G._FH_ClearAllDrags() end
        if _G._FH_SaveLock then _G._FH_SaveLock(guiLocked) end
    end)
    LockBtn.MouseEnter:Connect(function() Tween(LockBtn, F, {BackgroundColor3 = T.CardHover}) end)
    LockBtn.MouseLeave:Connect(function() Tween(LockBtn, F, {BackgroundColor3 = T.BgDeep}) end)
end

local Config = {}
do
    local FOLDER      = "GammaHub"
    local FILE        = FOLDER .. "/config.json"
    local FILE_BAK    = FOLDER .. "/config.bak.json"
    local LEGACY_FILE = "violet_hub_config.json"
    local HttpService = game:GetService("HttpService")
    Config.data = {}

    local function _ensureFolder()
        if not makefolder then return end
        if isfolder and isfolder(FOLDER) then return end
        pcall(function() makefolder(FOLDER) end)
    end
    pcall(_ensureFolder)

    pcall(function()
        local function tryDecode(path)
            if isfile and readfile and isfile(path) then
                local ok, decoded = pcall(function() return HttpService:JSONDecode(readfile(path)) end)
                if ok and type(decoded) == "table" then return decoded end
            end
        end
        local d = tryDecode(FILE) or tryDecode(FILE_BAK) or tryDecode(LEGACY_FILE)
        if d then Config.data = d end
    end)

    local function _writeNow()
        if not writefile then return end
        if Config._dirty == false then return end
        pcall(_ensureFolder)
        local ok, encoded = pcall(function() return HttpService:JSONEncode(Config.data) end)
        if not ok or type(encoded) ~= "string" or #encoded < 2 then return end

        pcall(function()
            if isfile and isfile(FILE) then
                writefile(FILE_BAK, readfile(FILE))
            end
        end)
        pcall(function() writefile(FILE, encoded) end)
        Config._dirty = false
    end

    local _saveHandle = nil
    function Config.save()
        Config._dirty = true
        if not writefile then return end
        if _saveHandle then return end
        _saveHandle = task.delay(0.2, function()
            _writeNow()
            _saveHandle = nil
        end)
    end

    function Config.flush() _writeNow() end

    function Config.get(key, default)
        local v = Config.data[key]
        if v == nil then return default end
        return v
    end

    local function _deepEq(a, b)
        if type(a) == "number" and type(b) == "number" then
            return math.abs(a - b) < 1e-9
        end
        if a == b then return true end
        if type(a) ~= "table" or type(b) ~= "table" then return false end
        for k, v in pairs(a) do if not _deepEq(v, b[k]) then return false end end
        for k, _ in pairs(b) do if a[k] == nil then return false end end
        return true
    end

    function Config.set(key, value)
        if _deepEq(Config.data[key], value) then return end
        Config.data[key] = value
        Config._dirty = true
        if type(value) == "number" then
            Config.save()
        else
            _writeNow()
            if _saveHandle then task.cancel(_saveHandle); _saveHandle = nil end
        end
    end

    task.spawn(function()
        while true do
            task.wait(45)
            if writefile then _writeNow() end
        end
    end)

    pcall(function()
        game:BindToClose(function() _writeNow() end)
    end)
    pcall(function()
        local lp = Players.LocalPlayer
        if lp then
            lp.AncestryChanged:Connect(function(_, parent)
                if not parent then _writeNow() end
            end)
        end
    end)
    pcall(function()

        game.Close:Connect(function() _writeNow() end)
    end)
end

do
    if not _G._FH_JoinTime then
        local now    = os.time()
        local jobId  = tostring(game.JobId)
        if jobId == "" then jobId = "studio" end
        local KEY    = "joinTimes"
        local store  = Config.get(KEY, nil)
        if type(store) ~= "table" then store = {} end
        local saved  = store[jobId]
        if type(saved) == "number" and saved > 0 and saved <= now then
            _G._FH_JoinTime = saved
        else
            _G._FH_JoinTime = now

            local kept = {}
            for k, v in pairs(store) do
                if type(v) == "number" and (now - v) < 86400 then kept[k] = v end
            end
            kept[jobId] = now
            pcall(function() Config.set(KEY, kept) end)
        end
    end
end
function _FH_SecondsInGame()
    return os.time() - (_G._FH_JoinTime or os.time())
end

local visible = true
local setVisible
local ReopenBtn = Instance.new("TextButton")
ReopenBtn.Size                   = UDim2.new(0, 88, 0, 34)
ReopenBtn.Position               = UDim2.new(0, 8, 0.5, -17)
ReopenBtn.BackgroundColor3       = T.BgDeep
ReopenBtn.BorderSizePixel        = 0
ReopenBtn.Text                   = "GAMMA"
ReopenBtn.Font                   = Enum.Font.GothamBold
ReopenBtn.TextSize               = 13
ReopenBtn.TextColor3             = T.Text
ReopenBtn.AutoButtonColor        = false
ReopenBtn.Visible                = true
ReopenBtn.ZIndex                 = 10
ReopenBtn.Parent                 = GUI
_newScale(ReopenBtn)
Corner(ReopenBtn, 10)
Stroke(ReopenBtn, Color3.fromRGB(40,40,60), 1, 0.5)
ReopenBtn.MouseEnter:Connect(function() Tween(ReopenBtn, F, {BackgroundColor3 = T.CardHover}) end)
ReopenBtn.MouseLeave:Connect(function() Tween(ReopenBtn, F, {BackgroundColor3 = T.BgDeep}) end)
do
    local pillDragging, pillDS, pillWS, pillMoved, pillT
    ReopenBtn.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1
        or inp.UserInputType == Enum.UserInputType.Touch then
            pillDragging = true; pillMoved = false
            pillDS = inp.Position; pillWS = ReopenBtn.Position
            pillT = tick()
        end
    end)

    UserInputService.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1
        or inp.UserInputType == Enum.UserInputType.Touch then
            if pillDragging then
                pillDragging = false
                if not pillMoved and (tick() - (pillT or 0)) < 0.3 then
                    if setVisible then setVisible(not visible) end
                else
                    local p = ReopenBtn.Position
                    Config.set("reopen_pos", { p.X.Scale, p.X.Offset, p.Y.Scale, p.Y.Offset })
                end
            end
        end
    end)
    UserInputService.InputChanged:Connect(function(inp)
        if pillDragging and (inp.UserInputType == Enum.UserInputType.MouseMovement
        or inp.UserInputType == Enum.UserInputType.Touch) then
            if guiLocked then return end
            local delta = inp.Position - pillDS
            if math.abs(delta.X) > 6 or math.abs(delta.Y) > 6 then pillMoved = true end
            if pillMoved then
                local _camP = workspace.CurrentCamera
                local _vpP  = _camP and _camP.ViewportSize or Vector2.new(1920, 1080)
                local _szP  = ReopenBtn.AbsoluteSize
                local _pnx  = math.clamp(pillWS.X.Scale * _vpP.X + pillWS.X.Offset + delta.X, 0, math.max(0, _vpP.X - _szP.X))
                local _pny  = math.clamp(pillWS.Y.Scale * _vpP.Y + pillWS.Y.Offset + delta.Y, 0, math.max(0, _vpP.Y - _szP.Y))
                ReopenBtn.Position = UDim2.new(0, _pnx, 0, _pny)
            end
        end
    end)
end
local fps, ft, fc = 0, 0, 0

do
    local dragging, ds, ws, moved
    TopBar.Active = true
    table.insert(_G._FH_DragClearers, function() dragging = false end)
    TopBar.InputBegan:Connect(function(inp)
        if guiLocked then return end
        if inp.UserInputType == Enum.UserInputType.MouseButton1
        or inp.UserInputType == Enum.UserInputType.Touch then
            local _abs = Root.AbsolutePosition
            Root.AnchorPoint = Vector2.new(0, 0)
            Root.Position = UDim2.new(0, _abs.X, 0, _abs.Y)
            dragging = true; ds = inp.Position; ws = Root.Position; moved = false
        end
    end)
    TopBar.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1
        or inp.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end)
    UserInputService.InputChanged:Connect(function(inp)
        if guiLocked then dragging = false; return end
        if dragging and (inp.UserInputType == Enum.UserInputType.MouseMovement
        or inp.UserInputType == Enum.UserInputType.Touch) then
            local d = inp.Position - ds
            if not moved then
                if d.Magnitude < 8 then return end
                moved = true; ds = inp.Position; ws = Root.Position; return
            end
            local _cam = workspace.CurrentCamera
            local _vp  = _cam and _cam.ViewportSize or Vector2.new(1920, 1080)
            local _sz  = Root.AbsoluteSize
            local _nx  = math.clamp(ws.X.Offset + d.X, 0, math.max(0, _vp.X - _sz.X))
            local _ny  = math.clamp(ws.Y.Offset + d.Y, 0, math.max(0, _vp.Y - _sz.Y))
            Root.Position = UDim2.new(0, _nx, 0, _ny)
            ws = UDim2.new(0, _nx, 0, _ny)
            ds = inp.Position
        end
    end)
end
local Pages = Instance.new("Frame")
Pages.Size                   = UDim2.new(1, 0, 1, -64)
Pages.Position               = UDim2.new(0, 0, 0, 42)
Pages.BackgroundTransparency = 1
Pages.ClipsDescendants       = true
Pages.ZIndex                 = 3
Pages.Parent                 = Content

local StatusBar = Instance.new("Frame")
StatusBar.Name                   = "StatusBar"
StatusBar.Size                   = UDim2.new(1, 0, 0, 22)
StatusBar.Position               = UDim2.new(0, 0, 1, -22)
StatusBar.BackgroundColor3       = Color3.fromRGB(10, 10, 15)
StatusBar.BorderSizePixel        = 0
StatusBar.ZIndex                 = 5
StatusBar.Parent                 = Content
local _sbTop = Instance.new("Frame")
_sbTop.Size             = UDim2.new(1, 0, 0, 1)
_sbTop.BackgroundColor3 = Color3.fromRGB(30, 30, 46)
_sbTop.BorderSizePixel  = 0
_sbTop.ZIndex           = 6
_sbTop.Parent           = StatusBar
local _sbStats = Instance.new("TextLabel")
_sbStats.Size                   = UDim2.new(0, 180, 1, 0)
_sbStats.Position               = UDim2.new(0, 10, 0, 0)
_sbStats.BackgroundTransparency = 1
_sbStats.Text                   = "FPS: --   PING: --ms"
_sbStats.TextSize               = 9
_sbStats.Font                   = Enum.Font.GothamMedium
_sbStats.TextColor3             = Color3.fromRGB(100, 100, 125)
_sbStats.TextXAlignment         = Enum.TextXAlignment.Left
_sbStats.TextYAlignment         = Enum.TextYAlignment.Center
_sbStats.ZIndex                 = 6
_sbStats.Parent                 = StatusBar
local _sbDot = Instance.new("Frame")
_sbDot.Size             = UDim2.new(0, 7, 0, 7)
_sbDot.Position         = UDim2.new(1, -50, 0.5, -3)
_sbDot.BackgroundColor3 = Color3.fromRGB(34, 197, 94)
_sbDot.BorderSizePixel  = 0
_sbDot.ZIndex           = 6
_sbDot.Parent           = StatusBar
local _sbDotCorner = Instance.new("UICorner")
_sbDotCorner.CornerRadius = UDim.new(1, 0)
_sbDotCorner.Parent = _sbDot
local _sbOnLbl = Instance.new("TextLabel")
_sbOnLbl.Size                   = UDim2.new(0, 30, 1, 0)
_sbOnLbl.Position               = UDim2.new(1, -40, 0, 0)
_sbOnLbl.BackgroundTransparency = 1
_sbOnLbl.Text                   = "ON"
_sbOnLbl.TextSize               = 9
_sbOnLbl.Font                   = Enum.Font.GothamBold
_sbOnLbl.TextColor3             = Color3.fromRGB(34, 197, 94)
_sbOnLbl.TextXAlignment         = Enum.TextXAlignment.Left
_sbOnLbl.TextYAlignment         = Enum.TextYAlignment.Center
_sbOnLbl.ZIndex                 = 6
_sbOnLbl.Parent                 = StatusBar

local _statsConn; _statsConn = RunService.Heartbeat:Connect(LPH_NO_VIRTUALIZE(function(dt)
    if _GEN ~= _G._FH_GAMMA_GEN then _statsConn:Disconnect(); return end

    _sharedFc = _sharedFc + 1
    _sharedFt = _sharedFt + dt
    if _sharedFt >= 1 then
        _sharedFps = math.floor(_sharedFc / _sharedFt)
        _sharedFc, _sharedFt = 0, 0
        local ping = math.floor(((Players.LocalPlayer and Players.LocalPlayer:GetNetworkPing()) or 0) * 1000)
        local txt = "FPS: " .. _sharedFps .. "   PING: " .. ping .. "ms"
        if txt ~= _bannerLast then
            _bannerLast = txt
            if _bannerStatsRef then pcall(_bannerStatsRef, _sharedFps, ping) end
            _sbStats.Text = txt
        end
    end

    if not isMobile then
        _sharedFlowPhase = (_sharedFlowPhase + dt * 0.4) % 1
        _gradAccum = _gradAccum + dt
        if _gradAccum < _GRAD_TICK then return end
        _gradAccum = 0
        _gradPhase = (_gradPhase + _GRAD_TICK * 90) % 360
        _sharedFlowSeq = _computeFlowSeq(_sharedFlowPhase)
        local n = #ThemeGrads
        if n == 0 then return end
        for i = 1, n do
            local e = ThemeGrads[i]
            local g = e.grad
            if g and g.Parent and g.Parent.Parent then
                local r = e.baseRot + _gradPhase * e.speed
                if g.Rotation ~= r then g.Rotation = r end
            end
        end
    end
end))

local function Scroll(parent)
    local s = Instance.new("ScrollingFrame")
    s.Size                  = UDim2.new(1, 0, 1, 0)
    s.BackgroundTransparency = 1
    s.BorderSizePixel       = 0
    s.ScrollBarThickness    = 2
    s.ScrollBarImageColor3  = T.White
    s.ScrollBarImageTransparency = 0
    s.CanvasSize            = UDim2.new(0, 0, 0, 0)
    s.AutomaticCanvasSize   = Enum.AutomaticSize.Y
    s.ScrollingDirection    = Enum.ScrollingDirection.Y
    s.ZIndex                = 3
    s.Parent                = parent
    local l = Instance.new("UIListLayout")
    l.FillDirection       = Enum.FillDirection.Vertical
    l.HorizontalAlignment = Enum.HorizontalAlignment.Center
    l.SortOrder           = Enum.SortOrder.LayoutOrder
    l.Padding             = UDim.new(0, 6)
    l.Parent              = s
    Pad(s, 8, 8, 8, 8)
    return s, l
end
local Tabs = {}
local Active = nil
local Swapping = false
local _swapGen  = 0
local function setPage(t)
    if Active == t or Swapping then return end
    Swapping = true
    _swapGen = _swapGen + 1
    local myGen = _swapGen
    local function doneSwap()
        if _swapGen == myGen then Swapping = false end
    end
    task.delay(0.7, doneSwap)

    local old = Active
    Active = t
    if old then
        Tween(old.btn, F, {BackgroundColor3 = T.Side})
        Tween(old.lbl, F, {TextColor3       = T.TextDim})
        Tween(old.dot, F, {BackgroundTransparency = 1})
    end
    Tween(t.btn, F, {BackgroundColor3 = T.SideActive})
    Tween(t.lbl, F, {TextColor3       = Color3.fromRGB(255, 255, 255)})
    Tween(t.dot, F, {BackgroundTransparency = 0})
    PageTitle.Text = t.title
    if old then
        local isCG = pcall(function() return old.canvas:IsA("CanvasGroup") end) and old.canvas:IsA("CanvasGroup")
        if isCG then
            local fadeOut = TweenService:Create(old.canvas, PG, {GroupTransparency = 1})
            fadeOut:Play()
            fadeOut.Completed:Connect(function()
                pcall(function() old.page.Visible = false end)
                local tCG = pcall(function() return t.canvas:IsA("CanvasGroup") end) and t.canvas:IsA("CanvasGroup")
                pcall(function()
                    if tCG then t.canvas.GroupTransparency = 1 end
                    t.page.Visible = true
                end)
                if tCG then
                    local fadeIn = TweenService:Create(t.canvas, PG, {GroupTransparency = 0})
                    fadeIn:Play()
                    fadeIn.Completed:Connect(doneSwap)
                else
                    doneSwap()
                end
            end)
        else
            pcall(function() old.page.Visible = false end)
            pcall(function() t.page.Visible   = true  end)
            doneSwap()
        end
    else
        pcall(function()
            t.page.Visible = true
            local tCG = pcall(function() return t.canvas:IsA("CanvasGroup") end) and t.canvas:IsA("CanvasGroup")
            if tCG then t.canvas.GroupTransparency = 0 end
        end)
        doneSwap()
    end
end
local function Nav(name, title)
    local btn = Instance.new("TextButton")
    btn.Size                   = UDim2.new(1, 0, 0, isMobile and 24 or 30)
    btn.BackgroundColor3       = T.Side
    btn.BorderSizePixel        = 0
    btn.Text                   = ""
    btn.AutoButtonColor        = false
    btn.ZIndex                 = 5
    btn.Parent                 = NavList
    Corner(btn, 6)
    local dot = Instance.new("Frame")
    dot.Size                   = UDim2.new(0, 3, 0, 12)
    dot.Position               = UDim2.new(0, 4, 0.5, -6)
    dot.BackgroundColor3       = T.Primary
    dot.BackgroundTransparency = 1
    dot.BorderSizePixel        = 0
    dot.ZIndex                 = 6
    dot.Parent                 = btn
    Corner(dot, 2)
    local lbl = Lbl(btn, name, isMobile and 9 or 11, T.TextDim, Enum.Font.GothamBold)
    lbl.Size           = UDim2.new(1, -16, 1, 0)
    lbl.Position       = UDim2.new(0, 14, 0, 0)
    lbl.TextYAlignment = Enum.TextYAlignment.Center
    lbl.ZIndex         = 6
    local page = Instance.new("Frame")
    page.Size                   = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.Visible                = false
    page.ZIndex                 = 3
    page.Parent                 = Pages
    local canvas
    local _cgOk = pcall(function()
        canvas = Instance.new("CanvasGroup")
        canvas.GroupTransparency = 0
    end)
    if not _cgOk then
        canvas = Instance.new("Frame")
    end
    canvas.Size                   = UDim2.new(1, 0, 1, 0)
    canvas.BackgroundTransparency = 1
    canvas.ZIndex                 = 3
    canvas.Parent                 = page
    local scroll = Scroll(canvas)
    local t = {btn = btn, lbl = lbl, dot = dot, page = page, canvas = canvas, scroll = scroll, title = title}
    btn.MouseEnter:Connect(function()
        if Active ~= t then Tween(btn, F, {BackgroundColor3 = T.SideHover}) end
    end)
    btn.MouseLeave:Connect(function()
        if Active ~= t then Tween(btn, F, {BackgroundColor3 = T.Side}) end
    end)
    btn.Activated:Connect(function() setPage(t) end)
    table.insert(Tabs, t)
    return t
end
local function Section(parent, title)
    local f = Instance.new("Frame")
    f.Size                   = UDim2.new(1, -8, 0, isMobile and 14 or 18)
    f.BackgroundTransparency = 1
    f.Parent                 = parent
    local lbl = Lbl(f, title:upper(), 8, T.TextDim, Enum.Font.GothamBold)
    lbl.Size           = UDim2.new(1, -4, 1, 0)
    lbl.Position       = UDim2.new(0, 4, 0, 0)
    lbl.TextYAlignment = Enum.TextYAlignment.Center
end
local function Card(parent, h)
    local card = Instance.new("Frame")
    card.Size             = UDim2.new(1, -8, 0, h)
    card.BackgroundColor3 = T.Card
    trackBgFrame(card, "Card")
    card.BorderSizePixel  = 0
    card.ZIndex           = 4
    card.Parent           = parent
    Corner(card, 6)
    local s = Stroke(card, T.Line, 1, 0.25)
    card.MouseEnter:Connect(function()
        Tween(card, F, {BackgroundColor3 = T.CardHover})
        Tween(s,    F, {Transparency = 0.05})
    end)
    card.MouseLeave:Connect(function()
        Tween(card, F, {BackgroundColor3 = T.Card})
        Tween(s,    F, {Transparency = 0.25})
    end)
    return card, s
end
do
    _G._FH_SaveLock = function(state) pcall(function() Config.set("gui_locked", state and true or false) end) end
    if Config.get("gui_locked", false) == true then
        guiLocked = true
        _G._FH_GuiLocked = true
        local lb = _G._FH_LockBtn
        if lb then
            lb.Text       = "🔒"
            lb.TextColor3 = Color3.fromRGB(255, 200, 60)
        end
    end
end
do
    local rp = Config.get("reopen_pos", nil)
    if type(rp) == "table" and #rp == 4 then
        ReopenBtn.Position = UDim2.new(rp[1], rp[2], rp[3], rp[4])
        task.defer(function()
            local _camR = workspace.CurrentCamera
            local _vpR  = _camR and _camR.ViewportSize or Vector2.new(1920, 1080)
            local _szR  = ReopenBtn.AbsoluteSize
            local _absR = ReopenBtn.AbsolutePosition
            local _rnx  = math.clamp(_absR.X, 0, math.max(0, _vpR.X - _szR.X))
            local _rny  = math.clamp(_absR.Y, 0, math.max(0, _vpR.Y - _szR.Y))
            if math.abs(_rnx - _absR.X) > 1 or math.abs(_rny - _absR.Y) > 1 then
                ReopenBtn.Position = UDim2.new(0, _rnx, 0, _rny)
                Config.set("reopen_pos", { 0, _rnx, 0, _rny })
            end
        end)
    end
end
do
    local function loadCol(key, default)
        local t = Config.get(key, nil)
        if type(t) == "table" and #t == 3 then
            return Color3.fromRGB(t[1], t[2], t[3])
        end
        return default
    end
    Theme.c1 = loadCol("theme_c1", Theme.c1)
    Theme.c2 = loadCol("theme_c2", Theme.c2)
    local _savedBg = loadCol("theme_bg", nil)
    if _savedBg then
        SetGuiColor(_savedBg)
        if Dot2 then Dot2.BackgroundColor3 = T.Bg end
    end
end
do
    local saved = tonumber(Config.get("slider:UI Size", nil))
    if saved then
        task.defer(function()
            _UI.userPct = math.clamp(saved, 50, 200)
            pcall(_applyUiScale)
        end)
    end
end
local KB_binds   = {}
local KB_capture = nil

-- Controller (gamepad) keybind state.
local PAD_capture    = nil   -- the ONE entry currently waiting for a controller button
local PAD_hovered    = nil   -- entry the cursor is currently over
local _padHeldKeys   = {}    -- gamepad KeyCodes currently held down
local _padIgnoreKeys = {}    -- buttons held when capture began; ignored until released
local PAD_INPUT_TYPES = {
    [Enum.UserInputType.Gamepad1] = true, [Enum.UserInputType.Gamepad2] = true,
    [Enum.UserInputType.Gamepad3] = true, [Enum.UserInputType.Gamepad4] = true,
    [Enum.UserInputType.Gamepad5] = true, [Enum.UserInputType.Gamepad6] = true,
    [Enum.UserInputType.Gamepad7] = true, [Enum.UserInputType.Gamepad8] = true,
}
local function _isPadInput(it) return PAD_INPUT_TYPES[it] == true end

local GuiService = game:GetService("GuiService")

-- Brand-correct controller button labels (PlayStation vs Xbox/generic).
local PAD_NAMES_PS = {
    ButtonA="Cross", ButtonB="Circle", ButtonX="Square", ButtonY="Triangle",
    ButtonL1="L1", ButtonR1="R1", ButtonL2="L2", ButtonR2="R2",
    ButtonL3="L3", ButtonR3="R3", ButtonStart="Options", ButtonSelect="Share",
    DPadUp="D-Up", DPadDown="D-Down", DPadLeft="D-Left", DPadRight="D-Right",
}
local PAD_NAMES_XBOX = {
    ButtonA="A", ButtonB="B", ButtonX="X", ButtonY="Y",
    ButtonL1="LB", ButtonR1="RB", ButtonL2="LT", ButtonR2="RT",
    ButtonL3="LS", ButtonR3="RS", ButtonStart="Menu", ButtonSelect="View",
    DPadUp="D-Up", DPadDown="D-Down", DPadLeft="D-Left", DPadRight="D-Right",
}
local _padBrand = "xbox"   -- "ps" | "xbox"
local function _refreshPadBrand()
    local a, y = "", ""
    pcall(function() a = tostring(UserInputService:GetStringForKeyCode(Enum.KeyCode.ButtonA) or "") end)
    pcall(function() y = tostring(UserInputService:GetStringForKeyCode(Enum.KeyCode.ButtonY) or "") end)
    local s = (a .. " " .. y):lower()
    if s:find("cross") or s:find("circle") or s:find("square") or s:find("triangle")
    or a:find("\226\156\149") or y:find("\226\150\179") then
        _padBrand = "ps"
    else
        _padBrand = "xbox"
    end
    for _, e in ipairs(KB_binds) do if e.refresh then pcall(e.refresh) end end
end
pcall(_refreshPadBrand)
pcall(function()
    UserInputService.GamepadConnected:Connect(function() pcall(_refreshPadBrand) end)
    UserInputService.LastInputTypeChanged:Connect(function(it)
        if _isPadInput(it) then pcall(_refreshPadBrand) end
    end)
end)
local function _padDisplayName(kc)
    if not kc then return "?" end
    local name = kc.Name
    if name == "" or name == "Unknown" then return "?" end
    local map = (_padBrand == "ps") and PAD_NAMES_PS or PAD_NAMES_XBOX
    if map[name] then return map[name] end
    -- Secondary: let the platform name odd buttons on any console.
    local s
    pcall(function() s = UserInputService:GetStringForKeyCode(kc) end)
    if type(s) == "string" and s ~= "" and s:lower() ~= "unknown" and #s <= 14 then
        return s
    end
    return (name:gsub("^Button", ""):gsub("^DPad", "D-"))
end
-- Only ever one capture active at a time; clearing one restores its label.
local function clearKBCapture()
    if KB_capture then local e = KB_capture; KB_capture = nil; if e.refresh then e.refresh() end end
end
local function clearPadCapture()
    if PAD_capture then local e = PAD_capture; PAD_capture = nil; if e.refresh then e.refresh() end end
end

-- True only if the element AND all its ancestors are visible (so we never
-- match a toggle that's on a hidden page).
local function _isShown(o)
    local n = o
    while n do
        if n:IsA("GuiObject") and not n.Visible then return false end
        n = n.Parent
    end
    return true
end

-- Work out which toggle the (virtual) cursor is really over. The hub uses
-- IgnoreGuiInset, so the gamepad cursor's hit-test was landing on the toggle
-- ABOVE the one under the pointer; adding the GUI inset corrects that distance.
local function _padHoverEntry()
    local ok, m = pcall(function() return UserInputService:GetMouseLocation() end)
    if not ok or not m then return PAD_hovered end
    local inset = Vector2.new(0, 0)
    pcall(function() inset = GuiService:GetGuiInset() end)
    local mx, my = m.X + inset.X, m.Y + inset.Y
    for _, e in ipairs(KB_binds) do
        local h = e.host
        if h then
            local p, s = h.AbsolutePosition, h.AbsoluteSize
            if s.X > 0 and s.Y > 0
            and mx >= p.X and mx <= p.X + s.X
            and my >= p.Y and my <= p.Y + s.Y
            and _isShown(h) then
                return e
            end
        end
    end
    return nil
end

local function attachKeybind(host, nameLbl, baseName, fireFn)
    local entry = {
        key = nil, padKey = nil, fire = fireFn,
        cfgKey = "keybind:" .. baseName, padCfgKey = "padbind:" .. baseName,
    }
    local function refresh()
        if KB_capture == entry or PAD_capture == entry then
            nameLbl.Text = baseName .. "  (...)"
            return
        end
        local parts = {}
        if entry.key    then table.insert(parts, entry.key.Name) end
        if entry.padKey then table.insert(parts, _padDisplayName(entry.padKey)) end
        if #parts > 0 then
            nameLbl.Text = baseName .. "  (" .. table.concat(parts, " / ") .. ")"
        else
            nameLbl.Text = baseName
        end
    end
    entry.refresh = refresh
    entry.host    = host
    table.insert(KB_binds, entry)
    local saved = Config.get(entry.cfgKey, nil)
    if saved then
        local ok, kc = pcall(function() return Enum.KeyCode[saved] end)
        if ok and kc then entry.key = kc end
    end
    local savedPad = Config.get(entry.padCfgKey, nil)
    if savedPad and savedPad ~= "Unknown" then
        local ok, kc = pcall(function() return Enum.KeyCode[savedPad] end)
        if ok and kc and kc ~= Enum.KeyCode.Unknown then entry.padKey = kc end
    end
    refresh()
    host.MouseEnter:Connect(function() PAD_hovered = entry end)
    host.MouseLeave:Connect(function() if PAD_hovered == entry then PAD_hovered = nil end end)
    host.MouseButton2Click:Connect(function()
        clearPadCapture()
        if KB_capture and KB_capture ~= entry then clearKBCapture() end
        KB_capture = entry
        refresh()
    end)
    do
        local pressT, pressing = 0, false

        local function isHold(it)
            return it == Enum.UserInputType.Touch or it == Enum.UserInputType.MouseButton1
        end
        host.InputBegan:Connect(function(inp)
            if not isHold(inp.UserInputType) then return end
            -- A controller press also fires MouseButton1 on the cursor; let the
            -- gamepad path handle that so we don't double-open capture.
            if _isPadInput(UserInputService:GetLastInputType()) then return end
            pressing = true; pressT = tick()
            task.delay(1.5, function()
                if pressing and tick() - pressT >= 1.5 then
                    clearPadCapture()
                    if KB_capture and KB_capture ~= entry then clearKBCapture() end
                    KB_capture = entry
                    refresh()
                end
            end)
        end)
        host.InputEnded:Connect(function(inp)
            if isHold(inp.UserInputType) then pressing = false end
        end)
    end
    return entry
end
UserInputService.InputBegan:Connect(function(inp, gpe)
    if inp.UserInputType ~= Enum.UserInputType.Keyboard then return end
    if KB_capture then
        local e, kc = KB_capture, inp.KeyCode
        KB_capture = nil
        if kc == Enum.KeyCode.Backspace or kc == Enum.KeyCode.Delete then
            e.key = nil
        elseif kc ~= Enum.KeyCode.Escape then
            e.key = kc
        end
        e.refresh()
        Config.set(e.cfgKey, e.key and e.key.Name or nil)
        return
    end
    if UserInputService:GetFocusedTextBox() then return end
    for _, e in ipairs(KB_binds) do
        if e.key and inp.KeyCode == e.key then task.spawn(e.fire) end
    end
end)

-- Controller keybind support:
--   * Hover ONE toggle and hold any controller button for 1.5s.
--       - No bind yet  -> that toggle (and only it) shows "(...)"; the next
--         controller button you press (after releasing the held one) is bound.
--       - Already bound -> the bind is removed.
--   * A short tap of a bound button fires that toggle.
UserInputService.InputBegan:Connect(function(inp, gpe)
    if not _isPadInput(inp.UserInputType) then return end
    local kc = inp.KeyCode
    if kc == Enum.KeyCode.Unknown then return end
    _padHeldKeys[kc] = true

    -- Assigning a controller button to the toggle that's waiting.
    if PAD_capture then
        if _padIgnoreKeys[kc] then return end -- button held since capture began
        local e = PAD_capture
        PAD_capture = nil
        e.padKey = kc
        e.refresh()
        Config.set(e.padCfgKey, kc.Name)
        return
    end

    -- Hold over the hovered toggle for 1.5s to bind / unbind it. The toggle is
    -- resolved from the real (inset-corrected) cursor position, so it's the one
    -- you're actually pointing at -- not the one above it.
    local hoverE = _padHoverEntry() or PAD_hovered
    if hoverE then
        local e = hoverE
        task.delay(1.5, function()
            if not _padHeldKeys[kc] then return end -- released before 1.5s
            if (_padHoverEntry() or PAD_hovered) ~= e then return end -- moved off it
            if e.padKey then
                -- Already bound -> remove the bind.
                e.padKey = nil
                Config.set(e.padCfgKey, nil)
                e.refresh()
            else
                -- Open capture on ONLY this toggle. Ignore every button held
                -- right now (incl. the activation button) until it's released
                -- so it can't be assigned by accident.
                clearKBCapture()
                clearPadCapture()
                PAD_capture = e
                _padIgnoreKeys = {}
                for hk in pairs(_padHeldKeys) do _padIgnoreKeys[hk] = true end
                e.refresh()
            end
        end)
    end

    -- Fire a bound toggle (never while assigning a bind).
    if not PAD_capture and not UserInputService:GetFocusedTextBox() then
        for _, e in ipairs(KB_binds) do
            if e.padKey and kc == e.padKey then task.spawn(e.fire) end
        end
    end
end)
UserInputService.InputEnded:Connect(function(inp)
    if not _isPadInput(inp.UserInputType) then return end
    local kc = inp.KeyCode
    _padHeldKeys[kc] = nil
    _padIgnoreKeys[kc] = nil -- once released, this button can be assigned
end)

local _guiReady = false
local _activeNotifs = {}
local NOTIF_W       = 200
local NOTIF_H       = 44
local NOTIF_GAP     = 6
local NOTIF_PAD_X   = 14
local NOTIF_PAD_Y   = 14
local NOTIF_DUR     = 2.2
local function _shadowTargetY(slotIdx)
    return -(NOTIF_PAD_Y + NOTIF_H + 4 + slotIdx * (NOTIF_H + NOTIF_GAP))
end
local function _repoAll(tweenInfo)
    for i, e in ipairs(_activeNotifs) do
        TweenService:Create(e.shadow, tweenInfo, {
            Position = UDim2.new(0, NOTIF_PAD_X - 4, 1, _shadowTargetY(i - 1))
        }):Play()
    end
end
local _toastDedup = {}
local function showToast(label, state)
    if not _guiReady then return end

    local key  = tostring(label) .. "|" .. tostring(state and 1 or 0)
    local nowT = tick()
    if _toastDedup[key] and (nowT - _toastDedup[key]) < 0.5 then return end
    _toastDedup[key] = nowT
    local statusTxt = state and "Enabled" or "Disabled"
    local statusCol = state and Color3.fromRGB(150, 255, 150) or Color3.fromRGB(255, 100, 100)
    local IN_INFO   = TweenInfo.new(isMobile and 0.3 or 0.38, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    local IN_FADE   = TweenInfo.new(isMobile and 0.24 or 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local OUT_INFO  = TweenInfo.new(isMobile and 0.22 or 0.28, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
    local BAR_INFO  = TweenInfo.new(NOTIF_DUR, Enum.EasingStyle.Linear)
    local FADE_INFO = TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
    local REPO_INFO = TweenInfo.new(isMobile and 0.24 or 0.32, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
    local shadow = Instance.new("Frame")
    shadow.Name                   = "ToastShadow"
    shadow.Size                   = UDim2.new(0, NOTIF_W + 8, 0, NOTIF_H + 8)
    shadow.Position               = UDim2.new(0, -(NOTIF_W + 32), 1, _shadowTargetY(0))
    shadow.BackgroundTransparency = 1
    shadow.BorderSizePixel        = 0
    shadow.ZIndex                 = 199
    shadow.Parent                 = GUI
    local toast = Instance.new("Frame")
    toast.Name                   = "ToastNotif"
    toast.Size                   = UDim2.new(0, NOTIF_W, 0, NOTIF_H)
    toast.Position               = UDim2.new(0, 4, 0, 4)
    toast.BackgroundColor3       = Color3.fromRGB(16, 16, 20)
    toast.BackgroundTransparency = 1
    toast.BorderSizePixel        = 0
    toast.ZIndex                 = 200
    toast.Parent                 = shadow
    local _tc = Instance.new("UICorner"); _tc.CornerRadius = UDim.new(0, 10); _tc.Parent = toast
    local _stroke = Instance.new("UIStroke")
    _stroke.Color           = Theme.c1
    _stroke.Thickness       = 1
    _stroke.Transparency    = 1
    _stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    _stroke.Parent          = toast
    local softShadow = Instance.new("ImageLabel")
    softShadow.Size                   = UDim2.new(1, 24, 1, 24)
    softShadow.Position               = UDim2.new(0, -12, 0, -12)
    softShadow.BackgroundTransparency = 1
    softShadow.Image                  = "rbxassetid://5028857084"
    softShadow.ImageColor3            = Color3.fromRGB(0, 0, 0)
    softShadow.ImageTransparency      = 1
    softShadow.ScaleType              = Enum.ScaleType.Slice
    softShadow.SliceCenter            = Rect.new(24, 24, 276, 276)
    softShadow.ZIndex                 = 199
    softShadow.Parent                 = toast
    local pill = Instance.new("Frame")
    pill.Size                   = UDim2.new(0, 3, 0, NOTIF_H - 16)
    pill.Position               = UDim2.new(0, 9, 0.5, -(NOTIF_H - 16) / 2)
    pill.BackgroundColor3       = statusCol
    pill.BackgroundTransparency = 0.15
    pill.BorderSizePixel        = 0
    pill.ZIndex                 = 201
    pill.Parent                 = toast
    local _pc = Instance.new("UICorner"); _pc.CornerRadius = UDim.new(1, 0); _pc.Parent = pill
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size               = UDim2.new(1, -24, 0, 15)
    nameLabel.Position           = UDim2.new(0, 19, 0, 7)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text               = label
    nameLabel.TextSize           = 11
    nameLabel.Font               = Enum.Font.GothamBold
    nameLabel.TextColor3         = Color3.fromRGB(255, 255, 255)
    nameLabel.TextXAlignment     = Enum.TextXAlignment.Left
    nameLabel.TextTruncate       = Enum.TextTruncate.AtEnd
    nameLabel.TextTransparency   = 1
    nameLabel.ZIndex             = 201
    nameLabel.Parent             = toast
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Size               = UDim2.new(1, -24, 0, 11)
    statusLabel.Position           = UDim2.new(0, 19, 0, 23)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text               = statusTxt
    statusLabel.TextSize           = 10
    statusLabel.Font               = Enum.Font.Gotham
    statusLabel.TextColor3         = statusCol
    statusLabel.TextXAlignment     = Enum.TextXAlignment.Left
    statusLabel.TextTransparency   = 1
    statusLabel.ZIndex             = 201
    statusLabel.Parent             = toast
    local barTrack = Instance.new("Frame")
    barTrack.Size                   = UDim2.new(1, -16, 0, 3)
    barTrack.Position               = UDim2.new(0, 8, 1, -7)
    barTrack.BackgroundColor3       = Color3.fromRGB(255, 255, 255)
    barTrack.BackgroundTransparency = 1
    barTrack.BorderSizePixel        = 0
    barTrack.ZIndex                 = 201
    barTrack.Parent                 = toast
    local _btc = Instance.new("UICorner"); _btc.CornerRadius = UDim.new(1, 0); _btc.Parent = barTrack
    local barFill = Instance.new("Frame")
    barFill.Size                   = UDim2.new(1, 0, 1, 0)
    barFill.BackgroundColor3       = Theme.c1
    barFill.BackgroundTransparency = 1
    barFill.BorderSizePixel        = 0
    barFill.ZIndex                 = 202
    barFill.Parent                 = barTrack
    local _bfc = Instance.new("UICorner"); _bfc.CornerRadius = UDim.new(1, 0); _bfc.Parent = barFill
    local _bgr = Instance.new("UIGradient")
    _bgr.Color  = ColorSequence.new(Theme.c1, statusCol)
    _bgr.Parent = barFill
    local entry = { shadow = shadow }
    table.insert(_activeNotifs, 1, entry)
    _repoAll(REPO_INFO)
    TweenService:Create(shadow, IN_INFO, {
        Position = UDim2.new(0, NOTIF_PAD_X - 4, 1, _shadowTargetY(0))
    }):Play()
    TweenService:Create(toast,       IN_FADE, {BackgroundTransparency = 0}):Play()
    TweenService:Create(_stroke,     IN_FADE, {Transparency = 0.15}):Play()
    TweenService:Create(nameLabel,   IN_FADE, {TextTransparency = 0}):Play()
    TweenService:Create(statusLabel, IN_FADE, {TextTransparency = 0}):Play()
    TweenService:Create(barTrack,    IN_FADE, {BackgroundTransparency = 0.92}):Play()
    TweenService:Create(barFill,     IN_FADE, {BackgroundTransparency = 0}):Play()
    task.delay(0.1, function()
        TweenService:Create(barFill, BAR_INFO, {Size = UDim2.new(0, 0, 1, 0)}):Play()
    end)
    task.delay(NOTIF_DUR + 0.15, function()
        for i, e in ipairs(_activeNotifs) do
            if e == entry then table.remove(_activeNotifs, i); break end
        end
        _repoAll(REPO_INFO)
        local exitY = shadow.Position.Y.Offset
        TweenService:Create(shadow, OUT_INFO, {
            Position = UDim2.new(0, -(NOTIF_W + 32), 1, exitY)
        }):Play()
        TweenService:Create(toast,       FADE_INFO, {BackgroundTransparency = 1}):Play()
        TweenService:Create(nameLabel,   FADE_INFO, {TextTransparency = 1}):Play()
        TweenService:Create(barTrack,    FADE_INFO, {BackgroundTransparency = 1}):Play()
        TweenService:Create(barFill,     FADE_INFO, {BackgroundTransparency = 1}):Play()
        local tw = TweenService:Create(statusLabel, FADE_INFO, {TextTransparency = 1})
        tw:Play()
        tw.Completed:Connect(function() pcall(function() shadow:Destroy() end) end)
    end)
end

local function Toggle(parent, name, desc, cb)
    local hasDesc = false
    local h = 32
    local card = Card(parent, h)
    local nameY = hasDesc and 6 or (h/2 - 7)
    local nameLbl = Lbl(card, name, 11, T.Text, Enum.Font.GothamBold)
    nameLbl.Size     = UDim2.new(1, -52, 0, 14)
    nameLbl.Position = UDim2.new(0, 10, 0, nameY)
    nameLbl.ZIndex   = 5
    if hasDesc then
        local d = Lbl(card, desc, 9, T.TextDim, Enum.Font.Gotham)
        d.Size     = UDim2.new(1, -52, 0, 11)
        d.Position = UDim2.new(0, 10, 0, nameY + 14)
        d.ZIndex   = 5
    end
    local track = Instance.new("Frame")
    track.Size             = UDim2.new(0, 30, 0, 16)
    track.Position         = UDim2.new(1, -38, 0.5, -8)
    track.BackgroundColor3 = T.Soft
    track.BorderSizePixel  = 0
    track.ZIndex           = 5
    track.Parent           = card
    trackBgFrame(track, "Soft")
    Corner(track, 8)
    local trackStroke = Stroke(track, T.Line, 1, 0)
    local activeFill = Instance.new("Frame")
    activeFill.Size                   = UDim2.new(1, 0, 1, 0)
    activeFill.BackgroundColor3       = T.Green
    activeFill.BackgroundTransparency = 1
    activeFill.BorderSizePixel        = 0
    activeFill.ZIndex                 = 6
    activeFill.Parent                 = track
    Corner(activeFill, 8)
    local knob = Instance.new("Frame")
    knob.Size             = UDim2.new(0, 12, 0, 12)
    knob.Position         = UDim2.new(0, 2, 0.5, -6)
    knob.BackgroundColor3 = T.TextMute
    knob.BorderSizePixel  = 0
    knob.ZIndex           = 7
    knob.Parent           = track
    Corner(knob, 6)
    local btn = Instance.new("TextButton")
    btn.Size                   = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text                   = ""
    btn.AutoButtonColor        = false
    btn.ZIndex                 = 8
    btn.Parent                 = card
    local on = false
    local cfgKey = "toggle:" .. name
    local function setState(state)
        on = state and true or false
        if on then
            if isMobile then
                knob.Position = UDim2.new(0, 16, 0.5, -6); knob.BackgroundColor3 = T.White
                activeFill.BackgroundTransparency = 0
                trackStroke.Color = T.Green; trackStroke.Transparency = 0.2
            else
                Tween(knob,        M, {Position = UDim2.new(0, 16, 0.5, -6), BackgroundColor3 = T.White})
                Tween(activeFill,  M, {BackgroundTransparency = 0})
                Tween(trackStroke, M, {Color = T.Green, Transparency = 0.2})
            end
        else
            if isMobile then
                knob.Position = UDim2.new(0, 2, 0.5, -6); knob.BackgroundColor3 = T.TextMute
                activeFill.BackgroundTransparency = 1
                trackStroke.Color = T.Line; trackStroke.Transparency = 0
            else
                Tween(knob,        M, {Position = UDim2.new(0, 2, 0.5, -6),  BackgroundColor3 = T.TextMute})
                Tween(activeFill,  M, {BackgroundTransparency = 1})
                Tween(trackStroke, M, {Color = T.Line,  Transparency = 0})
            end
        end
        Config.set(cfgKey, on)
        pcall(showToast, name, on)
        if cb then task.spawn(cb, on) end
    end
    local function doToggle() setState(not on) end
    btn.Activated:Connect(doToggle)
    if name ~= "Base ESP" then
        attachKeybind(btn, nameLbl, name, doToggle)
    end
    if Config.get(cfgKey, false) == true then
        task.defer(function() pcall(setState, true) end)
    end
    return { set = function(s) if (s and true or false) ~= on then setState(s) end end, get = function() return on end, card = card, btn = btn }
end
local function Button(parent, name, desc, cb, _h)
    local hasDesc = desc and desc ~= ""
    local h = _h or (hasDesc and 44 or 32)
    local card = Card(parent, h)
    local nameY = hasDesc and 6 or (h/2 - 7)
    local nameLbl = Lbl(card, name, 11, T.Text, Enum.Font.GothamBold, Enum.TextXAlignment.Center)
    nameLbl.Size     = UDim2.new(1, 0, 0, 14)
    nameLbl.Position = UDim2.new(0, 0, 0, nameY)
    nameLbl.ZIndex   = 5
    if hasDesc then
        local d = Lbl(card, desc, 9, T.TextDim, Enum.Font.Gotham, Enum.TextXAlignment.Center)
        d.Size     = UDim2.new(1, 0, 0, 11)
        d.Position = UDim2.new(0, 0, 0, nameY + 14)
        d.ZIndex   = 5
    end
    local btn = Instance.new("TextButton")
    btn.Size                   = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text                   = ""
    btn.AutoButtonColor        = false
    btn.ZIndex                 = 7
    btn.Parent                 = card
    local function press()
        Tween(card, F, {BackgroundColor3 = T.SideActive})
        task.delay(0.1, function()
            Tween(card, M, {BackgroundColor3 = T.Card})
        end)
        if cb then task.spawn(cb) end
    end
    btn.Activated:Connect(press)
    attachKeybind(btn, nameLbl, name, press)
end
local _SliderReg = _SliderReg or {}
local _activeSliderDrag = nil
UserInputService.InputChanged:Connect(function(inp)
    local s = _activeSliderDrag
    if not s then return end
    if inp.UserInputType ~= Enum.UserInputType.MouseMovement
    and inp.UserInputType ~= Enum.UserInputType.Touch then return end
    s.setFromX(inp.Position.X)
end)
local function Slider(parent, name, mn, mx, def, cb, step, onCommit)
    local card = Card(parent, 42)
    local v = def or mn
    local _step     = step or 1
    local _decimals = math.max(0, math.ceil(-math.log(math.max(_step, 1e-9)) / math.log(10)))
    local _fmt      = "%." .. _decimals .. "f"
    local nameLbl = Lbl(card, name, 11, T.Text, Enum.Font.GothamBold)
    nameLbl.Size     = UDim2.new(1, -52, 0, 12)
    nameLbl.Position = UDim2.new(0, 10, 0, 6)
    nameLbl.ZIndex   = 5
    local vBox = Instance.new("TextBox")
    vBox.Size                  = UDim2.new(0, 40, 0, 16)
    vBox.Position              = UDim2.new(1, -48, 0, 4)
    vBox.BackgroundColor3      = T.Soft
    trackBgFrame(vBox, "Soft")
    vBox.BorderSizePixel       = 0
    vBox.Text                  = string.format(_fmt, v)
    vBox.Font                  = Enum.Font.GothamBold
    vBox.TextSize              = 10
    vBox.TextColor3            = T.Text
    vBox.TextXAlignment        = Enum.TextXAlignment.Center
    vBox.ClearTextOnFocus      = false
    vBox.ZIndex                = 6
    vBox.Parent                = card
    Corner(vBox, 4)
    local vBoxStroke = GradStroke(vBox, 1, 0.3, 0)
    local trk = Instance.new("Frame")
    trk.Size             = UDim2.new(1, -20, 0, 4)
    trk.Position         = UDim2.new(0, 10, 0, 28)
    trk.BackgroundColor3 = T.Soft
    trk.BorderSizePixel  = 0
    trk.ZIndex           = 5
    trk.Parent           = card
    trackBgFrame(trk, "Soft")
    Corner(trk, 2)
    local frac = (v - mn) / math.max(1, mx - mn)
    local fill = Instance.new("Frame")
    fill.Size            = UDim2.new(frac, 0, 1, 0)
    fill.BorderSizePixel = 0
    fill.ZIndex          = 6
    fill.Parent          = trk
    Corner(fill, 2)
    trackSolid(fill, 1)
    local knob = Instance.new("Frame")
    knob.Size             = UDim2.new(0, 12, 0, 12)
    knob.AnchorPoint      = Vector2.new(0.5, 0.5)
    knob.Position         = UDim2.new(frac, 0, 0.5, 0)
    knob.BackgroundColor3 = T.White
    knob.BorderSizePixel  = 0
    knob.ZIndex           = 7
    knob.Parent           = trk
    Corner(knob, 6)
    Stroke(knob, T.White, 1.4, 0)
    local hit = Instance.new("TextButton")
    hit.Size                   = UDim2.new(1, 16, 0, 22)
    hit.Position               = UDim2.new(0, -8, 0.5, -11)
    hit.BackgroundTransparency = 1
    hit.Text                   = ""
    hit.AutoButtonColor        = false
    hit.ZIndex                 = 8
    hit.Parent                 = trk
    local cfgKey = "slider:" .. name
    local _entry
    local function setValue(n, fromBox, fromPeer)
        n = tonumber(string.format(_fmt, math.clamp(math.floor(n / _step + 0.5) * _step, mn, mx)))
        v = n
        local f = (v - mn) / math.max(1e-9, mx - mn)
        fill.Size     = UDim2.new(f, 0, 1, 0)
        knob.Position = UDim2.new(f, 0, 0.5, 0)
        if not fromBox then vBox.Text = string.format(_fmt, v) end
        if not fromPeer then
            Config.set(cfgKey, v)
            if cb then cb(v) end
            local reg = _SliderReg[cfgKey]
            if reg then
                for _, peer in ipairs(reg) do
                    if peer ~= _entry then peer.setVisualOnly(v) end
                end
            end
        end
    end
    _entry = { setVisualOnly = function(val) setValue(val, false, true) end }
    _SliderReg[cfgKey] = _SliderReg[cfgKey] or {}
    table.insert(_SliderReg[cfgKey], _entry)
    vBox.Focused:Connect(function() Tween(vBoxStroke, F, {Transparency = 0}) end)
    vBox.FocusLost:Connect(function()
        Tween(vBoxStroke, F, {Transparency = 0.3})
        local n = tonumber(vBox.Text)
        if n then setValue(n, true) end
        vBox.Text = string.format(_fmt, v)
        if onCommit then onCommit(v) end
        pcall(Config.flush)
    end)
    local function setFromX(px)
        local f = math.clamp((px - trk.AbsolutePosition.X) / math.max(1, trk.AbsoluteSize.X), 0, 1)
        setValue(mn + (mx - mn) * f)
    end
    local _dragHandle = { setFromX = setFromX }
    hit.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1
        or inp.UserInputType == Enum.UserInputType.Touch then
            _activeSliderDrag = _dragHandle
            setFromX(inp.Position.X)
            Tween(knob, F, {Size = UDim2.new(0, 14, 0, 14)})
        end
    end)
    hit.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1
        or inp.UserInputType == Enum.UserInputType.Touch then
            if _activeSliderDrag == _dragHandle then _activeSliderDrag = nil end
            Tween(knob, F, {Size = UDim2.new(0, 12, 0, 12)})
            if onCommit then onCommit(v) end
            pcall(Config.flush)
        end
    end)
    task.defer(function() pcall(setValue, Config.get(cfgKey, def or mn)) end)
    if onCommit then task.defer(function() if v ~= nil then pcall(onCommit, v) end end) end
    return { card = card, set = function(nv) pcall(setValue, nv) end }
end
local function Dropdown(parent, name, opts, cb, defaultOpt)
    local card = Card(parent, 32)
    card.ClipsDescendants = true
    local nameLbl = Lbl(card, name, 11, T.Text, Enum.Font.GothamBold)
    nameLbl.Size           = UDim2.new(1, -96, 1, 0)
    nameLbl.Position       = UDim2.new(0, 10, 0, 0)
    nameLbl.TextYAlignment = Enum.TextYAlignment.Center
    nameLbl.ZIndex         = 5
    local pick = Instance.new("Frame")
    pick.Size             = UDim2.new(0, 84, 0, 20)
    pick.Position         = UDim2.new(1, -92, 0.5, -10)
    pick.BackgroundColor3 = T.Soft
    pick.BorderSizePixel  = 0
    pick.ZIndex           = 5
    pick.Parent           = card
    trackBgFrame(pick, "Soft")
    Corner(pick, 4)
    GradStroke(pick, 1, 0.3, 0)
    local pLbl = Lbl(pick, opts[1] or "Select", 9, T.Text, Enum.Font.GothamMedium)
    pLbl.Size           = UDim2.new(1, -18, 1, 0)
    pLbl.Position       = UDim2.new(0, 8, 0, 0)
    pLbl.TextYAlignment = Enum.TextYAlignment.Center
    pLbl.ZIndex         = 6
    local arrow = Lbl(pick, "v", 9, T.Text, Enum.Font.GothamBold, Enum.TextXAlignment.Center)
    arrow.Size           = UDim2.new(0, 14, 1, 0)
    arrow.Position       = UDim2.new(1, -16, 0, 0)
    arrow.TextYAlignment = Enum.TextYAlignment.Center
    arrow.ZIndex         = 6
    local list = Instance.new("Frame")
    list.Size             = UDim2.new(1, -20, 0, 0)
    list.Position         = UDim2.new(0, 10, 0, 30)
    list.BackgroundColor3 = T.BgDeep
    list.BorderSizePixel  = 0
    list.ClipsDescendants = true
    list.ZIndex           = 6
    list.Parent           = card
    trackBgFrame(list, "BgDeep")
    Corner(list, 4)
    Stroke(list, T.Line, 1, 0.2)
    local ll = Instance.new("UIListLayout")
    ll.Padding = UDim.new(0, 2)
    ll.Parent  = list
    Pad(list, 4, 4, 4, 4)
    for _, o in ipairs(opts) do
        local r = Instance.new("TextButton")
        r.Size                   = UDim2.new(1, 0, 0, 18)
        r.BackgroundTransparency = 1
        r.Text                   = o
        r.TextSize               = 9
        r.Font                   = Enum.Font.GothamMedium
        r.TextColor3             = T.TextDim
        r.AutoButtonColor        = false
        r.ZIndex                 = 7
        r.Parent                 = list
        Corner(r, 3)
        r.MouseEnter:Connect(function() Tween(r, F, {BackgroundTransparency = 0, BackgroundColor3 = T.Card, TextColor3 = T.Text}) end)
        r.MouseLeave:Connect(function() Tween(r, F, {BackgroundTransparency = 1, TextColor3 = T.TextDim}) end)
        r.Activated:Connect(function()
            pLbl.Text = o
            Tween(card, M, {Size = UDim2.new(1, -8, 0, 32)})
            Tween(list, M, {Size = UDim2.new(1, -20, 0, 0)})
            arrow.Rotation = 0
            Config.set("dropdown:" .. name, o)
            if cb then task.spawn(cb, o) end
        end)
    end
    local open = false
    local btn = Instance.new("TextButton")
    btn.Size                   = UDim2.new(0, 84, 0, 20)
    btn.Position               = UDim2.new(1, -92, 0.5, -10)
    btn.BackgroundTransparency = 1
    btn.Text                   = ""
    btn.ZIndex                 = 8
    btn.Parent                 = card
    btn.Activated:Connect(function()
        open = not open
        if open then
            local h = 8 + (#opts * 20)
            Tween(card, M, {Size = UDim2.new(1, -8, 0, 32 + h + 2)})
            Tween(list, M, {Size = UDim2.new(1, -20, 0, h)})
            arrow.Rotation = 180
        else
            Tween(card, M, {Size = UDim2.new(1, -8, 0, 32)})
            Tween(list, M, {Size = UDim2.new(1, -20, 0, 0)})
            arrow.Rotation = 0
        end
    end)
    do
        local saved = Config.get("dropdown:" .. name, nil)
        local initial = saved or defaultOpt
        if initial then
            local found = false
            for _, o in ipairs(opts) do if o == initial then found = true; break end end
            if found then
                pLbl.Text = initial
                if cb then task.defer(function() pcall(cb, initial) end) end
            end
        end
    end
end
local function Input(parent, name, ph, default, cb)
    local card = Card(parent, 32)
    local nameLbl = Lbl(card, name, 11, T.Text, Enum.Font.GothamBold)
    nameLbl.Size           = UDim2.new(1, -120, 1, 0)
    nameLbl.Position       = UDim2.new(0, 10, 0, 0)
    nameLbl.TextYAlignment = Enum.TextYAlignment.Center
    nameLbl.ZIndex         = 5
    local box = Instance.new("TextBox")
    box.Size                  = UDim2.new(0, 108, 0, 20)
    box.Position              = UDim2.new(1, -116, 0.5, -10)
    box.BackgroundColor3      = T.Soft
    trackBgFrame(box, "Soft")
    box.BorderSizePixel       = 0
    box.Text                  = default or ""
    box.PlaceholderText       = ph or ""
    box.PlaceholderColor3     = T.TextMute
    box.Font                  = Enum.Font.GothamMedium
    box.TextSize              = 9
    box.TextColor3            = T.Text
    box.ClearTextOnFocus      = false
    box.ZIndex                = 5
    box.Parent                = card
    Corner(box, 4)
    Pad(box, 0, 0, 8, 8)
    local bs = GradStroke(box, 1, 0.3, 0)
    local cfgKey = "input:" .. name
    box.Focused:Connect(function() Tween(bs, F, {Transparency = 0}) end)
    box.FocusLost:Connect(function()
        Tween(bs, F, {Transparency = 0.3})
        Config.set(cfgKey, box.Text)
        if cb then task.spawn(cb, box.Text) end
    end)
    local saved = Config.get(cfgKey, nil)
    if saved ~= nil then box.Text = saved end
    if cb then task.spawn(cb, box.Text) end
end
local BrainrotESP = (function()
    local M = { enabled = false }
    function M.set(v) M.enabled = v and true or false end
    task.spawn(function()
        local ok, err = pcall(function()
            local cloneref = cloneref or function(o) return o end
            local RS        = cloneref(game:GetService("ReplicatedStorage"))
            local Workspace = cloneref(game:GetService("Workspace"))
            local Players   = cloneref(game:GetService("Players"))
            local player    = Players.LocalPlayer or Players.PlayerAdded:Wait()
            local Camera    = Workspace.CurrentCamera
            local plots     = Workspace:WaitForChild("Plots", 15)
            local Packages      = RS:WaitForChild("Packages", 15)
            if not plots or not Packages then return end
            local _plotsCache = plots:GetChildren()
            plots.ChildAdded:Connect(function(c) table.insert(_plotsCache, c) end)
            plots.ChildRemoved:Connect(function(c)
                for i = #_plotsCache, 1, -1 do
                    if _plotsCache[i] == c then table.remove(_plotsCache, i); break end
                end
            end)
            local function getPlotChildren() return _plotsCache end
            local function tryRequire(mod)
                if not mod then return nil end
                local ok, res = pcall(require, mod)
                return ok and res or nil
            end
            local AnimalsShared = tryRequire(RS:WaitForChild("Shared", 10):WaitForChild("Animals", 10))
            local AnimalsData   = tryRequire(RS:WaitForChild("Datas", 10):WaitForChild("Animals", 10))
            local NumberUtils   = tryRequire(RS:WaitForChild("Utils", 10):WaitForChild("NumberUtils", 10))
            if not AnimalsShared then
                AnimalsShared = { GetGeneration = function() return 0 end }
            end
            if not AnimalsData then
                AnimalsData = setmetatable({}, { __index = function() return {} end })
            end
            if not NumberUtils then
                NumberUtils = {
                    ToString = function(_, n)
                        if type(n) ~= "number" then return "0" end
                        if     n >= 1e12 then return string.format("%.1fT", n / 1e12)
                        elseif n >= 1e9  then return string.format("%.1fB", n / 1e9)
                        elseif n >= 1e6  then return string.format("%.1fM", n / 1e6)
                        elseif n >= 1e3  then return string.format("%.1fK", n / 1e3)
                        else return tostring(math.floor(n)) end
                    end
                }
            end
            local syncRemotes = (function()
                local folder = Packages:WaitForChild("Synchronizer")
                return {
                    channelFolder = folder:WaitForChild("Channel"),
                    routeRemote   = folder:WaitForChild("CommunicationRoute"),
                    requestData   = folder:FindFirstChild("RequestData"),
                }
            end)()
            local function getHRP()
                local c = player.Character
                return c and (c:FindFirstChild("HumanoidRootPart") or c:FindFirstChild("UpperTorso"))
            end
            local function getPlotOwner(plot)
                local sign  = plot:FindFirstChild("PlotSign")
                local frame = sign and sign:FindFirstChild("SurfaceGui") and sign.SurfaceGui:FindFirstChild("Frame")
                local label = frame and frame:FindFirstChild("TextLabel")
                if not label or label.Text == "Empty Base" then return nil end
                return label.Text:gsub("'s [Bb]ase$", ""):gsub("%s+$", "")
            end
            local function getEnemyPlots()
                local result, myName = {}, player.DisplayName
                for _, plot in ipairs(getPlotChildren()) do
                    local owner = getPlotOwner(plot)
                    if owner and owner ~= myName then table.insert(result, plot) end
                end
                return result
            end
            local function getPodiumPrompt(podium)
                local spawn  = podium:FindFirstChild("Base") and podium.Base:FindFirstChild("Spawn")
                local att    = spawn and spawn:FindFirstChild("PromptAttachment")
                local prompt = att and att:FindFirstChildWhichIsA("ProximityPrompt")
                return (prompt and prompt.ActionText == "Steal") and prompt or nil
            end
            local function getStealPromptForSlot(plot, slot)
                local podiums = plot and plot:FindFirstChild("AnimalPodiums")
                local podium  = podiums and slot ~= nil and podiums:FindFirstChild(tostring(slot))
                if not podium then return nil, nil, nil end
                local base = podium:FindFirstChild("Base")
                return getPodiumPrompt(podium), base or podium, podium
            end
            local function getPodiumWorldPart(animal)
                if not animal then return nil end
                if animal.base and animal.base.Parent then return animal.base end
                if animal.prompt and animal.prompt.Parent then
                    local current = animal.prompt.Parent
                    if current:IsA("Attachment") then current = current.Parent end
                    if current and current.Parent then return current end
                end
                if animal.model and animal.model.Parent then return animal.model end
                return nil
            end
            -- NEW METHOD: instead of subscribing to the Synchronizer channel diff
            -- stream (attach/detach listeners + apply per-packet diffs), we poll
            -- each enemy plot's data directly through the Synchronizer RequestData
            -- remote. It's far simpler, has no listener/diff state to drift out of
            -- sync, and always reflects the current server-side AnimalList.
            local _plotDataCache = {}
            local function fetchPlotData(plotName)
                if not syncRemotes.requestData then return nil end
                local okd, data = pcall(function()
                    return syncRemotes.requestData:InvokeServer(plotName)
                end)
                if okd and typeof(data) == "table" then
                    _plotDataCache[plotName] = data
                    return data
                end
                -- fall back to the last good snapshot if a request momentarily fails
                return _plotDataCache[plotName]
            end
            local function scanAllPlots()
                local result = {}
                for _, plot in ipairs(getEnemyPlots()) do
                    pcall(function()
                        local cache = fetchPlotData(plot.Name)
                        local animalList = cache and cache.AnimalList
                        if typeof(animalList) ~= "table" then return end
                        for slot, data in pairs(animalList) do
                            if typeof(data) == "table" and data.Index then
                                local prompt, base, model = getStealPromptForSlot(plot, slot)
                                if prompt and prompt.Parent then
                                    local info = AnimalsData[data.Index]
                                    local displayName = (info and info.DisplayName) or tostring(data.Index)
                                    local genValue = AnimalsShared:GetGeneration(data.Index, data.Mutation, data.Traits, nil)
                                    local genStr = "$" .. NumberUtils:ToString(genValue) .. "/s"
                                    local rarity = info and (info.Rarity or info.Tier or info.Type)
                                    if typeof(data.Traits) == "table" then
                                        for _, tr in pairs(data.Traits) do
                                            if tostring(tr):lower() == "og" then
                                                rarity = (rarity and rarity ~= "") and ("OG " .. rarity) or "OG"
                                                break
                                            end
                                        end
                                    end
                                    table.insert(result, {
                                        displayName = displayName,
                                        gen = genStr,
                                        rarity = rarity,
                                        line2 = (rarity and rarity ~= "") and (genStr .. "   " .. rarity) or genStr,
                                        num = genValue,
                                        position = prompt.Parent.WorldPosition,
                                        prompt = prompt, model = model, base = base,
                                    })
                                end
                            end
                        end
                    end)
                end
                table.sort(result, function(a, b) return a.num > b.num end)
                return result
            end
            local cachedBrainrots = {}
            task.spawn(function()
                while task.wait(1) do
                    if M.enabled then
                        pcall(function() cachedBrainrots = scanAllPlots() end)
                    end
                end
            end)

            local holder = _G._FH_ESP_GUI or GUI.Parent or GUI
            local function rarityColor(r)
                local s = r and tostring(r):lower() or ""
                if s:find("secret")       then return Color3.fromRGB(255,  80, 255) end
                if s:find("god")          then return Color3.fromRGB(255, 200,  60) end
                if s:find("og")           then return Color3.fromRGB( 80, 220, 255) end
                if s:find("mythic")       then return Color3.fromRGB(255,  90,  90) end
                if s:find("legendary")    then return Color3.fromRGB(255, 170,  40) end
                return Color3.fromRGB(255, 255, 255)
            end

            local RARITY_GRAD_SECRET = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 15, 15)),
            })
            local RARITY_GRAD_GOD = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 55, 55)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(60, 120, 255)),
            })
            local RARITY_GRAD_OG = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 200, 60)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 20, 20)),
            })
            local function rarityGradient(r)
                local s = r and tostring(r):lower() or ""
                if s:find("secret") then return RARITY_GRAD_SECRET end
                if s:find("god")    then return RARITY_GRAD_GOD end
                if s:find("og")     then return RARITY_GRAD_OG end
                return nil
            end
            local pool = {}
            local function mkLine(parent, y, h, size, color)
                local l = Instance.new("TextLabel")
                l.Size                   = UDim2.new(1, 0, 0, h)
                l.Position               = UDim2.new(0, 0, 0, y)
                l.BackgroundTransparency = 1
                l.Font                   = Enum.Font.GothamBold
                l.TextSize               = size
                l.Text                   = ""
                l.TextColor3             = color
                l.TextStrokeTransparency = 0
                l.TextStrokeColor3       = Color3.fromRGB(0, 0, 0)
                l.Parent                 = parent
                return l
            end
            local function getEntry(i)
                local e = pool[i]
                if e then return e end
                local bb = Instance.new("BillboardGui")
                bb.Name           = "BR_ESP"
                bb.Size           = UDim2.new(0, 140, 0, 42)
                bb.StudsOffset    = Vector3.new(0, 2.6, 0)
                bb.AlwaysOnTop    = true
                bb.LightInfluence = 0
                bb.MaxDistance    = math.huge
                bb.ClipsDescendants = false
                bb.Enabled        = false
                bb.Parent         = holder
                local nameLbl   = mkLine(bb, 0,  14, 13, Color3.fromRGB(255, 255, 255))
                local rarityLbl = mkLine(bb, 14, 14, 12, Color3.fromRGB(255, 255, 255))
                local rarityGrad = Instance.new("UIGradient")
                rarityGrad.Enabled = false
                rarityGrad.Parent  = rarityLbl
                local genLbl    = mkLine(bb, 28, 14, 12, Color3.fromRGB(110, 230, 140))
                e = { bb = bb, nameLbl = nameLbl, rarityLbl = rarityLbl, rarityGrad = rarityGrad, genLbl = genLbl }
                pool[i] = e
                return e
            end
            local _brAcc = 0
            RunService.Heartbeat:Connect(LPH_NO_VIRTUALIZE(function(dt)
                if _GEN ~= _G._FH_GAMMA_GEN then return end
                _brAcc = _brAcc + dt
                if _brAcc < (isMobile and 0.2 or 0.1) then return end
                _brAcc = 0
                if not M.enabled then
                    for _, e in ipairs(pool) do if e.bb.Enabled then e.bb.Enabled = false end end
                    return
                end
                local used = 0
                for _, a in ipairs(cachedBrainrots) do
                    local part = getPodiumWorldPart(a)
                    if part then
                        used = used + 1
                        local e = getEntry(used)
                        if e.bb.Adornee ~= part then e.bb.Adornee = part end
                        local nm = a.displayName or "Brainrot"
                        local rr = (a.rarity and a.rarity ~= "") and tostring(a.rarity) or ""
                        local gn = a.gen or ""
                        if e.nameLbl.Text   ~= nm then e.nameLbl.Text   = nm end
                        if e.rarityLbl.Text ~= rr then e.rarityLbl.Text = rr end
                        if e.genLbl.Text    ~= gn then e.genLbl.Text    = gn end
                        local grad = rarityGradient(rr)
                        if grad ~= e._lastGrad then
                            e._lastGrad = grad
                            if grad then
                                e.rarityGrad.Color   = grad
                                e.rarityGrad.Enabled = true
                                e.rarityLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
                            else
                                e.rarityGrad.Enabled = false
                                e.rarityLbl.TextColor3 = rarityColor(rr)
                            end
                        end
                        if not e.bb.Enabled then e.bb.Enabled = true end
                    end
                end
                for i = used + 1, #pool do
                    if pool[i].bb.Enabled then pool[i].bb.Enabled = false end
                end
            end))
        end)
    end)
    return M
end)()
local TimerESP = (function()
    local M = { enabled = false }
    function M.set(v) M.enabled = v and true or false end
    task.spawn(function()
        local ok, err = pcall(function()
            local cloneref = cloneref or function(o) return o end
            local Workspace = cloneref(game:GetService("Workspace"))
            local plots     = Workspace:FindFirstChild("Plots")
            while not plots do
                task.wait(0.5)
                if _GEN ~= _G._FH_GAMMA_GEN then return end
                plots = Workspace:FindFirstChild("Plots")
            end
            local holder    = _G._FH_ESP_GUI or GUI.Parent or GUI
            local _tPlotCache = plots:GetChildren()
            plots.ChildAdded:Connect(function(c) table.insert(_tPlotCache, c) end)
            plots.ChildRemoved:Connect(function(c)
                for i = #_tPlotCache, 1, -1 do if _tPlotCache[i] == c then table.remove(_tPlotCache, i); break end end
            end)
            local pool = {}
            local _timerLastSeq = nil
            local function getBoard(key, adornee)
                local e = pool[key]
                if not e then
                    local bb = Instance.new("BillboardGui")
                    bb.Name           = "TIMER_ESP"
                    bb.Size           = isMobile and UDim2.new(0, 84, 0, 21) or UDim2.new(0, 140, 0, 36)
                    bb.StudsOffset    = Vector3.new(0, 2.2, 0)
                    bb.AlwaysOnTop    = true
                    bb.LightInfluence = 0
                    bb.MaxDistance    = math.huge
                    bb.Enabled        = false
                    bb.Parent         = holder
                    local lbl = Instance.new("TextLabel")
                    lbl.Size                   = UDim2.new(1, 0, 1, 0)
                    lbl.BackgroundTransparency = 1
                    lbl.Font                   = Enum.Font.GothamBold
                    lbl.TextSize               = isMobile and 12 or 22
                    lbl.Text                   = ""
                    lbl.TextColor3             = Color3.fromRGB(255, 255, 255)
                    lbl.TextStrokeTransparency = 0.4
                    lbl.Parent                 = bb
                    local grad = Instance.new("UIGradient")
                    grad.Rotation = 0
                    grad.Parent   = lbl
                    e = { bb = bb, lbl = lbl, grad = grad, used = false }
                    pool[key] = e
                end
                e.bb.Adornee = adornee
                return e
            end
            local _pbAcc = 0
            RunService.Heartbeat:Connect(LPH_NO_VIRTUALIZE(function(dt)
                if _GEN ~= _G._FH_GAMMA_GEN then return end
                _pbAcc = _pbAcc + dt
                if _pbAcc < 0.1 then return end
                _pbAcc = 0
                local seq    = _sharedFlowSeq
                local seqNew = seq ~= _timerLastSeq
                if seqNew then _timerLastSeq = seq end
                for _, e in pairs(pool) do e.used = false end
                if M.enabled then
                    for _, plot in ipairs(_tPlotCache) do
                        for _, d in ipairs(plot:GetDescendants()) do
                            if d.Name == "RemainingTime" and (d:IsA("TextLabel") or d:IsA("TextBox")) then
                                local txt = (d.ContentText ~= "" and d.ContentText) or (d.Text ~= "" and d.Text) or nil
                                if txt then
                                    local anchor = d.Parent
                                    while anchor and not anchor:IsA("BasePart") do
                                        anchor = anchor.Parent
                                        if anchor == plot or anchor == nil then break end
                                    end
                                    if not (anchor and anchor:IsA("BasePart")) then
                                        local m = d:FindFirstAncestorOfClass("Model")
                                        anchor = m and (m.PrimaryPart or m:FindFirstChildWhichIsA("BasePart", true)) or nil
                                    end
                                    if anchor and anchor:IsA("BasePart") then
                                        -- Key by the timer label itself so a board stays stable
                                        -- (no index reshuffle/flicker if text briefly empties).
                                        local e = getBoard(d, anchor)
                                        if e.lbl.Text ~= txt then e.lbl.Text = txt end
                                        if seqNew and seq then e.grad.Color = seq end
                                        e.bb.Enabled = true
                                        e.used = true
                                    end
                                end
                            end
                        end
                    end
                end
                for key, e in pairs(pool) do
                    if not e.used then
                        if e.bb.Enabled then e.bb.Enabled = false end
                        -- Drop boards whose timer label no longer exists (streamed out / destroyed).
                        if typeof(key) == "Instance" and key.Parent == nil then
                            pcall(function() e.bb:Destroy() end)
                            pool[key] = nil
                        end
                    end
                end
            end))
        end)
    end)
    return M
end)()
_G._FH_REG_TimerESP = TimerESP
local PlayerESP = (function()
    local M = { enabled = false }
    function M.set(v) M.enabled = v and true or false end
    task.spawn(function()
        local ok, err = pcall(function()
            local cloneref     = cloneref or function(o) return o end
            local Players      = cloneref(game:GetService("Players"))
            local localPlayer  = Players.LocalPlayer or Players.PlayerAdded:Wait()
            local holder       = _G._FH_ESP_GUI or GUI.Parent or GUI

            local AP_IMAGE_ID = "rbxassetid://122740865547249"
            local FC_IMAGE_ID = "rbxassetid://139402154602449"
            local ATTR_REFRESH = 1
            local attrCache = {}

            local function checkAttributes(plr)
                local hasAdmin, hasCarpet = false, false
                local function check(obj)
                    if not obj then return end
                    if obj:GetAttribute("AdminCommands")   == true then hasAdmin  = true end
                    if obj:GetAttribute("HasFlyingCarpet") == true then hasCarpet = true end
                end
                check(plr)
                local char = plr.Character
                if char then
                    check(char)
                    check(char:FindFirstChild("HumanoidRootPart"))
                    check(char:FindFirstChild("Humanoid"))
                    check(char:FindFirstChild("Head"))
                end
                return hasAdmin, hasCarpet
            end

            local function getRebirths(plr)
                local ok2, val = pcall(function()
                    return plr.leaderstats.Rebirths.Value
                end)
                return ok2 and val or nil
            end

            local function nameText(plr)
                return string.format("%s (@%s)", plr.DisplayName, plr.Name)
            end
            local objs = {}
            local function describeState(hum)
                if not hum then return "" end
                local st = hum:GetState()
                if st == Enum.HumanoidStateType.Jumping then return "jumping" end
                if st == Enum.HumanoidStateType.Freefall then return "falling" end
                if st == Enum.HumanoidStateType.Climbing then return "climbing" end
                if st == Enum.HumanoidStateType.Seated then return "sitting" end
                if st == Enum.HumanoidStateType.Swimming then return "swimming" end
                if st == Enum.HumanoidStateType.Dead or st == Enum.HumanoidStateType.PlatformStanding then return "ragdolled" end
                if hum.MoveDirection.Magnitude > 0.1 then return "moving" end
                return "idle"
            end
            local function bindChar(e, plr, char)
                if not char then return end
                local function scan()
                    local tool
                    for _, c in ipairs(char:GetChildren()) do
                        if c:IsA("Tool") then tool = c.Name; break end
                    end
                    if tool ~= e.currentTool then
                        local now = tick()
                        if tool then
                            e.lastEvent = "equipped " .. tool
                        elseif e.currentTool then
                            e.lastEvent = "unequipped " .. e.currentTool
                        end
                        e.lastEventAt = now
                        e.currentTool = tool
                    end
                end
                scan()
                char.ChildAdded:Connect(function(c) if c:IsA("Tool") then scan() end end)
                char.ChildRemoved:Connect(function(c) if c:IsA("Tool") then scan() end end)
            end
            local function build(plr)
                local e = objs[plr]
                if e then return e end
                local hl = Instance.new("Highlight")
                hl.FillColor          = Theme.c1
                hl.FillTransparency   = 0.55
                hl.OutlineColor       = Color3.fromRGB(255, 255, 255)
                hl.OutlineTransparency = 0
                hl.DepthMode          = Enum.HighlightDepthMode.AlwaysOnTop
                hl.Enabled            = false
                hl.Parent             = holder
                local bb = Instance.new("BillboardGui")
                bb.Name           = "PLR_ESP"
                bb.Size           = UDim2.new(0, 260, 0, 110)
                bb.StudsOffset    = Vector3.new(0, 3.5, 0)
                bb.AlwaysOnTop    = true
                bb.LightInfluence = 0
                bb.MaxDistance    = math.huge
                bb.Enabled        = false
                bb.Parent         = holder
                local lbl = Instance.new("TextLabel")
                lbl.Size                   = UDim2.new(1, 0, 0, 20)
                lbl.Position               = UDim2.new(0, 0, 0, 0)
                lbl.BackgroundTransparency = 1
                lbl.Font                   = Enum.Font.ArialBold
                lbl.TextSize               = 14
                lbl.Text                   = ""
                lbl.TextColor3             = Color3.fromRGB(255, 255, 255)
                lbl.TextStrokeTransparency = 0.4
                lbl.TextXAlignment         = Enum.TextXAlignment.Center
                lbl.Parent                 = bb
                local grad = Instance.new("UIGradient")
                grad.Rotation = 0
                grad.Parent   = lbl
                local eqLbl = Instance.new("TextLabel")
                eqLbl.Size                   = UDim2.new(1, 0, 0, 16)
                eqLbl.Position               = UDim2.new(0, 0, 0, 42)
                eqLbl.BackgroundTransparency = 1
                eqLbl.Font                   = Enum.Font.GothamMedium
                eqLbl.TextSize               = 11
                eqLbl.Text                   = ""
                eqLbl.TextColor3             = Color3.fromRGB(255, 220, 50)
                eqLbl.TextStrokeTransparency = 0.5
                eqLbl.TextXAlignment         = Enum.TextXAlignment.Center
                eqLbl.Parent                 = bb
                local infoLbl = Instance.new("TextLabel")
                infoLbl.Size                   = UDim2.new(1, 0, 0, 40)
                infoLbl.Position               = UDim2.new(0, 0, 0, 58)
                infoLbl.BackgroundTransparency = 1
                infoLbl.Font                   = Enum.Font.GothamMedium
                infoLbl.TextSize               = 10
                infoLbl.Text                   = ""
                infoLbl.TextColor3             = Color3.fromRGB(255, 220, 50)
                infoLbl.RichText               = true
                infoLbl.TextStrokeTransparency = 0.4
                infoLbl.TextXAlignment         = Enum.TextXAlignment.Center
                infoLbl.TextYAlignment         = Enum.TextYAlignment.Top
                infoLbl.Parent                 = bb
                local apIcon = Instance.new("ImageLabel")
                apIcon.BackgroundTransparency = 1
                apIcon.Image                  = AP_IMAGE_ID
                apIcon.Size                   = UDim2.new(0, 36, 0, 36)
                apIcon.Position               = UDim2.new(0, 210, 0, 4)
                apIcon.ScaleType              = Enum.ScaleType.Fit
                apIcon.Visible                = false
                apIcon.Parent                 = bb
                local fcIcon = Instance.new("ImageLabel")
                fcIcon.BackgroundTransparency = 1
                fcIcon.Image                  = FC_IMAGE_ID
                fcIcon.Size                   = UDim2.new(0, 36, 0, 36)
                fcIcon.Position               = UDim2.new(0, 210, 0, 46)
                fcIcon.ScaleType              = Enum.ScaleType.Fit
                fcIcon.Visible                = false
                fcIcon.Parent                 = bb

                e = { hl = hl, bb = bb, lbl = lbl, grad = grad, eqLbl = eqLbl,
                      infoLbl = infoLbl, apIcon = apIcon, fcIcon = fcIcon,
                      chamsFolder = nil, chamsMap = {},
                      currentTool = nil, lastEvent = nil, lastEventAt = 0,
                      hasAdmin = false, hasCarpet = false, lastAttrCheck = 0 }
                objs[plr] = e
                if plr.Character then bindChar(e, plr, plr.Character) end
                plr.CharacterAdded:Connect(function(c) bindChar(e, plr, c) end)
                return e
            end
            local function clear(plr)
                local e = objs[plr]
                if e then
                    e.hl:Destroy(); e.bb:Destroy()
                    if e.chamsFolder then pcall(function() e.chamsFolder:Destroy() end) end
                    objs[plr] = nil
                end
            end
            Players.PlayerRemoving:Connect(clear)

            local function buildChams(e, char)
                if e.chamsFolder then
                    pcall(function() e.chamsFolder:Destroy() end)
                end
                e.chamsFolder = nil
                e.chamsMap = {}
            end

            local _CB_TRUE  = '<font color="#00ff66">True</font>'
            local _CB_FALSE = '<font color="#ff4444">False</font>'
            local function colorBool(v)
                return (v == true or v == "True") and _CB_TRUE or _CB_FALSE
            end

            local _plrCache = {}
            local function _rebuildPlrCache()
                _plrCache = {}
                for _, p in ipairs(Players:GetPlayers()) do
                    if p ~= localPlayer then table.insert(_plrCache, p) end
                end
            end
            _rebuildPlrCache()
            Players.PlayerAdded:Connect(function(p)
                if p ~= localPlayer then table.insert(_plrCache, p) end
            end)
            Players.PlayerRemoving:Connect(function(p)
                for i = #_plrCache, 1, -1 do
                    if _plrCache[i] == p then table.remove(_plrCache, i); break end
                end
            end)

            local _slowAcc  = 0

            local _fastAcc  = 0

            local _lastGradSeq = nil

            local _espAcc = 0
            RunService.Heartbeat:Connect(LPH_NO_VIRTUALIZE(function(dt)
                if _GEN ~= _G._FH_GAMMA_GEN then return end
                _espAcc  = _espAcc  + dt
                _slowAcc = _slowAcc + dt
                _fastAcc = _fastAcc + dt
                if _espAcc < (isMobile and 0.1 or 0.05) then return end
                _espAcc = 0

                local seq    = _sharedFlowSeq
                local seqNew = seq ~= _lastGradSeq
                if seqNew then _lastGradSeq = seq end

                local now        = tick()
                local doSlow     = _slowAcc >= 1.0
                local doFast     = _fastAcc >= 0.1
                if doSlow then _slowAcc = 0 end
                if doFast then _fastAcc = 0 end

                local enabled = M.enabled
                for i = 1, #_plrCache do
                    local plr  = _plrCache[i]
                    local char = plr.Character
                    local head = char and char:FindFirstChild("Head")
                    if enabled and char and head then
                        local e = build(plr)

                        if e.hl.Adornee ~= char then e.hl.Adornee = char end
                        if not e.hl.Enabled then
                            e.hl.FillColor = Theme.c1
                            e.hl.Enabled   = true
                        end

                        if e.bb.Adornee ~= head then e.bb.Adornee = head end
                        if not e.bb.Enabled then e.bb.Enabled = true end

                        if doSlow then
                            e.hasAdmin, e.hasCarpet = checkAttributes(plr)
                            e.lastAttrCheck         = now
                            e.cachedRebirths        = getRebirths(plr)
                            local txt = nameText(plr)
                            if e.lbl.Text ~= txt then e.lbl.Text = txt end

                            local rebStr = e.cachedRebirths ~= nil and tostring(e.cachedRebirths) or "?"
                            local info = "AP: " .. colorBool(e.hasAdmin) ..
                                         " | CARPET: " .. colorBool(e.hasCarpet) ..
                                         " | FLASH: " .. colorBool(e.cachedRebirths == 18)
                            if e.infoLbl.Text ~= info then e.infoLbl.Text = info end
                            local av = e.hasAdmin
                            if e.apIcon.Visible ~= av then e.apIcon.Visible = av end
                            local cv = e.hasCarpet
                            if e.fcIcon.Visible ~= cv then e.fcIcon.Visible = cv end
                        end

                        if doFast then
                            local hum    = char:FindFirstChildWhichIsA("Humanoid")
                            local action = describeState(hum)
                            local stealing = plr:GetAttribute("Stealing")
                            if stealing then action = "STEALING" end
                            local rebStr = (e.cachedRebirths ~= nil) and tostring(e.cachedRebirths) or "?"
                            local held   = e.currentTool and ("holds " .. e.currentTool) or "empty hands"
                            local recent = (e.lastEvent and (now - e.lastEventAt) < 2.5) and e.lastEvent or nil
                            local sub    = recent or (held .. "  |  " .. action .. "  |  Rebirths: " .. rebStr)
                            if e.eqLbl.Text ~= sub then e.eqLbl.Text = sub end
                        end

                        if seqNew and seq then
                            e.grad.Color = seq
                        end

                    elseif objs[plr] then
                        local e2 = objs[plr]
                        if e2.hl.Enabled then e2.hl.Enabled = false end
                        if e2.bb.Enabled then e2.bb.Enabled = false end
                    end
                end
            end))
        end)
    end)
    return M
end)()
_G._FH_REG_PlayerESP = PlayerESP

local FriendESP = (function()
    local M = { enabled = false, names = {} }
    function M.set(v) M.enabled = v and true or false end
    function M.setNames(raw)
        M.names = {}
        for part in raw:gmatch("[^,]+") do
            local trimmed = part:match("^%s*(.-)%s*$")
            if #trimmed > 0 then
                M.names[trimmed:lower()] = true
            end
        end
    end
    task.spawn(function()

        local saved = Config.get("friendesp_names", nil)
        if saved and #saved > 0 then M.setNames(saved) end
        local ok, err = pcall(function()
            local cloneref    = cloneref or function(o) return o end
            local Players     = cloneref(game:GetService("Players"))
            local localPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()
            local holder      = _G._FH_ESP_GUI or GUI.Parent or GUI

            local FRIEND_GREEN    = Color3.fromRGB(60, 230, 100)
            local FRIEND_OUTLINE  = Color3.fromRGB(180, 255, 180)

            local objs = {}

            local function build(plr)
                local e = objs[plr]
                if e then return e end

                local hl = Instance.new("Highlight")
                hl.FillColor           = FRIEND_GREEN
                hl.FillTransparency    = 0.45
                hl.OutlineColor        = FRIEND_OUTLINE
                hl.OutlineTransparency = 0
                hl.DepthMode           = Enum.HighlightDepthMode.AlwaysOnTop
                hl.Enabled             = false
                hl.Parent              = holder

                local bb = Instance.new("BillboardGui")
                bb.Name           = "FRIEND_ESP"
                bb.Size           = UDim2.new(0, 160, 0, 44)
                bb.StudsOffset    = Vector3.new(0, 3.2, 0)
                bb.AlwaysOnTop    = true
                bb.LightInfluence = 0
                bb.MaxDistance    = math.huge
                bb.Enabled        = false
                bb.Parent         = holder

                local friendLbl = Instance.new("TextLabel")
                friendLbl.Size                   = UDim2.new(1, 0, 0, 20)
                friendLbl.Position               = UDim2.new(0, 0, 0, 0)
                friendLbl.BackgroundTransparency = 1
                friendLbl.Font                   = Enum.Font.GothamBold
                friendLbl.TextSize               = 15
                friendLbl.Text                   = "Friend"
                friendLbl.TextColor3             = FRIEND_GREEN
                friendLbl.TextStrokeTransparency = 0.2
                friendLbl.TextXAlignment         = Enum.TextXAlignment.Center
                friendLbl.Parent                 = bb

                local nameLbl = Instance.new("TextLabel")
                nameLbl.Size                   = UDim2.new(1, 0, 0, 16)
                nameLbl.Position               = UDim2.new(0, 0, 0, 22)
                nameLbl.BackgroundTransparency = 1
                nameLbl.Font                   = Enum.Font.GothamMedium
                nameLbl.TextSize               = 11
                nameLbl.Text                   = plr.Name
                nameLbl.TextColor3             = Color3.fromRGB(230, 255, 230)
                nameLbl.TextStrokeTransparency = 0.4
                nameLbl.TextXAlignment         = Enum.TextXAlignment.Center
                nameLbl.Parent                 = bb

                e = { hl = hl, bb = bb, friendLbl = friendLbl, nameLbl = nameLbl }
                objs[plr] = e
                return e
            end

            local function clear(plr)
                local e = objs[plr]
                if e then
                    pcall(function() e.hl:Destroy() end)
                    pcall(function() e.bb:Destroy() end)
                    objs[plr] = nil
                end
            end
            Players.PlayerRemoving:Connect(clear)

            local _plrCache = {}
            local function rebuildCache()
                _plrCache = {}
                for _, p in ipairs(Players:GetPlayers()) do
                    if p ~= localPlayer then table.insert(_plrCache, p) end
                end
            end
            rebuildCache()
            Players.PlayerAdded:Connect(function(p)
                if p ~= localPlayer then table.insert(_plrCache, p) end
            end)
            Players.PlayerRemoving:Connect(function(p)
                for i = #_plrCache, 1, -1 do
                    if _plrCache[i] == p then table.remove(_plrCache, i); break end
                end
            end)

            local _acc = 0
            RunService.Heartbeat:Connect(LPH_NO_VIRTUALIZE(function(dt)
                if _GEN ~= _G._FH_GAMMA_GEN then return end
                _acc = _acc + dt
                if _acc < 0.05 then return end
                _acc = 0
                for i = 1, #_plrCache do
                    local plr  = _plrCache[i]
                    local char = plr.Character
                    local head = char and char:FindFirstChild("Head")
                    local isFriend = M.enabled
                        and (M.names[plr.Name:lower()] or M.names[plr.DisplayName:lower()])
                    if isFriend and char and head then
                        local e = build(plr)
                        if e.hl.Adornee ~= char then e.hl.Adornee = char end
                        if not e.hl.Enabled then e.hl.Enabled = true end
                        if e.bb.Adornee ~= head then e.bb.Adornee = head end
                        if not e.bb.Enabled then e.bb.Enabled = true end
                        if e.nameLbl.Text ~= plr.Name then e.nameLbl.Text = plr.Name end
                    elseif objs[plr] then
                        local e2 = objs[plr]
                        if e2.hl.Enabled then e2.hl.Enabled = false end
                        if e2.bb.Enabled then e2.bb.Enabled = false end
                    end
                end
            end))
        end)
    end)
    return M
end)()
_G._FH_REG_FriendESP = FriendESP
local FriendPanelESP = (function()
    local M = { enabled = false }
    function M.set(v) M.enabled = v and true or false end
    task.spawn(function()
        local ok, err = pcall(function()
            local cloneref = cloneref or function(o) return o end
            local Workspace = cloneref(game:GetService("Workspace"))
            local plots     = Workspace:WaitForChild("Plots", 15)
            if not plots then return end
            local holder    = _G._FH_ESP_GUI or GUI.Parent or GUI
            local _fpPlotCache = plots:GetChildren()
            plots.ChildAdded:Connect(function(c) table.insert(_fpPlotCache, c) end)
            plots.ChildRemoved:Connect(function(c)
                for i = #_fpPlotCache, 1, -1 do if _fpPlotCache[i] == c then table.remove(_fpPlotCache, i); break end end
            end)
            local UNALLOWED_IMG = "rbxassetid://110783679426495"
            local pool = {}
            local function getBoard(key, adornee)
                local e = pool[key]
                if not e then
                    local bb = Instance.new("BillboardGui")
                    bb.Name           = "FP_ESP"
                    local sz = isMobile and 22 or 36
                    bb.Size           = UDim2.new(0, sz, 0, sz)
                    bb.StudsOffset    = Vector3.new(0, 2.4, 0)
                    bb.AlwaysOnTop    = true
                    bb.LightInfluence = 0
                    bb.MaxDistance    = math.huge
                    bb.Enabled        = false
                    bb.Parent         = holder
                    local lbl = Instance.new("TextLabel")
                    lbl.Size                   = UDim2.new(1, 0, 1, 0)
                    lbl.BackgroundColor3       = Color3.fromRGB(0, 0, 0)
                    lbl.BackgroundTransparency = 0
                    lbl.Font                   = Enum.Font.GothamBold
                    lbl.TextSize               = isMobile and 16 or 26
                    lbl.Text                   = ""
                    lbl.TextColor3             = Color3.fromRGB(255, 255, 255)
                    lbl.TextStrokeTransparency = 0.4
                    lbl.Parent                 = bb
                    local corner = Instance.new("UICorner")
                    corner.CornerRadius = UDim.new(1, 0)
                    corner.Parent = lbl
                    local stroke = Instance.new("UIStroke")
                    stroke.Thickness = 1.5
                    stroke.Color = Color3.fromRGB(0, 0, 0)
                    stroke.Parent = lbl
                    lbl.Font = Enum.Font.SourceSansBold
                    lbl.TextSize = isMobile and 20 or 32
                    e = { bb = bb, lbl = lbl, used = false }
                    pool[key] = e
                end
                e.bb.Adornee = adornee
                return e
            end
            local GREEN = Color3.fromRGB(60, 230, 110)
            local RED   = Color3.fromRGB(240, 60, 60)
            local _fpAcc = 0
            RunService.Heartbeat:Connect(LPH_NO_VIRTUALIZE(function(dt)
                if _GEN ~= _G._FH_GAMMA_GEN then return end
                _fpAcc = _fpAcc + dt
                if _fpAcc < 0.1 then return end
                _fpAcc = 0
                for _, e in pairs(pool) do e.used = false end
                if M.enabled then
                    for _, plot in ipairs(_fpPlotCache) do
                        local panel = plot:FindFirstChild("FriendPanel")
                        if panel then
                            local part = (panel:IsA("BasePart") and panel)
                                or panel.PrimaryPart
                                or panel:FindFirstChildWhichIsA("BasePart", true)
                            if part then
                                local main = panel:FindFirstChild("Main")
                                local img  = main and main:FindFirstChild("SurfaceGui") and main.SurfaceGui:FindFirstChild("ImageLabel")
                                local unallowed = img and img.Image == UNALLOWED_IMG
                                local e = getBoard(plot.Name, part)
                                local txt = unallowed and "X" or "✓"
                                if e.lbl.Text ~= txt then e.lbl.Text = txt end
                                e.lbl.TextColor3 = unallowed and RED or GREEN
                                e.lbl.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                                e.bb.Enabled = true
                                e.used = true
                            end
                        end
                    end
                end
                for _, e in pairs(pool) do
                    if not e.used and e.bb.Enabled then e.bb.Enabled = false end
                end
            end))
        end)
    end)
    return M
end)()
_G._FH_REG_FriendPanelESP = FriendPanelESP
local NextBaseESP = { set = function() end }
if false then
    task.spawn(function()
        local ok, err = pcall(function()
            local cloneref  = cloneref or function(o) return o end
            local Workspace = cloneref(game:GetService("Workspace"))
            local plots     = Workspace:WaitForChild("Plots", 15)
            if not plots then return end
            local holder = _G._FH_ESP_GUI or GUI.Parent or GUI

            local _nbPlotCache = plots:GetChildren()
            plots.ChildAdded:Connect(function(c) table.insert(_nbPlotCache, c) end)
            plots.ChildRemoved:Connect(function(c)
                for i = #_nbPlotCache, 1, -1 do if _nbPlotCache[i] == c then table.remove(_nbPlotCache, i); break end end
            end)

            local RED = Color3.fromRGB(255, 50, 50)

            local hl = Instance.new("Highlight")
            hl.FillColor           = RED
            hl.FillTransparency    = 0.45
            hl.OutlineColor        = RED
            hl.OutlineTransparency = 0
            hl.DepthMode           = Enum.HighlightDepthMode.AlwaysOnTop
            hl.Enabled             = false
            hl.Parent              = holder

            local bb = Instance.new("BillboardGui")
            bb.Name           = "NB_ESP"
            bb.Size           = UDim2.new(0, 200, 0, 40)
            bb.StudsOffset    = Vector3.new(0, 6, 0)
            bb.AlwaysOnTop    = true
            bb.LightInfluence = 0
            bb.MaxDistance    = math.huge
            bb.Enabled        = false
            bb.Parent         = holder

            local lbl = Instance.new("TextLabel")
            lbl.Size                   = UDim2.new(1, 0, 1, 0)
            lbl.BackgroundTransparency = 1
            lbl.Font                   = Enum.Font.GothamBold
            lbl.TextSize               = 20
            lbl.Text                   = "\226\172\135 Next Base"
            lbl.TextColor3             = RED
            lbl.TextStrokeTransparency = 0.3
            lbl.TextStrokeColor3       = Color3.fromRGB(0, 0, 0)
            lbl.TextXAlignment         = Enum.TextXAlignment.Center
            lbl.Parent                 = bb

            local function isPlotEmpty(plot)
                local sign  = plot:FindFirstChild("PlotSign")
                if not sign then return true end
                local sg    = sign:FindFirstChild("SurfaceGui")
                local frame = sg and sg:FindFirstChild("Frame")
                local label = frame and frame:FindFirstChild("TextLabel")
                if not label then return true end
                return label.Text == "Empty Base"
            end

            local function getPlotAnchor(plot)
                local sign = plot:FindFirstChild("PlotSign")
                if sign and sign:IsA("BasePart") then return sign end
                if plot:IsA("Model") and plot.PrimaryPart then return plot.PrimaryPart end
                return plot:FindFirstChildWhichIsA("BasePart", true)
            end

            local function getPlayerPlot(player)
                for _, plot in ipairs(_nbPlotCache) do
                    local sign  = plot:FindFirstChild("PlotSign")
                    if sign then
                        local sg    = sign:FindFirstChild("SurfaceGui")
                        local frame = sg and sg:FindFirstChild("Frame")
                        local label = frame and frame:FindFirstChild("TextLabel")
                        if label and (label.Text == player.DisplayName or label.Text == player.Name) then
                            return plot
                        end
                    end
                end
                return nil
            end

            local _PLOT_ORDER = {
                ["874610d0-0f3d-4abf-b87f-21eced418ce4"] = 1,
                ["9affe21d-6fe7-4136-b1cf-cc5d6714952d"] = 2,
                ["d289bf7b-b8f7-4f63-8ec6-fbae789e3b38"] = 3,
                ["7b8fad28-4cfa-45bb-b10c-fe67ecbbeb98"] = 4,
                ["8eddc312-2fe7-45b6-97e7-b4250d09ec3a"] = 5,
                ["660cc8c9-421c-42a6-83a4-3c04878231de"] = 6,
                ["fd85a3bf-8788-4398-b8fe-be197c4514c9"] = 7,
                ["e82582ec-7048-4348-89db-8c3f5205227f"] = 8,
            }
            local function getPlotNumber(plot)
                local p = _PLOT_ORDER[plot.Name]
                if p then return p end
                local n = tonumber(plot.Name:match("%d+$"))
                return n or math.huge
            end

            local _freedQueue = {}

            Players.PlayerRemoving:Connect(function(player)
                local plot = getPlayerPlot(player)
                if plot then
                    table.insert(_freedQueue, plot)
                end
            end)

            Players.PlayerAdded:Connect(function()

                while #_freedQueue > 0 and not isPlotEmpty(_freedQueue[1]) do
                    table.remove(_freedQueue, 1)
                end
                if #_freedQueue > 0 then
                    table.remove(_freedQueue, 1)
                end
            end)

            local _nbAcc = 0
            RunService.Heartbeat:Connect(LPH_NO_VIRTUALIZE(function(dt)
                if _GEN ~= _G._FH_GAMMA_GEN then return end
                _nbAcc = _nbAcc + dt
                if _nbAcc < 0.5 then return end
                _nbAcc = 0

                if not M.enabled then
                    if hl.Enabled then hl.Enabled = false end
                    if bb.Enabled then bb.Enabled = false end
                    return
                end

                local nextPlot = nil
                local bestNum = math.huge
                for _, plot in ipairs(_nbPlotCache) do
                    if isPlotEmpty(plot) then
                        local num = getPlotNumber(plot)
                        if num < bestNum then
                            bestNum  = num
                            nextPlot = plot
                        end
                    end
                end

                if nextPlot then
                    if hl.Adornee ~= nextPlot then hl.Adornee = nextPlot end
                    if not hl.Enabled then hl.Enabled = true end
                    local anchor = getPlotAnchor(nextPlot)
                    if anchor then
                        if bb.Adornee ~= anchor then bb.Adornee = anchor end
                        if not bb.Enabled then bb.Enabled = true end
                    end
                else
                    if hl.Enabled then hl.Enabled = false end
                    if bb.Enabled then bb.Enabled = false end
                end
            end))
        end)
        if err then warn("[NextBaseESP]", err) end
    end)
end
local Booster = (function()
    local M = {
        enabled     = false,
        userEnabled = false,
        speed       = Config.get("booster_spd", 29),
        jump        = Config.get("booster_jmp", 50),
    }
    function M.setSpeed(n) M.speed = tonumber(n) or M.speed; Config.set("booster_spd", M.speed) end
    function M.setJump(n)  M.jump  = tonumber(n) or M.jump;  Config.set("booster_jmp", M.jump)  end

    local _boostConn = nil
    local _jumpConn  = nil

    local function detach()
        if _boostConn then _boostConn:Disconnect(); _boostConn = nil end
        if _jumpConn  then _jumpConn:Disconnect();  _jumpConn  = nil end
    end

    local function attach()
        detach()
        local player = Players.LocalPlayer or Players.PlayerAdded:Wait()

        _jumpConn = UserInputService.JumpRequest:Connect(function()
            if _GEN ~= _G._FH_GAMMA_GEN then return end
            if not M.enabled then return end
            local char = player.Character
            if not char then return end
            local hrp = char:FindFirstChild("HumanoidRootPart")
            local hum = char:FindFirstChildOfClass("Humanoid")
            if not (hrp and hum) then return end
            if hum.FloorMaterial == Enum.Material.Air then return end
            hrp.Velocity = Vector3.new(hrp.Velocity.X, M.jump, hrp.Velocity.Z)
        end)

        _boostConn = RunService.Heartbeat:Connect(function()
            if _GEN ~= _G._FH_GAMMA_GEN then return end
            if not M.enabled then return end
            local char = player.Character
            if not char then return end
            local hrp = char:FindFirstChild("HumanoidRootPart")
            local hum = char:FindFirstChildOfClass("Humanoid")
            if not (hrp and hum) then return end
            local moveDir = hum.MoveDirection
            if moveDir.Magnitude > 0 then
                local vel = hrp.Velocity
                hrp.Velocity = Vector3.new(
                    moveDir.X * M.speed,
                    vel.Y,
                    moveDir.Z * M.speed
                )
            end
        end)
    end

    local _attached = false
    local _suspends = {}

    local function applyState()
        local shouldBeOn = M.userEnabled and not next(_suspends)
        if shouldBeOn then
            M.enabled = true
            if not _attached then
                _attached = true
                task.spawn(function() pcall(attach) end)
            end
        else
            M.enabled = false
            if _attached then
                _attached = false
                detach()
            end
        end
    end

    function M.set(v)
        M.userEnabled = v and true or false
        Config.set("booster_on", M.userEnabled)
        applyState()
    end
    function M.suspend(name)
        _suspends[name or "default"] = true
        applyState()
    end
    function M.unsuspend(name)
        _suspends[name or "default"] = nil
        applyState()
    end

    do
        local player = Players.LocalPlayer or Players.PlayerAdded:Wait()
        player.CharacterAdded:Connect(function()
            if _GEN ~= _G._FH_GAMMA_GEN then return end
            _suspends = {}
            _attached = false
            detach()
            applyState()
        end)
    end

    task.spawn(function()
        while true do
            task.wait(1)
            if _GEN == _G._FH_GAMMA_GEN then applyState() end
        end
    end)

    return M
end)()
local InfiniteJump = (function()
    local UIS     = game:GetService("UserInputService")
    local Players = game:GetService("Players")
    local Player  = Players.LocalPlayer or Players.PlayerAdded:Wait()
    local M = {
        enabled       = false,
        jumpConn      = nil,
        fallConn      = nil,
        holdConn      = nil,
        holdBeginConn = nil,
        holdEndConn   = nil,
    }
    local JUMP_FORCE       = 50
    local CLAMP_FALL_SPEED = 50
    local HOLD_INTERVAL    = 0.18

    local HOLD_CLIMB       = 45
    local function attach()
        if M.jumpConn then return end
        local _fallAcc = 0
        M.fallConn = RunService.Heartbeat:Connect(LPH_NO_VIRTUALIZE(function(dt)
            _fallAcc = _fallAcc + dt
            if _fallAcc < (1/60) then return end
            _fallAcc = 0
            if not M.enabled then return end
            local char = Player.Character
            if not char then return end
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then
                local vel = hrp.Velocity
                if vel.Y < -CLAMP_FALL_SPEED then
                    hrp.Velocity = Vector3.new(vel.X, -CLAMP_FALL_SPEED, vel.Z)
                end
            end
        end))
        M.jumpConn = UIS.JumpRequest:Connect(function()
            if not M.enabled then return end
            local char = Player.Character
            if not char then return end
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.Velocity = Vector3.new(hrp.Velocity.X, JUMP_FORCE, hrp.Velocity.Z)
            end
        end)
        local jumpHeld   = false
        local jumpHoldCd = 0
        M.holdBeginConn = UIS.InputBegan:Connect(function(inp, gpe)
            if gpe then return end
            if inp.KeyCode == Enum.KeyCode.Space then
                jumpHeld = true
            end
        end)
        M.holdEndConn = UIS.InputEnded:Connect(function(inp)
            if inp.KeyCode == Enum.KeyCode.Space then
                jumpHeld = false
            end
        end)
        M.holdConn = RunService.Heartbeat:Connect(LPH_NO_VIRTUALIZE(function()
            if not M.enabled then return end
            if not jumpHeld then return end
            if not UIS:IsKeyDown(Enum.KeyCode.Space) then
                jumpHeld = false
                return
            end
            local char = Player.Character
            if not char then return end
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then

                local vel = hrp.Velocity
                if vel.Y < HOLD_CLIMB then
                    hrp.Velocity = Vector3.new(vel.X, HOLD_CLIMB, vel.Z)
                end
            end
        end))
    end
    local function detach()
        for _, k in ipairs({"jumpConn", "fallConn", "holdConn", "holdBeginConn", "holdEndConn"}) do
            if M[k] then M[k]:Disconnect(); M[k] = nil end
        end
    end
    function M.set(v)
        M.enabled = v and true or false
        if M.enabled then attach() else detach() end
    end
    return M
end)()
local antiragconn1, antiragdollrocketconn
local antiragInnerConns = {}
local Actions = (function()
    local cloneref        = cloneref or function(o) return o end
    local Players         = cloneref(game:GetService("Players"))
    local TeleportService = cloneref(game:GetService("TeleportService"))
    local player          = Players.LocalPlayer
    local A = {}
    local resetRemote = nil
    local RESET_GUID  = "f888ee6e-c86d-46e1-93d7-0639d6635d42"
    pcall(function()
        if type(hookfunction) == "function" then
            local _orig
            local _probe = Instance.new("RemoteEvent")
            local _restored = false
            local function restore()
                if _restored or not _orig then return end
                _restored = true
                pcall(function() hookfunction(_probe.FireServer, _orig) end)
            end
            _orig = hookfunction(_probe.FireServer, newcclosure(function(self, ...)
                if not resetRemote
                    and typeof(self) == "Instance"
                    and self:IsA("RemoteEvent")
                    and tostring(self.Name):sub(1, 3) == "RE/" then
                    resetRemote = self
                    task.defer(restore)
                end
                return _orig(self, ...)
            end))

            task.delay(12, restore)
            pcall(function() _probe:Destroy() end)
        end
    end)
    function A.kick()
        task.spawn(function()
            pcall(function()
                local GuiService = game:GetService("GuiService")
                local RunService = game:GetService("RunService")
                pcall(function() GuiService.SelectedCoreObject = nil end)
                for _ = 1, 3 do RunService.RenderStepped:Wait() end
                game:Shutdown()
            end)
        end)
    end
    function A.rejoin()
        task.spawn(function() pcall(function() TeleportService:Teleport(game.PlaceId, player) end) end)
        pcall(function() player:Kick("rejoining") end)
    end
    local resetting = false
    function A.reset()
        if not player then return end
        if resetting then return end
        resetting = true
        local oldChar = player.Character
        task.spawn(function()
            local deadline = tick() + 8
            while player.Character == oldChar and tick() < deadline do
                if not resetRemote then break end
                pcall(function() resetRemote:FireServer(RESET_GUID, player, "balloon") end)
                task.wait(0.15)
            end
            resetting = false
        end)
    end
    local _cmdCache, _profCache = {}, {}
    local function cacheActivated(guiObject)
        local cached = {}
        local ok, conns = pcall(getconnections, guiObject.Activated)
        if ok and type(conns) == "table" then
            for _, conn in ipairs(conns) do
                if type(conn.Function) == "function" then
                    table.insert(cached, conn.Function)
                end
            end
        end
        return cached
    end
    local function fireActivated(cached)
        for _, fn in ipairs(cached) do task.spawn(fn) end
    end
    local function getAdminFrames()
        if not player then return nil, nil end
        local pg = player:FindFirstChild("PlayerGui")
        local ap = pg and pg:FindFirstChild("AdminPanel")
        local panel = ap and ap:FindFirstChild("AdminPanel")
        local content  = panel and panel:FindFirstChild("Content")
        local profiles = panel and panel:FindFirstChild("Profiles")
        if not content or not profiles then return nil, nil end
        return content:FindFirstChild("ScrollingFrame"), profiles:FindFirstChild("ScrollingFrame")
    end
    function A.ragdollSelf()
        -- Fire ragdoll on yourself through the mapped admin remote.
        if _G._FH_FireAdmin and _G._FH_FireAdmin(player, "ragdoll") then return end
        -- Fallback (only if the remote couldn't be resolved): click the buttons.
        if type(getconnections) ~= "function" then return end
        local commandFrame, profileFrame = getAdminFrames()
        if not commandFrame or not profileFrame then return end
        local pName = player.Name
        local profileBtn = profileFrame:FindFirstChild(pName)
        local ragdollBtn = commandFrame:FindFirstChild("ragdoll")
        if not profileBtn or not ragdollBtn then return end
        if not _profCache[pName]    then _profCache[pName]    = cacheActivated(profileBtn) end
        if not _cmdCache["ragdoll"] then _cmdCache["ragdoll"] = cacheActivated(ragdollBtn) end
        fireActivated(_cmdCache["ragdoll"])
        task.wait()
        fireActivated(_profCache[pName])
    end
    return A
end)()
local FovController = (function()
    local cloneref  = cloneref or function(o) return o end
    local Workspace = cloneref(game:GetService("Workspace"))
    local Players   = cloneref(game:GetService("Players"))
    local value = 70
    local M = {}
    local _fovConn = nil

    local function getMobileScale()
        if not isMobile then return 1 end
        local vp = Workspace.CurrentCamera and Workspace.CurrentCamera.ViewportSize
        if not vp then return 0.7 end
        local short = math.min(vp.X, vp.Y)
        if short < 400 then return 0.55
        elseif short < 600 then return 0.65
        elseif short < 800 then return 0.75
        else return 0.85 end
    end

    M.set = function(v)
        pcall(function()
            value = tonumber(v) or value
            if _fovConn then return end
            local _fovAcc = 0
            local _fovEvent = isMobile and RunService.Heartbeat or RunService.RenderStepped
            _fovConn = _fovEvent:Connect(LPH_NO_VIRTUALIZE(function(dt)
                local ok = pcall(function()
                    if isMobile then
                        _fovAcc = _fovAcc + dt
                        if _fovAcc < 0.1 then return end
                        _fovAcc = 0
                    end
                    local cam = Workspace.CurrentCamera
                    if not cam then return end
                    local target = value
                    if isMobile then
                        target = math.floor(value * getMobileScale())
                    end
                    if math.abs(cam.FieldOfView - target) > 0.05 then
                        cam.FieldOfView = target
                    end
                    if isMobile then
                        local lp = Players.LocalPlayer
                        if lp then
                            local zoomDist = math.max(target * 2.2, 10)
                            pcall(function()
                                if lp.CameraMinZoomDistance > 0 then
                                    lp.CameraMinZoomDistance = 0
                                end
                            end)
                            pcall(function()
                                if lp.CameraMaxZoomDistance < zoomDist then
                                    lp.CameraMaxZoomDistance = zoomDist
                                end
                            end)
                        end
                    end
                end)
                if not ok then return end
            end))
        end)
    end
    return M
end)()

local CloneESP = (function()
    local cloneref  = cloneref or function(o) return o end
    local Players   = cloneref(game:GetService("Players"))
    local Workspace = cloneref(game:GetService("Workspace"))
    local enabled = false
    local conns = {}
    local switched = false
    local labels = {}
    local function getPlayerFromClone(clone)
        if not clone:IsA("Model") then return nil end
        local hum = clone:FindFirstChildOfClass("Humanoid")
        if not hum then return nil end
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr.Character and plr.Character:FindFirstChildOfClass("Humanoid") then
                local ch = plr.Character:FindFirstChildOfClass("Humanoid")
                if ch.DisplayName == hum.DisplayName then return plr end
            end
        end
        return nil
    end
    local function highlightClone(clone)
        local existing = clone:FindFirstChild("CloneHighlight")
        if existing then existing:Destroy() end
        local head = clone:FindFirstChild("Head")
        if labels[clone] then pcall(function() labels[clone]:Destroy() end); labels[clone] = nil end
        local plr = getPlayerFromClone(clone)
        local hl = Instance.new("Highlight")
        hl.Name = "CloneHighlight"
        hl.FillColor = Color3.fromRGB(255, 0, 0)
        hl.OutlineColor = Color3.fromRGB(0, 0, 0)
        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        hl.FillTransparency = 0.4
        hl.OutlineTransparency = 0
        hl.Parent = clone
        if head then
            local hum = clone:FindFirstChildOfClass("Humanoid")
            local dn = hum and hum.DisplayName or ""
            local pn = ""
            if plr then
                pn = plr.Name
                if dn == "" then dn = plr.DisplayName end
            end
            local who = pn ~= "" and pn or (dn ~= "" and dn or "?")
            local tag = string.format("sab %s's clone", who)
            local bb = Instance.new("BillboardGui")
            bb.Name = "CloneLabel"
            bb.Size = UDim2.new(0, 240, 0, 40)
            bb.StudsOffset = Vector3.new(0, 3, 0)
            bb.AlwaysOnTop = true
            bb.LightInfluence = 0
            bb.MaxDistance = 0
            bb.ClipsDescendants = false
            bb.Adornee = head
            local pg = Players.LocalPlayer and Players.LocalPlayer:FindFirstChildOfClass("PlayerGui")
            bb.Parent = pg or head
            local lbl = Instance.new("TextLabel")
            lbl.Size = UDim2.new(1, 0, 1, 0)
            lbl.BackgroundTransparency = 1
            lbl.Text = tag
            lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
            lbl.TextSize = 15
            lbl.Font = Enum.Font.GothamBold
            lbl.TextStrokeTransparency = 0
            lbl.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
            lbl.Parent = bb
            labels[clone] = bb
        end
    end
    local function clearAll()
        for clone, bb in pairs(labels) do
            pcall(function() bb:Destroy() end)
            labels[clone] = nil
        end
        for _, obj in ipairs(Workspace:GetChildren()) do
            if obj:IsA("Model") and obj.Name:find("_Clone") then
                local hl = obj:FindFirstChild("CloneHighlight")
                if hl then hl:Destroy() end
            end
        end
    end
    local function rescan()
        if not enabled then return end
        for _, obj in ipairs(Workspace:GetChildren()) do
            if obj:IsA("Model") and obj.Name:find("_Clone")
               and not obj:FindFirstChild("CloneHighlight") then
                pcall(highlightClone, obj)
            end
        end
    end
    task.spawn(function()
        local had = false
        while task.wait(0.5) do
            if not enabled then
                had = false
            else
                local lp = Players.LocalPlayer
                if lp then
                    local needle = lp.Name .. "_Clone"
                    local has = false
                    for _, obj in ipairs(Workspace:GetChildren()) do
                        if obj:IsA("Model") and obj.Name == needle then has = true; break end
                    end
                    if had and not has then
                        switched = true
                        task.delay(30, function() switched = false end)
                        rescan()
                    end
                    had = has
                end
            end
        end
    end)
    local function start()
        clearAll()
        conns.added = Workspace.ChildAdded:Connect(function(child)
            if enabled and child:IsA("Model") and child.Name:find("_Clone") then
                task.wait(0.1); highlightClone(child)
            end
        end)
        local acc = 0
        conns.hb = RunService.Heartbeat:Connect(LPH_NO_VIRTUALIZE(function(dt)
            if not enabled then return end
            acc = acc + dt
            if acc < 0.5 then return end
            acc = 0
            for _, obj in ipairs(Workspace:GetChildren()) do
                if obj:IsA("Model") and obj.Name:find("_Clone")
                   and not obj:FindFirstChild("CloneHighlight") then
                    highlightClone(obj)
                end
            end
        end))
    end
    local function stop()
        for _, c in pairs(conns) do if c then c:Disconnect() end end
        conns = {}
        clearAll()
    end
    local M = {}
    function M.set(on)
        enabled = on
        if on then start() else stop() end
    end
    return M
end)()
_G._FH_REG_CloneESP = CloneESP
local AntiBee = (function()
    local cloneref  = cloneref or function(o) return o end
    local Players   = cloneref(game:GetService("Players"))
    local Lighting  = cloneref(game:GetService("Lighting"))
    local D = {
        running = false,
        connections = {},
        originalMoveFunction = nil,
        controlsProtected = false,
        badLightingNames = { Blue = true, DiscoEffect = true, BeeBlur = true, ColorCorrection = true },
    }
    local function nuke(obj)
        if not obj or not obj.Parent then return end
        if D.badLightingNames[obj.Name] then pcall(function() obj:Destroy() end) end
    end
    local function disconnectAll()
        for _, c in ipairs(D.connections) do
            if typeof(c) == "RBXScriptConnection" then c:Disconnect() end
        end
        D.connections = {}
    end
    local function protectControls()
        if D.controlsProtected then return end
        pcall(function()
            local lp = Players.LocalPlayer
            local PlayerModule = lp.PlayerScripts:FindFirstChild("PlayerModule")
            if not PlayerModule then return end
            local Controls = require(PlayerModule):GetControls()
            if not Controls then return end
            if not D.originalMoveFunction then
                D.originalMoveFunction = Controls.moveFunction
            end
            local function protectedMove(...)
                if D.originalMoveFunction then
                    return D.originalMoveFunction(...)
                end
            end
            local acc = 0
            table.insert(D.connections, RunService.Heartbeat:Connect(LPH_NO_VIRTUALIZE(function(dt)
                if not D.running then return end
                acc = acc + dt
                if acc < (isMobile and 0.1 or 0.05) then return end
                acc = 0
                if Controls.moveFunction ~= protectedMove then Controls.moveFunction = protectedMove end
            end)))
            Controls.moveFunction = protectedMove
            D.controlsProtected = true
        end)
    end
    local function restoreControls()
        if not D.controlsProtected then return end
        pcall(function()
            local lp = Players.LocalPlayer
            local PlayerModule = lp.PlayerScripts:FindFirstChild("PlayerModule")
            if not PlayerModule then return end
            local Controls = require(PlayerModule):GetControls()
            if Controls and D.originalMoveFunction then
                Controls.moveFunction = D.originalMoveFunction
                D.controlsProtected = false
            end
        end)
    end
    local _cachedBeeSound = nil
    local function blockBuzz()
        pcall(function()
            if not _cachedBeeSound or not _cachedBeeSound.Parent then
                local lp = Players.LocalPlayer
                local beeScript = lp.PlayerScripts:FindFirstChild("Bee", true)
                _cachedBeeSound = beeScript and beeScript:FindFirstChild("Buzzing")
            end
            local b = _cachedBeeSound
            if b and b:IsA("Sound") then b:Stop(); b.Volume = 0 end
        end)
    end

    local INVERSE_ATTR_NAMES = { "Inverse", "inverse", "Inverted", "inverted",
                                  "InverseControls", "FlipControls", "ReverseControls",
                                  "IsInverted", "isInverted", "ControlsInverted",
                                  "InvertMovement", "FlipMovement", "Reversed",
                                  "reversed", "flipcontrols", "reversecontrols" }
    local function clearInverseAttrs(obj)
        if not obj or not obj.Parent then return end
        pcall(function()
            for _, aName in ipairs(INVERSE_ATTR_NAMES) do
                if obj:GetAttribute(aName) ~= nil then
                    obj:SetAttribute(aName, nil)
                end
            end
        end)
    end
    local function killInverseScripts(parent)
        if not parent then return end
        pcall(function()
            local stack, si = { parent }, 1
            local visited = 0
            while si > 0 do
                local cur = stack[si]; stack[si] = nil; si = si - 1
                local ch = cur:GetChildren()
                for i = 1, #ch do
                    local child = ch[i]
                    if child:IsA("LocalScript") or child:IsA("Script") then
                        local low = child.Name:lower()
                        if low:find("inverse") or low:find("invert") or low:find("flipcontrol") then
                            pcall(function() child.Disabled = true end)
                            pcall(function() child:Destroy() end)
                        end
                    end
                    si = si + 1; stack[si] = child
                end
                visited = visited + 1
                if visited % 60 == 0 then task.wait() end
            end
        end)
    end
    local function blockInverse()
        pcall(function()
            local lp = Players.LocalPlayer
            local char = lp.Character
            if char then
                clearInverseAttrs(char)
                local hrp = char:FindFirstChild("HumanoidRootPart")
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hrp then clearInverseAttrs(hrp) end
                if hum then clearInverseAttrs(hum) end
                killInverseScripts(char)
            end
            killInverseScripts(lp.PlayerScripts)
            local pg = lp:FindFirstChildOfClass("PlayerGui")
            if pg then killInverseScripts(pg) end
        end)
    end
    local M = {}
    function M.set(on)
        if on then
            if D.running then return end
            D.running = true
            for _, inst in ipairs(_deepChildren(Lighting)) do nuke(inst) end
            table.insert(D.connections, Lighting.DescendantAdded:Connect(function(o)
                if D.running then nuke(o) end
            end))
            protectControls()
            blockInverse()
            local acc = 0
            local accInv = 0
            table.insert(D.connections, RunService.Heartbeat:Connect(LPH_NO_VIRTUALIZE(function(dt)
                if not D.running then return end
                acc    = acc    + dt
                accInv = accInv + dt
                if acc >= 0.25 then acc = 0; blockBuzz() end
                if accInv >= 0.25 then
                    accInv = 0
                    pcall(function()
                        local lp   = Players.LocalPlayer
                        local char = lp and lp.Character
                        if not char then return end
                        local hrp  = char:FindFirstChild("HumanoidRootPart")
                        local hum  = char:FindFirstChildOfClass("Humanoid")
                        clearInverseAttrs(lp)
                        clearInverseAttrs(char)
                        if hrp then clearInverseAttrs(hrp) end
                        if hum then clearInverseAttrs(hum) end
                        local cam = workspace.CurrentCamera
                        if cam then
                            local _cx, _cy, _cz = cam.CFrame:ToOrientation()
                            if math.abs(_cx) > math.pi * 0.5 + 0.1 then
                                cam.CFrame = CFrame.new(cam.CFrame.Position)
                                    * CFrame.fromOrientation(0, _cy, 0)
                            end
                        end
                    end)
                end
            end)))
            local function watchInverseAdds(parent)
                if not parent then return end
                pcall(function()
                    table.insert(D.connections, parent.DescendantAdded:Connect(function(desc)
                        if not D.running then return end
                        clearInverseAttrs(desc)
                        local low = desc.Name:lower()
                        if (low:find("inverse") or low:find("invert") or low:find("flipcontrol"))
                        and (desc:IsA("LocalScript") or desc:IsA("Script")) then
                            pcall(function() desc.Disabled = true end)
                            pcall(function() desc:Destroy() end)
                        end
                    end))
                end)
            end
            local lp2 = Players.LocalPlayer
            if lp2 then
                table.insert(D.connections, lp2.CharacterAdded:Connect(function(c)
                    task.wait(0.05)
                    if not D.running then return end
                    blockInverse()
                    watchInverseAdds(c)
                end))
                watchInverseAdds(lp2)
                if lp2.Character then watchInverseAdds(lp2.Character) end
                watchInverseAdds(lp2.PlayerScripts)
                pcall(function() watchInverseAdds(lp2:FindFirstChildOfClass("PlayerGui")) end)
                table.insert(D.connections, lp2.ChildAdded:Connect(function(ch)
                    if ch:IsA("PlayerGui") then watchInverseAdds(ch) end
                end))
            end
        else
            if not D.running then return end
            D.running = false
            restoreControls()
            disconnectAll()
        end
    end
    return M
end)()
local HideAdmin = (function()
    local Players          = game:GetService("Players")
    local UserInputService = game:GetService("UserInputService")
    local player    = Players.LocalPlayer
    if not player then return { set = function() end } end
    local playerGui = player:WaitForChild("PlayerGui")
    local originalText    = "Trade Machine"
    local replacementText = "Currently not available in your region"
    local enabled     = false
    local adminHidden = false
    local textObjects   = {}
    local promptObjects = {}
    local function checkObject(v)
        if v:IsA("TextLabel") or v:IsA("TextButton") or v:IsA("TextBox") then
            local txt = string.lower(v.Text)
            if v.Text == originalText or v.Text == replacementText then
                table.insert(textObjects, v)
            end
            if txt == "receive trades from" then
                local parent = v.Parent
                if parent then parent.Visible = false end
            end

        end
        if v:IsA("ImageButton") or v:IsA("ImageLabel") then

        end
        if v:IsA("ProximityPrompt") then
            if v.ObjectText == originalText or v.ActionText == originalText then
                table.insert(promptObjects, v)
            end
        end
    end
    task.spawn(function()
        local all = game:GetDescendants()
        for i, v in ipairs(all) do
            checkObject(v)
            if i % 250 == 0 then task.wait() end
        end
    end)
    game.DescendantAdded:Connect(function(v)

        if not (v:IsA("TextLabel") or v:IsA("TextButton") or v:IsA("TextBox")
             or v:IsA("ProximityPrompt") or v:IsA("ImageLabel") or v:IsA("ImageButton")) then
            return
        end
        checkObject(v)
    end)
    local function applyChanges()
        for _, v in ipairs(textObjects) do
            if v and v.Parent then
                v.Text = enabled and replacementText or originalText
                v.TextColor3 = enabled and Color3.fromRGB(255, 70, 95) or Color3.fromRGB(255, 255, 255)
            end
        end
        for _, v in ipairs(promptObjects) do
            if v and v.Parent then v.Enabled = not enabled end
        end
    end
    local function setAdminHidden(v)
        _G._FH_HideAdminBusy = _G._FH_HideAdminBusy or false
        if _G._FH_HideAdminBusy then return end
        _G._FH_HideAdminBusy = true
        task.spawn(function()
            local function resolveLeft()
                local ok, left = pcall(function()
                    return game.Players.LocalPlayer.PlayerGui.TopbarStandard.Holders.Left
                end)
                if ok then return left end
            end
            local ref = _G._FH_HiddenAdminPanel
            if not (ref and ref.Parent) and not _G._FH_HiddenAdminPanelParent then
                local left = resolveLeft()
                if left then
                    local child = left:GetChildren()[4]
                    if child then
                        _G._FH_HiddenAdminPanel = child
                        _G._FH_HiddenAdminPanelParent = left
                        ref = child
                    end
                end
            end
            local parentRef = _G._FH_HiddenAdminPanelParent or resolveLeft()
            if v then
                if ref and ref.Parent then
                    pcall(function() ref.Parent = nil end)
                end
            else
                if ref and parentRef and ref.Parent ~= parentRef then
                    pcall(function() ref.Parent = parentRef end)
                end
            end
            _G._FH_HideAdminBusy = false
        end)
    end
    local M = {}
    function M.set(on)
        enabled = on
        setAdminHidden(on)
        applyChanges()
    end
    return M
end)()
local TradeRegionBlock = (function()
    local Players     = game:GetService("Players")
    local RunService  = game:GetService("RunService")
    local lp          = Players.LocalPlayer
    if not lp then return { set = function() end } end
    local playerGui   = lp:FindFirstChildOfClass("PlayerGui") or lp:WaitForChild("PlayerGui", 5)
    local enabled     = false
    local activeOverlays = {}
    local listConn    = nil

    local UNAVAIL_TEXT = "\240\159\148\146 Unavailable"
    local NOTE_TEXT    = "Trading isn't available in your region. (Err: TRADE_REGION_LOCK)"
    local BADGE_TEXT   = "\240\159\148\146 Region Locked"
    local WARN_TEXT    = "Trading is currently unavailable in your region."

    local function findLabel(btn)
        if btn:IsA("TextButton") or btn:IsA("TextLabel") then return btn end
        return btn:FindFirstChildWhichIsA("TextLabel", true)
    end

    local function dimColor(c)
        local h, s, v = Color3.toHSV(c)
        return Color3.fromHSV(h, s * 0.15, math.min(v * 0.55, 0.32))
    end

    local _lpBadge = nil

    local function getLpFrame(list)
        local myName  = lp.Name
        local myDisp  = lp.DisplayName
        for _, child in ipairs(list:GetChildren()) do
            if child:IsA("GuiObject") then
                local lbl = child:FindFirstChildWhichIsA("TextLabel")
                if lbl and (lbl.Text == myName or lbl.Text == myDisp) then return child end
                local nested = child:FindFirstChildWhichIsA("TextLabel", true)
                if nested and (nested.Text == myName or nested.Text == myDisp) then return child end
            end
        end
        return nil
    end

    local function buildLpBadge(lpFrame)
        if _lpBadge and _lpBadge.Parent == lpFrame then return end
        if _lpBadge then pcall(function() _lpBadge:Destroy() end) end
        _lpBadge = Instance.new("TextLabel")
        _lpBadge.Name                  = "RegionLockBadge"
        _lpBadge.Size                  = UDim2.new(0, 116, 0, 18)
        _lpBadge.Position              = UDim2.new(1, 4, 0.5, -9)
        _lpBadge.BackgroundColor3      = Color3.fromRGB(42, 45, 54)
        _lpBadge.BackgroundTransparency = 0.15
        _lpBadge.Text                  = BADGE_TEXT
        _lpBadge.TextSize              = 10
        _lpBadge.TextColor3            = Color3.fromRGB(190, 194, 205)
        _lpBadge.Font                  = Enum.Font.GothamMedium
        _lpBadge.TextXAlignment        = Enum.TextXAlignment.Center
        _lpBadge.ZIndex                = lpFrame.ZIndex + 10
        _lpBadge.Parent                = lpFrame
        Corner(_lpBadge, 4)
        Stroke(_lpBadge, Color3.fromRGB(70, 74, 86), 0.8, 0.25)
    end

    local function removeLpBadge()
        if _lpBadge then pcall(function() _lpBadge:Destroy() end); _lpBadge = nil end
    end

    local function buildOverlay(playerFrame, sendBtn)
        if activeOverlays[playerFrame] then return end
        local lblObj = findLabel(sendBtn)
        local origColor = sendBtn.BackgroundColor3
        local data = {
            sendBtn           = sendBtn,
            originalColor     = origColor,
            originalAuto      = sendBtn.AutoButtonColor,
            originalActive    = sendBtn.Active,
            lblObj            = lblObj,
            originalText      = lblObj and lblObj.Text or nil,
            originalTextColor = lblObj and lblObj.TextColor3 or nil,
        }
        local dimmed = dimColor(origColor)
        pcall(function()
            sendBtn.AutoButtonColor  = false
            sendBtn.Active           = false
            sendBtn.BackgroundColor3 = dimmed
        end)
        if lblObj then
            pcall(function()
                lblObj.Text       = UNAVAIL_TEXT
                lblObj.TextColor3 = Color3.fromRGB(160, 160, 170)
            end)
        end

        local blocker = Instance.new("TextButton")
        blocker.Size                  = UDim2.new(1, 0, 1, 0)
        blocker.BackgroundTransparency = 1
        blocker.Text                  = ""
        blocker.ZIndex                = sendBtn.ZIndex + 50
        blocker.Active                = true
        blocker.AutoButtonColor       = false
        blocker.Parent                = sendBtn
        blocker.MouseButton1Click:Connect(function() end)
        data.blocker = blocker

        local note = Instance.new("TextLabel")
        note.Name                  = "RegionNote"
        note.AnchorPoint           = Vector2.new(0.5, 0)
        note.Position              = UDim2.new(0.5, 0, 1, 2)
        note.Size                  = UDim2.new(1, -4, 0, 12)
        note.BackgroundTransparency = 1
        note.Text                  = NOTE_TEXT
        note.Font                  = Enum.Font.Gotham
        note.TextSize              = 10
        note.TextColor3            = Color3.fromRGB(140, 140, 150)
        note.TextTransparency      = 0.25
        note.TextXAlignment        = Enum.TextXAlignment.Center
        note.TextTruncate          = Enum.TextTruncate.AtEnd
        note.ZIndex                = playerFrame.ZIndex + 5
        note.Parent                = playerFrame
        data.note = note
        activeOverlays[playerFrame] = data
    end

    local function removeOverlay(playerFrame)
        local data = activeOverlays[playerFrame]
        if not data then return end
        pcall(function()
            data.sendBtn.BackgroundColor3 = data.originalColor
            data.sendBtn.Active           = data.originalActive
            data.sendBtn.AutoButtonColor  = data.originalAuto
        end)
        if data.lblObj and data.originalText ~= nil then
            pcall(function()
                data.lblObj.Text       = data.originalText
                data.lblObj.TextColor3 = data.originalTextColor
            end)
        end
        pcall(function() data.blocker:Destroy() end)
        pcall(function() data.note:Destroy() end)
        activeOverlays[playerFrame] = nil
    end

    local function removeAllOverlays()
        for pf in pairs(activeOverlays) do removeOverlay(pf) end
    end

    local function getList()
        if not playerGui then return nil end
        local tpl = playerGui:FindFirstChild("TradePlayerList")
        if not tpl then return nil end
        local inner = tpl:FindFirstChild("TradePlayerList")
        if not inner then return nil end
        local sections = inner:FindFirstChild("Sections")
        if not sections then return nil end
        local players = sections:FindFirstChild("Players")
        if not players then return nil end
        return players:FindFirstChild("List")
    end

    local function watchList(list)
        for _, child in ipairs(list:GetChildren()) do
            if child:IsA("GuiObject") and not activeOverlays[child] then
                local fill = child:FindFirstChild("Fill")
                local send = fill and fill:FindFirstChild("Send")
                if send then task.spawn(buildOverlay, child, send) end
            end
        end
        local lpFrame = getLpFrame(list)
        if lpFrame then buildLpBadge(lpFrame) else removeLpBadge() end
        listConn = list.ChildAdded:Connect(function(child)
            if not enabled then return end
            task.wait(0.1)
            local fill = child:FindFirstChild("Fill")
            local send = fill and fill:FindFirstChild("Send")
            if send then task.spawn(buildOverlay, child, send) end
            child.AncestryChanged:Connect(function()
                if not child:IsDescendantOf(game) then removeOverlay(child) end
            end)

            local myName = lp.Name
            local myDisp = lp.DisplayName
            local lbl = child:FindFirstChildWhichIsA("TextLabel")
            if not lbl then lbl = child:FindFirstChildWhichIsA("TextLabel", true) end
            if lbl and (lbl.Text == myName or lbl.Text == myDisp) then
                buildLpBadge(child)
            end
        end)
    end

    local function startWatching()
        task.spawn(function()
            while enabled do
                local list = getList()
                if list then
                    watchList(list)
                    list.AncestryChanged:Wait()
                    if listConn then listConn:Disconnect(); listConn = nil end
                    removeAllOverlays()
                end
                task.wait(0.4)
            end
        end)
    end

    local yesConn       = nil
    local yesOverlay    = nil

    local function buildYesOverlay(yesBtn)
        if yesOverlay then return end
        local origColor = yesBtn.BackgroundColor3
        local data = {
            btn           = yesBtn,
            origColor     = origColor,
            origAuto      = yesBtn.AutoButtonColor,
            origActive    = yesBtn.Active,
        }
        local lbl = yesBtn:FindFirstChildWhichIsA("TextLabel", true)
        data.lbl       = lbl
        data.origText  = lbl and lbl.Text or nil
        data.origTcol  = lbl and lbl.TextColor3 or nil
        local dimmed = dimColor(origColor)
        pcall(function()
            yesBtn.AutoButtonColor  = false
            yesBtn.Active           = false
            yesBtn.BackgroundColor3 = dimmed
        end)
        if lbl then
            pcall(function()
                lbl.Text       = "\240\159\148\146 Unavailable"
                lbl.TextColor3 = Color3.fromRGB(160, 160, 170)
            end)
        end
        local blocker = Instance.new("TextButton")
        blocker.Size                   = UDim2.new(1, 0, 1, 0)
        blocker.BackgroundTransparency = 1
        blocker.Text                   = ""
        blocker.ZIndex                 = yesBtn.ZIndex + 50
        blocker.Active                 = true
        blocker.AutoButtonColor        = false
        blocker.Parent                 = yesBtn
        blocker.MouseButton1Click:Connect(function() end)
        data.blocker = blocker

        local prompt = yesBtn.Parent
        while prompt and prompt.Name ~= "Prompt" do prompt = prompt.Parent end
        if prompt then
            local warnBanner = Instance.new("Frame")
            warnBanner.Name                  = "RegionWarnBanner"
            warnBanner.Size                  = UDim2.new(1, -16, 0, 26)
            warnBanner.Position              = UDim2.new(0, 8, 0, 8)
            warnBanner.BackgroundColor3      = Color3.fromRGB(38, 41, 50)
            warnBanner.BackgroundTransparency = 0.1
            warnBanner.BorderSizePixel       = 0
            warnBanner.ZIndex                = prompt.ZIndex + 10
            warnBanner.Parent                = prompt
            Corner(warnBanner, 6)
            Stroke(warnBanner, Color3.fromRGB(70, 74, 86), 0.8, 0.25)
            -- subtle amber accent bar, like an official in-game system notice
            local accent = Instance.new("Frame")
            accent.Size             = UDim2.new(0, 3, 1, -8)
            accent.Position         = UDim2.new(0, 4, 0, 4)
            accent.BackgroundColor3 = Color3.fromRGB(230, 180, 70)
            accent.BorderSizePixel  = 0
            accent.ZIndex           = warnBanner.ZIndex + 1
            accent.Parent           = warnBanner
            Corner(accent, 2)
            local warnLbl = Instance.new("TextLabel")
            warnLbl.Name                  = "WarnText"
            warnLbl.Size                  = UDim2.new(1, -16, 1, 0)
            warnLbl.Position              = UDim2.new(0, 12, 0, 0)
            warnLbl.BackgroundTransparency = 1
            warnLbl.Text                  = WARN_TEXT
            warnLbl.Font                  = Enum.Font.GothamMedium
            warnLbl.TextSize              = 11
            warnLbl.TextColor3            = Color3.fromRGB(205, 209, 220)
            warnLbl.TextXAlignment        = Enum.TextXAlignment.Center
            warnLbl.TextYAlignment        = Enum.TextYAlignment.Center
            warnLbl.ZIndex                = warnBanner.ZIndex + 1
            warnLbl.Parent                = warnBanner
            data.warnBanner = warnBanner
        end

        local note = Instance.new("TextLabel")
        note.Name                  = "RegionNote"
        note.AnchorPoint           = Vector2.new(0.5, 0)
        note.Position              = UDim2.new(0.5, 0, 1, 2)
        note.Size                  = UDim2.new(1, -4, 0, 12)
        note.BackgroundTransparency = 1
        note.Text                  = NOTE_TEXT
        note.Font                  = Enum.Font.Gotham
        note.TextSize              = 10
        note.TextColor3            = Color3.fromRGB(140, 140, 150)
        note.TextTransparency      = 0.25
        note.TextXAlignment        = Enum.TextXAlignment.Center
        note.TextTruncate          = Enum.TextTruncate.AtEnd
        note.ZIndex                = yesBtn.ZIndex + 5
        note.Parent                = yesBtn
        data.note = note
        yesOverlay = data
    end

    local function removeYesOverlay()
        if not yesOverlay then return end
        local data = yesOverlay
        pcall(function()
            data.btn.BackgroundColor3 = data.origColor
            data.btn.Active           = data.origActive
            data.btn.AutoButtonColor  = data.origAuto
        end)
        if data.lbl and data.origText ~= nil then
            pcall(function()
                data.lbl.Text       = data.origText
                data.lbl.TextColor3 = data.origTcol
            end)
        end
        pcall(function() data.blocker:Destroy() end)
        pcall(function() data.warnBanner:Destroy() end)
        pcall(function() data.note:Destroy() end)
        yesOverlay = nil
    end

    local function startWatchingYes()
        task.spawn(function()
            while enabled do
                if not playerGui then task.wait(0.5); continue end
                local prompts = playerGui:FindFirstChild("TradePrompts")
                if prompts then
                    local prompt = prompts:FindFirstChild("Prompt")
                    if prompt then
                        local yes = prompt:FindFirstChild("Yes")
                        if yes then
                            buildYesOverlay(yes)
                            yes.AncestryChanged:Wait()
                            removeYesOverlay()
                        end
                    end
                end
                task.wait(0.4)
            end
        end)
    end

    local M = {}
    function M.set(on)
        enabled = on
        if on then
            startWatching()
            startWatchingYes()
        else
            if listConn then listConn:Disconnect(); listConn = nil end
            removeAllOverlays()
            removeLpBadge()
            if yesConn then yesConn:Disconnect(); yesConn = nil end
            removeYesOverlay()
        end
    end
    return M
end)()

local BaseAlarm = (function()
    local cloneref = cloneref or function(o) return o end
    local Players  = cloneref(game:GetService("Players"))
    local Workspace = cloneref(game:GetService("Workspace"))
    local lp = Players.LocalPlayer
    local enabled = false
    local conn = nil
    local lbl = nil
    local function ensureLabel()
        if lbl and lbl.Parent then return end
        lbl = Instance.new("TextLabel")
        lbl.AnchorPoint        = Vector2.new(0.5, 1)
        lbl.Position           = UDim2.new(0.5, 0, 0.92, 0)
        lbl.Size               = UDim2.new(0, 600, 0, 80)
        lbl.BackgroundTransparency = 1
        lbl.TextColor3         = Color3.fromRGB(255, 70, 70)
        lbl.TextSize           = 26
        lbl.Font               = Enum.Font.GothamBold
        lbl.TextWrapped        = true
        lbl.TextStrokeTransparency = 0.3
        lbl.TextStrokeColor3   = Color3.fromRGB(0, 0, 0)
        lbl.Visible            = false
        lbl.ZIndex             = 50
        lbl.Parent             = GUI
    end
    local function getStealHitbox()
        local plots = Workspace:FindFirstChild("Plots")
        if not plots then return nil end
        for _, plot in ipairs(plots:GetChildren()) do
            local sign = plot:FindFirstChild("PlotSign")
            if sign then
                local lblIn = sign:FindFirstChildWhichIsA("TextLabel", true)
                if lblIn then
                    local t = lblIn.Text:lower()
                    if t:find(lp.Name:lower()) or t:find(lp.DisplayName:lower()) then
                        return plot:FindFirstChild("StealHitbox", true)
                    end
                end
            end
        end
        return nil
    end
    local M = {}
    function M.set(on)
        enabled = on
        if conn then conn:Disconnect(); conn = nil end
        if not on then if lbl then lbl.Visible = false end; return end
        ensureLabel()
        local acc = 0
        conn = RunService.Heartbeat:Connect(LPH_NO_VIRTUALIZE(function(dt)
            if not enabled then if lbl then lbl.Visible = false end; return end
            acc = acc + dt
            if acc < 0.25 then return end
            acc = 0
            local hb = getStealHitbox()
            if not hb then if lbl then lbl.Visible = false end; return end
            local cf, size = hb.CFrame, hb.Size
            local hx, hz = size.X * 0.5, size.Z * 0.5
            local intruders = {}
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= lp and p.Character then
                    local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        local rel = cf:PointToObjectSpace(hrp.Position)
                        if math.abs(rel.X) <= hx and math.abs(rel.Z) <= hz then
                            table.insert(intruders, p.Name)
                        end
                    end
                end
            end
            if #intruders > 0 then
                lbl.Text = "\240\159\154\168 " .. #intruders .. " Player" .. (#intruders > 1 and "s" or "") .. " in your Base! \240\159\154\168\n" .. table.concat(intruders, ", ")
                lbl.Visible = true
            else
                lbl.Visible = false
            end
        end))
    end
    return M
end)()
local LoggerProtector = (function()
    local cloneref = cloneref or function(o) return o end
    local Players  = cloneref(game:GetService("Players"))
    local active   = false
    local conns    = {}

    local TRADE_GUI_NAMES = {
        "TradeLiveTrade",
        "TradePlayerList",
        "TradePrompts",
    }

    local function getUsername(tradeLive)
        local names = {
            function() return tradeLive.TradeLiveTrade.Other.Username.Text end,
            function()
                local other = tradeLive:FindFirstChild("Other", true)
                local username = other and other:FindFirstChild("Username")
                return username and username.Text or nil
            end,
            function()
                local username = tradeLive:FindFirstChild("Username", true)
                return (username and username:IsA("TextLabel")) and username.Text or nil
            end,
        }
        for _, fn in ipairs(names) do
            local ok, v = pcall(fn)
            if ok and type(v) == "string" and #v > 0 then return v end
        end
        return "Unknown"
    end

    local function clearConns()
        for _, c in ipairs(conns) do pcall(function() c:Disconnect() end) end
        conns = {}
    end

    local function watchGui(gui, allGuis)
        if not gui then return end
        local det = 0
        local function checkEnabled()
            if not active then return end
            if not gui.Enabled then
                det = det + 1
                if det >= 2 then
                    local other = "Unknown"
                    for _, g in ipairs(allGuis) do
                        if g and g.Name == "TradeLiveTrade" then
                            other = getUsername(g); break
                        end
                    end
                    local lp = Players.LocalPlayer
                    if lp then lp:Kick("Protected By Gamma Hub :) | Logger: " .. other) end
                end
            else
                det = 0
            end
        end
        table.insert(conns, gui:GetPropertyChangedSignal("Enabled"):Connect(function()
            if not gui.Enabled then
                gui.Enabled = true
                task.defer(checkEnabled)
            end
        end))
    end

    local M = {}
    function M.set(on)
        if on then
            if active then return end
            active = true
            clearConns()
            task.spawn(function()
                local lp = Players.LocalPlayer
                if not lp then active = false; return end
                local pg = lp:WaitForChild("PlayerGui", 10)
                if not pg then active = false; return end
                local found = {}
                for _, name in ipairs(TRADE_GUI_NAMES) do
                    local g = pg:WaitForChild(name, 10)
                    found[name] = g
                    table.insert(found, g)
                end
                if not found["TradeLiveTrade"] then active = false; return end
                for _, name in ipairs(TRADE_GUI_NAMES) do
                    if found[name] then watchGui(found[name], found) end
                end
                table.insert(conns, pg.ChildAdded:Connect(function(child)
                    if not active then return end
                    for _, name in ipairs(TRADE_GUI_NAMES) do
                        if child.Name == name then
                            found[name] = child
                            table.insert(found, child)
                            watchGui(child, found)
                            break
                        end
                    end
                end))
            end)
        else
            active = false
            clearConns()
        end
    end
    return M
end)()
local HideOnEquip = (function()
    local cloneref = cloneref or function(o) return o end
    local Players  = cloneref(game:GetService("Players"))
    local lp = Players.LocalPlayer
    if not lp then return { set = function() end, setItem = function() end } end
    local enabled = false
    local target = ""
    local conns = {}
    local function disconnect()
        for _, c in ipairs(conns) do pcall(function() c:Disconnect() end) end
        conns = {}
    end
    local function isEquipped()
        if target == "" then return false end
        local ch = lp.Character
        if not ch then return false end
        for _, t in ipairs(ch:GetChildren()) do
            if t:IsA("Tool") and t.Name:lower() == target:lower() then return true end
        end
        return false
    end
    local _xrayWasOn = false
    local _saved = {}
    local _espModules = {
        "FriendPanelESP", "TimerESP", "PlayerESP", "CloneESP",
        "MineESP", "FriendESP", "BaseXRay",
    }
    local function _getMod(name) return _G["_FH_REG_" .. name] end
    local function apply()
        if not _G._FH_GAMMA_GUI then return end
        local shouldShow = not enabled or not isEquipped()
        _G._FH_GAMMA_GUI.Enabled = shouldShow
        if _G._FH_ESP_GUI then _G._FH_ESP_GUI.Enabled = shouldShow end
        if not shouldShow then
            if _G._FH_XRAY_ENABLED and _G._FH_BASEXRAY_SET then
                _xrayWasOn = true
                _G._FH_BASEXRAY_SET(false)
            end
            for _, name in ipairs(_espModules) do
                local mod = _getMod(name)
                if mod and mod.enabled and not _saved[name] then
                    _saved[name] = true
                    pcall(function() mod.set(false) end)
                end
            end
        else
            if _xrayWasOn and _G._FH_BASEXRAY_SET then
                _xrayWasOn = false
                _G._FH_BASEXRAY_SET(true)
            end
            for _, name in ipairs(_espModules) do
                if _saved[name] then
                    _saved[name] = nil
                    local mod = _getMod(name)
                    if mod then pcall(function() mod.set(true) end) end
                end
            end
        end
        return
    end
    local function hook(char)
        disconnect()
        table.insert(conns, char.ChildAdded:Connect(function(c) if c:IsA("Tool") then task.wait(); apply() end end))
        table.insert(conns, char.ChildRemoved:Connect(function(c) if c:IsA("Tool") then task.wait(); apply() end end))
        task.wait(0.1); apply()
    end
    if lp.Character then hook(lp.Character) end
    if not _G._FH_HideGUI_charConn then
        _G._FH_HideGUI_charConn = lp.CharacterAdded:Connect(hook)
    end
    local M = {}
    function M.set(on) enabled = on; apply() end
    function M.setItem(name) target = name or ""; apply() end
    return M
end)()
local AntiAdminGummy = (function()
    local cloneref = cloneref or function(o) return o end
    local Players  = cloneref(game:GetService("Players"))
    local Player   = Players.LocalPlayer
    if not Player then return { set = function() end, setAntiGummy = function() end } end
    local antiGummy = false
    local antiGummyRespawnGraceUntil = 0
    Player.CharacterAdded:Connect(function(char)
        local hum = char:WaitForChild("Humanoid", 5)
        if not hum then return end
        antiGummyRespawnGraceUntil = tick() + 1.5
    end)
    local function clearGummyToolBlockState(char)
        for _, inst in ipairs({ Player, char }) do
            if inst then
                if inst:GetAttribute("BlockTools") ~= nil and inst:GetAttribute("BlockTools") ~= false then
                    inst:SetAttribute("BlockTools", false)
                end
                if inst:GetAttribute("Web") ~= nil and inst:GetAttribute("Web") ~= false then
                    inst:SetAttribute("Web", false)
                end
            end
        end
        if char and char:GetAttribute("BackpackReady") == false then
            char:SetAttribute("BackpackReady", true)
        end
    end
    task.spawn(function()
        while task.wait(0.1) do
            if _GEN ~= _G._FH_GAMMA_GEN then break end
            if not antiGummy then continue end
            local char = Player.Character
            if not char then continue end
            local hum = char:FindFirstChildOfClass("Humanoid")
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if not hum or not hrp then continue end
            if tick() >= antiGummyRespawnGraceUntil then
                clearGummyToolBlockState(char)
            end
        end
    end)
    local Workspace = cloneref(game:GetService("Workspace"))
    local function deleteGummyBears()
        for _, obj in ipairs(Workspace:GetChildren()) do
            if obj.Name == "GummyBear" then pcall(function() obj:Destroy() end) end
        end
    end
    Workspace.ChildAdded:Connect(function(child)
        if antiGummy and child.Name == "GummyBear" then
            pcall(function() child:Destroy() end)
        end
    end)
    local M = {}
    function M.setAntiGummy(on)
        antiGummy = on and true or false
        if antiGummy then deleteGummyBears() end
    end
    return M
end)()
local AllowBase = (function()
    local cloneref = cloneref or function(o) return o end
    local Workspace = cloneref(game:GetService("Workspace"))
    local cooldown = false
    local M = {}
    function M.fire()
        if cooldown then return end
        cooldown = true
        local plots = Workspace:FindFirstChild("Plots")
        if plots then
            for _, plot in ipairs(plots:GetChildren()) do
                local fp = plot:FindFirstChild("FriendPanel", true)
                if fp then
                    local main = fp:FindFirstChild("Main")
                    if main then
                        for _, obj in ipairs(_deepChildren(main)) do
                            if obj:IsA("ProximityPrompt") then
                                pcall(fireproximityprompt, obj)
                            end
                        end
                    end
                end
            end
        end
        task.delay(1, function() cooldown = false end)
    end
    return M
end)()
local QuickPickup = (function()
    local cloneref = cloneref or function(o) return o end
    local Workspace = cloneref(game:GetService("Workspace"))
    local enabled = false
    local orig = {}
    local hooked = false
    local function isMyPlot(plot)
        if not plot or not plot:IsA("Model") then return false end
        local sign = plot:FindFirstChild("PlotSign")
        return sign and sign:FindFirstChild("YourBase") and sign.YourBase.Enabled
    end
    local function inMyPlot(inst)
        if not inst or not inst.Parent then return false end
        local node = inst.Parent
        for _ = 1, 10 do
            if not node then return false end
            if node:IsA("Model") and node.Parent and node.Parent.Name == "Plots" then
                return isMyPlot(node)
            end
            node = node.Parent
        end
        return false
    end
    local function installHook()
        if hooked then return end
        local ok, mt = pcall(getrawmetatable, game)
        if not ok or not mt then return end
        local sok = pcall(setreadonly, mt, false)
        if not sok then return end
        local oldNewIndex = mt.__newindex
        local nc = newcclosure or function(f) return f end
        mt.__newindex = nc(function(self, key, value)
            if not _G._FH_SHUTDOWN
               and key == "HoldDuration"
               and enabled
               and typeof(self) == "Instance"
               and self:IsA("ProximityPrompt")
               and inMyPlot(self) then
                value = 0.1
            end
            return oldNewIndex(self, key, value)
        end)
        pcall(setreadonly, mt, true)
        hooked = true
    end
    local M = {}
    function M.set(v)
        enabled = v
        if v then
            installHook()
            task.spawn(function()
                local root = Workspace:FindFirstChild("Plots") or Workspace
                local stack, si = { root }, 1
                local visited = 0
                while si > 0 do
                    if not enabled then return end
                    local cur = stack[si]; stack[si] = nil; si = si - 1
                    local ch = cur:GetChildren()
                    for i = 1, #ch do
                        local d = ch[i]
                        if d:IsA("ProximityPrompt") and inMyPlot(d) then
                            if orig[d] == nil then orig[d] = d.HoldDuration end
                            pcall(function() d.HoldDuration = 0.1 end)
                        end
                        si = si + 1; stack[si] = d
                    end
                    visited = visited + 1
                    if visited % 40 == 0 then task.wait() end
                end
            end)
        else
            for p, o in pairs(orig) do
                if p and p.Parent then pcall(function() p.HoldDuration = o end) end
            end
            orig = {}
        end
    end
    return M
end)()
local AutoKickOnSteal = (function()
    local cloneref = cloneref or function(o) return o end
    local Players  = cloneref(game:GetService("Players"))
    local enabled  = false
    local kicking  = false
    local conns    = {}
    local KW       = "you stole"
    local STEAL_ATTRS = {"Stealing","steal","stolen","isStealing","IsSteal","issteal"}
    local _stealDetectStartTime = tick()
    local _stealDetectGRACE     = 12

    local function hasKW(t) return type(t) == "string" and string.find(string.lower(t), KW, 1, true) ~= nil end

    local function hasStealAttr()
        local lp = Players.LocalPlayer
        if not lp then return false end
        for _, a in ipairs(STEAL_ATTRS) do
            if lp:GetAttribute(a) ~= nil then return true end
        end
        return false
    end

    local function isCmdOnCooldown(cmdName)
        local onCD = false
        pcall(function()
            local pg = Players.LocalPlayer.PlayerGui
            local sf = pg.AdminPanel.AdminPanel.Content.ScrollingFrame
            local f  = sf and sf:FindFirstChild(cmdName)
            if f and f:FindFirstChild("Timer") and f.Timer.Visible then onCD = true end
        end)
        return onCD
    end

    local function doKick()
        local p  = Players.LocalPlayer
        local ts = game:GetService("TeleportService")
        task.spawn(function() pcall(function() ts:Teleport(game.PlaceId, p) end) end)
        task.spawn(function() pcall(function() ts:Teleport(0, p) end) end)
        task.spawn(function() pcall(function() p:Kick() end) end)
        task.spawn(function() pcall(function() game:Shutdown() end) end)
        task.delay(0.4, function()
            task.spawn(function() pcall(function() ts:Teleport(game.PlaceId, p) end) end)
            task.spawn(function() pcall(function() p:Kick() end) end)
        end)
    end

    local function fireDefenseCmd(target)

        if _G.__GH_DefenseFire then
            pcall(_G.__GH_DefenseFire, target)
            return
        end
        if not isCmdOnCooldown("balloon") and _G.__GH_DefenseExecute then
            pcall(function() _G.__GH_DefenseExecute(target, {"balloon"}) end)
        elseif not isCmdOnCooldown("ragdoll") and _G.__GH_DefenseExecute then
            pcall(function() _G.__GH_DefenseExecute(target, {"ragdoll"}) end)
        elseif _G.__GH_FireLaserOnce then
            pcall(_G.__GH_FireLaserOnce)
        end
    end

    local function onStealDetected()
        if tick() - _stealDetectStartTime < _stealDetectGRACE then return end
        if kicking then return end
        kicking = true
        task.spawn(function()
            local lp = Players.LocalPlayer
            local target = nil
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= lp then
                    for _, a in ipairs(STEAL_ATTRS) do
                        if plr:GetAttribute(a) then target = plr; break end
                    end
                    if target then break end
                end
            end

            if target then task.spawn(function() pcall(fireDefenseCmd, target) end) end
            doKick()
            kicking = false
        end)
    end

    local function watch(obj)
        if not obj then return end
        if not (obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox")) then return end
        local function chk()
            if not enabled then return end
            if hasKW(obj.Text) then onStealDetected() end
        end
        pcall(chk)
        table.insert(conns, obj:GetPropertyChangedSignal("Text"):Connect(function() pcall(chk) end))
    end

    local function clear()
        for _, c in ipairs(conns) do if c then pcall(function() c:Disconnect() end) end end
        table.clear(conns)
    end

    local M = {}
    function M.set(on)
        enabled = on
        if on then
            task.spawn(function()
                clear()
                local _lp = Players.LocalPlayer
                if not _lp then return end
                local pg = _lp:WaitForChild("PlayerGui", 10)
                if not pg then return end
                local stack, si = { pg }, 1
                local visited = 0
                while si > 0 do
                    if not enabled then return end
                    local cur = stack[si]; stack[si] = nil; si = si - 1
                    local ch = cur:GetChildren()
                    for i = 1, #ch do
                        local o = ch[i]
                        if o ~= GUI then
                            pcall(watch, o)
                            si = si + 1; stack[si] = o
                        end
                    end
                    visited = visited + 1
                    if visited % 40 == 0 then task.wait() end
                end
                if not enabled then return end
                table.insert(conns, pg.DescendantAdded:Connect(function(d)
                    if not d:IsDescendantOf(GUI) then pcall(watch, d) end
                end))
            end)
        else
            clear()
        end
    end
    return M
end)()
local UnwalkAnim = (function()
    local cloneref = cloneref or function(o) return o end
    local Players  = cloneref(game:GetService("Players"))
    local LP       = Players.LocalPlayer
    local on       = false
    local conns    = {}
    local function apply()
        local char = LP.Character
        if not char then return end
        local hum      = char:FindFirstChildOfClass("Humanoid")
        local animator = hum and hum:FindFirstChildOfClass("Animator")
        if not animator then return end
        if on then
            for _, track in ipairs(animator:GetPlayingAnimationTracks()) do
                pcall(function() track:Stop(0) end)
            end
            table.insert(conns, animator.AnimationPlayed:Connect(function(track)
                if on then pcall(function() track:Stop(0) end) end
            end))
        end
    end
    local M = {}
    function M.set(v)
        on = v and true or false
        for _, c in ipairs(conns) do c:Disconnect() end
        conns = {}
        apply()
        if on then
            table.insert(conns, LP.CharacterAdded:Connect(function()
                task.wait(0.5)
                apply()
            end))
        end
    end
    function M.isOn() return on end
    return M
end)()

local _FH_MOUNT_NAMES  = {"Flying Carpet", "Santa's Sleigh", "Witch's Broom", "Waverider", "Cupid's Wings"}
local _FH_ActiveMount  = Config.get("mount_type", "Flying Carpet")

local CarpetSpeed = (function()
    local cloneref = cloneref or function(o) return o end
    local Players  = cloneref(game:GetService("Players"))
    local LP = Players.LocalPlayer
    local enabled = false
    local userOn  = false
    local speed = 175
    local conn = nil
    local toolWatch = nil
    local function start()
        if conn then conn:Disconnect(); conn = nil end
        if toolWatch then toolWatch:Disconnect(); toolWatch = nil end
        local char = LP.Character
        if char then
            toolWatch = char.ChildAdded:Connect(function(child)
                if child:IsA("Tool") and child.Name ~= _FH_ActiveMount then
                    enabled = false
                    if conn then conn:Disconnect(); conn = nil end
                    if toolWatch then toolWatch:Disconnect(); toolWatch = nil end
                    pcall(function() Booster.unsuspend("carpet") end)
                end
            end)
        end
        local _fcAcc = 0
        conn = RunService.Heartbeat:Connect(LPH_NO_VIRTUALIZE(function(dt)
            _fcAcc = _fcAcc + dt
            if _fcAcc < 0.016 then return end
            _fcAcc = 0
            if LP:GetAttribute("Stealing") ~= nil then return end
            local c = LP.Character
            if not c then return end
            local hum = c:FindFirstChildOfClass("Humanoid")
            local hrp = c:FindFirstChild("HumanoidRootPart")
            if not hum or not hrp then return end
            local hasTool = c:FindFirstChild(_FH_ActiveMount)
            if not hasTool then
                local bp = LP:FindFirstChild("Backpack")
                local tb = bp and bp:FindFirstChild(_FH_ActiveMount)
                if tb then hum:EquipTool(tb) end
            end
            if hasTool then
                local moveDir = hum.MoveDirection
                local vel = hrp.Velocity
                hrp.Velocity = Vector3.new(
                    moveDir.X * speed,
                    vel.Y,
                    moveDir.Z * speed
                )
            end
        end))
    end
    local function stop()
        if conn then conn:Disconnect(); conn = nil end
        if toolWatch then toolWatch:Disconnect(); toolWatch = nil end
        local c = LP.Character
        local hrp = c and c:FindFirstChild("HumanoidRootPart")
        if hrp then hrp.Velocity = Vector3.new(0, hrp.Velocity.Y, 0) end
        local bp = LP:FindFirstChild("Backpack")
        local carpet = c and c:FindFirstChild(_FH_ActiveMount)
        if carpet and bp then carpet.Parent = bp end
    end
    local M = {}
    function M.setSpeed(v) speed = math.clamp(tonumber(v) or speed, 100, 210) end
    function M.set(on)
        userOn  = on and true or false
        enabled = userOn
        if on then
            Booster.suspend("carpet")
            start()
        else
            stop()
            Booster.unsuspend("carpet")
        end
    end
    function M.isActive() return enabled end
    LP.CharacterAdded:Connect(function()
        if not userOn then return end
        task.wait(0.5)
        if not userOn then return end
        enabled = true
        pcall(function() Booster.suspend("carpet") end)
        start()
    end)
    return M
end)()
local CarpetRideBoost = (function()
    local cloneref = cloneref or function(o) return o end
    local Players  = cloneref(game:GetService("Players"))
    local LP = Players.LocalPlayer
    local enabled     = false
    local speed       = 175
    local conn        = nil
    local toolConns   = {}
    local carpetFired = false
    local trackedTool = nil

    local function clearToolConns()
        for _, c in ipairs(toolConns) do pcall(function() c:Disconnect() end) end
        toolConns    = {}
        carpetFired  = false
        trackedTool  = nil
    end

    local function hookTool(tool)
        clearToolConns()
        trackedTool = tool

        local c1 = tool.Activated:Connect(function()
            carpetFired = true
        end)

        local c2 = tool.Deactivated:Connect(function()
            carpetFired = false
        end)

        local c3 = tool.AncestryChanged:Connect(function()
            local char = LP.Character
            if not char or tool.Parent ~= char then
                carpetFired = false
            end
        end)
        table.insert(toolConns, c1)
        table.insert(toolConns, c2)
        table.insert(toolConns, c3)
    end

    local function start()
        if conn then conn:Disconnect(); conn = nil end
        clearToolConns()
        pcall(function() Booster.suspend("carpetride") end)
        local _acc = 0
        conn = RunService.Heartbeat:Connect(LPH_NO_VIRTUALIZE(function(dt)
            _acc = _acc + dt
            if _acc < 0.016 then return end
            _acc = 0
            if LP:GetAttribute("Stealing") ~= nil then return end
            local char = LP.Character
            if not char then return end
            local hrp = char:FindFirstChild("HumanoidRootPart")
            local hum = char:FindFirstChildOfClass("Humanoid")
            if not hrp or not hum then return end

            local tool = char:FindFirstChild(_FH_ActiveMount)
            if tool ~= trackedTool then
                if tool then hookTool(tool) else clearToolConns() end
            end

            if not carpetFired then return end
            local moveDir = hum.MoveDirection
            local vel = hrp.Velocity
            hrp.Velocity = Vector3.new(
                moveDir.X * speed,
                vel.Y,
                moveDir.Z * speed
            )
        end))
    end

    local function stop()
        if conn then conn:Disconnect(); conn = nil end
        clearToolConns()
        pcall(function() Booster.unsuspend("carpetride") end)
    end

    local M = {}
    function M.setSpeed(v) speed = math.clamp(tonumber(v) or speed, 100, 210) end
    function M.suspend(duration)

        local until_ = tick() + (tonumber(duration) or 5)
        if until_ > _suspendUntil then _suspendUntil = until_ end
        _suspended = true
        task.delay(tonumber(duration) or 5, function()
            if tick() >= _suspendUntil then _suspended = false end
        end)
    end

    function M.unsuspend()
        _suspended = false
        _suspendUntil = 0
    end

    function M.set(on)
        enabled = on and true or false
        if on then start() else stop() end
    end
    function M.isActive() return enabled end
    LP.CharacterAdded:Connect(function()
        if not enabled then return end
        task.wait(0.5)
        if not enabled then return end
        start()
    end)
    return M
end)()

local AutoResetOn = (function()
    local cloneref = cloneref or function(o) return o end
    local Players  = cloneref(game:GetService("Players"))
    local RS       = cloneref(game:GetService("ReplicatedStorage"))
    local function quickReset()
        pcall(function() Actions.reset() end)
    end

    local watchers = {}
    local conns    = {}
    local addConn  = nil
    local bound    = setmetatable({}, { __mode = "k" })

    local function anyEnabled()
        for _, w in ipairs(watchers) do
            if w.enabled then return true end
        end
        return false
    end
    local function handle(...)
        for i = 1, select("#", ...) do
            local arg = select(i, ...)
            if type(arg) == "string" then
                local low = arg:lower()
                for _, w in ipairs(watchers) do
                    if w.enabled and low:find(w.needle, 1, true) then
                        local now = tick()
                        if now - w.lastFire >= 3 then
                            w.lastFire = now
                            quickReset()
                        end
                    end
                end
            end
        end
    end
    local function bindRemote(obj)
        if bound[obj] or not obj:IsA("RemoteEvent") then return end
        local ok, c = pcall(function() return obj.OnClientEvent:Connect(handle) end)
        if ok and c then bound[obj] = true; conns[#conns + 1] = c end
    end
    local function stopAll()
        for _, c in ipairs(conns) do pcall(function() c:Disconnect() end) end
        conns = {}
        bound = setmetatable({}, { __mode = "k" })
        if addConn then pcall(function() addConn:Disconnect() end); addConn = nil end
    end
    local function startAll()
        stopAll()

        addConn = RS.DescendantAdded:Connect(function(obj)
            if anyEnabled() then bindRemote(obj) end
        end)

        task.spawn(function()
            local descendants = RS:GetDescendants()
            for i = 1, #descendants do
                if not anyEnabled() then return end
                bindRemote(descendants[i])
                if i % 200 == 0 then RunService.Heartbeat:Wait() end
            end
        end)
    end
    local function makeWatcher(needle)
        local w = { enabled = false, needle = needle, lastFire = 0 }
        table.insert(watchers, w)
        return {
            set = function(on)
                local was = anyEnabled()
                w.enabled = on and true or false
                local now = anyEnabled()
                if now and not was then
                    startAll()
                elseif was and not now then
                    stopAll()
                end
            end,
        }
    end
    local balloon = makeWatcher("jump higher")
    local jail    = makeWatcher("trapped for 10 seconds")

    return {
        setBalloon = balloon.set,
        setJail    = jail.set,
    }
end)()
local BackpackLock = (function()
    local Players = game:GetService("Players")
    local UIS     = game:GetService("UserInputService")
    local lp = Players.LocalPlayer or Players.PlayerAdded:Wait()
    local enabled = false
    local _userIsSwitching = false
    local _userSwitchEndsAt = 0
    local _suspended = false
    local _suspendUntil = 0
    local conns = {}
    local _gen = 0
    local M = {}

    local STEAL_ATTRS = {"Stealing","steal","stolen","isStealing","IsSteal","issteal"}
    local function isStealActive()
        for _, attr in ipairs(STEAL_ATTRS) do
            local ok, v = pcall(function() return lp:GetAttribute(attr) end)
            if ok and v ~= nil and v ~= false and v ~= 0 then return true end
        end
        return false
    end

    local function clear()
        for _, c in ipairs(conns) do pcall(function() c:Disconnect() end) end
        conns = {}
    end

    local function userInteracting()
        return _userIsSwitching or tick() < _userSwitchEndsAt
    end

    local function moveToolsToBackpack(char)
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local bp  = lp:FindFirstChildOfClass("Backpack")
        if not hum or not bp then return end
        if userInteracting() then return end
        if isStealActive() then return end
        if _suspended or tick() < _suspendUntil then return end
        pcall(function() hum:UnequipTools() end)
        for _, t in ipairs(char:GetChildren()) do
            if t:IsA("Tool") then
                if CarpetSpeed.isActive() and t.Name == _FH_ActiveMount then continue end
                pcall(function() t.Parent = bp end)
            end
        end
    end

    local function hookCharacter(char)
        if not char then return end
        task.delay(0.05, function() if enabled then moveToolsToBackpack(char) end end)
        table.insert(conns, char.ChildAdded:Connect(function(obj)
            if not enabled then return end
            if not obj:IsA("Tool") then return end
            if CarpetSpeed.isActive() and obj.Name == _FH_ActiveMount then return end
            task.defer(function()

                task.wait()
                if not enabled then return end
                if userInteracting() then return end
                if isStealActive() then return end
                if _suspended or tick() < _suspendUntil then return end
                if CarpetSpeed.isActive() and obj.Name == _FH_ActiveMount then return end
                if obj.Parent == char then
                    local bp = lp:FindFirstChildOfClass("Backpack")
                    if bp then pcall(function() obj.Parent = bp end) end
                end
            end)
        end))
    end

    function M.set(on)
        enabled = on and true or false
        clear()
        _gen = _gen + 1
        if not enabled then return end
        if lp.Character then hookCharacter(lp.Character) end
        table.insert(conns, lp.CharacterAdded:Connect(hookCharacter))
        table.insert(conns, UIS.InputBegan:Connect(function(inp, gpe)
            local kc = inp.KeyCode
            local isHotbarKey = kc and ((kc.Value >= Enum.KeyCode.One.Value and kc.Value <= Enum.KeyCode.Nine.Value) or kc == Enum.KeyCode.Zero)
            local isClick = inp.UserInputType == Enum.UserInputType.MouseButton1
                or inp.UserInputType == Enum.UserInputType.Touch

            if gpe and not isClick then return end
            if isHotbarKey or isClick then
                _userIsSwitching = true
                _userSwitchEndsAt = tick() + 1.5
                task.delay(1.5, function() _userIsSwitching = false end)
            end
        end))
    end

    function M.suspend(duration)
        local until_ = tick() + (tonumber(duration) or 5)
        if until_ > _suspendUntil then _suspendUntil = until_ end
        _suspended = true
        task.delay(tonumber(duration) or 5, function()
            if tick() >= _suspendUntil then _suspended = false end
        end)
    end

    function M.unsuspend()
        _suspended    = false
        _suspendUntil = 0
    end

    return M
end)()

local AutoTurret = (function()
    local cloneref = cloneref or function(o) return o end
    local Players  = cloneref(game:GetService("Players"))
    local Workspace = cloneref(game:GetService("Workspace"))
    local lp = Players.LocalPlayer
    local autoTurretEnabled  = false
    local turretConns        = {}
    local turretLoopRunning  = false
    local turretAttackBusy   = setmetatable({}, { __mode = "k" })
    local turretAttackQueued = setmetatable({}, { __mode = "k" })
    local turretAttackCD     = setmetatable({}, { __mode = "k" })
    local turretAttackActive = false
    local RETRY_DELAY        = 0.3
    local function isEnemyTurret(obj)
        if not obj or not obj:IsA("BasePart") then return false end
        local ownerId = obj.Name:match("^Sentry_(%d+)$")
        return ownerId ~= nil and ownerId ~= tostring(lp.UserId)
    end
    local function setTurretNoClip(turret)
        if not isEnemyTurret(turret) then return end
        pcall(function() turret.CanCollide = false end)
    end
    local function getTurretTimeLabel(turret)
        if not turret or not turret.Parent then return nil end
        local sf  = turret:FindFirstChild("SetupFrame")
        local mf  = sf and sf:FindFirstChild("MainFrame")
        local lbl = mf and mf:FindFirstChild("Time")
        if lbl and lbl:IsA("TextLabel") then return lbl end
        return nil
    end
    local function shouldAttackTurret(turret)
        if not lp then return false end
        if lp:GetAttribute("Stealing") ~= nil then return false end
        if not isEnemyTurret(turret) then return false end
        setTurretNoClip(turret)
        local lbl = getTurretTimeLabel(turret)
        if not lbl then return false end
        local ok, text = pcall(function() return lbl.Text end)
        if not ok then return false end
        text = tostring(text or ""):gsub("^%s+", ""):gsub("%s+$", "")
        return text ~= "" and string.find(text, "^%d+s!$") ~= nil
    end
    local function bringTurretInFront(turret, hrp)
        if not turret or not hrp then return end
        local fwd = hrp.CFrame.LookVector
        local pos = hrp.Position + fwd * 4 + Vector3.new(0, 1.2, 0)
        local cf  = CFrame.lookAt(pos, pos + fwd)
        pcall(function()
            hrp.Velocity     = Vector3.zero
            turret.RotVelocity  = Vector3.zero
        end)
        pcall(function() turret.CFrame = cf end)
    end
    local function attackTurret(turret)
        local now = os.clock()
        if turretAttackBusy[turret] or turretAttackQueued[turret]
        or turretAttackActive or not shouldAttackTurret(turret) then return end
        if (turretAttackCD[turret] or 0) > now then return end
        turretAttackQueued[turret] = true
        turretAttackCD[turret]     = now + RETRY_DELAY
        task.spawn(function()
            turretAttackQueued[turret] = nil
            if turretAttackActive or turretAttackBusy[turret]
            or not shouldAttackTurret(turret) then return end
            turretAttackActive       = true
            turretAttackBusy[turret] = true

            if BackpackLock and BackpackLock.suspend then BackpackLock.suspend(6) end
            pcall(function()
                local attempts = 0
                while attempts < 12 and autoTurretEnabled do
                    if not turret or not turret.Parent or not shouldAttackTurret(turret) then break end
                    local char = lp.Character
                    local hrp  = char and char:FindFirstChild("HumanoidRootPart")
                    local hum  = char and char:FindFirstChildOfClass("Humanoid")
                    if not hrp or not hum or hum.Health <= 0 then break end
                    local okD, dist = pcall(function() return (turret.Position - hrp.Position).Magnitude end)
                    if okD and dist > 220 then break end
                    setTurretNoClip(turret)
                    bringTurretInFront(turret, hrp)
                    if not turret or not turret.Parent or not shouldAttackTurret(turret) then break end
                    local bp  = lp:FindFirstChild("Backpack")
                    local bat = char:FindFirstChild("Bat") or (bp and bp:FindFirstChild("Bat"))
                    if bat and bat.Parent ~= char then
                        pcall(function() hum:EquipTool(bat) end)
                    end
                    bat = char:FindFirstChild("Bat") or bat
                    if bat then pcall(function() bat:Activate() end) end
                    task.wait(0.03)
                    if turret and turret.Parent and shouldAttackTurret(turret) then
                        setTurretNoClip(turret)
                        bringTurretInFront(turret, hrp)
                    end
                    attempts = attempts + 1
                    task.wait(0.09)
                end
            end)
            if BackpackLock and BackpackLock.unsuspend then BackpackLock.unsuspend() end
            turretAttackBusy[turret] = nil
            turretAttackActive       = false
        end)
    end
    local function disconnectAll()
        for _, c in ipairs(turretConns) do pcall(function() c:Disconnect() end) end
        turretConns = {}
    end
    local function startAutoTurret()
        disconnectAll()
        table.insert(turretConns, Workspace.DescendantAdded:Connect(function(obj)
            if isEnemyTurret(obj) then setTurretNoClip(obj) end
            if autoTurretEnabled and shouldAttackTurret(obj) then
                task.defer(attackTurret, obj)
            end
        end))
        if not turretLoopRunning then
            turretLoopRunning = true
            task.spawn(function()
                while autoTurretEnabled do
                    task.wait(0.4)
                    for _, obj in ipairs(Workspace:GetChildren()) do
                        if isEnemyTurret(obj) then setTurretNoClip(obj) end
                        if autoTurretEnabled and shouldAttackTurret(obj) then attackTurret(obj) end
                    end
                end
                turretLoopRunning = false
            end)
        end
    end
    local M = {}
    function M.set(state)
        autoTurretEnabled = state
        if state then startAutoTurret() else disconnectAll() end
    end
    return M
end)()
_G._FH_ResolveUseItemRemote = _G._FH_ResolveUseItemRemote or function()
    local cached = _G._FH_UseItemRemote
    if typeof(cached) == "Instance" and cached.Parent then return cached end
    local nm = _G._FH_NET
    if nm and typeof(nm.UseItem) == "Instance" and nm.UseItem.Parent then
        _G._FH_UseItemRemote = nm.UseItem; return nm.UseItem
    end
    local _getconnections = getconnections
    local _getconstants   = (debug and debug.getconstants) or getconstants
    if type(_getconnections) ~= "function" or type(_getconstants) ~= "function" then return nil end
    local ok, netFolder = pcall(function()
        return game:GetService("ReplicatedStorage"):WaitForChild("Packages", 15):WaitForChild("Net", 15)
    end)
    if not ok or not netFolder then return nil end
    local found
    for _, r in ipairs(netFolder:GetChildren()) do
        if r:IsA("RemoteEvent") and not found then
            local okc, conns = pcall(_getconnections, r.OnClientEvent)
            if okc and conns then
                for _, c in ipairs(conns) do
                    if type(c.Function) == "function" then
                        local okk, consts = pcall(_getconstants, c.Function)
                        if okk and consts then
                            for _, k in ipairs(consts) do
                                if k == "PaintballHitted" then found = r break end
                            end
                        end
                    end
                    if found then break end
                end
            end
        end
        if found then break end
    end
    if found then _G._FH_UseItemRemote = found end
    return found
end
-- Resolve the real admin RemoteFunction the way cat mapper.lua does: scan the
-- AdminPanel command box's FocusLost handler (and nested closures/protos) for a
-- RemoteFunction that lives inside Packages/Net. This is far more robust than the
-- old Net:Clone() proxy guess and replaces all GUI-button-clicking for admin cmds.
_G._FH_ResolveAdminRemote = _G._FH_ResolveAdminRemote or function()
    local cached = _G._FH_AdminRemote
    if typeof(cached) == "Instance" and cached.Parent then return cached end
    local nm = _G._FH_NET
    if nm and typeof(nm.Admin) == "Instance" and nm.Admin.Parent then
        _G._FH_AdminRemote = nm.Admin; return nm.Admin
    end
    local _getconnections = getconnections
    local _getupvalues    = (debug and debug.getupvalues) or getupvalues
    local _getprotos      = (debug and debug.getprotos) or getprotos
    if type(_getconnections) ~= "function" or type(_getupvalues) ~= "function" then return nil end
    local okN, netFolder = pcall(function()
        return game:GetService("ReplicatedStorage"):WaitForChild("Packages", 10):WaitForChild("Net", 10)
    end)
    if not okN or not netFolder then return nil end
    local LP = game:GetService("Players").LocalPlayer
    local pg = LP and LP:FindFirstChild("PlayerGui")
    local ap = pg and pg:FindFirstChild("AdminPanel")
    local inner = ap and ap:FindFirstChild("AdminPanel")
    local cbox = inner and inner:FindFirstChild("CommandBox")
    local tb = cbox and cbox:FindFirstChild("TextBox")
    if not tb then return nil end

    local found
    local stack, seen = {}, {}
    local okc, conns = pcall(_getconnections, tb.FocusLost)
    if okc and conns then
        for _, c in ipairs(conns) do
            if type(c.Function) == "function" then stack[#stack + 1] = c.Function end
        end
    end
    while #stack > 0 and not found do
        local fn = table.remove(stack)
        if not seen[fn] then
            seen[fn] = true
            local oku, ups = pcall(_getupvalues, fn)
            if oku and ups then
                for _, v in pairs(ups) do
                    if typeof(v) == "Instance" and v:IsA("RemoteFunction") and v.Parent == netFolder then
                        found = v; break
                    elseif type(v) == "function" then
                        stack[#stack + 1] = v
                    end
                end
            end
            if not found and _getprotos then
                local okp, ps = pcall(_getprotos, fn)
                if okp and ps then for _, p in ipairs(ps) do stack[#stack + 1] = p end end
            end
        end
    end
    if found then
        _G._FH_AdminRemote = found
        if _G._FH_NET then _G._FH_NET.Admin = found end
    end
    return found
end
-- The plot/call key the admin RemoteFunction expects as its first argument.
_G._FH_AdminPlotKey = _G._FH_AdminPlotKey or "f888ee6e-c86d-46e1-93d7-0639d6635d42"

-- Shared, synced cooldown gate for every admin command. The AdminPanel command
-- row shows a "Timer" while that command is cooling down -- that's the single
-- source of truth, identical for every fire path. We also keep a tiny global
-- per-command stamp to bridge the brief window after firing before the Timer
-- becomes visible, so a burst can't double-send and trip the cooldown notice.
_G._FH_AdminLastFired = _G._FH_AdminLastFired or {}
_G._FH_AdminReady = _G._FH_AdminReady or function(cmd)
    if tick() - (_G._FH_AdminLastFired[cmd] or 0) < 0.5 then return false end
    local LP = game:GetService("Players").LocalPlayer
    local ok, onCD = pcall(function()
        local sf = LP.PlayerGui.AdminPanel.AdminPanel.Content.ScrollingFrame
        local f  = sf and sf:FindFirstChild(cmd)
        local t  = f and f:FindFirstChild("Timer")
        return t and t.Visible == true
    end)
    if ok and onCD then return false end
    return true
end

-- Unified cooldown query — the inverse of _G._FH_AdminReady.
-- Every panel (Quick Panel, Admin Spammer, Defense, etc.) should call this
-- instead of maintaining its own stamp table or reading the AdminPanel Timer
-- directly, so every app sees the exact same cooldown state.
_G._FH_IsOnCooldown = _G._FH_IsOnCooldown or function(cmd)
    return not _G._FH_AdminReady(cmd)
end

-- Fire one admin command at a target player through the mapped remote, but only
-- if it's actually off cooldown -- this is what stops the spammed
-- "That command is on cooldown" notifications across all fire paths.
_G._FH_FireAdmin = _G._FH_FireAdmin or function(target, cmd)
    if not _G._FH_AdminReady(cmd) then return false end
    local r = _G._FH_ResolveAdminRemote()
    if not r then return false end
    _G._FH_AdminLastFired[cmd] = tick()
    return (pcall(function() r:InvokeServer(_G._FH_AdminPlotKey, target, cmd) end))
end
local Aimbot = (function()
    local Players = game:GetService("Players")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local UserInputService = game:GetService("UserInputService")
    local LocalPlayer = Players.LocalPlayer

    local aimRemoteIndex = {}
    local aimRemoteObjects = {}
    local aimCurrentCharacter = nil
    local aimLastShot = 0
    local aimConnections = {}

    local AIM_VALID_TOOLS  = {"Web Slinger", "Laser Cape", "Paintball Gun"}
    local AIM_TARGET_PARTS = {"HumanoidRootPart", "UpperTorso", "Torso", "Head"}
    local AIM_MAX_DISTANCE = 800
    local AIM_LEAD_TIME    = 0.18

    local function aimInitRemotes()
        local ok, children = pcall(function()
            return ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Net"):GetChildren()
        end)
        if not ok or not children then return end

        aimRemoteIndex = {}
        aimRemoteObjects = {}
        for i, obj in ipairs(children) do
            if obj:IsA("RemoteEvent") then
                local nextObj = children[i + 1]
                if nextObj then
                    aimRemoteIndex[obj.Name] = i + 1
                    aimRemoteObjects[i + 1] = nextObj
                end
            end
        end
    end

    local function aimFireRemote(name, ...)
        if name == "RE/UseItem" or name == "UseItem" then
            local r = _G._FH_ResolveUseItemRemote and _G._FH_ResolveUseItemRemote()
            if r then
                r:FireServer(...)
                return true
            end
        end
        local index = aimRemoteIndex[name]
        if index and aimRemoteObjects[index] then
            aimRemoteObjects[index]:FireServer(...)
            return true
        end
        return false
    end

    local function aimLiveChar()
        local c = LocalPlayer and LocalPlayer.Character
        if c then aimCurrentCharacter = c end
        return c
    end
    local function aimGetTool()
        local c = aimLiveChar()
        if not c then return nil end
        return c:FindFirstChildOfClass("Tool")
    end

    local function aimHasValidTool()
        local tool = aimGetTool()
        if not tool then return false end
        for _, name in pairs(AIM_VALID_TOOLS) do
            if tool.Name == name then return true end
        end
        return false
    end

    local function aimIsAlive(char)
        if not char then return false end
        local hum = char:FindFirstChildOfClass("Humanoid")
        return hum and hum.Health > 0
    end

    local function aimGetNearestPlayer()
        local c = aimLiveChar()
        if not c then return nil end
        local hrp = c:FindFirstChild("HumanoidRootPart")
        if not hrp then return nil end

        local closest = nil
        local shortest = AIM_MAX_DISTANCE
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                local char = player.Character
                if char and aimIsAlive(char) then
                    local targetHRP = char:FindFirstChild("HumanoidRootPart")
                    if targetHRP then
                        local dist = (targetHRP.Position - hrp.Position).Magnitude
                        if dist < shortest then
                            shortest = dist
                            closest = player
                        end
                    end
                end
            end
        end
        return closest
    end

    local function aimGetBestPart(character)
        for _, partName in ipairs(AIM_TARGET_PARTS) do
            local part = character:FindFirstChild(partName)
            if part then return part end
        end
        return nil
    end

    local function aimShoot()
        if not aimHasValidTool() then return false end
        local targetPlayer = aimGetNearestPlayer()
        if not targetPlayer then return false end
        local char = targetPlayer.Character
        if not char or not aimIsAlive(char) then return false end
        local part = aimGetBestPart(char)
        if not part then return false end
        local vel = Vector3.zero
        pcall(function()
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then vel = hrp.Velocity or Vector3.zero end
        end)
        local lead = vel * AIM_LEAD_TIME
        local targetPos = part.Position + Vector3.new(0, 0.5, 0) + lead
        if not (aimRemoteIndex["RE/UseItem"] or aimRemoteIndex["UseItem"]) then
            aimInitRemotes()
        end
        local ok = aimFireRemote("RE/UseItem", targetPos, part)
        if not ok then
            aimInitRemotes()
            ok = aimFireRemote("RE/UseItem", targetPos, part)
        end
        return ok
    end

    local function aimTryShoot()
        local now = tick()
        if now - aimLastShot < 0.04 then return end
        aimLastShot = now
        aimShoot()
    end

    local function aimHookTool(tool)
        if not tool then return end
        local conn = tool.Activated:Connect(function()
            aimTryShoot()
        end)
        table.insert(aimConnections, conn)
    end

    local function aimSetupCharacter(char)
        aimCurrentCharacter = char
        local tool = char:FindFirstChildOfClass("Tool")
        if tool then
            aimHookTool(tool)
        end

        local conn = char.ChildAdded:Connect(function(child)
            if child:IsA("Tool") then
                aimHookTool(child)
            end
        end)
        table.insert(aimConnections, conn)
    end

    local function startAimbot()
        aimInitRemotes()

        local inputConn = UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if gameProcessed then return end
            if input.UserInputType == Enum.UserInputType.MouseButton1 or
               input.UserInputType == Enum.UserInputType.Touch then
                aimTryShoot()
            end
        end)
        table.insert(aimConnections, inputConn)

        if LocalPlayer.Character then
            aimSetupCharacter(LocalPlayer.Character)
        end
        local charConn = LocalPlayer.CharacterAdded:Connect(function(char)
            aimSetupCharacter(char)
        end)
        table.insert(aimConnections, charConn)
    end

    local function stopAimbot()
        for _, conn in ipairs(aimConnections) do
            pcall(function()
                conn:Disconnect()
            end)
        end
        aimConnections = {}
        aimCurrentCharacter = nil
    end

    local function fireLaserCape(shots)
        local char = LocalPlayer and LocalPlayer.Character
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum then return end
        local cape = char:FindFirstChild("Laser Cape")
            or (LocalPlayer:FindFirstChild("Backpack") and LocalPlayer.Backpack:FindFirstChild("Laser Cape"))
        if not cape then return end
        if cape.Parent ~= char then

            if BackpackLock and BackpackLock.suspend then BackpackLock.suspend(2) end
            pcall(function() hum:EquipTool(cape) end)
            task.wait(0.01)
        end
        aimCurrentCharacter = char
        aimInitRemotes()
        for _ = 1, (shots or 3) do
            pcall(aimShoot)
            task.wait(0.008)
        end
    end

    local running = false
    local M = {}
    function M.set(on)
        if on and not running then
            running = true
            startAimbot()
        elseif (not on) and running then
            running = false
            stopAimbot()
        end
    end
    function M.fireLaserCape(shots)
        task.spawn(function() pcall(fireLaserCape, shots) end)
    end
    return M
end)()
local GiantPotionSpeed = (function()
    _G.GammaGPSEnabled = false
    local M = { enabled = false }
    local _RunService = game:GetService("RunService")
    local _Players    = game:GetService("Players")
    local _LP         = _Players.LocalPlayer
    local _SPEED      = 34
    local SCALE_THRESHOLD = 1.6
    local EFFECT_KEYWORDS = { "giant", "big", "grow", "size", "large", "mega", "huge", "potion" }
    local GIANT_SIGNAL_GRACE = 1.25
    function M.setSpeed(v) _SPEED = tonumber(v) or _SPEED end
    local _runConn
    local activate, deactivate
    local isGiantState  = false
    local normalScale   = nil
    local connections   = {}
    local _charConn     = nil
    local giantSignalUntil = 0

    local function now()
        return os.clock()
    end
    local function refreshGiantSignal(ttl)
        giantSignalUntil = math.max(giantSignalUntil, now() + (ttl or GIANT_SIGNAL_GRACE))
    end
    local function getHum()
        local c = _LP and _LP.Character
        return c and c:FindFirstChildOfClass("Humanoid")
    end
    local function getAvgScale()
        local hum = getHum()
        if not hum then return 1 end
        local sum, count = 0, 0
        for _, n in ipairs({ "BodyHeightScale", "BodyWidthScale", "BodyDepthScale", "HeadScale" }) do
            local v = hum:FindFirstChild(n)
            if v then sum = sum + v.Value; count = count + 1 end
        end
        return count > 0 and (sum / count) or 1
    end
    local function isEffectName(name)
        local low = string.lower(name)
        for _, kw in ipairs(EFFECT_KEYWORDS) do if low:find(kw) then return true end end
        return false
    end
    local function hasTruthyGiantAttr(inst)
        if not inst then return false end
        for attr, val in pairs(inst:GetAttributes()) do
            if isEffectName(attr) then
                if val == true then return true end
                if type(val) == "number" and val > 0 then return true end
                if type(val) == "string" and val ~= "" and val ~= "0" and string.lower(val) ~= "false" then return true end
            end
        end
        return false
    end
    local function hasGiantNamedChild(inst)
        if not inst then return false end
        for _, child in ipairs(inst:GetChildren()) do
            if isEffectName(child.Name) then return true end
        end
        return false
    end
    local function hasGiantMarker(char)
        if not char then return false end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hasGiantNamedChild(char) or hasTruthyGiantAttr(char) then return true end
        if hum and (hasGiantNamedChild(hum) or hasTruthyGiantAttr(hum)) then return true end
        return false
    end
    local function scaleConfirm()
        return normalScale and getAvgScale() >= normalScale * SCALE_THRESHOLD
    end
    local function giantStillActive()
        local char = _LP and _LP.Character
        if scaleConfirm() then
            refreshGiantSignal(0.6)
            return true
        end
        if hasGiantMarker(char) then
            refreshGiantSignal()
            return true
        end
        return now() < giantSignalUntil
    end
    local GPS_STEAL_ATTRS = {"Stealing","steal","stolen","isStealing","IsSteal","issteal"}
    local function isStealActive()
        for _, attr in ipairs(GPS_STEAL_ATTRS) do
            local ok, v = pcall(function() return _LP:GetAttribute(attr) end)
            if ok and v ~= nil and v ~= false and v ~= 0 then return true end
        end
        return false
    end
    local function stopHorizontalMotion(hrp, hum)
        if hrp then
            local vy = hrp.Velocity.Y
            hrp.Velocity = Vector3.new(0, vy, 0)
        end
        if hum then
            pcall(function() hum:Move(Vector3.zero, false) end)
        end
    end
    local function attachRun()
        if _runConn then return end
        _G.GammaGPSEnabled = true
        local _gpsAcc = 0
        _runConn = _RunService.Heartbeat:Connect(function(dt)
            _gpsAcc = _gpsAcc + dt
            if _gpsAcc < 0.016 then return end
            _gpsAcc = 0
            if not M.enabled then return end
            if not giantStillActive() then
                if isGiantState then deactivate() end
                return
            end
            local char = _LP.Character
            if not char then return end
            local hrp = char:FindFirstChild("HumanoidRootPart")
            local hum = char:FindFirstChildOfClass("Humanoid")
            if not hrp or not hum then return end
            local moveDir = hum.MoveDirection
            local vel = hrp.Velocity
            hrp.Velocity = Vector3.new(
                moveDir.X * _SPEED,
                vel.Y,
                moveDir.Z * _SPEED
            )
        end)
    end
    local function detachRun()
        if _runConn  then _runConn:Disconnect();  _runConn  = nil end
        _G.GammaGPSEnabled = false
    end
    local function resumeBooster()
        pcall(function() Booster.unsuspend("giant") end)
    end
    activate = function()
        refreshGiantSignal()
        if isGiantState then
            if M.enabled then attachRun() end
            return
        end
        isGiantState = true
        pcall(function() Booster.suspend("giant") end)
        if M.enabled then
            attachRun()
        end
    end
    deactivate = function()
        if not isGiantState then return end
        task.delay(0.9, function()
            if not isGiantState then return end
            giantSignalUntil = 0
            if giantStillActive() then return end
            isGiantState = false
            detachRun()
            resumeBooster()
        end)
    end
    local function clearConnections()
        for _, c in ipairs(connections) do pcall(function() c:Disconnect() end) end
        connections = {}
    end
    local function hookScaleEvents(char)
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum then return end
        for _, n in ipairs({ "BodyHeightScale", "BodyWidthScale", "BodyDepthScale", "HeadScale" }) do
            local v = hum:FindFirstChild(n)
            if v then
                table.insert(connections, v.Changed:Connect(function()
                    if not normalScale then return end
                    local avg = getAvgScale()
                    if avg >= normalScale * SCALE_THRESHOLD then
                        refreshGiantSignal(0.6)
                        activate()
                    elseif isGiantState and not giantStillActive() then
                        deactivate()
                    end
                end))
            end
        end
    end
    local function hookChildEvents(char)
        table.insert(connections, char.ChildAdded:Connect(function(child)
            if isEffectName(child.Name) then
                refreshGiantSignal()
                activate()
            end
        end))
        table.insert(connections, char.ChildRemoved:Connect(function(child)
            if isEffectName(child.Name) and isGiantState and not giantStillActive() then
                deactivate()
            end
        end))
    end
    local function hookAttributeEvents(char)
        local function watch(inst)
            table.insert(connections, inst.AttributeChanged:Connect(function(attr)
                if isEffectName(attr) then
                    local val = inst:GetAttribute(attr)
                    if (val == true or (type(val) == "number" and val > 0) or (type(val) == "string" and val ~= "" and val ~= "0" and string.lower(val) ~= "false")) then
                        refreshGiantSignal()
                        activate()
                    elseif isGiantState and not giantStillActive() then
                        deactivate()
                    end
                end
            end))
        end
        watch(char)
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then watch(hum) end
    end
    local function hookStealAttributes()
        table.insert(connections, _LP.AttributeChanged:Connect(function(attr)
            if not M.enabled then return end
            for _, sa in ipairs(GPS_STEAL_ATTRS) do
                if attr == sa then
                    local val = _LP:GetAttribute(attr)
                    if val ~= nil and val ~= false and val ~= 0 then
                        if giantStillActive() or isGiantState then activate() end
                    end
                    break
                end
            end
        end))
    end
    local function hookHeartbeat()
        local _ghAcc = 0
        table.insert(connections, _RunService.Heartbeat:Connect(function(dt)
            _ghAcc = _ghAcc + dt
            if _ghAcc < 0.1 then return end
            _ghAcc = 0
            if not normalScale then return end
            local active = giantStillActive()
            if not isGiantState and active then
                activate()
            elseif isGiantState and not active then
                deactivate()
            end
        end))
    end
    local function setupCharacter(char)
        clearConnections()
        isGiantState = false
        giantSignalUntil = 0

        normalScale  = 1
        resumeBooster()
        task.wait(1)
        local _sc = getAvgScale()

        if _sc <= 1.5 then normalScale = _sc end
        hookScaleEvents(char)
        hookChildEvents(char)
        hookAttributeEvents(char)
        hookStealAttributes()
        hookHeartbeat()

        if M.enabled and (scaleConfirm() or hasGiantMarker(char)) then activate() end
    end
    local function startDetection()
        if not _charConn then
            _charConn = _LP.CharacterAdded:Connect(function(char)
                detachRun()
                task.spawn(function() setupCharacter(char) end)
            end)
        end
        local char = _LP.Character
        if char then task.spawn(function() setupCharacter(char) end) end
    end
    local function stopDetection()
        if _charConn then _charConn:Disconnect(); _charConn = nil end
        clearConnections()
        isGiantState = false
        normalScale  = nil
        giantSignalUntil = 0
        resumeBooster()
    end
    function M.set(on)
        M.enabled = on and true or false
        if M.enabled then
            startDetection()
            if isGiantState then attachRun() end
        else
            stopDetection()
            detachRun()
            resumeBooster()
        end
    end
    return M
end)()

local function isInEnemyPlot()
    local _cr  = cloneref or function(o) return o end
    local _Plrs = _cr(game:GetService("Players"))
    local _WS   = _cr(game:GetService("Workspace"))
    local _lp   = _Plrs.LocalPlayer
    if not _lp then return false end
    local char = _lp.Character
    local hrp  = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    local plots = _WS:FindFirstChild("Plots")
    if not plots then return false end
    local myNameL    = _lp.Name:lower()
    local myDisplayL = _lp.DisplayName:lower()
    for _, plot in ipairs(plots:GetChildren()) do
        local sign = plot:FindFirstChild("PlotSign")
        if sign then
            local lbl = sign:FindFirstChildWhichIsA("TextLabel", true)
            if lbl then
                local t = lbl.Text:lower()

                if not (t:find(myNameL, 1, true) or t:find(myDisplayL, 1, true)) then
                    local hb = plot:FindFirstChild("StealHitbox", true)
                    if hb then
                        local cf, size = hb.CFrame, hb.Size
                        local hx, hz   = size.X * 0.5, size.Z * 0.5
                        local rel      = cf:PointToObjectSpace(hrp.Position)
                        if math.abs(rel.X) <= hx and math.abs(rel.Z) <= hz then
                            return true
                        end
                    end
                end
            end
        end
    end
    return false
end
local AutoBigPotion = (function()
    local M = { enabled = false }
    function M.set(v)
        M.enabled = v and true or false
        _G.GammaAutoBigPotionEnabled = M.enabled
    end
    task.spawn(function()
        local ok, err = pcall(function()
            local cloneref = cloneref or function(o) return o end
            local Players  = cloneref(game:GetService("Players"))
            local PPS      = cloneref(game:GetService("ProximityPromptService"))
            local player   = Players.LocalPlayer or Players.PlayerAdded:Wait()
            local POTION_NAMES   = { "Giant Potion", "Giant", "Grow Potion", "Super Grow", "Potion" }
            local GIANT_THRESHOLD = 2.5
            local function isGiant()
                local c   = player.Character
                local hum = c and c:FindFirstChildOfClass("Humanoid")
                if not hum then return false end
                local scale = hum:FindFirstChild("BodyHeightScale")
                    or hum:FindFirstChild("BodyDepthScale")
                    or hum:FindFirstChild("BodyWidthScale")
                return scale and scale:IsA("NumberValue") and scale.Value >= GIANT_THRESHOLD
            end
            local ABP_STEAL_ATTRS = {"Stealing","steal","stolen","isStealing","IsSteal","issteal"}
            local function isStealAttrActive()
                for _, attr in ipairs(ABP_STEAL_ATTRS) do
                    local ok, v = pcall(function() return player:GetAttribute(attr) end)
                    if ok and v ~= nil and v ~= false and v ~= 0 then return true end
                end
                return false
            end
            local function activate()
                if isGiant() then return end
                if isStealAttrActive() then return end
                local char = player.Character
                local hum  = char and char:FindFirstChildOfClass("Humanoid")
                local bp   = player:FindFirstChild("Backpack")
                if not char or not hum or not bp then return end
                local potion
                for _, name in ipairs(POTION_NAMES) do
                    local t = bp:FindFirstChild(name) or char:FindFirstChild(name)
                    if t and t:IsA("Tool") then potion = t break end
                end
                if not potion then return end

                if BackpackLock and BackpackLock.suspend then BackpackLock.suspend(1) end
                pcall(function()
                    if potion.Parent ~= char then hum:EquipTool(potion) end
                    potion:Activate()
                    task.delay(0.25, function()
                        if potion and potion.Parent == char and bp and bp.Parent then
                            pcall(function() potion.Parent = bp end)
                        end
                    end)
                end)
            end
            M.activate = activate
            local sessionToken = {}
            M.clearSession = function()
                for k in next, sessionToken do sessionToken[k] = nil end
            end

            local function isSteal(prompt)
                return prompt.ActionText == "Steal"
            end
            PPS.PromptButtonHoldBegan:Connect(function(prompt, plr)
                if plr ~= player or not M.enabled or not isSteal(prompt) then return end
                if isGiant() then return end
                if isStealAttrActive() then return end
                local myToken = {}
                sessionToken[prompt] = myToken
                local dur = (prompt.HoldDuration and prompt.HoldDuration > 0) and prompt.HoldDuration or 1
                task.delay(dur * 0.99, function()
                    if sessionToken[prompt] ~= myToken or not M.enabled then return end
                    if prompt and prompt.Parent and isInEnemyPlot() then pcall(activate) end
                end)
            end)
            PPS.PromptButtonHoldEnded:Connect(function(prompt, plr)
                if plr == player then sessionToken[prompt] = nil end
            end)
            PPS.PromptTriggered:Connect(function(prompt, plr)
                if plr == player then sessionToken[prompt] = nil end
            end)
        end)
    end)
    return M
end)()
local FlashTeleport = (function()
    local M = {
        active      = false,   -- armed while the Flash Teleport Panel is open
        giantPotion = false,
        mode        = "Timing",-- "Timing" or "Percent"
        timing      = 1.00,    -- seconds (1.00 - 1.50)
        percent     = 90,      -- percent of HoldDuration (80 - 100)
    }
    function M.setActive(v)      M.active      = v and true or false end
    function M.setGiantPotion(v) M.giantPotion = v and true or false end
    function M.setMode(v)        if v == "Percent" or v == "Timing" then M.mode = v end end
    function M.setTiming(v)      M.timing      = tonumber(v) or M.timing end
    function M.setPercent(v)     M.percent     = tonumber(v) or M.percent end
    task.spawn(function()
        pcall(function()
            local cloneref = cloneref or function(o) return o end
            local Players  = cloneref(game:GetService("Players"))
            local PPS      = cloneref(game:GetService("ProximityPromptService"))
            local player   = Players.LocalPlayer or Players.PlayerAdded:Wait()
            local FLASH_NAMES  = { "Flash Teleport", "FlashTeleport", "Flash Tele", "Flash" }
            local POTION_NAMES = { "Giant Potion", "Giant", "Grow Potion", "Super Grow", "Potion" }
            local function findTool(names)
                local char = player.Character
                local bp   = player:FindFirstChild("Backpack")
                for _, name in ipairs(names) do
                    local t = (bp and bp:FindFirstChild(name)) or (char and char:FindFirstChild(name))
                    if t and t:IsA("Tool") then return t end
                end
                return nil
            end
            local function fireFlash()
                local char = player.Character
                local hum  = char and char:FindFirstChildOfClass("Humanoid")
                if not char or not hum then return end
                local flash = findTool(FLASH_NAMES)
                if not flash then return end
                if BackpackLock and BackpackLock.suspend then pcall(function() BackpackLock.suspend(1) end) end
                pcall(function()
                    if flash.Parent ~= char then hum:EquipTool(flash) end
                    flash:Activate()
                end)
            end
            local function fireGiantPotion()
                local char = player.Character
                local hum  = char and char:FindFirstChildOfClass("Humanoid")
                local bp   = player:FindFirstChild("Backpack")
                if not char or not hum or not bp then return end
                local potion
                for _, name in ipairs(POTION_NAMES) do
                    local t = bp:FindFirstChild(name) or char:FindFirstChild(name)
                    if t and t:IsA("Tool") then potion = t break end
                end
                if not potion then return end
                if BackpackLock and BackpackLock.suspend then pcall(function() BackpackLock.suspend(1) end) end
                pcall(function()
                    if potion.Parent ~= char then hum:EquipTool(potion) end
                    potion:Activate()
                    task.delay(0.25, function()
                        if potion and potion.Parent == char and bp and bp.Parent then
                            pcall(function() potion.Parent = bp end)
                        end
                    end)
                end)
            end
            local function isSteal(prompt) return prompt.ActionText == "Steal" end
            local sessionToken = {}
            PPS.PromptButtonHoldBegan:Connect(function(prompt, plr)
                if plr ~= player or not M.active or not isSteal(prompt) then return end
                local myToken = {}
                sessionToken[prompt] = myToken
                local holdDur = (prompt.HoldDuration and prompt.HoldDuration > 0) and prompt.HoldDuration or 1
                local fireAt
                if M.mode == "Percent" then
                    fireAt = holdDur * (math.clamp(M.percent, 0, 100) / 100)
                else
                    fireAt = M.timing
                end
                task.delay(fireAt, function()
                    if sessionToken[prompt] ~= myToken or not M.active then return end
                    if not (prompt and prompt.Parent) then return end
                    fireFlash()
                    if M.giantPotion then task.defer(fireGiantPotion) end
                end)
            end)
            PPS.PromptButtonHoldEnded:Connect(function(prompt, plr)
                if plr == player then sessionToken[prompt] = nil end
            end)
            PPS.PromptTriggered:Connect(function(prompt, plr)
                if plr == player then sessionToken[prompt] = nil end
            end)
        end)
    end)
    return M
end)()
local AutoDefenseEnabled  = false
local AntiTPEnabled_state = false
task.spawn(function()

task.spawn(function()
    local cloneref          = cloneref or function(o) return o end
    local Players           = cloneref(game:GetService("Players"))
    local ReplicatedStorage = cloneref(game:GetService("ReplicatedStorage"))
    local Workspace         = cloneref(game:GetService("Workspace"))
    local player            = Players.LocalPlayer

    local DEFENSE_DEBUG = false
    local function defenseDebug(...)
        if DEFENSE_DEBUG then warn("[DefenseDebug]", ...) end
    end

    local function getAdminPanel()
        local ap = player.PlayerGui:FindFirstChild("AdminPanel")
        if not ap then return nil, nil end
        local panel = ap:FindFirstChild("AdminPanel")
        if not panel then return nil, nil end
        local content  = panel:FindFirstChild("Content")
        local profiles = panel:FindFirstChild("Profiles")
        if not content or not profiles then return nil, nil end
        return content:FindFirstChild("ScrollingFrame"), profiles:FindFirstChild("ScrollingFrame")
    end

    local lastFired     = { balloon = 0, ragdoll = 0, rocket = 0, inverse = 0, tiny = 0, jail = 0, jumpscare = 0, morph = 0 }
    -- Fallback cooldowns (only used if the in-game Timer can't be read). Kept
    -- tiny so we fire the instant the real cooldown clears -- the server-side
    -- Timer is the true gate, and respecting it is what stops the "That command
    -- is on cooldown" message from ever showing.
    local CMD_COOLDOWN  = { balloon = 0.05, ragdoll = 0.05 }
    local function stampCmds(cmds)
        for _, c in ipairs(cmds) do
            lastFired[c] = tick()
        end
    end
    -- Admin commands fire straight through the mapped admin RemoteFunction
    -- (resolved via the AdminPanel command box) -- no GUI-button clicking.
    local function executeAdminCommands(targetPlayer, cmds)
        if not _G._FH_ResolveAdminRemote() then
            defenseDebug("no admin remote resolved")
            return false
        end
        for _, cmd in ipairs(cmds) do
            task.spawn(function() _G._FH_FireAdmin(targetPlayer, cmd) end)
        end
        stampCmds(cmds)
        return true
    end

    local function cmdReady(cmdName)
        -- Delegate to the shared gate so Defense sees the same cooldown state
        -- as Quick Panel, Admin Spammer, and every other fire path.
        if _G._FH_IsOnCooldown then return not _G._FH_IsOnCooldown(cmdName) end
        -- Fallback when the global function isn't available yet.
        if tick() - (lastFired[cmdName] or 0) < 0.05 then return false end
        local cmdFrame = getAdminPanel()
        local f = cmdFrame and cmdFrame:FindFirstChild(cmdName)
        local t = f and f:FindFirstChild("Timer")
        if t then return not t.Visible end
        return tick() - (lastFired[cmdName] or 0) >= (CMD_COOLDOWN[cmdName] or 0.05)
    end

    local lastLaserTime = 0
    local function fireLaserOnce()
        if tick() - lastLaserTime < 1.5 then return end
        lastLaserTime = tick()
        if Aimbot and Aimbot.fireLaserCape then Aimbot.fireLaserCape(1) end
    end

    local function setHasReady(list)
        for _, cmd in ipairs(list) do
            if cmdReady(cmd) then return true end
        end
        return false
    end
    local function fireSet(target, list)
        local admin = {}
        for _, cmd in ipairs(list) do
            if cmdReady(cmd) then table.insert(admin, cmd) end
        end
        if #admin > 0 then
            defenseDebug("Sending", table.concat(admin, " "), target.Name)
            executeAdminCommands(target, admin)
        end
    end
    local function fireDefenseOn(target)
        local set1 = _G.__GH_DefCmds1 or { "balloon" }
        local set2 = _G.__GH_DefCmds2 or { "ragdoll" }
        if setHasReady(set1) then
            fireSet(target, set1)
        elseif setHasReady(set2) then
            fireSet(target, set2)
        elseif not (cmdReady("balloon") or cmdReady("ragdoll")) then
            defenseDebug("Laser Cape one shot", target.Name)
            fireLaserOnce()
        end
    end

    _G.__GH_DefenseExecute = executeAdminCommands
    _G.__GH_DefenseFire    = fireDefenseOn
    _G.__GH_FireLaserOnce  = fireLaserOnce

    local function getPlotOwner(plot)
        local sign  = plot:FindFirstChild("PlotSign")
        local frame = sign and sign:FindFirstChild("SurfaceGui") and sign.SurfaceGui:FindFirstChild("Frame")
        local label = frame and frame:FindFirstChild("TextLabel")
        if not label or label.Text == "Empty Base" then return nil end
        return label.Text:gsub("'s [Bb]ase$", ""):gsub("%s+$", "")
    end
    local function getMyPlot()
        local plots = Workspace:FindFirstChild("Plots")
        if not plots then return nil end
        local myName = player.DisplayName
        for _, plot in ipairs(plots:GetChildren()) do
            if getPlotOwner(plot) == myName then return plot end
        end
        return nil
    end
    local function getDefenseTargets()
        local myPlot = getMyPlot()
        if not myPlot then return {} end
        local ranked = {}
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= player then
                local char = plr.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                local hum = char and char:FindFirstChild("Humanoid")
                if hrp and hum and hum.Health > 0 then
                    local bestDist = math.huge
                    for _, obj in ipairs(myPlot:GetChildren()) do
                        if obj:IsA("Model") then
                            local root = obj.PrimaryPart or obj:FindFirstChild("HumanoidRootPart")
                            if root then
                                local dist = (hrp.Position - root.Position).Magnitude
                                if dist < bestDist then bestDist = dist end
                            end
                        elseif obj:IsA("BasePart") then
                            local dist = (hrp.Position - obj.Position).Magnitude
                            if dist < bestDist then bestDist = dist end
                        end
                    end
                    if bestDist <= 12 then
                        table.insert(ranked, { plr = plr, dist = bestDist })
                    end
                end
            end
        end
        table.sort(ranked, function(a, b) return a.dist < b.dist end)
        local out = {}
        for i = 1, math.min(2, #ranked) do table.insert(out, ranked[i].plr) end
        return out
    end

    local stealingDetected = false

    task.spawn(function()
        local descendants = ReplicatedStorage:GetDescendants()
        for i, obj in ipairs(descendants) do
            if obj:IsA("RemoteEvent") then
                obj.OnClientEvent:Connect(function(...)
                    for _, arg in ipairs({ ... }) do
                        if type(arg) == "string" then
                            local lower = arg:lower()
                            if lower:find("stealing") then
                                stealingDetected = true
                                defenseDebug("Text trigger", arg)
                            end
                            local execCmd = lower:match('successfully executed "(%a+)"')
                            if execCmd and lastFired[execCmd] ~= nil then lastFired[execCmd] = tick() end
                        end
                    end
                end)
            end
            if i % 200 == 0 then task.wait() end
        end
    end)

    for _, obj in ipairs(_deepChildren(Workspace)) do
        if obj:IsA("Sound") and obj.Name:lower():find("warn", 1, true) then
            obj:Destroy()
        end
    end
    local function playStealAlert(obj)
        pcall(function()
            local cam = Workspace.CurrentCamera
            if not cam then return end
            local alert = Instance.new("Sound")
            alert.SoundId = (obj and obj.SoundId and obj.SoundId ~= "") and obj.SoundId or "rbxassetid://9120386954"
            alert.Volume  = 1
            alert.RollOffMaxDistance = 0
            alert.Parent  = cam
            alert:Play()
            game:GetService("Debris"):AddItem(alert, 5)
        end)
    end
    Workspace.DescendantAdded:Connect(function(obj)
        if not obj:IsA("Sound") then return end
        if obj.Name:lower():find("warn", 1, true) then
            task.spawn(playStealAlert, obj)
            if AutoDefenseEnabled or AntiTPEnabled_state then
                obj:Destroy()
                stealingDetected = true
                defenseDebug("Sound trigger", obj.Name)
            end
        end
    end)

    task.spawn(function()
        while task.wait(0.1) do
            if AntiTPEnabled_state then
                local myPlot = getMyPlot()
                if myPlot then
                    for _, plr in ipairs(Players:GetPlayers()) do
                        if plr ~= player and plr.Parent == Players and plr.Character then
                            local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
                            if hrp then
                                for _, obj in ipairs(myPlot:GetChildren()) do
                                    if obj:IsA("Model") then
                                        local root = obj.PrimaryPart or obj:FindFirstChild("HumanoidRootPart")
                                        if root and (hrp.Position - root.Position).Magnitude < 9 then
                                            stealingDetected = true
                                            defenseDebug("Distance trigger", plr.Name, "near", obj.Name)
                                            break
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end)

    local lastExecuteTime = 0
    task.spawn(function()
        while task.wait(0.02) do
            if not (AutoDefenseEnabled or AntiTPEnabled_state) then
                stealingDetected = false
            elseif stealingDetected then
                stealingDetected = false
                if tick() - lastExecuteTime > 0.04 then
                    local valid = getDefenseTargets()
                    if #valid > 0 then
                        defenseDebug("Execute on", #valid, "target(s)")
                        fireDefenseOn(valid[1])
                        if valid[2] then fireDefenseOn(valid[2]) end
                        lastExecuteTime = tick()
                    end
                end
            end
        end
    end)
end)
local AutoGrab = (function()
    local M = { nearest = false, best = false, priorityGrab = false, _oneShot = false, progress = 0, hasTarget = false, priority = {} }
    function M.setNearest(v)      M.nearest      = v and true or false end
    function M.setBest(v)         M.best         = v and true or false end
    function M.setPriorityGrab(v) M.priorityGrab = v and true or false end
    function M.togglePriority(name)
        if M.priority[name] then M.priority[name] = nil else M.priority[name] = true end
        return M.priority[name] == true
    end
    function M.isPriority(name) return M.priority[name] == true end
    function M.hasPriority()    return next(M.priority) ~= nil end
    M.animalList = {}
    task.spawn(function()
        local ok, err = pcall(function()
            local cloneref          = cloneref or function(o) return o end
            local Players           = cloneref(game:GetService("Players"))
            local ReplicatedStorage = cloneref(game:GetService("ReplicatedStorage"))
            local Workspace         = cloneref(game:GetService("Workspace"))
            local player            = Players.LocalPlayer or Players.PlayerAdded:Wait()
            local V1_RED_PHASE        = 1.5
            local V1_PROXIMITY_RADIUS = 10
            local function _tryReq(mod)
                if not mod then return nil end
                local ok, res = pcall(require, mod)
                return ok and res or nil
            end
            local AnimalsData   = _tryReq(ReplicatedStorage:WaitForChild("Datas",   10):WaitForChild("Animals",     10))
            local NumberUtils   = _tryReq(ReplicatedStorage:WaitForChild("Utils",   10):WaitForChild("NumberUtils", 10))
            local AnimalsShared = _tryReq(ReplicatedStorage:WaitForChild("Shared",  10):WaitForChild("Animals",     10))
            if not AnimalsShared then AnimalsShared = { GetGeneration = function() return 0 end } end
            if not AnimalsData   then AnimalsData   = setmetatable({}, { __index = function() return {} end }) end
            if not NumberUtils   then
                NumberUtils = {
                    ToString = function(_, n)
                        if type(n) ~= "number" then return "0" end
                        if     n >= 1e12 then return string.format("%.1fT", n / 1e12)
                        elseif n >= 1e9  then return string.format("%.1fB", n / 1e9)
                        elseif n >= 1e6  then return string.format("%.1fM", n / 1e6)
                        elseif n >= 1e3  then return string.format("%.1fK", n / 1e3)
                        else return tostring(math.floor(n)) end
                    end
                }
            end
            local SyncRemotes = (function()
                local folder = ReplicatedStorage:WaitForChild("Packages", 15):WaitForChild("Synchronizer")
                return {
                    channelFolder = folder:WaitForChild("Channel"),
                    routeRemote   = folder:WaitForChild("CommunicationRoute"),
                    requestData   = folder:FindFirstChild("RequestData"),
                }
            end)()
            local PlotSync = { caches = {}, connections = {} }
            local function splitPath(path)
                if typeof(path) == "table" then return path end
                local out = {}
                for part in string.gmatch(tostring(path), "[^%.]+") do
                    table.insert(out, tonumber(part) or part)
                end
                return out
            end
            local function resolvePath(path, root)
                local current, parent, key = root, nil, nil
                for _, part in ipairs(splitPath(path)) do
                    parent = current; key = part
                    current = current and current[part] or nil
                end
                return current, parent, key
            end
            local function isMyPlot(plot)
                if not plot or not plot:IsA("Model") then return false end
                local sign = plot:FindFirstChild("PlotSign")
                return sign and sign:FindFirstChild("YourBase") and sign.YourBase.Enabled
            end
            local function applyDiff(channelName, packet)
                local cache = PlotSync.caches[channelName]
                if typeof(cache) ~= "table" then return end
                local path, action, a, b = packet[1], packet[2], packet[3], packet[4]
                local current, parent, key = resolvePath(path, cache)
                if action == "Changed" then
                    if parent ~= nil then parent[key] = a end
                elseif action == "ArrayInsert" then
                    if current ~= nil then table.insert(current, b, a) end
                elseif action == "ArrayRemoved" then
                    if current ~= nil then table.remove(current, b) end
                elseif action == "DictionaryInsert" then
                    if current ~= nil then current[b] = a end
                elseif action == "DictionaryRemoved" then
                    if current ~= nil then current[b] = nil end
                end
            end
            local function attachChannel(remote)
                if PlotSync.connections[remote] then return end
                local plots = Workspace:FindFirstChild("Plots")
                local channelName = tostring(remote.Name)
                if not (plots and plots:FindFirstChild(channelName)) then return end
                if SyncRemotes.requestData and PlotSync.caches[channelName] == nil then
                    local okd, data = pcall(function() return SyncRemotes.requestData:InvokeServer(channelName) end)
                    PlotSync.caches[channelName] = okd and typeof(data) == "table" and data or {}
                elseif PlotSync.caches[channelName] == nil then
                    PlotSync.caches[channelName] = {}
                end
                PlotSync.connections[remote] = remote.OnClientEvent:Connect(function(queue)
                    for _, packet in ipairs(queue) do applyDiff(channelName, packet) end
                end)
            end
            local function detachChannel(channelName)
                for remote, conn in pairs(PlotSync.connections) do
                    if tostring(remote.Name) == tostring(channelName) then
                        conn:Disconnect()
                        PlotSync.connections[remote] = nil
                        PlotSync.caches[tostring(channelName)] = nil
                        break
                    end
                end
            end
            local function refreshCache(channelName)
                if not SyncRemotes.requestData then return end
                local okd, data = pcall(function() return SyncRemotes.requestData:InvokeServer(channelName) end)
                if okd and typeof(data) == "table" then PlotSync.caches[channelName] = data end
            end
            local function getStealPrompt(plot, slot)
                local podiums = plot and plot:FindFirstChild("AnimalPodiums")
                local podium  = podiums and podiums:FindFirstChild(tostring(slot))
                local spawn   = podium and podium:FindFirstChild("Base") and podium.Base:FindFirstChild("Spawn")
                local att     = spawn and spawn:FindFirstChild("PromptAttachment")
                local prompt  = att and att:FindFirstChildWhichIsA("ProximityPrompt")
                if not (prompt and prompt.Parent) then return nil end
                return prompt, spawn
            end
            local function scanAllPlots()
                local result = {}
                local plots = Workspace:FindFirstChild("Plots")
                if not plots then return result end
                for _, plot in ipairs(plots:GetChildren()) do
                    if not isMyPlot(plot) then
                        pcall(function()
                            local cache = PlotSync.caches[plot.Name]
                            local animalList = cache and cache.AnimalList
                            if typeof(animalList) ~= "table" then return end
                            for slot, data in pairs(animalList) do
                                if typeof(data) == "table" and data.Index then
                                    local prompt, spawn = getStealPrompt(plot, slot)
                                    if prompt and spawn then
                                        local genValue = AnimalsShared:GetGeneration(data.Index, data.Mutation, data.Traits, nil)
                                        local info = AnimalsData[data.Index]
                                        table.insert(result, {
                                            plotName = plot.Name,
                                            pod = tonumber(slot) or 0,
                                            pos = spawn.Position,
                                            prompt = prompt,
                                            genValue = genValue,
                                            displayName = (info and info.DisplayName) or tostring(data.Index),
                                            mutation = data.Mutation,
                                            traits = data.Traits,
                                        })
                                    end
                                end
                            end
                        end)
                    end
                end
                table.sort(result, function(a, b) return a.genValue > b.genValue end)
                return result
            end
            local CachedBrainrots = {}
            for _, child in ipairs(SyncRemotes.channelFolder:GetChildren()) do
                if child:IsA("RemoteEvent") then attachChannel(child) end
            end
            SyncRemotes.channelFolder.ChildAdded:Connect(function(child)
                if child:IsA("RemoteEvent") then attachChannel(child) end
            end)
            SyncRemotes.routeRemote.OnClientEvent:Connect(function(actions)
                local plots = Workspace:FindFirstChild("Plots")
                if not plots then return end
                for _, action in ipairs(actions) do
                    local kind, channelName = action[1], tostring(action[2])
                    if plots:FindFirstChild(channelName) then
                        if kind == "ListenerAdded" then
                            local remote = SyncRemotes.channelFolder:FindFirstChild(channelName)
                            if remote and remote:IsA("RemoteEvent") then attachChannel(remote) end
                        elseif kind == "ListenerRemoved" then
                            detachChannel(channelName)
                        end
                    end
                end
            end)
            task.spawn(function()
                local lastFullRefresh = 0
                while true do
                    local need = M.nearest or M.best or M.priorityGrab or M._oneShot or (_G._FH_GammaNeedList == true)
                    if not need then
                        task.wait(1)
                    else
                        task.wait(0.3)
                        pcall(function()
                            local plots = Workspace:FindFirstChild("Plots")
                            if not plots then return end
                            if os.clock() - lastFullRefresh >= 3 then
                                lastFullRefresh = os.clock()
                                for _, plot in ipairs(plots:GetChildren()) do
                                    if not isMyPlot(plot) then refreshCache(plot.Name) end
                                end
                            end
                            CachedBrainrots = scanAllPlots()
                            local list = {}
                            for _, br in ipairs(CachedBrainrots) do
                                if br.displayName then
                                    list[#list + 1] = {
                                        name = br.displayName, mutation = br.mutation,
                                        traits = br.traits, genValue = br.genValue,
                                        plotName = br.plotName, pod = br.pod,
                                    }
                                end
                            end
                            table.sort(list, function(a, b) return (a.genValue or 0) > (b.genValue or 0) end)
                            M.animalList = list
                        end)
                    end
                end
            end)
            local function getNearest()
                local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                if not hrp then return nil end
                local best, bestDist = nil, math.huge
                for _, br in ipairs(CachedBrainrots) do
                    local d = (br.pos - hrp.Position).Magnitude
                    if d < bestDist then bestDist = d; best = br end
                end
                return best
            end
            local function getBest()
                return CachedBrainrots[1]
            end
            local function getPriorityTarget()
                if not M.hasPriority() then return nil end
                local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                if not hrp then return nil end
                local best, bestDist = nil, math.huge
                for _, br in ipairs(CachedBrainrots) do
                    local brsig = tostring(br.plotName or "") .. "::" .. tostring(br.pod or 0) .. "::" .. tostring(br.displayName or "")
                    if M.priority[brsig] then
                        local d = (br.pos - hrp.Position).Magnitude
                        if d < bestDist then bestDist = d; best = br end
                    end
                end
                return best
            end
            local function isActive() return M.nearest or M.best or M.priorityGrab or M._oneShot end
            local function harvest(prompt)
                local hold, trigger = {}, {}
                if type(getconnections) ~= "function" then return hold, trigger end
                local ok1, c1 = pcall(getconnections, prompt.PromptButtonHoldBegan)
                if ok1 then for _, c in ipairs(c1) do if type(c.Function) == "function" then table.insert(hold, c.Function) end end end
                local ok2, c2 = pcall(getconnections, prompt.Triggered)
                if ok2 then for _, c in ipairs(c2) do if type(c.Function) == "function" then table.insert(trigger, c.Function) end end end
                return hold, trigger
            end
            local MIN_HOLD  = 1.3
            local WAIT_STOP = 2.6
            M.waitUntil = 0
            local grabActive = {}
            local function firePatchedSteal(prompt)
                if not prompt or not prompt.Parent then return false end
                if grabActive[prompt] then return false end
                grabActive[prompt] = true
                local hold, trigger = harvest(prompt)
                if #hold == 0 and #trigger == 0 then
                    grabActive[prompt] = nil
                    if type(fireproximityprompt) == "function" then pcall(fireproximityprompt, prompt) end
                    return false
                end
                local origDist = prompt.MaxActivationDistance
                pcall(function() prompt.MaxActivationDistance = 9e9 end)
                pcall(function() prompt.RequiresLineOfSight = false end)
                for _, fn in ipairs(hold) do task.spawn(fn) end
                local startedAt = tick()
                while tick() - startedAt < MIN_HOLD do
                    if not isActive() then break end
                    M.progress = math.clamp((tick() - startedAt) / MIN_HOLD, 0, 1)
                    RunService.RenderStepped:Wait()
                end
                M.progress = 1
                local function dist()
                    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                    if not hrp or not prompt.Parent then return math.huge end
                    local pp  = prompt.Parent
                    local pos = pp:IsA("Attachment") and pp.WorldPosition or (pp:IsA("BasePart") and pp.Position) or nil
                    if not pos then return math.huge end
                    return (hrp.Position - pos).Magnitude
                end

                local alreadyInRange = dist() <= 10
                local fired = false
                M.waitUntil = startedAt + WAIT_STOP
                while isActive() do
                    local elapsed = tick() - startedAt
                    if elapsed > WAIT_STOP then break end
                    if not prompt.Parent then break end
                    if dist() <= 10 then
                        if not alreadyInRange then task.wait(0.3) end
                        if AutoBigPotion.enabled and AutoBigPotion.activate and isInEnemyPlot() then pcall(AutoBigPotion.activate) end
                        if prompt.Parent and #trigger > 0 then
                            for _, fn in ipairs(trigger) do task.spawn(fn) end
                            fired = true
                        end
                        break
                    end
                    RunService.RenderStepped:Wait()
                end
                M.waitUntil = 0
                if prompt and prompt.Parent then
                    pcall(function() prompt.MaxActivationDistance = origDist end)
                end
                grabActive[prompt] = nil
                M.progress = 0
                return fired
            end
            local function loop()
                while isActive() do
                    local target
                    if M.priorityGrab then target = getPriorityTarget()
                    elseif M.best then     target = getBest()
                    else                   target = getNearest() end
                    local prompt = target and target.prompt
                    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                    if prompt and prompt.Parent and hrp then
                        local pp = prompt.Parent
                        local promptPos = (pp:IsA("Attachment") and pp.WorldPosition)
                            or (pp:IsA("BasePart") and pp.Position) or target.pos
                        local dist = promptPos and (hrp.Position - promptPos).Magnitude or math.huge
                        if dist > 30 then
                            M.hasTarget = false
                            M.progress  = 0
                            task.wait(0.05)
                        else
                            M.hasTarget  = true
                            M.targetName = target.displayName or "Brainrot"
                            M.targetGen  = target.genValue or 0
                            firePatchedSteal(prompt)
                        end
                    else
                        M.hasTarget = false
                        M.progress  = 0
                        task.wait(0.05)
                    end
                end
                M.progress  = 0
                M.hasTarget = false
                M.waitUntil = 0
            end
            while true do
                if isActive() then loop() end
                task.wait(0.2)
            end
        end)
    end)
    return M
end)()
do
    local bar = Instance.new("Frame")
    bar.Name                   = "AutoGrabBar"
    bar.Size                   = UDim2.new(0, 210, 0, 44)
    bar.Position               = UDim2.new(0.5, -105, 0.5, -22)
    bar.BackgroundColor3       = T.Bg
    bar.BackgroundTransparency = 0.05
    bar.BorderSizePixel        = 0
    bar.Active                 = true
    bar.Visible                = false
    bar.ZIndex                 = 60
    bar.Parent                 = GUI
    _newScale(bar)
    trackBgFrame(bar, "Bg")
    do
        local pp = Config.get("panelpos:AutoGrabBar", nil)
        if type(pp) == "table" and #pp == 4 then
            bar.Position = UDim2.new(pp[1], pp[2], pp[3], pp[4])
        end
    end
    local function _grabClampOnScreen()
        local vp = GUI.AbsoluteSize
        if vp.X < 1 or vp.Y < 1 then return end
        local abs = bar.AbsolutePosition
        local sz  = bar.AbsoluteSize
        local nx  = math.clamp(abs.X, 0, math.max(0, vp.X - sz.X))
        local ny  = math.clamp(abs.Y, 0, math.max(0, vp.Y - sz.Y))
        if math.abs(nx - abs.X) > 0.5 or math.abs(ny - abs.Y) > 0.5 then
            bar.Position = UDim2.new(0, nx, 0, ny)
        end
    end
    bar:GetPropertyChangedSignal("Visible"):Connect(function()
        if bar.Visible then task.defer(_grabClampOnScreen) end
    end)
    Corner(bar, 10)
    GradStroke(bar, 2, 0, 135)
    local Shadow = Instance.new("ImageLabel")
    Shadow.Size                   = UDim2.new(1, 30, 1, 30)
    Shadow.Position               = UDim2.new(0, -15, 0, -15)
    Shadow.BackgroundTransparency = 1
    Shadow.Image                  = "rbxassetid://5028857084"
    Shadow.ImageColor3            = Color3.fromRGB(0, 0, 0)
    Shadow.ImageTransparency      = 0.55
    Shadow.ScaleType              = Enum.ScaleType.Slice
    Shadow.SliceCenter            = Rect.new(24, 24, 276, 276)
    Shadow.ZIndex                 = 59
    Shadow.Parent                 = bar
    local dot = Instance.new("Frame")
    dot.Size             = UDim2.new(0, 6, 0, 6)
    dot.Position         = UDim2.new(0, 12, 0, 11)
    dot.BackgroundColor3 = T.White
    dot.BorderSizePixel  = 0
    dot.ZIndex           = 61
    dot.Parent           = bar
    Corner(dot, 3)
    Grad(dot, nil, nil, 0)
    local title = Lbl(bar, "AUTO GRAB", 11, T.Text, Enum.Font.GothamBold)
    title.Size     = UDim2.new(1, -100, 0, 14)
    title.Position = UDim2.new(0, 24, 0, 7)
    title.ZIndex   = 61
    local pct = Lbl(bar, "0%", 11, T.TextDim, Enum.Font.GothamBold, Enum.TextXAlignment.Right)
    pct.Size     = UDim2.new(0, 80, 0, 14)
    pct.Position = UDim2.new(1, -92, 0, 7)
    pct.ZIndex   = 61
    local track = Instance.new("Frame")
    track.Size             = UDim2.new(1, -24, 0, 8)
    track.Position         = UDim2.new(0, 12, 1, -16)
    track.BackgroundColor3 = T.Soft
    track.BorderSizePixel  = 0
    track.ClipsDescendants = true
    track.ZIndex           = 61
    track.Parent           = bar
    trackBgFrame(track, "Soft")
    Corner(track, 4)
    local fill = Instance.new("Frame")
    fill.Size             = UDim2.new(0, 0, 1, 0)
    fill.BackgroundColor3 = T.White
    fill.BorderSizePixel  = 0
    fill.ZIndex           = 62
    fill.Parent           = track
    Corner(fill, 4)
    Grad(fill, nil, nil, 0)

    local grabBarLocked = Config.get("grabbar_locked", true)

    local barLockBtn = Instance.new("TextButton")
    barLockBtn.Name              = "BarLockBtn"
    barLockBtn.Size              = UDim2.new(0, 16, 0, 16)
    barLockBtn.Position          = UDim2.new(1, -20, 0, 4)
    barLockBtn.BackgroundColor3  = T.BgDeep
    barLockBtn.BorderSizePixel   = 0
    barLockBtn.Text              = grabBarLocked and "🔒" or "🔓"
    barLockBtn.Font              = Enum.Font.GothamBold
    barLockBtn.TextSize          = 10
    barLockBtn.TextColor3        = grabBarLocked and Color3.fromRGB(255, 200, 60) or T.TextMute
    barLockBtn.AutoButtonColor   = false
    barLockBtn.ZIndex            = 63
    barLockBtn.Parent            = bar
    Corner(barLockBtn, 4)
    barLockBtn.Activated:Connect(function()
        grabBarLocked = not grabBarLocked
        barLockBtn.Text       = grabBarLocked and "🔒" or "🔓"
        barLockBtn.TextColor3 = grabBarLocked and Color3.fromRGB(255, 200, 60) or T.TextMute
        Config.set("grabbar_locked", grabBarLocked)
    end)
    barLockBtn.MouseEnter:Connect(function() Tween(barLockBtn, F, {BackgroundColor3 = T.CardHover}) end)
    barLockBtn.MouseLeave:Connect(function() Tween(barLockBtn, F, {BackgroundColor3 = T.BgDeep}) end)
    do
        local dragging, ds, ws, moved
        bar.InputBegan:Connect(function(inp)
            if guiLocked or grabBarLocked then return end
            if inp.UserInputType == Enum.UserInputType.MouseButton1
            or inp.UserInputType == Enum.UserInputType.Touch then
                dragging = true; ds = inp.Position; ws = bar.Position; moved = false
            end
        end)
        bar.InputEnded:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1
            or inp.UserInputType == Enum.UserInputType.Touch then
                if dragging then
                    dragging = false
                    local p = bar.Position
                    Config.set("panelpos:AutoGrabBar", { p.X.Scale, p.X.Offset, p.Y.Scale, p.Y.Offset })
                end
            end
        end)
        UserInputService.InputChanged:Connect(function(inp)
            if dragging and (inp.UserInputType == Enum.UserInputType.MouseMovement
            or inp.UserInputType == Enum.UserInputType.Touch) then
                local d = inp.Position - ds
                if not moved then
                    if d.Magnitude < 8 then return end
                    moved = true; ds = inp.Position; return
                end
                bar.Position = UDim2.new(ws.X.Scale, ws.X.Offset + d.X, ws.Y.Scale, ws.Y.Offset + d.Y)
            end
        end)
    end
    local function fmtGen(n)
        n = tonumber(n) or 0
        local s, i = { "", "K", "M", "B", "T", "Qa", "Qi" }, 1
        while n >= 1000 and i < #s do n = n / 1000; i = i + 1 end
        return string.format(i == 1 and "$%d%s/s" or "$%.1f%s/s", n, s[i])
    end
    local shown = 0
    local _barAcc = 0
    local _barConn; _barConn = RunService.Heartbeat:Connect(LPH_NO_VIRTUALIZE(function(dt)
        if _GEN ~= _G._FH_GAMMA_GEN then _barConn:Disconnect(); return end
        local on = AutoGrab.nearest or AutoGrab.best or AutoGrab.priorityGrab
        if bar.Visible ~= on then bar.Visible = on end
        if not on then return end

        local wu = AutoGrab.waitUntil or 0
        if wu <= tick() then
            local p = math.clamp(AutoGrab.progress or 0, 0, 1)
            shown = shown + (p - shown) * math.clamp(dt * 14, 0, 1)
        end

        _barAcc = _barAcc + dt
        if _barAcc < (isMobile and 1/15 or 1/30) then return end
        _barAcc = 0
        if wu > tick() then
            local remain = math.max(0, wu - tick())
            shown = 1
            fill.Size      = UDim2.new(1, 0, 1, 0)
            title.Text     = AutoGrab.targetName or "Waiting..."
            pct.Text       = string.format("%.1fs", remain)
            pct.TextColor3 = T.TextMute
            return
        end
        fill.Size = UDim2.new(math.clamp(shown, 0, 1), 0, 1, 0)
        if AutoGrab.hasTarget then
            title.Text     = AutoGrab.targetName or "Stealing..."
            pct.Text       = fmtGen(AutoGrab.targetGen)
            pct.TextColor3 = T.Text
        else
            title.Text     = "AUTO GRAB"
            pct.Text       = "searching..."
            pct.TextColor3 = T.TextMute
        end
    end))
end
local _FH_CarpetTP_Speed = 214
local _FH_CarpetTP
do
    local LP = Players.LocalPlayer
    local function stripTool(tool)
        if not LP then return end
        if not tool or not tool:IsA("Tool") then return end
        local hrpD = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
        for _, d in ipairs(_deepChildren(tool)) do
            if d:IsA("BasePart") then
                pcall(function()
                    d.Massless   = true
                    d.CanCollide = false
                    if hrpD then hrp.Velocity = Vector3.zero end
                end)
            end
        end
        tool.DescendantAdded:Connect(function(d)
            if d:IsA("BasePart") then
                local hrpD2 = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
                pcall(function()
                    d.Massless   = true
                    d.CanCollide = false
                    if hrpD2 then hrp.Velocity = Vector3.zero end
                end)
            end
        end)
    end
    local function wireChar(c)
        for _, t in ipairs(c:GetChildren()) do stripTool(t) end
        c.ChildAdded:Connect(stripTool)
    end
    if LP and LP.Character then wireChar(LP.Character) end
    if LP then LP.CharacterAdded:Connect(wireChar) end
end
local _fhCarpetActiveTween
_FH_CarpetTP = function(targetCF, speedOverride)
    local lp  = Players.LocalPlayer
    if lp and lp:GetAttribute("Stealing") ~= nil then return end
    local chr = lp and lp.Character
    local hrp = chr and chr:FindFirstChild("HumanoidRootPart")
    if not hrp or not targetCF then return end
    if typeof(targetCF) == "Vector3" then targetCF = CFrame.new(targetCF) end
    local dist = (hrp.Position - targetCF.Position).Magnitude
    local dur  = math.max(0.05, dist / (speedOverride or _FH_CarpetTP_Speed or 214))
    local bp     = lp:FindFirstChildOfClass("Backpack")
    local carpet = (bp and bp:FindFirstChild(_FH_ActiveMount)) or chr:FindFirstChild(_FH_ActiveMount)
    local hum    = chr:FindFirstChildOfClass("Humanoid")
    if carpet and hum and carpet.Parent ~= chr then
        if BackpackLock and BackpackLock.suspend then pcall(function() BackpackLock.suspend(math.max(0.5, dur + 0.3)) end) end
        pcall(function() hum:EquipTool(carpet) end)
    end
    if _fhCarpetActiveTween then pcall(function() _fhCarpetActiveTween:Cancel() end) end
    local tw = TweenService:Create(hrp, TweenInfo.new(dur, Enum.EasingStyle.Linear), { CFrame = targetCF })
    _fhCarpetActiveTween = tw
    tw:Play()
    return tw
end
local _FH_StealRemote
local _FH_TripRemote
do
    local ok, NetMod = pcall(function() return game:GetService("ReplicatedStorage"):WaitForChild("Packages"):WaitForChild("Net") end)
    if ok and NetMod then
        local okClone, NetClone = pcall(function() return require(NetMod:Clone()) end)
        if okClone and NetClone then
            local function getRemote(uuid)
                local okr, rn = pcall(function() return NetClone:RemoteEvent(uuid) end)
                if okr and rn then return NetMod:FindFirstChild(tostring(rn)) end
                return nil
            end
            _FH_StealRemote = getRemote("3ba148c9-7ed6-4675-93f8-9f7c356a2c54")
            _FH_TripRemote  = getRemote("f40f7d9e-2f0d-4167-b250-899273f46874")
            _G._FH_GetRemote = _G._FH_GetRemote or getRemote
            _G._FH_UseItemRemote = _G._FH_UseItemRemote
                or (_G._FH_ResolveUseItemRemote and _G._FH_ResolveUseItemRemote())
                or getRemote("UseItem") or getRemote("RE/UseItem")
            _FH_UseItemRemote = _G._FH_UseItemRemote
        end
    end
end
local _FH_TRIP_U1  = "68c86eb7-eb7e-4b4d-96ae-cf7cd847c5b0"
local _FH_TRIP_U2  = "07b9cc25-2a1f-4a26-a0ec-f2fab578d8bd"
local _FH_STEAL_U1 = "cda5c764-d4e3-45c4-94e4-53a538347590"
local _FH_STEAL_U2 = "8c852fbf-d542-4ef4-aa28-612e24db8d4a"
local function _FH_ResolvePromptTarget(prompt)
    if not prompt or not prompt.Parent then return nil end
    local att    = prompt.Parent
    local spawn  = att and att.Parent
    local base   = spawn and spawn.Parent
    local podium = base and base.Parent
    local pods   = podium and podium.Parent
    local plot   = pods and pods.Parent
    local pod    = podium and tonumber(podium.Name)
    if not (plot and pod) then return nil end
    return { plotName = plot.Name, pod = pod }
end
local function _FH_StartTrip(target)
    local T0 = workspace:GetServerTimeNow()
    if _FH_TripRemote then
        pcall(function() _FH_TripRemote:FireServer(T0 + 124, _FH_TRIP_U1) end)
        pcall(function() _FH_TripRemote:FireServer(T0 + 124, _FH_TRIP_U2) end)
    end
    _G._FH_LastStealStart = tick()
    return { t0 = T0, startedAt = tick(), target = target }
end
local function _FH_FinishSteal(ctx)
    if not ctx or not ctx.target or not _FH_StealRemote then return false end
    local elapsed = tick() - ctx.startedAt
    if elapsed < 1.3 then task.wait(1.3 - elapsed) end
    local ts = ctx.t0 + 1.3 + 31
    pcall(function() _FH_StealRemote:FireServer(ts, _FH_STEAL_U1, ctx.target.plotName, ctx.target.pod) end)
    pcall(function() _FH_StealRemote:FireServer(ts, _FH_STEAL_U2, ctx.target.plotName, ctx.target.pod) end)
    return true
end
local __MIN_HOLD_TIME_v2       = 1.3
local __TRIGGER_AFTER_GREEN_v2 = 0.02
local __stealCbCache_v2 = setmetatable({}, { __mode = "k" })
local function __buildStealCallbacks_v2(prompt)
    if __stealCbCache_v2[prompt] then return __stealCbCache_v2[prompt] end
    if type(getconnections) ~= "function" then return nil end
    local data = { hold = {}, trigger = {} }
    local ok1, c1 = pcall(getconnections, prompt.PromptButtonHoldBegan)
    if ok1 then for _, c in ipairs(c1) do if type(c.Function) == "function" then table.insert(data.hold, c.Function) end end end
    local ok2, c2 = pcall(getconnections, prompt.Triggered)
    if ok2 then for _, c in ipairs(c2) do if type(c.Function) == "function" then table.insert(data.trigger, c.Function) end end end
    if #data.hold == 0 and #data.trigger == 0 then return nil end
    __stealCbCache_v2[prompt] = data
    return data
end
local __FH_v2 = {}
function __FH_v2.startStealHold(prompt, method)
    if not prompt or not prompt.Parent then return nil end
    local cb = __buildStealCallbacks_v2(prompt)
    if not cb then return nil end
    for _, fn in ipairs(cb.hold) do task.spawn(fn) end
    local now = tick()
    return {
        prompt = prompt, cb = cb, method = method,
        ragdollFireTime = now, startedAt = now,
        holdBeganAt = now, holdDone = true,
    }
end
function __FH_v2.doHoldAndWait(ctx)
    if ctx.holdDone then return end
    for _, fn in ipairs(ctx.cb.hold) do task.spawn(fn) end
    ctx.holdBeganAt = tick()
    task.wait(__MIN_HOLD_TIME_v2)
    ctx.holdDone = true
end
function __FH_v2.waitForStealTime(ctx, sec)
    if not ctx then return end
    if sec >= 1.0 then return end
    local elapsed = tick() - ctx.ragdollFireTime
    if elapsed < sec then task.wait(sec - elapsed) end
end
function __FH_v2.finishStealHold(ctx)
    if not ctx then return false end
    if not ctx.holdBeganAt then __FH_v2.doHoldAndWait(ctx) end
    local heldFor = tick() - (ctx.holdBeganAt or tick())
    if heldFor < __MIN_HOLD_TIME_v2 then task.wait(__MIN_HOLD_TIME_v2 - heldFor) end
    task.wait(__TRIGGER_AFTER_GREEN_v2)
    for _, fn in ipairs(ctx.cb.trigger) do task.spawn(fn) end
    return true
end
local HalfwaySteal = (function()
    local M = { potion = false, debounce = false, method = "Walk", _semiStealCtx = nil }
    function M.setPotion(v) M.potion = v and true or false end
    function M.setMethod(v) M.method = (v == "Prime") and "Prime" or "Walk" end

    local cloneref          = cloneref or function(o) return o end
    local Players           = cloneref(game:GetService("Players"))
    local Workspace         = cloneref(game:GetService("Workspace"))
    local player            = Players.LocalPlayer or Players.PlayerAdded:Wait()
    M.player = player

    local BASES = {
        b1 = { refVec = Vector3.new(-337, -5, 100), finalPos = Vector3.new(-337,    -5,    103)   },
        b2 = { refVec = Vector3.new(-335, -5,  20), finalPos = Vector3.new(-334.80, -5.04, 18.90) },
    }
    local RIGHT_BASE = CFrame.new(-371, -6, 30)
    local LEFT_BASE  = CFrame.new(-373, -7, 83)

    local FFLAGS = {
        GameNetPVHeaderRotationalVelocityZeroCutoffExponent           = -5000,
        LargeReplicatorWrite5                                         = true,
        LargeReplicatorEnabled9                                       = true,
        AngularVelociryLimit                                          = 360,
        TimestepArbiterVelocityCriteriaThresholdTwoDt                 = 2147483646,
        S2PhysicsSenderRate                                           = 15000,
        DisableDPIScale                                               = true,
        MaxDataPacketPerSend                                          = 2147483647,
        PhysicsSenderMaxBandwidthBps                                  = 20000,
        TimestepArbiterHumanoidLinearVelThreshold                     = 21,
        MaxMissedWorldStepsRemembered                                 = -2147483648,
        PlayerHumanoidPropertyUpdateRestrict                          = true,
        SimDefaultHumanoidTimestepMultiplier                          = 0,
        StreamJobNOUVolumeLengthCap                                   = 2147483647,
        DebugSendDistInSteps                                          = -2147483648,
        GameNetDontSendRedundantNumTimes                              = 1,
        CheckPVLinearVelocityIntegrateVsDeltaPositionThresholdPercent = 1,
        CheckPVDifferencesForInterpolationMinVelThresholdStudsPerSecHundredth = 1,
        LargeReplicatorSerializeRead3                                 = true,
        ReplicationFocusNouExtentsSizeCutoffForPauseStuds             = 2147483647,
        CheckPVCachedVelThresholdPercent                              = 10,
        CheckPVDifferencesForInterpolationMinRotVelThresholdRadsPerSecHundredth = 1,
        GameNetDontSendRedundantDeltaPositionMillionth                = 1,
        InterpolationFrameVelocityThresholdMillionth                  = 5,
        StreamJobNOUVolumeCap                                         = 2147483647,
        InterpolationFrameRotVelocityThresholdMillionth               = 5,
        CheckPVCachedRotVelThresholdPercent                           = 10,
        WorldStepMax                                                  = 30,
        InterpolationFramePositionThresholdMillionth                  = 5,
        TimestepArbiterHumanoidTurningVelThreshold                    = 1,
        SimOwnedNOUCountThresholdMillionth                            = 2147483647,
        GameNetPVHeaderLinearVelocityZeroCutoffExponent               = -5000,
        NextGenReplicatorEnabledWrite4                                = true,
        TimestepArbiterOmegaThou                                      = 1073741823,
        MaxAcceptableUpdateDelay                                      = 1,
        LargeReplicatorSerializeWrite4                                = true,
    }
    local function SSSetFFlags()
        if type(setfflag) ~= "function" then return end
        for k, v in pairs(FFLAGS) do pcall(function() setfflag(k, tostring(v)) end) end
    end
    M.SSSetFFlags = SSSetFFlags

    local function SSEquipGrapple()

        if BackpackLock and BackpackLock.suspend then BackpackLock.suspend(4) end
        local char = player.Character
        local bp   = player:FindFirstChild("Backpack")
        if not char or not bp then return end
        for _, tool in ipairs(char:GetChildren()) do
            if tool:IsA("Tool") then tool.Parent = bp end
        end
        local carpet = bp:FindFirstChild(_FH_ActiveMount)
        if carpet then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then pcall(function() hum:EquipTool(carpet) end) end
        end
    end
    M.SSEquipGrapple = SSEquipGrapple

    function M.SSTeleportHRP(position)
        local character = player.Character or player.CharacterAdded:Wait()
        local hrp = character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        hrp.Velocity = Vector3.zero
        _FH_CarpetTP(CFrame.new(position))
    end

    local function _stealIsGiant()
        local c   = player.Character
        local hum = c and c:FindFirstChildOfClass("Humanoid")
        if not hum then return false end
        local scale = hum:FindFirstChild("BodyHeightScale")
            or hum:FindFirstChild("BodyDepthScale")
            or hum:FindFirstChild("BodyWidthScale")
        return scale and scale:IsA("NumberValue") and scale.Value >= 2.5
    end

    local function drinkPotion()
        if (M.potion or AutoBigPotion.enabled) and not _stealIsGiant() and AutoBigPotion.activate and isInEnemyPlot() then
            pcall(AutoBigPotion.activate)
        end
    end

    local _FH_V2_TP_AFTER = 1000000000

    local function isPrimeMethod() return M.method == "Prime" end
    local function isWalkMode()    return M.method ~= "Prime" end

    local canDirectTp, tpThroughWaypoints, walkTo

    canDirectTp = function(HRP, targetPos)
        if not HRP or not targetPos then return false end
        local origin = HRP.Position
        local ignored = { player.Character }
        for _ = 1, 12 do
            local direction = targetPos - origin
            if direction.Magnitude <= 0.05 then return true end
            local params = RaycastParams.new()
            params.FilterType = Enum.RaycastFilterType.Blacklist
            params.FilterDescendantsInstances = ignored
            params.IgnoreWater = true
            local result = Workspace:Raycast(origin, direction, params)
            if not result then return true end
            local hit = result.Instance
            if not hit then return true end
            if hit:IsA("BasePart") and not hit.CanCollide then
                table.insert(ignored, hit)
                origin = result.Position + direction.Unit * 0.1
            else
                return (result.Position - targetPos).Magnitude <= 3
            end
        end
        return false
    end
    tpThroughWaypoints = function(HRP, waypoints)
        if #waypoints == 0 then return end
        local startIndex = 1
        for i = #waypoints, 1, -1 do
            if canDirectTp(HRP, waypoints[i]) then startIndex = i; break end
        end
        for i = startIndex, #waypoints do
            HRP.CFrame = CFrame.new(waypoints[i])
            if i < #waypoints then task.wait(0.135) end
        end
    end
    walkTo = function(HRP, targetPos, speed, arriveDist, timeout)
        if not HRP or not HRP.Parent or not targetPos then return end
        speed      = speed      or 180
        arriveDist = arriveDist or 6
        timeout    = timeout    or 6
        SSEquipGrapple()
        local _ctrls
        pcall(function()
            _ctrls = require(player.PlayerScripts:WaitForChild("PlayerModule")):GetControls()
        end)
        if _ctrls then pcall(function() _ctrls:Disable() end) end
        Booster.suspend("steal")
        pcall(function()
            local start = tick()
            while HRP and HRP.Parent do
                local d    = targetPos - HRP.Position
                local flat = Vector3.new(d.X, 0, d.Z)
                local mag  = flat.Magnitude
                if mag < arriveDist then break end
                if tick() - start > timeout then break end
                local effSpeed = speed
                if mag < 25 then effSpeed = math.max(60, speed * (mag / 25)) end
                local dir = flat.Unit
                local vy  = HRP.Velocity.Y
                HRP.Velocity = Vector3.new(dir.X * effSpeed, vy, dir.Z * effSpeed)
                task.wait()
            end
            if HRP and HRP.Parent then
                HRP.Velocity = Vector3.new(0, 0, 0)
                HRP.CFrame   = CFrame.new(targetPos)
            end
        end)
        if _ctrls then pcall(function() _ctrls:Enable() end) end
        Booster.unsuspend("steal")
    end
    local _FH_WalkTo = function(targetPos, speed, arriveDist, timeout)
        local char = player.Character
        local hrp  = char and char:FindFirstChild("HumanoidRootPart")
        return walkTo(hrp, targetPos, speed, arriveDist, timeout)
    end

    local function _v2TeleportHRP(position)
        local character = player.Character
        local h = character and character:FindFirstChild("HumanoidRootPart")
        if not h then return end
        h.Velocity = Vector3.zero
        pcall(function() hrp.Velocity = Vector3.zero end)
        h.CFrame = CFrame.new(position)
    end
    local _v2PlotController
    local function _v2GetMyPlotModel()
        if not _v2PlotController then
            pcall(function()
                _v2PlotController = require(game:GetService("ReplicatedStorage"):WaitForChild("Controllers"):WaitForChild("PlotController"))
            end)
        end
        local model
        pcall(function() model = _v2PlotController:GetMyPlot().PlotModel end)
        return model
    end
    function M.SSDoTeleportV2()
        local char = player.Character
        local hum  = char and char:FindFirstChildOfClass("Humanoid")
        local hrp  = char and char:FindFirstChild("HumanoidRootPart")
        if not hum or not hrp then return end

        SSSetFFlags()

        local MyPlot = _v2GetMyPlotModel()
        if not MyPlot then return end
        local plotOrder = MyPlot:GetAttribute("Order")

        if plotOrder == 2 then
            SSEquipGrapple()
            pcall(function() hrp.CFrame = MyPlot.Spawn.CFrame end)
            task.wait(0.135)
            _v2TeleportHRP(Vector3.new(-368.18, -6.97, 69.17))
            task.wait(0.135)
            _v2TeleportHRP(Vector3.new(-335.650, -5.103, 100.070))
            if M.autoAP and _G._FH_RunSemiAP then task.spawn(function() pcall(_G._FH_RunSemiAP) end) end
            task.wait(0.25)
            _v2TeleportHRP(Vector3.new(-351.980, -7.002, 75.540))
            drinkPotion()
        elseif plotOrder == 1 then
            SSEquipGrapple()
            pcall(function() hrp.CFrame = MyPlot.Spawn.CFrame end)
            task.wait(0.135)
            _v2TeleportHRP(Vector3.new(-375.3137512207031, -7.252167701721191, 74.2289810180664))
            task.wait(0.135)
            _v2TeleportHRP(Vector3.new(-336.110, -5.037, 19.840))
            if M.autoAP and _G._FH_RunSemiAP then task.spawn(function() pcall(_G._FH_RunSemiAP) end) end
            task.wait(0.25)
            _v2TeleportHRP(Vector3.new(-352.860, -7.002, 44.180))
            drinkPotion()
        end
    end

    function M.SSDoTeleport()
        local char = player.Character
        local hum  = char and char:FindFirstChild("Humanoid")
        local hrp  = char and char:FindFirstChild("HumanoidRootPart")
        if not hum or not hrp then return end

        SSEquipGrapple()

        M.semiInstantMode = "Semi"

        local wasBoosterOn = Booster.userEnabled
        if wasBoosterOn then Booster.set(false) end

        local wasNear, wasBest, wasPri = AutoGrab.nearest, AutoGrab.best, AutoGrab.priorityGrab
        local wasPotionOn = AutoBigPotion.enabled
        AutoGrab.setNearest(false); AutoGrab.setBest(false); AutoGrab.setPriorityGrab(false)
        if wasPotionOn then AutoBigPotion.set(false) end
        if AutoBigPotion.clearSession then pcall(AutoBigPotion.clearSession) end
        local restored = false
        local function restoreAGs()
            if restored then return end
            restored = true
            if wasNear     then AutoGrab.setNearest(true) end
            if wasBest     then AutoGrab.setBest(true) end
            if wasPri      then AutoGrab.setPriorityGrab(true) end
            if wasPotionOn then AutoBigPotion.set(true) end
        end

        local plots = Workspace:FindFirstChild("Plots")
        if not plots then restoreAGs(); return end
        local myName = player.DisplayName
        local enemyPlots = {}
        for _, plot in ipairs(plots:GetChildren()) do
            local sign  = plot:FindFirstChild("PlotSign")
            local label = sign and sign:FindFirstChild("SurfaceGui")
                and sign.SurfaceGui:FindFirstChild("Frame")
                and sign.SurfaceGui.Frame:FindFirstChild("TextLabel")
            if label and label.Text ~= "Empty Base" then
                local owner = label.Text:gsub("'s Base$",""):gsub("'s base$",""):gsub("%s+$","")
                if owner ~= myName then table.insert(enemyPlots, plot) end
            end
        end

        local function getClosestPodium()
            if #enemyPlots == 0 then return nil end
            local best, bestDist = nil, math.huge
            for _, plot in ipairs(enemyPlots) do
                local podiums = plot:FindFirstChild("AnimalPodiums"); if not podiums then continue end
                local plotPos
                pcall(function()
                    if plot.PrimaryPart then
                        plotPos = plot.PrimaryPart.Position
                    else
                        plotPos = plot:GetPivot().Position
                    end
                end)
                if not plotPos then
                    local part = plot:FindFirstChildWhichIsA("BasePart", true)
                    if part then plotPos = part.Position end
                end
                local plotIsBase1 = true
                if plotPos then
                    local d1 = (plotPos - BASES.b1.refVec).Magnitude
                    local d2 = (plotPos - BASES.b2.refVec).Magnitude
                    plotIsBase1 = d1 < d2
                end
                for _, pname in ipairs({ "1", "10" }) do
                    local podium = podiums:FindFirstChild(pname); if not podium then continue end
                    local cm = podium:FindFirstChild("Claim") and podium.Claim:FindFirstChild("Main"); if not cm then continue end
                    local d = (hrp.Position - cm.Position).Magnitude
                    if d < bestDist then
                        bestDist = d
                        local spawn  = podium:FindFirstChild("Base") and podium.Base:FindFirstChild("Spawn")
                        local pa     = spawn and spawn:FindFirstChild("PromptAttachment")
                        local prompt = pa and pa:FindFirstChildWhichIsA("ProximityPrompt")
                        if prompt then
                            best = {
                                plot         = plot,
                                podiumName   = pname,
                                position     = cm.Position,
                                prompt       = prompt,
                                promptPos    = pa.WorldPosition,
                                distance     = d,
                                isEnemyBase1 = plotIsBase1,
                            }
                        end
                    end
                end
            end
            return best
        end

        local carpet = char:FindFirstChild(_FH_ActiveMount)
            or (player.Backpack and player.Backpack:FindFirstChild(_FH_ActiveMount))
        local podium = getClosestPodium()
        if not podium then restoreAGs(); return end

        local finalPos
        do
            local dB1 = (podium.position - BASES.b1.refVec).Magnitude
            local dB2 = (podium.position - BASES.b2.refVec).Magnitude
            finalPos  = (dB1 < dB2) and BASES.b1.finalPos or BASES.b2.finalPos
        end

        if carpet then pcall(function() hum:EquipTool(carpet) end) end

        local netCtx = _FH_StartTrip({ plotName = podium.plot.Name, pod = tonumber(podium.podiumName) or podium.podiumName })
        M._semiStealCtx = netCtx

        local function doTpSequence(HRP, fPos, pod)
            local isAtBase1
            do
                local dB1 = (pod.position - BASES.b1.refVec).Magnitude
                local dB2 = (pod.position - BASES.b2.refVec).Magnitude
                isAtBase1 = dB1 < dB2
            end

            local redPos   = isAtBase1 and Vector3.new(-337, -5, 100)         or Vector3.new(-335, -5, 20)
            local greenPos = isAtBase1 and Vector3.new(-347.12, -6.67, 81.64) or Vector3.new(-349.43, -6.78, 37.47)

            local approachWaypoints
            if not isAtBase1 then
                approachWaypoints = {
                    Vector3.new(-351.49, -6.65, 113.72),
                    Vector3.new(-352.54, -6.83,   6.66),
                    Vector3.new(-334.80, -5.04,  18.90),
                }
            else
                approachWaypoints = {
                    Vector3.new(-352.54, -6.83,   6.66),
                    Vector3.new(-351.49, -6.65, 113.72),
                    Vector3.new(-337,    -5,    103),
                }
            end

            local function doApproachPath(HRP_, _pod, _isAtBase1)
                if isWalkMode() then
                    local startIndex = 1
                    for i = #approachWaypoints, 1, -1 do
                        if canDirectTp(HRP_, approachWaypoints[i]) then startIndex = i; break end
                    end
                    for i = startIndex, #approachWaypoints do
                        walkTo(HRP_, approachWaypoints[i], 180)
                    end
                    return
                end
                if _pod and redPos and canDirectTp(HRP_, redPos) then
                    HRP_.CFrame = CFrame.new(redPos)
                else
                    tpThroughWaypoints(HRP_, approachWaypoints)
                end
            end

            if isPrimeMethod() then
                local prompt = pod and pod.prompt
                if not prompt or not prompt.Parent then return end
                prompt.RequiresLineOfSight   = false
                prompt.MaxActivationDistance = math.huge
                SSEquipGrapple()
                HRP.CFrame = isAtBase1 and CFrame.new(-343.08, -6.84, 93.20) or CFrame.new(-342.91, -6.81, 28.00)
                task.wait(0.25)
                HRP.CFrame = isAtBase1 and CFrame.new(-340.16, -7.29, 48.82) or CFrame.new(-340.16, -7.29, 72.40)
                task.wait(0.12)
                HRP.CFrame = isAtBase1 and CFrame.new(-341.26, -7.29, 66.95) or CFrame.new(-341.26, -7.29, 54.27)
                task.wait(0.12)
                HRP.CFrame = isAtBase1 and CFrame.new(-339.93, -7.29, 82.14) or CFrame.new(-339.63, -7.29, 39.33)
                task.wait(0.18)
                local ctx = __FH_v2.startStealHold(prompt, "Prime")
                HRP.CFrame = isAtBase1 and CFrame.new(-354.04, -7.21, 90.42) or CFrame.new(-354.04, -7.21, 28.00)
                task.wait(0.45)
                HRP.CFrame = isAtBase1 and CFrame.new(-334.60, -5.00, 101.30) or CFrame.new(-334.60, -5.00, 19.30)
                if ctx and ctx.holdBeganAt then
                    while tick() - ctx.holdBeganAt < __MIN_HOLD_TIME_v2 do task.wait() end
                end
                drinkPotion()
                SSEquipGrapple()
                HRP.CFrame = isAtBase1 and CFrame.new(-351.53, -7.29, 83.66) or CFrame.new(-350.62, -7.29, 35.91)
                if ctx then __FH_v2.finishStealHold(ctx) end
            else
                local ctx
                if pod and pod.prompt and pod.prompt.Parent then
                    pod.prompt.RequiresLineOfSight   = false
                    pod.prompt.MaxActivationDistance = math.huge
                    ctx = __FH_v2.startStealHold(pod.prompt, "Walk")
                end
                if ctx then __FH_v2.waitForStealTime(ctx, 0.8) end
                doApproachPath(HRP, pod, isAtBase1)
                task.wait(0.25)
                drinkPotion()
                SSEquipGrapple()
                if pod and pod.prompt and pod.prompt.Parent and ctx then
                    if greenPos then
                        __FH_v2.waitForStealTime(ctx, 1.3)
                        HRP.CFrame = CFrame.new(greenPos)
                    end
                    __FH_v2.finishStealHold(ctx)
                end
            end

            local startTime = tick()
            while player:GetAttribute("Stealing") == nil do
                if tick() - startTime >= 1 then break end
                task.wait(0.1)
            end
        end

        task.spawn(function()
            local ok, err = pcall(function()
                doTpSequence(hrp, finalPos, podium)
                M._semiStealCtx = nil
            end)

            if wasBoosterOn then Booster.set(true) end

            if M.autoAP and _G._FH_RunSemiAP then pcall(_G._FH_RunSemiAP) end

            if M.autoWalk and M.walkPoint then
                pcall(function() Booster.unsuspend("steal") end)
                pcall(function()
                    local boostOn = Booster.userEnabled
                    local spd     = tonumber(Booster.speed) or 29
                    local c   = player.Character
                    local hum = c and c:FindFirstChildOfClass("Humanoid")
                    local hrp = c and c:FindFirstChild("HumanoidRootPart")
                    if hum and hrp then
                        local deadline = tick() + 15
                        while tick() < deadline do
                            local flat = Vector3.new(M.walkPoint.X - hrp.Position.X, 0, M.walkPoint.Z - hrp.Position.Z)
                            if flat.Magnitude < 3 then break end
                            hum:MoveTo(M.walkPoint)
                            if boostOn and flat.Magnitude > 4 then
                                local dir = flat.Unit
                                hrp.Velocity = Vector3.new(dir.X * spd, hrp.Velocity.Y, dir.Z * spd)
                            end
                            task.wait()
                            c   = player.Character
                            hrp = c and c:FindFirstChild("HumanoidRootPart")
                            hum = c and c:FindFirstChildOfClass("Humanoid")
                            if not (hrp and hum) then break end
                        end
                    end
                end)
            end
            restoreAGs()
            if not ok then end
        end)
    end
    M.SSDoSteal = M.SSDoTeleport

    function M.execute()
        local _lp = game:GetService("Players").LocalPlayer
        if _lp and _lp:GetAttribute("Stealing") then return end
        if M.debounce then return end
        M.debounce = true
        _G._FH_LastV2UseTime = os.clock()
        task.spawn(function()
            SSSetFFlags()
            M.SSDoTeleport()
            task.wait(1.2)
            M.debounce = false
        end)
    end

    function M.activate()
        task.spawn(function()
            SSSetFFlags()
            if Actions and Actions.reset then pcall(Actions.reset) end
        end)
    end

    return M
end)()
SS = HalfwaySteal
SS.autoTPUnlockState = false
SS.SSExecute = function() pcall(function() HalfwaySteal.execute() end) end
local _mpDrag = nil
table.insert(_G._FH_DragClearers, function() _mpDrag = nil end)
UserInputService.InputEnded:Connect(function(inp)
    if _mpDrag and (inp.UserInputType == Enum.UserInputType.MouseButton1
    or inp.UserInputType == Enum.UserInputType.Touch) then
        local d = _mpDrag; _mpDrag = nil; d.savePos()
    end
end)
UserInputService.InputChanged:Connect(function(inp)
    if guiLocked then _mpDrag = nil; return end
    if not _mpDrag then return end
    if inp.UserInputType == Enum.UserInputType.MouseMovement
    or inp.UserInputType == Enum.UserInputType.Touch then
        local d = inp.Position - _mpDrag.ds
        if not _mpDrag.moved then
            if d.Magnitude < 8 then return end
            _mpDrag.moved = true; _mpDrag.ds = inp.Position; return
        end

        _mpDrag.panel.Position = UDim2.new(
            _mpDrag.ws.X.Scale, _mpDrag.ws.X.Offset + d.X,
            _mpDrag.ws.Y.Scale, _mpDrag.ws.Y.Offset + d.Y)
    end
end)
local _miniPanelRegistry = {}
local function MiniPanel(title, x, y, w, extraFactor)
    w = w or 200
    local panel = Instance.new("Frame")
    panel.Name             = "Mini_" .. title
    panel.Size             = UDim2.new(0, w, 0, 30)
    panel.Position         = UDim2.new(0.5, x, 0.5, y)
    panel.BackgroundColor3 = T.Bg
    panel.BackgroundTransparency = 0.35
    panel.BorderSizePixel  = 0
    panel.ClipsDescendants = true
    panel.Visible          = false
    panel.ZIndex           = 50
    panel.Parent           = GUI
    _newScale(panel, (extraFactor or 1) * (isMobile and 0.925 or 1))
    Corner(panel, 12)
    GradStroke(panel, 2, 0, 135)
    trackBgFrame(panel, "Bg")
    local _ppKey = "panelpos:" .. title
    do
        local pp = Config.get(_ppKey, nil)
        if type(pp) == "table" and #pp == 4 then
            panel.Position = UDim2.new(pp[1], pp[2], pp[3], pp[4])
        end
    end
    local function _clampOnScreen()
        local vp = GUI.AbsoluteSize
        if vp.X < 1 or vp.Y < 1 then return end
        local abs = panel.AbsolutePosition
        local sz  = panel.AbsoluteSize
        local nx  = math.clamp(abs.X, 0, math.max(0, vp.X - sz.X))
        local ny  = math.clamp(abs.Y, 0, math.max(0, vp.Y - sz.Y))
        if math.abs(nx - abs.X) > 0.5 or math.abs(ny - abs.Y) > 0.5 then

            panel.Position = UDim2.new(0, nx, 0, ny)
        end
    end
    panel:GetPropertyChangedSignal("Visible"):Connect(function()
        if panel.Visible then task.defer(_clampOnScreen) end
    end)
    local header = Instance.new("Frame")
    header.Size             = UDim2.new(1, 0, 0, 30)
    header.BackgroundColor3 = T.BgDeep
    header.BorderSizePixel  = 0
    header.Active           = true
    header.ZIndex           = 51
    header.Parent           = panel
    trackBgFrame(header, "BgDeep")
    Corner(header, 12)
    local hdrFill = Instance.new("Frame")
    hdrFill.Size             = UDim2.new(1, 0, 0, 12)
    hdrFill.Position         = UDim2.new(0, 0, 1, -12)
    hdrFill.BackgroundColor3 = T.BgDeep
    hdrFill.BorderSizePixel  = 0
    hdrFill.ZIndex           = 51
    hdrFill.Parent           = header
    trackBgFrame(hdrFill, "BgDeep")
    local titleLbl = Lbl(header, title, 12, T.Text, Enum.Font.GothamBold)
    titleLbl.Size           = UDim2.new(1, -40, 1, 0)
    titleLbl.Position       = UDim2.new(0, 10, 0, 0)
    titleLbl.TextYAlignment = Enum.TextYAlignment.Center
    titleLbl.ZIndex         = 53
    local minBtn = Instance.new("TextButton")
    minBtn.Name             = "MinBtn"
    minBtn.Size             = UDim2.new(0, 20, 0, 20)
    minBtn.Position         = UDim2.new(1, -26, 0.5, -10)
    minBtn.BackgroundColor3 = T.Soft
    minBtn.Text             = "-"
    minBtn.TextColor3       = T.Text
    minBtn.Font             = Enum.Font.GothamBold
    minBtn.TextSize         = 14
    minBtn.AutoButtonColor  = false
    minBtn.ZIndex           = 53
    minBtn.Parent           = header
    trackBgFrame(minBtn, "Soft")
    Corner(minBtn, 6)
    local body = Instance.new("Frame")
    body.Size                   = UDim2.new(1, 0, 0, 0)
    body.Position               = UDim2.new(0, 0, 0, 30)
    body.BackgroundTransparency = 1
    body.Visible                = true
    body.ZIndex                 = 51
    body.Parent                 = panel
    local bodyLayout = Instance.new("UIListLayout")
    bodyLayout.FillDirection       = Enum.FillDirection.Vertical
    bodyLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    bodyLayout.SortOrder           = Enum.SortOrder.LayoutOrder
    bodyLayout.Padding             = UDim.new(0, 4)
    bodyLayout.Parent              = body
    Pad(body, 6, 6, 6, 6)
    local contentH = 0
    local open = Config.get("panelopen:" .. title, true)
    local curW = w
    hdrFill.Visible = open
    body.Visible    = open
    minBtn.Text     = open and "-" or "+"

    local function panelScale()

        local own = panel:FindFirstChildOfClass("UIScale")
        if own and own.Scale and own.Scale > 0 then return own.Scale end
        return 1
    end
    local function recomputeContent()
        contentH = (bodyLayout.AbsoluteContentSize.Y / panelScale()) + 12
    end
    local function applySize(animate)
        local hdrH   = header.Size.Y.Offset
        local totalH = hdrH + (open and contentH or 0)
        body.Size    = UDim2.new(1, 0, 0, open and contentH or 0)
        body.Position = UDim2.new(0, 0, 0, hdrH)
        local target = UDim2.new(0, curW, 0, totalH)
        if animate then Tween(panel, M, {Size = target}) else panel.Size = target end
    end
    bodyLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        recomputeContent()
        applySize(false)
    end)

    panel:GetPropertyChangedSignal("Visible"):Connect(function()
        if panel.Visible then
            task.defer(function() recomputeContent(); applySize(false) end)
        end
    end)

    task.spawn(function()
        for _ = 1, 8 do
            task.wait(0.1)
            if bodyLayout.AbsoluteContentSize.Y > 0 then
                recomputeContent(); if open then applySize(false) end
            end
        end
    end)
    local function setWidth(nw, animate)
        curW = nw
        applySize(animate)
    end
    minBtn.Activated:Connect(function()
        open = not open
        minBtn.Text = open and "-" or "+"
        Config.set("panelopen:" .. title, open)
        if open then
            hdrFill.Visible = true
            body.Visible    = true
            applySize(true)
        else
            applySize(true)
            task.delay(0.2, function()
                if not open then
                    body.Visible    = false
                    hdrFill.Visible = false
                end
            end)
        end
    end)
    local function savePos()
        local p = panel.Position
        Config.set(_ppKey, { p.X.Scale, p.X.Offset, p.Y.Scale, p.Y.Offset })
    end
    local function startDrag(inp)
        if guiLocked then return end
        if inp.UserInputType == Enum.UserInputType.MouseButton1
        or inp.UserInputType == Enum.UserInputType.Touch then
            _mpDrag = { panel = panel, ds = inp.Position, ws = panel.Position, savePos = savePos }
        end
    end
    header.InputBegan:Connect(startDrag)
    table.insert(_miniPanelRegistry, { panel = panel, key = _ppKey, defaultPos = UDim2.new(0.5, x, 0.5, y) })
    return { panel = panel, body = body, header = header, setWidth = setWidth, startDrag = startDrag }
end

local boosterPanel = MiniPanel("Booster", 240, 0, 170)

Toggle(boosterPanel.body, "Booster", "", function(on) Booster.set(on) end)
Slider(boosterPanel.body, "Walk Speed", 16, 100, 29, function(v) Booster.setSpeed(v) end, 0.1)
Slider(boosterPanel.body, "Jump Power", 50, 100, 50, function(v) Booster.setJump(v) end, 0.1)
local actionsPanel = MiniPanel("Actions", 240, 80,177)
Button(actionsPanel.body, "Rejoin",          "", function() Actions.rejoin() end, 30)
Button(actionsPanel.body, "Kick Self",       "", function() Actions.kick() end, 30)
Button(actionsPanel.body, "Ragdoll Self",    "", function() Actions.ragdollSelf() end, 30)
Button(actionsPanel.body, "Reset Character", "", function() Actions.reset() end, 30)
Button(actionsPanel.body, "Ragdoll Tech",    "", function() if AutoBigPotion.activate then pcall(AutoBigPotion.activate) end task.wait(0.1) Actions.ragdollSelf() end, 30)
local allowBasePanelObj = MiniPanel("Allow Base", -260, 180, 134)
Button(allowBasePanelObj.body, "Allow", "", function() AllowBase.fire() end)
local AllowBasePanel = { setVisible = function(v) allowBasePanelObj.panel.Visible = v end }
do
    local minB = allowBasePanelObj.header:FindFirstChild("MinBtn")
    if minB then minB.Visible = false end
    allowBasePanelObj.header:FindFirstChildOfClass("TextLabel").Size = UDim2.new(1, -10, 1, 0)
end

local unlockPanel = {}
local mobilePanelObj = MiniPanel("Quick Actions", -220, 160, 210)
do
    local mHeader = mobilePanelObj.header
    local mHdrH   = 36
    mHeader.Size  = UDim2.new(1, 0, 0, mHdrH)
    local mBody   = mobilePanelObj.body
    mBody.Position = UDim2.new(0, 0, 0, mHdrH)
    local mTitle  = mHeader:FindFirstChildOfClass("TextLabel")
    if mTitle then mTitle.TextSize = 13 end
end
Toggle(mobilePanelObj.body, "Carpet Speed",          "", function(on) CarpetSpeed.set(on) end)
Button(mobilePanelObj.body, "Reset Character",       "", function() Actions.reset()   end)

local MobilePanel = { setVisible = function(v) mobilePanelObj.panel.Visible = v end }
local defensePanel = MiniPanel("Defense", -260, -40, 160)

Toggle(defensePanel.body, "Auto Defense", "", function(on) AutoDefenseEnabled = on end)
Toggle(defensePanel.body, "Anti Intruder", "", function(on) AntiTPEnabled_state = on end)
task.spawn(function()
    local body = defensePanel.body
    local CMDS = {
        { label = "Balloon",   id = "balloon"   },
        { label = "Ragdoll",   id = "ragdoll"   },
        { label = "Rocket",    id = "rocket"    },
        { label = "Inverse",   id = "inverse"   },
        { label = "Tiny",      id = "tiny"      },
        { label = "Jail",      id = "jail"      },
        { label = "Jumpscare", id = "jumpscare" },
        { label = "Morph",     id = "morph"     },
    }
    local PAGE_W = { main = 160, menu = 200, set1 = 200, set2 = 200 }
    local pages  = { main = {}, menu = {}, set1 = {}, set2 = {} }
    local function snapshot()
        local t = {}
        for _, ch in ipairs(body:GetChildren()) do
            if ch:IsA("GuiObject") then t[ch] = true end
        end
        return t
    end
    local function collect(before, into)
        for _, ch in ipairs(body:GetChildren()) do
            if ch:IsA("GuiObject") and not before[ch] then table.insert(into, ch) end
        end
    end
    local function showPage(name)
        for pg, rows in pairs(pages) do
            local vis = (pg == name)
            for _, r in ipairs(rows) do r.Visible = vis end
        end
        local w = PAGE_W[name] or 160
        if defensePanel.setWidth then
            defensePanel.setWidth(w, false)
            task.delay(0.05, function() defensePanel.setWidth(w, false) end)
            task.delay(0.2,  function() defensePanel.setWidth(w, false) end)
        end
    end
    local before = snapshot()
    Button(body, "Defense Commands", "", function() showPage("menu") end, 28)
    for ch in pairs(snapshot()) do pages.main[#pages.main + 1] = ch end
    before = snapshot()
    Button(body, "\226\134\144 Back", "", function() showPage("main") end, 28)
    Button(body, "First Defense Commands", "", function() showPage("set1") end, 30)
    Button(body, "2nd Defense Commands", "", function() showPage("set2") end, 30)
    collect(before, pages.menu)
    local enabled = { set1 = {}, set2 = {} }
    local tgs     = { set1 = {}, set2 = {} }
    local function rebuild(sk, gname)
        local list = {}
        for _, c in ipairs(CMDS) do
            if enabled[sk][c.id] then table.insert(list, c.id) end
        end
        _G[gname] = list
    end
    local function buildSetPage(sk, gname, prefix, defaults)
        local other = (sk == "set1") and "set2" or "set1"
        before = snapshot()
        Button(body, "\226\134\144 Back", "", function() showPage("menu") end, 28)
        for _, c in ipairs(CMDS) do
            local tg = Toggle(body, prefix .. c.label, "", function(on)
                enabled[sk][c.id] = on or nil
                rebuild(sk, gname)
                if on then
                    local o = tgs[other][c.id]
                    if o and o.get() then o.set(false) end
                end
            end)
            tgs[sk][c.id] = tg
            if defaults[c.id] and Config.get("toggle:" .. prefix .. c.label, nil) == nil then
                task.defer(function() pcall(tg.set, true) end)
            end
        end
        rebuild(sk, gname)
        collect(before, pages[sk])
    end
    buildSetPage("set1", "__GH_DefCmds1", "1: ", { balloon = true })
    buildSetPage("set2", "__GH_DefCmds2", "2: ", { ragdoll = true })
    showPage("main")
end)
do
    local cloneref  = cloneref or function(o) return o end
    local Players   = cloneref(game:GetService("Players"))
    local Workspace = cloneref(game:GetService("Workspace"))
    local player    = Players.LocalPlayer
    local function getPlotOwner(plot)
        local sign  = plot:FindFirstChild("PlotSign")
        local frame = sign and sign:FindFirstChild("SurfaceGui") and sign.SurfaceGui:FindFirstChild("Frame")
        local label = frame and frame:FindFirstChild("TextLabel")
        if not label or label.Text == "Empty Base" then return nil end
        return label.Text:gsub("'s [Bb]ase$", ""):gsub("%s+$", "")
    end
    local function getEnemyPlots()
        local result, myName = {}, player.DisplayName
        local plots = Workspace:FindFirstChild("Plots")
        if not plots then return result end
        for _, plot in ipairs(plots:GetChildren()) do
            local owner = getPlotOwner(plot)
            if owner and owner ~= myName then table.insert(result, plot) end
        end
        return result
    end
    local function getClosestEnemyPlot()
        local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then return nil end
        local best, bestDist = nil, math.huge
        for _, plot in ipairs(getEnemyPlots()) do
            local unlock = plot:FindFirstChild("Unlock")
            local main   = unlock and unlock:FindFirstChild("Main")
            if main then
                local d = (hrp.Position - main.Position).Magnitude
                if d < bestDist then bestDist = d; best = plot end
            end
        end
        return best
    end
    local function unlockBase(idx)
        if type(fireproximityprompt) ~= "function" then return end
        local plot   = getClosestEnemyPlot()
        local unlock = plot and plot:FindFirstChild("Unlock")
        if not unlock then return end
        local target = nil
        for _, ch in ipairs(unlock:GetDescendants()) do
            local f = ch:GetAttribute("Floor")
            if f ~= nil and (f == idx or tostring(f) == tostring(idx)) then
                target = ch
                break
            end
        end
        local function findPrompt(root)
            if not root then return nil end
            local p = root:FindFirstChild("UnlockBase")
            if p and p:IsA("ProximityPrompt") then return p end
            for _, d in ipairs(root:GetDescendants()) do
                if d:IsA("ProximityPrompt") and (d.Name == "UnlockBase" or d.ActionText == "Unlock Base") then
                    return d
                end
            end
            return nil
        end
        local prompt = findPrompt(target)
        if prompt then
            pcall(fireproximityprompt, prompt)
        end
    end
    local UB = {}
    local CELL = 44
    local GAP  = 7
    local PAD  = 10
    local N    = 4
    local ubIsHorizontal = Config.get("ub_horiz", true)
    local function ubComputeSize()
        if ubIsHorizontal then
            local w = N * CELL + (N - 1) * GAP + PAD * 2
            local h = CELL + PAD * 2
            return w, h
        else
            local w = CELL + PAD * 2
            local h = N * CELL + (N - 1) * GAP + PAD * 2
            return w, h
        end
    end
    UB.W, UB.H = ubComputeSize()
    UB.UBBorderFrame = Instance.new("Frame")
    UB.UBBorderFrame.Name             = "UBGradBorder"
    UB.UBBorderFrame.Size             = UDim2.new(0, UB.W + 4, 0, UB.H + 4)
    UB.UBBorderFrame.Position         = UDim2.new(0.5, -(UB.W + 4) / 2, 1, -(UB.H + 4 + 80))
    UB.UBBorderFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    UB.UBBorderFrame.BackgroundTransparency = 1
    UB.UBBorderFrame.BorderSizePixel  = 0
    UB.UBBorderFrame.ZIndex           = 18
    UB.UBBorderFrame.Visible          = false
    UB.UBBorderFrame.Parent           = GUI
    _newScale(UB.UBBorderFrame)
    Corner(UB.UBBorderFrame, 12)
    GradStroke(UB.UBBorderFrame, 2.5, 0, 135)
    UB.UBWin = Instance.new("Frame")
    UB.UBWin.Name                   = "UnlockBasePanel"
    UB.UBWin.Size                   = UDim2.new(0, UB.W, 0, UB.H)
    UB.UBWin.Position               = UDim2.new(0.5, -UB.W / 2, 1, -(UB.H + 82))
    UB.UBWin.BackgroundColor3       = T.Bg
    UB.UBWin.BackgroundTransparency = 0.35
    UB.UBWin.BorderSizePixel        = 0
    UB.UBWin.ZIndex                 = 19
    UB.UBWin.Visible                = false
    UB.UBWin.ClipsDescendants       = true
    UB.UBWin.Parent                 = GUI
    _newScale(UB.UBWin)
    trackBgFrame(UB.UBWin, "Bg")
    Corner(UB.UBWin, 10)
    GradStroke(UB.UBWin, 2.5, 0, 135)
    UB.UBWin.Active = true
    do
        local pp = Config.get("panelpos:UnlockBase", nil)
        if type(pp) == "table" and pp.x and pp.y then
            local xs = pp.xs; if xs == nil then xs = 0.5 end
            local ys = pp.ys; if ys == nil then ys = 1   end
            UB.UBWin.Position         = UDim2.new(xs, pp.x, ys, pp.y)
            UB.UBBorderFrame.Position = UDim2.new(xs, pp.x - 2, ys, pp.y - 2)
        end
    end
    local ubContent = Instance.new("Frame")
    ubContent.Size                   = UDim2.new(1, 0, 1, 0)
    ubContent.Position               = UDim2.new(0, 0, 0, 0)
    ubContent.BackgroundTransparency = 1
    ubContent.ZIndex                 = 19
    ubContent.Parent                 = UB.UBWin
    Pad(ubContent, PAD, PAD, PAD, PAD)
    local ubBtnGrid = Instance.new("UIGridLayout")
    ubBtnGrid.CellSize = UDim2.new(0, CELL, 0, CELL)
    if ubIsHorizontal then
        ubBtnGrid.CellPadding           = UDim2.new(0, GAP, 0, 0)
        ubBtnGrid.FillDirectionMaxCells = N
    else
        ubBtnGrid.CellPadding           = UDim2.new(0, 0, 0, GAP)
        ubBtnGrid.FillDirectionMaxCells = 1
    end
    ubBtnGrid.HorizontalAlignment = Enum.HorizontalAlignment.Center
    ubBtnGrid.VerticalAlignment   = Enum.VerticalAlignment.Center
    ubBtnGrid.Parent              = ubContent
    local function ubApplyLayout()
        UB.W, UB.H = ubComputeSize()
        if ubIsHorizontal then
            ubBtnGrid.FillDirectionMaxCells = N
            ubBtnGrid.CellPadding           = UDim2.new(0, GAP, 0, 0)
        else
            ubBtnGrid.FillDirectionMaxCells = 1
            ubBtnGrid.CellPadding           = UDim2.new(0, 0, 0, GAP)
        end
        UB.UBWin.Size         = UDim2.new(0, UB.W, 0, UB.H)
        UB.UBBorderFrame.Size = UDim2.new(0, UB.W + 4, 0, UB.H + 4)
        local p = UB.UBWin.Position
        UB.UBBorderFrame.Position = UDim2.new(p.X.Scale, p.X.Offset - 2, p.Y.Scale, p.Y.Offset - 2)
    end
    local ubLayoutToggle = Instance.new("TextButton")
    ubLayoutToggle.BackgroundColor3 = T.Card
    ubLayoutToggle.BorderSizePixel  = 0
    ubLayoutToggle.Text             = ubIsHorizontal and "\226\134\148" or "\226\134\149"
    ubLayoutToggle.TextSize         = 16
    ubLayoutToggle.Font             = Enum.Font.GothamBold
    ubLayoutToggle.TextColor3       = T.White
    ubLayoutToggle.AutoButtonColor  = false
    ubLayoutToggle.ZIndex           = 22
    ubLayoutToggle.Parent           = ubContent
    Corner(ubLayoutToggle, 8)
    Stroke(ubLayoutToggle, T.Line, 1)
    local ubLayoutDebounce = false
    local function ubToggleLayout()
        if ubLayoutDebounce then return end
        ubLayoutDebounce = true
        ubIsHorizontal = not ubIsHorizontal
        ubLayoutToggle.Text = ubIsHorizontal and "\226\134\148" or "\226\134\149"
        ubApplyLayout()
        Config.set("ub_horiz", ubIsHorizontal)
        task.delay(0.35, function() ubLayoutDebounce = false end)
    end
    ubLayoutToggle.Activated:Connect(ubToggleLayout)
    local floorLabels = { "1", "2", "3" }
    for i = 1, 3 do
        local fbtn = Instance.new("TextButton", ubContent)
        fbtn.BackgroundColor3 = T.Card
        fbtn.Text             = floorLabels[i]
        fbtn.Font             = Enum.Font.GothamBlack
        fbtn.TextSize         = 20
        fbtn.TextColor3       = T.White
        fbtn.AutoButtonColor  = false
        fbtn.ZIndex           = 21
        Corner(fbtn, 8)
        local fbs = Stroke(fbtn, T.Line, 1)
        fbtn.MouseEnter:Connect(function()
            Tween(fbtn, F, { BackgroundColor3 = T.CardHover })
            fbs.Color = T.White
        end)
        fbtn.MouseLeave:Connect(function()
            Tween(fbtn, F, { BackgroundColor3 = T.Card })
            fbs.Color = T.Line
        end)
        local floorDebounce = false
        local function fireFloor()
            if floorDebounce then return end
            floorDebounce = true
            task.spawn(unlockBase, i)
            Tween(fbtn, F, { BackgroundColor3 = T.SideActive })
            fbs.Color = T.White
            task.delay(0.4, function()
                Tween(fbtn, M, { BackgroundColor3 = T.Card })
                fbs.Color = T.Line
                floorDebounce = false
            end)
        end
        fbtn.Activated:Connect(fireFloor)
    end
    local function savePos()
        local p = UB.UBWin.Position
        Config.set("panelpos:UnlockBase", { xs = p.X.Scale, x = p.X.Offset, ys = p.Y.Scale, y = p.Y.Offset })
    end
    UB.UBWin.InputBegan:Connect(function(inp)
        if guiLocked then return end
        if inp.UserInputType == Enum.UserInputType.MouseButton1
        or inp.UserInputType == Enum.UserInputType.Touch then
            UB.dragging   = true
            UB.dragStart  = inp.Position
            UB.panelStart = UB.UBWin.Position
            UB.dragMoved  = false
        end
    end)
    table.insert(_G._FH_DragClearers, function() UB.dragging = false end)
    UB.UBWin.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1
        or inp.UserInputType == Enum.UserInputType.Touch then
            if UB.dragging then UB.dragging = false; savePos() end
        end
    end)
    UserInputService.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1
        or inp.UserInputType == Enum.UserInputType.Touch then
            if UB.dragging then UB.dragging = false; savePos() end
        end
    end)
    UserInputService.InputChanged:Connect(function(inp)
        if guiLocked then UB.dragging = false; return end
        if UB.dragging and (
            inp.UserInputType == Enum.UserInputType.MouseMovement or
            inp.UserInputType == Enum.UserInputType.Touch
        ) then
            local d = inp.Position - UB.dragStart
            if not UB.dragMoved then
                if d.Magnitude < 8 then return end
                UB.dragMoved = true; UB.dragStart = inp.Position; return
            end
            local newPos = UDim2.new(
                UB.panelStart.X.Scale, UB.panelStart.X.Offset + d.X,
                UB.panelStart.Y.Scale, UB.panelStart.Y.Offset + d.Y
            )
            UB.UBWin.Position         = newPos
            UB.UBBorderFrame.Position = UDim2.new(newPos.X.Scale, newPos.X.Offset - 2, newPos.Y.Scale, newPos.Y.Offset - 2)
        end
    end)
    unlockPanel.panel = UB.UBWin
    UB.UBWin:GetPropertyChangedSignal("Visible"):Connect(function()
        UB.UBBorderFrame.Visible = false
        if not UB.UBWin.Visible then return end
        task.defer(function()
            local vp = GUI.AbsoluteSize
            if vp.X < 1 then return end
            local abs, sz = UB.UBWin.AbsolutePosition, UB.UBWin.AbsoluteSize
            local pad = 4
            local nx = math.clamp(abs.X, pad, math.max(pad, vp.X - sz.X - pad))
            local ny = math.clamp(abs.Y, pad, math.max(pad, vp.Y - sz.Y - pad))
            if math.abs(nx - abs.X) > 0.5 or math.abs(ny - abs.Y) > 0.5 then
                UB.UBWin.Position = UDim2.new(0, nx, 0, ny)
                local p = UB.UBWin.Position
                UB.UBBorderFrame.Position = UDim2.new(p.X.Scale, p.X.Offset - 2, p.Y.Scale, p.Y.Offset - 2)
                savePos()
            end
        end)
    end)
end
local cdPanel = MiniPanel("Command Cooldowns", -260, 60, 196)
do
    local cloneref = cloneref or function(o) return o end
    local Players  = cloneref(game:GetService("Players"))
    local player   = Players.LocalPlayer
    local CD_CMDS = {
        { name = "rocket",    display = "Rocket",    inGame = "rocket"    },
        { name = "ragdoll",   display = "Ragdoll",   inGame = "ragdoll"   },
        { name = "balloon",   display = "Balloon",   inGame = "balloon"   },
        { name = "inverse",   display = "Inverse",   inGame = "inverse"   },
        { name = "jail",      display = "Jail",      inGame = "jail"      },
        { name = "control",   display = "Control",   inGame = "control"   },
        { name = "tiny",      display = "Titty",     inGame = "tiny"      },
        { name = "jumpscare", display = "Jumpscare", inGame = "jumpscare" },
        { name = "morph",     display = "Morph",     inGame = "morph"     },
    }
    local READY  = Color3.fromRGB(80, 200, 80)
    local ONCD   = Color3.fromRGB(255, 100, 100)
    local BARCD  = Color3.fromRGB(200, 60, 60)
    local rows = {}
    for _, cmd in ipairs(CD_CMDS) do
        local row = Instance.new("Frame")
        row.Size             = UDim2.new(1, -8, 0, 26)
        row.BackgroundColor3 = T.Card
        row.BorderSizePixel  = 0
        row.ZIndex           = 52
        row.Parent           = cdPanel.body
        Corner(row, 6)
        Stroke(row, T.Line, 1, 0.3)
        local bar = Instance.new("Frame")
        bar.Size             = UDim2.new(0, 3, 1, -8)
        bar.Position         = UDim2.new(0, 0, 0, 4)
        bar.BackgroundColor3 = READY
        bar.BorderSizePixel  = 0
        bar.ZIndex           = 53
        bar.Parent           = row
        Corner(bar, 2)
        local nameLbl = Lbl(row, cmd.display, 11, T.Text, Enum.Font.GothamBold)
        nameLbl.Size           = UDim2.new(1, -76, 1, 0)
        nameLbl.Position       = UDim2.new(0, 12, 0, 0)
        nameLbl.TextYAlignment = Enum.TextYAlignment.Center
        nameLbl.ZIndex         = 53
        local dot = Instance.new("Frame")
        dot.Size             = UDim2.new(0, 10, 0, 10)
        dot.Position         = UDim2.new(1, -16, 0.5, -5)
        dot.BackgroundColor3 = READY
        dot.BorderSizePixel  = 0
        dot.ZIndex           = 54
        dot.Parent           = row
        Corner(dot, 5)
        local status = Lbl(row, "", 11, ONCD, Enum.Font.GothamBold, Enum.TextXAlignment.Right)
        status.Size           = UDim2.new(0, 40, 1, 0)
        status.Position       = UDim2.new(1, -58, 0, 0)
        status.TextYAlignment = Enum.TextYAlignment.Center
        status.ZIndex         = 53
        rows[cmd.name] = { status = status, bar = bar, dot = dot }
    end
    task.spawn(function()
        while true do
            task.wait(0.3)
            if not cdPanel.panel.Visible then continue end
            pcall(function()
                local pg = player:FindFirstChild("PlayerGui")
                local ap = pg and pg:FindFirstChild("AdminPanel")
                local panel = ap and ap:FindFirstChild("AdminPanel")
                local content = panel and panel:FindFirstChild("Content")
                local sf = content and content:FindFirstChild("ScrollingFrame")
                if not sf then return end
                for _, cmd in ipairs(CD_CMDS) do
                    local r = rows[cmd.name]
                    local cmdFrame = sf:FindFirstChild(cmd.inGame)
                    if r and cmdFrame then
                        local timer = cmdFrame:FindFirstChild("Timer")
                        if timer and timer.Visible then
                            r.status.Text          = timer.Text ~= "" and timer.Text or "..."
                            r.status.TextColor3     = ONCD
                            r.bar.BackgroundColor3  = BARCD
                            r.dot.BackgroundColor3  = ONCD
                        else
                            r.status.Text           = ""
                            r.bar.BackgroundColor3   = READY
                            r.dot.BackgroundColor3   = READY
                        end
                    end
                end
            end)
        end
    end)
end
local AnimalFX = (function()
    local RS  = game:GetService("ReplicatedStorage")
    local AFX = {}
    local _sa
    local function GetSharedAnimals()
        if _sa == nil then
            local ok, res = pcall(function() return require(RS:WaitForChild("Shared"):WaitForChild("Animals")) end)
            _sa = ok and res or false
        end
        return _sa or nil
    end
    AFX.GetSharedAnimals = GetSharedAnimals

    local BG_COL = Color3.fromRGB(12, 12, 14)
    local MUT_PALETTES = {
        Gold        = {Color3.fromRGB(237,178,0),   Color3.fromRGB(237,194,86), Color3.fromRGB(215,111,1),  Color3.fromRGB(139,74,0),   Color3.fromRGB(255,164,164), Color3.fromRGB(255,244,190)},
        Diamond     = {Color3.fromRGB(37,196,254),  Color3.fromRGB(116,212,254),Color3.fromRGB(28,137,254), Color3.fromRGB(21,64,254),   Color3.fromRGB(160,162,254), Color3.fromRGB(176,255,252)},
        Bloodrot    = {Color3.fromRGB(145,0,27),    Color3.fromRGB(154,94,100), Color3.fromRGB(75,0,7),     Color3.fromRGB(72,0,2),      Color3.fromRGB(121,112,112), Color3.fromRGB(255,152,154)},
        Candy       = {Color3.fromRGB(255,105,180), Color3.fromRGB(255,182,193),Color3.fromRGB(200,50,150), Color3.fromRGB(255,20,147),  Color3.fromRGB(255,200,220), Color3.fromRGB(255,240,245)},
        Lava        = {Color3.fromRGB(200,50,0),    Color3.fromRGB(255,100,0),  Color3.fromRGB(150,20,0),   Color3.fromRGB(100,10,0),    Color3.fromRGB(255,160,0),   Color3.fromRGB(255,220,100)},
        Galaxy      = {Color3.fromRGB(60,0,120),    Color3.fromRGB(100,0,180),  Color3.fromRGB(30,0,80),    Color3.fromRGB(180,0,255),   Color3.fromRGB(80,0,160),    Color3.fromRGB(200,150,255)},
        YinYang     = {BG_COL, Color3.fromRGB(20,20,28), Color3.fromRGB(230,230,240), Color3.fromRGB(230,230,240), Color3.fromRGB(128,128,128), Color3.fromRGB(24,24,30)},
        Radioactive = {Color3.fromRGB(100,255,0),   Color3.fromRGB(150,255,50), Color3.fromRGB(50,200,0),   Color3.fromRGB(0,150,0),     Color3.fromRGB(200,255,100), Color3.fromRGB(230,255,180)},
        Cursed      = {Color3.fromRGB(255,23,23),   Color3.fromRGB(180,0,0),    Color3.fromRGB(120,0,0),    Color3.fromRGB(80,0,0),      Color3.fromRGB(255,100,100), Color3.fromRGB(255,180,180)},
        Divine      = {Color3.fromRGB(255,215,0),   Color3.fromRGB(255,255,200),Color3.fromRGB(200,160,0),  Color3.fromRGB(255,240,150), BG_COL,                      Color3.fromRGB(255,250,220)},
    }

    function AFX.ApplyMutation(model, animalName, mutName, skipShared)
        if not mutName or mutName == "None" then return end

        if not skipShared then
            local sa = GetSharedAnimals()
            if sa then
                local ok = pcall(function() sa:ApplyMutation(model, animalName, mutName) end)
                if ok then return end
            end
        end
        local ok2, mutData = pcall(function() return require(RS.Datas.Mutations) end)
        local palette = MUT_PALETTES[mutName]
        if ok2 and mutData and mutData[mutName] and mutData[mutName].Palettes then
            palette = mutData[mutName].Palettes[1] or palette
        end
        if mutName == "Rainbow" then model:AddTag("RainbowModel"); return end

        local descendants = _deepChildren(model)
        for _, v in ipairs(descendants) do
            if v:IsA("BasePart") and not v:GetAttribute("IgnoreColor") then
                pcall(function()
                    if palette then
                        local mv = v.MaterialVariant
                        if mv == "Strawberry Stud Light" or mv == "Strawberry Stud Dark" then
                            v.MaterialVariant = mutName .. " Strawberry Stud Light"
                        else
                            local colorIdx = tonumber(v:GetAttribute(mutName .. "*Color") or v:GetAttribute("Color") or 1) or 1
                            colorIdx = math.clamp(colorIdx, 1, #palette)
                            local col = palette[colorIdx] or palette[1]
                            if col then
                                local surfApp = v:FindFirstChildOfClass("SurfaceAppearance")
                                if surfApp then surfApp:Destroy() end
                                v.Color = col
                                if v:GetAttribute("Neon") then v.Material = Enum.Material.Neon end
                            end
                        end
                    end

                    if mutName == "Galaxy" then
                        if (v:GetAttribute("GalaxyColor") or v:GetAttribute("Color") or 1) == 1 then v.Material = Enum.Material.Neon end
                        v.MaterialVariant = "Galaxy Stud"
                    elseif mutName == "Lava" then
                        if (v:GetAttribute("LavaColor") or v:GetAttribute("Color") or 1) == 1 then v.Material = Enum.Material.Neon end
                    elseif mutName == "YinYang" then
                        local c = v:GetAttribute("YinYangColor") or v:GetAttribute("Color") or 1
                        if c == 3 or c == 4 then v.Material = Enum.Material.Neon end
                    elseif mutName == "Divine" then
                        local c = v:GetAttribute("DivineColor") or v:GetAttribute("Color") or 1
                        if c == 2 then v.Material = Enum.Material.Neon end
                        if v:GetAttribute("Divine*Stud") == false then
                            v.MaterialVariant = ""
                        elseif v.MaterialVariant == "Custom Stud" or v:GetAttribute("Divine*Stud") == true or (c ~= 2 and c ~= 6) then
                            v.Material = Enum.Material.SmoothPlastic
                            v.MaterialVariant = "Divine Stud"
                        end
                    elseif mutName == "Radioactive" then
                        local c = v:GetAttribute("RadioactiveColor") or v:GetAttribute("Color") or 1
                        if c == 2 then v.Material = Enum.Material.Neon end
                        if v:GetAttribute("Radioactive*Stud") == false then
                            v.MaterialVariant = ""
                        elseif v.MaterialVariant == "Custom Stud" or v:GetAttribute("Radioactive*Stud") == true or (c ~= 2 and c ~= 6) then
                            v.Material = Enum.Material.SmoothPlastic
                            v.MaterialVariant = "Radioactive Stud"
                        end
                    elseif mutName == "Cursed" then
                        local c = v:GetAttribute("CursedColor") or v:GetAttribute("Color") or 1
                        if c == 2 then v.Material = Enum.Material.Neon end
                        if v:GetAttribute("Cursed*Stud") == false then
                            v.MaterialVariant = ""
                        elseif v.MaterialVariant == "Custom Stud" or v:GetAttribute("Cursed*Stud") == true or (c ~= 2 and c ~= 6) then
                            v.Material = Enum.Material.SmoothPlastic
                            v.MaterialVariant = "Cursed Stud"
                            v.Color = Color3.fromRGB(255, 23, 23)
                        end
                        local sa2 = v:FindFirstChildOfClass("SurfaceAppearance")
                        if sa2 then
                            if not v:GetAttribute("Cursed*IgnoreSurfaceColor") then sa2.Color = Color3.fromRGB(255, 23, 23) end
                            if v:GetAttribute("IgnoreSurface") then sa2:Destroy() end
                        end
                    elseif mutName == "Cyber" and v.Transparency ~= 1 then
                        local c = tonumber(v:GetAttribute("Cyber*Color") or v:GetAttribute("Color") or 1) or 1
                        local surfApp = v:FindFirstChildOfClass("SurfaceAppearance")
                        if v:GetAttribute("Eyes") then
                            v.Color = Color3.fromRGB(62, 155, 255); v.Transparency = 0.25; v.Material = Enum.Material.Neon; return
                        end
                        if c == 7 then v.Material = Enum.Material.Neon
                        elseif c == 4 then
                            v.Transparency = 0.5; v.Material = Enum.Material.SmoothPlastic
                            v.MaterialVariant = "Tech Stud"; v.Color = Color3.fromRGB(62, 155, 255)
                        elseif c == 3 then
                            v.Material = Enum.Material.Glass; v.Transparency = 0.5
                            if not surfApp and v.ClassName == "MeshPart" then Instance.new("SurfaceAppearance").Parent = v end
                        elseif c == 1 then
                            v.Material = Enum.Material.Glass; v.Transparency = 0.25
                            if not surfApp and v.ClassName == "MeshPart" then Instance.new("SurfaceAppearance").Parent = v end
                        end
                        surfApp = v:FindFirstChildOfClass("SurfaceAppearance")
                        if surfApp then
                            local vol = v.Size.X * v.Size.Y * v.Size.Z
                            v.Transparency = 0; v.Material = Enum.Material.Neon
                            surfApp.AlphaMode = Enum.AlphaMode.Overlay
                            surfApp.EmissiveTint = Color3.fromRGB(255, 255, 255)
                            if vol > 3 then
                                surfApp.Color = Color3.fromRGB(35, 75, 115); surfApp.EmissiveStrength = 50
                            else
                                surfApp.Color = Color3.fromRGB(0, 25, 30); surfApp.EmissiveStrength = 25
                            end
                        end
                    end
                end)
            end
        end
        pcall(function()
            local vfxFolder = RS.Vfx:FindFirstChild(mutName)
            local vfxInst = model:FindFirstChild("VfxInstance")
            if vfxFolder and vfxInst then
                for _, vfx in ipairs(vfxFolder:GetChildren()) do
                    pcall(function() vfx:Clone().Parent = vfxInst end)
                end
            end
        end)
    end

    local function AttachViaRigidConstraint(clone, model)
        for _, part in ipairs(clone:GetChildren()) do
            if part:IsA("BasePart") or part:IsA("MeshPart") or part:IsA("Model") then
                for _, att in ipairs(part:GetChildren()) do
                    if att:IsA("Attachment") then
                        local target = model:FindFirstChild(att.Name, true)
                        if target and target:IsA("Attachment") then
                            local rc = Instance.new("RigidConstraint")
                            rc.Attachment0 = att; rc.Attachment1 = target; rc.Parent = part
                        end
                    end
                end
            end
        end
    end

    local function alignTraitClone(clone, model)
        for _, att in ipairs(_deepChildren(clone)) do
            if att:IsA("Attachment") then
                local target = model:FindFirstChild(att.Name, true)
                if target and target:IsA("Attachment") then
                    local t = target.WorldCFrame * att.WorldCFrame:Inverse()
                    if clone:IsA("Model") then
                        pcall(function() clone:PivotTo(t * clone:GetPivot()) end)
                    elseif clone:IsA("BasePart") then
                        clone.CFrame = t * clone.CFrame
                    end
                    return true
                end
            end
        end
        return false
    end
    local function anchorClone(clone)
        for _, d in ipairs(_deepChildren(clone)) do
            if d:IsA("BasePart") then d.Anchored = true; d.CanCollide = false end
        end
        if clone:IsA("BasePart") then clone.Anchored = true; clone.CanCollide = false end
    end

    function AFX.traitNames(traitList)
        local list = {}
        if typeof(traitList) == "table" then
            for k, v in pairs(traitList) do
                if type(k) == "number" then list[#list + 1] = tostring(v) else list[#list + 1] = tostring(k) end
            end
        end
        return list
    end

    function AFX.ApplyTraits(model, animalName, traitList, skipShared)
        if not traitList then return end
        local list = AFX.traitNames(traitList)
        if #list == 0 then return end

        if not skipShared then
            local sa0 = GetSharedAnimals()
            if sa0 then
                local ok = pcall(function() sa0:ApplyTraits(model, animalName, list) end)
                if ok then return end
            end
        end
        local tap       = RS.Models and RS.Models:FindFirstChild("TraitsPerAnimal")
        local modTraits = RS.Models and RS.Models:FindFirstChild("Traits")
        local vfxTraits = RS.Vfx and RS.Vfx:FindFirstChild("Traits")
        local rootPart  = model.PrimaryPart or model:FindFirstChild("RootPart")
            or model:FindFirstChildWhichIsA("BasePart", true)
        local sa = GetSharedAnimals()
        for _, traitName in ipairs(list) do
            pcall(function()
                if model:FindFirstChild("_Trait." .. traitName) then return end
                local source
                if tap then
                    local tf = tap:FindFirstChild(traitName)
                    source = tf and tf:FindFirstChild(animalName)
                end
                if not source and modTraits then source = modTraits:FindFirstChild(traitName) end
                local vfxSource
                if not source and vfxTraits then vfxSource = vfxTraits:FindFirstChild(traitName) end
                if source then
                    local clone = source:Clone()
                    clone.Name = "_Trait." .. traitName
                    local aligned = alignTraitClone(clone, model)
                    clone.Parent = model
                    if not aligned then AttachViaRigidConstraint(clone, model) end
                    anchorClone(clone)
                elseif vfxSource then
                    local clone = vfxSource:Clone()
                    clone.Name = "_Trait." .. traitName
                    local aligned = alignTraitClone(clone, model)
                    if not aligned and rootPart then
                        local vfxPart = clone:FindFirstChild("VfxInstance") or clone:FindFirstChildWhichIsA("BasePart", true)
                        if vfxPart and vfxPart:IsA("BasePart") then vfxPart.CFrame = rootPart.CFrame end
                    end
                    clone.Parent = model
                    anchorClone(clone)
                elseif sa then
                    pcall(function() sa:ApplyTraits(model, animalName, { traitName }) end)
                end
            end)
        end
    end

    AFX.TRAIT_ICONS = {
        ["Taco"]="rbxassetid://89041930759464", ["Nyan"]="rbxassetid://104229924295526", ["Galactic"]="rbxassetid://99181785766598",
        ["Fireworks"]="rbxassetid://121100427764858", ["Zombie"]="rbxassetid://110723387483939", ["Claws"]="rbxassetid://104964195846833",
        ["Glitched"]="rbxassetid://121332433272976", ["Bubblegum"]="rbxassetid://100601425541874", ["Fire"]="rbxassetid://118283346037788",
        ["Wet"]="rbxassetid://78474194088770", ["Snowy"]="rbxassetid://83627475909869", ["Cometstruck"]="rbxassetid://127455440418221",
        ["Explosive"]="rbxassetid://97725744252608", ["Disco"]="rbxassetid://82620342632406", ["10B"]="rbxassetid://134655415681926",
        ["Shark Fin"]="rbxassetid://104985313532149", ["Matteo Hat"]="rbxassetid://115664804212096", ["Brazil"]="rbxassetid://75650816341229",
        ["Sleepy"]="rbxassetid://115001117876534", ["Lightning"]="rbxassetid://139729696247144", ["UFO"]="rbxassetid://110910518481052",
        ["Spider"]="rbxassetid://117478971325696", ["Strawberry"]="rbxassetid://84731118566493", ["Paint"]="rbxassetid://119591742504251",
        ["Skeleton"]="rbxassetid://89591838221335", ["Sombrero"]="rbxassetid://95128039793845", ["Tie"]="rbxassetid://103610037004911",
        ["Witch Hat"]="rbxassetid://123964048606874", ["Indonesia"]="rbxassetid://93350414974589", ["Meowl"]="rbxassetid://114748221761549",
        ["RIP Gravestone"]="rbxassetid://123115843719383", ["Jackolantern Pet"]="rbxassetid://97054765273857", ["Santa Hat"]="rbxassetid://88375043733582",
        ["Reindeer Pet"]="rbxassetid://70894779883038", ["Skibidi"]="rbxassetid://83384385019272", ["26"]="rbxassetid://80468035315420",
        ["Rose"]="rbxassetid://135489065859287", [":3"]="rbxassetid://108293878529172", ["Chocolate"]="rbxassetid://81641382604997",
        ["Halo"]="rbxassetid://98316436141359", ["Lucky"]="rbxassetid://124098467754457", ["Orange Balloon"]="rbxassetid://83111173051279",
        ["Green Balloon"]="rbxassetid://75222826429094", ["Blue Balloon"]="rbxassetid://128841931686463", ["Red Balloon"]="rbxassetid://119661964026012",
        ["Pink Balloon"]="rbxassetid://114128099162490", ["Rainbow Balloon"]="rbxassetid://112821854659961", ["Granny"]="rbxassetid://73467619616299",
        ["Bunny Ears"]="rbxassetid://118516289496954", ["Orange Egg"]="rbxassetid://76307362192037", ["Green Egg"]="rbxassetid://94602857440295",
        ["Blue Egg"]="rbxassetid://109212886335786", ["Pink Egg"]="rbxassetid://133939661230277", ["John Pork"]="rbxassetid://117176397136731",
    }

    local _templateCache = {}
    local _templateIndex = _G._FH_TEMPLATE_INDEX or {}
    local _templateIndexBuilt = _G._FH_TEMPLATE_INDEX_BUILT or false
    local function _buildTemplateIndex()
        if _templateIndexBuilt then return end
        _templateIndexBuilt = true
        _G._FH_TEMPLATE_INDEX_BUILT = true
        pcall(function()
            local animalsFolder = RS:FindFirstChild("Models") and RS.Models:FindFirstChild("Animals")
            if not animalsFolder then return end
            for _, d in ipairs(animalsFolder:GetChildren()) do
                if d:IsA("Model") then
                    local key = string.lower(d.Name)
                    if _templateIndex[key] == nil then
                        _templateIndex[key] = d
                    end
                end
            end
            _G._FH_TEMPLATE_INDEX = _templateIndex
        end)
    end
    function AFX.getTemplate(name)
        if _templateCache[name] ~= nil then
            local v = _templateCache[name]
            return v ~= false and v or nil
        end
        local ok, v = pcall(function() return RS.Models.Animals[name] end)
        if ok and v then _templateCache[name] = v; return v end
        local lower = string.lower(name)
        _buildTemplateIndex()
        local found = _templateIndex[lower]
        _templateCache[name] = found or false
        return found
    end
    function AFX.getAnimFolder(name)
        local ok, v = pcall(function() return RS.Animations.Animals[name] end); return ok and v or nil
    end

    function AFX.makeViewport(parent, opts)
        opts = opts or {}
        local name    = opts.name or "?"
        local zIdx    = opts.zindex or 54
        local boxSize = opts.size   or UDim2.new(0, 58, 0, 58)
        local boxPos  = opts.pos    or UDim2.new(0, 6, 0.5, -29)

        local box = Instance.new("Frame")
        box.Name                   = "AnimalBadge"
        box.Size                   = boxSize
        box.Position               = boxPos
        box.BackgroundColor3       = T.BgDeep
        box.BackgroundTransparency = 0.1
        box.BorderSizePixel        = 0
        box.ZIndex                 = zIdx
        box.ClipsDescendants       = true
        box.Parent                 = parent
        Corner(box, opts.corner or 6)

        local initials = name:match("%S") or "?"
        local main = Lbl(box, string.upper(initials), 24, T.TextDim, Enum.Font.GothamBold, Enum.TextXAlignment.Center)
        main.Size                   = UDim2.new(1, 0, 1, 0)
        main.BackgroundTransparency = 1
        main.TextYAlignment         = Enum.TextYAlignment.Center
        main.ZIndex                 = zIdx + 1

        if opts.mutation and opts.mutation ~= "None" then
            local badge = Lbl(box, tostring(opts.mutation):sub(1, 2):upper(), 8, T.Text, Enum.Font.GothamBold, Enum.TextXAlignment.Center)
            badge.Size                   = UDim2.new(0, 18, 0, 12)
            badge.Position               = UDim2.new(1, -20, 0, 4)
            badge.BackgroundTransparency = 0.15
            badge.BackgroundColor3       = T.Card
            badge.ZIndex                 = zIdx + 4
            Corner(badge, 4)
        end

        task.spawn(function()
            local template = AFX.getTemplate(name)
            if not (template and box.Parent) then return end
            local ok, clone = pcall(function() return template:Clone() end)
            if not ok or not clone then return end

            for _, d in ipairs(clone:GetDescendants()) do
                if d:IsA("BasePart") then
                    d.Anchored   = true
                    d.CanCollide = false
                end
            end

            if opts.mutation and opts.mutation ~= "None" then
                pcall(AFX.ApplyMutation, clone, name, tostring(opts.mutation))
            end
            if opts.traits then
                local list = AFX.traitNames(opts.traits)
                if #list > 0 then pcall(AFX.ApplyTraits, clone, name, list) end
            end

            local vp = Instance.new("ViewportFrame")
            vp.Size                   = UDim2.new(1, 0, 1, 0)
            vp.BackgroundTransparency = 1
            vp.BorderSizePixel        = 0
            vp.ZIndex                 = zIdx + 2
            vp.Ambient                = Color3.fromRGB(200, 200, 200)
            vp.LightColor             = Color3.fromRGB(255, 255, 255)
            vp.LightDirection         = Vector3.new(-0.5, -1, -0.6)

            clone.Parent = vp

            local cam = Instance.new("Camera")
            cam.FieldOfView = 35
            vp.CurrentCamera = cam
            cam.Parent = vp

            pcall(function()
                local cf, size = clone:GetBoundingBox()
                local center = cf.Position
                local radius = math.max(size.X, size.Y, size.Z) * 0.6
                local dist   = radius / math.tan(math.rad(cam.FieldOfView / 2))
                cam.CFrame   = CFrame.new(
                    center + Vector3.new(dist * 0.45, size.Y * 0.15, dist * 1.0),
                    center
                )
            end)

            if box.Parent then
                vp.Parent    = box
                main.Visible = false
            else
                vp:Destroy()
                clone:Destroy()
            end
        end)

        return box
    end

    return AFX
end)()
local priorityPanel = MiniPanel("Steal Priority", -280, 110, 234, isMobile and 0.82 or 1)
do
    local saved = Config.get("priority_set", nil)
    if type(saved) == "table" then
        for name, v in pairs(saved) do
            if v then AutoGrab.priority[name] = true; break end
        end
    end
    local RS = game:GetService("ReplicatedStorage")
    local SharedAnimals
    pcall(function() SharedAnimals = require(RS:WaitForChild("Shared"):WaitForChild("Animals")) end)
    local _templateCache = {}
    local _templateIndex = _G._FH_TEMPLATE_INDEX or {}
    local _templateList = _G._FH_TEMPLATE_LIST or {}
    local _templateIndexBuilt = _G._FH_TEMPLATE_INDEX_BUILT or false
    local function _buildTemplateIndex()
        if _templateIndexBuilt and #_templateList > 0 then return end
        if _templateIndexBuilt then
            for _, d in pairs(_templateIndex) do
                _templateList[#_templateList + 1] = d
            end
            _G._FH_TEMPLATE_LIST = _templateList
            return
        end
        _templateIndexBuilt = true
        _G._FH_TEMPLATE_INDEX_BUILT = true
        pcall(function()
            local animalsFolder = RS:FindFirstChild("Models") and RS.Models:FindFirstChild("Animals")
            if not animalsFolder then return end
            for _, d in ipairs(animalsFolder:GetChildren()) do
                if d:IsA("Model") then
                    local key = string.lower(d.Name)
                    if _templateIndex[key] == nil then
                        _templateIndex[key] = d
                        _templateList[#_templateList + 1] = d
                    end
                end
            end
            _G._FH_TEMPLATE_INDEX = _templateIndex
            _G._FH_TEMPLATE_LIST = _templateList
        end)
    end
    local function getTemplate(name)
        if _templateCache[name] ~= nil then
            local v = _templateCache[name]
            return v ~= false and v or nil
        end
        local ok, v = pcall(function() return RS.Models.Animals[name] end)
        if ok and v then _templateCache[name] = v; return v end
        local lower = string.lower(name)
        _buildTemplateIndex()
        local found = _templateIndex[lower]
        if not found then
            for _, d in ipairs(_templateList) do
                if string.lower(d.Name):find(lower, 1, true) then
                    found = d
                    break
                end
            end
        end
        _templateCache[name] = found or false
        return found
    end
    local function getAnimFolder(name) local ok, v = pcall(function() return RS.Animations.Animals[name] end); return ok and v or nil end
    local function fmtNum(n)
        n = tonumber(n) or 0
        local s = { "", "K", "M", "B", "T", "Qa", "Qi" }
        local i = 1
        while n >= 1000 and i < #s do n = n / 1000; i = i + 1 end
        return string.format(i == 1 and "%d%s" or "%.1f%s", n, s[i])
    end
    local function makeViewport(parent, name, mutation, traits)
        local box = Instance.new("Frame")
        box.Name                   = "AnimalBadge"
        box.Size                   = UDim2.new(0, 58, 0, 58)
        box.Position               = UDim2.new(0, 6, 0.5, -29)
        box.BackgroundColor3       = T.BgDeep
        box.BackgroundTransparency = 0.1
        box.BorderSizePixel        = 0
        box.ZIndex                 = 54
        box.Parent                 = parent
        Corner(box, 6)

        local initials = (name and name:match("%S")) or "?"
        local ph = Instance.new("TextLabel")
        ph.Size                   = UDim2.new(1, 0, 1, 0)
        ph.BackgroundTransparency = 1
        ph.Text                   = string.upper(initials)
        ph.Font                   = Enum.Font.GothamBold
        ph.TextSize               = 26
        ph.TextColor3             = T.TextDim
        ph.TextYAlignment         = Enum.TextYAlignment.Center
        ph.ZIndex                 = 55
        ph.Parent                 = box

        if mutation and mutation ~= "None" then
            local badge = Instance.new("TextLabel")
            badge.Size                   = UDim2.new(0, 18, 0, 12)
            badge.Position               = UDim2.new(1, -20, 0, 4)
            badge.BackgroundTransparency = 0.15
            badge.BackgroundColor3       = T.Card
            badge.BorderSizePixel        = 0
            badge.Text                   = tostring(mutation):sub(1, 2):upper()
            badge.Font                   = Enum.Font.GothamBold
            badge.TextSize               = 8
            badge.TextColor3             = T.Text
            badge.ZIndex                 = 56
            badge.Parent                 = box
            Corner(badge, 4)
        end

        return box
    end
    local hint = Lbl(priorityPanel.body, "tap an animal to target it", 10, T.TextMute, Enum.Font.Gotham)
    hint.Size           = UDim2.new(1, -4, 0, 14)
    hint.TextXAlignment = Enum.TextXAlignment.Center
    hint.ZIndex         = 52
    local scroll = Instance.new("ScrollingFrame")
    scroll.Size                   = UDim2.new(1, -4, 0, 230)
    scroll.BackgroundTransparency = 1
    scroll.BorderSizePixel        = 0
    scroll.ScrollBarThickness     = 3
    scroll.ScrollBarImageColor3   = T.White
    scroll.CanvasSize             = UDim2.new(0, 0, 0, 0)
    scroll.AutomaticCanvasSize    = Enum.AutomaticSize.Y
    scroll.ScrollingDirection     = Enum.ScrollingDirection.Y
    scroll.ZIndex                 = 52
    scroll.Parent                 = priorityPanel.body
    local sl = Instance.new("UIListLayout")
    sl.Padding   = UDim.new(0, 5)
    sl.SortOrder = Enum.SortOrder.LayoutOrder
    sl.Parent    = scroll
    local function traitText(traits)
        if typeof(traits) ~= "table" then return nil end
        local list = {}
        for k, v in pairs(traits) do
            if type(k) == "number" then list[#list + 1] = tostring(v) else list[#list + 1] = tostring(k) end
        end
        return #list > 0 and table.concat(list, ", ") or nil
    end
    local rows = {}
    local function recSig(rec)
        return tostring(rec.plotName or "") .. "::" .. tostring(rec.pod or 0) .. "::" .. tostring(rec.name)
    end
    local function makeCard(rec)
        local name = rec.name
        local sig = recSig(rec)
        local card = Instance.new("TextButton")
        card.Size             = UDim2.new(1, -6, 0, 70)
        card.BackgroundColor3 = T.Card
        card.AutoButtonColor  = false
        card.Text             = ""
        card.BorderSizePixel  = 0
        card.ZIndex           = 53
        card.Parent           = scroll
        Corner(card, 8)
        local baseStroke = Stroke(card, T.Line, 1)
        local gradStroke = GradStroke(card, 1.6, 1, 0)
        AnimalFX.makeViewport(card, { name = name, mutation = rec.mutation, traits = rec.traits })
        local nameLbl = Lbl(card, name, 12, T.Text, Enum.Font.GothamBold)
        nameLbl.Size           = UDim2.new(1, -100, 0, 16)
        nameLbl.Position       = UDim2.new(0, 72, 0, 8)
        nameLbl.TextTruncate   = Enum.TextTruncate.AtEnd
        nameLbl.ZIndex         = 54
        local genLbl = Lbl(card, "$" .. fmtNum(rec.genValue) .. "/s", 10, T.Green, Enum.Font.GothamBold)
        genLbl.Size     = UDim2.new(1, -100, 0, 12)
        genLbl.Position = UDim2.new(0, 72, 0, 26)
        genLbl.ZIndex   = 54
        local mutLbl = Lbl(card, "Mutation: " .. (rec.mutation and tostring(rec.mutation) or "None"), 9, T.TextDim, Enum.Font.Gotham)
        mutLbl.Size     = UDim2.new(1, -78, 0, 11)
        mutLbl.Position = UDim2.new(0, 72, 0, 40)
        mutLbl.ZIndex   = 54
        local traitList = AnimalFX.traitNames(rec.traits)
        if #traitList > 0 then
            local traitsRow = Instance.new("Frame")
            traitsRow.Size                   = UDim2.new(1, -78, 0, 16)
            traitsRow.Position               = UDim2.new(0, 72, 0, 51)
            traitsRow.BackgroundTransparency = 1
            traitsRow.BorderSizePixel        = 0
            traitsRow.ClipsDescendants       = true
            traitsRow.ZIndex                 = 54
            traitsRow.Parent                 = card
            local ul = Instance.new("UIListLayout")
            ul.FillDirection     = Enum.FillDirection.Horizontal
            ul.VerticalAlignment = Enum.VerticalAlignment.Center
            ul.Padding           = UDim.new(0, 2)
            ul.Parent            = traitsRow
            for i, traitName in ipairs(traitList) do
                if i > 8 then break end
                local icon = AnimalFX.TRAIT_ICONS[traitName]
                local img = Instance.new("ImageLabel")
                img.Size                   = UDim2.new(0, 16, 0, 16)
                img.BackgroundTransparency = icon and 1 or 0.5
                img.BackgroundColor3       = T.BgDeep
                img.BorderSizePixel        = 0
                img.Image                  = icon or ""
                img.ZIndex                 = 55
                img.Parent                 = traitsRow
                if not icon then
                    Corner(img, 3)
                    local l2 = Lbl(img, traitName:sub(1, 2), 7, T.TextDim, Enum.Font.GothamBold, Enum.TextXAlignment.Center)
                    l2.Size           = UDim2.new(1, 0, 1, 0)
                    l2.TextYAlignment = Enum.TextYAlignment.Center
                    l2.ZIndex         = 56
                end
            end
        else
            local traitLbl = Lbl(card, "Traits: None", 9, T.TextMute, Enum.Font.Gotham)
            traitLbl.Size     = UDim2.new(1, -78, 0, 11)
            traitLbl.Position = UDim2.new(0, 72, 0, 52)
            traitLbl.ZIndex   = 54
        end
        local function paint()
            local on = AutoGrab.isPriority(sig)
            card.BackgroundColor3   = on and T.SideActive or T.Card
            baseStroke.Transparency = on and 1 or 0
            gradStroke.Transparency = on and 0 or 1
        end
        paint()
        card.Activated:Connect(function()
            local wasOn = AutoGrab.isPriority(sig)
            for k in pairs(AutoGrab.priority) do AutoGrab.priority[k] = nil end
            if not wasOn then AutoGrab.priority[sig] = true end
            Config.set("priority_set", AutoGrab.priority)
            for _, r in pairs(rows) do r.paint() end
        end)
        rows[sig] = { card = card, paint = paint }
    end
    task.spawn(function()
        while true do
            local vis = priorityPanel.panel.Visible
            _G._FH_GammaNeedList = vis
            if vis then
                local present = {}
                for _, rec in ipairs(AutoGrab.animalList or {}) do
                    local sig = recSig(rec)
                    present[sig] = true
                    if not rows[sig] then makeCard(rec) end
                end
                for sig, r in pairs(rows) do
                    if not present[sig] then r.card:Destroy(); rows[sig] = nil
                    else r.paint() end
                end
                task.wait(0.3)
            else
                task.wait(1)
            end
        end
    end)
end

local animPanel = MiniPanel("Animations", -20, -150, 258)
local _animPanelDragBound = setmetatable({}, { __mode = "k" })
local function _bindAnimPanelDrag(guiObj)
    if not guiObj or not animPanel.startDrag or _animPanelDragBound[guiObj] then return guiObj end
    if not guiObj:IsA("GuiObject") or guiObj:IsA("TextBox") then return guiObj end
    _animPanelDragBound[guiObj] = true
    pcall(function() guiObj.Active = true end)
    guiObj.InputBegan:Connect(function(inp)
        animPanel.startDrag(inp)
    end)
    return guiObj
end
local function _bindAnimPanelDragTree(root)
    if not root then return root end
    _bindAnimPanelDrag(root)
    for _, obj in ipairs(_deepChildren(root)) do
        _bindAnimPanelDrag(obj)
    end
    root.DescendantAdded:Connect(function(obj)
        _bindAnimPanelDrag(obj)
    end)
    return root
end
_bindAnimPanelDragTree(animPanel.panel)
_bindAnimPanelDrag(animPanel.body)
;(function()
    local LP = Players.LocalPlayer or Players.PlayerAdded:Wait()
    local ANIM_PACKS = {
    ["Adidas Sports"]          = {WalkAnim=18537392113, RunAnim=18537384940, JumpAnim=18537380791, FallAnim=18537367238, SwimIdle=18537387180, Swim=18537389531, Animation1=18537376492, Animation2=18537371272, ClimbAnim=18537363391},
    ["Adidas Community"]       = {WalkAnim=122150855457006, RunAnim=82598234841035, JumpAnim=75290611992385, FallAnim=98600215928904, SwimIdle=109346520324160, Swim=133308483266208, Animation1=122257458498464, Animation2=102357151005774, ClimbAnim=88763136693023},
    ["Adidas Aura"]            = {WalkAnim=83842218823011, RunAnim=118320322718866, JumpAnim=109996626521204, FallAnim=95603166884636, SwimIdle=94922130551805, Swim=134530128383903, Animation1=110211186840347, Animation2=114191137265065, ClimbAnim=97824616490448},
    ["Wicked Popular"]         = {WalkAnim=92072849924640, RunAnim=72301599441680, JumpAnim=104325245285198, FallAnim=121152442762481, Animation1=118832222982049, ClimbAnim=131326830509784, SwimIdle=113199415118199, Swim=99384245425157, Animation2=76049494037641},
    ["Elder"]                  = {WalkAnim=10921111375, RunAnim=10921104374, JumpAnim=10921107367, FallAnim=10921105765, SwimIdle=10921110146, Swim=10921108971, ClimbAnim=10921100400, Animation1=10921101664, Animation2=10921102574},
    ["Zombie"]                 = {WalkAnim=10921355261, RunAnim=616163682, JumpAnim=10921351278, FallAnim=10921350320, SwimIdle=10921353442, Swim=10921352344, Animation1=10921344533, Animation2=10921345304, ClimbAnim=10921343576},
    ["Mage"]                   = {WalkAnim=10921152678, RunAnim=10921148209, JumpAnim=10921149743, FallAnim=10921148939, SwimIdle=10921151661, Swim=10921150788, ClimbAnim=10921143404, Animation1=10921144709, Animation2=10921145797},
    ["Catwalk Glam"]           = {WalkAnim=109168724482748, RunAnim=81024476153754, JumpAnim=116936326516985, FallAnim=92294537340807, SwimIdle=98854111361360, Swim=134591743181628, ClimbAnim=119377220967554, Animation1=133806214992291, Animation2=94970088341563},
    ["Astronaut"]              = {WalkAnim=10921046031, RunAnim=10921039308, JumpAnim=10921042494, FallAnim=10921040576, SwimIdle=10921045006, Swim=10921044000, ClimbAnim=10921032124, Animation1=10921034824, Animation2=10921036806},
    ['Wicked "Dancing"']       = {WalkAnim=73718308412641, RunAnim=135515454877967, JumpAnim=78508480717326, FallAnim=78147885297412, SwimIdle=129183123083281, Swim=110657013921774, ClimbAnim=129447497744818, Animation1=92849173543269, Animation2=132238900951109},
    ["Werewolf"]               = {WalkAnim=10921342074, RunAnim=10921336997, FallAnim=10921337907, SwimIdle=10921341319, Swim=10921340419, ClimbAnim=10921329322, Animation1=10921330408, Animation2=10921333667},
    ["Superhero"]              = {WalkAnim=10921298616, RunAnim=10921291831, JumpAnim=10921294559, FallAnim=10921293373, SwimIdle=10921297391, Swim=10921295495, ClimbAnim=10921286911, Animation1=10921288909, Animation2=10921290167},
    ["Toy"]                    = {WalkAnim=10921312010, RunAnim=10921306285, JumpAnim=10921308158, FallAnim=10921307241, SwimIdle=10921310341, Swim=10921309319, ClimbAnim=10921300839, Animation1=10921301576},
    ["No Boundaries"]          = {WalkAnim=18747074203, RunAnim=18747070484, JumpAnim=18747069148, FallAnim=18747062535, SwimIdle=18747071682, Swim=18747073181, ClimbAnim=18747060903, Animation1=18747067405, Animation2=18747063918},
    ["NFL"]                    = {WalkAnim=110358958299415, RunAnim=117333533048078, JumpAnim=119846112151352, FallAnim=129773241321032, SwimIdle=79090109939093, Swim=132697394189921, ClimbAnim=134630013742019, Animation1=92080889861410, Animation2=74451233229259},
    ["Amazon Unboxed"]         = {WalkAnim=90478085024465, RunAnim=134824450619865, JumpAnim=121454505477205, FallAnim=94788218468396, SwimIdle=129126268464847, Swim=105962919001086, ClimbAnim=121145883950231, Animation1=98281136301627},
    ["Vampire"]                = {WalkAnim=10921326949, RunAnim=10921320299, JumpAnim=10921322186, FallAnim=10921321317, SwimIdle=10921325443, Swim=10921324408, ClimbAnim=10921314188, Animation1=10921315373},
    ["Ninja"]                  = {RunAnim=656118852, WalkAnim=656121766, JumpAnim=656117878, FallAnim=656115606, Swim=656119721, SwimIdle=656121397, ClimbAnim=656114359, Idle={656117400,656118341,886742569}},
    ["Robot"]                  = {RunAnim=616091570, WalkAnim=616095330, JumpAnim=616090535, FallAnim=616087089, Swim=616092998, SwimIdle=616094091, ClimbAnim=616086039, Idle={616088211,616089559,885531463}},
    ["Levitation"]             = {RunAnim=616010382, WalkAnim=616013216, JumpAnim=616008936, FallAnim=616005863, Swim=616011509, SwimIdle=616012453, ClimbAnim=616003713, Idle={616006778,616008087,886862142}},
    ["Stylish"]                = {RunAnim=616140816, WalkAnim=616146177, JumpAnim=616139451, FallAnim=616134815, Swim=616143378, SwimIdle=616144772, ClimbAnim=616133594, Idle={616136790,616138447,886888594}},
    ["Bubbly"]                 = {RunAnim=910025107, WalkAnim=910034870, JumpAnim=910016857, FallAnim=910001910, Swim=910028158, SwimIdle=910030921, ClimbAnim=909997997, Idle={910004836,910009958,1018536639}},
    ["Cartoon"]                = {RunAnim=742638842, WalkAnim=742640026, JumpAnim=742637942, FallAnim=742637151, Swim=742639220, SwimIdle=742639812, ClimbAnim=742636889, Idle={742637544,742638445,885477856}},
}
    local applyingAnimPack = false
    local selectedPack = nil
    local animButtons = {}
    local function waitForAnimate(char)
        for _ = 1, 40 do
            local animate = char and char:FindFirstChild("Animate")
            if animate and animate:FindFirstChild("idle") and animate:FindFirstChild("run") and animate:FindFirstChild("walk") then
                return animate
            end
            task.wait(0.1)
        end
        return nil
    end
    local function stopAllTracks(hum)
        if not hum then return end
        for _, track in ipairs(hum:GetPlayingAnimationTracks()) do
            pcall(function() track:Stop(0) end)
        end
    end
    local function ensureAnim(folder, name)
        if not folder then return nil end
        local anim = folder:FindFirstChild(name)
        if not anim then
            anim = Instance.new("Animation")
            anim.Name = name
            anim.Parent = folder
        end
        return anim
    end
    local function ensureIdleSlots(idleFolder, count)
        if not idleFolder then return end
        for i = 1, count do
            ensureAnim(idleFolder, "Animation" .. i)
        end
    end
    local function setAnim(obj, id)
        if obj and id then
            obj.AnimationId = "rbxassetid://" .. tostring(id)
        end
    end
    local function pick(pack, ...)
        for i = 1, select("#", ...) do
            local v = pack[select(i, ...)]
            if v ~= nil then return v end
        end
        return nil
    end
    local function saveAnimPack(name)
        Config.set("anim_pack", name or "")
    end
    local function loadAnimPack()
        local v = Config.get("anim_pack", "")
        if type(v) == "string" and v ~= "" then return v end
        return nil
    end
    local currentCard = Instance.new("Frame")
    currentCard.Size = UDim2.new(1, -8, 0, 28)
    currentCard.BackgroundColor3 = T.Card
    currentCard.BorderSizePixel = 0
    currentCard.ZIndex = 52
    currentCard.Parent = animPanel.body
    Corner(currentCard, 8)
    Stroke(currentCard, T.Line, 1, 0.15)
    _bindAnimPanelDrag(currentCard)
    local currentLbl = Lbl(currentCard, "Current: Default", 10, T.TextDim, Enum.Font.GothamBold)
    currentLbl.Size = UDim2.new(1, -12, 1, 0)
    currentLbl.Position = UDim2.new(0, 10, 0, 0)
    currentLbl.TextYAlignment = Enum.TextYAlignment.Center
    currentLbl.ZIndex = 53
    local searchWrap = Instance.new("Frame")
    searchWrap.Size = UDim2.new(1, -8, 0, 32)
    searchWrap.BackgroundColor3 = T.Card
    searchWrap.BorderSizePixel = 0
    searchWrap.ZIndex = 52
    searchWrap.Parent = animPanel.body
    _bindAnimPanelDrag(searchWrap)
    Corner(searchWrap, 8)
    GradStroke(searchWrap, 1, 0.25, 0)
    local searchIcon = Lbl(searchWrap, "⌕", 11, T.TextDim, Enum.Font.GothamBold, Enum.TextXAlignment.Center)
    searchIcon.Size = UDim2.new(0, 22, 1, 0)
    searchIcon.Position = UDim2.new(0, 6, 0, 0)
    searchIcon.TextYAlignment = Enum.TextYAlignment.Center
    searchIcon.ZIndex = 53
    local searchBox = Instance.new("TextBox")
    searchBox.Size = UDim2.new(1, -34, 1, 0)
    searchBox.Position = UDim2.new(0, 28, 0, 0)
    searchBox.BackgroundTransparency = 1
    searchBox.BorderSizePixel = 0
    searchBox.PlaceholderText = "Search pack"
    searchBox.Text = ""
    searchBox.ClearTextOnFocus = false
    searchBox.Font = Enum.Font.GothamMedium
    searchBox.TextSize = 10
    searchBox.PlaceholderColor3 = T.TextMute
    searchBox.TextColor3 = T.Text
    searchBox.TextXAlignment = Enum.TextXAlignment.Left
    searchBox.ZIndex = 53
    searchBox.Parent = searchWrap
    local actionsRow = Instance.new("Frame")
    actionsRow.Size = UDim2.new(1, -8, 0, 32)
    actionsRow.BackgroundTransparency = 1
    actionsRow.BorderSizePixel = 0
    actionsRow.ZIndex = 52
    actionsRow.Parent = animPanel.body
    local actionsLayout = Instance.new("UIListLayout")
    actionsLayout.FillDirection = Enum.FillDirection.Horizontal
    actionsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    actionsLayout.Padding = UDim.new(0, 4)
    actionsLayout.Parent = actionsRow
    _bindAnimPanelDrag(actionsRow)
    local function smallButton(text, cb)
        local card = Instance.new("TextButton")
        card.Size = UDim2.new(0.5, -2, 1, 0)
        card.BackgroundColor3 = T.Card
        card.BorderSizePixel = 0
        card.AutoButtonColor = false
        card.Text = text
        card.TextSize = 10
        card.Font = Enum.Font.GothamBold
        card.TextColor3 = T.Text
        card.ZIndex = 53
        card.Parent = actionsRow
        Corner(card, 8)
        local stroke = GradStroke(card, 1.2, 0.2, 0)
        card.MouseEnter:Connect(function() Tween(card, F, {BackgroundColor3 = T.CardHover}) end)
        card.MouseLeave:Connect(function() Tween(card, F, {BackgroundColor3 = T.Card}) end)
        _bindAnimPanelDrag(card)
        card.Activated:Connect(function()
            Tween(card, F, {BackgroundColor3 = T.SideActive})
            task.delay(0.12, function() pcall(function() Tween(card, F, {BackgroundColor3 = T.Card}) end) end)
            if cb then task.spawn(cb) end
        end)
        return card, stroke
    end
    local function setCurrent(text, active)
        currentLbl.Text = "Current: " .. tostring(text or "Default")
        currentLbl.TextColor3 = active and T.Text or T.TextDim
    end
    local function repaintButtons()
        for name, rec in pairs(animButtons) do
            local on = selectedPack == name
            rec.button.BackgroundColor3 = on and T.SideActive or T.Card
            rec.button.TextColor3 = on and T.White or T.Text
            rec.stroke.Transparency = on and 1 or 0.15
            rec.grad.Transparency = on and 0 or 1
        end
    end
    local function applyPack(name)
        if applyingAnimPack then return false end
        local pack = ANIM_PACKS[name]
        if not pack then return false end
        applyingAnimPack = true
        local ok = pcall(function()
            local char = LP.Character or LP.CharacterAdded:Wait()
            local animate = waitForAnimate(char)
            if not animate then error("animate missing") end
            local hum = char:FindFirstChildOfClass("Humanoid")
            stopAllTracks(hum)
            setAnim(ensureAnim(animate:FindFirstChild("walk"), "WalkAnim"), pick(pack, "WalkAnim", "Walk"))
            setAnim(ensureAnim(animate:FindFirstChild("run"), "RunAnim"), pick(pack, "RunAnim", "Run"))
            setAnim(ensureAnim(animate:FindFirstChild("jump"), "JumpAnim"), pick(pack, "JumpAnim", "Jump"))
            setAnim(ensureAnim(animate:FindFirstChild("fall"), "FallAnim"), pick(pack, "FallAnim", "Fall"))
            setAnim(ensureAnim(animate:FindFirstChild("climb"), "ClimbAnim"), pick(pack, "ClimbAnim", "Climb"))
            setAnim(ensureAnim(animate:FindFirstChild("swim"), "Swim"), pick(pack, "Swim"))
            setAnim(ensureAnim(animate:FindFirstChild("swimidle"), "SwimIdle"), pick(pack, "SwimIdle") or pick(pack, "Swim"))
            local idleFolder = animate:FindFirstChild("idle")
            if idleFolder then
                local a1 = pick(pack, "Animation1")
                local a2 = pick(pack, "Animation2")
                if a1 or a2 then
                    ensureIdleSlots(idleFolder, 2)
                    setAnim(idleFolder:FindFirstChild("Animation1"), a1 or a2)
                    setAnim(idleFolder:FindFirstChild("Animation2"), a2 or a1)
                elseif pack.Idle and #pack.Idle > 0 then
                    ensureIdleSlots(idleFolder, math.max(2, #pack.Idle))
                    for i, id in ipairs(pack.Idle) do
                        local slot = idleFolder:FindFirstChild("Animation" .. i)
                        if slot then setAnim(slot, id) end
                    end
                end
            end
            animate.Disabled = true
            task.wait(0.06)
            animate.Disabled = false
            if hum then
                pcall(function()
                    hum:ChangeState(Enum.HumanoidStateType.Landed)
                    task.wait(0.03)
                    hum:ChangeState(Enum.HumanoidStateType.Running)
                end)
            end
        end)
        applyingAnimPack = false
        if ok then
            selectedPack = name
            saveAnimPack(name)
            setCurrent(name, true)
            repaintButtons()
            return true
        end
        return false
    end
    local function resetDefault()
        local ok = pcall(function()
            local char = LP.Character or LP.CharacterAdded:Wait()
            local animate = char and char:FindFirstChild("Animate")
            if not animate then error("animate missing") end
            local clone = animate:Clone()
            animate:Destroy()
            clone.Parent = char
        end)
        if ok then
            selectedPack = nil
            saveAnimPack("")
            setCurrent("Default", false)
            repaintButtons()
        end
        return ok
    end
    smallButton("Reapply", function()
        if selectedPack then applyPack(selectedPack) end
    end)
    smallButton("Reset", function()
        resetDefault()
    end)
    local listWrap = Instance.new("Frame")
    listWrap.Size = UDim2.new(1, -8, 0, 236)
    listWrap.BackgroundColor3 = T.BgDeep
    listWrap.BorderSizePixel = 0
    listWrap.ZIndex = 52
    listWrap.Parent = animPanel.body
    _bindAnimPanelDrag(listWrap)
    Corner(listWrap, 8)
    Stroke(listWrap, T.Line, 1, 0.2)
    local animScroll = Instance.new("ScrollingFrame")
    animScroll.Size = UDim2.new(1, -8, 1, -8)
    animScroll.Position = UDim2.new(0, 4, 0, 4)
    animScroll.BackgroundTransparency = 1
    animScroll.BorderSizePixel = 0
    animScroll.ScrollBarThickness = 3
    animScroll.ScrollBarImageColor3 = T.White
    animScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    animScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    animScroll.ScrollingDirection = Enum.ScrollingDirection.Y
    animScroll.ZIndex = 53
    animScroll.Parent = listWrap
    _bindAnimPanelDrag(animScroll)
    local grid = Instance.new("UIGridLayout")
    grid.CellSize = UDim2.new(0.5, -4, 0, 30)
    grid.CellPadding = UDim2.new(0, 4, 0, 4)
    grid.SortOrder = Enum.SortOrder.Name
    grid.Parent = animScroll
    local pad = Instance.new("UIPadding")
    pad.PaddingLeft = UDim.new(0, 2)
    pad.PaddingRight = UDim.new(0, 2)
    pad.PaddingTop = UDim.new(0, 2)
    pad.PaddingBottom = UDim.new(0, 2)
    pad.Parent = animScroll
    local packNames = {}
    for name in pairs(ANIM_PACKS) do
        packNames[#packNames + 1] = name
    end
    table.sort(packNames)
    local function filterList()
        local q = string.lower(searchBox.Text or "")
        for name, rec in pairs(animButtons) do
            rec.button.Visible = (q == "") or (string.find(string.lower(name), q, 1, true) ~= nil)
        end
    end
    for _, name in ipairs(packNames) do
        local btn = Instance.new("TextButton")
        btn.BackgroundColor3 = T.Card
        btn.BorderSizePixel = 0
        btn.AutoButtonColor = false
        btn.Text = name
        btn.TextSize = 9
        btn.Font = Enum.Font.GothamBold
        btn.TextColor3 = T.Text
        btn.TextWrapped = true
        btn.TextTruncate = Enum.TextTruncate.AtEnd
        btn.ZIndex = 54
        btn.Parent = animScroll
        Corner(btn, 6)
        local stroke = Stroke(btn, T.Line, 1, 0.15)
        local grad = GradStroke(btn, 1.4, 1, 0)
        _bindAnimPanelDrag(btn)
        btn.MouseEnter:Connect(function()
            if selectedPack ~= name then
                Tween(btn, F, {BackgroundColor3 = T.CardHover})
            end
        end)
        btn.MouseLeave:Connect(function()
            if selectedPack ~= name then
                Tween(btn, F, {BackgroundColor3 = T.Card})
            end
        end)
        btn.Activated:Connect(function()
            applyPack(name)
        end)
        animButtons[name] = { button = btn, stroke = stroke, grad = grad }
    end
    searchBox:GetPropertyChangedSignal("Text"):Connect(filterList)
    local savedPack = loadAnimPack()
    if savedPack and ANIM_PACKS[savedPack] then
        selectedPack = savedPack
        setCurrent(savedPack, true)
    else
        setCurrent("Default", false)
    end
    repaintButtons()
    filterList()
    LP.CharacterAdded:Connect(function()
        task.delay(1.1, function()
            local saved = loadAnimPack()
            if saved and ANIM_PACKS[saved] then
                applyPack(saved)
            end
        end)
    end)
end)()

local QP = {}
local function _qpVPx()
    local cam = workspace.CurrentCamera
    return (cam and cam.ViewportSize and cam.ViewportSize.X) or 800
end
local function _qpVPy()
    local cam = workspace.CurrentCamera
    return (cam and cam.ViewportSize and cam.ViewportSize.Y) or 600
end
function QP.computeMetrics()
    local vpx, vpy = _qpVPx(), _qpVPy()
    if isMobile then
        local maxW = isTablet and 680 or 560
        local w = math.clamp(math.floor(vpx - 24), 280, maxW)
        QP.W       = w
        QP.H       = isTablet and 96 or 82
        QP.ROW_H   = isTablet and 64 or 56
        QP.EXPANDED_H = isTablet
            and math.clamp(math.floor(vpy * 0.50), 240, 380)
            or  math.clamp(math.floor(vpy * 0.50), 170, 240)
    else
        QP.W       = 410
        QP.H       = 76
        QP.ROW_H   = 42
        QP.EXPANDED_H = 188
    end
end
QP.computeMetrics()
do
    local _qp_saved_pos = Config.get("qp_pos", nil)
    if type(_qp_saved_pos) == "table" and _qp_saved_pos.x and _qp_saved_pos.y then
        local xs = _qp_saved_pos.xs or 0
        local ys = _qp_saved_pos.ys or 0
        if QP.QPWin then
            QP.QPWin.Position         = UDim2.new(xs, _qp_saved_pos.x, ys, _qp_saved_pos.y)
        end
        if QP.QPBorderFrame then
            QP.QPBorderFrame.Position = UDim2.new(xs, _qp_saved_pos.x - 2, ys, _qp_saved_pos.y - 2)
        end
        QP._pending_restore = _qp_saved_pos
        task.defer(function()
            if not QP.QPWin then return end
            local _camQl = workspace.CurrentCamera
            local _vpQl  = _camQl and _camQl.ViewportSize or Vector2.new(1920, 1080)
            local _szQl  = QP.QPWin.AbsoluteSize
            local _absQl = QP.QPWin.AbsolutePosition
            local _lnx   = math.clamp(_absQl.X, 0, math.max(0, _vpQl.X - _szQl.X))
            local _lny   = math.clamp(_absQl.Y, 0, math.max(0, _vpQl.Y - _szQl.Y))
            if math.abs(_lnx - _absQl.X) > 1 or math.abs(_lny - _absQl.Y) > 1 then
                QP.QPWin.Position         = UDim2.new(0, _lnx, 0, _lny)
                QP.QPBorderFrame.Position = UDim2.new(0, _lnx - 2, 0, _lny - 2)
                Config.set("qp_pos", { x = _lnx, y = _lny, xs = 0, ys = 0 })
            end
        end)
    end
    if Config.get("qp_min", false) == true then
        QP.minimized = true
    end
end
QP.minimized  = QP.minimized or false
QP.dragging   = false
QP.dragStart  = nil
QP.panelStart = nil
;(function()
local QP_CMDS = {
    { name = "tiny",    emoji = "\xF0\x9F\xA4\x8F"},
    { name = "jail",    emoji = "\xF0\x9F\x94\x92"},
    { name = "rocket",  emoji = "\xF0\x9F\x9A\x80"},
    { name = "ragdoll", emoji = "\xF0\x9F\x8F\x83"},
    { name = "balloon", emoji = "\xF0\x9F\x8E\x88"},
}
local QP_cooldownBtns = {}
for _, c in ipairs(QP_CMDS) do QP_cooldownBtns[c.name] = {} end
local QP_commandCache = {}
local QP_profileCache = {}
QP.QPBorderFrame = Instance.new("Frame")
QP.QPBorderFrame.Name             = "QuickPanelGradBorder"
QP.QPBorderFrame.Size             = UDim2.new(0, QP.W + 4, 0, QP.H + 4)
QP.QPBorderFrame.Position         = UDim2.new(0, 14, 0.55, -2)
QP.QPBorderFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
QP.QPBorderFrame.BorderSizePixel  = 0
QP.QPBorderFrame.ZIndex           = 18
QP.QPBorderFrame.Visible          = false
QP.QPBorderFrame.Parent           = GUI
QP.QPBorderFrame.BackgroundTransparency = 1
Corner(QP.QPBorderFrame, 12)
GradStroke(QP.QPBorderFrame, 2.5, 0, 135)
QP.QPWin = Instance.new("Frame")
QP.QPWin.Name             = "QuickPanel"
QP.QPWin.Size             = UDim2.new(0, QP.W, 0, QP.H)
QP.QPWin.Position         = UDim2.new(0, 16, 0.55, 0)
QP.QPWin.BackgroundColor3 = T.Bg
QP.QPWin.BorderSizePixel  = 0
QP.QPWin.ZIndex           = 19
QP.QPWin.Visible          = false
QP.QPWin.ClipsDescendants = true
QP.QPWin.Parent           = GUI
QP.QPWin.BackgroundTransparency = 0.25
trackBgFrame(QP.QPWin, "Bg")
Corner(QP.QPWin, 10)
GradStroke(QP.QPWin, 2.5, 0, 135)
if QP._pending_restore then
    local p = QP._pending_restore
    local xs = p.xs or 0
    local ys = p.ys or 0
    QP.QPWin.Position         = UDim2.new(xs, p.x, ys, p.y)
    QP.QPBorderFrame.Position = UDim2.new(xs, p.x - 2, ys, p.y - 2)
    QP._pending_restore = nil
end
_newScale(QP.QPWin, isMobile and (isPhone and 0.55 or 0.83) or 1)
_newScale(QP.QPBorderFrame, isMobile and (isPhone and 0.55 or 0.83) or 1)
QP.QPHdr = Instance.new("Frame")
QP.QPHdr.Size             = UDim2.new(1, 0, 0, 28)
QP.QPHdr.BackgroundColor3 = T.BgDeep
QP.QPHdr.BorderSizePixel  = 0
QP.QPHdr.ZIndex           = 20
QP.QPHdr.Parent           = QP.QPWin
QP.QPHdr.BackgroundTransparency = 0.2
trackBgFrame(QP.QPHdr, "BgDeep")
Corner(QP.QPHdr, 10)
QP.QPHdr.Active = true
QP.QPHdrFill = Instance.new("Frame")
QP.QPHdrFill.Size             = UDim2.new(1, 0, 0, 10)
QP.QPHdrFill.Position         = UDim2.new(0, 0, 1, -10)
QP.QPHdrFill.BackgroundColor3       = T.BgDeep
QP.QPHdrFill.BackgroundTransparency = 0.2
QP.QPHdrFill.BorderSizePixel        = 0
QP.QPHdrFill.ZIndex           = 20
QP.QPHdrFill.Parent           = QP.QPHdr
trackBgFrame(QP.QPHdrFill, "BgDeep")
QP.QPHdrLine = Instance.new("Frame")
QP.QPHdrLine.Size             = UDim2.new(1, 0, 0, 1)
QP.QPHdrLine.Position         = UDim2.new(0, 0, 1, -1)
QP.QPHdrLine.BackgroundColor3 = T.Line
QP.QPHdrLine.BorderSizePixel  = 0
QP.QPHdrLine.ZIndex           = 21
QP.QPHdrLine.Parent           = QP.QPHdr
trackBgFrame(QP.QPHdrLine, "Line")
do
local QPTitleLbl = Lbl(QP.QPHdr, "Quick Panel", 11, T.White, Enum.Font.GothamBold)
QPTitleLbl.Size           = UDim2.new(1, -40, 1, 0)
QPTitleLbl.Position       = UDim2.new(0, 12, 0, 0)
QPTitleLbl.TextXAlignment = Enum.TextXAlignment.Left
QPTitleLbl.TextYAlignment = Enum.TextYAlignment.Center
QPTitleLbl.ZIndex         = 22
end
QP.QPMinBtn = Instance.new("TextButton")
QP.QPMinBtn.Size             = UDim2.new(0, 18, 0, 18)
QP.QPMinBtn.Position         = UDim2.new(1, -24, 0.5, -9)
QP.QPMinBtn.BackgroundColor3 = T.Card
trackBgFrame(QP.QPMinBtn, "Card")
QP.QPMinBtn.BorderSizePixel  = 0
QP.QPMinBtn.Text             = "\226\136\146"
QP.QPMinBtn.TextSize         = 14
QP.QPMinBtn.Font             = Enum.Font.GothamBold
QP.QPMinBtn.TextColor3       = T.White
QP.QPMinBtn.ZIndex           = 23
QP.QPMinBtn.Parent           = QP.QPHdr
Corner(QP.QPMinBtn, 6)
Stroke(QP.QPMinBtn, T.Line, 1)
QP.QPScroll = Instance.new("ScrollingFrame")
QP.QPScroll.Size                  = UDim2.new(1, -12, 1, -34)
QP.QPScroll.Position              = UDim2.new(0, 6, 0, 32)
QP.QPScroll.BackgroundTransparency = 1
QP.QPScroll.BorderSizePixel       = 0
QP.QPScroll.ScrollBarThickness    = 3
QP.QPScroll.ScrollBarImageColor3  = T.Line
QP.QPScroll.CanvasSize            = UDim2.new(0, 0, 0, 0)
QP.QPScroll.AutomaticCanvasSize   = Enum.AutomaticSize.Y
QP.QPScroll.ScrollingDirection    = Enum.ScrollingDirection.Y
QP.QPScroll.ZIndex                = 19
QP.QPScroll.Parent                = QP.QPWin
QP.QPLayout = Instance.new("UIListLayout")
QP.QPLayout.Padding             = UDim.new(0, 2)
QP.QPLayout.SortOrder           = Enum.SortOrder.LayoutOrder
QP.QPLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
QP.QPLayout.Parent              = QP.QPScroll
QP.QPLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    QP.QPScroll.CanvasSize = UDim2.new(0, 0, 0, QP.QPLayout.AbsoluteContentSize.Y + 6)
end)
Pad(QP.QPScroll, 2, 2, 0, 0)
QP.QPNoTarget = Instance.new("TextLabel")
QP.QPNoTarget.Size                   = UDim2.new(1, -20, 0, 24)
QP.QPNoTarget.Position               = UDim2.new(0, 10, 0, 34)
QP.QPNoTarget.BackgroundTransparency = 1
QP.QPNoTarget.Text                   = "No players found"
QP.QPNoTarget.Font                   = Enum.Font.GothamMedium
QP.QPNoTarget.TextColor3             = T.TextDim
QP.QPNoTarget.TextSize               = 12
QP.QPNoTarget.TextXAlignment         = Enum.TextXAlignment.Center
QP.QPNoTarget.Visible                = true
QP.QPNoTarget.ZIndex                 = 20
QP.QPNoTarget.Parent                 = QP.QPWin
local function qpGetAdminSF()
    local ok, sf = pcall(function()
        return Players.LocalPlayer.PlayerGui.AdminPanel.AdminPanel.Content.ScrollingFrame
    end)
    return ok and sf or nil
end
local function qpIsOnCooldown(cmdName)
    -- Use the shared gate so the stamp window (0.5 s post-fire) is respected,
    -- not just the AdminPanel Timer visibility.
    if _G._FH_IsOnCooldown then return _G._FH_IsOnCooldown(cmdName) end
    local sf = qpGetAdminSF()
    if not sf then return false end
    local f = sf:FindFirstChild(cmdName)
    if not f then return false end
    local t = f:FindFirstChild("Timer")
    return t and t.Visible == true
end
local function qpGetCDText(cmdName)
    local sf = qpGetAdminSF()
    if not sf then return nil end
    local f = sf:FindFirstChild(cmdName)
    if not f then return nil end
    local t = f:FindFirstChild("Timer")
    if not t or not t.Visible then return nil end
    return t.Text or ""
    end
local qpCDRunning = false
local function qpStartCDLoop()
    if qpCDRunning then return end
    qpCDRunning = true
    task.spawn(function()
        while QP.QPWin and QP.QPWin.Parent and QP.QPWin.Visible do
            for _, cmd in ipairs(QP_CMDS) do
                local onCD = qpIsOnCooldown(cmd.name)
                local txt  = onCD and qpGetCDText(cmd.name) or nil
                for _, entry in ipairs(QP_cooldownBtns[cmd.name]) do
                    local btn, emoji = entry[1], entry[2]
                    if btn and btn.Parent then
                        if onCD and txt then
                            btn.Text                   = txt
                            btn.TextSize               = 9
                            btn.TextColor3             = Color3.fromRGB(160, 160, 160)
                            btn.BackgroundTransparency = 0.55
                        else
                            btn.Text                   = emoji
                            btn.TextSize               = isMobile and 14 or 18
                            btn.TextColor3             = T.White
                            btn.BackgroundTransparency = 0.3
                        end
                    end
                end
            end
            task.wait(0.25)
        end
        qpCDRunning = false
    end)
end
local function qpGetAdminFrames()
    local ap = Players.LocalPlayer.PlayerGui:FindFirstChild("AdminPanel")
    if not ap then return nil, nil end
    local inner = ap:FindFirstChild("AdminPanel")
    if not inner then return nil, nil end
    local content  = inner:FindFirstChild("Content")
    local profiles = inner:FindFirstChild("Profiles")
    if not content or not profiles then return nil, nil end
    return content:FindFirstChild("ScrollingFrame"), profiles:FindFirstChild("ScrollingFrame")
end
local function qpCacheActivated(guiObj)
    local cached = {}
    local ok, conns = pcall(getconnections, guiObj.Activated)
    if ok and type(conns) == "table"then
        for _, conn in ipairs(conns) do
            if type(conn.Function) == "function"then
                table.insert(cached, conn.Function)
            end
        end
    end
    return cached
end
local function qpFireActivated(cached)
    for _, fn in ipairs(cached) do task.spawn(fn) end
end
local function qpRunCommand(cmdName, target)
    -- Route through the mapped admin remote instead of clicking GUI buttons.
    if _G._FH_FireAdmin and _G._FH_FireAdmin(target, cmdName) then return end
    -- Fallback if the remote couldn't be resolved.
    local cmdFrame, profileFrame = qpGetAdminFrames()
    if not cmdFrame or not profileFrame then return end
    local profileBtn = profileFrame:FindFirstChild(target.Name)
    local commandBtn = cmdFrame:FindFirstChild(cmdName)
    if not profileBtn or not commandBtn then return end
    if not QP_profileCache[target.Name] then
        QP_profileCache[target.Name] = qpCacheActivated(profileBtn)
    end
    if not QP_commandCache[cmdName] then
        QP_commandCache[cmdName] = qpCacheActivated(commandBtn)
    end
    qpFireActivated(QP_profileCache[target.Name])
    task.wait()
    qpFireActivated(QP_commandCache[cmdName])
end
local function qpMakeRow(plr, order)
    local row = Instance.new("Frame")
    row.Name                   = "QP_".. plr.Name
    row.Size                   = UDim2.new(1, -8, 0, QP.ROW_H)
    row.BackgroundColor3       = T.Card
    row.BackgroundTransparency = isMobile and 0.35 or 0.15
    row.BorderSizePixel        = 0
    row.LayoutOrder            = order
    row.ZIndex                 = 20
    row.Parent                 = QP.QPScroll
    Corner(row, 6)
    Stroke(row, T.Line, 1)
    local displayName = plr.DisplayName

    local BTN_SZ  = isTablet and 50 or (isMobile and 42 or 40)
    local BTN_GAP = isTablet and 6 or (isMobile and 4 or 5)
    local BTN_COUNT  = #QP_CMDS
    local btnsW      = BTN_COUNT * BTN_SZ + (BTN_COUNT - 1) * BTN_GAP
    local rightPad   = 4
    local btnsHolder = Instance.new("Frame")
    btnsHolder.Name                   = "QPCmds"
    btnsHolder.BackgroundTransparency = 1
    btnsHolder.Size                   = UDim2.new(0, btnsW, 0, BTN_SZ)
    btnsHolder.Position               = UDim2.new(1, -(btnsW + rightPad), 0.5, -BTN_SZ / 2)
    btnsHolder.ZIndex                 = 21
    btnsHolder.Parent                 = row
    local btnsLayout = Instance.new("UIListLayout")
    btnsLayout.FillDirection         = Enum.FillDirection.Horizontal
    btnsLayout.Padding               = UDim.new(0, BTN_GAP)
    btnsLayout.HorizontalAlignment   = Enum.HorizontalAlignment.Right
    btnsLayout.VerticalAlignment     = Enum.VerticalAlignment.Center
    btnsLayout.SortOrder             = Enum.SortOrder.LayoutOrder
    btnsLayout.Parent                = btnsHolder
    local nameLeft = 10
    local nameW    = math.max(40, QP.W - nameLeft - btnsW - rightPad - 8)
    local nameLbl  = Lbl(row, displayName, isTablet and 15 or (isMobile and 12 or 13), T.White, Enum.Font.GothamBold)
    nameLbl.Size           = UDim2.new(0, nameW, 1, 0)
    nameLbl.Position       = UDim2.new(0, nameLeft, 0, 0)
    nameLbl.TextTruncate   = Enum.TextTruncate.AtEnd
    nameLbl.TextXAlignment = Enum.TextXAlignment.Left
    nameLbl.TextYAlignment = Enum.TextYAlignment.Center
    nameLbl.ZIndex         = 21
    for i, cmd in ipairs(QP_CMDS) do
        local btn = Instance.new("TextButton")
        btn.Name                   = "QPCmd_".. cmd.name
        btn.Size                   = UDim2.new(0, BTN_SZ, 0, BTN_SZ)
        btn.LayoutOrder            = i
        btn.Parent                 = btnsHolder
        btn.BackgroundColor3       = T.Card
        btn.BackgroundTransparency = 0.3
        btn.Text                   = cmd.emoji
        btn.TextSize               = isTablet and 28 or (isMobile and 22 or 18)
        btn.Font                   = Enum.Font.SourceSans
        btn.TextColor3             = T.White
        btn.AutoButtonColor        = false
        btn.ZIndex                 = 21
        Corner(btn, 4)
        Stroke(btn, T.Line, 1)
        table.insert(QP_cooldownBtns[cmd.name], { btn, cmd.emoji })
        btn.MouseEnter:Connect(function()
            if not qpIsOnCooldown(cmd.name) then
                Tween(btn, F, { BackgroundTransparency = 0, BackgroundColor3 = T.CardHover })
            end
        end)
        btn.MouseLeave:Connect(function()
            if not qpIsOnCooldown(cmd.name) then
                Tween(btn, F, { BackgroundTransparency = 0.3, BackgroundColor3 = T.Card })
            end
        end)
        local function fire()
            if qpIsOnCooldown(cmd.name) then return end
            task.spawn(function() qpRunCommand(cmd.name, plr) end)
            Tween(btn, F, { BackgroundColor3 = T.Line })
            task.delay(0.2, function() Tween(btn, F, { BackgroundColor3 = T.Card }) end)
        end
        local qpBtnDebounce = false
        local function fireSafe()
            if qpBtnDebounce then return end
            qpBtnDebounce = true
            fire()
            task.delay(0.35, function() qpBtnDebounce = false end)
        end
        if not isMobile then
            btn.Activated:Connect(fireSafe)
        end
        do
            local _qpBtnTouchStart = nil
            btn.InputBegan:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.Touch then
                    _qpBtnTouchStart = inp.Position
                end
            end)
            btn.InputEnded:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.Touch and _qpBtnTouchStart then
                    local mag = (inp.Position - _qpBtnTouchStart).Magnitude
                    _qpBtnTouchStart = nil
                    if mag < 10 then fireSafe() end
                end
            end)
        end
    end
    return row
end
local function qpResizeToFit()
    local count = 0
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= Players.LocalPlayer then count = count + 1 end
    end
    local HDR      = 28
    local PAD      = 8
    local SPACING  = 2
    local rowH     = QP.ROW_H
    local maxH     = QP.EXPANDED_H
    local minH     = QP.H
    local targetH
    if count == 0 then
        targetH = minH
    else
        targetH = HDR + PAD + count * rowH + math.max(0, count - 1) * SPACING
        targetH = math.max(minH, math.min(maxH, targetH))
    end
    if math.abs(QP.QPWin.Size.Y.Offset - targetH) > 2 then
        Tween(QP.QPWin,         M, { Size = UDim2.new(0, QP.W, 0, targetH) })
        Tween(QP.QPBorderFrame, M, { Size = UDim2.new(0, QP.W + 4, 0, targetH + 4) })
    end
end
local function qpRefresh()
    for _, c in ipairs(QP_CMDS) do QP_cooldownBtns[c.name] = {} end
    for _, child in ipairs(QP.QPScroll:GetChildren()) do
        if child:IsA("Frame") then child:Destroy() end
    end
    local order = 1
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= Players.LocalPlayer then
            qpMakeRow(plr, order)
            order = order + 1
        end
    end
    QP.QPNoTarget.Visible = (order == 1)
    QP.QPScroll.CanvasSize = UDim2.new(0, 0, 0, QP.QPLayout.AbsoluteContentSize.Y + 6)
    qpResizeToFit()
    qpStartCDLoop()
end
Players.PlayerAdded:Connect(function()
    task.wait(0.3)
    if QP.QPWin.Visible then
        qpRefresh()
    end
end)
Players.PlayerRemoving:Connect(function(plr)
    QP_profileCache[plr.Name] = nil
    task.wait(0.3)
    if QP.QPWin.Visible then qpRefresh() end
end)

do
    local _qpResizeJob = 0
    local function _qpOnViewportChanged()
        _qpResizeJob = _qpResizeJob + 1
        local myJob = _qpResizeJob
        task.delay(0.05, function()
            if myJob ~= _qpResizeJob then return end
            QP.computeMetrics()
            local W, H = QP.W, QP.H
            QP.QPWin.Size         = UDim2.new(0, W, 0, QP.minimized and 28 or H)
            QP.QPBorderFrame.Size = UDim2.new(0, W + 4, 0, (QP.minimized and 28 or H) + 4)

            local vpx, vpy = _qpVPx(), _qpVPy()
            local p = QP.QPWin.Position
            local ax = p.X.Scale * vpx + p.X.Offset
            local ay = p.Y.Scale * vpy + p.Y.Offset
            local pad = 4
            if ax < pad then ax = pad end
            if ay < pad then ay = pad end
            if ax > vpx - W - pad then ax = vpx - W - pad end
            if ay > vpy - H - pad then ay = vpy - H - pad end
            QP.QPWin.Position         = UDim2.new(0, ax, 0, ay)
            QP.QPBorderFrame.Position = UDim2.new(0, ax - 2, 0, ay - 2)
            if QP.QPWin.Visible and not QP.minimized then qpRefresh() end
                        Config.set("qp_pos", { x = ax, y = ay, xs = 0, ys = 0 })
        end)
    end
    local function _qpHookCamera()
        local cam = workspace.CurrentCamera
        if not cam then return end
        cam:GetPropertyChangedSignal("ViewportSize"):Connect(_qpOnViewportChanged)
    end
    _qpHookCamera()
    workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(_qpHookCamera)
end
QP.QPHdr.InputBegan:Connect(function(inp)
    if guiLocked then return end
    if inp.UserInputType == Enum.UserInputType.MouseButton1
    or inp.UserInputType == Enum.UserInputType.Touch then
        QP.dragging   = true
        QP.dragStart  = inp.Position
        QP.panelStart = QP.QPWin.Position
        QP.dragMoved  = false
    end
end)
table.insert(_G._FH_DragClearers, function() QP.dragging = false end)
QP.QPHdr.InputEnded:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1
    or inp.UserInputType == Enum.UserInputType.Touch then
        QP.dragging = false
        Config.set("qp_pos", { x = QP.QPWin.Position.X.Offset, y = QP.QPWin.Position.Y.Offset,
                       xs = QP.QPWin.Position.X.Scale, ys = QP.QPWin.Position.Y.Scale })
    end
end)
UserInputService.InputChanged:Connect(function(inp)
    if guiLocked then QP.dragging = false; return end
    if QP.dragging and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
        local d = inp.Position - QP.dragStart
        if not QP.dragMoved then
            if d.Magnitude < 8 then return end
            QP.dragMoved = true; QP.dragStart = inp.Position; return
        end
        local _s = (_UI and _UI.desiredScale) or 1
        if _s <= 0 then _s = 1 end
        local _camQ = workspace.CurrentCamera
        local _vpQ  = _camQ and _camQ.ViewportSize or Vector2.new(1920, 1080)
        local _szQ  = QP.QPWin.AbsoluteSize
        local _qrx  = QP.panelStart.X.Scale * _vpQ.X + QP.panelStart.X.Offset + d.X / _s
        local _qry  = QP.panelStart.Y.Scale * _vpQ.Y + QP.panelStart.Y.Offset + d.Y / _s
        local _qnx  = math.clamp(_qrx, 0, math.max(0, _vpQ.X - _szQ.X))
        local _qny  = math.clamp(_qry, 0, math.max(0, _vpQ.Y - _szQ.Y))
        local newPos = UDim2.new(0, _qnx, 0, _qny)
        QP.QPWin.Position         = newPos
        QP.QPBorderFrame.Position = UDim2.new(0, _qnx - 2, 0, _qny - 2)
    end
end)
QP.QPMinBtn.Activated:Connect(function()
    QP.minimized = not QP.minimized
    if QP.minimized then
        QP.QPWin.ClipsDescendants = false
        QP.QPHdrFill.Visible  = false
        QP.QPHdrLine.Visible  = false
        QP.QPScroll.Visible   = false
        QP.QPNoTarget.Visible = false
        Tween(QP.QPWin,         M, { Size = UDim2.new(0, QP.W, 0, 28) })
        Tween(QP.QPBorderFrame, M, { Size = UDim2.new(0, QP.W + 4, 0, 32) })
        QP.QPMinBtn.Text = "+"
    else
        QP.QPMinBtn.Text = "\226\136\146"
        QP.QPHdrFill.Visible = true
        QP.QPHdrLine.Visible = true
        QP.QPScroll.Visible = true
        QP.QPWin.ClipsDescendants = true
        Tween(QP.QPWin,         M, { Size = UDim2.new(0, QP.W, 0, QP.H) })
        Tween(QP.QPBorderFrame, M, { Size = UDim2.new(0, QP.W + 4, 0, QP.H + 4) })
        task.defer(qpRefresh)
    end
        Config.set("qp_min", QP.minimized)
end)
QP.setQuickPanelVisible = function(vis)
    QP.QPWin.Visible         = vis
    QP.QPBorderFrame.Visible = false
    if vis then
        local p = QP.QPWin.Position
        QP.QPBorderFrame.Position = UDim2.new(p.X.Scale, p.X.Offset - 2, p.Y.Scale, p.Y.Offset - 2)
        if QP.minimized then
            QP.QPMinBtn.Text          = "+"
            QP.QPScroll.Visible       = false
            QP.QPHdrFill.Visible      = false
            QP.QPHdrLine.Visible      = false
            QP.QPWin.ClipsDescendants = false
            QP.QPWin.Size             = UDim2.new(0, QP.W, 0, 28)
            QP.QPBorderFrame.Size     = UDim2.new(0, QP.W + 4, 0, 32)
        else
            QP.QPMinBtn.Text          = "\226\136\146"
            QP.QPScroll.Visible       = true
            QP.QPHdrFill.Visible      = true
            QP.QPHdrLine.Visible      = true
            QP.QPWin.ClipsDescendants = true
            QP.QPWin.Size             = UDim2.new(0, QP.W, 0, QP.H)
            QP.QPBorderFrame.Size     = UDim2.new(0, QP.W + 4, 0, QP.H + 4)
            task.defer(qpRefresh)
        end
    end
end
end)()
local spamPanel = MiniPanel("Admin Spammer", 490, 320, 257, isPhone and 0.65 or nil)
;(function()
    local cloneref    = cloneref or function(o) return o end
    local _Players    = cloneref(game:GetService("Players"))
    local ALL_SPAM_CMDS = {"balloon","tiny","rocket","ragdoll","inverse","jail","morph","jumpscare"}
    Config.set("spammer_semi", Config.get("spammer_semi", {"balloon","tiny","rocket","inverse"}))
    Config.set("spammer_full", Config.get("spammer_full", {"balloon","tiny","rocket","ragdoll","inverse","jail","morph","jumpscare"}))
    local function getSpamSemiCmds()
        local t = Config.get("spammer_semi", {})
        return type(t) == "table" and t or {"balloon","tiny","rocket","inverse"}
    end
    local function getSpamFullCmds()
        local t = Config.get("spammer_full", {})
        return type(t) == "table" and t or {"balloon","tiny","rocket","ragdoll","inverse","jail","morph","jumpscare"}
    end
    local function saveSpamCmds(semi, full)
        Config.set("spammer_semi", semi)
        Config.set("spammer_full", full)
    end
    local spamProfileCache = {}
    local spamCommandCache = {}
    local function spamGetFrames()
        local ap = _Players.LocalPlayer.PlayerGui:FindFirstChild("AdminPanel")
        if not ap then return nil, nil end
        local inner = ap:FindFirstChild("AdminPanel")
        if not inner then return nil, nil end
        local c = inner:FindFirstChild("Content")
        local p = inner:FindFirstChild("Profiles")
        if not c or not p then return nil, nil end
        return c:FindFirstChild("ScrollingFrame"), p:FindFirstChild("ScrollingFrame")
    end
    local function spamCacheBtn(btn)
        local out = {}
        if type(getconnections) ~= "function" then return out end
        local ok, conns = pcall(getconnections, btn.Activated)
        if ok and type(conns) == "table" then
            for _, c in ipairs(conns) do
                if type(c.Function) == "function" then table.insert(out, c.Function) end
            end
        end
        return out
    end
    local function spamFire(fns)
        for _, fn in ipairs(fns) do task.spawn(fn) end
    end
    -- Use the shared gate instead of a separate timestamp table that was
    -- never populated, so the Admin Spammer reads the same cooldown state
    -- as every other panel.
    local function _spamIsOnCD(cmd)
        if _G._FH_IsOnCooldown then return _G._FH_IsOnCooldown(cmd) end
        return false
    end
    local function spamRun(target, cmds)
        -- Route through the mapped admin remote instead of clicking GUI buttons.
        if _G._FH_FireAdmin and _G._FH_ResolveAdminRemote and _G._FH_ResolveAdminRemote() then
            for _, cmd in ipairs(cmds) do
                task.spawn(function() _G._FH_FireAdmin(target, cmd) end)
            end
            return
        end
        -- Fallback if the remote couldn't be resolved.
        local cf, pf = spamGetFrames()
        if not cf or not pf then return end
        local pb = pf:FindFirstChild(target.Name)
        if not pb then return end
        for _, cmd in ipairs(cmds) do
            local cb = cf:FindFirstChild(cmd)
            if not cb then continue end
            task.spawn(spamFire, spamCacheBtn(cb))
            task.spawn(spamFire, spamCacheBtn(pb))
        end
    end
    local gearBtn = Instance.new("TextButton")
    gearBtn.Size             = UDim2.new(0, 20, 0, 20)
    gearBtn.Position         = UDim2.new(1, -48, 0.5, -10)
    gearBtn.BackgroundColor3 = T.Soft
    trackBgFrame(gearBtn, "Soft")
    gearBtn.Text             = "⚙"
    gearBtn.TextColor3       = T.TextDim
    gearBtn.TextSize         = 12
    gearBtn.Font             = Enum.Font.GothamBold
    gearBtn.AutoButtonColor  = false
    gearBtn.ZIndex           = 53
    gearBtn.Parent           = spamPanel.header
    Corner(gearBtn, 6)
    gearBtn.MouseEnter:Connect(function() Tween(gearBtn, F, {TextColor3 = T.Text}) end)
    gearBtn.MouseLeave:Connect(function() Tween(gearBtn, F, {TextColor3 = T.TextDim}) end)
    local hintLbl = Lbl(spamPanel.body, "⚙ to edit cmds  •  right-click Closest to bind", 9, T.TextMute, Enum.Font.Gotham)
    hintLbl.Size           = UDim2.new(1, -4, 0, 20)
    hintLbl.TextXAlignment = Enum.TextXAlignment.Center
    hintLbl.TextWrapped    = true
    hintLbl.ZIndex         = 52
    local plrSectionLbl = Lbl(spamPanel.body, "PLAYERS", 9, T.TextDim, Enum.Font.GothamBold)
    plrSectionLbl.Size           = UDim2.new(1, -4, 0, 14)
    plrSectionLbl.TextXAlignment = Enum.TextXAlignment.Left
    plrSectionLbl.ZIndex         = 52
    local spamScroll = Instance.new("ScrollingFrame")
    spamScroll.Size                   = UDim2.new(1, -4, 0, 176)
    spamScroll.BackgroundTransparency = 1
    spamScroll.BorderSizePixel        = 0
    spamScroll.ScrollBarThickness     = 3
    spamScroll.ScrollBarImageColor3   = T.White
    spamScroll.CanvasSize             = UDim2.new(0, 0, 0, 0)
    spamScroll.AutomaticCanvasSize    = Enum.AutomaticSize.Y
    spamScroll.ZIndex                 = 52
    spamScroll.Parent                 = spamPanel.body
    local _spamScrollLayout = Instance.new("UIListLayout")
    _spamScrollLayout.Padding             = UDim.new(0, 4)
    _spamScrollLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    _spamScrollLayout.Parent              = spamScroll
    Pad(spamScroll, 2, 2, 0, 0)
    local closestHolder = Instance.new("Frame")
    closestHolder.Size                   = UDim2.new(1, -4, 0, 28)
    closestHolder.BackgroundTransparency = 1
    closestHolder.ZIndex                 = 52
    closestHolder.Parent                 = spamPanel.body
    local spamClosestBtn = Instance.new("TextButton")
    spamClosestBtn.Size             = UDim2.new(1, 0, 1, 0)
    spamClosestBtn.BackgroundColor3 = T.SideActive
    spamClosestBtn.BorderSizePixel  = 0
    spamClosestBtn.Text             = "Spam Closest"
    spamClosestBtn.TextSize         = 11
    spamClosestBtn.Font             = Enum.Font.GothamBold
    spamClosestBtn.TextColor3       = T.Text
    spamClosestBtn.AutoButtonColor  = false
    spamClosestBtn.ZIndex           = 53
    spamClosestBtn.Parent           = closestHolder
    Corner(spamClosestBtn, 8)
    GradStroke(spamClosestBtn, 1.2, 0.3, 45)
    spamClosestBtn.MouseEnter:Connect(function() Tween(spamClosestBtn, F, {BackgroundColor3 = T.SideHover}) end)
    spamClosestBtn.MouseLeave:Connect(function() Tween(spamClosestBtn, F, {BackgroundColor3 = T.SideActive}) end)
    local spamClosestKBLbl = Instance.new("TextLabel")
    spamClosestKBLbl.Size                   = UDim2.new(0, 60, 0, 14)
    spamClosestKBLbl.Position               = UDim2.new(1, -64, 0.5, -7)
    spamClosestKBLbl.BackgroundTransparency = 1
    spamClosestKBLbl.Text                   = ""
    spamClosestKBLbl.TextSize               = 9
    spamClosestKBLbl.Font                   = Enum.Font.GothamBold
    spamClosestKBLbl.TextColor3             = T.TextDim
    spamClosestKBLbl.TextXAlignment         = Enum.TextXAlignment.Center
    spamClosestKBLbl.ZIndex                 = 54
    spamClosestKBLbl.Parent                 = spamClosestBtn
    local function _spamGetClosest()
        local lp    = _Players.LocalPlayer
        local myHRP = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
        if not myHRP then return nil end
        local best, bestDist = nil, math.huge
        for _, p in ipairs(_Players:GetPlayers()) do
            if p ~= lp then
                local hrp = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local d = (hrp.Position - myHRP.Position).Magnitude
                    if d < bestDist then best, bestDist = p, d end
                end
            end
        end
        return best
    end
    local _spamClosestPhase = "semi"
    local function spamClosestFire()
        local plr = _spamGetClosest()
        if not plr then return end
        local phase = _spamClosestPhase
        _spamClosestPhase = (phase == "semi") and "full" or "semi"
        task.spawn(function()
            if phase == "semi" then
                spamRun(plr, getSpamSemiCmds())
            else
                spamRun(plr, getSpamFullCmds())
            end
        end)
    end

    _G._FH_RunSemiAP = function()
        local plr = _spamGetClosest()
        if plr then task.spawn(spamRun, plr, getSpamSemiCmds()) end
    end
    spamClosestBtn.Activated:Connect(spamClosestFire)
    local _closestKBEntry = attachKeybind(spamClosestBtn, spamClosestKBLbl, "Spam Closest", spamClosestFire)
    _closestKBEntry.refresh = function()
        if KB_capture == _closestKBEntry then
            spamClosestKBLbl.Text = "(...)"
        elseif _closestKBEntry.key then
            spamClosestKBLbl.Text = "[" .. _closestKBEntry.key.Name .. "]"
        else
            spamClosestKBLbl.Text = ""
        end
    end
    _closestKBEntry.refresh()
    local function spamAddRow(plr)
        if plr == _Players.LocalPlayer then return end
        if spamScroll:FindFirstChild("spr_" .. plr.Name) then return end
        local rowH = isMobile and 44 or 40
        local row = Instance.new("Frame")
        row.Name             = "spr_" .. plr.Name
        row.Size             = UDim2.new(1, -4, 0, rowH)
        row.BackgroundColor3 = T.Card
        row.BackgroundTransparency = 0.15
        row.BorderSizePixel  = 0
        row.ZIndex           = 53
        row.Parent           = spamScroll
        Corner(row, 6)
        Stroke(row, T.Line, 1, 0.3)
        local avSz = 26
        local av = Instance.new("Frame")
        av.Size             = UDim2.new(0, avSz, 0, avSz)
        av.Position         = UDim2.new(0, 5, 0.5, -avSz/2)
        av.BackgroundColor3 = T.BgDeep
        av.BorderSizePixel  = 0
        av.ZIndex           = 54
        av.Parent           = row
        Corner(av, 5)
        task.spawn(function()
            local ok, img = pcall(function()
                return game:GetService("Players"):GetUserThumbnailAsync(plr.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
            end)
            if ok and img then
                local il = Instance.new("ImageLabel")
                il.Size = UDim2.new(1,0,1,0); il.BackgroundTransparency = 1
                il.Image = img; il.ZIndex = 55; il.Parent = av
                Corner(il, 5)
            end
        end)
        local nameW = isMobile and 11 or 12
        local nLbl = Lbl(row, plr.Name, nameW, T.Text, Enum.Font.GothamMedium)
        nLbl.Size           = UDim2.new(1, -(avSz + 132), 1, 0)
        nLbl.Position       = UDim2.new(0, avSz + 8, 0, 0)
        nLbl.TextYAlignment = Enum.TextYAlignment.Center
        nLbl.TextTruncate   = Enum.TextTruncate.AtEnd
        nLbl.ZIndex         = 54
        local btnH = isMobile and 32 or 28
        local sBtn = Instance.new("TextButton")
        sBtn.Size             = UDim2.new(0, 52, 0, btnH)
        sBtn.Position         = UDim2.new(1, -114, 0.5, -btnH/2)
        sBtn.BackgroundColor3 = Color3.fromRGB(18, 62, 26)
        sBtn.BorderSizePixel  = 0
        sBtn.Text             = "Semi"
        sBtn.TextSize         = 12
        sBtn.Font             = Enum.Font.GothamBold
        sBtn.TextColor3       = T.Green
        sBtn.AutoButtonColor  = false
        sBtn.ZIndex           = 54
        sBtn.Parent           = row
        Corner(sBtn, 5)
        Stroke(sBtn, T.Green, 1, 0.6)
        local sSDB = false
        local function sfire()
            if sSDB then return end; sSDB = true
            Tween(sBtn, F, {BackgroundColor3 = T.Green})
            task.delay(0.15, function() Tween(sBtn, F, {BackgroundColor3 = Color3.fromRGB(18,62,26)}) end)
            task.spawn(spamRun, plr, getSpamSemiCmds())
            task.delay(0.5, function() sSDB = false end)
        end
        sBtn.Activated:Connect(sfire)
        sBtn.MouseEnter:Connect(function() Tween(sBtn, F, {BackgroundColor3 = Color3.fromRGB(25,85,38)}) end)
        sBtn.MouseLeave:Connect(function() Tween(sBtn, F, {BackgroundColor3 = Color3.fromRGB(18,62,26)}) end)
        local sKBLbl = Instance.new("TextLabel")
        sKBLbl.Size                   = UDim2.new(1, 0, 0, 8)
        sKBLbl.Position               = UDim2.new(0, 0, 1, -8)
        sKBLbl.BackgroundTransparency = 1
        sKBLbl.Text                   = ""
        sKBLbl.TextSize               = 8
        sKBLbl.Font                   = Enum.Font.GothamBold
        sKBLbl.TextColor3             = T.TextDim
        sKBLbl.TextXAlignment         = Enum.TextXAlignment.Center
        sKBLbl.ZIndex                 = 55
        sKBLbl.Parent                 = sBtn
        local sKB = attachKeybind(sBtn, sKBLbl, "Semi: " .. plr.Name, sfire)
        sKB.refresh = function()
            if KB_capture == sKB then sKBLbl.Text = "..."
            elseif sKB.key then sKBLbl.Text = sKB.key.Name
            else sKBLbl.Text = "" end
        end
        sKB.refresh()
        local fBtn = Instance.new("TextButton")
        fBtn.Size             = UDim2.new(0, 52, 0, btnH)
        fBtn.Position         = UDim2.new(1, -56, 0.5, -btnH/2)
        fBtn.BackgroundColor3 = Color3.fromRGB(62, 14, 14)
        fBtn.BorderSizePixel  = 0
        fBtn.Text             = "Full"
        fBtn.TextSize         = 12
        fBtn.Font             = Enum.Font.GothamBold
        fBtn.TextColor3       = Color3.fromRGB(220, 80, 80)
        fBtn.AutoButtonColor  = false
        fBtn.ZIndex           = 54
        fBtn.Parent           = row
        Corner(fBtn, 5)
        Stroke(fBtn, Color3.fromRGB(220, 80, 80), 1, 0.6)
        local sFDB = false
        local function ffire()
            if sFDB then return end; sFDB = true
            Tween(fBtn, F, {BackgroundColor3 = Color3.fromRGB(180,40,40)})
            task.delay(0.15, function() Tween(fBtn, F, {BackgroundColor3 = Color3.fromRGB(62,14,14)}) end)
            task.spawn(spamRun, plr, getSpamFullCmds())
            task.delay(0.5, function() sFDB = false end)
        end
        fBtn.Activated:Connect(ffire)
        fBtn.MouseEnter:Connect(function() Tween(fBtn, F, {BackgroundColor3 = Color3.fromRGB(90,20,20)}) end)
        fBtn.MouseLeave:Connect(function() Tween(fBtn, F, {BackgroundColor3 = Color3.fromRGB(62,14,14)}) end)
        local fKBLbl = Instance.new("TextLabel")
        fKBLbl.Size                   = UDim2.new(1, 0, 0, 8)
        fKBLbl.Position               = UDim2.new(0, 0, 1, -8)
        fKBLbl.BackgroundTransparency = 1
        fKBLbl.Text                   = ""
        fKBLbl.TextSize               = 8
        fKBLbl.Font                   = Enum.Font.GothamBold
        fKBLbl.TextColor3             = T.TextDim
        fKBLbl.TextXAlignment         = Enum.TextXAlignment.Center
        fKBLbl.ZIndex                 = 55
        fKBLbl.Parent                 = fBtn
        local fKB = attachKeybind(fBtn, fKBLbl, "Full: " .. plr.Name, ffire)
        fKB.refresh = function()
            if KB_capture == fKB then fKBLbl.Text = "..."
            elseif fKB.key then fKBLbl.Text = fKB.key.Name
            else fKBLbl.Text = "" end
        end
        fKB.refresh()
    end
    local function spamRefresh()
        for _, c in ipairs(spamScroll:GetChildren()) do
            if c:IsA("Frame") then c:Destroy() end
        end
        spamProfileCache = {}
        spamCommandCache = {}
        for _, plr in ipairs(_Players:GetPlayers()) do spamAddRow(plr) end
    end
    _Players.PlayerAdded:Connect(function(plr)
        if spamPanel.panel.Visible then spamAddRow(plr) end
    end)
    _Players.PlayerRemoving:Connect(function(plr)
        spamProfileCache[plr.Name] = nil
        spamCommandCache = {}
        local r = spamScroll:FindFirstChild("spr_" .. plr.Name)
        if r then r:Destroy() end
    end)
    local customizeOpen = false
    local customizePanel = nil
    local function buildCustomizePanel()
        customizePanel = MiniPanel("Customize Semi / Full", 490, 60, 248)
        local cScroll = Instance.new("ScrollingFrame")
        cScroll.Size                   = UDim2.new(1, -4, 0, 300)
        cScroll.BackgroundTransparency = 1
        cScroll.BorderSizePixel        = 0
        cScroll.ScrollBarThickness     = 3
        cScroll.ScrollBarImageColor3   = T.White
        cScroll.CanvasSize             = UDim2.new(0, 0, 0, 0)
        cScroll.AutomaticCanvasSize    = Enum.AutomaticSize.Y
        cScroll.ZIndex                 = 52
        cScroll.Parent                 = customizePanel.body
        local cLayout = Instance.new("UIListLayout")
        cLayout.Padding             = UDim.new(0, 3)
        cLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        cLayout.Parent              = cScroll
        Pad(cScroll, 4, 4, 2, 2)
        local function makeSectionLbl(txt, col)
            local lbl = Lbl(cScroll, txt, 9, col, Enum.Font.GothamBold)
            lbl.Size           = UDim2.new(1, -4, 0, 16)
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.ZIndex         = 52
            return lbl
        end
        local function makeCmdToggle(cmd, getList, saveAll)
            local isOn = table.find(getList(), cmd) ~= nil
            local row  = Instance.new("Frame")
            row.Size             = UDim2.new(1, -4, 0, 24)
            row.BackgroundColor3 = T.Card
            row.BorderSizePixel  = 0
            row.ZIndex           = 53
            row.Parent           = cScroll
            Corner(row, 5)
            local rLbl = Lbl(row, cmd, 10, T.Text, Enum.Font.GothamMedium)
            rLbl.Size           = UDim2.new(1, -50, 1, 0)
            rLbl.Position       = UDim2.new(0, 8, 0, 0)
            rLbl.TextYAlignment = Enum.TextYAlignment.Center
            rLbl.ZIndex         = 54
            local rTog = Instance.new("TextButton")
            rTog.Size             = UDim2.new(0, 36, 0, 16)
            rTog.Position         = UDim2.new(1, -42, 0.5, -8)
            rTog.BackgroundColor3 = isOn and T.SideActive or T.Soft
            rTog.BorderSizePixel  = 0
            rTog.Text             = isOn and "ON" or "OFF"
            rTog.TextSize         = 9
            rTog.Font             = Enum.Font.GothamBold
            rTog.TextColor3       = isOn and T.Text or T.TextMute
            rTog.AutoButtonColor  = false
            rTog.ZIndex           = 54
            rTog.Parent           = row
            Corner(rTog, 4)
            rTog.Activated:Connect(function()
                local list = getList()
                local idx  = table.find(list, cmd)
                if idx then
                    table.remove(list, idx)
                    rTog.Text             = "OFF"
                    rTog.TextColor3       = T.TextMute
                    rTog.BackgroundColor3 = T.Soft
                else
                    table.insert(list, cmd)
                    rTog.Text             = "ON"
                    rTog.TextColor3       = T.Text
                    rTog.BackgroundColor3 = T.SideActive
                end
                saveAll()
            end)
        end
        local _semiCmds = getSpamSemiCmds()
        local _fullCmds = getSpamFullCmds()
        local function _save() saveSpamCmds(_semiCmds, _fullCmds) end
        makeSectionLbl("SEMI COMMANDS", T.Green)
        for _, cmd in ipairs(ALL_SPAM_CMDS) do
            makeCmdToggle(cmd, function() return _semiCmds end, _save)
        end
        makeSectionLbl("FULL COMMANDS", Color3.fromRGB(220, 80, 80))
        for _, cmd in ipairs(ALL_SPAM_CMDS) do
            makeCmdToggle(cmd, function() return _fullCmds end, _save)
        end
    end
    gearBtn.Activated:Connect(function()
        if not customizePanel then buildCustomizePanel() end
        customizeOpen = not customizeOpen
        customizePanel.panel.Visible = customizeOpen
        if customizeOpen then
            Tween(gearBtn, F, {BackgroundColor3 = T.SideActive, TextColor3 = T.Text})
        else
            Tween(gearBtn, F, {BackgroundColor3 = T.Soft, TextColor3 = T.TextDim})
        end
    end)
    _G.GammaSpamPanel = {
        panel   = spamPanel.panel,
        refresh = spamRefresh,
    }
    spamRefresh()
end)()

local BaseXRay = (function()
    local TRANSPARENCY  = 0.35
    local CHUNK_SIZE    = 75

    local xrayEnabled = false
    local modified    = {}
    local modelCache  = {}
    local descConn    = nil
    local _reapplyActive = false

    local function isPetOrNPC(part, plotsFolder)
        local obj = part.Parent
        while obj and obj ~= plotsFolder and obj ~= workspace do
            if obj:IsA("Model") then
                local cached = modelCache[obj]
                if cached == nil then
                    cached = obj:FindFirstChildWhichIsA("Humanoid") ~= nil
                    modelCache[obj] = cached
                end
                if cached then return true end
                break
            end
            obj = obj.Parent
        end
        return false
    end

    local _xr_orig
    local _xr_hooked = false
    local function _xr_installHook()
        if _xr_hooked then return end
        _xr_hooked = true
        pcall(function()
            if type(hookmetamethod) ~= "function" then return end
            local nc = (type(newcclosure) == "function") and newcclosure or function(f) return f end
            local mod = modified
            _xr_orig = hookmetamethod(game, "__index", nc(function(self, key)
                if key == "LocalTransparencyModifier" and mod[self] then
                    return 0
                end
                return _xr_orig(self, key)
            end))
        end)
    end

    local function startReapplyLoop()
        if _reapplyActive then return end
        _reapplyActive = true
        task.spawn(function()
            while _reapplyActive and xrayEnabled do
                task.wait(5)
                if not _reapplyActive or not xrayEnabled then break end
                local entries = {}
                for part, origLTM in pairs(modified) do
                    entries[#entries + 1] = part
                end
                local total = #entries
                if total == 0 then continue end
                local i = 1
                while i <= total and _reapplyActive and xrayEnabled do
                    local limit = math.min(i + 50 - 1, total)
                    for j = i, limit do
                        local p = entries[j]
                        if p.Parent and p.LocalTransparencyModifier ~= TRANSPARENCY then
                            p.LocalTransparencyModifier = TRANSPARENCY
                        end
                    end
                    i = limit + 1
                    if i <= total then RunService.Heartbeat:Wait() end
                end
            end
            _reapplyActive = false
        end)
    end

    local function stopReapplyLoop()
        _reapplyActive = false
    end

    local function applyPart(part, plotsFolder)
        if modified[part] then return end
        if not part:IsA("BasePart") then return end
        if isPetOrNPC(part, plotsFolder) then return end
        modified[part] = part.LocalTransparencyModifier
        part.LocalTransparencyModifier = TRANSPARENCY
    end

    local function chunkedEnable(plotsFolder)

        local baseParts = {}
        for _, obj in ipairs(plotsFolder:GetDescendants()) do
            if obj:IsA("BasePart") then
                baseParts[#baseParts + 1] = obj
            end
        end
        local total = #baseParts
        if total == 0 then return end
        coroutine.wrap(function()
            local i = 1
            while i <= total do
                local limit = math.min(i + CHUNK_SIZE - 1, total)
                for j = i, limit do
                    applyPart(baseParts[j], plotsFolder)
                end
                i = limit + 1
                if i <= total then RunService.Heartbeat:Wait() end
            end
        end)()
_G._FH_REG_BaseXRay = BaseXRay
    end

    local function enableXRay()
        local plotsFolder = workspace:FindFirstChild("Plots")
        if not plotsFolder then return end
        _xr_installHook()
        chunkedEnable(plotsFolder)
        if descConn then descConn:Disconnect() end
        descConn = plotsFolder.DescendantAdded:Connect(function(obj)
            if xrayEnabled then applyPart(obj, plotsFolder) end
        end)
    end

    local function disableXRay()
        if descConn then descConn:Disconnect(); descConn = nil end
        local snapshot = modified
        modified   = {}
        modelCache = {}
        local parts = {}
        for part, origLTM in pairs(snapshot) do
            parts[#parts + 1] = {part, origLTM}
        end
        local total = #parts
        if total == 0 then return end
        coroutine.wrap(function()
            local i = 1
            while i <= total do
                local limit = math.min(i + CHUNK_SIZE - 1, total)
                for j = i, limit do
                    local entry = parts[j]
                    pcall(function()
                        if entry[1].Parent then
                            entry[1].LocalTransparencyModifier = entry[2]
                        end
                    end)
                end
                i = limit + 1
                if i <= total then RunService.Heartbeat:Wait() end
            end
        end)()
    end

    local _camSaved      = false
    local _origOcclusion = nil
    local _origMaxZoom   = nil
    local _origMinZoom   = nil
    local _camPollConn   = nil
    local function _applyCamSettings(lp)
        pcall(function()
            lp.DevCameraOcclusionMode = Enum.DevCameraOcclusionMode.Invisicam
            lp.CameraMaxZoomDistance  = 400
            lp.CameraMinZoomDistance  = 0
        end)
    end
    local function enableCamThroughWalls()
        local lp = Players.LocalPlayer
        if not lp then return end
        pcall(function()
            if not _camSaved then
                _origOcclusion = lp.DevCameraOcclusionMode
                _origMaxZoom   = lp.CameraMaxZoomDistance
                _origMinZoom   = lp.CameraMinZoomDistance
                _camSaved      = true
            end
            _applyCamSettings(lp)
        end)

        if not _camPollConn then
            local _pollActive = true
            _camPollConn = { Disconnect = function() _pollActive = false end }
            task.spawn(function()
                while _pollActive do
                    task.wait(0.5)
                    if not _pollActive then break end
                    if not xrayEnabled then break end
                    local lp2 = Players.LocalPlayer
                    if not lp2 then break end
                    if lp2.DevCameraOcclusionMode ~= Enum.DevCameraOcclusionMode.Invisicam
                    or lp2.CameraMaxZoomDistance < 400
                    or lp2.CameraMinZoomDistance > 0 then
                        pcall(_applyCamSettings, lp2)
                    end
                end
                _camPollConn = nil
            end)
        end
    end
    local function disableCamThroughWalls()
        local lp = Players.LocalPlayer
        if _camPollConn then _camPollConn:Disconnect(); _camPollConn = nil end
        if not lp or not _camSaved then return end
        pcall(function()
            lp.DevCameraOcclusionMode = _origOcclusion
            lp.CameraMaxZoomDistance  = _origMaxZoom
            lp.CameraMinZoomDistance  = _origMinZoom
        end)
        _camSaved = false
    end

    local function _xraySet(on)
        _G._FH_XRAY_ENABLED = on
        xrayEnabled = on
        if on then
            enableXRay()
            enableCamThroughWalls()
        else
            disableXRay()
            disableCamThroughWalls()
        end
    end
    _G._FH_BASEXRAY_SET = _xraySet
    local function _setTransparency(v)
        v = math.clamp(tonumber(v) or 0.35, 0, 1)
        TRANSPARENCY = v
        if xrayEnabled then
            for part in pairs(modified) do
                if part.Parent then
                    pcall(function() part.LocalTransparencyModifier = v end)
                end
            end
        end
    end
    return { set = _xraySet, setTransparency = _setTransparency }
end)()

local Main   = Nav("Main",   "Main")

local MineESP = (function()
    local M = {}
    local SUBSPACE_FOLDER = "ToolsAdds"
    local subspaceData    = {}
    local subspaceEnabled = false
    local subspaceConns   = {}

    local function _smOwnerLabel(mineName)
        local userName = mineName:match("SubspaceTripmine(.+)")
        if not userName then return "Unknown" end
        local foundPlayer = Players:FindFirstChild(userName)
        local displayName = foundPlayer and foundPlayer.DisplayName or userName
        return string.format("%s (@%s)", displayName, userName)
    end

    local _SM_COLOR = Color3.fromRGB(255, 80, 80)
    local function _smCurrentColor()
        return _SM_COLOR
    end

    local function _smCreateESP(mine)
        local ownerLabel = _smOwnerLabel(mine.Name)
        local col = _smCurrentColor()

        local selectionBox = Instance.new("SelectionBox")
        selectionBox.Name                = "ESP_Hitbox"
        selectionBox.Adornee             = mine
        selectionBox.Color3              = col
        selectionBox.LineThickness       = 0.06
        selectionBox.SurfaceColor3       = Color3.fromRGB(0, 0, 0)
        selectionBox.SurfaceTransparency = 1
        selectionBox.Parent              = mine

        local billboardGui = Instance.new("BillboardGui")
        billboardGui.Name        = "ESP_Label"
        billboardGui.Adornee     = mine
        billboardGui.Size        = UDim2.new(0, 260, 0, 50)
        billboardGui.StudsOffset = Vector3.new(0, 2.5, 0)
        billboardGui.AlwaysOnTop = true
        billboardGui.Parent      = mine

        local textLabel = Instance.new("TextLabel")
        textLabel.Size                   = UDim2.new(1, 0, 1, 0)
        textLabel.BackgroundTransparency = 1
        textLabel.Text                   = ownerLabel .. "'s Mine"
        textLabel.TextColor3             = col
        textLabel.TextStrokeColor3       = Color3.fromRGB(0, 0, 0)
        textLabel.TextStrokeTransparency = 0
        textLabel.Font                   = Enum.Font.GothamBold
        textLabel.TextSize               = 15
        textLabel.Parent                 = billboardGui

        return { selectionBox = selectionBox, billboardGui = billboardGui, mine = mine, textLabel = textLabel }
    end

    local function _smClearAll()
        for _, data in pairs(subspaceData) do
            if data.selectionBox and data.selectionBox.Parent then data.selectionBox:Destroy() end
            if data.billboardGui and data.billboardGui.Parent then data.billboardGui:Destroy() end
        end
        table.clear(subspaceData)
    end

    local function _smIsMine(obj)
        return obj:IsA("BasePart") and obj.Name:match("^SubspaceTripmine") ~= nil
    end

    local function _smTryAdd(obj)
        if not subspaceEnabled then return end
        if not _smIsMine(obj) then return end
        if subspaceData[obj] then return end
        subspaceData[obj] = _smCreateESP(obj)
    end

    local function _smRemove(obj)
        local data = subspaceData[obj]
        if not data then return end
        if data.selectionBox and data.selectionBox.Parent then data.selectionBox:Destroy() end
        if data.billboardGui and data.billboardGui.Parent then data.billboardGui:Destroy() end
        subspaceData[obj] = nil
    end

    local function _smDisconnect()
        for _, c in ipairs(subspaceConns) do pcall(function() c:Disconnect() end) end
        subspaceConns = {}
    end

    local function _smBindFolder(folder)
        table.insert(subspaceConns, folder.ChildAdded:Connect(function(obj)
            if subspaceEnabled then _smTryAdd(obj) end
        end))
        table.insert(subspaceConns, folder.ChildRemoved:Connect(function(obj)
            _smRemove(obj)
        end))
        for _, obj in ipairs(folder:GetChildren()) do _smTryAdd(obj) end
    end

    local function _smEnable()
        if subspaceEnabled then return end
        subspaceEnabled = true
        local folder = workspace:FindFirstChild(SUBSPACE_FOLDER)
        if folder then _smBindFolder(folder) end
        table.insert(subspaceConns, workspace.ChildAdded:Connect(function(child)
            if subspaceEnabled and child.Name == SUBSPACE_FOLDER then
                _smBindFolder(child)
            end
        end))
    end

    local function _smDisable()
        if not subspaceEnabled then return end
        subspaceEnabled = false
        _smDisconnect()
        _smClearAll()
    end

    function M.set(on)
        if on then _smEnable() else _smDisable() end
    end

    return M
end)()
_G._FH_REG_MineESP = MineESP
local Visual = Nav("Visual", "Visual")
local Player = Nav("Player", "Player")
local Utils  = Nav("Utils",  "Utils")
Section(Main.scroll, "AUTO GRABS")
local _panelsReady = false
local grabNearestToggle, grabBestToggle, grabPriorityToggle
grabNearestToggle = Toggle(Main.scroll, "Auto Grab Nearest", "Grab the nearest brainrot in range", function(on)
    AutoGrab.setNearest(on)
    if on then
        if grabBestToggle then grabBestToggle.set(false) end
        if grabPriorityToggle then grabPriorityToggle.set(false) end
    end
end)
grabBestToggle = Toggle(Main.scroll, "Auto Steal Best", "Steal the highest gen brainrot in other plots", function(on)
    AutoGrab.setBest(on)
    if on then
        if grabNearestToggle then grabNearestToggle.set(false) end
        if grabPriorityToggle then grabPriorityToggle.set(false) end
    end
end)
grabPriorityToggle = Toggle(Main.scroll, "Auto Steal Priority", "Only steal the animals you pick", function(on)
    AutoGrab.setPriorityGrab(on)
    if _panelsReady then priorityPanel.panel.Visible = on end
    if on then
        if grabNearestToggle then grabNearestToggle.set(false) end
        if grabBestToggle then grabBestToggle.set(false) end
    end
end)
local halfwayPanel = MiniPanel("Halfway Steal", 240, 200, 196)
if _GEN > 1 then
    halfwayPanel.panel.Visible = true
    if not Config.get("panelpos:Halfway Steal", nil) then
        halfwayPanel.panel.Position = UDim2.new(0.5, -98, 0.5, -100)
    end
end
Button(halfwayPanel.body, "Activate",  "", function() HalfwaySteal.activate() end)
Button(halfwayPanel.body, "Steal Now", "", function() HalfwaySteal.execute() end)
Toggle(halfwayPanel.body, "Use Potion", "", function(on) HalfwaySteal.setPotion(on) end)
do
    local card = Card(halfwayPanel.body, 32)
    local lbl  = Lbl(card, "Method: Walk", 11, T.Text, Enum.Font.GothamBold, Enum.TextXAlignment.Center)
    lbl.Size           = UDim2.new(1, 0, 1, 0)
    lbl.TextYAlignment = Enum.TextYAlignment.Center
    lbl.ZIndex         = 5
    local btn = Instance.new("TextButton")
    btn.Size                   = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text                   = ""
    btn.AutoButtonColor        = false
    btn.ZIndex                 = 8
    btn.Parent                 = card
    local prime = Config.get("toggle:HalfwayMethod", false) == true
    local function apply()
        HalfwaySteal.setMethod(prime and "Prime" or "Walk")
        lbl.Text = "Method: " .. (prime and "Prime" or "Walk")
    end
    apply()
    btn.Activated:Connect(function()
        prime = not prime
        apply()
        Config.set("toggle:HalfwayMethod", prime)
    end)
end

local _walkEsp
local function _destroyWalkEsp() if _walkEsp then pcall(function() _walkEsp:Destroy() end); _walkEsp = nil end end
local function _updateWalkEsp()
    if HalfwaySteal.autoWalk and HalfwaySteal.walkPoint then
        if not (_walkEsp and _walkEsp.Parent) then
            _destroyWalkEsp()
            _walkEsp = Instance.new("Part")
            _walkEsp.Name         = "FH_WalkPointESP"
            _walkEsp.Shape        = Enum.PartType.Ball
            _walkEsp.Size         = Vector3.new(2, 2, 2)
            _walkEsp.Anchored     = true
            _walkEsp.CanCollide   = false
            _walkEsp.CanQuery     = false
            _walkEsp.CanTouch     = false
            _walkEsp.Material     = Enum.Material.Neon
            _walkEsp.Color        = Theme.c1
            _walkEsp.Transparency = 0.45
            local hl = Instance.new("Highlight")
            hl.FillColor           = Theme.c1
            hl.FillTransparency    = 0.5
            hl.OutlineColor        = Color3.new(1, 1, 1)
            hl.OutlineTransparency = 0
            hl.DepthMode           = Enum.HighlightDepthMode.AlwaysOnTop
            hl.Adornee             = _walkEsp
            hl.Parent              = _walkEsp
            local bb = Instance.new("BillboardGui")
            bb.Size        = UDim2.new(0, 100, 0, 22)
            bb.StudsOffset = Vector3.new(0, 2.5, 0)
            bb.AlwaysOnTop = true
            bb.Parent      = _walkEsp
            local elbl = Instance.new("TextLabel")
            elbl.Size                   = UDim2.new(1, 0, 1, 0)
            elbl.BackgroundTransparency = 1
            elbl.Text                   = "Walk Point"
            elbl.TextColor3             = Color3.new(1, 1, 1)
            elbl.Font                   = Enum.Font.GothamBold
            elbl.TextSize               = 13
            elbl.TextStrokeTransparency = 0.3
            elbl.Parent                 = bb
            _walkEsp.Parent = workspace
        end
        _walkEsp.Position = HalfwaySteal.walkPoint
    else
        _destroyWalkEsp()
    end
end
Toggle(halfwayPanel.body, "Auto AP On Semi", "", function(on) HalfwaySteal.autoAP = on end)
local _swCard

Section(Main.scroll, "EXTRAS")
Toggle(Main.scroll, "Halfway Steal", "Semi/Instant Steal V2 panel", function(on) halfwayPanel.panel.Visible = on end)

do
    -- Anti Ragdoll (ported from faded). Reverses ragdoll/knockback by stripping
    -- ragdoll constraints, re-enabling motors, clearing the server ragdoll timer
    -- and standing you back up. Keeps the backpack forced open while active.
    if _G.__AntiRagdollToggleCleanup then pcall(_G.__AntiRagdollToggleCleanup) end

    local LocalPlayer = Players.LocalPlayer

    local AntiRagdoll = { connections = {}, running = false }

    AntiRagdoll.forceBackpack = function()
        if not AntiRagdoll.running then return end
        local gui = LocalPlayer:FindFirstChild("PlayerGui")
        if not gui then return end
        local backpackGui = gui:FindFirstChild("BackpackGui")
        if not backpackGui then return end
        local backpack = backpackGui:FindFirstChild("Backpack")
        if not backpack then return end
        backpack.Visible = true
        if not backpack:FindFirstChild("ForceConnection") then
            local tag = Instance.new("BoolValue")
            tag.Name   = "ForceConnection"
            tag.Parent = backpack
            backpack:GetPropertyChangedSignal("Visible"):Connect(function()
                if not AntiRagdoll.running then return end
                if not backpack.Visible then backpack.Visible = true end
            end)
        end
    end
    AntiRagdoll.removeRagdollConstraints = function(char)
        for _, d in ipairs(char:GetDescendants()) do
            if d:IsA("BallSocketConstraint") or d:IsA("HingeConstraint")
                or d:IsA("NoCollisionConstraint")
                or (d:IsA("Attachment") and d.Name:find("RagdollAttachment")) then
                d:Destroy()
            end
        end
    end
    AntiRagdoll.resetCharacter = function(char)
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        local rootPart = char:FindFirstChild("HumanoidRootPart")
        if rootPart then
            rootPart.Anchored = false
            rootPart.Velocity  = Vector3.zero
        end
        if humanoid then
            for _, obj in ipairs(char:GetDescendants()) do
                if obj:IsA("Motor6D") and obj.Enabled == false then
                    obj.Enabled = true
                end
            end
            humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll,     false)
            humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
            humanoid.PlatformStand = false
            humanoid.Sit           = false
            if humanoid.Health > 0 then
                humanoid:ChangeState(Enum.HumanoidStateType.Running)
            end
            workspace.CurrentCamera.CameraSubject = humanoid
        end
    end
    AntiRagdoll.onCharacterAdded_AR = function(char)
        char:WaitForChild("HumanoidRootPart")
        local humanoid = char:WaitForChild("Humanoid")

        AntiRagdoll.connections.charDescAdded = char.DescendantAdded:Connect(function(obj)
            if not AntiRagdoll.running then return end
            if obj:IsA("BallSocketConstraint") or obj:IsA("HingeConstraint")
                or obj:IsA("NoCollisionConstraint")
                or (obj:IsA("Attachment") and obj.Name:find("RagdollAttachment")) then
                task.defer(function()
                    if not AntiRagdoll.running then return end
                    if obj.Parent then obj:Destroy() end
                end)
            end
        end)
        AntiRagdoll.connections.platformStand = humanoid:GetPropertyChangedSignal("PlatformStand"):Connect(function()
            if not AntiRagdoll.running then return end
            if humanoid.PlatformStand then
                task.defer(function()
                    if not AntiRagdoll.running then return end
                    AntiRagdoll.resetCharacter(char)
                    AntiRagdoll.removeRagdollConstraints(char)
                end)
            end
        end)
        AntiRagdoll.removeRagdollConstraints(char)
        AntiRagdoll.resetCharacter(char)
    end
    AntiRagdoll.enable = function()

        if AntiRagdoll.running then return end
        AntiRagdoll.running = true
        local _arTick = 0
        AntiRagdoll.connections.heartbeat = RunService.Heartbeat:Connect(function(dt)
            _arTick = _arTick + dt
            if _arTick < 0.1 then return end
            _arTick = 0
            local char = LocalPlayer.Character
            if not char then return end
            local hum  = char:FindFirstChildOfClass("Humanoid")
            local root = char:FindFirstChild("HumanoidRootPart")
            if not (hum and root) then return end
            local s = hum:GetState()
            local ragdolled = (s == Enum.HumanoidStateType.Physics
                or s == Enum.HumanoidStateType.Ragdoll
                or s == Enum.HumanoidStateType.FallingDown)
            local endTime = LocalPlayer:GetAttribute("RagdollEndTime")
            if endTime and (endTime - workspace:GetServerTimeNow()) > 0 then
                ragdolled = true
            end
            if ragdolled then
                pcall(function() LocalPlayer:SetAttribute("RagdollEndTime", workspace:GetServerTimeNow()) end)
                AntiRagdoll.removeRagdollConstraints(char)
                for _, obj in ipairs(char:GetDescendants()) do
                    if obj:IsA("Motor6D") and obj.Enabled == false then
                        obj.Enabled = true
                    end
                end
                if hum.Health > 0 then hum:ChangeState(Enum.HumanoidStateType.Running) end
                workspace.CurrentCamera.CameraSubject = hum
                root.Anchored = false
                root.Velocity  = Vector3.zero
            end
        end)
        AntiRagdoll.connections.charAdded = LocalPlayer.CharacterAdded:Connect(function(char)
            task.wait(1)
            AntiRagdoll.forceBackpack()
            AntiRagdoll.onCharacterAdded_AR(char)
        end)
        if LocalPlayer.Character then AntiRagdoll.onCharacterAdded_AR(LocalPlayer.Character) end
        task.spawn(function()
            while AntiRagdoll.running do
                task.wait(0.5)
                AntiRagdoll.forceBackpack()
            end
        end)
    end
    AntiRagdoll.disable = function()
        AntiRagdoll.running = false
        for _, conn in pairs(AntiRagdoll.connections) do
            if conn then pcall(function() conn:Disconnect() end) end
        end
        AntiRagdoll.connections = {}

        pcall(function()
            local char = LocalPlayer.Character
            local hum  = char and char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll,     true)
                hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, true)
            end
        end)
    end

    _G.__AntiRagdollToggleCleanup = function() AntiRagdoll.disable() end

    Toggle(Player.scroll, "Anti Ragdoll", "No hit effects.", function(state)
        if state then AntiRagdoll.enable() else AntiRagdoll.disable() end
    end)
end

Toggle(Main.scroll, "Allow Base Panel", "Open the Allow Base mini-panel.", function(on) AllowBasePanel.setVisible(on) end)
Section(Visual.scroll, "ESP")
Toggle(Visual.scroll, "Brainrot ESP", "Label the best brainrot", function(on) BrainrotESP.set(on) end)
if isMobile then

    Toggle(Visual.scroll, "Timer ESP",    "Show purchase timers",     function(on) TimerESP.set(on) end)
    Toggle(Visual.scroll, "FriendPanel ESP", "ALLOWED / UNALLOWED",  function(on) FriendPanelESP.set(on) end)
    Toggle(Visual.scroll, "Next Base ESP", "Highlight next empty base", function(on) NextBaseESP.set(on) end)
else

    local subTimer, subFriendPanel, subBaseXRay, subNextBase
    local baseEsp
    baseEsp = Toggle(Visual.scroll, "Base ESP", "Right-click to open sub-options", function(on) end)
    pcall(function()
        for _, ch in ipairs(baseEsp.card:GetChildren()) do
            if ch:IsA("Frame") then ch.Visible = false end
        end
        baseEsp.btn.Active = false
        baseEsp.btn.AutoButtonColor = false
    end)
    subTimer       = Toggle(Visual.scroll, "  • Timer ESP",       "Show purchase timers",                     function(on) TimerESP.set(on) end)
    subFriendPanel = Toggle(Visual.scroll, "  • FriendPanel ESP", "ALLOWED / UNALLOWED",                      function(on) FriendPanelESP.set(on) end)
    subBaseXRay    = Toggle(Visual.scroll, "  • Base X-Ray",      "See through plots (hides pets/NPCs)",      function(on) BaseXRay.set(on) end)
    local baseXRayAlpha = Slider(Visual.scroll, "  • Base X-Ray Transparency", 0, 100, math.floor((Config.get("basexray_alpha", 0.35)) * 100 + 0.5), function(v)
        local f = v / 100
        Config.set("basexray_alpha", f)
        BaseXRay.setTransparency(f)
    end, 1)
    BaseXRay.setTransparency(Config.get("basexray_alpha", 0.35))
    local function setSubVisible(v)
        subTimer.card.Visible       = v
        subFriendPanel.card.Visible = v
        subBaseXRay.card.Visible    = v
        baseXRayAlpha.card.Visible  = v
    end
    setSubVisible(false)
    local expanded = false
    baseEsp.btn.MouseButton2Click:Connect(function()
        expanded = not expanded
        setSubVisible(expanded)
    end)
end
Toggle(Visual.scroll, "Player ESP",  "Highlight + name tag", function(on) PlayerESP.set(on) end)
Toggle(Visual.scroll, "Clone ESP",   "Highlight clones after switch", function(on) CloneESP.set(on) end)
Toggle(Visual.scroll, "Mine ESP",    "Box + owner name on Subspace Tripmines", function(on) MineESP.set(on) end)
Toggle(Visual.scroll, "Friend ESP", "Highlight friends in green", function(on) FriendESP.set(on) end)
Input(Visual.scroll, "Friend Names", "name1, name2, ...", Config.get("friendesp_names", ""), function(v)
    Config.set("friendesp_names", v)
    FriendESP.setNames(v)
end)
if isMobile then
    Section(Visual.scroll, "X-Ray")
    Toggle(Visual.scroll, "Base X-Ray", "See through plots (hides pets/NPCs)", function(on) BaseXRay.set(on) end)
end
Section(Visual.scroll, "Camera")
Slider(Visual.scroll, "FOV", 60, 120, 70, function(v) FovController.set(v) end)

Section(Visual.scroll, "Performance")
do
local FPSBoost = (function()

    local M = { enabled = false }
    local Lighting = game:GetService("Lighting")
    local _savedLight      = nil
    local _savedFpsCap     = nil
    local _disabledEffects = {}
    local _removedEffects  = {}
    local _savedTerrain    = nil
    local _savedRender     = nil

    local function applyTerrain()
        local terrain = workspace:FindFirstChildOfClass("Terrain")
        if not terrain then return end
        _savedTerrain = {
            terrain          = terrain,
            Decoration       = terrain.Decoration,
            WaterWaveSize    = terrain.WaterWaveSize,
            WaterWaveSpeed   = terrain.WaterWaveSpeed,
            WaterReflectance = terrain.WaterReflectance,
            WaterTransparency= terrain.WaterTransparency,
        }
        pcall(function() terrain.Decoration        = false end)
        pcall(function() terrain.WaterWaveSize      = 0 end)
        pcall(function() terrain.WaterWaveSpeed     = 0 end)
        pcall(function() terrain.WaterReflectance   = 0 end)
        pcall(function() terrain.WaterTransparency  = 1 end)
    end
    local function restoreTerrain()
        if not _savedTerrain then return end
        local t = _savedTerrain.terrain
        pcall(function() t.Decoration        = _savedTerrain.Decoration end)
        pcall(function() t.WaterWaveSize      = _savedTerrain.WaterWaveSize end)
        pcall(function() t.WaterWaveSpeed     = _savedTerrain.WaterWaveSpeed end)
        pcall(function() t.WaterReflectance   = _savedTerrain.WaterReflectance end)
        pcall(function() t.WaterTransparency  = _savedTerrain.WaterTransparency end)
        _savedTerrain = nil
    end

    local function applyRender()
        pcall(function()
            local r = settings().Rendering
            _savedRender = { MeshPartDetailLevel = r.MeshPartDetailLevel }
            r.MeshPartDetailLevel = Enum.MeshPartDetailLevel.Level04
        end)
    end
    local function restoreRender()
        if not _savedRender then return end
        pcall(function() settings().Rendering.MeshPartDetailLevel = _savedRender.MeshPartDetailLevel end)
        _savedRender = nil
    end

    local function applyEngineTweaks()
        pcall(function() settings().Rendering.QualityLevel = Enum.QualityLevel.Level01 end)
        pcall(function()
            local UGS = UserSettings():GetService("UserGameSettings")
            UGS.SavedQualityLevel = Enum.SavedQualitySetting.QualityLevel1
        end)

        if typeof(setfpscap) == "function" then
            if typeof(getfpscap) == "function" then
                local ok, cap = pcall(getfpscap)
                if ok and tonumber(cap) then _savedFpsCap = cap end
            end
            pcall(setfpscap, 0)
        end
    end
    local function restoreEngineTweaks()
        pcall(function() settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic end)
        pcall(function()
            local UGS = UserSettings():GetService("UserGameSettings")
            UGS.SavedQualityLevel = Enum.SavedQualitySetting.QualityLevelAutomatic
        end)
        if typeof(setfpscap) == "function" and _savedFpsCap then
            pcall(setfpscap, _savedFpsCap)
            _savedFpsCap = nil
        end
    end

    local function applyLighting()
        _savedLight = {
            GlobalShadows            = Lighting.GlobalShadows,
            EnvironmentDiffuseScale  = Lighting.EnvironmentDiffuseScale,
            EnvironmentSpecularScale = Lighting.EnvironmentSpecularScale,
            FogEnd                   = Lighting.FogEnd,
        }
        pcall(function() Lighting.GlobalShadows            = false end)
        pcall(function() Lighting.EnvironmentDiffuseScale  = 0 end)
        pcall(function() Lighting.EnvironmentSpecularScale = 0 end)
        pcall(function() Lighting.FogEnd                   = 9e9 end)

        _disabledEffects = {}
        _removedEffects  = {}
        for _, e in ipairs(Lighting:GetDescendants()) do
            if e:IsA("Atmosphere") or e:IsA("Clouds") then
                local parent = e.Parent
                pcall(function() e.Parent = nil end)
                _removedEffects[#_removedEffects + 1] = { inst = e, parent = parent }
            elseif e:IsA("BloomEffect") or e:IsA("BlurEffect") or e:IsA("DepthOfFieldEffect")
            or e:IsA("SunRaysEffect") or e:IsA("ColorCorrectionEffect") then
                local ok, en = pcall(function() return e.Enabled end)
                if ok and en ~= false then
                    pcall(function() e.Enabled = false end)
                    _disabledEffects[#_disabledEffects + 1] = e
                end
            end
        end
    end
    local function restoreLighting()
        if _savedLight then
            pcall(function() Lighting.GlobalShadows            = _savedLight.GlobalShadows end)
            pcall(function() Lighting.EnvironmentDiffuseScale  = _savedLight.EnvironmentDiffuseScale end)
            pcall(function() Lighting.EnvironmentSpecularScale = _savedLight.EnvironmentSpecularScale end)
            pcall(function() Lighting.FogEnd                   = _savedLight.FogEnd end)
            _savedLight = nil
        end
        for _, e in ipairs(_disabledEffects) do
            if e.Parent then pcall(function() e.Enabled = true end) end
        end
        _disabledEffects = {}
        for _, r in ipairs(_removedEffects) do
            if r.inst and r.parent then pcall(function() r.inst.Parent = r.parent end) end
        end
        _removedEffects = {}
    end

    function M.set(on)
        M.enabled = on and true or false
        if M.enabled then
            applyEngineTweaks()
            applyLighting()
            applyTerrain()
            applyRender()
        else
            restoreLighting()
            restoreEngineTweaks()
            restoreTerrain()
            restoreRender()
        end
    end
    return M
end)()
Toggle(Visual.scroll, "Optimization and FPS Boost", "Reversible FPS boost: lowest render quality, uncapped frames, no shadows/fog/post-FX. Safe (no part edits) and fully restores when toggled off.", function(on) FPSBoost.set(on) end)
end
Section(Visual.scroll, "Misc")
Toggle(Visual.scroll, "Anti Bee", "", function(on) AntiBee.set(on) end)
local HideTradePlaza = (function()
    local M = { enabled = false }
    local REGION_TEXT  = "Trading Plaza Isnt Available In Your Current Region, Please try again later"
    local REGION_COLOR = Color3.fromRGB(255, 0, 0)
    local origText, origColor = {}, {}
    local origGradEnabled, origPromptEnabled = {}, {}
    local conns = {}
    local _selfEdit = setmetatable({}, { __mode = "k" })
    local function disconnectAll()
        for _, c in ipairs(conns) do pcall(function() c:Disconnect() end) end
        conns = {}
    end
    -- Apply the region-lock look to a single object and keep it stuck (re-assert
    -- if the game changes it back) so the portal doesn't flicker/glitch.
    local function applyObj(obj)
        if not M.enabled then return end
        if obj:IsA("TextLabel") then
            if origText[obj] == nil then
                origText[obj]  = obj.Text
                origColor[obj] = obj.TextColor3
            end
            _selfEdit[obj] = true
            pcall(function()
                obj.Text       = REGION_TEXT
                obj.TextColor3 = REGION_COLOR
            end)
            _selfEdit[obj] = nil
            conns[#conns+1] = obj:GetPropertyChangedSignal("Text"):Connect(function()
                if M.enabled and not _selfEdit[obj] and obj.Text ~= REGION_TEXT then
                    _selfEdit[obj] = true
                    pcall(function() obj.Text = REGION_TEXT; obj.TextColor3 = REGION_COLOR end)
                    _selfEdit[obj] = nil
                end
            end)
        elseif obj:IsA("UIGradient") then
            if origGradEnabled[obj] == nil then origGradEnabled[obj] = obj.Enabled end
            pcall(function() obj.Enabled = false end)
            conns[#conns+1] = obj:GetPropertyChangedSignal("Enabled"):Connect(function()
                if M.enabled and obj.Enabled then obj.Enabled = false end
            end)
        elseif obj:IsA("ProximityPrompt") then
            if origPromptEnabled[obj] == nil then origPromptEnabled[obj] = obj.Enabled end
            pcall(function() obj.Enabled = false end)
            conns[#conns+1] = obj:GetPropertyChangedSignal("Enabled"):Connect(function()
                if M.enabled and obj.Enabled then obj.Enabled = false end
            end)
        end
    end
    local function applyAll(portal)
        for _, obj in ipairs(portal:GetDescendants()) do applyObj(obj) end
        -- Catch portal pieces that stream/respawn in after we enabled.
        conns[#conns+1] = portal.DescendantAdded:Connect(function(obj)
            if M.enabled then task.defer(applyObj, obj) end
        end)
    end
    function M.set(on)
        M.enabled = on
        if on then
            local portal = workspace:FindFirstChild("TradePlazaPortal")
            if portal then
                applyAll(portal)
            else
                -- Portal not streamed in yet: wait for it without blocking.
                conns[#conns+1] = workspace.ChildAdded:Connect(function(child)
                    if M.enabled and child.Name == "TradePlazaPortal" then
                        task.defer(applyAll, child)
                    end
                end)
            end
        else
            disconnectAll()
            for obj, t in pairs(origText) do
                if obj.Parent then pcall(function() obj.Text = t end) end
            end
            for obj, c in pairs(origColor) do
                if obj.Parent then pcall(function() obj.TextColor3 = c end) end
            end
            for obj, e in pairs(origPromptEnabled) do
                if obj.Parent then pcall(function() obj.Enabled = e end) end
            end
            for obj, e in pairs(origGradEnabled) do
                if obj.Parent then pcall(function() obj.Enabled = e end) end
            end
            origText, origColor, origGradEnabled, origPromptEnabled = {}, {}, {}, {}
        end
    end
    return M
end)()
Section(Player.scroll, "Anti")
Toggle(Player.scroll, "Anti Gummy Bear", "Clear gummy-bear tool block / web attributes.", function(on) AntiAdminGummy.setAntiGummy(on) end)
Section(Player.scroll, "Auto Reset")
Toggle(Player.scroll, "Auto Reset on Balloon", "Instantly resets you when the balloon effect is applied.", function(on) AutoResetOn.setBalloon(on) end)
Toggle(Player.scroll, "Auto Reset on Jail",    "Instantly resets you when the jail effect is applied.", function(on) AutoResetOn.setJail(on) end)
Section(Player.scroll, "Movement")
Toggle(Player.scroll, "Carpet Speed", "Fly fast on the Flying Carpet.", function(on) CarpetSpeed.set(on) end)
local carpetWarnLbl
Slider(Player.scroll, "Carpet Speed Value", 100, 210, 175, function(v)
    CarpetSpeed.setSpeed(v)
    if carpetWarnLbl then carpetWarnLbl.Visible = v > 185 end
end, 1)
carpetWarnLbl = Lbl(Player.scroll, "Going over speed 185 can cause lag backs.", 9, Color3.fromRGB(255, 210, 40), Enum.Font.GothamBold, Enum.TextXAlignment.Center)
carpetWarnLbl.Size       = UDim2.new(1, -8, 0, 22)
carpetWarnLbl.TextWrapped = true
carpetWarnLbl.Visible    = (tonumber(Config.get("slider:Carpet Speed Value", 175)) or 175) > 185
Toggle(Player.scroll, "Infinite Jump", "Jump anytime, mid-air. Hold space/A to repeat.", function(on) InfiniteJump.set(on) end)
Toggle(Player.scroll, "Backpack Lock", "Forces tools back into backpack after reset; only switches when you do.", function(on) BackpackLock.set(on) end)
Section(Player.scroll, "Giant Potion")
Toggle(Player.scroll, "Auto Big Potion", "Keep giant potion active", function(on) AutoBigPotion.set(on) end)
Toggle(Player.scroll, "Giant Potion Speed", "Speed boost while giant potion is active.", function(on) GiantPotionSpeed.set(on) end)
Slider(Player.scroll, "Giant Potion Speed Value", 10, 200, 34, function(v) GiantPotionSpeed.setSpeed(v) end, 0.1)
Section(Player.scroll, "Combat")
Toggle(Player.scroll, "Aimbot", "Web Slinger / Laser Cape aimbot.", function(on) Aimbot.set(on) end)
Toggle(Player.scroll, "Auto Destroy Turrets", "Deletes turrets that other players place.", function(on) AutoTurret.set(on) end)
Section(Player.scroll, "Other")
Toggle(Player.scroll, "Hide Admin Panel", "Hides the admin topbar panel and locks the trade machine.", function(on) HideAdmin.set(on) end)
Toggle(Player.scroll, "Base Alarm", "Warn when players enter your steal hitbox.", function(on) BaseAlarm.set(on) end)
Section(Player.scroll, "Hide GUI")
Toggle(Player.scroll, "Hide GUI on Equip", "Auto-hide the hub while the selected tool is equipped.", function(on) HideOnEquip.set(on) end)
Input(Player.scroll, "Hide GUI Item", "tool name", "", function(t) HideOnEquip.setItem(t) end)
local CustomFonts = (function()
    local M = { font = nil, size = nil }
    local FONT_MAP = {
        ["Gotham"]        = Enum.Font.Gotham,
        ["Gotham Bold"]   = Enum.Font.GothamBold,
        ["Gotham Medium"] = Enum.Font.GothamMedium,
        ["Gotham Black"]  = Enum.Font.GothamBlack,
        ["Source Sans"]   = Enum.Font.SourceSans,
        ["Arial"]         = Enum.Font.Arial,
        ["Code"]          = Enum.Font.Code,
        ["Cartoon"]       = Enum.Font.Cartoon,
        ["Highway"]       = Enum.Font.Highway,
        ["Fantasy"]       = Enum.Font.Fantasy,
    }
    M.FONT_NAMES = {
        "Default", "Gotham", "Gotham Bold", "Gotham Medium", "Gotham Black",
        "Source Sans", "Arial", "Code", "Cartoon", "Highway", "Fantasy",
    }
    local function isText(o)
        if not (o:IsA("TextLabel") or o:IsA("TextButton") or o:IsA("TextBox")) then
            return false
        end
        if o:IsDescendantOf(GUI) then return false end
        if not (o:FindFirstAncestorWhichIsA("BillboardGui")
             or o:FindFirstAncestorWhichIsA("SurfaceGui")) then
            return false
        end
        return true
    end
    local function stash(o)
        if o:GetAttribute("_origFont") == nil then
            pcall(function() o:SetAttribute("_origFont", o.Font.Name) end)
        end
        if o:GetAttribute("_origSize") == nil then
            pcall(function() o:SetAttribute("_origSize", o.TextSize) end)
        end
    end
    local function apply(o)
        stash(o)
        if M.font then
            o.Font = M.font
        else
            local n = o:GetAttribute("_origFont")
            if n and Enum.Font[n] then o.Font = Enum.Font[n] end
        end
        if M.size and M.size > 0 then
            o.TextSize = M.size
        else
            local s = o:GetAttribute("_origSize")
            if s then o.TextSize = s end
        end
    end
    local _roots = {}
    local _textPool = setmetatable({}, { __mode = "k" })
    local function rememberText(o)
        if o and isText(o) then
            _textPool[o] = true
            return true
        end
        return false
    end
    local function seedRoot(r)
        local stack, si = { r }, 1
        local visited = 0
        while si > 0 do
            local cur = stack[si]; stack[si] = nil; si = si - 1
            local ch = cur:GetChildren()
            for i = 1, #ch do
                local d = ch[i]
                rememberText(d)
                si = si + 1; stack[si] = d
            end
            visited = visited + 1
            if visited % 40 == 0 then task.wait() end
        end
    end
    local function addRoot(r)
        if not r or _roots[r] then return end
        _roots[r] = true
        task.spawn(function() pcall(seedRoot, r) end)
        r.DescendantAdded:Connect(function(d)
            if rememberText(d) then task.defer(function() pcall(apply, d) end) end
        end)
    end
    local _activated = false
    local function activateRoots()
        if _activated then return end
        _activated = true
        pcall(function() addRoot(game:GetService("CoreGui")) end)
        pcall(function()
            local lp = Players.LocalPlayer
            local pg = lp and lp:FindFirstChildOfClass("PlayerGui")
            if pg then addRoot(pg) end
            if lp then
                lp.ChildAdded:Connect(function(c)
                    if c:IsA("PlayerGui") then addRoot(c) end
                end)
            end
        end)
        pcall(function() addRoot(game:GetService("Workspace")) end)
        pcall(function() addRoot(game:GetService("StarterGui")) end)
    end
    local function applyAll()
        for d in pairs(_textPool) do
            if d and d.Parent and isText(d) then pcall(apply, d) end
        end
    end
    function M.setFont(name)
        if not name or name == "Default" then
            M.font = nil
        else
            M.font = FONT_MAP[name]
        end
        if M.font then activateRoots() end
        applyAll()
    end
    function M.setSize(s)
        local n = tonumber(s)
        if not n or n <= 0 then M.size = nil else M.size = n end
        if M.size then activateRoots() end
        applyAll()
    end
    return M
end)()
Section(Utils.scroll, "Interface")
Slider(Utils.scroll, "UI Size", 50, 200, 100, function(v)
    _UI.userPct = v
    _applyUiScale()
end, 1, function(v)
    _UI.userPct = v
    _applyUiScale()
end)
Section(Utils.scroll, "Custom Fonts")
Dropdown(Utils.scroll, "Font", CustomFonts.FONT_NAMES, function(o) CustomFonts.setFont(o) end, "Default")
Input(Utils.scroll, "Font Size", "auto", "", function(s) CustomFonts.setSize(s) end)
Button(Utils.scroll, "Set To Default", "Revert text size to original.", function()
    pcall(function() Config.set("input:Font Size", "") end)
    CustomFonts.setSize(nil)
end)
Section(Utils.scroll, "Movement")
Dropdown(Utils.scroll, "Mount Type", _FH_MOUNT_NAMES, function(o)
    _FH_ActiveMount = o
    Config.set("mount_type", o)
end, _FH_ActiveMount)

local MuteWalkSound = (function()
    local M = { enabled = false, conns = {} }
    local NAME_HINTS = { "running", "footstep", "footsteps", "walk", "step", "movement" }
    local function looksWalk(name)
        name = string.lower(name or "")
        for _, h in ipairs(NAME_HINTS) do
            if string.find(name, h, 1, true) then return true end
        end
        return false
    end
    local function muteSound(s)
        if not (M.enabled and s and s:IsA("Sound") and looksWalk(s.Name)) then return end
        pcall(function() s.Volume = 0 end)
        table.insert(M.conns, s:GetPropertyChangedSignal("Volume"):Connect(function()
            if M.enabled and s.Volume ~= 0 then pcall(function() s.Volume = 0 end) end
        end))
    end
    local function hookCharacter(char)
        if not char then return end
        for _, d in ipairs(char:GetDescendants()) do muteSound(d) end
        table.insert(M.conns, char.DescendantAdded:Connect(function(d)
            if not M.enabled then return end
            if d:IsA("Sound") then task.defer(muteSound, d) end
        end))
    end
    local function disconnectAll()
        for _, c in ipairs(M.conns) do pcall(function() c:Disconnect() end) end
        M.conns = {}
    end
    function M.set(on)
        M.enabled = on and true or false
        disconnectAll()
        if not M.enabled then return end
        local lp = Players.LocalPlayer
        if lp.Character then hookCharacter(lp.Character) end
        table.insert(M.conns, lp.CharacterAdded:Connect(function(char)
            if not M.enabled then return end
            task.wait(0.3)
            hookCharacter(char)
        end))
    end
    return M
end)()
Toggle(Utils.scroll, "Mute Walk Sound", "Silences your footstep/walking sounds.", function(on) MuteWalkSound.set(on) end)
Section(Main.scroll, "Panels")
Toggle(Main.scroll, "Booster Panel", "Show booster window", function(on) boosterPanel.panel.Visible = on end)
Toggle(Main.scroll, "Actions Panel", "Show actions window", function(on) actionsPanel.panel.Visible = on end)
Toggle(Main.scroll, "Defense Panel", "Show defense window", function(on) defensePanel.panel.Visible = on end)
Toggle(Main.scroll, "Unlock Base Panel", "Unlock enemy base floors (1/2/3)", function(on) unlockPanel.panel.Visible = on end)
local cdPanelToggle = Toggle(Main.scroll, "Command Cooldowns Panel", "Live admin command cooldowns", function(on) if _panelsReady then cdPanel.panel.Visible = on end end)
Toggle(Main.scroll, "Mobile Mini Panel", "Quick-action buttons for mobile users.", function(on) MobilePanel.setVisible(on) end)
_panelsReady = true

priorityPanel.panel.Visible = grabPriorityToggle.get()
cdPanel.panel.Visible       = cdPanelToggle.get()
Section(Utils.scroll, "Panels")
Toggle(Utils.scroll, "Quick Panel", "Per-player quick admin commands", function(on) QP.setQuickPanelVisible(on) end)
Toggle(Utils.scroll, "Admin Spammer", "Spam admin commands per-player", function(on) spamPanel.panel.Visible = on end)
Toggle(Utils.scroll, "Quick Pickup", "Near-instant pickup (0.1s) for brainrots in YOUR base.", function(on) QuickPickup.set(on) end)
local flashPanel = MiniPanel("Flash Teleport", -260, -120, 190)
FlashTeleport.setActive(false)
Toggle(flashPanel.body, "Giant Potion", "Fire the Giant Potion from your backpack right after the Flash Teleport fires.", function(on) FlashTeleport.setGiantPotion(on) end)
-- Sliders first; the mode dropdown is added LAST so its expanding option list
-- opens into empty space and its clicks are never intercepted by a slider below.
local _ftTimingSlider  = Slider(flashPanel.body, "Trigger Timing", 1.00, 1.50, 1.00, function(v) FlashTeleport.setTiming(v) end, 0.01)
local _ftPercentSlider = Slider(flashPanel.body, "Percent", 80, 100, 90, function(v) FlashTeleport.setPercent(v) end, 1)
local function _ftApplyMode(o)
    FlashTeleport.setMode(o)
    if _ftTimingSlider  then _ftTimingSlider.card.Visible  = (o == "Timing")  end
    if _ftPercentSlider then _ftPercentSlider.card.Visible = (o == "Percent") end
end
Dropdown(flashPanel.body, "Trigger Mode", {"Timing", "Percent"}, _ftApplyMode, "Timing")
Toggle(Utils.scroll, "Flash Teleport Panel", "Auto-fire the Flash Teleport tool while holding a steal prompt (by timing or % of hold), with optional Giant Potion follow-up.", function(on)
    flashPanel.panel.Visible = on
    FlashTeleport.setActive(on)
end)
Section(Utils.scroll, "Trade & Logging")
Toggle(Utils.scroll, "Auto Kick On Steal", "Kick yourself the moment a steal lands.", function(on) AutoKickOnSteal.set(on) end)
Toggle(Utils.scroll, "Trade Region Block", "Makes trading look region-locked: Send buttons appear quietly disabled (\"Unavailable\") with a subtle in-game note.", function(on) TradeRegionBlock.set(on) end)
Toggle(Utils.scroll, "Logger Protector", "Kicks you if trade GUIs are forcibly disabled.", function(on) LoggerProtector.set(on) end)
Toggle(Utils.scroll, "Hide Trade Plaza", "Disables Trade Plaza portal (prompt off, label swap)", function(on) HideTradePlaza.set(on) end)
Section(Utils.scroll, "Animations")
Toggle(Utils.scroll, "Animations Panel", "Apply animation packs in Gamma style.", function(on) animPanel.panel.Visible = on end)
Section(Utils.scroll, "Reset")
Button(Utils.scroll, "Reset All Configs", "Restore every panel to its original default position.", function()
    for _, entry in ipairs(_miniPanelRegistry) do
        pcall(function()
            Tween(entry.panel, M, { Position = entry.defaultPos })
            Config.set(entry.key, nil)
        end)
    end
    if QP and QP.QPWin and QP.QPBorderFrame then
        Tween(QP.QPWin,         M, { Position = UDim2.new(0, 16, 0.55, 0) })
        Tween(QP.QPBorderFrame, M, { Position = UDim2.new(0, 14, 0.55, -2) })
        Config.set("qp_pos", nil)
    end
    local ubPanel  = GUI:FindFirstChild("UnlockBasePanel")
    local ubBorder = GUI:FindFirstChild("UBGradBorder")
    if ubPanel then
        local ubW = ubPanel.Size.X.Offset
        local ubH = ubPanel.Size.Y.Offset
        Tween(ubPanel,  M, { Position = UDim2.new(0.5, -ubW / 2, 1, -(ubH + 82)) })
        if ubBorder then
            Tween(ubBorder, M, { Position = UDim2.new(0.5, -(ubW + 4) / 2, 1, -(ubH + 4 + 80)) })
        end
        Config.set("panelpos:UnlockBase", nil)
    end
    Tween(Root, M, { Position = UDim2.new(0.5, 0, 0.5, 0) })
    Config.set("reopen_pos", nil)
end)
local Picker
;(function()
Picker = Instance.new("Frame")
Picker.Size             = UDim2.new(0, 208, 0, 214)
Picker.BackgroundColor3 = T.Side
Picker.BorderSizePixel  = 0
Picker.Visible          = false
Picker.ZIndex           = 100
Picker.Parent           = GUI
_newScale(Picker)
trackBgFrame(Picker, "Side")
Corner(Picker, 10)
GradStroke(Picker, 2, 0, 0)
local PickerHdr = Instance.new("Frame")
PickerHdr.Size             = UDim2.new(1, 0, 0, 24)
PickerHdr.BackgroundColor3 = T.BgDeep
PickerHdr.BorderSizePixel  = 0
PickerHdr.ZIndex           = 101
PickerHdr.Parent           = Picker
trackBgFrame(PickerHdr, "BgDeep")
Corner(PickerHdr, 10)
local PickerHdrFill = Instance.new("Frame")
PickerHdrFill.Size             = UDim2.new(1, 0, 0, 8)
PickerHdrFill.Position         = UDim2.new(0, 0, 1, -8)
PickerHdrFill.BackgroundColor3 = T.BgDeep
PickerHdrFill.BorderSizePixel  = 0
PickerHdrFill.ZIndex           = 101
PickerHdrFill.Parent           = PickerHdr
trackBgFrame(PickerHdrFill, "BgDeep")
local PickerTitle = Lbl(PickerHdr, "Color Picker", 10, T.Text, Enum.Font.GothamBold)
PickerTitle.Size           = UDim2.new(1, -30, 1, 0)
PickerTitle.Position       = UDim2.new(0, 10, 0, 0)
PickerTitle.TextYAlignment = Enum.TextYAlignment.Center
PickerTitle.ZIndex         = 102
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size                   = UDim2.new(0, 20, 0, 20)
CloseBtn.Position               = UDim2.new(1, -22, 0, 2)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text                   = "x"
CloseBtn.Font                   = Enum.Font.GothamBold
CloseBtn.TextSize               = 12
CloseBtn.TextColor3             = T.TextDim
CloseBtn.AutoButtonColor        = false
CloseBtn.ZIndex                 = 102
CloseBtn.Parent                 = PickerHdr
CloseBtn.MouseEnter:Connect(function() Tween(CloseBtn, F, {TextColor3 = T.Text}) end)
CloseBtn.MouseLeave:Connect(function() Tween(CloseBtn, F, {TextColor3 = T.TextDim}) end)
local SV = Instance.new("Frame")
SV.Size             = UDim2.new(0, 158, 0, 124)
SV.Position         = UDim2.new(0, 10, 0, 32)
SV.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
SV.BorderSizePixel  = 0
SV.ZIndex           = 101
SV.Parent           = Picker
Corner(SV, 5)
local SatOverlay = Instance.new("Frame")
SatOverlay.Size             = UDim2.new(1, 0, 1, 0)
SatOverlay.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
SatOverlay.BorderSizePixel  = 0
SatOverlay.ZIndex           = 102
SatOverlay.Parent           = SV
Corner(SatOverlay, 5)
local satGrad = Instance.new("UIGradient")
satGrad.Color = ColorSequence.new(Color3.new(1,1,1), Color3.new(1,1,1))
satGrad.Transparency = NumberSequence.new({
    NumberSequenceKeypoint.new(0, 0),
    NumberSequenceKeypoint.new(1, 1),
})
satGrad.Rotation = 0
satGrad.Parent   = SatOverlay
local ValOverlay = Instance.new("Frame")
ValOverlay.Size             = UDim2.new(1, 0, 1, 0)
ValOverlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
ValOverlay.BorderSizePixel  = 0
ValOverlay.ZIndex           = 103
ValOverlay.Parent           = SV
Corner(ValOverlay, 5)
local valGrad = Instance.new("UIGradient")
valGrad.Color = ColorSequence.new(Color3.new(0,0,0), Color3.new(0,0,0))
valGrad.Transparency = NumberSequence.new({
    NumberSequenceKeypoint.new(0, 1),
    NumberSequenceKeypoint.new(1, 0),
})
valGrad.Rotation = 90
valGrad.Parent   = ValOverlay
local SVCursor = Instance.new("Frame")
SVCursor.Size                   = UDim2.new(0, 10, 0, 10)
SVCursor.AnchorPoint            = Vector2.new(0.5, 0.5)
SVCursor.Position               = UDim2.new(1, 0, 0, 0)
SVCursor.BackgroundTransparency = 1
SVCursor.BorderSizePixel        = 0
SVCursor.ZIndex                 = 104
SVCursor.Parent                 = SV
Corner(SVCursor, 5)
Stroke(SVCursor, T.White, 2, 0)
local HueBar = Instance.new("Frame")
HueBar.Size             = UDim2.new(0, 18, 0, 124)
HueBar.Position         = UDim2.new(0, 174, 0, 32)
HueBar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
HueBar.BorderSizePixel  = 0
HueBar.ZIndex           = 101
HueBar.Parent           = Picker
Corner(HueBar, 4)
local hueGrad = Instance.new("UIGradient")
hueGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0,     Color3.fromRGB(255,   0,   0)),
    ColorSequenceKeypoint.new(0.167, Color3.fromRGB(255, 255,   0)),
    ColorSequenceKeypoint.new(0.333, Color3.fromRGB(  0, 255,   0)),
    ColorSequenceKeypoint.new(0.5,   Color3.fromRGB(  0, 255, 255)),
    ColorSequenceKeypoint.new(0.667, Color3.fromRGB(  0,   0, 255)),
    ColorSequenceKeypoint.new(0.833, Color3.fromRGB(255,   0, 255)),
    ColorSequenceKeypoint.new(1,     Color3.fromRGB(255,   0,   0)),
})
hueGrad.Rotation = 90
hueGrad.Parent   = HueBar
local HueCursor = Instance.new("Frame")
HueCursor.Size                   = UDim2.new(1, 4, 0, 4)
HueCursor.AnchorPoint            = Vector2.new(0.5, 0.5)
HueCursor.Position               = UDim2.new(0.5, 0, 0, 0)
HueCursor.BackgroundColor3       = T.White
HueCursor.BorderSizePixel        = 0
HueCursor.ZIndex                 = 102
HueCursor.Parent                 = HueBar
Corner(HueCursor, 2)
Stroke(HueCursor, Color3.fromRGB(0, 0, 0), 1, 0.3)
local ApplyBtn = Instance.new("TextButton")
ApplyBtn.Size                   = UDim2.new(0, 182, 0, 44)
ApplyBtn.Position               = UDim2.new(0, 10, 0, 162)
ApplyBtn.BackgroundColor3       = Theme.c1
ApplyBtn.BorderSizePixel        = 0
ApplyBtn.Text                   = ""
ApplyBtn.AutoButtonColor        = false
ApplyBtn.ZIndex                 = 101
ApplyBtn.Parent                 = Picker
Corner(ApplyBtn, 6)
local applyStroke = Stroke(ApplyBtn, T.White, 1.4, 0.3)
ApplyBtn.MouseEnter:Connect(function() Tween(applyStroke, F, {Transparency = 0}) end)
ApplyBtn.MouseLeave:Connect(function() Tween(applyStroke, F, {Transparency = 0.3}) end)
local pickerState = {slot = 1, h = 0.75, s = 1, v = 0.97, pending = Theme.c1}
local function updatePickerVisuals()
    local col = Color3.fromHSV(pickerState.h, pickerState.s, pickerState.v)
    pickerState.pending       = col
    SV.BackgroundColor3       = Color3.fromHSV(pickerState.h, 1, 1)
    SVCursor.Position         = UDim2.new(pickerState.s, 0, 1 - pickerState.v, 0)
    HueCursor.Position        = UDim2.new(0.5, 0, pickerState.h, 0)
    ApplyBtn.BackgroundColor3 = col
end
local function rgbToHsv(c)
    local r, g, b = c.R, c.G, c.B
    local mx = math.max(r, g, b)
    local mn = math.min(r, g, b)
    local d  = mx - mn
    local h  = 0
    if d > 0 then
        if mx == r then     h = ((g - b)/d) % 6
        elseif mx == g then h = ((b - r)/d) + 2
        else                h = ((r - g)/d) + 4 end
        h = h / 6
        if h < 0 then h = h + 1 end
    end
    local s = (mx > 0) and (d / mx) or 0
    return h, s, mx
end
local function openPicker(slot)
    pickerState.slot = slot
    local current = (slot == 1) and Theme.c1 or T.Bg
    pickerState.h, pickerState.s, pickerState.v = rgbToHsv(current)
    updatePickerVisuals()
    local guiSz = GUI.AbsoluteSize
    if isMobile then
        local px = math.max(4, math.floor((guiSz.X - 208) / 2))
        local py = math.max(4, math.floor((guiSz.Y - 214) / 2))
        Picker.Position = UDim2.new(0, px, 0, py)
    else
        local dot = (slot == 1) and Dot1 or Dot2
        local pos = dot.AbsolutePosition
        local px = math.max(8, math.min(pos.X - 100, guiSz.X - 216))
        local py = pos.Y + 24
        Picker.Position = UDim2.new(0, px, 0, py)
    end
    Picker.Visible = true
end
local function persistTheme()
    Config.set("theme_c1", { math.floor(Theme.c1.R*255+0.5), math.floor(Theme.c1.G*255+0.5), math.floor(Theme.c1.B*255+0.5) })
    Config.set("theme_c2", { math.floor(Theme.c2.R*255+0.5), math.floor(Theme.c2.G*255+0.5), math.floor(Theme.c2.B*255+0.5) })
    Config.set("theme_bg",  { math.floor(T.Bg.R*255+0.5),    math.floor(T.Bg.G*255+0.5),    math.floor(T.Bg.B*255+0.5)    })
end
local function applyLive()
    local col = pickerState.pending
    if pickerState.slot == 1 then
        Theme.c1 = col
        Dot1.BackgroundColor3 = col
        Repaint()
    else
        SetGuiColor(col)
        Dot2.BackgroundColor3 = T.Bg
    end
    persistTheme()
end
local function applyPicked()
    applyLive()
    persistTheme()
end
Dot1Btn.Activated:Connect(function() openPicker(1) end)
Dot2Btn.Activated:Connect(function() openPicker(2) end)
CloseBtn.Activated:Connect(function() Picker.Visible = false end)
ApplyBtn.Activated:Connect(applyPicked)
local svDragging, hueDragging = false, false
SV.InputBegan:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1
    or inp.UserInputType == Enum.UserInputType.Touch then
        svDragging = true
        local pos  = SV.AbsolutePosition
        local size = SV.AbsoluteSize
        pickerState.s = math.clamp((inp.Position.X - pos.X) / size.X, 0, 1)
        pickerState.v = 1 - math.clamp((inp.Position.Y - pos.Y) / size.Y, 0, 1)
        updatePickerVisuals(); applyLive()
    end
end)
SV.InputEnded:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1
    or inp.UserInputType == Enum.UserInputType.Touch then svDragging = false end
end)
HueBar.InputBegan:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1
    or inp.UserInputType == Enum.UserInputType.Touch then
        hueDragging = true
        local pos  = HueBar.AbsolutePosition
        local size = HueBar.AbsoluteSize
        pickerState.h = math.clamp((inp.Position.Y - pos.Y) / size.Y, 0, 1)
        updatePickerVisuals(); applyLive()
    end
end)
HueBar.InputEnded:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1
    or inp.UserInputType == Enum.UserInputType.Touch then hueDragging = false end
end)
UserInputService.InputChanged:Connect(function(inp)
    if inp.UserInputType ~= Enum.UserInputType.MouseMovement
    and inp.UserInputType ~= Enum.UserInputType.Touch then return end
    if svDragging then
        local pos  = SV.AbsolutePosition
        local size = SV.AbsoluteSize
        pickerState.s = math.clamp((inp.Position.X - pos.X) / size.X, 0, 1)
        pickerState.v = 1 - math.clamp((inp.Position.Y - pos.Y) / size.Y, 0, 1)
        updatePickerVisuals()
        applyLive()
    elseif hueDragging then
        local pos  = HueBar.AbsolutePosition
        local size = HueBar.AbsoluteSize
        pickerState.h = math.clamp((inp.Position.Y - pos.Y) / size.Y, 0, 1)
        updatePickerVisuals()
        applyLive()
    end
end)
end)()
setPage(Main)
task.defer(function() pcall(Repaint) end)
rootScale = Instance.new("UIScale")
rootScale.Scale  = _UI.desiredScale
rootScale.Parent = Root
local POP_IN  = TweenInfo.new(0.22, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
local POP_OUT = TweenInfo.new(0.16, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
visible   = Config.get("hub_open", true)
if not visible then
    Root.Visible    = false
    rootScale.Scale = 0
end
local curVisTween = nil
setVisible = function(show)
    if show == visible then return end
    visible = show
    Config.set("hub_open", show)
    if curVisTween then curVisTween:Cancel() end
    if show then
        Root.Visible = true
        if rootScale.Scale < 0.01 then rootScale.Scale = (_UI.desiredScale or 1) * 0.85 end
        curVisTween = TweenService:Create(rootScale, POP_IN, {Scale = _UI.desiredScale or 1})
        curVisTween:Play()
    else
        Picker.Visible = false
        curVisTween = TweenService:Create(rootScale, POP_OUT, {Scale = 0})
        local t = curVisTween
        t.Completed:Connect(function(state)
            if state == Enum.PlaybackState.Completed and not visible then
                Root.Visible = false
            end
        end)
        t:Play()
    end
end
UserInputService.InputBegan:Connect(function(inp, gpe)
    if gpe and UserInputService:GetFocusedTextBox() then return end
    if inp.UserInputType == Enum.UserInputType.Keyboard
    and (inp.KeyCode == Enum.KeyCode.LeftControl
      or inp.KeyCode == Enum.KeyCode.RightControl) then
        setVisible(not visible)
    end
end)
do
    local function adopt(ch)
        if ch ~= UIRoot and ch:IsA("GuiObject") then
            pcall(function() ch.Parent = UIRoot end)
        end
    end
    task.defer(function()
        local children = GUI:GetChildren()
        for i, ch in ipairs(children) do
            pcall(adopt, ch)
            if i % 8 == 0 then task.wait() end
        end
    end)
    GUI.ChildAdded:Connect(function(ch) task.defer(adopt, ch) end)
end
task.defer(function() _guiReady = true end)
end)
end)
