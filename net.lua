--[[
    ═══════════════════════════════════════════════════════════════════════════════
    👻 SUITE ASTRAL V12.0 — TITANIUM SINGULARITY EDITION
    ═══════════════════════════════════════════════════════════════════════════════
    100+ Sistemas Reais | 10 Abas Categorizadas | UI Glassmorphism + 10 Temas
    Combate Pro (Aimbot + Predição, Skeleton ESP, 2D Box, Radar 2D, Kill-Aura)
    Mobilidade Extrema (Astral, Fly, Spider-Swing, Jetpack, Blink, Macro Pro)
    Mundo & Dev Tools (Part Spawner, Vortex, Anti-Grav Zone, Explorer, Sound Spy)
    Automação (Auto-ClickDetectors, Auto-Prompts, Magnet Touch, Named Waypoints)
    Rede (Server Hop Menor/Aleatório, Rejoin, Chat Logger, Remote Scanner)
    10 Escudos Blindados | Perfis Múltiplos (A/B/C) | Mini-HUD 7.0 | Unload Limpo
    ═══════════════════════════════════════════════════════════════════════════════
]]

if _G.SuiteAstralV12_Cleanup then
    pcall(_G.SuiteAstralV12_Cleanup)
end

-- ════════════════════════════════════════════════════════════════════════════════
-- SERVICES
-- ════════════════════════════════════════════════════════════════════════════════
local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local UserInputService  = game:GetService("UserInputService")
local Workspace         = game:GetService("Workspace")
local StarterGui        = game:GetService("StarterGui")
local TweenService      = game:GetService("TweenService")
local Lighting          = game:GetService("Lighting")
local HttpService       = game:GetService("HttpService")
local TeleportService   = game:GetService("TeleportService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Stats             = game:GetService("Stats")

local VirtualUser = nil
pcall(function()
    VirtualUser = game:GetService("VirtualUser")
end)

local player = Players.LocalPlayer
local camera = Workspace.CurrentCamera
local mouse  = player:GetMouse()

local connections = {}
local F = {}
local function trackConn(conn)
    if conn then
        table.insert(connections, conn)
    end
    return conn
end

-- ════════════════════════════════════════════════════════════════════════════════
-- CONFIGURAÇÕES GLOBAIS V12.0
-- ════════════════════════════════════════════════════════════════════════════════
local config = {
    -- Mobilidade
    modoAstralAtivo        = false,
    alturaCeu              = 850,
    vooAtivo               = false,
    velocidadeVoo          = 65,
    multiplicadorSprintVoo = 2.5,
    velocidadeSprint       = 32,
    velocidadePadrao       = 16,
    puloInfinitoAtivo      = false,
    andarParedesAtivo      = false,
    freezeAtivo            = false,
    cameraLivreAtiva       = false,
    checkpointPos          = nil,
    invisibilidadeAtiva    = false,
    freeCamSpeed           = 50,
    freeCamSens            = 0.35,
    magicFloorAtivo        = false,
    elevadorAtivo          = false,
    elevadorVelocidade     = 35,
    bhopAtivo              = false,
    dashForca              = 85,
    blinkDist              = 35,
    superPuloAtivo         = false,
    superPuloForca         = 120,
    autoWalkAtivo          = false,
    spiderClimbAtivo       = false,
    spinbotAtivo           = false,
    spinbotSpeed           = 18,
    airSwimAtivo           = false,
    vehicleBoostAtivo      = false,
    vehicleSpeed           = 120,
    pathTrailAtivo         = false,
    autoVaultAtivo         = false,
    jetpackAtivo           = false,
    jetpackForca           = 55,

    -- Macro / Waypoint Recorder
    macroGravando          = false,
    macroReproduzindo      = false,
    macroReverso           = false,
    macroLoop              = true,
    macroVelocidade        = 1,

    -- Combate & Mira
    aimbotAtivo            = false,
    aimbotSuavidade        = 0.25,
    aimbotFov              = 140,
    aimbotTeamCheck        = true,
    aimbotWallCheck        = true,
    aimbotPredicao         = true,
    aimbotPredicaoFator    = 0.14,
    aimbotParte            = "Head",
    aimbotShowFov          = true,
    hitboxAtivo            = false,
    hitboxTamanho          = 8,
    hitboxTransp           = 0.65,
    triggerbotAtivo        = false,
    triggerDelay           = 0.05,
    killAuraAtivo          = false,
    killAuraRaio           = 16,
    autoDodgeAtivo         = false,
    autoDodgeRaio          = 10,

    -- Visão & Óptica
    fullbrightAtivo        = false,
    timeOfDayAtivo         = false,
    timeOfDayValor         = 14,
    noFogAtivo             = false,
    droneModeAtivo         = false,
    fovIndice              = 1,
    cameraFovOriginal      = camera and camera.FieldOfView or 70,
    cameraZoomOriginal     = player.CameraMaxZoomDistance,
    xrayAtivo              = false,
    espAtivo               = false,
    esp2DBoxAtivo          = false,
    espSkeletonAtivo       = false,
    espTeamCheck           = false,
    espMaxDist             = 1500,
    corAuraIndice          = 1,
    outlineTrackerAtivo    = false,
    tracersAtivo           = false,
    crosshairAtivo         = false,
    crosshairEstilo        = 1, -- 1=Cruz, 2=Ponto, 3=Círculo, 4=T-Cruz
    radarInteracoesAtivo   = false,
    detectorAurasAtivo     = false,
    radar2DAtivo           = false,
    radar2DRange           = 200,

    -- Mundo & Builder
    vortexAtivo            = false,
    vortexRaio             = 85,
    vortexForca            = 65,
    antiGravZoneAtivo      = false,
    gravGunAtivo           = false,
    gravGunDist            = 16,
    spawnerMaterial        = "Neon",
    spawnerAnchored        = true,
    spawnerSize            = 8,

    -- Avatar & Efeitos
    auraParticulasAtiva    = false,
    rainbowTemaAtivo       = false,

    -- Jogadores
    orbitAtivo             = false,
    alvoOrbit              = nil,
    orbitRaio              = 14,
    orbitVel               = 2.5,
    orbitAngulo            = 0,
    followAtivo            = false,
    alvoFollow             = nil,

    -- Utilitários & Automação
    antiAfkAtivo           = true,
    noclipAtivo            = false,
    deleteModeAtivo        = false,
    inspectorAtivo         = false,
    speedHackAtivo         = false,
    speedHackMultiplier    = 2,
    gravitacaoAtiva        = false,
    gravitacaoPercent      = 100,
    miniHudAtivo           = true,
    slotAlturaOffset       = 15,
    slotAlturaDirecao      = "cima",
    autoClickerAtivo       = false,
    autoClickerCPS         = 20,
    autoClickerBotao       = "Left",
    autoInteractAtivo      = false,
    autoClickDetectors     = false,
    magnetAtivo            = false,
    magnetTouchAtivo       = false,
    fpsBoosterAtivo        = false,

    -- Defesas Blindadas (OFF por padrão)
    antiFling              = false,
    antiVoid               = false,
    antiRagdoll            = false,
    antiAnchor             = false,
    autoEmergencyHp        = false,
    emergencyHpThreshold   = 30,
    antiKillbrick          = false,
    antiFallDamage         = false,
    antiBlind              = false,
    antiSeat               = false,
    velocityCapAtivo       = false,
    velocityCapMax         = 220,

    -- Aparência & Sistema
    temaIndice             = 1,
    modoSilencioso         = false,
    uiTransparencia        = 0.06,
}

-- ════════════════════════════════════════════════════════════════════════════════
-- TECLAS & ATALHOS CUSTOMIZÁVEIS
-- ════════════════════════════════════════════════════════════════════════════════
local teclasPadrao = {
    menu         = Enum.KeyCode.F8,
    hud          = Enum.KeyCode.Tab,
    panico       = Enum.KeyCode.F12,
    checkpoint   = Enum.KeyCode.R,
    dash         = Enum.KeyCode.F10,
    autowalk     = Enum.KeyCode.Home,
    autoclicker  = Enum.KeyCode.F9,
    astral       = Enum.KeyCode.G,
    voo          = Enum.KeyCode.F,
    paredes      = Enum.KeyCode.L,
    pulo         = Enum.KeyCode.P,
    freeze       = Enum.KeyCode.Q,
    grapple      = Enum.KeyCode.Y,
    magicfloor   = Enum.KeyCode.U,
    elevador     = Enum.KeyCode.End,
    bhop         = Enum.KeyCode.F7,
    freecam      = Enum.KeyCode.C,
    invisivel    = Enum.KeyCode.T,
    choque       = Enum.KeyCode.Insert,
    limpar       = Enum.KeyCode.Delete,
    fullbright   = Enum.KeyCode.H,
    fov          = Enum.KeyCode.F11,
    drone        = Enum.KeyCode.F5,
    xray         = Enum.KeyCode.X,
    noclip       = Enum.KeyCode.N,
    delete       = Enum.KeyCode.B,
    undo         = Enum.KeyCode.Z,
    inspector    = Enum.KeyCode.E,
    outline      = Enum.KeyCode.O,
    speedhack    = Enum.KeyCode.F1,
    gravidade    = Enum.KeyCode.F2,
    spawns       = Enum.KeyCode.F3,
    radar        = Enum.KeyCode.F4,
    antiafk      = Enum.KeyCode.F6,
    esp          = Enum.KeyCode.V,
    cor          = Enum.KeyCode.M,
    playerlist   = Enum.KeyCode.J,
    auras        = Enum.KeyCode.K,
}

local teclasConfig = {}
for k, v in pairs(teclasPadrao) do
    teclasConfig[k] = v
end
local rebindAtivo  = nil
local rebindBtnRef = nil

local fovPresets = {70, 90, 110, 30}

local coresAura = {
    {nome = "Ciano Neon",   cor = Color3.fromRGB(0, 255, 255)},
    {nome = "Verde Neon",   cor = Color3.fromRGB(50, 255, 120)},
    {nome = "Roxo Neon",    cor = Color3.fromRGB(168, 85, 247)},
    {nome = "Vermelho",     cor = Color3.fromRGB(255, 65, 65)},
    {nome = "Amarelo Ouro", cor = Color3.fromRGB(255, 215, 0)},
    {nome = "Laranja",      cor = Color3.fromRGB(255, 125, 0)},
    {nome = "Rosa Choque",  cor = Color3.fromRGB(255, 60, 200)},
    {nome = "Branco Puro",  cor = Color3.fromRGB(255, 255, 255)},
}

local temas = {
    {nome = "Roxo Astral",      accent = Color3.fromRGB(168, 85, 247),  glow = Color3.fromRGB(192, 132, 252), bg = Color3.fromRGB(10, 12, 20)},
    {nome = "Ciano Cyber",      accent = Color3.fromRGB(6, 182, 212),   glow = Color3.fromRGB(34, 211, 238),  bg = Color3.fromRGB(8, 14, 22)},
    {nome = "Esmeralda Matrix", accent = Color3.fromRGB(16, 185, 129),  glow = Color3.fromRGB(52, 211, 153),  bg = Color3.fromRGB(8, 16, 14)},
    {nome = "Carmesim Rubro",   accent = Color3.fromRGB(239, 68, 68),   glow = Color3.fromRGB(248, 113, 113), bg = Color3.fromRGB(18, 10, 14)},
    {nome = "Dourado Imperial", accent = Color3.fromRGB(234, 179, 8),   glow = Color3.fromRGB(250, 204, 21),  bg = Color3.fromRGB(16, 14, 10)},
    {nome = "Obsidiana Rose",   accent = Color3.fromRGB(244, 63, 94),   glow = Color3.fromRGB(251, 113, 133), bg = Color3.fromRGB(16, 10, 16)},
    {nome = "Azul Titânio",     accent = Color3.fromRGB(59, 130, 246),  glow = Color3.fromRGB(96, 165, 250),  bg = Color3.fromRGB(9, 13, 24)},
    {nome = "Laranja Solar",    accent = Color3.fromRGB(249, 115, 22),  glow = Color3.fromRGB(251, 146, 60),  bg = Color3.fromRGB(18, 12, 10)},
    {nome = "Violeta Neon",     accent = Color3.fromRGB(217, 70, 239),  glow = Color3.fromRGB(232, 121, 249), bg = Color3.fromRGB(14, 10, 20)},
    {nome = "Prata Fantasma",   accent = Color3.fromRGB(148, 163, 184), glow = Color3.fromRGB(203, 213, 225), bg = Color3.fromRGB(12, 14, 18)},
}

-- ════════════════════════════════════════════════════════════════════════════════
-- TABELAS CENTRAIS DE UI & ESTADO
-- ════════════════════════════════════════════════════════════════════════════════
local UI = {
    toggles         = {},
    keybindButtons  = {},
    themeAccentObjs = {},
    searchableCards = {},
    esp2DBoxes      = {},
    radarDots       = {},
    skeletonLines   = {},
}

local state = {
    slotsPosicoes         = {},
    namedWaypoints        = {},
    copiaPersonagem       = nil,
    plataformaCeu         = nil,
    magicFloorPart        = nil,
    magicFloorY           = nil,
    xrayOriginalTransp    = {},
    invisOriginal         = {},
    noclipOriginal        = {},
    fpsOriginal           = {},
    hitboxOriginal        = {},
    undoHistory           = {},
    tempPlataformas       = {},
    spawnedParts          = {},
    tracersCache          = {},
    radarItens            = {},
    aurasBoxes            = {},
    aurasOriginais        = {},
    animTracks            = {},
    espItens              = {},
    macroFrames           = {},
    macroRecordTimer      = 0,
    macroPlayIdx          = 1,
    pathTrailTimer        = 0,
    espThrottleTimer      = 0,
    radarTimer            = 0,
    lastSafeCFrame        = nil,
    lastEmergencyWarp     = 0,
    autoClickerTimer      = 0,
    autoInteractTimer     = 0,
    autoClickDetTimer     = 0,
    magnetTimer           = 0,
    killbrickTimer        = 0,
    killAuraTimer         = 0,
    triggerTimer          = 0,
    dodgeTimer            = 0,
    lastDash              = 0,
    spectatingPlayer      = nil,
    cameraOriginalSubject = nil,
    droneOriginalMaxZoom  = player.CameraMaxZoomDistance,
    freeCamCFrame         = CFrame.new(0, 50, 0),
    freeCamYaw            = 0,
    freeCamPitch          = 0,
    freeCamRotating       = false,
    aimbotHolding         = false,
    gravGunPart           = nil,
    gravForce             = nil,
    auraEmitter           = nil,
    customAnimTrack       = nil,
    swingRope             = nil,
    swingAttach0          = nil,
    swingAttach1          = nil,
    swingAnchorPart       = nil,
    bhopGrounded          = false,
    grappleBeams          = {},
    inspectorTarget       = nil,
    outlineTarget         = nil,
    outlineBox            = nil,
    frameCount            = 0,
    lastFps               = 60,
    fpsTimer              = 0,
    serverStartTime       = tick(),
    chatLogs              = {},
    rainbowHue            = 0,
    unloaded              = false,
}

local originalLighting = {
    GlobalShadows  = Lighting.GlobalShadows,
    FogEnd         = Lighting.FogEnd,
    Brightness     = Lighting.Brightness,
    ClockTime      = Lighting.ClockTime,
    Ambient        = Lighting.Ambient,
    OutdoorAmbient = Lighting.OutdoorAmbient,
}

do
    local pod = Instance.new("Part")
    pod.Name         = "SuiteV12AstralSkyPod"
    pod.Size         = Vector3.new(24, 1.2, 24)
    pod.Transparency = 0.55
    pod.Color        = temas[1].accent
    pod.Material     = Enum.Material.ForceField
    pod.Anchored     = true
    pod.CanCollide   = true
    pod.CFrame       = CFrame.new(0, -9999, 0)
    pod.Parent       = Workspace
    state.plataformaCeu = pod
end

local rayParams = RaycastParams.new()
rayParams.FilterType = Enum.RaycastFilterType.Exclude

local function atualizarRayParams()
    local excl = {}
    if player.Character then
        table.insert(excl, player.Character)
    end
    if state.copiaPersonagem then
        table.insert(excl, state.copiaPersonagem)
    end
    if state.plataformaCeu then
        table.insert(excl, state.plataformaCeu)
    end
    if state.magicFloorPart then
        table.insert(excl, state.magicFloorPart)
    end
    for _, p in ipairs(state.tempPlataformas) do
        if p then
            table.insert(excl, p)
        end
    end
    for _, p in ipairs(state.spawnedParts) do
        if p then
            table.insert(excl, p)
        end
    end
    rayParams.FilterDescendantsInstances = excl
end

local slotMapa = {
    [Enum.KeyCode.Zero] = 0, [Enum.KeyCode.One] = 1, [Enum.KeyCode.Two] = 2,
    [Enum.KeyCode.Three] = 3, [Enum.KeyCode.Four] = 4, [Enum.KeyCode.Five] = 5,
    [Enum.KeyCode.Six] = 6, [Enum.KeyCode.Seven] = 7, [Enum.KeyCode.Eight] = 8,
    [Enum.KeyCode.Nine] = 9,
    [Enum.KeyCode.KeypadZero] = 0, [Enum.KeyCode.KeypadOne] = 1,
    [Enum.KeyCode.KeypadTwo] = 2, [Enum.KeyCode.KeypadThree] = 3,
    [Enum.KeyCode.KeypadFour] = 4, [Enum.KeyCode.KeypadFive] = 5,
    [Enum.KeyCode.KeypadSix] = 6, [Enum.KeyCode.KeypadSeven] = 7,
    [Enum.KeyCode.KeypadEight] = 8, [Enum.KeyCode.KeypadNine] = 9,
}

-- ════════════════════════════════════════════════════════════════════════════════
-- UTILITÁRIOS GERAIS & NOTIFICAÇÕES TOAST ANIMADAS
-- ════════════════════════════════════════════════════════════════════════════════
local function tweenObj(obj, props, dur, style, dir)
    if not obj then
        return nil
    end
    local ti = TweenInfo.new(
        dur or 0.18,
        style or Enum.EasingStyle.Quad,
        dir or Enum.EasingDirection.Out
    )
    local tw = TweenService:Create(obj, ti, props)
    tw:Play()
    return tw
end

local function avisar(titulo, msg, dur, tipo)
    if config.modoSilencioso then
        return
    end
    dur = dur or 2.6

    if UI.toastContainer and UI.toastContainer.Parent then
        local accentCol = temas[config.temaIndice].accent
        if tipo == "warn" or tostring(titulo):find("⚠️") or tostring(titulo):find("🚨") then
            accentCol = Color3.fromRGB(239, 68, 68)
        elseif tipo == "ok" or tostring(titulo):find("ATIVAD") or tostring(titulo):find("Salvo") then
            accentCol = Color3.fromRGB(16, 185, 129)
        end

        local existing = {}
        for _, ch in ipairs(UI.toastContainer:GetChildren()) do
            if ch:IsA("Frame") then
                table.insert(existing, ch)
            end
        end
        if #existing >= 5 then
            existing[1]:Destroy()
        end

        local toast = Instance.new("Frame")
        toast.Size                   = UDim2.new(1, 0, 0, 52)
        toast.BackgroundColor3       = Color3.fromRGB(12, 15, 24)
        toast.BackgroundTransparency = 0.08
        toast.BorderSizePixel        = 0
        toast.ClipsDescendants       = true
        toast.Parent                 = UI.toastContainer

        local tc = Instance.new("UICorner")
        tc.CornerRadius = UDim.new(0, 8)
        tc.Parent       = toast

        local ts = Instance.new("UIStroke")
        ts.Color        = accentCol
        ts.Thickness    = 1.2
        ts.Transparency = 0.25
        ts.Parent       = toast

        local bar = Instance.new("Frame")
        bar.Size             = UDim2.new(0, 4, 1, 0)
        bar.BackgroundColor3 = accentCol
        bar.BorderSizePixel  = 0
        bar.Parent           = toast

        local tTit = Instance.new("TextLabel")
        tTit.Size                   = UDim2.new(1, -16, 0, 18)
        tTit.Position               = UDim2.new(0, 11, 0, 5)
        tTit.BackgroundTransparency = 1
        tTit.Font                   = Enum.Font.GothamBold
        tTit.TextSize               = 11
        tTit.TextColor3             = Color3.fromRGB(245, 248, 255)
        tTit.TextXAlignment         = Enum.TextXAlignment.Left
        tTit.TextTruncate           = Enum.TextTruncate.AtEnd
        tTit.Text                   = tostring(titulo)
        tTit.Parent                 = toast

        local tMsg = Instance.new("TextLabel")
        tMsg.Size                   = UDim2.new(1, -16, 0, 20)
        tMsg.Position               = UDim2.new(0, 11, 0, 23)
        tMsg.BackgroundTransparency = 1
        tMsg.Font                   = Enum.Font.Gotham
        tMsg.TextSize               = 9.5
        tMsg.TextColor3             = Color3.fromRGB(170, 185, 210)
        tMsg.TextXAlignment         = Enum.TextXAlignment.Left
        tMsg.TextTruncate           = Enum.TextTruncate.AtEnd
        tMsg.Text                   = tostring(msg or "")
        tMsg.Parent                 = toast

        local prog = Instance.new("Frame")
        prog.Size             = UDim2.new(1, 0, 0, 2)
        prog.Position         = UDim2.new(0, 0, 1, -2)
        prog.BackgroundColor3 = accentCol
        prog.BorderSizePixel  = 0
        prog.Parent           = toast

        toast.BackgroundTransparency = 1
        tweenObj(toast, {BackgroundTransparency = 0.08}, 0.18)
        tweenObj(prog, {Size = UDim2.new(0, 0, 0, 2)}, dur, Enum.EasingStyle.Linear)

        task.delay(dur, function()
            if toast and toast.Parent then
                local tw = tweenObj(toast, {BackgroundTransparency = 1}, 0.18)
                if tw then
                    tw.Completed:Wait()
                end
                if toast and toast.Parent then
                    toast:Destroy()
                end
            end
        end)
    else
        pcall(function()
            StarterGui:SetCore("SendNotification", {
                Title    = titulo,
                Text     = msg,
                Duration = dur,
            })
        end)
    end
end

local function setToggleVisual(key, ativo)
    local info = UI.toggles[key]
    if not info then
        return
    end
    info.isAtivo = ativo
    local corAtiva = info.cor or temas[config.temaIndice].accent
    if info.pill and info.knob then
        tweenObj(info.pill, {
            BackgroundColor3 = ativo and corAtiva or Color3.fromRGB(36, 44, 62)
        }, 0.16)
        tweenObj(info.knob, {
            Position = ativo and UDim2.new(1, -18, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
        }, 0.16)
    end
    if info.stroke then
        tweenObj(info.stroke, {
            Color = ativo and corAtiva or Color3.fromRGB(34, 44, 64)
        }, 0.16)
    end
    if info.subLbl then
        info.subLbl.Text = ativo and ("● ATIVO  •  " .. info.baseSub) or info.baseSub
        info.subLbl.TextColor3 = ativo and Color3.fromRGB(110, 255, 165) or Color3.fromRGB(148, 163, 184)
    end
end

local function obterRootAtivo()
    if config.modoAstralAtivo and state.copiaPersonagem and state.copiaPersonagem.Parent then
        return state.copiaPersonagem:FindFirstChild("HumanoidRootPart")
    end
    local c = player.Character
    return c and c:FindFirstChild("HumanoidRootPart")
end

local function obterHumAtivo()
    if config.modoAstralAtivo and state.copiaPersonagem and state.copiaPersonagem.Parent then
        return state.copiaPersonagem:FindFirstChildOfClass("Humanoid")
    end
    local c = player.Character
    return c and c:FindFirstChildOfClass("Humanoid")
end

local function obterCharAtivo()
    if config.modoAstralAtivo and state.copiaPersonagem and state.copiaPersonagem.Parent then
        return state.copiaPersonagem
    end
    return player.Character
end

-- ════════════════════════════════════════════════════════════════════════════════
-- GERENCIADOR DE PERFIS MÚLTIPLOS (SLOT A / B / C EM JSON)
-- ════════════════════════════════════════════════════════════════════════════════
function F.getProfileFileName(slotName)
    return "SuiteAstralV12_Perfil_" .. (slotName or "A") .. ".json"
end

function F.salvarPerfilJSON(slotName)
    if not writefile then
        avisar("⚠️ Perfil", "Executor sem suporte a writefile().", 3, "warn")
        return false
    end
    local fileName = F.getProfileFileName(slotName)
    local data = {
        config = {},
        teclas = {},
    }
    local skip = {
        checkpointPos     = true,
        alvoOrbit         = true,
        alvoFollow        = true,
        modoAstralAtivo   = true,
        cameraLivreAtiva  = true,
        macroGravando     = true,
        macroReproduzindo = true,
    }
    for k, v in pairs(config) do
        if not skip[k] and (type(v) == "number" or type(v) == "boolean" or type(v) == "string") then
            data.config[k] = v
        end
    end
    for k, v in pairs(teclasConfig) do
        data.teclas[k] = v and v.Name or "NONE"
    end
    local ok, err = pcall(function()
        writefile(fileName, HttpService:JSONEncode(data))
    end)
    if ok then
        avisar("💾 Perfil " .. (slotName or "A") .. " Salvo", fileName, 2.5, "ok")
    else
        avisar("⚠️ Erro ao Salvar", tostring(err), 3, "warn")
    end
    return ok
end

function F.carregarPerfilJSON(slotName, silencioso)
    local fileName = F.getProfileFileName(slotName)
    if not (readfile and isfile and isfile(fileName)) then
        if not silencioso then
            avisar("⚠️ Perfil " .. (slotName or "A"), "Arquivo não encontrado.", 2.5, "warn")
        end
        return false
    end
    local ok, decoded = pcall(function()
        return HttpService:JSONDecode(readfile(fileName))
    end)
    if ok and type(decoded) == "table" then
        if type(decoded.config) == "table" then
            for k, v in pairs(decoded.config) do
                if config[k] ~= nil and type(config[k]) == type(v) then
                    config[k] = v
                end
            end
        end
        if type(decoded.teclas) == "table" then
            for k, name in pairs(decoded.teclas) do
                if name == "NONE" then
                    teclasConfig[k] = nil
                elseif Enum.KeyCode[name] then
                    teclasConfig[k] = Enum.KeyCode[name]
                end
            end
        end
        if not silencioso then
            avisar("📂 Perfil " .. (slotName or "A") .. " Carregado", "Configurações restauradas!", 2.5, "ok")
        end
        return true
    end
    return false
end

-- ════════════════════════════════════════════════════════════════════════════════
-- MOTOR DE ANIMAÇÕES, AVATAR & EMOTES V12.0
-- ════════════════════════════════════════════════════════════════════════════════
function F.formatarId(id)
    if not id then
        return nil
    end
    local s = tostring(id):gsub("%s+", "")
    if s == "" or s == "0" then
        return nil
    end
    local num = s:match("%d+")
    if num then
        return "rbxassetid://" .. num
    end
    return s
end

function F.extrairAnimId(pastaNome, nomeAnim)
    local char = player.Character
    if not char then
        return nil
    end
    local animateScript = char:FindFirstChild("Animate")
    local pasta = animateScript and animateScript:FindFirstChild(pastaNome)
    if pasta then
        local anim = pasta:FindFirstChild(nomeAnim)
        if anim and anim:IsA("Animation") and anim.AnimationId ~= "" then
            return F.formatarId(anim.AnimationId)
        end
        for _, ch in ipairs(pasta:GetChildren()) do
            if ch:IsA("Animation") and ch.AnimationId ~= "" then
                return F.formatarId(ch.AnimationId)
            elseif ch:IsA("StringValue") and ch.Value ~= "" then
                return F.formatarId(ch.Value)
            end
        end
    end
    return nil
end

function F.obterAnimIdAtiva(keyword)
    local char = player.Character
    local h = char and char:FindFirstChildOfClass("Humanoid")
    if h then
        for _, t in ipairs(h:GetPlayingAnimationTracks()) do
            if t.Name:lower():find(keyword) and t.Animation and t.Animation.AnimationId ~= "" then
                return F.formatarId(t.Animation.AnimationId)
            end
        end
    end
    return nil
end

function F.limparAnimTracks()
    for _, track in pairs(state.animTracks) do
        pcall(function()
            track:Stop()
            track:Destroy()
        end)
    end
    table.clear(state.animTracks)
end

function F.configurarAnimacoes(modelo, humAlvo)
    if not modelo or not humAlvo then
        return
    end
    F.limparAnimTracks()

    local cAnimator = humAlvo:FindFirstChildOfClass("Animator")
    if not cAnimator then
        cAnimator = Instance.new("Animator")
        cAnimator.Parent = humAlvo
    end
    for _, trk in ipairs(cAnimator:GetPlayingAnimationTracks()) do
        pcall(function()
            trk:Stop()
        end)
    end

    local isR15 = (modelo:FindFirstChild("UpperTorso")) ~= nil
    local runId  = F.obterAnimIdAtiva("run") or F.obterAnimIdAtiva("walk") or F.extrairAnimId("run", "RunAnim") or F.extrairAnimId("walk", "WalkAnim") or (isR15 and "rbxassetid://507767714" or "rbxassetid://180426354")
    local idleId = F.obterAnimIdAtiva("idle") or F.extrairAnimId("idle", "Animation1") or (isR15 and "rbxassetid://507766666" or "rbxassetid://180435571")
    local jumpId = F.obterAnimIdAtiva("jump") or F.extrairAnimId("jump", "JumpAnim") or (isR15 and "rbxassetid://507765000" or "rbxassetid://125750702")
    local fallId = F.obterAnimIdAtiva("fall") or F.extrairAnimId("fall", "FallAnim") or (isR15 and "rbxassetid://507767968" or "rbxassetid://180436148")

    local function carregar(id, prioridade, looped)
        id = F.formatarId(id)
        if not id or id == "" then
            return nil
        end
        local aObj = Instance.new("Animation")
        aObj.AnimationId = id
        local ok, trk = pcall(function()
            return cAnimator:LoadAnimation(aObj)
        end)
        if ok and trk then
            trk.Priority = prioridade or Enum.AnimationPriority.Action4
            trk.Looped = (looped ~= false)
            return trk
        end
        return nil
    end

    state.animTracks.run  = carregar(runId,  Enum.AnimationPriority.Action4, true)
    state.animTracks.idle = carregar(idleId, Enum.AnimationPriority.Action4, true)
    state.animTracks.jump = carregar(jumpId, Enum.AnimationPriority.Action4, false)
    state.animTracks.fall = carregar(fallId, Enum.AnimationPriority.Action4, true)

    if state.animTracks.idle then
        state.animTracks.idle:Play(0.1)
    end
end

local emotesCatalogo = {
    {nome = "💃 Dança Clássica", idR15 = "507771019", idR6 = "182435998"},
    {nome = "👋 Acenar (Wave)",  idR15 = "507770239", idR6 = "128777973"},
    {nome = "😂 Rir (Laugh)",    idR15 = "507770818", idR6 = "129423131"},
    {nome = "🎉 Comemorar",      idR15 = "507770677", idR6 = "129423030"},
    {nome = "👉 Apontar",        idR15 = "507770453", idR6 = "128853357"},
    {nome = "🧘 Levitar",        idR15 = "616006778", idR6 = "180435571"},
    {nome = "🧟 Zumbi",          idR15 = "616158929", idR6 = "180435571"},
    {nome = "🥷 Ninja Idle",     idR15 = "656117400", idR6 = "180435571"},
}

function F.pararEmoteAtual()
    if state.customAnimTrack then
        pcall(function()
            state.customAnimTrack:Stop()
            state.customAnimTrack:Destroy()
        end)
        state.customAnimTrack = nil
    end
end

function F.tocarAnimacaoPorId(rawId, nomeExib)
    F.pararEmoteAtual()
    local hum = obterHumAtivo()
    local char = obterCharAtivo()
    if not hum or not char then
        return
    end
    local fmt = F.formatarId(rawId)
    if not fmt then
        avisar("⚠️ Animação", "ID inválido!", 2, "warn")
        return
    end
    local animator = hum:FindFirstChildOfClass("Animator") or Instance.new("Animator", hum)
    local animObj = Instance.new("Animation")
    animObj.AnimationId = fmt
    local ok, trk = pcall(function()
        return animator:LoadAnimation(animObj)
    end)
    if ok and trk then
        trk.Priority = Enum.AnimationPriority.Action4
        trk.Looped = true
        trk:Play(0.15)
        state.customAnimTrack = trk
        avisar("🎭 Emote Ativo", nomeExib or fmt, 2)
    else
        avisar("⚠️ Animação", "Não foi possível carregar este ID.", 2.5, "warn")
    end
end

function F.aplicarHeadlessClient()
    local char = player.Character
    local head = char and char:FindFirstChild("Head")
    if head then
        head.Transparency = 1
        for _, d in ipairs(head:GetChildren()) do
            if d:IsA("Decal") then
                d.Transparency = 1
            end
        end
        avisar("🎃 Headless (Client)", "Cabeça ocultada localmente!")
    end
end

function F.removerAcessoriosClient()
    local char = player.Character
    if not char then
        return
    end
    local cnt = 0
    for _, acc in ipairs(char:GetChildren()) do
        if acc:IsA("Accessory") then
            acc:Destroy()
            cnt = cnt + 1
        end
    end
    avisar("🧢 Acessórios", cnt .. " acessórios removidos (client)!")
end

function F.alternarAuraParticulas()
    config.auraParticulasAtiva = not config.auraParticulasAtiva
    if state.auraEmitter and state.auraEmitter.Parent then
        state.auraEmitter:Destroy()
        state.auraEmitter = nil
    end
    if config.auraParticulasAtiva then
        local root = obterRootAtivo()
        if root then
            local pe = Instance.new("ParticleEmitter")
            pe.Name         = "SuiteV12AuraParticles"
            pe.Color        = ColorSequence.new(temas[config.temaIndice].accent, temas[config.temaIndice].glow)
            pe.Size         = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.4), NumberSequenceKeypoint.new(1, 0)})
            pe.Lifetime     = NumberRange.new(0.6, 1.2)
            pe.Rate         = 35
            pe.Speed        = NumberRange.new(2, 5)
            pe.SpreadAngle  = Vector2.new(180, 180)
            pe.LightEmission = 1
            pe.Parent       = root
            state.auraEmitter = pe
        end
    end
    setToggleVisual("aurapart", config.auraParticulasAtiva)
end

-- ════════════════════════════════════════════════════════════════════════════════
-- SISTEMAS DE FÍSICA, MOBILIDADE & PARKOUR V12.0
-- ════════════════════════════════════════════════════════════════════════════════
function F.alternarModoAstral()
    config.modoAstralAtivo = not config.modoAstralAtivo
    local charReal = player.Character
    if not charReal then
        config.modoAstralAtivo = false
        return
    end
    local realRoot = charReal:FindFirstChild("HumanoidRootPart")
    local realHum  = charReal:FindFirstChildOfClass("Humanoid")
    if not realRoot or not realHum then
        config.modoAstralAtivo = false
        return
    end

    if config.modoAstralAtivo then
        local cframeAtual = realRoot.CFrame
        state.plataformaCeu.CFrame = CFrame.new(cframeAtual.X, config.alturaCeu, cframeAtual.Z)
        charReal.Archivable = true
        local clone = charReal:Clone()
        clone.Name = player.Name .. "_AstralClone"
        for _, s in ipairs(clone:GetDescendants()) do
            if s:IsA("Script") or s:IsA("LocalScript") then
                s:Destroy()
            end
        end
        local cHum  = clone:FindFirstChildOfClass("Humanoid")
        local cRoot = clone:FindFirstChild("HumanoidRootPart")
        if cHum and cRoot then
            cHum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
            cHum.HealthDisplayType   = Enum.HumanoidHealthDisplayType.AlwaysOff
            cHum.WalkSpeed           = config.velocidadePadrao
            cHum.PlatformStand       = false
            clone.Parent             = Workspace
            clone:PivotTo(cframeAtual)
            state.copiaPersonagem = clone
            F.configurarAnimacoes(clone, cHum)
            camera.CameraSubject = cHum
        end
        realHum.PlatformStand            = true
        realRoot.AssemblyLinearVelocity  = Vector3.zero
        realRoot.AssemblyAngularVelocity = Vector3.zero
        realRoot.CFrame = CFrame.new(cframeAtual.X, config.alturaCeu + 3.5, cframeAtual.Z)
        atualizarRayParams()
        setToggleVisual("astral", true)
        avisar("👻 Modo Astral: ATIVADO", "Corpo blindado a +" .. config.alturaCeu .. " studs!")
    else
        if state.copiaPersonagem and state.copiaPersonagem.Parent then
            local cRoot = state.copiaPersonagem:FindFirstChild("HumanoidRootPart")
            if cRoot and realRoot then
                realRoot.AssemblyLinearVelocity  = Vector3.zero
                realRoot.AssemblyAngularVelocity = Vector3.zero
                realRoot.CFrame = cRoot.CFrame
            end
            state.copiaPersonagem:Destroy()
        end
        state.copiaPersonagem      = nil
        realHum.PlatformStand      = false
        camera.CameraSubject       = realHum
        state.plataformaCeu.CFrame = CFrame.new(0, -9999, 0)
        F.limparAnimTracks()
        atualizarRayParams()
        setToggleVisual("astral", false)
        avisar("👻 Modo Astral: DESATIVADO", "Retornado ao corpo físico.")
    end
end

function F.alternarVoo()
    config.vooAtivo = not config.vooAtivo
    local r = obterRootAtivo()
    if r then
        r.AssemblyLinearVelocity  = Vector3.zero
        r.AssemblyAngularVelocity = Vector3.zero
    end
    setToggleVisual("voo", config.vooAtivo)
    avisar(
        config.vooAtivo and "🦅 Voo: ATIVADO" or "🦅 Voo: DESATIVADO",
        config.velocidadeVoo .. " st/s (Shift Turbo)"
    )
end

function F.alternarAndarParedes()
    config.andarParedesAtivo = not config.andarParedesAtivo
    if not config.andarParedesAtivo then
        local h = obterHumAtivo()
        if h then
            h.PlatformStand = false
        end
    end
    setToggleVisual("paredes", config.andarParedesAtivo)
    avisar(
        config.andarParedesAtivo and "🧗 Paredes 360°: ATIVADO" or "🧗 Paredes 360°: DESATIVADO",
        "Física de superfície"
    )
end

function F.alternarPuloInfinito()
    config.puloInfinitoAtivo = not config.puloInfinitoAtivo
    setToggleVisual("pulo", config.puloInfinitoAtivo)
end

function F.alternarFreeze()
    config.freezeAtivo = not config.freezeAtivo
    local r = obterRootAtivo()
    if r then
        r.Anchored                = config.freezeAtivo
        r.AssemblyLinearVelocity  = Vector3.zero
        r.AssemblyAngularVelocity = Vector3.zero
    end
    setToggleVisual("freeze", config.freezeAtivo)
end

function F.salvarCheckpoint()
    local r = obterRootAtivo()
    if r then
        config.checkpointPos = r.CFrame
        avisar(
            "💾 Checkpoint Gravado",
            string.format("X:%.0f Y:%.0f Z:%.0f", r.Position.X, r.Position.Y, r.Position.Z)
        )
    else
        avisar("⚠️ Checkpoint", "Personagem não encontrado.", 2.5, "warn")
    end
end

function F.carregarCheckpoint()
    local r = obterRootAtivo()
    if not r then
        avisar("⚠️ Checkpoint", "Personagem não encontrado.", 2.5, "warn")
        return
    end
    if not config.checkpointPos then
        F.salvarCheckpoint()
        return
    end
    local char = obterCharAtivo()
    if char then
        char:PivotTo(config.checkpointPos)
    else
        r.CFrame = config.checkpointPos
    end
    r.AssemblyLinearVelocity  = Vector3.zero
    r.AssemblyAngularVelocity = Vector3.zero
    avisar("⚡ Checkpoint", "Teleportado para o ponto salvo!")
end

function F.dispararGrapple()
    local r   = obterRootAtivo()
    local hit = mouse.Hit
    if not r or not hit then
        return
    end
    local targetPos = hit.Position
    local dist      = (targetPos - r.Position).Magnitude
    if dist < 4 or dist > 1500 then
        avisar("🪝 Grapple", "Alvo fora de alcance", 1.5, "warn")
        return
    end
    local beamPart = Instance.new("Part")
    beamPart.Name       = "SuiteV12GrappleBeam"
    beamPart.Anchored   = true
    beamPart.CanCollide = false
    beamPart.Material   = Enum.Material.Neon
    beamPart.Color      = temas[config.temaIndice].accent
    beamPart.Size       = Vector3.new(0.28, 0.28, dist)
    beamPart.CFrame     = CFrame.new(r.Position:Lerp(targetPos, 0.5), targetPos)
    beamPart.Parent     = Workspace
    table.insert(state.grappleBeams, beamPart)

    r.AssemblyLinearVelocity = (targetPos - r.Position).Unit * math.clamp(dist * 2.2, 75, 280) + Vector3.new(0, 18, 0)
    task.delay(0.5, function()
        if beamPart and beamPart.Parent then
            beamPart:Destroy()
        end
    end)
end

function F.soltarSpiderSwing()
    if state.swingRope then pcall(function() state.swingRope:Destroy() end) state.swingRope = nil end
    if state.swingAttach0 then pcall(function() state.swingAttach0:Destroy() end) state.swingAttach0 = nil end
    if state.swingAttach1 then pcall(function() state.swingAttach1:Destroy() end) state.swingAttach1 = nil end
    if state.swingAnchorPart then pcall(function() state.swingAnchorPart:Destroy() end) state.swingAnchorPart = nil end
end

function F.dispararSpiderSwing()
    if state.swingRope then
        F.soltarSpiderSwing()
        avisar("🕸️ Swing", "Teia solta!", 1)
        return
    end
    local r   = obterRootAtivo()
    local hit = mouse.Hit
    if not r or not hit then
        return
    end
    local dist = (hit.Position - r.Position).Magnitude
    if dist < 6 or dist > 600 then
        avisar("🕸️ Swing", "Alvo fora de alcance (6–600 st)", 1.5, "warn")
        return
    end
    local anchor = Instance.new("Part")
    anchor.Name         = "SuiteV12SwingAnchor"
    anchor.Anchored     = true
    anchor.CanCollide   = false
    anchor.Transparency = 1
    anchor.Size         = Vector3.new(1, 1, 1)
    anchor.CFrame       = CFrame.new(hit.Position)
    anchor.Parent       = Workspace

    local a0 = Instance.new("Attachment", r)
    local a1 = Instance.new("Attachment", anchor)
    local rope = Instance.new("RopeConstraint")
    rope.Attachment0  = a0
    rope.Attachment1  = a1
    rope.Length       = math.max(dist * 0.85, 6)
    rope.Visible      = true
    rope.Thickness    = 0.22
    rope.Color        = BrickColor.new(temas[config.temaIndice].accent)
    rope.Parent       = r

    state.swingAnchorPart = anchor
    state.swingAttach0    = a0
    state.swingAttach1    = a1
    state.swingRope       = rope
    avisar("🕸️ Spider Swing", "Conectado! Pressione novamente para soltar.", 1.5)
end

function F.alternarMagicFloor()
    config.magicFloorAtivo = not config.magicFloorAtivo
    local r = obterRootAtivo()
    if config.magicFloorAtivo and r then
        if not state.magicFloorPart or not state.magicFloorPart.Parent then
            local mf = Instance.new("Part")
            mf.Name         = "SuiteV12MagicFloor"
            mf.Size         = Vector3.new(14, 1, 14)
            mf.Transparency = 0.48
            mf.Material     = Enum.Material.ForceField
            mf.Color        = temas[config.temaIndice].accent
            mf.Anchored     = true
            mf.CanCollide   = true
            mf.Parent       = Workspace
            state.magicFloorPart = mf
        end
        state.magicFloorY = r.Position.Y - 3.5
        state.magicFloorPart.CFrame = CFrame.new(r.Position.X, state.magicFloorY, r.Position.Z)
        atualizarRayParams()
        avisar("🔮 Magic Floor: ATIVADO", "Espaço sobe • Ctrl desce")
    else
        if state.magicFloorPart and state.magicFloorPart.Parent then
            state.magicFloorPart:Destroy()
        end
        state.magicFloorPart = nil
        state.magicFloorY    = nil
        atualizarRayParams()
        avisar("🔮 Magic Floor: DESATIVADO", "Piso removido.")
    end
    setToggleVisual("magicfloor", config.magicFloorAtivo)
end

function F.alternarElevador()
    config.elevadorAtivo = not config.elevadorAtivo
    local r = obterRootAtivo()
    if r then
        r.AssemblyLinearVelocity  = Vector3.zero
        r.AssemblyAngularVelocity = Vector3.zero
    end
    setToggleVisual("elevador", config.elevadorAtivo)
end

function F.alternarBhop()
    config.bhopAtivo = not config.bhopAtivo
    setToggleVisual("bhop", config.bhopAtivo)
end

function F.alternarJetpack()
    config.jetpackAtivo = not config.jetpackAtivo
    setToggleVisual("jetpack", config.jetpackAtivo)
    avisar(
        config.jetpackAtivo and "🚀 Jetpack: ATIVADO" or "🚀 Jetpack: DESATIVADO",
        "Segure Espaço para propulsão contínua!"
    )
end

function F.executarDash()
    if tick() - state.lastDash < 0.5 then
        return
    end
    state.lastDash = tick()
    local root = obterRootAtivo()
    if not root then
        return
    end
    local hum = obterHumAtivo()
    local moveDir
    if hum and hum.MoveDirection.Magnitude > 0.1 then
        moveDir = hum.MoveDirection
    else
        local lv = Vector3.new(camera.CFrame.LookVector.X, 0, camera.CFrame.LookVector.Z)
        moveDir = lv.Magnitude > 0.01 and lv.Unit or root.CFrame.LookVector
    end
    local trailPart = Instance.new("Part")
    trailPart.Size         = Vector3.new(3.5, 5.5, 3.5)
    trailPart.CFrame       = root.CFrame
    trailPart.Anchored     = true
    trailPart.CanCollide   = false
    trailPart.Material     = Enum.Material.Neon
    trailPart.Color        = temas[config.temaIndice].accent
    trailPart.Transparency = 0.35
    trailPart.Parent       = Workspace
    tweenObj(trailPart, {Transparency = 1, Size = Vector3.new(0.4, 0.4, 0.4)}, 0.4)
    task.delay(0.45, function()
        if trailPart and trailPart.Parent then
            trailPart:Destroy()
        end
    end)
    root.AssemblyLinearVelocity = moveDir * (config.dashForca or 85) + Vector3.new(0, 12, 0)
end

function F.executarBlinkDash()
    local root = obterRootAtivo()
    local char = obterCharAtivo()
    if not root or not char then
        return
    end
    local look = Vector3.new(camera.CFrame.LookVector.X, 0, camera.CFrame.LookVector.Z)
    local dir  = look.Magnitude > 0.01 and look.Unit or root.CFrame.LookVector
    local targetCF = root.CFrame + (dir * (config.blinkDist or 35))
    char:PivotTo(targetCF)
    root.AssemblyLinearVelocity = Vector3.zero
    avisar("⚡ Blink Dash", "Avanço instantâneo de " .. (config.blinkDist or 35) .. " studs!", 1)
end

function F.alternarSuperPulo()
    config.superPuloAtivo = not config.superPuloAtivo
    local hum = obterHumAtivo()
    if hum then
        hum.UseJumpPower = true
        hum.JumpPower = config.superPuloAtivo and (config.superPuloForca or 120) or 50
    end
    setToggleVisual("superpulo", config.superPuloAtivo)
end

function F.alternarAutoWalk()
    config.autoWalkAtivo = not config.autoWalkAtivo
    setToggleVisual("autowalk", config.autoWalkAtivo)
end

function F.alternarSpiderClimb()
    config.spiderClimbAtivo = not config.spiderClimbAtivo
    setToggleVisual("spiderclimb", config.spiderClimbAtivo)
end

function F.alternarSpinbot()
    config.spinbotAtivo = not config.spinbotAtivo
    setToggleVisual("spinbot", config.spinbotAtivo)
end

function F.alternarAirSwim()
    config.airSwimAtivo = not config.airSwimAtivo
    local hum = obterHumAtivo()
    if hum then
        hum:SetStateEnabled(Enum.HumanoidStateType.Swimming, true)
        if config.airSwimAtivo then
            hum:ChangeState(Enum.HumanoidStateType.Swimming)
        end
    end
    setToggleVisual("airswim", config.airSwimAtivo)
end

function F.alternarVehicleBoost()
    config.vehicleBoostAtivo = not config.vehicleBoostAtivo
    setToggleVisual("vehboost", config.vehicleBoostAtivo)
end

function F.alternarPathTrail()
    config.pathTrailAtivo = not config.pathTrailAtivo
    setToggleVisual("pathtrail", config.pathTrailAtivo)
end

function F.alternarAutoVault()
    config.autoVaultAtivo = not config.autoVaultAtivo
    setToggleVisual("autovault", config.autoVaultAtivo)
end

-- MACRO RECORDER PRO
function F.alternarMacroGravar()
    config.macroGravando = not config.macroGravando
    if config.macroGravando then
        config.macroReproduzindo = false
        setToggleVisual("macroplay", false)
        table.clear(state.macroFrames)
        state.macroRecordTimer = 0
        avisar("⏺️ Macro: GRAVANDO", "Ande pelo mapa para gravar a rota!", 2.5, "ok")
    else
        avisar("⏹️ Macro: GRAVADO", #state.macroFrames .. " waypoints capturados!", 2.5)
    end
    setToggleVisual("macrorec", config.macroGravando)
    if UI.macroCountLbl then
        UI.macroCountLbl.Text = "🎞️ Waypoints gravados: " .. #state.macroFrames
    end
end

function F.alternarMacroPlay()
    if #state.macroFrames == 0 then
        avisar("⚠️ Macro Vazio", "Grave uma rota primeiro!", 2.5, "warn")
        config.macroReproduzindo = false
        setToggleVisual("macroplay", false)
        return
    end
    config.macroReproduzindo = not config.macroReproduzindo
    if config.macroReproduzindo then
        config.macroGravando = false
        setToggleVisual("macrorec", false)
        state.macroPlayIdx = config.macroReverso and #state.macroFrames or 1
        avisar("▶️ Macro: REPRODUZINDO", #state.macroFrames .. " waypoints")
    else
        avisar("⏸️ Macro: PAUSADO", "Reprodução interrompida")
    end
    setToggleVisual("macroplay", config.macroReproduzindo)
end

function F.limparMacro()
    config.macroGravando     = false
    config.macroReproduzindo = false
    setToggleVisual("macrorec", false)
    setToggleVisual("macroplay", false)
    table.clear(state.macroFrames)
    if UI.macroCountLbl then
        UI.macroCountLbl.Text = "🎞️ Waypoints gravados: 0"
    end
    avisar("🗑️ Macro Limpo", "Rota apagada.")
end

function F.alternarCameraLivre()
    config.cameraLivreAtiva = not config.cameraLivreAtiva
    if config.cameraLivreAtiva then
        state.cameraOriginalSubject = camera.CameraSubject
        state.freeCamCFrame = camera.CFrame
        local rx, ry, _ = camera.CFrame:ToEulerAnglesYXZ()
        state.freeCamPitch = rx
        state.freeCamYaw   = ry
        camera.CameraType  = Enum.CameraType.Scriptable
        setToggleVisual("freecam", true)
        avisar("🎥 Câmera Livre: ATIVADA", "WASD + Botão Direito para olhar")
    else
        state.freeCamRotating = false
        UserInputService.MouseBehavior = Enum.MouseBehavior.Default
        camera.CameraType    = Enum.CameraType.Custom
        camera.CameraSubject = obterHumAtivo() or state.cameraOriginalSubject
        setToggleVisual("freecam", false)
    end
end

function F.alternarInvisibilidade()
    config.invisibilidadeAtiva = not config.invisibilidadeAtiva
    local char = obterCharAtivo()
    if not char then
        return
    end
    if config.invisibilidadeAtiva then
        table.clear(state.invisOriginal)
        for _, p in ipairs(char:GetDescendants()) do
            if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then
                state.invisOriginal[p] = {t = p.Transparency, s = p.CastShadow}
                p.Transparency = 1
                p.CastShadow   = false
            elseif p:IsA("Decal") then
                state.invisOriginal[p] = {t = p.Transparency}
                p.Transparency = 1
            end
        end
    else
        for p, orig in pairs(state.invisOriginal) do
            if p and p.Parent then
                p.Transparency = orig.t
                if p:IsA("BasePart") and orig.s ~= nil then
                    p.CastShadow = orig.s
                end
            end
        end
        table.clear(state.invisOriginal)
    end
    setToggleVisual("invisivel", config.invisibilidadeAtiva)
end

-- ════════════════════════════════════════════════════════════════════════════════
-- COMBATE & MIRA AVANÇADA V12.0
-- ════════════════════════════════════════════════════════════════════════════════
function F.alternarAimbot()
    config.aimbotAtivo = not config.aimbotAtivo
    if UI.fovCircle then
        UI.fovCircle.Visible = config.aimbotAtivo and config.aimbotShowFov
    end
    setToggleVisual("aimbot", config.aimbotAtivo)
    avisar(
        config.aimbotAtivo and "🎯 Aimbot Pro: ATIVADO" or "🎯 Aimbot Pro: DESATIVADO",
        "Segure Botão Direito para travar mira"
    )
end

function F.obterAlvoAimbot()
    local camPos = camera.CFrame.Position
    local center = Vector2.new(camera.ViewportSize.X * 0.5, camera.ViewportSize.Y * 0.5)
    local bestTarget, bestDist = nil, config.aimbotFov
    atualizarRayParams()

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= player and p.Character then
            local sameTeam = config.aimbotTeamCheck and player.Team and p.Team and (player.Team == p.Team)
            local hum  = p.Character:FindFirstChildOfClass("Humanoid")
            local part = p.Character:FindFirstChild(config.aimbotParte) or p.Character:FindFirstChild("HumanoidRootPart")
            if not sameTeam and hum and hum.Health > 0 and part then
                local screenPos, onScreen = camera:WorldToViewportPoint(part.Position)
                if onScreen then
                    local dist2D = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                    if dist2D < bestDist then
                        local visivel = true
                        if config.aimbotWallCheck then
                            local ray = Workspace:Raycast(camPos, part.Position - camPos, rayParams)
                            if ray and ray.Instance and not ray.Instance:IsDescendantOf(p.Character) then
                                visivel = false
                            end
                        end
                        if visivel then
                            bestDist   = dist2D
                            bestTarget = part
                        end
                    end
                end
            end
        end
    end
    return bestTarget
end

function F.restaurarHitboxes()
    for part, orig in pairs(state.hitboxOriginal) do
        if part and part.Parent then
            pcall(function()
                part.Size         = orig.size
                part.Transparency = orig.transp
                part.CanCollide   = orig.cc
            end)
        end
    end
    table.clear(state.hitboxOriginal)
end

function F.aplicarHitboxExpander()
    if not config.hitboxAtivo then
        return
    end
    local sz = Vector3.new(config.hitboxTamanho, config.hitboxTamanho, config.hitboxTamanho)
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= player and p.Character then
            local hrp = p.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                if not state.hitboxOriginal[hrp] then
                    state.hitboxOriginal[hrp] = {size = hrp.Size, transp = hrp.Transparency, cc = hrp.CanCollide}
                end
                pcall(function()
                    hrp.Size         = sz
                    hrp.Transparency = config.hitboxTransp
                    hrp.CanCollide   = false
                    hrp.Material     = Enum.Material.Neon
                end)
            end
        end
    end
end

function F.alternarHitbox()
    config.hitboxAtivo = not config.hitboxAtivo
    if config.hitboxAtivo then
        F.aplicarHitboxExpander()
    else
        F.restaurarHitboxes()
    end
    setToggleVisual("hitbox", config.hitboxAtivo)
end

function F.alternarTriggerbot()
    config.triggerbotAtivo = not config.triggerbotAtivo
    setToggleVisual("triggerbot", config.triggerbotAtivo)
end

function F.alternarKillAura()
    config.killAuraAtivo = not config.killAuraAtivo
    setToggleVisual("killaura", config.killAuraAtivo)
end

function F.alternarAutoDodge()
    config.autoDodgeAtivo = not config.autoDodgeAtivo
    setToggleVisual("autododge", config.autoDodgeAtivo)
    avisar(
        config.autoDodgeAtivo and "💨 Auto-Dodge: ATIVADO" or "💨 Auto-Dodge: DESATIVADO",
        "Esquiva automaticamente se inimigo chegar perto"
    )
end

-- ════════════════════════════════════════════════════════════════════════════════
-- VISÃO, ESP PRO, SKELETON ESP & RADAR 2D V12.0
-- ════════════════════════════════════════════════════════════════════════════════
function F.alternarFullbright()
    config.fullbrightAtivo = not config.fullbrightAtivo
    if config.fullbrightAtivo then
        Lighting.FogEnd         = 9e9
        Lighting.Brightness     = 2
        Lighting.ClockTime      = 14
        Lighting.Ambient        = Color3.fromRGB(255, 255, 255)
        Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
    else
        Lighting.FogEnd         = config.noFogAtivo and 9e9 or originalLighting.FogEnd
        Lighting.Brightness     = originalLighting.Brightness
        Lighting.ClockTime      = config.timeOfDayAtivo and config.timeOfDayValor or originalLighting.ClockTime
        Lighting.Ambient        = originalLighting.Ambient
        Lighting.OutdoorAmbient = originalLighting.OutdoorAmbient
    end
    setToggleVisual("fullbright", config.fullbrightAtivo)
end

function F.alternarNoFog()
    config.noFogAtivo = not config.noFogAtivo
    Lighting.FogEnd = config.noFogAtivo and 9e9 or originalLighting.FogEnd
    local atmo = Lighting:FindFirstChildOfClass("Atmosphere")
    if atmo then
        atmo.Density = config.noFogAtivo and 0 or 0.3
    end
    setToggleVisual("nofog", config.noFogAtivo)
end

function F.ciclarFov()
    config.fovIndice = (config.fovIndice % #fovPresets) + 1
    camera.FieldOfView = fovPresets[config.fovIndice]
    avisar("🔭 FOV", camera.FieldOfView .. "°", 1.2)
end

function F.alternarDroneMode()
    config.droneModeAtivo = not config.droneModeAtivo
    if config.droneModeAtivo then
        state.droneOriginalMaxZoom = player.CameraMaxZoomDistance
        player.CameraMaxZoomDistance = 2000
    else
        player.CameraMaxZoomDistance = state.droneOriginalMaxZoom or 128
    end
    setToggleVisual("drone", config.droneModeAtivo)
end

function F.alternarXRay()
    config.xrayAtivo = not config.xrayAtivo
    local char = player.Character
    for _, part in ipairs(Workspace:GetDescendants()) do
        if part:IsA("BasePart") and (not char or not part:IsDescendantOf(char)) then
            if config.xrayAtivo then
                if part.Transparency < 0.85 then
                    if state.xrayOriginalTransp[part] == nil then
                        state.xrayOriginalTransp[part] = part.Transparency
                    end
                    part.Transparency = 0.65
                end
            elseif state.xrayOriginalTransp[part] ~= nil then
                part.Transparency = state.xrayOriginalTransp[part]
            end
        end
    end
    if not config.xrayAtivo then
        table.clear(state.xrayOriginalTransp)
    end
    setToggleVisual("xray", config.xrayAtivo)
end

function F.atualizarEstiloCrosshair()
    if not UI.crosshairFrame then
        return
    end
    local st = config.crosshairEstilo
    UI.crosshairH.Visible    = (st == 1 or st == 4)
    UI.crosshairV.Visible    = (st == 1 or st == 4)
    UI.crosshairDot.Visible  = (st == 1 or st == 2 or st == 3)
    UI.crosshairRing.Visible = (st == 3)
    if st == 4 then
        UI.crosshairV.Position = UDim2.new(0.5, -1, 0.5, 0)
        UI.crosshairV.Size     = UDim2.new(0, 2, 0, 10)
    else
        UI.crosshairV.Position = UDim2.new(0.5, -1, 0.5, -9)
        UI.crosshairV.Size     = UDim2.new(0, 2, 0, 18)
    end
end

function F.alternarCrosshair()
    config.crosshairAtivo = not config.crosshairAtivo
    if UI.crosshairFrame then
        UI.crosshairFrame.Visible = config.crosshairAtivo
        F.atualizarEstiloCrosshair()
    end
    setToggleVisual("crosshair", config.crosshairAtivo)
end

function F.limparSkeletonJogador(p)
    local sk = UI.skeletonLines[p]
    if sk then
        for _, line in ipairs(sk) do
            pcall(function()
                line:Destroy()
            end)
        end
        UI.skeletonLines[p] = nil
    end
end

function F.limparEspJogador(p)
    local it = state.espItens[p]
    if it then
        pcall(function()
            if it.highlight then it.highlight:Destroy() end
            if it.billboard then it.billboard:Destroy() end
        end)
        state.espItens[p] = nil
    end
    local bx = UI.esp2DBoxes[p]
    if bx then
        pcall(function()
            bx:Destroy()
        end)
        UI.esp2DBoxes[p] = nil
    end
    F.limparSkeletonJogador(p)
end

function F.alternarCorAura()
    config.corAuraIndice = (config.corAuraIndice % #coresAura) + 1
    local sel = coresAura[config.corAuraIndice]
    for _, item in pairs(state.espItens) do
        if item.highlight then
            item.highlight.FillColor    = sel.cor
            item.highlight.OutlineColor = sel.cor
        end
        if item.billboard and item.billboard:FindFirstChild("Texto") then
            item.billboard.Texto.TextColor3 = sel.cor
        end
    end
    for _, bx in pairs(UI.esp2DBoxes) do
        local st = bx:FindFirstChildOfClass("UIStroke")
        if st then
            st.Color = sel.cor
        end
    end
    if UI.corEspLblRef then
        UI.corEspLblRef.Text       = "🎨 Cor ESP Ativa: " .. sel.nome .. "  ● ● ●"
        UI.corEspLblRef.TextColor3 = sel.cor
    end
    avisar("🎨 Cor ESP", sel.nome, 1.4)
end

function F.atualizarEspJogador(p)
    if p == player then
        return
    end
    local char     = p.Character
    local sameTeam = config.espTeamCheck and player.Team and p.Team and (player.Team == p.Team)
    local root     = char and char:FindFirstChild("HumanoidRootPart")
    local hum      = char and char:FindFirstChildOfClass("Humanoid")
    local myRoot   = obterRootAtivo()
    local dist     = (myRoot and root) and (myRoot.Position - root.Position).Magnitude or 0

    if not config.espAtivo or not char or not root or not hum or sameTeam or dist > config.espMaxDist then
        if state.espItens[p] then
            pcall(function()
                if state.espItens[p].highlight then state.espItens[p].highlight:Destroy() end
                if state.espItens[p].billboard then state.espItens[p].billboard:Destroy() end
            end)
            state.espItens[p] = nil
        end
        return
    end

    local sel  = coresAura[config.corAuraIndice]
    local item = state.espItens[p]
    if not item or not item.highlight or not item.highlight.Parent then
        local hl = Instance.new("Highlight")
        hl.Name                = "V12_ESP_HL"
        hl.FillColor           = sel.cor
        hl.OutlineColor        = sel.cor
        hl.FillTransparency    = 0.52
        hl.OutlineTransparency = 0
        hl.Adornee             = char
        hl.Parent              = char

        local bb = Instance.new("BillboardGui")
        bb.Name        = "V12_ESP_BB"
        bb.Size        = UDim2.new(0, 190, 0, 52)
        bb.StudsOffset = Vector3.new(0, 3.5, 0)
        bb.AlwaysOnTop = true
        bb.Adornee     = root
        bb.Parent      = char

        local txt = Instance.new("TextLabel")
        txt.Name                   = "Texto"
        txt.Size                   = UDim2.new(1, 0, 0, 34)
        txt.BackgroundTransparency = 1
        txt.Font                   = Enum.Font.GothamBold
        txt.TextSize               = 10
        txt.TextColor3             = sel.cor
        txt.TextStrokeTransparency = 0.15
        txt.TextStrokeColor3       = Color3.fromRGB(0, 0, 0)
        txt.Parent                 = bb

        local hpBg = Instance.new("Frame")
        hpBg.Size             = UDim2.new(0.65, 0, 0, 4)
        hpBg.Position         = UDim2.new(0.175, 0, 0, 36)
        hpBg.BackgroundColor3 = Color3.fromRGB(20, 24, 34)
        hpBg.BorderSizePixel  = 0
        hpBg.Parent           = bb
        Instance.new("UICorner", hpBg).CornerRadius = UDim.new(1, 0)

        local hpFill = Instance.new("Frame")
        hpFill.Size             = UDim2.new(1, 0, 1, 0)
        hpFill.BackgroundColor3 = Color3.fromRGB(80, 255, 140)
        hpFill.BorderSizePixel  = 0
        hpFill.Parent           = hpBg
        Instance.new("UICorner", hpFill).CornerRadius = UDim.new(1, 0)

        item = {highlight = hl, billboard = bb, hpFill = hpFill}
        state.espItens[p] = item
    end

    local hpRatio = math.clamp(hum.Health / math.max(hum.MaxHealth, 1), 0, 1)
    local tool    = char:FindFirstChildOfClass("Tool")
    local toolStr = tool and (" [" .. tool.Name .. "]") or ""
    local txtLbl  = item.billboard:FindFirstChild("Texto")
    if txtLbl then
        txtLbl.Text = string.format("%s%s\n%.0fm • %d%% HP", p.DisplayName, toolStr, dist, math.floor(hpRatio * 100))
    end
    if item.hpFill then
        item.hpFill.Size = UDim2.new(hpRatio, 0, 1, 0)
        item.hpFill.BackgroundColor3 = hpRatio > 0.5 and Color3.fromRGB(80, 255, 140)
            or hpRatio > 0.25 and Color3.fromRGB(250, 204, 21)
            or Color3.fromRGB(239, 68, 68)
    end
end

function F.alternarEsp()
    config.espAtivo = not config.espAtivo
    if not config.espAtivo then
        for _, p in ipairs(Players:GetPlayers()) do
            if state.espItens[p] then
                pcall(function()
                    if state.espItens[p].highlight then state.espItens[p].highlight:Destroy() end
                    if state.espItens[p].billboard then state.espItens[p].billboard:Destroy() end
                end)
            end
        end
        table.clear(state.espItens)
    else
        for _, p in ipairs(Players:GetPlayers()) do
            F.atualizarEspJogador(p)
        end
    end
    setToggleVisual("esp", config.espAtivo)
end

function F.alternarEsp2D()
    config.esp2DBoxAtivo = not config.esp2DBoxAtivo
    if not config.esp2DBoxAtivo then
        for _, bx in pairs(UI.esp2DBoxes) do
            pcall(function()
                bx:Destroy()
            end)
        end
        table.clear(UI.esp2DBoxes)
    end
    setToggleVisual("esp2d", config.esp2DBoxAtivo)
end

function F.alternarEspSkeleton()
    config.espSkeletonAtivo = not config.espSkeletonAtivo
    if not config.espSkeletonAtivo then
        for p, _ in pairs(UI.skeletonLines) do
            F.limparSkeletonJogador(p)
        end
    end
    setToggleVisual("espskel", config.espSkeletonAtivo)
end

function F.alternarRadar2D()
    config.radar2DAtivo = not config.radar2DAtivo
    if UI.radarFrame then
        UI.radarFrame.Visible = config.radar2DAtivo
    end
    setToggleVisual("radar2d", config.radar2DAtivo)
end

function F.alternarTracers()
    config.tracersAtivo = not config.tracersAtivo
    if not config.tracersAtivo then
        for _, t in pairs(state.tracersCache) do
            pcall(function()
                t:Destroy()
            end)
        end
        table.clear(state.tracersCache)
    end
    setToggleVisual("tracers", config.tracersAtivo)
end

function F.alternarOutlineTracker()
    config.outlineTrackerAtivo = not config.outlineTrackerAtivo
    if not config.outlineTrackerAtivo and state.outlineBox then
        state.outlineBox:Destroy()
        state.outlineBox    = nil
        state.outlineTarget = nil
    end
    setToggleVisual("outline", config.outlineTrackerAtivo)
end

function F.limparRadarInteracoes()
    for _, bb in pairs(state.radarItens) do
        pcall(function()
            bb:Destroy()
        end)
    end
    table.clear(state.radarItens)
end

function F.atualizarRadarInteracoes()
    if not config.radarInteracoesAtivo then
        return
    end
    local root = obterRootAtivo()
    if not root then
        return
    end
    for obj, bb in pairs(state.radarItens) do
        if not obj or not obj.Parent or not bb or not bb.Parent then
            pcall(function()
                if bb then bb:Destroy() end
            end)
            state.radarItens[obj] = nil
        end
    end
    for _, desc in ipairs(Workspace:GetDescendants()) do
        if (desc:IsA("ProximityPrompt") and desc.Enabled) or desc:IsA("ClickDetector") then
            local adornee = desc.Parent
            if adornee and (adornee:IsA("BasePart") or adornee:IsA("Model")) then
                local pos  = adornee:IsA("BasePart") and adornee.Position or adornee:GetPivot().Position
                local dist = (pos - root.Position).Magnitude
                if dist <= 160 then
                    local bb = state.radarItens[desc]
                    if not bb then
                        bb = Instance.new("BillboardGui")
                        bb.Name        = "V12_RadarBB"
                        bb.Size        = UDim2.new(0, 150, 0, 28)
                        bb.StudsOffset = Vector3.new(0, 2.2, 0)
                        bb.AlwaysOnTop = true
                        bb.Adornee     = adornee
                        bb.Parent      = UI.screenGui

                        local lbl = Instance.new("TextLabel")
                        lbl.Name                   = "Lbl"
                        lbl.Size                   = UDim2.new(1, 0, 1, 0)
                        lbl.BackgroundColor3       = Color3.fromRGB(14, 18, 28)
                        lbl.BackgroundTransparency = 0.25
                        lbl.Font                   = Enum.Font.GothamBold
                        lbl.TextSize               = 9.5
                        lbl.TextColor3             = desc:IsA("ProximityPrompt") and Color3.fromRGB(251, 191, 36) or Color3.fromRGB(56, 189, 248)
                        lbl.Parent                 = bb
                        Instance.new("UICorner", lbl).CornerRadius = UDim.new(0, 5)
                        state.radarItens[desc] = bb
                    end
                    local lbl = bb:FindFirstChild("Lbl")
                    if lbl then
                        local tag = desc:IsA("ProximityPrompt") and ("⚡ " .. (desc.ActionText ~= "" and desc.ActionText or "Prompt")) or "🖱️ Click"
                        lbl.Text = string.format("%s (%.0fm)", tag, dist)
                    end
                elseif state.radarItens[desc] then
                    state.radarItens[desc]:Destroy()
                    state.radarItens[desc] = nil
                end
            end
        end
    end
end

function F.alternarRadarInteracoes()
    config.radarInteracoesAtivo = not config.radarInteracoesAtivo
    if not config.radarInteracoesAtivo then
        F.limparRadarInteracoes()
    else
        F.atualizarRadarInteracoes()
    end
    setToggleVisual("radar", config.radarInteracoesAtivo)
end

function F.alternarDetectorAuras()
    config.detectorAurasAtivo = not config.detectorAurasAtivo
    local char = player.Character
    for _, part in ipairs(Workspace:GetDescendants()) do
        if part:IsA("BasePart") and (not char or not part:IsDescendantOf(char)) and part.Transparency >= 0.85 then
            if config.detectorAurasAtivo then
                if state.aurasOriginais[part] == nil then
                    state.aurasOriginais[part] = part.Transparency
                end
                part.Transparency = 0.35
                local sb = Instance.new("SelectionBox")
                sb.Adornee = part
                sb.Color3  = Color3.fromRGB(244, 63, 94)
                sb.Parent  = part
                state.aurasBoxes[part] = sb
            else
                if state.aurasOriginais[part] ~= nil then
                    part.Transparency = state.aurasOriginais[part]
                end
                if state.aurasBoxes[part] then
                    state.aurasBoxes[part]:Destroy()
                    state.aurasBoxes[part] = nil
                end
            end
        end
    end
    if not config.detectorAurasAtivo then
        table.clear(state.aurasBoxes)
        table.clear(state.aurasOriginais)
    end
    setToggleVisual("auras", config.detectorAurasAtivo)
end

-- ════════════════════════════════════════════════════════════════════════════════
-- MUNDO, BUILDER & EXPLORER V12.0
-- ════════════════════════════════════════════════════════════════════════════════
function F.spawnarParte(forma)
    local r = obterRootAtivo()
    if not r then
        return
    end
    local sz = config.spawnerSize or 8
    local p
    if forma == "Ramp" then
        p = Instance.new("WedgePart")
        p.Size = Vector3.new(sz, sz * 0.7, sz * 1.5)
    elseif forma == "Seat" then
        p = Instance.new("Seat")
        p.Size = Vector3.new(3, 1.5, 3)
    elseif forma == "Truss" then
        p = Instance.new("TrussPart")
        p.Size = Vector3.new(2, sz * 2, 2)
    else
        p = Instance.new("Part")
        if forma == "Sphere" then
            p.Shape = Enum.PartType.Ball
            p.Size  = Vector3.new(sz, sz, sz)
        elseif forma == "Cylinder" then
            p.Shape = Enum.PartType.Cylinder
            p.Size  = Vector3.new(sz, sz, sz)
        elseif forma == "Platform" then
            p.Size = Vector3.new(sz * 2, 1.2, sz * 2)
        else
            p.Size = Vector3.new(sz, sz, sz)
        end
    end

    p.Name         = "SuiteV12Spawned_" .. forma
    p.Anchored     = config.spawnerAnchored
    p.CanCollide   = true
    p.Color        = temas[config.temaIndice].accent
    p.Material     = Enum.Material[config.spawnerMaterial] or Enum.Material.Neon
    p.Transparency = (config.spawnerMaterial == "ForceField") and 0.35 or 0
    p.CFrame       = r.CFrame * CFrame.new(0, 2, -(sz + 4))
    p.Parent       = Workspace

    table.insert(state.spawnedParts, p)
    atualizarRayParams()
    avisar("🧱 Spawner", forma .. " criada!")
end

function F.limparPartesSpawnadas()
    local cnt = 0
    for _, p in ipairs(state.spawnedParts) do
        if p and p.Parent then
            p:Destroy()
            cnt = cnt + 1
        end
    end
    table.clear(state.spawnedParts)
    atualizarRayParams()
    avisar("🧹 Spawner", cnt .. " partes removidas.")
end

function F.alternarVortex()
    config.vortexAtivo = not config.vortexAtivo
    setToggleVisual("vortex", config.vortexAtivo)
end

function F.alternarAntiGravZone()
    config.antiGravZoneAtivo = not config.antiGravZoneAtivo
    setToggleVisual("antigravzone", config.antiGravZoneAtivo)
    avisar(
        config.antiGravZoneAtivo and "🌌 Zona Anti-Gravidade: ON" or "🌌 Zona Anti-Gravidade: OFF",
        "Peças soltas ao redor flutuam no ar!"
    )
end

function F.alternarGravGun()
    config.gravGunAtivo = not config.gravGunAtivo
    if not config.gravGunAtivo then
        state.gravGunPart = nil
    end
    setToggleVisual("gravgun", config.gravGunAtivo)
end

function F.removerBarreirasInvisiveis()
    local char = player.Character
    local cnt = 0
    for _, p in ipairs(Workspace:GetDescendants()) do
        if p:IsA("BasePart") and p.Transparency >= 0.95 and p.CanCollide and (not char or not p:IsDescendantOf(char)) then
            if p ~= state.plataformaCeu and p ~= state.magicFloorPart then
                p.CanCollide = false
                cnt = cnt + 1
            end
        end
    end
    avisar("🚧 Barreiras Invisíveis", cnt .. " paredes desativadas!", 2.5, "ok")
end

-- ════════════════════════════════════════════════════════════════════════════════
-- REDE & SERVIDOR V12.0
-- ════════════════════════════════════════════════════════════════════════════════
function F.rejoinServer()
    avisar("🔄 Rejoin", "Reconectando ao servidor atual...", 2)
    pcall(function()
        TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, player)
    end)
end

function F.serverHop(modoMenor)
    avisar("🌐 Server Hop", modoMenor and "Buscando menor servidor..." or "Buscando servidor público...", 2.5)
    task.spawn(function()
        local sort = modoMenor and "Asc" or "Desc"
        local ok, res = pcall(function()
            local url = string.format(
                "https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=%s&limit=50",
                game.PlaceId,
                sort
            )
            return HttpService:JSONDecode(game:HttpGet(url))
        end)
        if ok and res and res.data then
            local candidates = {}
            for _, srv in ipairs(res.data) do
                if srv.id ~= game.JobId and srv.playing < srv.maxPlayers then
                    table.insert(candidates, srv.id)
                end
            end
            if #candidates > 0 then
                local chosen = modoMenor and candidates[1] or candidates[math.random(1, #candidates)]
                TeleportService:TeleportToPlaceInstance(game.PlaceId, chosen, player)
                return
            end
        end
        avisar("⚠️ Server Hop", "Nenhum outro servidor encontrado.", 3, "warn")
    end)
end

function F.copiarInfoServidor()
    local info = string.format("PlaceId: %d | JobId: %s", game.PlaceId, game.JobId)
    if setclipboard then
        setclipboard(info)
        avisar("📋 Copiado", "PlaceId e JobId copiados!", 2, "ok")
    else
        avisar("ℹ️ Info Servidor", info, 4)
    end
end

function F.adicionarChatLog(autor, msg)
    local line = string.format("[%s] %s: %s", os.date("%H:%M:%S"), autor, msg)
    table.insert(state.chatLogs, line)
    if #state.chatLogs > 45 then
        table.remove(state.chatLogs, 1)
    end
    if UI.chatLogBox then
        UI.chatLogBox.Text = table.concat(state.chatLogs, "\n")
    end
end

for _, p in ipairs(Players:GetPlayers()) do
    trackConn(p.Chatted:Connect(function(m)
        F.adicionarChatLog(p.DisplayName, m)
    end))
end
trackConn(Players.PlayerAdded:Connect(function(p)
    trackConn(p.Chatted:Connect(function(m)
        F.adicionarChatLog(p.DisplayName, m)
    end))
end))

-- ════════════════════════════════════════════════════════════════════════════════
-- AUTOMAÇÃO, UTILITÁRIOS & WAYPOINTS V12.0
-- ════════════════════════════════════════════════════════════════════════════════
function F.alternarAutoClicker()
    config.autoClickerAtivo = not config.autoClickerAtivo
    setToggleVisual("autoclicker", config.autoClickerAtivo)
end

function F.alternarAutoInteract()
    config.autoInteractAtivo = not config.autoInteractAtivo
    setToggleVisual("autointeract", config.autoInteractAtivo)
end

function F.alternarAutoClickDetectors()
    config.autoClickDetectors = not config.autoClickDetectors
    setToggleVisual("autocd", config.autoClickDetectors)
    avisar(
        config.autoClickDetectors and "🖱️ Auto-ClickDetectors: ON" or "🖱️ Auto-ClickDetectors: OFF",
        "Aciona ClickDetectors próximos automaticamente"
    )
end

function F.alternarMagnet()
    config.magnetAtivo = not config.magnetAtivo
    setToggleVisual("magnet", config.magnetAtivo)
end

function F.alternarMagnetTouch()
    config.magnetTouchAtivo = not config.magnetTouchAtivo
    setToggleVisual("magtouch", config.magnetTouchAtivo)
    avisar(
        config.magnetTouchAtivo and "✨ Touch Collect: ON" or "✨ Touch Collect: OFF",
        "Aciona TouchTransmitters de itens próximos!"
    )
end

function F.alternarFpsBooster()
    config.fpsBoosterAtivo = not config.fpsBoosterAtivo
    setToggleVisual("fpsbooster", config.fpsBoosterAtivo)
    if config.fpsBoosterAtivo then
        Lighting.GlobalShadows = false
        Lighting.FogEnd        = 9e9
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") then
                if state.fpsOriginal[obj] == nil then
                    state.fpsOriginal[obj] = {m = obj.Material, s = obj.CastShadow}
                end
                obj.Material   = Enum.Material.SmoothPlastic
                obj.CastShadow = false
            elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Smoke") or obj:IsA("Fire") then
                if state.fpsOriginal[obj] == nil then
                    state.fpsOriginal[obj] = {e = obj.Enabled}
                end
                obj.Enabled = false
            end
        end
        avisar("🚀 FPS Booster: ON", "Gráficos otimizados!")
    else
        Lighting.GlobalShadows = originalLighting.GlobalShadows
        for obj, orig in pairs(state.fpsOriginal) do
            if obj and obj.Parent then
                if obj:IsA("BasePart") then
                    obj.Material   = orig.m
                    obj.CastShadow = orig.s
                elseif orig.e ~= nil then
                    obj.Enabled = orig.e
                end
            end
        end
        table.clear(state.fpsOriginal)
        avisar("🚀 FPS Booster: OFF", "Gráficos restaurados.")
    end
end

function F.removerTexturasEDecals()
    local cnt = 0
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("Decal") or obj:IsA("Texture") then
            pcall(function()
                obj:Destroy()
            end)
            cnt = cnt + 1
        end
    end
    avisar("🧼 Limpeza de Texturas", cnt .. " Decals/Textures removidos (+FPS)!")
end

function F.dispararOndaDeChoque()
    local root = obterRootAtivo()
    if not root then
        return
    end
    local char = obterCharAtivo()
    local pos  = root.Position
    local count, blastRadius, blastForce = 0, 52, 175
    for _, p in ipairs(Workspace:GetDescendants()) do
        if p:IsA("BasePart") and not p.Anchored and (not char or not p:IsDescendantOf(char)) then
            local diff = p.Position - pos
            local dist = diff.Magnitude
            if dist <= blastRadius and dist > 0.5 then
                local dir = (diff.Unit + Vector3.new(0, 0.45, 0)).Unit
                pcall(function()
                    p.AssemblyLinearVelocity = dir * (blastForce * (1 - dist / blastRadius))
                end)
                count = count + 1
            end
        end
    end
    local ring = Instance.new("Part")
    ring.Name       = "SuiteV12Shockwave"
    ring.Anchored   = true
    ring.CanCollide = false
    ring.Material   = Enum.Material.ForceField
    ring.Color      = temas[config.temaIndice].accent
    ring.Size       = Vector3.new(4, 1, 4)
    ring.CFrame     = CFrame.new(pos)
    ring.Parent     = Workspace
    tweenObj(ring, {Size = Vector3.new(blastRadius * 2, 0.5, blastRadius * 2), Transparency = 1}, 0.45)
    task.delay(0.5, function()
        if ring and ring.Parent then
            ring:Destroy()
        end
    end)
    avisar("💥 Onda de Choque", count .. " objetos lançados!")
end

function F.limparVestigios()
    local removidos = 0
    if state.magicFloorPart and state.magicFloorPart.Parent then
        state.magicFloorPart:Destroy()
        state.magicFloorPart   = nil
        config.magicFloorAtivo = false
        setToggleVisual("magicfloor", false)
        removidos = removidos + 1
    end
    for _, p in ipairs(state.tempPlataformas) do
        if p and p.Parent then
            p:Destroy()
            removidos = removidos + 1
        end
    end
    table.clear(state.tempPlataformas)
    for _, b in ipairs(state.grappleBeams) do
        if b and b.Parent then
            b:Destroy()
            removidos = removidos + 1
        end
    end
    table.clear(state.grappleBeams)
    for _, obj in ipairs(Workspace:GetChildren()) do
        if obj.Name:find("SuiteV12") and obj ~= state.plataformaCeu then
            obj:Destroy()
            removidos = removidos + 1
        end
    end
    table.clear(state.spawnedParts)
    atualizarRayParams()
    avisar("🧹 Limpeza", removidos .. " vestígios removidos.")
end

function F.alternarNoclip()
    config.noclipAtivo = not config.noclipAtivo
    if not config.noclipAtivo then
        for p, origCC in pairs(state.noclipOriginal) do
            if p and p.Parent and p:IsA("BasePart") then
                p.CanCollide = origCC
            end
        end
        table.clear(state.noclipOriginal)
    end
    setToggleVisual("noclip", config.noclipAtivo)
end

function F.apagarObjetoNoMouse()
    local t    = mouse.Target
    local char = player.Character
    if t and t:IsA("BasePart") and (not char or not t:IsDescendantOf(char)) then
        local nm = t.Name
        table.insert(state.undoHistory, {instance = t, parent = t.Parent, cframe = t.CFrame})
        if #state.undoHistory > 30 then
            table.remove(state.undoHistory, 1)
        end
        t.Parent = nil
        avisar("🗑️ Apagado", "'" .. nm .. "' [Z restaura]")
    end
end

function F.alternarDeleteMode()
    config.deleteModeAtivo = not config.deleteModeAtivo
    setToggleVisual("delete", config.deleteModeAtivo)
end

function F.executarUndoDelete()
    if #state.undoHistory > 0 then
        local item = table.remove(state.undoHistory)
        if item and item.instance then
            item.instance.Parent = item.parent or Workspace
            item.instance.CFrame = item.cframe
            avisar("↩️ Undo", "'" .. item.instance.Name .. "' restaurado!")
        end
    else
        avisar("ℹ️ Undo", "Histórico vazio.")
    end
end

function F.alternarInspector()
    config.inspectorAtivo = not config.inspectorAtivo
    if not config.inspectorAtivo and UI.inspectorBillboard then
        UI.inspectorBillboard.Enabled = false
        state.inspectorTarget         = nil
    end
    setToggleVisual("inspector", config.inspectorAtivo)
end

function F.alternarSpeedHack()
    config.speedHackAtivo = not config.speedHackAtivo
    local h = obterHumAtivo()
    if h then
        h.WalkSpeed = config.speedHackAtivo and (config.velocidadePadrao * config.speedHackMultiplier) or config.velocidadePadrao
    end
    setToggleVisual("speedhack", config.speedHackAtivo)
end

function F.recalcularGravForce()
    local root = obterRootAtivo()
    if not root then
        return
    end
    if config.gravitacaoAtiva and config.gravitacaoPercent ~= 100 then
        if not state.gravForce or not state.gravForce.Parent then
            local vf = Instance.new("VectorForce")
            vf.Name                = "SuiteV12GravForce"
            vf.RelativeTo          = Enum.ActuatorRelativeTo.World
            vf.ApplyAtCenterOfMass = true
            local att              = root:FindFirstChild("SuiteV12GravAtt") or Instance.new("Attachment", root)
            att.Name               = "SuiteV12GravAtt"
            vf.Attachment0         = att
            vf.Parent              = root
            state.gravForce        = vf
        end
        local mass = 0
        local char = obterCharAtivo()
        if char then
            for _, p in ipairs(char:GetDescendants()) do
                if p:IsA("BasePart") then
                    mass = mass + p:GetMass()
                end
            end
        end
        local defG = Workspace.Gravity
        state.gravForce.Force = Vector3.new(0, mass * (defG - defG * (config.gravitacaoPercent / 100)), 0)
    else
        if state.gravForce and state.gravForce.Parent then
            state.gravForce:Destroy()
        end
        state.gravForce = nil
    end
end

function F.alternarGravidade()
    config.gravitacaoAtiva = not config.gravitacaoAtiva
    F.recalcularGravForce()
    setToggleVisual("gravidade", config.gravitacaoAtiva)
end

function F.alternarAntiAfk()
    config.antiAfkAtivo = not config.antiAfkAtivo
    setToggleVisual("antiafk", config.antiAfkAtivo)
end

trackConn(player.Idled:Connect(function()
    if not config.antiAfkAtivo or state.unloaded then
        return
    end
    pcall(function()
        if VirtualUser then
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end
    end)
end))

function F.executarClickTeleport()
    local h, r = mouse.Hit, obterRootAtivo()
    if h and r then
        local c  = obterCharAtivo()
        local cf = CFrame.new(h.Position + Vector3.new(0, 3.2, 0))
        if c then
            c:PivotTo(cf)
        else
            r.CFrame = cf
        end
        r.AssemblyLinearVelocity  = Vector3.zero
        r.AssemblyAngularVelocity = Vector3.zero
    end
end

function F.atualizarSlotsUI()
    if UI.slotButtons then
        for i = 0, 9 do
            local btn = UI.slotButtons[i]
            if btn then
                local filled = state.slotsPosicoes[i] ~= nil
                btn.BackgroundColor3 = filled and temas[config.temaIndice].accent or Color3.fromRGB(22, 28, 42)
                btn.TextColor3       = filled and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(130, 145, 170)
            end
        end
    end
end

function F.salvarSlot(s)
    local r = obterRootAtivo()
    if r then
        state.slotsPosicoes[s] = r.CFrame
        F.atualizarSlotsUI()
        avisar("💾 Slot " .. s .. " Salvo", string.format("%.0f, %.0f, %.0f", r.Position.X, r.Position.Y, r.Position.Z))
    end
end

function F.carregarSlot(s)
    local targetCF, r = state.slotsPosicoes[s], obterRootAtivo()
    if not targetCF then
        avisar("⚠️ Slot " .. s .. " Vazio", "Ctrl Dir + " .. s .. " salva", 2, "warn")
        return
    end
    if not r then
        return
    end
    local char = obterCharAtivo()
    if s >= 6 then
        atualizarRayParams()
        local ray     = Workspace:Raycast(targetCF.Position + Vector3.new(0, 20, 0), Vector3.new(0, -60, 0), rayParams)
        local groundY = ray and ray.Position.Y or targetCF.Position.Y
        local offset  = (config.slotAlturaDirecao == "cima") and config.slotAlturaOffset or -config.slotAlturaOffset
        local finalCF = CFrame.new(targetCF.Position.X, groundY + offset, targetCF.Position.Z)
        if char then
            char:PivotTo(finalCF)
        else
            r.CFrame = finalCF
        end
    else
        if char then
            char:PivotTo(targetCF)
        else
            r.CFrame = targetCF
        end
    end
    r.AssemblyLinearVelocity  = Vector3.zero
    r.AssemblyAngularVelocity = Vector3.zero
    avisar("⚡ Slot " .. s, "Teleportado!")
end

-- ════════════════════════════════════════════════════════════════════════════════
-- DEFESAS BLINDADAS V12.0 (10 ESCUDOS)
-- ════════════════════════════════════════════════════════════════════════════════
function F.aplicarNoPlayerCollide()
    if not config.antiFling then
        return
    end
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= player and p.Character then
            for _, part in ipairs(p.Character:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide then
                    part.CanCollide = false
                end
            end
        end
    end
end

function F.processarAntiVoid(realRoot)
    if not config.antiVoid or not realRoot then
        return
    end
    local destroyY = Workspace.FallenPartsDestroyHeight + 40
    if realRoot.Position.Y < destroyY or (realRoot.Position.Y < -60 and realRoot.AssemblyLinearVelocity.Y < -80) then
        realRoot.AssemblyLinearVelocity  = Vector3.zero
        realRoot.AssemblyAngularVelocity = Vector3.zero
        local targetCF = state.lastSafeCFrame or config.checkpointPos or CFrame.new(realRoot.Position.X, 60, realRoot.Position.Z)
        if player.Character then
            player.Character:PivotTo(targetCF + Vector3.new(0, 3.5, 0))
        end
        if not config.magicFloorAtivo then
            F.alternarMagicFloor()
        end
        avisar("🕳️ Anti-Void", "Resgatado do abismo!", 2, "ok")
    end
end

function F.processarAntiRagdoll(realHum)
    if not realHum then
        return
    end
    if (config.antiRagdoll or config.antiSeat) and realHum.Sit then
        realHum.Sit = false
    end
    if config.antiRagdoll then
        local st = realHum:GetState()
        if st == Enum.HumanoidStateType.Ragdoll or st == Enum.HumanoidStateType.FallingDown or st == Enum.HumanoidStateType.PlatformStanding then
            realHum:ChangeState(Enum.HumanoidStateType.GettingUp)
        end
    end
end

function F.processarAntiAnchor(char)
    if not config.antiAnchor or not char or config.freezeAtivo or config.modoAstralAtivo then
        return
    end
    for _, part in ipairs(char:GetChildren()) do
        if part:IsA("BasePart") and part.Anchored then
            part.Anchored = false
        end
    end
end

function F.processarEmergencyHp(realRoot, realHum)
    if not config.autoEmergencyHp or not realHum or realHum.Health <= 0 then
        return
    end
    local pct = (realHum.Health / math.max(realHum.MaxHealth, 1)) * 100
    if pct <= (config.emergencyHpThreshold or 30) and (tick() - state.lastEmergencyWarp > 7) then
        state.lastEmergencyWarp = tick()
        local safeTarget = config.checkpointPos or state.lastSafeCFrame or (realRoot.CFrame + Vector3.new(0, 80, 0))
        realRoot.AssemblyLinearVelocity  = Vector3.zero
        realRoot.AssemblyAngularVelocity = Vector3.zero
        if player.Character then
            player.Character:PivotTo(safeTarget)
        end
        avisar("🩸 Salvamento HP", math.floor(pct) .. "% HP! Resgatado.", 2.5, "warn")
    end
end

function F.escanearKillbricks()
    if not config.antiKillbrick then
        return
    end
    local root = obterRootAtivo()
    if not root then
        return
    end
    local pos, char = root.Position, player.Character
    for _, part in ipairs(Workspace:GetDescendants()) do
        if part:IsA("BasePart") and (not char or not part:IsDescendantOf(char)) then
            local nm = part.Name:lower()
            if nm:find("lava") or nm:find("kill") or nm:find("acid") or nm:find("hazard") or nm:find("spike") or nm:find("deadly") or nm:find("death") or nm:find("dano") then
                if (part.Position - pos).Magnitude < 120 then
                    pcall(function()
                        part.CanTouch   = false
                        part.CanCollide = false
                        local tt = part:FindFirstChildOfClass("TouchTransmitter")
                        if tt then
                            tt:Destroy()
                        end
                    end)
                end
            end
        end
    end
end

function F.processarAntiFallDamage(realRoot, realHum)
    if not config.antiFallDamage or not realRoot or not realHum then
        return
    end
    if realHum:GetState() == Enum.HumanoidStateType.Freefall and realRoot.AssemblyLinearVelocity.Y < -55 then
        atualizarRayParams()
        local ray = Workspace:Raycast(realRoot.Position, Vector3.new(0, -11, 0), rayParams)
        if ray and ray.Instance then
            realRoot.AssemblyLinearVelocity = Vector3.new(realRoot.AssemblyLinearVelocity.X, 0, realRoot.AssemblyLinearVelocity.Z)
            realHum:ChangeState(Enum.HumanoidStateType.RunningNoPhysics)
        end
    end
end

function F.limparEfeitosTela()
    if not config.antiBlind then
        return
    end
    for _, ef in ipairs(Lighting:GetChildren()) do
        if ef:IsA("BlurEffect") and ef.Size > 4 then
            ef.Size = 0
        elseif ef:IsA("ColorCorrectionEffect") and (ef.Brightness < -0.3 or ef.TintColor.R < 0.2) then
            ef.Brightness = 0
            ef.TintColor  = Color3.fromRGB(255, 255, 255)
        end
    end
    Lighting.FogEnd = 9e9
end

-- ════════════════════════════════════════════════════════════════════════════════
-- JOGADORES, TEMAS, PÂNICO & UNLOAD
-- ════════════════════════════════════════════════════════════════════════════════
function F.executarBackstab(alvo)
    if not alvo or not alvo.Character then
        return
    end
    local tRoot          = alvo.Character:FindFirstChild("HumanoidRootPart")
    local myChar, myRoot = obterCharAtivo(), obterRootAtivo()
    if tRoot and myChar and myRoot then
        myChar:PivotTo(tRoot.CFrame * CFrame.new(0, 0, 4))
        myRoot.AssemblyLinearVelocity = Vector3.zero
        avisar("🗡️ Backstab", alvo.DisplayName)
    end
end

function F.alternarOrbit(alvo)
    if config.orbitAtivo and config.alvoOrbit == alvo then
        config.orbitAtivo = false
        config.alvoOrbit  = nil
        avisar("🛸 Orbit", "Desligado.")
    else
        config.orbitAtivo = true
        config.alvoOrbit  = alvo
        avisar("🛸 Orbit", alvo.DisplayName)
    end
end

function F.alternarFollow(alvo)
    if config.followAtivo and config.alvoFollow == alvo then
        config.followAtivo = false
        config.alvoFollow  = nil
        avisar("🧲 Follow", "Desligado.")
    else
        config.followAtivo = true
        config.alvoFollow  = alvo
        avisar("🧲 Follow", "Seguindo " .. alvo.DisplayName)
    end
end

function F.pararSpectate()
    if state.spectatingPlayer then
        state.spectatingPlayer = nil
        camera.CameraType      = Enum.CameraType.Custom
        camera.CameraSubject   = obterHumAtivo() or state.cameraOriginalSubject
        if UI.spectateBanner then
            UI.spectateBanner.Visible = false
        end
        avisar("👁️ Spectate", "Encerrado.")
    end
end

function F.aplicarTemaCorDireta(accentCol, glowCol, bgCol, nomeTema)
    if UI.mainStroke then UI.mainStroke.Color = accentCol end
    if UI.main and bgCol then UI.main.BackgroundColor3 = bgCol end
    if UI.hudStroke then UI.hudStroke.Color = accentCol end
    if UI.hudTit then UI.hudTit.TextColor3 = glowCol end
    if UI.floatPill then UI.floatPill.BackgroundColor3 = accentCol end
    if UI.badgeLabel then UI.badgeLabel.BackgroundColor3 = accentCol end
    if UI.fovStroke then UI.fovStroke.Color = accentCol end
    if UI.radarStroke then UI.radarStroke.Color = accentCol end
    if UI.temaBtnLbl and nomeTema then UI.temaBtnLbl.Text = "🎨 Tema Ativo: " .. nomeTema end
    if state.plataformaCeu then state.plataformaCeu.Color = accentCol end
    if state.magicFloorPart then state.magicFloorPart.Color = accentCol end
    if UI.crosshairH then UI.crosshairH.BackgroundColor3 = glowCol end
    if UI.crosshairV then UI.crosshairV.BackgroundColor3 = glowCol end
    if UI.crosshairDot then UI.crosshairDot.BackgroundColor3 = accentCol end

    for _, obj in ipairs(UI.themeAccentObjs) do
        if obj and obj.Parent then
            if obj:IsA("UIStroke") then
                obj.Color = accentCol
            elseif obj:IsA("TextLabel") then
                obj.TextColor3 = glowCol
            else
                obj.BackgroundColor3 = accentCol
            end
        end
    end
    for k, info in pairs(UI.toggles) do
        if info.isAtivo then
            setToggleVisual(k, true)
        end
    end
    if UI.tabButtons then
        for j, b in pairs(UI.tabButtons) do
            b.BackgroundColor3 = (j == UI.currentTabIdx) and accentCol or Color3.fromRGB(20, 26, 40)
        end
    end
    F.atualizarSlotsUI()
end

function F.aplicarTemaVisual(idx)
    config.temaIndice = ((idx - 1) % #temas) + 1
    local t = temas[config.temaIndice]
    F.aplicarTemaCorDireta(t.accent, t.glow, t.bg, t.nome)
end

function F.ativarPanico()
    if config.modoAstralAtivo then F.alternarModoAstral() end
    if config.vooAtivo then F.alternarVoo() end
    if config.andarParedesAtivo then F.alternarAndarParedes() end
    if config.freezeAtivo then F.alternarFreeze() end
    if config.noclipAtivo then F.alternarNoclip() end
    if config.cameraLivreAtiva then F.alternarCameraLivre() end
    if config.magicFloorAtivo then F.alternarMagicFloor() end
    if config.elevadorAtivo then F.alternarElevador() end
    if config.invisibilidadeAtiva then F.alternarInvisibilidade() end
    if config.fullbrightAtivo then F.alternarFullbright() end
    if config.noFogAtivo then F.alternarNoFog() end
    if config.xrayAtivo then F.alternarXRay() end
    if config.espAtivo then F.alternarEsp() end
    if config.esp2DBoxAtivo then F.alternarEsp2D() end
    if config.espSkeletonAtivo then F.alternarEspSkeleton() end
    if config.radar2DAtivo then F.alternarRadar2D() end
    if config.tracersAtivo then F.alternarTracers() end
    if config.radarInteracoesAtivo then F.alternarRadarInteracoes() end
    if config.autoClickerAtivo then F.alternarAutoClicker() end
    if config.autoWalkAtivo then F.alternarAutoWalk() end
    if config.superPuloAtivo then F.alternarSuperPulo() end
    if config.spiderClimbAtivo then F.alternarSpiderClimb() end
    if config.spinbotAtivo then F.alternarSpinbot() end
    if config.airSwimAtivo then F.alternarAirSwim() end
    if config.crosshairAtivo then F.alternarCrosshair() end
    if config.aimbotAtivo then F.alternarAimbot() end
    if config.hitboxAtivo then F.alternarHitbox() end
    if config.triggerbotAtivo then F.alternarTriggerbot() end
    if config.killAuraAtivo then F.alternarKillAura() end
    if config.autoDodgeAtivo then F.alternarAutoDodge() end
    if config.vortexAtivo then F.alternarVortex() end
    if config.antiGravZoneAtivo then F.alternarAntiGravZone() end
    if config.gravGunAtivo then F.alternarGravGun() end
    if config.vehicleBoostAtivo then F.alternarVehicleBoost() end
    if config.pathTrailAtivo then F.alternarPathTrail() end
    if config.autoVaultAtivo then F.alternarAutoVault() end
    if config.jetpackAtivo then F.alternarJetpack() end
    if config.auraParticulasAtiva then F.alternarAuraParticulas() end
    F.soltarSpiderSwing()
    F.pararEmoteAtual()
    F.pararSpectate()

    config.orbitAtivo       = false
    config.alvoOrbit        = nil
    config.followAtivo      = false
    config.alvoFollow       = nil
    config.macroGravando    = false
    config.macroReproduzindo = false
    setToggleVisual("macrorec", false)
    setToggleVisual("macroplay", false)
    config.bhopAtivo         = false
    setToggleVisual("bhop", false)
    config.puloInfinitoAtivo = false
    setToggleVisual("pulo", false)
    config.speedHackAtivo    = false
    setToggleVisual("speedhack", false)
    config.gravitacaoAtiva   = false
    setToggleVisual("gravidade", false)
    F.recalcularGravForce()

    local root = obterRootAtivo()
    if root then
        root.AssemblyLinearVelocity  = Vector3.zero
        root.AssemblyAngularVelocity = Vector3.zero
        root.Anchored                = false
    end
    F.limparVestigios()
    camera.FieldOfView           = config.cameraFovOriginal or 70
    player.CameraMaxZoomDistance = state.droneOriginalMaxZoom or 128
    config.droneModeAtivo        = false
    setToggleVisual("drone", false)
    avisar("🚨 PÂNICO TOTAL", "Todos os modos desligados!", 3, "warn")
end

function F.descarregarScript()
    if state.unloaded then
        return
    end
    state.unloaded = true
    pcall(F.ativarPanico)
    for _, c in ipairs(connections) do
        pcall(function()
            c:Disconnect()
        end)
    end
    table.clear(connections)
    if state.plataformaCeu then
        pcall(function()
            state.plataformaCeu:Destroy()
        end)
    end
    if UI.screenGui then
        pcall(function()
            UI.screenGui:Destroy()
        end)
    end
    _G.SuiteAstralV12_Cleanup = nil
end
_G.SuiteAstralV12_Cleanup = F.descarregarScript

trackConn(player.CharacterAdded:Connect(function(newChar)
    if state.unloaded then
        return
    end
    if config.modoAstralAtivo then
        config.modoAstralAtivo = false
        if state.copiaPersonagem then
            pcall(function()
                state.copiaPersonagem:Destroy()
            end)
        end
        state.copiaPersonagem      = nil
        state.plataformaCeu.CFrame = CFrame.new(0, -9999, 0)
        setToggleVisual("astral", false)
    end
    table.clear(state.noclipOriginal)
    table.clear(state.invisOriginal)
    state.gravForce = nil
    F.soltarSpiderSwing()

    local hum = newChar:WaitForChild("Humanoid", 5)
    task.wait(0.25)
    atualizarRayParams()
    if hum then
        if config.superPuloAtivo then
            hum.UseJumpPower = true
            hum.JumpPower    = config.superPuloForca or 120
        end
        if config.speedHackAtivo then
            hum.WalkSpeed = config.velocidadePadrao * config.speedHackMultiplier
        end
    end
    if config.gravitacaoAtiva then
        F.recalcularGravForce()
    end
    if config.auraParticulasAtiva then
        config.auraParticulasAtiva = false
        F.alternarAuraParticulas()
    end
end))

-- ════════════════════════════════════════════════════════════════════════════════
-- INTERFACE GRÁFICA V12.0 — 10 ABAS, RADAR 2D, SKELETON ESP & MINI-HUD 7.0
-- ════════════════════════════════════════════════════════════════════════════════
;(function()
    local playerGui = player:WaitForChild("PlayerGui")
    for _, nm in ipairs({"SuiteAstralV12Gui", "SuiteAstralV11Gui", "SuiteAstralV10Gui", "ColisaoV90Gui"}) do
        local old = playerGui:FindFirstChild(nm)
        if old then
            old:Destroy()
        end
    end

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name           = "SuiteAstralV12Gui"
    screenGui.ResetOnSpawn   = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent         = playerGui
    UI.screenGui             = screenGui

    local esp2DLayer = Instance.new("Frame")
    esp2DLayer.Name                   = "ESP2DLayer"
    esp2DLayer.Size                   = UDim2.new(1, 0, 1, 0)
    esp2DLayer.BackgroundTransparency = 1
    esp2DLayer.Parent                 = screenGui
    UI.esp2DLayer                     = esp2DLayer

    local toastContainer = Instance.new("Frame")
    toastContainer.Name                   = "ToastContainer"
    toastContainer.Size                   = UDim2.new(0, 295, 0, 290)
    toastContainer.Position               = UDim2.new(1, -310, 1, -304)
    toastContainer.BackgroundTransparency = 1
    toastContainer.Parent                 = screenGui
    UI.toastContainer                     = toastContainer

    local tl = Instance.new("UIListLayout")
    tl.VerticalAlignment = Enum.VerticalAlignment.Bottom
    tl.Padding           = UDim.new(0, 6)
    tl.Parent            = toastContainer

    -- CROSSHAIR CYBER (4 ESTILOS)
    local chFrame = Instance.new("Frame")
    chFrame.Size                   = UDim2.new(0, 28, 0, 28)
    chFrame.Position               = UDim2.new(0.5, -14, 0.5, -14)
    chFrame.BackgroundTransparency = 1
    chFrame.Visible                = false
    chFrame.Parent                 = screenGui
    UI.crosshairFrame              = chFrame

    local chH = Instance.new("Frame")
    chH.Size             = UDim2.new(0, 18, 0, 2)
    chH.Position         = UDim2.new(0.5, -9, 0.5, -1)
    chH.BackgroundColor3 = temas[1].glow
    chH.BorderSizePixel  = 0
    chH.Parent           = chFrame
    UI.crosshairH        = chH

    local chV = Instance.new("Frame")
    chV.Size             = UDim2.new(0, 2, 0, 18)
    chV.Position         = UDim2.new(0.5, -1, 0.5, -9)
    chV.BackgroundColor3 = temas[1].glow
    chV.BorderSizePixel  = 0
    chV.Parent           = chFrame
    UI.crosshairV        = chV

    local chDot = Instance.new("Frame")
    chDot.Size             = UDim2.new(0, 4, 0, 4)
    chDot.Position         = UDim2.new(0.5, -2, 0.5, -2)
    chDot.BackgroundColor3 = temas[1].accent
    chDot.BorderSizePixel  = 0
    chDot.Parent           = chFrame
    Instance.new("UICorner", chDot).CornerRadius = UDim.new(1, 0)
    UI.crosshairDot        = chDot

    local chRing = Instance.new("Frame")
    chRing.Size                   = UDim2.new(0, 20, 0, 20)
    chRing.Position               = UDim2.new(0.5, -10, 0.5, -10)
    chRing.BackgroundTransparency = 1
    chRing.Visible                = false
    chRing.Parent                 = chFrame
    Instance.new("UICorner", chRing).CornerRadius = UDim.new(1, 0)
    local chrs = Instance.new("UIStroke", chRing)
    chrs.Color     = temas[1].glow
    chrs.Thickness = 1.4
    UI.crosshairRing = chRing

    -- AIMBOT FOV CIRCLE
    local fovCircle = Instance.new("Frame")
    fovCircle.Name                   = "AimbotFOV"
    fovCircle.Size                   = UDim2.new(0, config.aimbotFov * 2, 0, config.aimbotFov * 2)
    fovCircle.Position               = UDim2.new(0.5, -config.aimbotFov, 0.5, -config.aimbotFov)
    fovCircle.BackgroundTransparency = 1
    fovCircle.Visible                = false
    fovCircle.Parent                 = screenGui
    Instance.new("UICorner", fovCircle).CornerRadius = UDim.new(1, 0)
    local fovStroke = Instance.new("UIStroke", fovCircle)
    fovStroke.Color        = temas[1].accent
    fovStroke.Thickness    = 1.4
    fovStroke.Transparency = 0.25
    UI.fovCircle           = fovCircle
    UI.fovStroke           = fovStroke

    -- RADAR 2D MINIMAP
    local radarFrame = Instance.new("Frame")
    radarFrame.Name                   = "Radar2D"
    radarFrame.Size                   = UDim2.new(0, 168, 0, 168)
    radarFrame.Position               = UDim2.new(1, -184, 0, 16)
    radarFrame.BackgroundColor3       = Color3.fromRGB(10, 13, 22)
    radarFrame.BackgroundTransparency = 0.16
    radarFrame.BorderSizePixel        = 0
    radarFrame.Active                 = true
    radarFrame.Draggable              = true
    radarFrame.Visible                = false
    radarFrame.ClipsDescendants       = true
    radarFrame.Parent                 = screenGui
    Instance.new("UICorner", radarFrame).CornerRadius = UDim.new(1, 0)
    local rStroke = Instance.new("UIStroke", radarFrame)
    rStroke.Color     = temas[1].accent
    rStroke.Thickness = 1.6
    UI.radarFrame     = radarFrame
    UI.radarStroke    = rStroke

    local rCrossH = Instance.new("Frame", radarFrame)
    rCrossH.Size                   = UDim2.new(1, 0, 0, 1)
    rCrossH.Position               = UDim2.new(0, 0, 0.5, 0)
    rCrossH.BackgroundColor3       = Color3.fromRGB(45, 58, 85)
    rCrossH.BackgroundTransparency = 0.5
    rCrossH.BorderSizePixel        = 0

    local rCrossV = Instance.new("Frame", radarFrame)
    rCrossV.Size                   = UDim2.new(0, 1, 1, 0)
    rCrossV.Position               = UDim2.new(0.5, 0, 0, 0)
    rCrossV.BackgroundColor3       = Color3.fromRGB(45, 58, 85)
    rCrossV.BackgroundTransparency = 0.5
    rCrossV.BorderSizePixel        = 0

    local rCenter = Instance.new("Frame", radarFrame)
    rCenter.Size             = UDim2.new(0, 8, 0, 8)
    rCenter.Position         = UDim2.new(0.5, -4, 0.5, -4)
    rCenter.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    rCenter.BorderSizePixel  = 0
    Instance.new("UICorner", rCenter).CornerRadius = UDim.new(1, 0)

    -- BANNER SPECTATE & BOTÃO FLUTUANTE
    local specBanner = Instance.new("TextButton")
    specBanner.Size             = UDim2.new(0, 270, 0, 32)
    specBanner.Position         = UDim2.new(0.5, -135, 0, 14)
    specBanner.BackgroundColor3 = Color3.fromRGB(220, 38, 38)
    specBanner.TextColor3       = Color3.fromRGB(255, 255, 255)
    specBanner.Font             = Enum.Font.GothamBold
    specBanner.TextSize         = 11
    specBanner.Text             = "👁️ Observando • Clique para SAIR"
    specBanner.Visible          = false
    specBanner.BorderSizePixel  = 0
    specBanner.Parent           = screenGui
    Instance.new("UICorner", specBanner).CornerRadius = UDim.new(1, 0)
    specBanner.MouseButton1Click:Connect(F.pararSpectate)
    UI.spectateBanner = specBanner

    local floatPill = Instance.new("TextButton")
    floatPill.Size             = UDim2.new(0, 92, 0, 30)
    floatPill.Position         = UDim2.new(0, 14, 0, 14)
    floatPill.BackgroundColor3 = temas[1].accent
    floatPill.TextColor3       = Color3.fromRGB(255, 255, 255)
    floatPill.Font             = Enum.Font.GothamBold
    floatPill.TextSize         = 11
    floatPill.Text             = "👻 V12.0"
    floatPill.Active           = true
    floatPill.Draggable        = true
    floatPill.BorderSizePixel  = 0
    floatPill.Parent           = screenGui
    Instance.new("UICorner", floatPill).CornerRadius = UDim.new(1, 0)
    local fps = Instance.new("UIStroke", floatPill)
    fps.Color        = Color3.fromRGB(255, 255, 255)
    fps.Transparency = 0.65
    fps.Thickness    = 1
    UI.floatPill     = floatPill

    -- COMPONENTES REUTILIZÁVEIS
    local function mkSection(parent, titulo)
        local sec = Instance.new("Frame")
        sec.Size                   = UDim2.new(1, -12, 0, 22)
        sec.BackgroundTransparency = 1
        sec.Parent                 = parent

        local lbl = Instance.new("TextLabel", sec)
        lbl.Size                   = UDim2.new(1, 0, 1, 0)
        lbl.BackgroundTransparency = 1
        lbl.Font                   = Enum.Font.GothamBold
        lbl.TextSize               = 10.5
        lbl.TextColor3             = temas[config.temaIndice].glow
        lbl.TextXAlignment         = Enum.TextXAlignment.Left
        lbl.Text                   = "▸ " .. titulo:upper()
        table.insert(UI.themeAccentObjs, lbl)
        return sec
    end

    local function mkGrid(parent)
        local grid = Instance.new("Frame")
        grid.Size                   = UDim2.new(1, -12, 0, 0)
        grid.AutomaticSize          = Enum.AutomaticSize.Y
        grid.BackgroundTransparency = 1
        grid.Parent                 = parent

        local gl = Instance.new("UIGridLayout", grid)
        gl.CellSize    = UDim2.new(0.5, -5, 0, 48)
        gl.CellPadding = UDim2.new(0, 8, 0, 7)
        gl.SortOrder   = Enum.SortOrder.LayoutOrder
        return grid
    end

    local function mkToggleCard(parent, titulo, sub, cor, key, cb)
        local card = Instance.new("TextButton")
        card.Size             = UDim2.new(1, 0, 0, 48)
        card.BackgroundColor3 = Color3.fromRGB(16, 20, 32)
        card.BorderSizePixel  = 0
        card.Text             = ""
        card.AutoButtonColor  = false
        card.Parent           = parent
        Instance.new("UICorner", card).CornerRadius = UDim.new(0, 8)
        local cs = Instance.new("UIStroke", card)
        cs.Color     = Color3.fromRGB(34, 44, 64)
        cs.Thickness = 1

        local t1 = Instance.new("TextLabel", card)
        t1.Size                   = UDim2.new(1, -60, 0, 18)
        t1.Position               = UDim2.new(0, 10, 0, 6)
        t1.BackgroundTransparency = 1
        t1.TextColor3             = Color3.fromRGB(242, 246, 255)
        t1.Font                   = Enum.Font.GothamBold
        t1.TextSize               = 11
        t1.Text                   = titulo
        t1.TextXAlignment         = Enum.TextXAlignment.Left
        t1.TextTruncate           = Enum.TextTruncate.AtEnd

        local t2 = Instance.new("TextLabel", card)
        t2.Size                   = UDim2.new(1, -60, 0, 15)
        t2.Position               = UDim2.new(0, 10, 0, 25)
        t2.BackgroundTransparency = 1
        t2.TextColor3             = Color3.fromRGB(148, 163, 184)
        t2.Font                   = Enum.Font.Gotham
        t2.TextSize               = 9
        t2.Text                   = sub
        t2.TextXAlignment         = Enum.TextXAlignment.Left
        t2.TextTruncate           = Enum.TextTruncate.AtEnd

        local pill = Instance.new("Frame", card)
        pill.Size             = UDim2.new(0, 38, 0, 20)
        pill.Position         = UDim2.new(1, -48, 0.5, -10)
        pill.BackgroundColor3 = Color3.fromRGB(36, 44, 62)
        pill.BorderSizePixel  = 0
        Instance.new("UICorner", pill).CornerRadius = UDim.new(1, 0)

        local knob = Instance.new("Frame", pill)
        knob.Size             = UDim2.new(0, 14, 0, 14)
        knob.Position         = UDim2.new(0, 3, 0.5, -7)
        knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        knob.BorderSizePixel  = 0
        Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

        card.MouseEnter:Connect(function()
            tweenObj(card, {BackgroundColor3 = Color3.fromRGB(22, 28, 44)}, 0.12)
        end)
        card.MouseLeave:Connect(function()
            tweenObj(card, {BackgroundColor3 = Color3.fromRGB(16, 20, 32)}, 0.12)
        end)
        card.MouseButton1Click:Connect(cb)

        if key then
            UI.toggles[key] = {
                card    = card,
                pill    = pill,
                knob    = knob,
                stroke  = cs,
                subLbl  = t2,
                baseSub = sub,
                cor     = cor,
                isAtivo = false,
            }
        end
        table.insert(UI.searchableCards, {obj = card, text = (titulo .. " " .. sub):lower()})
        return card
    end

    local function mkActionCard(parent, titulo, sub, cor, cb)
        local card = Instance.new("TextButton")
        card.Size             = UDim2.new(1, 0, 0, 48)
        card.BackgroundColor3 = Color3.fromRGB(16, 20, 32)
        card.BorderSizePixel  = 0
        card.Text             = ""
        card.AutoButtonColor  = false
        card.Parent           = parent
        Instance.new("UICorner", card).CornerRadius = UDim.new(0, 8)
        local cs = Instance.new("UIStroke", card)
        cs.Color        = cor
        cs.Transparency = 0.55
        cs.Thickness    = 1

        local bar = Instance.new("Frame", card)
        bar.Size             = UDim2.new(0, 3, 0.6, 0)
        bar.Position         = UDim2.new(0, 0, 0.2, 0)
        bar.BackgroundColor3 = cor
        bar.BorderSizePixel  = 0
        Instance.new("UICorner", bar).CornerRadius = UDim.new(1, 0)

        local t1 = Instance.new("TextLabel", card)
        t1.Size                   = UDim2.new(1, -24, 0, 18)
        t1.Position               = UDim2.new(0, 12, 0, 6)
        t1.BackgroundTransparency = 1
        t1.TextColor3             = Color3.fromRGB(242, 246, 255)
        t1.Font                   = Enum.Font.GothamBold
        t1.TextSize               = 11
        t1.Text                   = titulo
        t1.TextXAlignment         = Enum.TextXAlignment.Left
        t1.TextTruncate           = Enum.TextTruncate.AtEnd

        local t2 = Instance.new("TextLabel", card)
        t2.Size                   = UDim2.new(1, -24, 0, 15)
        t2.Position               = UDim2.new(0, 12, 0, 25)
        t2.BackgroundTransparency = 1
        t2.TextColor3             = Color3.fromRGB(155, 170, 195)
        t2.Font                   = Enum.Font.Gotham
        t2.TextSize               = 9
        t2.Text                   = sub
        t2.TextXAlignment         = Enum.TextXAlignment.Left
        t2.TextTruncate           = Enum.TextTruncate.AtEnd

        card.MouseEnter:Connect(function()
            tweenObj(card, {BackgroundColor3 = Color3.fromRGB(24, 30, 48)}, 0.12)
            tweenObj(cs, {Transparency = 0.1}, 0.12)
        end)
        card.MouseLeave:Connect(function()
            tweenObj(card, {BackgroundColor3 = Color3.fromRGB(16, 20, 32)}, 0.12)
            tweenObj(cs, {Transparency = 0.55}, 0.12)
        end)
        card.MouseButton1Click:Connect(cb)
        table.insert(UI.searchableCards, {obj = card, text = (titulo .. " " .. sub):lower()})
        return card
    end

    local function mkSliderCard(parent, titulo, minV, maxV, step, getVal, setVal, suffix)
        local card = Instance.new("Frame")
        card.Size             = UDim2.new(1, -12, 0, 46)
        card.BackgroundColor3 = Color3.fromRGB(15, 19, 30)
        card.BorderSizePixel  = 0
        card.Parent           = parent
        Instance.new("UICorner", card).CornerRadius = UDim.new(0, 8)
        local cs = Instance.new("UIStroke", card)
        cs.Color     = Color3.fromRGB(36, 46, 68)
        cs.Thickness = 1

        local lbl = Instance.new("TextLabel", card)
        lbl.Size                   = UDim2.new(0.65, 0, 0, 20)
        lbl.Position               = UDim2.new(0, 12, 0, 4)
        lbl.BackgroundTransparency = 1
        lbl.Font                   = Enum.Font.GothamBold
        lbl.TextSize               = 10.5
        lbl.TextColor3             = Color3.fromRGB(220, 232, 255)
        lbl.TextXAlignment         = Enum.TextXAlignment.Left
        lbl.Text                   = titulo

        local valLbl = Instance.new("TextLabel", card)
        valLbl.Size                   = UDim2.new(0.35, -12, 0, 20)
        valLbl.Position               = UDim2.new(0.65, 0, 0, 4)
        valLbl.BackgroundTransparency = 1
        valLbl.Font                   = Enum.Font.GothamBold
        valLbl.TextSize               = 10.5
        valLbl.TextColor3             = temas[config.temaIndice].glow
        valLbl.TextXAlignment         = Enum.TextXAlignment.Right
        table.insert(UI.themeAccentObjs, valLbl)

        local track = Instance.new("TextButton", card)
        track.Size             = UDim2.new(1, -24, 0, 8)
        track.Position         = UDim2.new(0, 12, 0, 29)
        track.BackgroundColor3 = Color3.fromRGB(28, 35, 52)
        track.BorderSizePixel  = 0
        track.Text             = ""
        track.AutoButtonColor  = false
        Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

        local fill = Instance.new("Frame", track)
        fill.Size             = UDim2.new(0.5, 0, 1, 0)
        fill.BackgroundColor3 = temas[config.temaIndice].accent
        fill.BorderSizePixel  = 0
        Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)
        table.insert(UI.themeAccentObjs, fill)

        local knob = Instance.new("Frame", fill)
        knob.Size             = UDim2.new(0, 14, 0, 14)
        knob.Position         = UDim2.new(1, -7, 0.5, -7)
        knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        knob.BorderSizePixel  = 0
        Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

        local function refresh(v)
            local pct = math.clamp((v - minV) / math.max(maxV - minV, 0.001), 0, 1)
            fill.Size   = UDim2.new(pct, 0, 1, 0)
            valLbl.Text = string.format((step < 1) and "%.2f" or "%.0f", v) .. (suffix or "")
        end
        refresh(getVal())

        local dragging = false
        local function updateFromX(ix)
            local pct     = math.clamp((ix - track.AbsolutePosition.X) / math.max(track.AbsoluteSize.X, 1), 0, 1)
            local snapped = math.clamp(math.floor((minV + pct * (maxV - minV)) / step + 0.5) * step, minV, maxV)
            setVal(snapped)
            refresh(snapped)
        end

        track.InputBegan:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                updateFromX(inp.Position.X)
            end
        end)
        trackConn(UserInputService.InputChanged:Connect(function(inp)
            if dragging and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
                updateFromX(inp.Position.X)
            end
        end))
        trackConn(UserInputService.InputEnded:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end))
        table.insert(UI.searchableCards, {obj = card, text = titulo:lower()})
        return card
    end

    -- BLOCO 1: JANELA PRINCIPAL (890x610) + 10 ABAS
    local tabFrames = {}
    ;(function()
        local main = Instance.new("Frame")
        main.Name                   = "MainFrame"
        main.Size                   = UDim2.new(0, 890, 0, 610)
        main.Position               = UDim2.new(0.5, -445, 0.5, -305)
        main.BackgroundColor3       = temas[1].bg
        main.BackgroundTransparency = config.uiTransparencia
        main.BorderSizePixel        = 0
        main.Active                 = true
        main.Draggable              = true
        main.ClipsDescendants       = true
        main.Visible                = false
        main.Parent                 = screenGui
        UI.main                     = main
        Instance.new("UICorner", main).CornerRadius = UDim.new(0, 14)

        local ms = Instance.new("UIStroke", main)
        ms.Color     = temas[1].accent
        ms.Thickness = 1.6
        UI.mainStroke = ms

        floatPill.MouseButton1Click:Connect(function()
            main.Visible = not main.Visible
        end)

        local topBar = Instance.new("Frame", main)
        topBar.Size                   = UDim2.new(1, 0, 0, 48)
        topBar.BackgroundColor3       = Color3.fromRGB(16, 20, 34)
        topBar.BackgroundTransparency = 0.15
        topBar.BorderSizePixel        = 0
        Instance.new("UICorner", topBar).CornerRadius = UDim.new(0, 14)

        local badge = Instance.new("TextLabel", topBar)
        badge.Size             = UDim2.new(0, 165, 0, 28)
        badge.Position         = UDim2.new(0, 12, 0.5, -14)
        badge.BackgroundColor3 = temas[1].accent
        badge.TextColor3       = Color3.fromRGB(255, 255, 255)
        badge.Font             = Enum.Font.GothamBold
        badge.TextSize         = 11
        badge.Text             = "👻 V12.0 SINGULARITY"
        Instance.new("UICorner", badge).CornerRadius = UDim.new(0, 7)
        UI.badgeLabel          = badge

        local searchBox = Instance.new("TextBox", topBar)
        searchBox.Size               = UDim2.new(0, 280, 0, 28)
        searchBox.Position           = UDim2.new(0, 188, 0.5, -14)
        searchBox.BackgroundColor3   = Color3.fromRGB(12, 15, 24)
        searchBox.TextColor3         = Color3.fromRGB(235, 242, 255)
        searchBox.PlaceholderText    = "🔍 Buscar em 100+ funções..."
        searchBox.PlaceholderColor3  = Color3.fromRGB(115, 130, 155)
        searchBox.Font               = Enum.Font.Gotham
        searchBox.TextSize           = 10.5
        searchBox.Text               = ""
        searchBox.ClearTextOnFocus   = false
        searchBox.BorderSizePixel    = 0
        Instance.new("UICorner", searchBox).CornerRadius = UDim.new(0, 7)
        Instance.new("UIStroke", searchBox).Color        = Color3.fromRGB(40, 52, 78)
        Instance.new("UIPadding", searchBox).PaddingLeft = UDim.new(0, 8)

        searchBox:GetPropertyChangedSignal("Text"):Connect(function()
            local q = searchBox.Text:lower():gsub("^%s+", ""):gsub("%s+$", "")
            for _, item in ipairs(UI.searchableCards) do
                if item.obj and item.obj.Parent then
                    item.obj.Visible = (q == "" or item.text:find(q, 1, true) ~= nil)
                end
            end
        end)

        local btnPanic = Instance.new("TextButton", topBar)
        btnPanic.Size             = UDim2.new(0, 86, 0, 28)
        btnPanic.Position         = UDim2.new(1, -132, 0.5, -14)
        btnPanic.BackgroundColor3 = Color3.fromRGB(220, 38, 38)
        btnPanic.TextColor3       = Color3.fromRGB(255, 255, 255)
        btnPanic.Font             = Enum.Font.GothamBold
        btnPanic.TextSize         = 10
        btnPanic.Text             = "🚨 PÂNICO"
        btnPanic.BorderSizePixel  = 0
        Instance.new("UICorner", btnPanic).CornerRadius = UDim.new(0, 7)
        btnPanic.MouseButton1Click:Connect(F.ativarPanico)

        local closeBtn = Instance.new("TextButton", topBar)
        closeBtn.Size             = UDim2.new(0, 28, 0, 28)
        closeBtn.Position         = UDim2.new(1, -38, 0.5, -14)
        closeBtn.BackgroundColor3 = Color3.fromRGB(40, 48, 68)
        closeBtn.TextColor3       = Color3.fromRGB(255, 255, 255)
        closeBtn.Font             = Enum.Font.GothamBold
        closeBtn.TextSize         = 12
        closeBtn.Text             = "✕"
        closeBtn.BorderSizePixel  = 0
        Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 7)
        closeBtn.MouseButton1Click:Connect(function()
            main.Visible = false
        end)

        local tabBar = Instance.new("Frame", main)
        tabBar.Size                   = UDim2.new(1, -24, 0, 32)
        tabBar.Position               = UDim2.new(0, 12, 0, 54)
        tabBar.BackgroundTransparency = 1
        UI.tabBar                     = tabBar
        local tll = Instance.new("UIListLayout", tabBar)
        tll.FillDirection = Enum.FillDirection.Horizontal
        tll.Padding       = UDim.new(0, 4)

        local bodyFrame = Instance.new("Frame", main)
        bodyFrame.Size                   = UDim2.new(1, -16, 1, -96)
        bodyFrame.Position               = UDim2.new(0, 8, 0, 90)
        bodyFrame.BackgroundTransparency = 1

        local tabNames = {
            "🚀 Mover",
            "⚔️ Combate",
            "👁️ Visão",
            "🌍 Mundo",
            "🤖 Auto",
            "🎭 Avatar",
            "🌐 Rede",
            "👥 Players",
            "🛡️ Defesa",
            "⚙️ Config",
        }
        UI.tabButtons    = {}
        UI.currentTabIdx = 1

        local function switchTab(idx)
            UI.currentTabIdx = idx
            local curTema = temas[config.temaIndice]
            for j, f in pairs(tabFrames) do
                f.Visible = (j == idx)
            end
            for j, b in pairs(UI.tabButtons) do
                tweenObj(b, {
                    BackgroundColor3 = (j == idx) and curTema.accent or Color3.fromRGB(20, 26, 40),
                    TextColor3       = (j == idx) and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(150, 165, 190),
                }, 0.14)
            end
        end
        UI.switchTab = switchTab

        for i, name in ipairs(tabNames) do
            local tb = Instance.new("TextButton", tabBar)
            tb.Size             = UDim2.new(1 / 10, -4, 0, 28)
            tb.BackgroundColor3 = (i == 1) and temas[1].accent or Color3.fromRGB(20, 26, 40)
            tb.TextColor3       = (i == 1) and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(150, 165, 190)
            tb.Font             = Enum.Font.GothamBold
            tb.TextSize         = 9.5
            tb.Text             = name
            tb.BorderSizePixel  = 0
            tb.LayoutOrder      = i
            Instance.new("UICorner", tb).CornerRadius = UDim.new(0, 6)
            UI.tabButtons[i]    = tb
            tb.MouseButton1Click:Connect(function()
                switchTab(i)
            end)

            local sf = Instance.new("ScrollingFrame", bodyFrame)
            sf.Size                 = UDim2.new(1, 0, 1, 0)
            sf.BackgroundTransparency = 1
            sf.Visible              = (i == 1)
            sf.ScrollBarThickness   = 5
            sf.ScrollBarImageColor3 = temas[1].accent
            sf.AutomaticCanvasSize  = Enum.AutomaticSize.Y
            sf.CanvasSize           = UDim2.new(0, 0, 0, 0)
            sf.BorderSizePixel      = 0
            table.insert(UI.themeAccentObjs, sf)

            local sfl = Instance.new("UIListLayout", sf)
            sfl.Padding   = UDim.new(0, 7)
            sfl.SortOrder = Enum.SortOrder.LayoutOrder

            local sfp = Instance.new("UIPadding", sf)
            sfp.PaddingLeft   = UDim.new(0, 6)
            sfp.PaddingTop    = UDim.new(0, 4)
            sfp.PaddingBottom = UDim.new(0, 12)
            tabFrames[i]      = sf
        end
    end)()

    -- BLOCO 2: ABA 1 - MOBILIDADE, PARKOUR & MACRO PRO
    ;(function()
        local t1 = tabFrames[1]
        mkSection(t1, "Modos Principais")
        local g1 = mkGrid(t1)
        mkToggleCard(g1, "👻 Modo Astral [G]",      "Clone no chão • Corpo a +" .. config.alturaCeu .. "m", Color3.fromRGB(147, 51, 234), "astral",     F.alternarModoAstral)
        mkToggleCard(g1, "🦅 Fly Mode [F]",          "Voo 3D + Shift Turbo",                              Color3.fromRGB(37, 99, 235),  "voo",        F.alternarVoo)
        mkToggleCard(g1, "🧗 Paredes 360° [L]",      "Anda em paredes e tetos",                           Color3.fromRGB(16, 185, 129), "paredes",    F.alternarAndarParedes)
        mkToggleCard(g1, "🦘 Pulo Infinito [P]",     "Pulos ilimitados no ar",                            Color3.fromRGB(5, 150, 105),  "pulo",       F.alternarPuloInfinito)
        mkToggleCard(g1, "🔮 Magic Floor [U]",       "Piso móvel sob os pés",                             Color3.fromRGB(13, 148, 136), "magicfloor", F.alternarMagicFloor)
        mkToggleCard(g1, "🛗 Elevador [End]",        "Sobe/desce com Espaço/Ctrl",                        Color3.fromRGB(124, 58, 237), "elevador",   F.alternarElevador)
        mkToggleCard(g1, "🚀 Jetpack",               "Propulsão contínua ao segurar Espaço",              Color3.fromRGB(249, 115, 22), "jetpack",    F.alternarJetpack)
        mkToggleCard(g1, "❄️ Freeze [Q]",            "Trava posição no ar",                               Color3.fromRGB(56, 189, 248), "freeze",     F.alternarFreeze)
        mkToggleCard(g1, "🎥 Câmera Livre [C]",      "WASD + Botão Direito olha",                         Color3.fromRGB(100, 116, 139),"freecam",    F.alternarCameraLivre)

        mkSection(t1, "Avançado, Veículos & Parkour")
        local g2 = mkGrid(t1)
        mkToggleCard(g2, "🦿 Bhop Glide [F7]",         "Acumula velocidade ao pular",           Color3.fromRGB(20, 184, 166), "bhop",        F.alternarBhop)
        mkToggleCard(g2, "🦘 Super Pulo",              "JumpPower turbinado",                   Color3.fromRGB(16, 185, 129), "superpulo",   F.alternarSuperPulo)
        mkToggleCard(g2, "🧭 Piloto Auto [Home]",      "Caminha na direção da câmera",          Color3.fromRGB(14, 165, 233), "autowalk",    F.alternarAutoWalk)
        mkToggleCard(g2, "🕷️ Spider Climb",           "Escala paredes segurando W",            Color3.fromRGB(234, 88, 12),  "spiderclimb", F.alternarSpiderClimb)
        mkToggleCard(g2, "🌀 Spinbot 360°",            "Gira o avatar em alta velocidade",      Color3.fromRGB(217, 70, 239), "spinbot",     F.alternarSpinbot)
        mkToggleCard(g2, "🏊 Air Swim",                "Nada pelo ar em qualquer lugar",        Color3.fromRGB(6, 182, 212),  "airswim",     F.alternarAirSwim)
        mkToggleCard(g2, "🚗 Vehicle Boost",           "Turbo em carros, barcos e assentos",    Color3.fromRGB(245, 158, 11), "vehboost",    F.alternarVehicleBoost)
        mkToggleCard(g2, "🌉 Path Trail",              "Cria ponte neon sob seus pés no ar",    Color3.fromRGB(168, 85, 247), "pathtrail",   F.alternarPathTrail)
        mkToggleCard(g2, "🏃 Auto-Vault",              "Pula obstáculos baixos sozinho",        Color3.fromRGB(16, 185, 129), "autovault",   F.alternarAutoVault)
        mkActionCard(g2, "⚡ Flash Dash [F10]",        "Impulso direcional rápido",             Color3.fromRGB(217, 70, 239), F.executarDash)
        mkActionCard(g2, "🌀 Blink Dash",              "Teleporte curto para frente",           Color3.fromRGB(99, 102, 241), F.executarBlinkDash)
        mkActionCard(g2, "🪝 Grappling Hook [Y]",      "Gancho neon até o mouse",               Color3.fromRGB(6, 182, 212),  F.dispararGrapple)
        mkActionCard(g2, "🕸️ Spider Swing (Toggle)",   "Corda física estilo Homem-Aranha",      Color3.fromRGB(239, 68, 68),  F.dispararSpiderSwing)
        mkActionCard(g2, "📍 TP Checkpoint [R]",       "Volta ao ponto salvo",                  Color3.fromRGB(234, 88, 12),  F.carregarCheckpoint)
        mkActionCard(g2, "💾 Gravar Checkpoint [Shift+R]", "Salva posição atual",               Color3.fromRGB(249, 115, 22), F.salvarCheckpoint)

        mkSection(t1, "Gravador de Rota (Macro / Waypoints Pro)")
        local gMac = mkGrid(t1)
        mkToggleCard(gMac, "⏺️ Gravar Rota",         "Captura seus passos em tempo real",         Color3.fromRGB(239, 68, 68),  "macrorec",  F.alternarMacroGravar)
        mkToggleCard(gMac, "▶️ Reproduzir Rota",     "Refaz o caminho gravado automaticamente",   Color3.fromRGB(16, 185, 129), "macroplay", F.alternarMacroPlay)
        mkToggleCard(gMac, "🔁 Loop da Rota",        "Repete a rota infinitamente",               Color3.fromRGB(59, 130, 246), "macroloop", function()
            config.macroLoop = not config.macroLoop
            setToggleVisual("macroloop", config.macroLoop)
        end)
        mkToggleCard(gMac, "⏪ Reverso (Ida e Volta)","Reproduz de trás para frente",             Color3.fromRGB(168, 85, 247), "macrorev", function()
            config.macroReverso = not config.macroReverso
            setToggleVisual("macrorev", config.macroReverso)
        end)
        mkActionCard(gMac, "🗑️ Limpar Rota",         "Apaga todos os waypoints gravados",         Color3.fromRGB(100, 116, 139), F.limparMacro)
        setToggleVisual("macroloop", config.macroLoop)

        local mLbl = Instance.new("TextLabel", t1)
        mLbl.Size                   = UDim2.new(1, -12, 0, 20)
        mLbl.BackgroundTransparency = 1
        mLbl.Font                   = Enum.Font.GothamBold
        mLbl.TextSize               = 10
        mLbl.TextColor3             = Color3.fromRGB(170, 185, 215)
        mLbl.TextXAlignment         = Enum.TextXAlignment.Left
        mLbl.Text                   = "🎞️ Waypoints gravados: 0"
        UI.macroCountLbl            = mLbl

        mkSection(t1, "Ajustes de Mobilidade")
        mkSliderCard(t1, "🦅 Velocidade de Voo", 10, 400, 5, function() return config.velocidadeVoo end, function(v) config.velocidadeVoo = v end, " st/s")
        mkSliderCard(t1, "🚀 Força Jetpack", 20, 150, 5, function() return config.jetpackForca end, function(v) config.jetpackForca = v end, "")
        mkSliderCard(t1, "🚗 Velocidade Veículo", 30, 350, 10, function() return config.vehicleSpeed end, function(v) config.vehicleSpeed = v end, " st/s")
        mkSliderCard(t1, "⚡ Força Flash Dash", 30, 250, 5, function() return config.dashForca end, function(v) config.dashForca = v end, " st")
        mkSliderCard(t1, "🌀 Distância Blink Dash", 10, 120, 5, function() return config.blinkDist end, function(v) config.blinkDist = v end, " st")
        mkSliderCard(t1, "🦘 Força Super Pulo", 50, 350, 10, function() return config.superPuloForca end, function(v)
            config.superPuloForca = v
            if config.superPuloAtivo then
                local h = obterHumAtivo()
                if h then h.UseJumpPower = true h.JumpPower = v end
            end
        end, " JP")
    end)()

    -- BLOCO 3: ABA 2 - COMBATE & MIRA AVANÇADA
    ;(function()
        local t2 = tabFrames[2]
        mkSection(t2, "Assistência de Mira & Hitbox")
        local g1 = mkGrid(t2)
        mkToggleCard(g1, "🎯 Aimbot Pro (Botão Dir)", "Trava suavemente no inimigo no FOV",         Color3.fromRGB(239, 68, 68),  "aimbot",     F.alternarAimbot)
        mkToggleCard(g1, "🔮 Predição de Movimento",  "Compensa velocidade do alvo ao mirar",        Color3.fromRGB(6, 182, 212),  "aimpred",    function()
            config.aimbotPredicao = not config.aimbotPredicao
            setToggleVisual("aimpred", config.aimbotPredicao)
        end)
        mkToggleCard(g1, "⭕ Mostrar Círculo FOV",    "Exibe o raio do Aimbot na tela",              Color3.fromRGB(168, 85, 247), "showfov",    function()
            config.aimbotShowFov = not config.aimbotShowFov
            setToggleVisual("showfov", config.aimbotShowFov)
            if UI.fovCircle then UI.fovCircle.Visible = config.aimbotAtivo and config.aimbotShowFov end
        end)
        mkToggleCard(g1, "👥 Aimbot Team Check",      "Ignora jogadores do mesmo time",              Color3.fromRGB(59, 130, 246), "aimteam",    function()
            config.aimbotTeamCheck = not config.aimbotTeamCheck
            setToggleVisual("aimteam", config.aimbotTeamCheck)
        end)
        mkToggleCard(g1, "🧱 Aimbot Wall Check",      "Só mira em quem está visível (Raycast)",      Color3.fromRGB(16, 185, 129), "aimwall",    function()
            config.aimbotWallCheck = not config.aimbotWallCheck
            setToggleVisual("aimwall", config.aimbotWallCheck)
        end)
        mkActionCard(g1, "💀 Alvo: Head / Torso",     "Alterna entre Cabeça e HumanoidRootPart",     Color3.fromRGB(245, 158, 11), function()
            config.aimbotParte = (config.aimbotParte == "Head") and "HumanoidRootPart" or "Head"
            avisar("🎯 Alvo Aimbot", "Mirando em: " .. config.aimbotParte)
        end)
        mkToggleCard(g1, "📦 Hitbox Expander",        "Aumenta hitbox dos outros jogadores",         Color3.fromRGB(217, 70, 239), "hitbox",     F.alternarHitbox)
        mkToggleCard(g1, "⚡ Triggerbot",             "Atira automático ao passar mira no inimigo",  Color3.fromRGB(234, 88, 12),  "triggerbot", F.alternarTriggerbot)
        mkToggleCard(g1, "⚔️ Kill-Aura (Tool)",       "Ativa ferramenta equipada perto de inimigos", Color3.fromRGB(220, 38, 38),  "killaura",   F.alternarKillAura)
        mkToggleCard(g1, "💨 Auto-Dodge",             "Esquiva automaticamente de inimigos próximos",Color3.fromRGB(16, 185, 129), "autododge",  F.alternarAutoDodge)

        setToggleVisual("aimpred", config.aimbotPredicao)
        setToggleVisual("showfov", config.aimbotShowFov)
        setToggleVisual("aimteam", config.aimbotTeamCheck)
        setToggleVisual("aimwall", config.aimbotWallCheck)

        mkSection(t2, "Calibração de Combate")
        mkSliderCard(t2, "⭕ Raio FOV Aimbot", 40, 420, 10, function() return config.aimbotFov end, function(v)
            config.aimbotFov = v
            if UI.fovCircle then
                UI.fovCircle.Size     = UDim2.new(0, v * 2, 0, v * 2)
                UI.fovCircle.Position = UDim2.new(0.5, -v, 0.5, -v)
            end
        end, " px")
        mkSliderCard(t2, "🎯 Suavidade Aimbot", 0.05, 1, 0.05, function() return config.aimbotSuavidade end, function(v) config.aimbotSuavidade = v end, "")
        mkSliderCard(t2, "🔮 Fator Predição", 0.02, 0.4, 0.02, function() return config.aimbotPredicaoFator end, function(v) config.aimbotPredicaoFator = v end, "s")
        mkSliderCard(t2, "📦 Tamanho Hitbox Expander", 2, 25, 1, function() return config.hitboxTamanho end, function(v)
            config.hitboxTamanho = v
            if config.hitboxAtivo then F.aplicarHitboxExpander() end
        end, " st")
        mkSliderCard(t2, "⚔️ Alcance Kill-Aura", 6, 40, 2, function() return config.killAuraRaio end, function(v) config.killAuraRaio = v end, " st")
        mkSliderCard(t2, "💨 Raio Auto-Dodge", 5, 25, 1, function() return config.autoDodgeRaio end, function(v) config.autoDodgeRaio = v end, " st")
    end)()

    -- BLOCO 4: ABA 3 - VISÃO, SKELETON ESP & RADAR 2D
    ;(function()
        local t3 = tabFrames[3]
        mkSection(t3, "ESP Pro, Skeleton & Radar 2D")
        local g1 = mkGrid(t3)
        mkToggleCard(g1, "👁️ ESP Highlight + HP [V]", "Aura, Tool, distância e barra de vida",    Color3.fromRGB(13, 148, 136), "esp",       F.alternarEsp)
        mkToggleCard(g1, "🟦 ESP 2D Box",             "Caixas 2D precisas ao redor dos jogadores", Color3.fromRGB(59, 130, 246), "esp2d",     F.alternarEsp2D)
        mkToggleCard(g1, "🦴 Skeleton ESP",           "Linhas conectando ossos dos jogadores",     Color3.fromRGB(244, 63, 94),  "espskel",   F.alternarEspSkeleton)
        mkToggleCard(g1, "📡 Radar 2D Minimap",       "Minimapa circular ao vivo com direção",     Color3.fromRGB(168, 85, 247), "radar2d",   F.alternarRadar2D)
        mkToggleCard(g1, "👥 ESP Team Check",         "Oculta jogadores do seu time",              Color3.fromRGB(99, 102, 241), "teamcheck", function()
            config.espTeamCheck = not config.espTeamCheck
            setToggleVisual("teamcheck", config.espTeamCheck)
        end)
        mkActionCard(g1, "🎨 Cor do ESP [M]",         "Alterna entre 8 cores neon",                Color3.fromRGB(217, 70, 239), F.alternarCorAura)
        mkToggleCard(g1, "📏 Tracers 3D",             "Linhas neon até cada jogador",              Color3.fromRGB(6, 182, 212),  "tracers",   F.alternarTracers)
        mkToggleCard(g1, "🔘 Radar Prompts [F4]",     "Destaca ProximityPrompts e ClickDetectors", Color3.fromRGB(217, 119, 6),  "radar",     F.alternarRadarInteracoes)
        mkToggleCard(g1, "🔮 Auras Invisíveis [K]",   "Revela partes invisíveis (clique apaga)",   Color3.fromRGB(244, 63, 94),  "auras",     F.alternarDetectorAuras)
        mkToggleCard(g1, "📦 Outline Tracker [O]",    "SelectionBox por distância",                Color3.fromRGB(99, 102, 241), "outline",   F.alternarOutlineTracker)
        mkToggleCard(g1, "🎯 Crosshair Cyber",        "Mira central fixa na tela",                 Color3.fromRGB(16, 185, 129), "crosshair", F.alternarCrosshair)
        mkActionCard(g1, "➕ Estilo Crosshair",       "Cicla: Cruz / Ponto / Círculo / T-Cruz",    Color3.fromRGB(56, 189, 248), function()
            config.crosshairEstilo = (config.crosshairEstilo % 4) + 1
            F.atualizarEstiloCrosshair()
            local nomes = {"Cruz", "Ponto", "Círculo", "T-Cruz"}
            avisar("🎯 Crosshair", "Estilo: " .. nomes[config.crosshairEstilo], 1.2)
        end)

        mkSection(t3, "Óptica & Iluminação")
        local g2 = mkGrid(t3)
        mkToggleCard(g2, "💡 Fullbright [H]",         "Remove escuridão e neblina",                Color3.fromRGB(234, 179, 8),  "fullbright", F.alternarFullbright)
        mkToggleCard(g2, "🌫️ Remover Neblina (NoFog)","Limpa FogEnd e Atmosphere",                 Color3.fromRGB(148, 163, 184),"nofog",      F.alternarNoFog)
        mkToggleCard(g2, "🛸 Modo Drone [F5]",        "Destrava zoom até 2.000 studs",             Color3.fromRGB(99, 102, 241), "drone",      F.alternarDroneMode)
        mkToggleCard(g2, "🔍 Raio-X [X]",             "Paredes semitransparentes",                 Color3.fromRGB(180, 83, 9),   "xray",       F.alternarXRay)
        mkActionCard(g2, "🔭 Seletor FOV [F11]",      "Cicla 70° / 90° / 110° / 30°",              Color3.fromRGB(59, 130, 246), F.ciclarFov)
        mkToggleCard(g2, "🕒 Travar Hora do Dia",     "Controla horário do céu manualmente",       Color3.fromRGB(245, 158, 11), "tod", function()
            config.timeOfDayAtivo = not config.timeOfDayAtivo
            setToggleVisual("tod", config.timeOfDayAtivo)
            Lighting.ClockTime = config.timeOfDayAtivo and config.timeOfDayValor or originalLighting.ClockTime
        end)

        mkSliderCard(t3, "📡 Alcance Radar 2D", 60, 600, 20, function() return config.radar2DRange end, function(v) config.radar2DRange = v end, " st")
        mkSliderCard(t3, "👁️ Distância Máxima ESP", 150, 3000, 50, function() return config.espMaxDist end, function(v) config.espMaxDist = v end, " st")
        mkSliderCard(t3, "🕒 Horário do Céu", 0, 24, 0.5, function() return config.timeOfDayValor end, function(v)
            config.timeOfDayValor = v
            if config.timeOfDayAtivo then Lighting.ClockTime = v end
        end, "h")

        local corCard = Instance.new("Frame", t3)
        corCard.Size             = UDim2.new(1, -12, 0, 32)
        corCard.BackgroundColor3 = Color3.fromRGB(15, 19, 30)
        corCard.BorderSizePixel  = 0
        Instance.new("UICorner", corCard).CornerRadius = UDim.new(0, 8)
        local corEspLbl = Instance.new("TextLabel", corCard)
        corEspLbl.Size                   = UDim2.new(1, -16, 1, 0)
        corEspLbl.Position               = UDim2.new(0, 12, 0, 0)
        corEspLbl.BackgroundTransparency = 1
        corEspLbl.Font                   = Enum.Font.GothamBold
        corEspLbl.TextSize               = 11
        corEspLbl.TextColor3             = coresAura[1].cor
        corEspLbl.TextXAlignment         = Enum.TextXAlignment.Left
        corEspLbl.Text                   = "🎨 Cor ESP Ativa: " .. coresAura[1].nome .. "  ● ● ●"
        UI.corEspLblRef                  = corEspLbl
    end)()

    -- BLOCO 5: ABA 4 - MUNDO, BUILDER & WORKSPACE EXPLORER
    ;(function()
        local t4 = tabFrames[4]
        mkSection(t4, "Part Spawner Pro")
        local g1 = mkGrid(t4)
        mkActionCard(g1, "🧱 Spawnar Bloco",         "Cria um cubo na sua frente",             Color3.fromRGB(168, 85, 247), function() F.spawnarParte("Block") end)
        mkActionCard(g1, "🔮 Spawnar Esfera",        "Cria uma esfera na sua frente",          Color3.fromRGB(6, 182, 212),  function() F.spawnarParte("Sphere") end)
        mkActionCard(g1, "🛢️ Spawnar Cilindro",      "Cria um cilindro",                       Color3.fromRGB(99, 102, 241), function() F.spawnarParte("Cylinder") end)
        mkActionCard(g1, "📐 Spawnar Rampa",         "Cria uma rampa inclinada",               Color3.fromRGB(16, 185, 129), function() F.spawnarParte("Ramp") end)
        mkActionCard(g1, "🛸 Spawnar Plataforma",    "Cria plataforma larga",                  Color3.fromRGB(59, 130, 246), function() F.spawnarParte("Platform") end)
        mkActionCard(g1, "🪜 Spawnar Escada (Truss)","Cria escada vertical escalável",         Color3.fromRGB(245, 158, 11), function() F.spawnarParte("Truss") end)
        mkActionCard(g1, "🪑 Spawnar Assento (Seat)","Cria um assento onde quiser",            Color3.fromRGB(234, 88, 12),  function() F.spawnarParte("Seat") end)
        mkToggleCard(g1, "⚓ Ancorar Partes",        "Partes criadas ficam fixas no ar",       Color3.fromRGB(245, 158, 11), "spanchor", function()
            config.spawnerAnchored = not config.spawnerAnchored
            setToggleVisual("spanchor", config.spawnerAnchored)
        end)
        mkActionCard(g1, "🎨 Material: Neon/FF/Liso","Alterna material do Spawner",            Color3.fromRGB(217, 70, 239), function()
            config.spawnerMaterial = (config.spawnerMaterial == "Neon") and "ForceField" or (config.spawnerMaterial == "ForceField") and "SmoothPlastic" or "Neon"
            avisar("🎨 Material Spawner", config.spawnerMaterial)
        end)
        mkActionCard(g1, "🧹 Limpar Partes Criadas", "Remove todas as peças do Spawner",       Color3.fromRGB(239, 68, 68),  F.limparPartesSpawnadas)
        setToggleVisual("spanchor", config.spawnerAnchored)

        mkSection(t4, "Física de Mundo & Manipulação")
        local g2 = mkGrid(t4)
        mkToggleCard(g2, "🌀 Buraco Negro (Vortex)", "Atrai e gira peças soltas ao redor",     Color3.fromRGB(147, 51, 234), "vortex",       F.alternarVortex)
        mkToggleCard(g2, "🌌 Zona Anti-Gravidade",   "Faz peças móveis próximas flutuarem",    Color3.fromRGB(6, 182, 212),  "antigravzone", F.alternarAntiGravZone)
        mkToggleCard(g2, "🔫 Gravity Gun",           "Clique em peça solta para levitar",      Color3.fromRGB(59, 130, 246), "gravgun",      F.alternarGravGun)
        mkActionCard(g2, "💥 Onda de Choque [Ins]",  "Lança peças móveis ao redor",            Color3.fromRGB(168, 85, 247), F.dispararOndaDeChoque)
        mkActionCard(g2, "🚧 Sem Barreiras Invis.",  "Desativa colisão de paredes invisíveis", Color3.fromRGB(16, 185, 129), F.removerBarreirasInvisiveis)
        mkToggleCard(g2, "🗑️ Modo Apagar [B]",       "Clique em objetos para apagá-los",       Color3.fromRGB(100, 116, 139),"delete",       F.alternarDeleteMode)
        mkActionCard(g2, "↩️ Undo Delete [Z]",       "Restaura últimos 30 objetos apagados",   Color3.fromRGB(234, 88, 12),  F.executarUndoDelete)

        mkSliderCard(t4, "📐 Tamanho das Partes (Spawner)", 2, 40, 2, function() return config.spawnerSize end, function(v) config.spawnerSize = v end, " st")
        mkSliderCard(t4, "🌀 Raio do Buraco Negro", 20, 220, 10, function() return config.vortexRaio end, function(v) config.vortexRaio = v end, " st")

        mkSection(t4, "Workspace Explorer Lite (Teleportar para Modelos)")
        local expBtn = Instance.new("TextButton", t4)
        expBtn.Size             = UDim2.new(1, -12, 0, 28)
        expBtn.BackgroundColor3 = Color3.fromRGB(37, 99, 235)
        expBtn.TextColor3       = Color3.fromRGB(255, 255, 255)
        expBtn.Font             = Enum.Font.GothamBold
        expBtn.TextSize         = 10
        expBtn.Text             = "🧭 LISTAR MODELOS DO WORKSPACE"
        expBtn.BorderSizePixel  = 0
        Instance.new("UICorner", expBtn).CornerRadius = UDim.new(0, 7)

        local expList = Instance.new("Frame", t4)
        expList.Size                   = UDim2.new(1, -12, 0, 0)
        expList.AutomaticSize          = Enum.AutomaticSize.Y
        expList.BackgroundTransparency = 1
        Instance.new("UIListLayout", expList).Padding = UDim.new(0, 4)

        expBtn.MouseButton1Click:Connect(function()
            for _, ch in ipairs(expList:GetChildren()) do
                if ch:IsA("Frame") then ch:Destroy() end
            end
            local cnt = 0
            for _, ch in ipairs(Workspace:GetChildren()) do
                if (ch:IsA("Model") or ch:IsA("Folder")) and ch.Name ~= player.Name and cnt < 25 then
                    cnt = cnt + 1
                    local row = Instance.new("Frame", expList)
                    row.Size             = UDim2.new(1, 0, 0, 28)
                    row.BackgroundColor3 = Color3.fromRGB(15, 19, 30)
                    row.BorderSizePixel  = 0
                    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 5)

                    local nl = Instance.new("TextLabel", row)
                    nl.Size                   = UDim2.new(1, -70, 1, 0)
                    nl.Position               = UDim2.new(0, 8, 0, 0)
                    nl.BackgroundTransparency = 1
                    nl.Font                   = Enum.Font.GothamBold
                    nl.TextSize               = 10
                    nl.TextColor3             = Color3.fromRGB(220, 230, 250)
                    nl.TextXAlignment         = Enum.TextXAlignment.Left
                    nl.Text                   = string.format("[%s] %s", ch.ClassName, ch.Name)
                    nl.TextTruncate           = Enum.TextTruncate.AtEnd

                    local tp = Instance.new("TextButton", row)
                    tp.Size             = UDim2.new(0, 54, 0, 20)
                    tp.Position         = UDim2.new(1, -60, 0.5, -10)
                    tp.BackgroundColor3 = Color3.fromRGB(16, 185, 129)
                    tp.TextColor3       = Color3.fromRGB(255, 255, 255)
                    tp.Font             = Enum.Font.GothamBold
                    tp.TextSize         = 9
                    tp.Text             = "⚡ TP"
                    tp.BorderSizePixel  = 0
                    Instance.new("UICorner", tp).CornerRadius = UDim.new(0, 4)
                    local obj = ch
                    tp.MouseButton1Click:Connect(function()
                        local c = obterCharAtivo()
                        local ok, piv = pcall(function() return obj:GetPivot() end)
                        if ok and c and piv then
                            c:PivotTo(piv + Vector3.new(0, 4, 0))
                            avisar("🧭 Explorer TP", obj.Name)
                        end
                    end)
                end
            end
        end)
    end)()

    -- BLOCO 6: ABA 5 - AUTOMAÇÃO, UTILITÁRIOS & WAYPOINTS NOMEADOS
    ;(function()
        local t5 = tabFrames[5]
        mkSection(t5, "Automação & Farm")
        local g1 = mkGrid(t5)
        mkToggleCard(g1, "🖱️ Auto-Clicker [F9]",     "Cliques contínuos configuráveis",         Color3.fromRGB(244, 63, 94),  "autoclicker",  F.alternarAutoClicker)
        mkToggleCard(g1, "⚡ Auto-Interact Aura",     "Dispara ProximityPrompts próximos",       Color3.fromRGB(234, 88, 12),  "autointeract", F.alternarAutoInteract)
        mkToggleCard(g1, "👆 Auto-ClickDetectors",    "Aciona ClickDetectors ao redor",          Color3.fromRGB(245, 158, 11), "autocd",       F.alternarAutoClickDetectors)
        mkToggleCard(g1, "🧲 Coletor Magnético",      "Puxa peças móveis próximas",              Color3.fromRGB(13, 148, 136), "magnet",       F.alternarMagnet)
        mkToggleCard(g1, "✨ Touch Collect Aura",     "Aciona TouchTransmitters de itens",       Color3.fromRGB(168, 85, 247), "magtouch",     F.alternarMagnetTouch)
        mkToggleCard(g1, "🛡️ Anti-AFK Real [F6]",     "Impede desconexão por inatividade",       Color3.fromRGB(16, 185, 129), "antiafk",      F.alternarAntiAfk)

        mkSection(t5, "Ferramentas & Performance")
        local g2 = mkGrid(t5)
        mkToggleCard(g2, "🚀 FPS Booster",            "Remove sombras e partículas",             Color3.fromRGB(16, 185, 129), "fpsbooster",   F.alternarFpsBooster)
        mkActionCard(g2, "🧼 Remover Texturas/Decals","Deleta Decals e Textures (+FPS)",         Color3.fromRGB(20, 184, 166), F.removerTexturasEDecals)
        mkToggleCard(g2, "👤 Invisibilidade [T]",     "Transparência com restauração exata",     Color3.fromRGB(71, 85, 105),  "invisivel",    F.alternarInvisibilidade)
        mkToggleCard(g2, "🧱 Noclip Total [N]",       "Atravessa paredes com restauração",       Color3.fromRGB(225, 29, 72),  "noclip",       F.alternarNoclip)
        mkToggleCard(g2, "🔍 Inspector 3D [E]",       "Mostra propriedades do objeto mirado",    Color3.fromRGB(6, 182, 212),  "inspector",    F.alternarInspector)
        mkToggleCard(g2, "⚡ Speed Hack [F1]",        "Multiplica velocidade",                   Color3.fromRGB(234, 179, 8),  "speedhack",    F.alternarSpeedHack)
        mkToggleCard(g2, "🌍 Gravidade Custom [F2]",  "Altera gravidade do avatar",              Color3.fromRGB(16, 185, 129), "gravidade",    F.alternarGravidade)
        mkActionCard(g2, "📍 SpawnLocations [F3]",    "Lista spawns do mapa",                    Color3.fromRGB(234, 88, 12),  function() UI.spFrame.Visible = not UI.spFrame.Visible end)
        mkActionCard(g2, "🧹 Limpar Vestígios [Del]", "Remove pisos e feixes temporários",       Color3.fromRGB(239, 68, 68),  F.limparVestigios)

        mkSliderCard(t5, "⚡ Speed Hack Multiplier", 1, 10, 0.5, function() return config.speedHackMultiplier end, function(v)
            config.speedHackMultiplier = v
            if config.speedHackAtivo then
                local h = obterHumAtivo()
                if h then h.WalkSpeed = config.velocidadePadrao * v end
            end
        end, "×")
        mkSliderCard(t5, "🌍 Gravidade (%)", 0, 300, 10, function() return config.gravitacaoPercent end, function(v)
            config.gravitacaoPercent = v
            F.recalcularGravForce()
        end, "%")
        mkSliderCard(t5, "🖱️ Auto-Clicker (CPS)", 1, 50, 1, function() return config.autoClickerCPS end, function(v) config.autoClickerCPS = v end, " cps")

        mkSection(t5, "Slots Rápidos (0-9)  •  Clique = TP  •  Shift+Clique = Salvar")
        local slotBar = Instance.new("Frame", t5)
        slotBar.Size             = UDim2.new(1, -12, 0, 42)
        slotBar.BackgroundColor3 = Color3.fromRGB(15, 19, 30)
        slotBar.BorderSizePixel  = 0
        Instance.new("UICorner", slotBar).CornerRadius = UDim.new(0, 8)
        local sbl = Instance.new("UIListLayout", slotBar)
        sbl.FillDirection       = Enum.FillDirection.Horizontal
        sbl.Padding             = UDim.new(0, 6)
        sbl.HorizontalAlignment = Enum.HorizontalAlignment.Center
        sbl.VerticalAlignment   = Enum.VerticalAlignment.Center

        UI.slotButtons = {}
        for i = 0, 9 do
            local sb = Instance.new("TextButton", slotBar)
            sb.Size             = UDim2.new(0, 74, 0, 30)
            sb.BackgroundColor3 = Color3.fromRGB(22, 28, 42)
            sb.TextColor3       = Color3.fromRGB(130, 145, 170)
            sb.Font             = Enum.Font.GothamBold
            sb.TextSize         = 11
            sb.Text             = (i >= 6) and ("✈️ " .. i) or ("📍 " .. i)
            sb.BorderSizePixel  = 0
            Instance.new("UICorner", sb).CornerRadius = UDim.new(0, 6)
            UI.slotButtons[i]   = sb
            local idx           = i
            sb.MouseButton1Click:Connect(function()
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) or UserInputService:IsKeyDown(Enum.KeyCode.RightShift) then
                    F.salvarSlot(idx)
                else
                    F.carregarSlot(idx)
                end
            end)
        end

        mkSection(t5, "Waypoints Nomeados (Bookmarks)")
        local wpBar = Instance.new("Frame", t5)
        wpBar.Size                   = UDim2.new(1, -12, 0, 34)
        wpBar.BackgroundTransparency = 1
        local wpInput = Instance.new("TextBox", wpBar)
        wpInput.Size               = UDim2.new(1, -120, 0, 30)
        wpInput.BackgroundColor3   = Color3.fromRGB(15, 19, 30)
        wpInput.TextColor3         = Color3.fromRGB(235, 242, 255)
        wpInput.PlaceholderText    = "Nome do local (ex: Loja, Base, Topo)..."
        wpInput.PlaceholderColor3  = Color3.fromRGB(115, 130, 155)
        wpInput.Font               = Enum.Font.Gotham
        wpInput.TextSize           = 10.5
        wpInput.Text               = ""
        wpInput.BorderSizePixel    = 0
        Instance.new("UICorner", wpInput).CornerRadius = UDim.new(0, 7)
        Instance.new("UIPadding", wpInput).PaddingLeft = UDim.new(0, 8)

        local wpAdd = Instance.new("TextButton", wpBar)
        wpAdd.Size             = UDim2.new(0, 112, 0, 30)
        wpAdd.Position         = UDim2.new(1, -112, 0, 0)
        wpAdd.BackgroundColor3 = Color3.fromRGB(16, 185, 129)
        wpAdd.TextColor3       = Color3.fromRGB(255, 255, 255)
        wpAdd.Font             = Enum.Font.GothamBold
        wpAdd.TextSize         = 10
        wpAdd.Text             = "📌 SALVAR LOCAL"
        wpAdd.BorderSizePixel  = 0
        Instance.new("UICorner", wpAdd).CornerRadius = UDim.new(0, 7)

        local wpList = Instance.new("Frame", t5)
        wpList.Size                   = UDim2.new(1, -12, 0, 0)
        wpList.AutomaticSize          = Enum.AutomaticSize.Y
        wpList.BackgroundTransparency = 1
        Instance.new("UIListLayout", wpList).Padding = UDim.new(0, 4)

        local function rebuildWaypoints()
            for _, ch in ipairs(wpList:GetChildren()) do
                if ch:IsA("Frame") then ch:Destroy() end
            end
            for i, wp in ipairs(state.namedWaypoints) do
                local row = Instance.new("Frame", wpList)
                row.Size             = UDim2.new(1, 0, 0, 30)
                row.BackgroundColor3 = Color3.fromRGB(15, 19, 30)
                row.BorderSizePixel  = 0
                Instance.new("UICorner", row).CornerRadius = UDim.new(0, 6)

                local lbl = Instance.new("TextLabel", row)
                lbl.Size                   = UDim2.new(1, -115, 1, 0)
                lbl.Position               = UDim2.new(0, 8, 0, 0)
                lbl.BackgroundTransparency = 1
                lbl.Font                   = Enum.Font.GothamBold
                lbl.TextSize               = 10
                lbl.TextColor3             = Color3.fromRGB(220, 232, 255)
                lbl.TextXAlignment         = Enum.TextXAlignment.Left
                lbl.Text                   = string.format("📌 %s (%.0f, %.0f, %.0f)", wp.name, wp.cf.X, wp.cf.Y, wp.cf.Z)

                local tpB = Instance.new("TextButton", row)
                tpB.Size             = UDim2.new(0, 56, 0, 22)
                tpB.Position         = UDim2.new(1, -92, 0.5, -11)
                tpB.BackgroundColor3 = Color3.fromRGB(37, 99, 235)
                tpB.TextColor3       = Color3.fromRGB(255, 255, 255)
                tpB.Font             = Enum.Font.GothamBold
                tpB.TextSize         = 9
                tpB.Text             = "⚡ TP"
                tpB.BorderSizePixel  = 0
                Instance.new("UICorner", tpB).CornerRadius = UDim.new(0, 4)
                tpB.MouseButton1Click:Connect(function()
                    local c = obterCharAtivo()
                    local r = obterRootAtivo()
                    if c and r then
                        c:PivotTo(wp.cf)
                        r.AssemblyLinearVelocity = Vector3.zero
                    end
                end)

                local delB = Instance.new("TextButton", row)
                delB.Size             = UDim2.new(0, 26, 0, 22)
                delB.Position         = UDim2.new(1, -30, 0.5, -11)
                delB.BackgroundColor3 = Color3.fromRGB(220, 38, 38)
                delB.TextColor3       = Color3.fromRGB(255, 255, 255)
                delB.Font             = Enum.Font.GothamBold
                delB.TextSize         = 9
                delB.Text             = "✕"
                delB.BorderSizePixel  = 0
                Instance.new("UICorner", delB).CornerRadius = UDim.new(0, 4)
                local idx = i
                delB.MouseButton1Click:Connect(function()
                    table.remove(state.namedWaypoints, idx)
                    rebuildWaypoints()
                end)
            end
        end

        wpAdd.MouseButton1Click:Connect(function()
            local r = obterRootAtivo()
            if not r then return end
            local nm = wpInput.Text ~= "" and wpInput.Text or ("Local #" .. (#state.namedWaypoints + 1))
            table.insert(state.namedWaypoints, {name = nm, cf = r.CFrame})
            wpInput.Text = ""
            rebuildWaypoints()
            avisar("📌 Waypoint Salvo", nm, 2, "ok")
        end)
    end)()

    -- BLOCO 7: ABA 6 - AVATAR, EMOTES & EFEITOS VISUAIS
    ;(function()
        local t6 = tabFrames[6]
        mkSection(t6, "Efeitos & Aparência (Client-Side)")
        local g1 = mkGrid(t6)
        mkToggleCard(g1, "✨ Aura de Partículas",   "Emite partículas neon ao seu redor",    Color3.fromRGB(168, 85, 247), "aurapart", F.alternarAuraParticulas)
        mkActionCard(g1, "🎃 Headless (Client)",     "Deixa sua cabeça invisível localmente", Color3.fromRGB(249, 115, 22), F.aplicarHeadlessClient)
        mkActionCard(g1, "🧢 Remover Acessórios",    "Remove chapéus e asas localmente",      Color3.fromRGB(239, 68, 68),  F.removerAcessoriosClient)
        mkActionCard(g1, "⏹️ Parar Emote/Animação",  "Interrompe animação customizada",       Color3.fromRGB(100, 116, 139), F.pararEmoteAtual)

        mkSection(t6, "Tocar Animação por ID")
        local animBar = Instance.new("Frame", t6)
        animBar.Size                   = UDim2.new(1, -12, 0, 34)
        animBar.BackgroundTransparency = 1
        local animInput = Instance.new("TextBox", animBar)
        animInput.Size              = UDim2.new(1, -120, 0, 30)
        animInput.BackgroundColor3  = Color3.fromRGB(15, 19, 30)
        animInput.TextColor3        = Color3.fromRGB(235, 242, 255)
        animInput.PlaceholderText   = "Cole o ID da Animação (ex: 507771019)..."
        animInput.PlaceholderColor3 = Color3.fromRGB(115, 130, 155)
        animInput.Font              = Enum.Font.Gotham
        animInput.TextSize          = 10.5
        animInput.Text              = ""
        animInput.BorderSizePixel   = 0
        Instance.new("UICorner", animInput).CornerRadius = UDim.new(0, 7)
        Instance.new("UIPadding", animInput).PaddingLeft = UDim.new(0, 8)

        local animPlay = Instance.new("TextButton", animBar)
        animPlay.Size             = UDim2.new(0, 112, 0, 30)
        animPlay.Position         = UDim2.new(1, -112, 0, 0)
        animPlay.BackgroundColor3 = Color3.fromRGB(168, 85, 247)
        animPlay.TextColor3       = Color3.fromRGB(255, 255, 255)
        animPlay.Font             = Enum.Font.GothamBold
        animPlay.TextSize         = 10
        animPlay.Text             = "▶️ TOCAR ID"
        animPlay.BorderSizePixel  = 0
        Instance.new("UICorner", animPlay).CornerRadius = UDim.new(0, 7)
        animPlay.MouseButton1Click:Connect(function()
            F.tocarAnimacaoPorId(animInput.Text, "Custom ID")
        end)

        mkSection(t6, "Catálogo Rápido de Emotes (R15 & R6)")
        local gEm = mkGrid(t6)
        for _, em in ipairs(emotesCatalogo) do
            mkActionCard(gEm, em.nome, "Clique para executar emote", Color3.fromRGB(59, 130, 246), function()
                local char = obterCharAtivo()
                local isR15 = char and char:FindFirstChild("UpperTorso") ~= nil
                F.tocarAnimacaoPorId(isR15 and em.idR15 or em.idR6, em.nome)
            end)
        end
    end)()

    -- BLOCO 8: ABA 7 - REDE, CHAT LOGGER, REMOTE SCANNER & SOUND SPY
    ;(function()
        local t7 = tabFrames[7]
        mkSection(t7, "Ações de Servidor")
        local g1 = mkGrid(t7)
        mkActionCard(g1, "🌐 Server Hop (Aleatório)", "Troca para outro servidor público",    Color3.fromRGB(59, 130, 246),  function() F.serverHop(false) end)
        mkActionCard(g1, "🪶 Server Hop (Menor)",     "Busca o servidor mais vazio possível", Color3.fromRGB(6, 182, 212),   function() F.serverHop(true) end)
        mkActionCard(g1, "🔄 Rejoin Server",          "Reconecta no mesmo servidor atual",    Color3.fromRGB(16, 185, 129),  F.rejoinServer)
        mkActionCard(g1, "📋 Copiar IDs",             "Copia PlaceId e JobId do servidor",    Color3.fromRGB(168, 85, 247),  F.copiarInfoServidor)

        local srvInfoLbl = Instance.new("TextLabel", t7)
        srvInfoLbl.Size             = UDim2.new(1, -12, 0, 24)
        srvInfoLbl.BackgroundColor3 = Color3.fromRGB(15, 19, 30)
        srvInfoLbl.Font             = Enum.Font.Code
        srvInfoLbl.TextSize         = 10
        srvInfoLbl.TextColor3       = Color3.fromRGB(180, 205, 245)
        srvInfoLbl.Text             = string.format("  PlaceId: %d  |  Players: %d/%d", game.PlaceId, #Players:GetPlayers(), Players.MaxPlayers)
        srvInfoLbl.TextXAlignment   = Enum.TextXAlignment.Left
        srvInfoLbl.BorderSizePixel  = 0
        Instance.new("UICorner", srvInfoLbl).CornerRadius = UDim.new(0, 6)
        UI.srvInfoLbl = srvInfoLbl

        mkSection(t7, "Chat Logger Ao Vivo")
        local chatBox = Instance.new("TextLabel", t7)
        chatBox.Size             = UDim2.new(1, -12, 0, 110)
        chatBox.BackgroundColor3 = Color3.fromRGB(11, 14, 22)
        chatBox.TextColor3       = Color3.fromRGB(190, 215, 245)
        chatBox.Font             = Enum.Font.Code
        chatBox.TextSize         = 9.5
        chatBox.TextXAlignment   = Enum.TextXAlignment.Left
        chatBox.TextYAlignment   = Enum.TextYAlignment.Top
        chatBox.TextWrapped      = true
        chatBox.Text             = "Aguardando mensagens no chat..."
        chatBox.BorderSizePixel  = 0
        Instance.new("UICorner", chatBox).CornerRadius = UDim.new(0, 8)
        Instance.new("UIPadding", chatBox).PaddingLeft = UDim.new(0, 8)
        UI.chatLogBox = chatBox

        mkSection(t7, "Scanner de Remotes & Sons Tocando")
        local gSc = mkGrid(t7)
        local remList = Instance.new("Frame", t7)
        remList.Size                   = UDim2.new(1, -12, 0, 0)
        remList.AutomaticSize          = Enum.AutomaticSize.Y
        remList.BackgroundTransparency = 1
        Instance.new("UIListLayout", remList).Padding = UDim.new(0, 4)

        mkActionCard(gSc, "📡 Escanear Remotes", "Lista RemoteEvents/Functions", Color3.fromRGB(37, 99, 235), function()
            for _, ch in ipairs(remList:GetChildren()) do
                if ch:IsA("Frame") then ch:Destroy() end
            end
            local count = 0
            for _, root in ipairs({ReplicatedStorage, Workspace}) do
                for _, d in ipairs(root:GetDescendants()) do
                    if (d:IsA("RemoteEvent") or d:IsA("RemoteFunction")) and count < 40 then
                        count = count + 1
                        local row = Instance.new("Frame", remList)
                        row.Size             = UDim2.new(1, 0, 0, 30)
                        row.BackgroundColor3 = Color3.fromRGB(15, 19, 30)
                        row.BorderSizePixel  = 0
                        Instance.new("UICorner", row).CornerRadius = UDim.new(0, 6)

                        local lbl = Instance.new("TextLabel", row)
                        lbl.Size                   = UDim2.new(1, -120, 1, 0)
                        lbl.Position               = UDim2.new(0, 8, 0, 0)
                        lbl.BackgroundTransparency = 1
                        lbl.Font                   = Enum.Font.Code
                        lbl.TextSize               = 9.5
                        lbl.TextXAlignment         = Enum.TextXAlignment.Left
                        lbl.TextColor3             = d:IsA("RemoteEvent") and Color3.fromRGB(250, 204, 21) or Color3.fromRGB(56, 189, 248)
                        lbl.Text                   = string.format("[%s] %s", d:IsA("RemoteEvent") and "RE" or "RF", d:GetFullName())
                        lbl.TextTruncate           = Enum.TextTruncate.AtEnd

                        local cpB = Instance.new("TextButton", row)
                        cpB.Size             = UDim2.new(0, 52, 0, 22)
                        cpB.Position         = UDim2.new(1, -110, 0.5, -11)
                        cpB.BackgroundColor3 = Color3.fromRGB(36, 44, 62)
                        cpB.TextColor3       = Color3.fromRGB(255, 255, 255)
                        cpB.Font             = Enum.Font.GothamBold
                        cpB.TextSize         = 9
                        cpB.Text             = "Copiar"
                        cpB.BorderSizePixel  = 0
                        Instance.new("UICorner", cpB).CornerRadius = UDim.new(0, 4)
                        local rem = d
                        cpB.MouseButton1Click:Connect(function()
                            if setclipboard then
                                setclipboard(rem:GetFullName())
                                avisar("📋 Copiado", rem.Name)
                            end
                        end)
                        if d:IsA("RemoteEvent") then
                            local frB = Instance.new("TextButton", row)
                            frB.Size             = UDim2.new(0, 48, 0, 22)
                            frB.Position         = UDim2.new(1, -54, 0.5, -11)
                            frB.BackgroundColor3 = Color3.fromRGB(220, 38, 38)
                            frB.TextColor3       = Color3.fromRGB(255, 255, 255)
                            frB.Font             = Enum.Font.GothamBold
                            frB.TextSize         = 9
                            frB.Text             = "Fire"
                            frB.BorderSizePixel  = 0
                            Instance.new("UICorner", frB).CornerRadius = UDim.new(0, 4)
                            frB.MouseButton1Click:Connect(function()
                                pcall(function() rem:FireServer() end)
                                avisar("⚡ Fired", rem.Name)
                            end)
                        end
                    end
                end
            end
            avisar("📡 Remotes", count .. " encontrados!")
        end)

        mkActionCard(gSc, "🔊 Audio / Sound Spy", "Lista áudios tocando no Workspace", Color3.fromRGB(234, 88, 12), function()
            for _, ch in ipairs(remList:GetChildren()) do
                if ch:IsA("Frame") then ch:Destroy() end
            end
            local count = 0
            for _, s in ipairs(Workspace:GetDescendants()) do
                if s:IsA("Sound") and s.IsPlaying and count < 35 then
                    count = count + 1
                    local row = Instance.new("Frame", remList)
                    row.Size             = UDim2.new(1, 0, 0, 30)
                    row.BackgroundColor3 = Color3.fromRGB(15, 19, 30)
                    row.BorderSizePixel  = 0
                    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 6)

                    local lbl = Instance.new("TextLabel", row)
                    lbl.Size                   = UDim2.new(1, -70, 1, 0)
                    lbl.Position               = UDim2.new(0, 8, 0, 0)
                    lbl.BackgroundTransparency = 1
                    lbl.Font                   = Enum.Font.Code
                    lbl.TextSize               = 9.5
                    lbl.TextXAlignment         = Enum.TextXAlignment.Left
                    lbl.TextColor3             = Color3.fromRGB(110, 255, 165)
                    lbl.Text                   = string.format("🔊 %s | %s", s.Name, s.SoundId)
                    lbl.TextTruncate           = Enum.TextTruncate.AtEnd

                    local cpB = Instance.new("TextButton", row)
                    cpB.Size             = UDim2.new(0, 56, 0, 22)
                    cpB.Position         = UDim2.new(1, -62, 0.5, -11)
                    cpB.BackgroundColor3 = Color3.fromRGB(36, 44, 62)
                    cpB.TextColor3       = Color3.fromRGB(255, 255, 255)
                    cpB.Font             = Enum.Font.GothamBold
                    cpB.TextSize         = 9
                    cpB.Text             = "Copiar ID"
                    cpB.BorderSizePixel  = 0
                    Instance.new("UICorner", cpB).CornerRadius = UDim.new(0, 4)
                    local sid = s.SoundId
                    cpB.MouseButton1Click:Connect(function()
                        if setclipboard then setclipboard(sid) avisar("📋 Copiado", sid) end
                    end)
                end
            end
            avisar("🔊 Sound Spy", count .. " áudios tocando!")
        end)
    end)()

    -- BLOCO 9: ABA 8 - JOGADORES
    ;(function()
        local t8 = tabFrames[8]
        local topPl = Instance.new("Frame", t8)
        topPl.Size                   = UDim2.new(1, -12, 0, 36)
        topPl.BackgroundTransparency = 1

        local plSearch = Instance.new("TextBox", topPl)
        plSearch.Size              = UDim2.new(1, -240, 0, 30)
        plSearch.Position          = UDim2.new(0, 0, 0, 3)
        plSearch.BackgroundColor3  = Color3.fromRGB(15, 19, 30)
        plSearch.TextColor3        = Color3.fromRGB(235, 242, 255)
        plSearch.PlaceholderText   = "🔍 Filtrar jogador..."
        plSearch.PlaceholderColor3 = Color3.fromRGB(115, 130, 155)
        plSearch.Font              = Enum.Font.Gotham
        plSearch.TextSize          = 10.5
        plSearch.Text              = ""
        plSearch.ClearTextOnFocus  = false
        plSearch.BorderSizePixel   = 0
        Instance.new("UICorner", plSearch).CornerRadius = UDim.new(0, 7)
        Instance.new("UIPadding", plSearch).PaddingLeft = UDim.new(0, 10)

        local stopSpecBtn = Instance.new("TextButton", topPl)
        stopSpecBtn.Size             = UDim2.new(0, 112, 0, 30)
        stopSpecBtn.Position         = UDim2.new(1, -230, 0, 3)
        stopSpecBtn.BackgroundColor3 = Color3.fromRGB(99, 102, 241)
        stopSpecBtn.TextColor3       = Color3.fromRGB(255, 255, 255)
        stopSpecBtn.Font             = Enum.Font.GothamBold
        stopSpecBtn.TextSize         = 10
        stopSpecBtn.Text             = "👁️ Sair Spectate"
        stopSpecBtn.BorderSizePixel  = 0
        Instance.new("UICorner", stopSpecBtn).CornerRadius = UDim.new(0, 7)
        stopSpecBtn.MouseButton1Click:Connect(F.pararSpectate)

        local stopOrbBtn = Instance.new("TextButton", topPl)
        stopOrbBtn.Size             = UDim2.new(0, 110, 0, 30)
        stopOrbBtn.Position         = UDim2.new(1, -112, 0, 3)
        stopOrbBtn.BackgroundColor3 = Color3.fromRGB(220, 38, 38)
        stopOrbBtn.TextColor3       = Color3.fromRGB(255, 255, 255)
        stopOrbBtn.Font             = Enum.Font.GothamBold
        stopOrbBtn.TextSize         = 10
        stopOrbBtn.Text             = "🛸 Parar Orbit/Fol"
        stopOrbBtn.BorderSizePixel  = 0
        Instance.new("UICorner", stopOrbBtn).CornerRadius = UDim.new(0, 7)
        stopOrbBtn.MouseButton1Click:Connect(function()
            config.orbitAtivo  = false
            config.alvoOrbit   = nil
            config.followAtivo = false
            config.alvoFollow  = nil
        end)

        mkSliderCard(t8, "🛸 Raio do Orbit", 4, 50, 1, function() return config.orbitRaio end, function(v) config.orbitRaio = v end, " st")
        mkSliderCard(t8, "🛸 Velocidade do Orbit", 0.5, 10, 0.5, function() return config.orbitVel end, function(v) config.orbitVel = v end, "×")

        local plList = Instance.new("Frame", t8)
        plList.Size                   = UDim2.new(1, -12, 0, 0)
        plList.AutomaticSize          = Enum.AutomaticSize.Y
        plList.BackgroundTransparency = 1
        Instance.new("UIListLayout", plList).Padding = UDim.new(0, 6)

        local function rebuildPlayerList()
            for _, ch in ipairs(plList:GetChildren()) do
                if ch:IsA("Frame") then ch:Destroy() end
            end
            local q      = plSearch.Text:lower()
            local myRoot = obterRootAtivo()
            for _, p in ipairs(Players:GetPlayers()) do
                if (q == "") or p.DisplayName:lower():find(q, 1, true) or p.Name:lower():find(q, 1, true) then
                    local row = Instance.new("Frame", plList)
                    row.Size             = UDim2.new(1, 0, 0, 50)
                    row.BorderSizePixel  = 0
                    row.BackgroundColor3 = (p == player) and Color3.fromRGB(24, 34, 54) or Color3.fromRGB(15, 19, 30)
                    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8)
                    Instance.new("UIStroke", row).Color        = Color3.fromRGB(34, 44, 64)

                    local thumb = Instance.new("ImageLabel", row)
                    thumb.Size                   = UDim2.new(0, 36, 0, 36)
                    thumb.Position               = UDim2.new(0, 8, 0.5, -18)
                    thumb.BackgroundTransparency = 1
                    Instance.new("UICorner", thumb).CornerRadius = UDim.new(1, 0)
                    task.spawn(function()
                        pcall(function()
                            thumb.Image = Players:GetUserThumbnailAsync(p.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
                        end)
                    end)

                    local tRoot   = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
                    local tHum    = p.Character and p.Character:FindFirstChildOfClass("Humanoid")
                    local distStr = (myRoot and tRoot) and string.format("%.0fm", (myRoot.Position - tRoot.Position).Magnitude) or "—"
                    local hpStr   = tHum and string.format("%d%%", math.floor((tHum.Health / math.max(tHum.MaxHealth, 1)) * 100)) or "—"

                    local pName = Instance.new("TextLabel", row)
                    pName.Size                   = UDim2.new(0, 220, 0, 18)
                    pName.Position               = UDim2.new(0, 52, 0, 6)
                    pName.BackgroundTransparency = 1
                    pName.TextColor3             = Color3.fromRGB(245, 248, 255)
                    pName.Font                   = Enum.Font.GothamBold
                    pName.TextSize               = 11
                    pName.TextXAlignment         = Enum.TextXAlignment.Left
                    pName.Text                   = p.DisplayName .. (p == player and " (Você)" or "")

                    local pSub = Instance.new("TextLabel", row)
                    pSub.Size                   = UDim2.new(0, 220, 0, 14)
                    pSub.Position               = UDim2.new(0, 52, 0, 26)
                    pSub.BackgroundTransparency = 1
                    pSub.TextColor3             = Color3.fromRGB(148, 163, 184)
                    pSub.Font                   = Enum.Font.Gotham
                    pSub.TextSize               = 9.5
                    pSub.TextXAlignment         = Enum.TextXAlignment.Left
                    pSub.Text                   = string.format("@%s • 📏 %s • 💚 %s", p.Name, distStr, hpStr)

                    if p ~= player then
                        local function mkPB(xOff, txt, col, fn)
                            local b = Instance.new("TextButton", row)
                            b.Size             = UDim2.new(0, 52, 0, 28)
                            b.Position         = UDim2.new(1, xOff, 0.5, -14)
                            b.BackgroundColor3 = col
                            b.TextColor3       = Color3.fromRGB(255, 255, 255)
                            b.Font             = Enum.Font.GothamBold
                            b.TextSize         = 9
                            b.Text             = txt
                            b.BorderSizePixel  = 0
                            Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
                            b.MouseButton1Click:Connect(fn)
                        end
                        mkPB(-284, "⚡ TP", Color3.fromRGB(37, 99, 235), function()
                            local tr = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
                            local mr = obterRootAtivo()
                            if tr and mr then
                                local c = obterCharAtivo()
                                if c then c:PivotTo(tr.CFrame * CFrame.new(0, 0, -3)) end
                                mr.AssemblyLinearVelocity = Vector3.zero
                            end
                        end)
                        mkPB(-228, "👁️ View", Color3.fromRGB(124, 58, 237), function()
                            local th = p.Character and p.Character:FindFirstChildOfClass("Humanoid")
                            if th then
                                state.spectatingPlayer     = p
                                camera.CameraSubject       = th
                                UI.spectateBanner.Text     = "👁️ " .. p.DisplayName .. " • Sair"
                                UI.spectateBanner.Visible  = true
                            end
                        end)
                        mkPB(-172, "🗡️ Costas", Color3.fromRGB(220, 38, 38),  function() F.executarBackstab(p) end)
                        mkPB(-116, "🛸 Orbit",  Color3.fromRGB(16, 185, 129), function() F.alternarOrbit(p) end)
                        mkPB(-60,  "🧲 Seguir", Color3.fromRGB(234, 88, 12),  function() F.alternarFollow(p) end)
                    end
                end
            end
        end

        plSearch:GetPropertyChangedSignal("Text"):Connect(rebuildPlayerList)
        trackConn(Players.PlayerAdded:Connect(function()
            task.wait(0.5)
            rebuildPlayerList()
        end))
        trackConn(Players.PlayerRemoving:Connect(function(p)
            F.limparEspJogador(p)
            if state.spectatingPlayer == p then F.pararSpectate() end
            if config.alvoOrbit == p then config.orbitAtivo = false config.alvoOrbit = nil end
            if config.alvoFollow == p then config.followAtivo = false config.alvoFollow = nil end
            task.wait(0.1)
            rebuildPlayerList()
        end))
        rebuildPlayerList()
    end)()

    -- BLOCO 10: ABA 9 - DEFESAS BLINDADAS (10 ESCUDOS)
    ;(function()
        local t9 = tabFrames[9]
        mkSection(t9, "Controle Mestre de Blindagem")
        local gM      = mkGrid(t9)
        local defKeys = {
            "antiFling", "antiVoid", "antiRagdoll", "antiSeat", "antiAnchor",
            "autoEmergencyHp", "antiKillbrick", "antiFallDamage", "antiBlind", "velocityCapAtivo",
        }
        mkActionCard(gM, "🛡️ ATIVAR TODAS DEFESAS", "Liga todos os 10 escudos blindados", Color3.fromRGB(16, 185, 129), function()
            for _, k in ipairs(defKeys) do
                config[k] = true
                setToggleVisual(k, true)
            end
            avisar("🛡️ Blindagem Total", "10/10 defesas ativadas!", 2.5, "ok")
        end)
        mkActionCard(gM, "❌ DESATIVAR TODAS DEFESAS", "Desliga todos os escudos", Color3.fromRGB(239, 68, 68), function()
            for _, k in ipairs(defKeys) do
                config[k] = false
                setToggleVisual(k, false)
            end
        end)

        mkSection(t9, "Escudos Individuais")
        local gD   = mkGrid(t9)
        local defs = {
            {"🛡️ Anti-Fling & NoCollide", "antiFling",        "Bloqueia empurrões e colisão",          Color3.fromRGB(56, 189, 248)},
            {"🕳️ Anti-Void Rescue",       "antiVoid",         "Resgata de abismos com Magic Floor",     Color3.fromRGB(168, 85, 247)},
            {"⚡ Anti-Ragdoll",           "antiRagdoll",      "Levanta de tombos instantaneamente",     Color3.fromRGB(16, 185, 129)},
            {"🪑 Anti-Seat",              "antiSeat",         "Impede sentar em cadeiras/armadilhas",   Color3.fromRGB(245, 158, 11)},
            {"⛓️ Anti-Anchor",            "antiAnchor",       "Desancora corpo contra scripts",         Color3.fromRGB(234, 88, 12)},
            {"🩸 Auto-Rescue HP",         "autoEmergencyHp",  "Teleporta se HP cair abaixo do limite",  Color3.fromRGB(239, 68, 68)},
            {"☣️ Anti-Killbrick",         "antiKillbrick",    "Neutraliza lava, ácido e espinhos",      Color3.fromRGB(234, 179, 8)},
            {"🪂 Anti-Dano de Queda",     "antiFallDamage",   "Amortece impacto vertical",              Color3.fromRGB(20, 184, 166)},
            {"🌫️ Anti-Blind Purge",       "antiBlind",        "Remove telas pretas, blur e neblina",     Color3.fromRGB(99, 102, 241)},
            {"🛑 Velocity Cap Guard",     "velocityCapAtivo", "Limita velocidade extrema contra fling", Color3.fromRGB(244, 63, 94)},
        }
        for _, d in ipairs(defs) do
            local tit, key, sub, cor = d[1], d[2], d[3], d[4]
            mkToggleCard(gD, tit, sub, cor, key, function()
                config[key] = not config[key]
                setToggleVisual(key, config[key])
            end)
        end
        mkSliderCard(t9, "🩸 Limite de HP para Auto-Rescue", 10, 80, 5, function() return config.emergencyHpThreshold end, function(v) config.emergencyHpThreshold = v end, "%")
        mkSliderCard(t9, "🛑 Limite Máximo Velocity Cap", 80, 500, 20, function() return config.velocityCapMax end, function(v) config.velocityCapMax = v end, " st/s")
    end)()

    -- BLOCO 11: ABA 10 - CONFIGURAÇÕES, 10 TEMAS, PERFIS A/B/C & TECLAS
    ;(function()
        local t10 = tabFrames[10]
        mkSection(t10, "10 Temas Neon & Chroma Rainbow")
        local themeCard = Instance.new("Frame", t10)
        themeCard.Size             = UDim2.new(1, -12, 0, 46)
        themeCard.BackgroundColor3 = Color3.fromRGB(15, 19, 30)
        themeCard.BorderSizePixel  = 0
        Instance.new("UICorner", themeCard).CornerRadius = UDim.new(0, 8)

        local temaLbl = Instance.new("TextLabel", themeCard)
        temaLbl.Size                   = UDim2.new(0, 230, 1, 0)
        temaLbl.Position               = UDim2.new(0, 12, 0, 0)
        temaLbl.BackgroundTransparency = 1
        temaLbl.Font                   = Enum.Font.GothamBold
        temaLbl.TextSize               = 10.5
        temaLbl.TextColor3             = Color3.fromRGB(220, 232, 255)
        temaLbl.TextXAlignment         = Enum.TextXAlignment.Left
        temaLbl.Text                   = "🎨 Tema Ativo: " .. temas[1].nome
        UI.temaBtnLbl                  = temaLbl

        for i, tm in ipairs(temas) do
            local sw = Instance.new("TextButton", themeCard)
            sw.Size             = UDim2.new(0, 24, 0, 24)
            sw.Position         = UDim2.new(1, -((#temas - i + 1) * 28) - 8, 0.5, -12)
            sw.BackgroundColor3 = tm.accent
            sw.Text             = ""
            sw.BorderSizePixel  = 0
            Instance.new("UICorner", sw).CornerRadius = UDim.new(1, 0)
            local idx = i
            sw.MouseButton1Click:Connect(function()
                config.rainbowTemaAtivo = false
                setToggleVisual("rainbow", false)
                F.aplicarTemaVisual(idx)
            end)
        end

        local gCfg = mkGrid(t10)
        mkToggleCard(gCfg, "🌈 Modo Rainbow Chroma", "Cicla todas as cores RGB na UI", Color3.fromRGB(217, 70, 239), "rainbow", function()
            config.rainbowTemaAtivo = not config.rainbowTemaAtivo
            setToggleVisual("rainbow", config.rainbowTemaAtivo)
        end)
        mkToggleCard(gCfg, "🔕 Modo Silencioso", "Oculta notificações toast", Color3.fromRGB(100, 116, 139), "silencioso", function()
            config.modoSilencioso = not config.modoSilencioso
            setToggleVisual("silencioso", config.modoSilencioso)
        end)
        mkActionCard(gCfg, "💾 Salvar Perfil A", "Grava no slot A", Color3.fromRGB(16, 185, 129), function() F.salvarPerfilJSON("A") end)
        mkActionCard(gCfg, "📂 Carregar Perfil A", "Restaura slot A", Color3.fromRGB(59, 130, 246), function() if F.carregarPerfilJSON("A", false) then F.aplicarTemaVisual(config.temaIndice) end end)
        mkActionCard(gCfg, "💾 Salvar Perfil B", "Grava no slot B", Color3.fromRGB(16, 185, 129), function() F.salvarPerfilJSON("B") end)
        mkActionCard(gCfg, "📂 Carregar Perfil B", "Restaura slot B", Color3.fromRGB(59, 130, 246), function() if F.carregarPerfilJSON("B", false) then F.aplicarTemaVisual(config.temaIndice) end end)
        mkActionCard(gCfg, "💾 Salvar Perfil C", "Grava no slot C", Color3.fromRGB(16, 185, 129), function() F.salvarPerfilJSON("C") end)
        mkActionCard(gCfg, "📂 Carregar Perfil C", "Restaura slot C", Color3.fromRGB(59, 130, 246), function() if F.carregarPerfilJSON("C", false) then F.aplicarTemaVisual(config.temaIndice) end end)
        mkActionCard(gCfg, "🗑️ Descarregar Script", "Remove GUI e desconecta tudo", Color3.fromRGB(239, 68, 68), F.descarregarScript)

        mkSliderCard(t10, "🏃 Velocidade Normal", 8, 100, 2, function() return config.velocidadePadrao end, function(v) config.velocidadePadrao = v end, " st/s")
        mkSliderCard(t10, "💨 Velocidade Sprint", 16, 200, 4, function() return config.velocidadeSprint end, function(v) config.velocidadeSprint = v end, " st/s")
        mkSliderCard(t10, "☁️ Altura Céu Astral", 200, 2500, 50, function() return config.alturaCeu end, function(v) config.alturaCeu = v end, " st")

        mkSection(t10, "Gerenciador de Teclas")
        local resetKb = Instance.new("TextButton", t10)
        resetKb.Size             = UDim2.new(1, -12, 0, 28)
        resetKb.BackgroundColor3 = Color3.fromRGB(37, 99, 235)
        resetKb.TextColor3       = Color3.fromRGB(255, 255, 255)
        resetKb.Font             = Enum.Font.GothamBold
        resetKb.TextSize         = 10
        resetKb.Text             = "🔄 RESTAURAR TODAS AS TECLAS PADRÃO"
        resetKb.BorderSizePixel  = 0
        Instance.new("UICorner", resetKb).CornerRadius = UDim.new(0, 7)

        local kbGrid = Instance.new("Frame", t10)
        kbGrid.Size                   = UDim2.new(1, -12, 0, 0)
        kbGrid.AutomaticSize          = Enum.AutomaticSize.Y
        kbGrid.BackgroundTransparency = 1
        local kgl = Instance.new("UIGridLayout", kbGrid)
        kgl.CellSize    = UDim2.new(0.5, -5, 0, 34)
        kgl.CellPadding = UDim2.new(0, 8, 0, 6)

        local listaTeclas = {
            {"menu", "📋 Menu"}, {"hud", "📊 HUD"}, {"panico", "🚨 Pânico"}, {"checkpoint", "📍 Checkpoint"},
            {"dash", "⚡ Dash"}, {"autowalk", "🧭 Auto-Walk"}, {"autoclicker", "🖱️ Clicker"}, {"astral", "👻 Astral"},
            {"voo", "🦅 Voo"}, {"paredes", "🧗 Paredes"}, {"pulo", "🦘 Pulo Inf"}, {"freeze", "❄️ Freeze"},
            {"grapple", "🪝 Grapple"}, {"magicfloor", "🔮 MagicFloor"}, {"elevador", "🛗 Elevador"}, {"bhop", "🦿 Bhop"},
            {"freecam", "🎥 FreeCam"}, {"invisivel", "👤 Invisível"}, {"choque", "💥 Choque"}, {"limpar", "🧹 Limpar"},
            {"fullbright", "💡 Fullbright"}, {"fov", "🔭 FOV"}, {"drone", "🛸 Drone"}, {"xray", "🔍 Raio-X"},
            {"noclip", "🧱 Noclip"}, {"delete", "🗑️ Apagar"}, {"undo", "↩️ Undo"}, {"inspector", "🔍 Inspector"},
            {"outline", "📦 Outline"}, {"speedhack", "⚡ Speed"}, {"gravidade", "🌍 Gravidade"}, {"spawns", "📍 Spawns"},
            {"radar", "🔘 Prompts"}, {"antiafk", "🛡️ Anti-AFK"}, {"esp", "👁️ ESP"}, {"cor", "🎨 Cor ESP"},
            {"playerlist", "👥 Players"}, {"auras", "🔮 Auras"},
        }
        for _, it in ipairs(listaTeclas) do
            local ak, nm = it[1], it[2]
            local card = Instance.new("Frame", kbGrid)
            card.BackgroundColor3 = Color3.fromRGB(15, 19, 30)
            card.BorderSizePixel  = 0
            Instance.new("UICorner", card).CornerRadius = UDim.new(0, 6)

            local al = Instance.new("TextLabel", card)
            al.Size                   = UDim2.new(1, -104, 1, 0)
            al.Position               = UDim2.new(0, 8, 0, 0)
            al.BackgroundTransparency = 1
            al.Font                   = Enum.Font.GothamBold
            al.TextSize               = 10
            al.TextColor3             = Color3.fromRGB(220, 230, 250)
            al.TextXAlignment         = Enum.TextXAlignment.Left
            al.Text                   = nm

            local ck = teclasConfig[ak]
            local kb = Instance.new("TextButton", card)
            kb.Size             = UDim2.new(0, 66, 0, 22)
            kb.Position         = UDim2.new(1, -96, 0.5, -11)
            kb.BackgroundColor3 = ck and temas[1].accent or Color3.fromRGB(35, 45, 60)
            kb.TextColor3       = ck and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(130, 145, 170)
            kb.Font             = Enum.Font.GothamBold
            kb.TextSize         = 9.5
            kb.Text             = ck and ("[" .. ck.Name .. "]") or "[OFF]"
            kb.BorderSizePixel  = 0
            Instance.new("UICorner", kb).CornerRadius = UDim.new(0, 5)
            UI.keybindButtons[ak] = kb

            local cb = Instance.new("TextButton", card)
            cb.Size             = UDim2.new(0, 22, 0, 22)
            cb.Position         = UDim2.new(1, -26, 0.5, -11)
            cb.BackgroundColor3 = Color3.fromRGB(28, 36, 52)
            cb.TextColor3       = Color3.fromRGB(239, 68, 68)
            cb.Font             = Enum.Font.GothamBold
            cb.TextSize         = 10
            cb.Text             = "✕"
            cb.BorderSizePixel  = 0
            Instance.new("UICorner", cb).CornerRadius = UDim.new(0, 5)

            kb.MouseButton1Click:Connect(function()
                if rebindBtnRef then
                    local ok2 = teclasConfig[rebindAtivo]
                    rebindBtnRef.Text             = ok2 and ("[" .. ok2.Name .. "]") or "[OFF]"
                    rebindBtnRef.BackgroundColor3 = ok2 and temas[config.temaIndice].accent or Color3.fromRGB(35, 45, 60)
                end
                rebindAtivo          = ak
                rebindBtnRef         = kb
                kb.Text              = "[...]"
                kb.BackgroundColor3  = Color3.fromRGB(234, 179, 8)
            end)
            cb.MouseButton1Click:Connect(function()
                teclasConfig[ak]    = nil
                kb.Text             = "[OFF]"
                kb.BackgroundColor3 = Color3.fromRGB(35, 45, 60)
                if rebindAtivo == ak then
                    rebindAtivo  = nil
                    rebindBtnRef = nil
                end
            end)
        end

        resetKb.MouseButton1Click:Connect(function()
            rebindAtivo  = nil
            rebindBtnRef = nil
            local acc    = temas[config.temaIndice].accent
            for k, v in pairs(teclasPadrao) do
                teclasConfig[k] = v
                local b         = UI.keybindButtons[k]
                if b then
                    b.Text             = "[" .. v.Name .. "]"
                    b.BackgroundColor3 = acc
                    b.TextColor3       = Color3.fromRGB(255, 255, 255)
                end
            end
        end)
    end)()

    -- BLOCO 12: MODAL SPAWNS, INSPECTOR 3D & MINI-HUD 7.0
    ;(function()
        local spFrame = Instance.new("Frame", screenGui)
        spFrame.Size             = UDim2.new(0, 340, 0, 320)
        spFrame.Position         = UDim2.new(0.5, -170, 0.5, -160)
        spFrame.BackgroundColor3 = Color3.fromRGB(12, 15, 24)
        spFrame.BorderSizePixel  = 0
        spFrame.Active           = true
        spFrame.Draggable        = true
        spFrame.Visible          = false
        UI.spFrame               = spFrame
        Instance.new("UICorner", spFrame).CornerRadius = UDim.new(0, 10)
        Instance.new("UIStroke", spFrame).Color        = Color3.fromRGB(234, 88, 12)

        local spTit = Instance.new("TextLabel", spFrame)
        spTit.Size                   = UDim2.new(1, -40, 0, 34)
        spTit.Position               = UDim2.new(0, 12, 0, 0)
        spTit.BackgroundTransparency = 1
        spTit.TextColor3             = Color3.fromRGB(255, 255, 255)
        spTit.Font                   = Enum.Font.GothamBold
        spTit.TextSize               = 11
        spTit.TextXAlignment         = Enum.TextXAlignment.Left
        spTit.Text                   = "📍 SpawnLocations do Mapa"

        local spClose = Instance.new("TextButton", spFrame)
        spClose.Size             = UDim2.new(0, 24, 0, 24)
        spClose.Position         = UDim2.new(1, -30, 0, 5)
        spClose.BackgroundColor3 = Color3.fromRGB(239, 68, 68)
        spClose.TextColor3       = Color3.fromRGB(255, 255, 255)
        spClose.Font             = Enum.Font.GothamBold
        spClose.TextSize         = 11
        spClose.Text             = "✕"
        spClose.BorderSizePixel  = 0
        Instance.new("UICorner", spClose).CornerRadius = UDim.new(0, 5)
        spClose.MouseButton1Click:Connect(function()
            spFrame.Visible = false
        end)

        local spScroll = Instance.new("ScrollingFrame", spFrame)
        spScroll.Size                   = UDim2.new(1, -16, 1, -42)
        spScroll.Position               = UDim2.new(0, 8, 0, 36)
        spScroll.BackgroundTransparency = 1
        spScroll.BorderSizePixel        = 0
        spScroll.ScrollBarThickness     = 4
        spScroll.AutomaticCanvasSize    = Enum.AutomaticSize.Y
        spScroll.CanvasSize             = UDim2.new(0, 0, 0, 0)
        Instance.new("UIListLayout", spScroll).Padding = UDim.new(0, 4)

        spFrame:GetPropertyChangedSignal("Visible"):Connect(function()
            if not spFrame.Visible then
                return
            end
            for _, ch in ipairs(spScroll:GetChildren()) do
                if ch:IsA("TextButton") then
                    ch:Destroy()
                end
            end
            local idx = 0
            for _, obj in ipairs(Workspace:GetDescendants()) do
                if obj:IsA("SpawnLocation") then
                    idx = idx + 1
                    local b = Instance.new("TextButton", spScroll)
                    b.Size             = UDim2.new(1, -6, 0, 30)
                    b.BackgroundColor3 = Color3.fromRGB(20, 26, 40)
                    b.TextColor3       = Color3.fromRGB(255, 255, 255)
                    b.Font             = Enum.Font.GothamBold
                    b.TextSize         = 10
                    b.BorderSizePixel  = 0
                    b.Text             = string.format("#%d %s (%.0f, %.0f, %.0f)", idx, obj.Name, obj.Position.X, obj.Position.Y, obj.Position.Z)
                    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 5)
                    b.MouseButton1Click:Connect(function()
                        local r, c = obterRootAtivo(), obterCharAtivo()
                        if r and c then
                            c:PivotTo(obj.CFrame + Vector3.new(0, 3.5, 0))
                            r.AssemblyLinearVelocity = Vector3.zero
                        end
                    end)
                end
            end
        end)

        local inspGui = Instance.new("BillboardGui", screenGui)
        inspGui.Name        = "V12Inspector"
        inspGui.Size        = UDim2.new(0, 240, 0, 114)
        inspGui.AlwaysOnTop = true
        inspGui.Enabled     = false
        UI.inspectorBillboard = inspGui

        local inspFrame = Instance.new("Frame", inspGui)
        inspFrame.Size                   = UDim2.new(1, 0, 1, 0)
        inspFrame.BackgroundColor3       = Color3.fromRGB(10, 13, 22)
        inspFrame.BackgroundTransparency = 0.12
        inspFrame.BorderSizePixel        = 0
        Instance.new("UICorner", inspFrame).CornerRadius = UDim.new(0, 8)
        Instance.new("UIStroke", inspFrame).Color        = Color3.fromRGB(0, 255, 200)

        local inspLbl = Instance.new("TextLabel", inspFrame)
        inspLbl.Size                   = UDim2.new(1, -12, 1, -10)
        inspLbl.Position               = UDim2.new(0, 6, 0, 5)
        inspLbl.BackgroundTransparency = 1
        inspLbl.TextColor3             = Color3.fromRGB(220, 242, 255)
        inspLbl.Font                   = Enum.Font.Code
        inspLbl.TextSize               = 9.5
        inspLbl.TextXAlignment         = Enum.TextXAlignment.Left
        inspLbl.TextYAlignment         = Enum.TextYAlignment.Top
        inspLbl.TextWrapped            = true
        UI.inspectorLabel              = inspLbl

        local hud = Instance.new("Frame", screenGui)
        hud.Name                   = "MiniHUD"
        hud.Size                   = UDim2.new(0, 280, 0, 180)
        hud.Position               = UDim2.new(0, 14, 0.5, -90)
        hud.BackgroundColor3       = Color3.fromRGB(10, 13, 22)
        hud.BackgroundTransparency = 0.14
        hud.BorderSizePixel        = 0
        hud.Active                 = true
        hud.Draggable              = true
        UI.hud                     = hud
        Instance.new("UICorner", hud).CornerRadius = UDim.new(0, 10)
        local hs = Instance.new("UIStroke", hud)
        hs.Color     = temas[1].accent
        hs.Thickness = 1.2
        UI.hudStroke = hs

        local function mkHudLbl(y, h, bold, cor)
            local l = Instance.new("TextLabel", hud)
            l.Size                   = UDim2.new(1, -16, 0, h)
            l.Position               = UDim2.new(0, 8, 0, y)
            l.BackgroundTransparency = 1
            l.TextColor3             = cor or Color3.fromRGB(210, 225, 248)
            l.Font                   = bold and Enum.Font.GothamBold or Enum.Font.Gotham
            l.TextSize               = 10.5
            l.TextXAlignment         = Enum.TextXAlignment.Left
            l.TextTruncate           = Enum.TextTruncate.AtEnd
            return l
        end

        UI.hudTit        = mkHudLbl(6,   16, true,  temas[1].glow)
        UI.hudTit.Text   = "👻 SUITE ASTRAL V12.0 SINGULARITY"
        UI.hudCoords     = mkHudLbl(24,  14, false, Color3.fromRGB(225, 235, 255))
        UI.hudSpeed      = mkHudLbl(39,  14, false, Color3.fromRGB(160, 210, 255))
        UI.hudCheckpoint = mkHudLbl(54,  14, false, Color3.fromRGB(255, 165, 70))
        UI.hudShield     = mkHudLbl(69,  14, true,  Color3.fromRGB(148, 163, 184))
        UI.hudFov        = mkHudLbl(84,  14, false, Color3.fromRGB(100, 220, 255))
        UI.hudModes      = mkHudLbl(100, 14, true,  Color3.fromRGB(80, 255, 140))
        UI.hudModes2     = mkHudLbl(115, 14, true,  Color3.fromRGB(80, 255, 140))
        UI.hudTarget     = mkHudLbl(131, 14, false, Color3.fromRGB(255, 200, 80))
        UI.hudSlots      = mkHudLbl(146, 14, false, Color3.fromRGB(175, 185, 210))
        UI.hudHelp       = mkHudLbl(161, 12, false, Color3.fromRGB(125, 140, 165))
        UI.hudHelp.Text  = "[F8] Menu  •  [F12] Pânico  •  [Tab] HUD"
    end)()
end)()

-- ════════════════════════════════════════════════════════════════════════════════
-- ENTRADA DO USUÁRIO (TECLADO & MOUSE) V12.0
-- ════════════════════════════════════════════════════════════════════════════════
trackConn(UserInputService.InputBegan:Connect(function(input, processed)
    if state.unloaded then
        return
    end

    if input.UserInputType == Enum.UserInputType.Keyboard and rebindAtivo then
        local k = input.KeyCode
        if k ~= Enum.KeyCode.Unknown then
            if k == Enum.KeyCode.Escape or k == Enum.KeyCode.Backspace then
                teclasConfig[rebindAtivo] = nil
                if rebindBtnRef then
                    rebindBtnRef.Text             = "[OFF]"
                    rebindBtnRef.BackgroundColor3 = Color3.fromRGB(35, 45, 60)
                    rebindBtnRef.TextColor3       = Color3.fromRGB(130, 145, 170)
                end
            else
                teclasConfig[rebindAtivo] = k
                if rebindBtnRef then
                    rebindBtnRef.Text             = "[" .. k.Name .. "]"
                    rebindBtnRef.BackgroundColor3 = temas[config.temaIndice].accent
                    rebindBtnRef.TextColor3       = Color3.fromRGB(255, 255, 255)
                end
            end
            rebindAtivo  = nil
            rebindBtnRef = nil
        end
        return
    end

    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        if config.cameraLivreAtiva then
            state.freeCamRotating = true
            UserInputService.MouseBehavior = Enum.MouseBehavior.LockCurrentPosition
            return
        elseif config.aimbotAtivo then
            state.aimbotHolding = true
        end
    end

    if processed then
        return
    end
    if input.UserInputType == Enum.UserInputType.MouseButton3 then
        F.dispararGrapple()
        return
    end

    local k = input.KeyCode
    if teclasConfig.menu and k == teclasConfig.menu then
        UI.main.Visible = not UI.main.Visible
        return
    end
    if teclasConfig.hud and k == teclasConfig.hud then
        UI.hud.Visible = not UI.hud.Visible
        return
    end
    if teclasConfig.panico and k == teclasConfig.panico then
        F.ativarPanico()
        return
    end

    if teclasConfig.checkpoint and k == teclasConfig.checkpoint then
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift)
            or UserInputService:IsKeyDown(Enum.KeyCode.RightShift)
            or UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
            F.salvarCheckpoint()
        else
            F.carregarCheckpoint()
        end
        return
    end

    if teclasConfig.astral      and k == teclasConfig.astral      then F.alternarModoAstral()      return end
    if teclasConfig.voo         and k == teclasConfig.voo         then F.alternarVoo()             return end
    if teclasConfig.paredes     and k == teclasConfig.paredes     then F.alternarAndarParedes()    return end
    if teclasConfig.pulo        and k == teclasConfig.pulo        then F.alternarPuloInfinito()    return end
    if teclasConfig.freeze      and k == teclasConfig.freeze      then F.alternarFreeze()          return end
    if teclasConfig.grapple     and k == teclasConfig.grapple     then F.dispararGrapple()         return end
    if teclasConfig.magicfloor  and k == teclasConfig.magicfloor  then F.alternarMagicFloor()      return end
    if teclasConfig.elevador    and k == teclasConfig.elevador    then F.alternarElevador()        return end
    if teclasConfig.bhop        and k == teclasConfig.bhop        then F.alternarBhop()            return end
    if teclasConfig.dash        and k == teclasConfig.dash        then F.executarDash()            return end
    if teclasConfig.autowalk    and k == teclasConfig.autowalk    then F.alternarAutoWalk()        return end
    if teclasConfig.freecam     and k == teclasConfig.freecam     then F.alternarCameraLivre()     return end
    if teclasConfig.invisivel   and k == teclasConfig.invisivel   then F.alternarInvisibilidade()  return end
    if teclasConfig.choque      and k == teclasConfig.choque      then F.dispararOndaDeChoque()    return end
    if teclasConfig.limpar      and k == teclasConfig.limpar      then F.limparVestigios()         return end

    if k == Enum.KeyCode.PageUp then
        config.velocidadeVoo = math.clamp(config.velocidadeVoo + 10, 10, 400)
        avisar("🦅 Voo", config.velocidadeVoo .. " st/s", 1)
        return
    end
    if k == Enum.KeyCode.PageDown then
        config.velocidadeVoo = math.clamp(config.velocidadeVoo - 10, 10, 400)
        avisar("🦅 Voo", config.velocidadeVoo .. " st/s", 1)
        return
    end

    if teclasConfig.fullbright  and k == teclasConfig.fullbright  then F.alternarFullbright()      return end
    if teclasConfig.fov         and k == teclasConfig.fov         then F.ciclarFov()               return end
    if teclasConfig.drone       and k == teclasConfig.drone       then F.alternarDroneMode()       return end
    if teclasConfig.xray        and k == teclasConfig.xray        then F.alternarXRay()            return end
    if teclasConfig.autoclicker and k == teclasConfig.autoclicker then F.alternarAutoClicker()     return end
    if teclasConfig.noclip      and k == teclasConfig.noclip      then F.alternarNoclip()          return end
    if teclasConfig.delete      and k == teclasConfig.delete      then F.alternarDeleteMode()      return end
    if teclasConfig.undo        and k == teclasConfig.undo        then F.executarUndoDelete()      return end
    if teclasConfig.inspector   and k == teclasConfig.inspector   then F.alternarInspector()       return end
    if teclasConfig.outline     and k == teclasConfig.outline     then F.alternarOutlineTracker()  return end
    if teclasConfig.speedhack   and k == teclasConfig.speedhack   then F.alternarSpeedHack()       return end
    if teclasConfig.gravidade   and k == teclasConfig.gravidade   then F.alternarGravidade()       return end
    if teclasConfig.spawns      and k == teclasConfig.spawns      then UI.spFrame.Visible = not UI.spFrame.Visible return end
    if teclasConfig.radar       and k == teclasConfig.radar       then F.alternarRadarInteracoes() return end
    if teclasConfig.antiafk     and k == teclasConfig.antiafk     then F.alternarAntiAfk()         return end
    if teclasConfig.esp         and k == teclasConfig.esp         then F.alternarEsp()             return end
    if teclasConfig.cor         and k == teclasConfig.cor         then F.alternarCorAura()         return end
    if teclasConfig.auras       and k == teclasConfig.auras       then F.alternarDetectorAuras()   return end
    if teclasConfig.playerlist  and k == teclasConfig.playerlist  then
        UI.main.Visible = true
        if UI.switchTab then
            UI.switchTab(8)
        end
        return
    end

    if UserInputService:IsKeyDown(Enum.KeyCode.RightControl) then
        local s = slotMapa[k]
        if s ~= nil then
            F.salvarSlot(s)
            return
        end
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.RightAlt) or UserInputService:IsKeyDown(Enum.KeyCode.Alt) then
        local s = slotMapa[k]
        if s ~= nil then
            F.carregarSlot(s)
            return
        end
    end
end))

trackConn(UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        if state.freeCamRotating then
            state.freeCamRotating = false
            UserInputService.MouseBehavior = Enum.MouseBehavior.Default
        end
        state.aimbotHolding = false
    end
end))

trackConn(UserInputService.InputChanged:Connect(function(input)
    if state.unloaded then
        return
    end
    if input.UserInputType == Enum.UserInputType.MouseWheel and UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
        camera.FieldOfView = math.clamp(camera.FieldOfView - (input.Position.Z * 5), 15, 120)
    elseif input.UserInputType == Enum.UserInputType.MouseMovement and config.cameraLivreAtiva and state.freeCamRotating then
        state.freeCamYaw   = state.freeCamYaw - (input.Delta.X * config.freeCamSens * 0.01)
        state.freeCamPitch = math.clamp(state.freeCamPitch - (input.Delta.Y * config.freeCamSens * 0.01), -1.5, 1.5)
    end
end))

trackConn(mouse.Button1Down:Connect(function()
    if state.unloaded or config.cameraLivreAtiva then
        return
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
        F.executarClickTeleport()
        return
    end
    if config.gravGunAtivo then
        if state.gravGunPart and state.gravGunPart.Parent then
            local p = state.gravGunPart
            state.gravGunPart = nil
            pcall(function()
                p.AssemblyLinearVelocity = camera.CFrame.LookVector * 185
            end)
            avisar("🔫 Gravity Gun", "Lançado!", 1)
        else
            local t    = mouse.Target
            local char = player.Character
            if t and t:IsA("BasePart") and not t.Anchored and (not char or not t:IsDescendantOf(char)) then
                state.gravGunPart = t
                avisar("🔫 Gravity Gun", "Segurando '" .. t.Name .. "'!", 1.2)
            end
        end
        return
    end
    if config.detectorAurasAtivo then
        local t    = mouse.Target
        local char = player.Character
        if t and t:IsA("BasePart") and (not char or not t:IsDescendantOf(char)) and state.aurasBoxes[t] then
            pcall(function()
                state.aurasBoxes[t]:Destroy()
            end)
            state.aurasBoxes[t]     = nil
            state.aurasOriginais[t] = nil
            t:Destroy()
            return
        end
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.LeftAlt) or config.deleteModeAtivo then
        F.apagarObjetoNoMouse()
    end
end))

trackConn(mouse.Button2Down:Connect(function()
    if state.unloaded or config.cameraLivreAtiva then
        return
    end
    local char = player.Character
    if UserInputService:IsKeyDown(Enum.KeyCode.LeftAlt) then
        local t, root = mouse.Target, obterRootAtivo()
        if t and t:IsA("BasePart") and root and not t.Anchored and (not char or not t:IsDescendantOf(char)) then
            pcall(function()
                t.AssemblyLinearVelocity = ((t.Position - root.Position).Unit + Vector3.new(0, 0.25, 0)) * 155
            end)
        end
    elseif UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
        local h = mouse.Hit
        if h then
            local plat = Instance.new("Part")
            plat.Name       = "SuiteV12TempPlat"
            plat.Size       = Vector3.new(10, 1, 10)
            plat.CFrame     = CFrame.new(h.Position)
            plat.Anchored   = true
            plat.CanCollide = true
            plat.Color      = temas[config.temaIndice].accent
            plat.Material   = Enum.Material.ForceField
            plat.Parent     = Workspace
            table.insert(state.tempPlataformas, plat)
            atualizarRayParams()
            task.delay(15, function()
                if plat and plat.Parent then
                    plat:Destroy()
                end
            end)
        end
    elseif UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
        local t, root = mouse.Target, obterRootAtivo()
        if t and t:IsA("BasePart") and root and not t.Anchored and (not char or not t:IsDescendantOf(char)) then
            pcall(function()
                t.AssemblyLinearVelocity = (root.Position - t.Position).Unit * 75
            end)
        end
    end
end))

-- ════════════════════════════════════════════════════════════════════════════════
-- RENDERSTEPPED (AIMBOT + PREDIÇÃO, 2D BOX ESP, SKELETON ESP, RADAR 2D & CHROMA)
-- ════════════════════════════════════════════════════════════════════════════════
local bonePairsR15 = {
    {"Head", "UpperTorso"}, {"UpperTorso", "LowerTorso"},
    {"UpperTorso", "LeftUpperArm"}, {"LeftUpperArm", "LeftLowerArm"},
    {"UpperTorso", "RightUpperArm"}, {"RightUpperArm", "RightLowerArm"},
    {"LowerTorso", "LeftUpperLeg"}, {"LeftUpperLeg", "LeftLowerLeg"},
    {"LowerTorso", "RightUpperLeg"}, {"RightUpperLeg", "RightLowerLeg"},
}

local bonePairsR6 = {
    {"Head", "Torso"}, {"Torso", "Left Arm"}, {"Torso", "Right Arm"},
    {"Torso", "Left Leg"}, {"Torso", "Right Leg"},
}

trackConn(RunService.RenderStepped:Connect(function(dt)
    if state.unloaded then
        return
    end

    -- RAINBOW CHROMA TEMA
    if config.rainbowTemaAtivo then
        state.rainbowHue = (state.rainbowHue + dt * 0.25) % 1
        local acc  = Color3.fromHSV(state.rainbowHue, 0.85, 0.95)
        local glow = Color3.fromHSV(state.rainbowHue, 0.65, 1.0)
        F.aplicarTemaCorDireta(acc, glow, nil, "🌈 Rainbow Chroma")
    end

    -- AIMBOT SUAVE COM PREDIÇÃO
    if config.aimbotAtivo and state.aimbotHolding and not config.cameraLivreAtiva then
        local targetPart = F.obterAlvoAimbot()
        if targetPart then
            local aimPos = targetPart.Position
            if config.aimbotPredicao then
                aimPos = aimPos + (targetPart.AssemblyLinearVelocity * (config.aimbotPredicaoFator or 0.14))
            end
            local targetCF = CFrame.new(camera.CFrame.Position, aimPos)
            camera.CFrame  = camera.CFrame:Lerp(targetCF, math.clamp(config.aimbotSuavidade or 0.25, 0.05, 1))
        end
    end

    -- ESP 2D BOX
    if config.esp2DBoxAtivo and UI.esp2DLayer then
        local sel    = coresAura[config.corAuraIndice]
        local myRoot = obterRootAtivo()
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= player then
                local char     = p.Character
                local root     = char and char:FindFirstChild("HumanoidRootPart")
                local hum      = char and char:FindFirstChildOfClass("Humanoid")
                local sameTeam = config.espTeamCheck and player.Team and p.Team and (player.Team == p.Team)
                local dist     = (myRoot and root) and (myRoot.Position - root.Position).Magnitude or 99999
                local show     = char and root and hum and hum.Health > 0 and not sameTeam and dist <= config.espMaxDist

                if show then
                    local topPos, on1 = camera:WorldToViewportPoint(root.Position + Vector3.new(0, 3, 0))
                    local botPos, on2 = camera:WorldToViewportPoint(root.Position - Vector3.new(0, 3.2, 0))
                    if on1 or on2 then
                        local h  = math.abs(botPos.Y - topPos.Y)
                        local w  = h * 0.58
                        local bx = UI.esp2DBoxes[p]
                        if not bx then
                            bx = Instance.new("Frame", UI.esp2DLayer)
                            bx.BackgroundTransparency = 1
                            bx.BorderSizePixel        = 0
                            local st = Instance.new("UIStroke", bx)
                            st.Thickness = 1.5
                            st.Color     = sel.cor
                            UI.esp2DBoxes[p] = bx
                        end
                        bx.Visible  = true
                        bx.Size     = UDim2.new(0, w, 0, h)
                        bx.Position = UDim2.new(0, topPos.X - w * 0.5, 0, topPos.Y)
                        local st    = bx:FindFirstChildOfClass("UIStroke")
                        if st then
                            st.Color = sel.cor
                        end
                    elseif UI.esp2DBoxes[p] then
                        UI.esp2DBoxes[p].Visible = false
                    end
                elseif UI.esp2DBoxes[p] then
                    UI.esp2DBoxes[p].Visible = false
                end
            end
        end
    end

    -- SKELETON ESP
    if config.espSkeletonAtivo and UI.esp2DLayer then
        local sel    = coresAura[config.corAuraIndice]
        local myRoot = obterRootAtivo()
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= player then
                local char     = p.Character
                local root     = char and char:FindFirstChild("HumanoidRootPart")
                local hum      = char and char:FindFirstChildOfClass("Humanoid")
                local sameTeam = config.espTeamCheck and player.Team and p.Team and (player.Team == p.Team)
                local dist     = (myRoot and root) and (myRoot.Position - root.Position).Magnitude or 99999
                local show     = char and root and hum and hum.Health > 0 and not sameTeam and dist <= config.espMaxDist

                if show then
                    local pairsList = char:FindFirstChild("UpperTorso") and bonePairsR15 or bonePairsR6
                    local pool      = UI.skeletonLines[p]
                    if not pool then
                        pool = {}
                        for i = 1, 10 do
                            local ln = Instance.new("Frame", UI.esp2DLayer)
                            ln.BorderSizePixel  = 0
                            ln.AnchorPoint      = Vector2.new(0.5, 0.5)
                            ln.BackgroundColor3 = sel.cor
                            ln.Visible          = false
                            pool[i]             = ln
                        end
                        UI.skeletonLines[p] = pool
                    end
                    for i = 1, #pool do
                        local bp = pairsList[i]
                        local ln = pool[i]
                        if bp then
                            local p1 = char:FindFirstChild(bp[1])
                            local p2 = char:FindFirstChild(bp[2])
                            if p1 and p2 then
                                local v1, on1 = camera:WorldToViewportPoint(p1.Position)
                                local v2, on2 = camera:WorldToViewportPoint(p2.Position)
                                if on1 and on2 then
                                    local dx, dy = v2.X - v1.X, v2.Y - v1.Y
                                    local len    = math.sqrt(dx * dx + dy * dy)
                                    ln.Visible          = true
                                    ln.Size             = UDim2.new(0, len, 0, 1.5)
                                    ln.Position         = UDim2.new(0, (v1.X + v2.X) * 0.5, 0, (v1.Y + v2.Y) * 0.5)
                                    ln.Rotation         = math.deg(math.atan2(dy, dx))
                                    ln.BackgroundColor3 = sel.cor
                                else
                                    ln.Visible = false
                                end
                            else
                                ln.Visible = false
                            end
                        else
                            ln.Visible = false
                        end
                    end
                elseif UI.skeletonLines[p] then
                    for _, ln in ipairs(UI.skeletonLines[p]) do
                        ln.Visible = false
                    end
                end
            end
        end
    end

    -- RADAR 2D MINIMAP
    if config.radar2DAtivo and UI.radarFrame then
        local myRoot = obterRootAtivo()
        if myRoot then
            local camLook    = Vector3.new(camera.CFrame.LookVector.X, 0, camera.CFrame.LookVector.Z)
            local yaw        = math.atan2(-camLook.X, -camLook.Z)
            local cosY, sinY = math.cos(yaw), math.sin(yaw)
            local range      = config.radar2DRange or 200

            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= player then
                    local tr  = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
                    local dot = UI.radarDots[p]
                    if tr then
                        if not dot then
                            dot                  = Instance.new("Frame", UI.radarFrame)
                            dot.Size             = UDim2.new(0, 7, 0, 7)
                            dot.BackgroundColor3 = Color3.fromRGB(239, 68, 68)
                            dot.BorderSizePixel  = 0
                            Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)
                            UI.radarDots[p]      = dot
                        end
                        local rel = tr.Position - myRoot.Position
                        local rx  = (rel.X * cosY - rel.Z * sinY) / range
                        local rz  = (rel.X * sinY + rel.Z * cosY) / range
                        local mag = math.sqrt(rx * rx + rz * rz)
                        if mag > 0.92 then
                            rx = (rx / mag) * 0.92
                            rz = (rz / mag) * 0.92
                        end
                        dot.Visible  = true
                        dot.Position = UDim2.new(0.5 + rx * 0.48, -3, 0.5 + rz * 0.48, -3)
                    elseif dot then
                        dot.Visible = false
                    end
                end
            end
        end
    end
end))

-- ════════════════════════════════════════════════════════════════════════════════
-- LOOP PRINCIPAL — HEARTBEAT V12.0
-- ════════════════════════════════════════════════════════════════════════════════
trackConn(RunService.Heartbeat:Connect(function(dt)
    if state.unloaded then
        return
    end
    local char = player.Character
    if not char then
        return
    end
    local realRoot = char:FindFirstChild("HumanoidRootPart")
    local realHum  = char:FindFirstChildOfClass("Humanoid")
    if not realRoot or not realHum then
        return
    end

    local keys = {
        W           = UserInputService:IsKeyDown(Enum.KeyCode.W),
        S           = UserInputService:IsKeyDown(Enum.KeyCode.S),
        A           = UserInputService:IsKeyDown(Enum.KeyCode.A),
        D           = UserInputService:IsKeyDown(Enum.KeyCode.D),
        Space       = UserInputService:IsKeyDown(Enum.KeyCode.Space),
        LeftShift   = UserInputService:IsKeyDown(Enum.KeyCode.LeftShift),
        LeftControl = UserInputService:IsKeyDown(Enum.KeyCode.LeftControl),
    }

    state.frameCount = state.frameCount + 1
    state.fpsTimer   = state.fpsTimer + dt
    if state.fpsTimer >= 1 then
        state.lastFps    = state.frameCount
        state.frameCount = 0
        state.fpsTimer   = 0
        if UI.srvInfoLbl then
            UI.srvInfoLbl.Text = string.format(
                "  PlaceId: %d  |  Players: %d/%d  |  Tempo: %ds",
                game.PlaceId,
                #Players:GetPlayers(),
                Players.MaxPlayers,
                math.floor(tick() - state.serverStartTime)
            )
        end
    end

    if realHum.FloorMaterial ~= Enum.Material.Air and realHum.Health > 0 and realRoot.Position.Y > -50 then
        state.lastSafeCFrame = realRoot.CFrame
    end

    -- DEFESAS
    if config.antiFling then
        F.aplicarNoPlayerCollide()
        if not config.vooAtivo and realRoot.AssemblyLinearVelocity.Magnitude > 250 then
            realRoot.AssemblyLinearVelocity  = Vector3.zero
            realRoot.AssemblyAngularVelocity = Vector3.zero
        end
    end
    if config.velocityCapAtivo and not config.vooAtivo then
        local cap = config.velocityCapMax or 220
        if realRoot.AssemblyLinearVelocity.Magnitude > cap then
            realRoot.AssemblyLinearVelocity = realRoot.AssemblyLinearVelocity.Unit * cap
        end
    end
    F.processarAntiVoid(realRoot)
    F.processarAntiRagdoll(realHum)
    F.processarAntiAnchor(char)
    F.processarEmergencyHp(realRoot, realHum)
    F.processarAntiFallDamage(realRoot, realHum)
    F.limparEfeitosTela()

    state.killbrickTimer = state.killbrickTimer + dt
    if state.killbrickTimer >= 0.35 then
        state.killbrickTimer = 0
        F.escanearKillbricks()
    end

    -- TRIGGERBOT, KILL-AURA & AUTO-DODGE
    if config.triggerbotAtivo then
        state.triggerTimer = state.triggerTimer + dt
        if state.triggerTimer >= (config.triggerDelay or 0.05) then
            state.triggerTimer = 0
            local t = mouse.Target
            if t and t.Parent then
                local tp = Players:GetPlayerFromCharacter(t.Parent) or (t.Parent.Parent and Players:GetPlayerFromCharacter(t.Parent.Parent))
                if tp and tp ~= player then
                    local sameTeam = config.aimbotTeamCheck and player.Team and tp.Team and (player.Team == tp.Team)
                    if not sameTeam and mouse1click then
                        pcall(mouse1click)
                    end
                end
            end
        end
    end

    if config.killAuraAtivo then
        state.killAuraTimer = state.killAuraTimer + dt
        if state.killAuraTimer >= 0.15 then
            state.killAuraTimer = 0
            local tool = char:FindFirstChildOfClass("Tool")
            if tool then
                for _, p in ipairs(Players:GetPlayers()) do
                    if p ~= player and p.Character then
                        local tr = p.Character:FindFirstChild("HumanoidRootPart")
                        local th = p.Character:FindFirstChildOfClass("Humanoid")
                        if tr and th and th.Health > 0 and (tr.Position - realRoot.Position).Magnitude <= config.killAuraRaio then
                            pcall(function()
                                tool:Activate()
                            end)
                            break
                        end
                    end
                end
            end
        end
    end

    if config.autoDodgeAtivo then
        state.dodgeTimer = state.dodgeTimer + dt
        if state.dodgeTimer >= 0.35 then
            local mr = obterRootAtivo()
            if mr then
                for _, p in ipairs(Players:GetPlayers()) do
                    if p ~= player and p.Character then
                        local sameTeam = config.aimbotTeamCheck and player.Team and p.Team and (player.Team == p.Team)
                        local tr       = p.Character:FindFirstChild("HumanoidRootPart")
                        if not sameTeam and tr and (tr.Position - mr.Position).Magnitude <= (config.autoDodgeRaio or 10) then
                            state.dodgeTimer = 0
                            local away = (mr.Position - tr.Position)
                            away = Vector3.new(away.X, 0, away.Z)
                            if away.Magnitude > 0.01 then
                                mr.AssemblyLinearVelocity = away.Unit * 75 + Vector3.new(0, 14, 0)
                            end
                            break
                        end
                    end
                end
            end
        end
    end

    -- VORTEX, ANTI-GRAV ZONE & GRAVITY GUN
    if config.vortexAtivo then
        local root = obterRootAtivo()
        if root then
            local center = root.Position + Vector3.new(0, 6, 0)
            for _, obj in ipairs(Workspace:GetChildren()) do
                if obj:IsA("BasePart") and not obj.Anchored and not obj:IsDescendantOf(char) then
                    local diff = center - obj.Position
                    if diff.Magnitude < config.vortexRaio and diff.Magnitude > 1 then
                        local tangent = diff:Cross(Vector3.new(0, 1, 0)).Unit
                        pcall(function()
                            obj.AssemblyLinearVelocity = (diff.Unit * 35) + (tangent * config.vortexForca)
                        end)
                    end
                end
            end
        end
    end

    if config.antiGravZoneAtivo then
        local root = obterRootAtivo()
        if root then
            for _, obj in ipairs(Workspace:GetChildren()) do
                if obj:IsA("BasePart") and not obj.Anchored and not obj:IsDescendantOf(char) then
                    if (obj.Position - root.Position).Magnitude < 75 then
                        pcall(function()
                            obj.AssemblyLinearVelocity = Vector3.new(obj.AssemblyLinearVelocity.X * 0.96, 8, obj.AssemblyLinearVelocity.Z * 0.96)
                        end)
                    end
                end
            end
        end
    end

    if config.gravGunAtivo and state.gravGunPart and state.gravGunPart.Parent then
        local holdPos = camera.CFrame.Position + (camera.CFrame.LookVector * config.gravGunDist)
        pcall(function()
            state.gravGunPart.AssemblyLinearVelocity  = (holdPos - state.gravGunPart.Position) * 14
            state.gravGunPart.AssemblyAngularVelocity = Vector3.zero
        end)
    end

    -- AUTOMAÇÕES (CLICKER, PROMPTS, CLICKDETECTORS, MAGNET, TOUCH COLLECT)
    if config.autoClickerAtivo then
        state.autoClickerTimer = state.autoClickerTimer + dt
        if state.autoClickerTimer >= (1 / math.max(config.autoClickerCPS or 20, 1)) then
            state.autoClickerTimer = 0
            pcall(function()
                if mouse1click then
                    mouse1click()
                end
            end)
        end
    end

    if config.autoInteractAtivo then
        state.autoInteractTimer = state.autoInteractTimer + dt
        if state.autoInteractTimer >= 0.25 then
            state.autoInteractTimer = 0
            local root = obterRootAtivo()
            if root then
                for _, p in ipairs(Workspace:GetDescendants()) do
                    if p:IsA("ProximityPrompt") and p.Enabled and p.Parent and p.Parent:IsA("BasePart") then
                        if (p.Parent.Position - root.Position).Magnitude <= (p.MaxActivationDistance or 18) then
                            pcall(function()
                                if fireproximityprompt then
                                    fireproximityprompt(p)
                                end
                            end)
                        end
                    end
                end
            end
        end
    end

    if config.autoClickDetectors then
        state.autoClickDetTimer = state.autoClickDetTimer + dt
        if state.autoClickDetTimer >= 0.3 then
            state.autoClickDetTimer = 0
            local root = obterRootAtivo()
            if root and fireclickdetector then
                for _, cd in ipairs(Workspace:GetDescendants()) do
                    if cd:IsA("ClickDetector") and cd.Parent and cd.Parent:IsA("BasePart") then
                        if (cd.Parent.Position - root.Position).Magnitude <= (cd.MaxActivationDistance or 32) then
                            pcall(function()
                                fireclickdetector(cd)
                            end)
                        end
                    end
                end
            end
        end
    end

    if config.magnetAtivo then
        state.magnetTimer = state.magnetTimer + dt
        if state.magnetTimer >= 0.25 then
            state.magnetTimer = 0
            local root = obterRootAtivo()
            if root then
                for _, obj in ipairs(Workspace:GetChildren()) do
                    if obj:IsA("BasePart") and not obj.Anchored and not obj:IsDescendantOf(char) then
                        local diff = root.Position - obj.Position
                        if diff.Magnitude < 55 then
                            pcall(function()
                                obj.AssemblyLinearVelocity = diff.Unit * 45
                            end)
                        end
                    end
                end
            end
        end
    end

    if config.magnetTouchAtivo and firetouchinterest then
        local root = obterRootAtivo()
        if root then
            for _, tt in ipairs(Workspace:GetDescendants()) do
                if tt:IsA("TouchTransmitter") and tt.Parent and tt.Parent:IsA("BasePart") then
                    if not tt.Parent:IsDescendantOf(char) and (tt.Parent.Position - root.Position).Magnitude < 45 then
                        pcall(function()
                            firetouchinterest(root, tt.Parent, 0)
                            firetouchinterest(root, tt.Parent, 1)
                        end)
                    end
                end
            end
        end
    end

    if config.radarInteracoesAtivo then
        state.radarTimer = state.radarTimer + dt
        if state.radarTimer >= 0.35 then
            state.radarTimer = 0
            F.atualizarRadarInteracoes()
        end
    end

    -- MACRO RECORDER & PLAYER
    if config.macroGravando then
        state.macroRecordTimer = state.macroRecordTimer + dt
        if state.macroRecordTimer >= 0.08 then
            state.macroRecordTimer = 0
            local r = obterRootAtivo()
            if r then
                table.insert(state.macroFrames, r.CFrame)
                if UI.macroCountLbl then
                    UI.macroCountLbl.Text = "🎞️ Waypoints gravados: " .. #state.macroFrames
                end
            end
        end
    elseif config.macroReproduzindo and #state.macroFrames > 0 then
        local c = obterCharAtivo()
        local r = obterRootAtivo()
        if c and r then
            c:PivotTo(state.macroFrames[state.macroPlayIdx])
            r.AssemblyLinearVelocity = Vector3.zero
            if config.macroReverso then
                state.macroPlayIdx = state.macroPlayIdx - 1
                if state.macroPlayIdx < 1 then
                    if config.macroLoop then
                        state.macroPlayIdx = #state.macroFrames
                    else
                        config.macroReproduzindo = false
                        setToggleVisual("macroplay", false)
                    end
                end
            else
                state.macroPlayIdx = state.macroPlayIdx + 1
                if state.macroPlayIdx > #state.macroFrames then
                    if config.macroLoop then
                        state.macroPlayIdx = 1
                    else
                        config.macroReproduzindo = false
                        setToggleVisual("macroplay", false)
                    end
                end
            end
        end
    end

    -- JETPACK, VEHICLE BOOST, PATH TRAIL, AUTO-VAULT
    if config.jetpackAtivo and keys.Space and not config.vooAtivo then
        local r = obterRootAtivo()
        if r then
            r.AssemblyLinearVelocity = Vector3.new(r.AssemblyLinearVelocity.X, config.jetpackForca or 55, r.AssemblyLinearVelocity.Z)
        end
    end

    if config.vehicleBoostAtivo and realHum.SeatPart and realHum.SeatPart:IsA("VehicleSeat") then
        local seat = realHum.SeatPart
        local dir  = (keys.W and 1 or 0) - (keys.S and 1 or 0)
        if dir ~= 0 then
            seat.AssemblyLinearVelocity = seat.CFrame.LookVector * (dir * config.vehicleSpeed)
        end
    end

    if config.pathTrailAtivo then
        state.pathTrailTimer = state.pathTrailTimer + dt
        if state.pathTrailTimer >= 0.14 then
            state.pathTrailTimer = 0
            local r = obterRootAtivo()
            if r then
                local p = Instance.new("Part")
                p.Name         = "SuiteV12PathTile"
                p.Size         = Vector3.new(5, 0.6, 5)
                p.CFrame       = CFrame.new(r.Position.X, r.Position.Y - 3.4, r.Position.Z)
                p.Anchored     = true
                p.CanCollide   = true
                p.Material     = Enum.Material.Neon
                p.Color        = temas[config.temaIndice].accent
                p.Transparency = 0.3
                p.Parent       = Workspace
                tweenObj(p, {Transparency = 0.9}, 4.5)
                task.delay(4.6, function()
                    if p and p.Parent then
                        p:Destroy()
                    end
                end)
            end
        end
    end

    if config.autoVaultAtivo and keys.W and realHum.FloorMaterial ~= Enum.Material.Air then
        atualizarRayParams()
        local r = obterRootAtivo()
        if r then
            local lowRay  = Workspace:Raycast(r.Position - Vector3.new(0, 1.5, 0), r.CFrame.LookVector * 3.5, rayParams)
            local highRay = Workspace:Raycast(r.Position + Vector3.new(0, 2.2, 0), r.CFrame.LookVector * 3.5, rayParams)
            if lowRay and not highRay then
                realHum:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end

    -- MAGIC FLOOR
    if config.magicFloorAtivo and state.magicFloorPart and state.magicFloorPart.Parent then
        local r = obterRootAtivo()
        if r then
            if keys.Space then
                state.magicFloorY = (state.magicFloorY or r.Position.Y - 3.5) + (28 * dt)
            end
            if keys.LeftControl then
                state.magicFloorY = (state.magicFloorY or r.Position.Y - 3.5) - (28 * dt)
            end
            state.magicFloorPart.CFrame = CFrame.new(r.Position.X, state.magicFloorY or (r.Position.Y - 3.5), r.Position.Z)
        end
    end

    -- AUTO-WALK, SPIDER, SPINBOT, AIRSWIM, FOLLOW, ORBIT, TRACERS
    if config.autoWalkAtivo and not config.vooAtivo and not config.andarParedesAtivo then
        local flat = Vector3.new(camera.CFrame.LookVector.X, 0, camera.CFrame.LookVector.Z)
        if flat.Magnitude > 0.01 then
            realHum:Move(flat.Unit, false)
        end
    end
    if config.spiderClimbAtivo and not config.vooAtivo and keys.W then
        atualizarRayParams()
        local r = obterRootAtivo()
        if r then
            local fr = Workspace:Raycast(r.Position, r.CFrame.LookVector * 2.8, rayParams)
            if fr and fr.Instance and math.abs(fr.Normal.Y) < 0.4 then
                r.AssemblyLinearVelocity = Vector3.new(r.AssemblyLinearVelocity.X, 28, r.AssemblyLinearVelocity.Z)
            end
        end
    end
    if config.spinbotAtivo then
        local r = obterRootAtivo()
        if r then
            r.CFrame = r.CFrame * CFrame.Angles(0, config.spinbotSpeed * dt, 0)
        end
    end
    if config.airSwimAtivo then
        local h = obterHumAtivo()
        if h and h:GetState() ~= Enum.HumanoidStateType.Swimming then
            h:ChangeState(Enum.HumanoidStateType.Swimming)
        end
    end
    if config.followAtivo and config.alvoFollow and config.alvoFollow.Character then
        local tr = config.alvoFollow.Character:FindFirstChild("HumanoidRootPart")
        local mr = obterRootAtivo()
        if tr and mr then
            mr.CFrame                 = tr.CFrame * CFrame.new(0, 0, 3.5)
            mr.AssemblyLinearVelocity = Vector3.zero
        end
    end
    if config.orbitAtivo and config.alvoOrbit and config.alvoOrbit.Character then
        local tr = config.alvoOrbit.Character:FindFirstChild("HumanoidRootPart")
        local mr = obterRootAtivo()
        if tr and mr then
            config.orbitAngulo        = (config.orbitAngulo or 0) + (dt * (config.orbitVel or 2.5))
            mr.CFrame                 = CFrame.new(
                tr.Position + Vector3.new(math.cos(config.orbitAngulo) * config.orbitRaio, 4, math.sin(config.orbitAngulo) * config.orbitRaio),
                tr.Position
            )
            mr.AssemblyLinearVelocity = Vector3.zero
        end
    end
    if config.tracersAtivo then
        local myRoot = obterRootAtivo()
        if myRoot then
            local sel = coresAura[config.corAuraIndice]
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= player and p.Character then
                    local tr = p.Character:FindFirstChild("HumanoidRootPart")
                    if tr then
                        local t = state.tracersCache[p]
                        if not t or not t.Parent then
                            t             = Instance.new("LineHandleAdornment", Workspace.CurrentCamera)
                            t.Thickness   = 2
                            t.ZIndex      = 5
                            t.AlwaysOnTop = true
                            state.tracersCache[p] = t
                        end
                        t.Adornee = Workspace.Terrain
                        t.CFrame  = CFrame.new(myRoot.Position, tr.Position)
                        t.Length  = (tr.Position - myRoot.Position).Magnitude
                        t.Color3  = sel.cor
                    elseif state.tracersCache[p] then
                        state.tracersCache[p]:Destroy()
                        state.tracersCache[p] = nil
                    end
                end
            end
        end
    end

    -- MODO ASTRAL
    if config.modoAstralAtivo and state.copiaPersonagem and state.copiaPersonagem.Parent then
        local cHum  = state.copiaPersonagem:FindFirstChildOfClass("Humanoid")
        local cRoot = state.copiaPersonagem:FindFirstChild("HumanoidRootPart")
        if cHum and cRoot then
            local camCF = camera.CFrame
            local fwd   = Vector3.new(camCF.LookVector.X, 0, camCF.LookVector.Z)
            local rgt   = Vector3.new(camCF.RightVector.X, 0, camCF.RightVector.Z)
            if fwd.Magnitude > 0.001 then fwd = fwd.Unit end
            if rgt.Magnitude > 0.001 then rgt = rgt.Unit end
            local md = Vector3.zero
            if keys.W then md = md + fwd end
            if keys.S then md = md - fwd end
            if keys.D then md = md + rgt end
            if keys.A then md = md - rgt end
            local mov = md.Magnitude > 0.1
            if mov then md = md.Unit end
            cHum.WalkSpeed = (keys.LeftShift and config.velocidadeSprint or config.velocidadePadrao) * (config.speedHackAtivo and config.speedHackMultiplier or 1)
            cHum:Move(md, false)
            if mov then cRoot.CFrame = CFrame.new(cRoot.Position, cRoot.Position + md) end
            if keys.Space and cHum.FloorMaterial ~= Enum.Material.Air then
                cHum:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
        realHum.PlatformStand            = true
        realRoot.AssemblyLinearVelocity  = Vector3.zero
        realRoot.AssemblyAngularVelocity = Vector3.zero
        local sc                         = state.plataformaCeu.Position
        realRoot.CFrame                  = CFrame.new(sc.X, sc.Y + 3.5, sc.Z)
    end

    -- PULO INFINITO, VOO, PAREDES, ELEVADOR, BHOP, FREEZE, NOCLIP, FREECAM
    if config.puloInfinitoAtivo and keys.Space and not config.vooAtivo and not config.andarParedesAtivo then
        local h = obterHumAtivo()
        if h then
            h:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
    if config.vooAtivo and not config.modoAstralAtivo then
        local camCF, fd = camera.CFrame, Vector3.zero
        if keys.W then fd = fd + camCF.LookVector end
        if keys.S then fd = fd - camCF.LookVector end
        if keys.D then fd = fd + camCF.RightVector end
        if keys.A then fd = fd - camCF.RightVector end
        if keys.Space then fd = fd + Vector3.new(0, 1, 0) end
        if keys.LeftControl then fd = fd - Vector3.new(0, 1, 0) end
        local vel = config.velocidadeVoo * (keys.LeftShift and config.multiplicadorSprintVoo or 1) * (config.speedHackAtivo and config.speedHackMultiplier or 1)
        realRoot.AssemblyLinearVelocity  = (fd.Magnitude > 0.001) and (fd.Unit * vel) or Vector3.zero
        realRoot.AssemblyAngularVelocity = Vector3.zero
    end
    if config.andarParedesAtivo and not config.modoAstralAtivo then
        atualizarRayParams()
        local dirs = {
            Vector3.new(0, -3.8, 0), Vector3.new(0, 3.8, 0),
            realRoot.CFrame.LookVector * 3.5, -realRoot.CFrame.LookVector * 3.5,
            realRoot.CFrame.RightVector * 3.5, -realRoot.CFrame.RightVector * 3.5,
        }
        local ch, cd = nil, 999
        for _, d in ipairs(dirs) do
            local r = Workspace:Raycast(realRoot.Position, d, rayParams)
            if r and r.Instance and r.Instance.CanCollide and (r.Position - realRoot.Position).Magnitude < cd then
                cd = (r.Position - realRoot.Position).Magnitude
                ch = r
            end
        end
        if ch then
            local n, camCF = ch.Normal, camera.CFrame
            local fp       = camCF.LookVector - n * camCF.LookVector:Dot(n)
            local rp       = camCF.RightVector - n * camCF.RightVector:Dot(n)
            if fp.Magnitude > 0.001 then fp = fp.Unit end
            if rp.Magnitude > 0.001 then rp = rp.Unit end
            local md = Vector3.zero
            if keys.W then md = md + fp end
            if keys.S then md = md - fp end
            if keys.D then md = md + rp end
            if keys.A then md = md - rp end
            local spd = (keys.LeftShift and config.velocidadeSprint or config.velocidadePadrao) * (config.speedHackAtivo and config.speedHackMultiplier or 1)
            local np  = ch.Position + n * 3
            if md.Magnitude > 0.001 then
                np = realRoot.Position + md.Unit * spd * dt
                local wr = Workspace:Raycast(np, -n * 4.5, rayParams)
                if wr and wr.Instance then
                    np = wr.Position + n * 3
                    n  = wr.Normal
                end
            end
            realRoot.CFrame                  = CFrame.lookAt(np, np + (md.Magnitude > 0.001 and md.Unit or fp), n)
            realRoot.AssemblyLinearVelocity  = Vector3.zero
            realRoot.AssemblyAngularVelocity = Vector3.zero
            realHum.PlatformStand            = true
        else
            realHum.PlatformStand = false
        end
    end
    if config.elevadorAtivo and not config.vooAtivo and not config.modoAstralAtivo then
        realRoot.AssemblyLinearVelocity = Vector3.new(
            realRoot.AssemblyLinearVelocity.X,
            keys.Space and config.elevadorVelocidade or (keys.LeftControl and -config.elevadorVelocidade or 0),
            realRoot.AssemblyLinearVelocity.Z
        )
    end
    if config.bhopAtivo and not config.vooAtivo and not config.modoAstralAtivo then
        local g = (realHum.FloorMaterial ~= Enum.Material.Air)
        if g and not state.bhopGrounded then
            local fv = Vector3.new(realRoot.AssemblyLinearVelocity.X, 0, realRoot.AssemblyLinearVelocity.Z)
            if fv.Magnitude > 5 then
                realHum:ChangeState(Enum.HumanoidStateType.Jumping)
                realRoot.AssemblyLinearVelocity = fv * 1.08 + Vector3.new(0, realHum.JumpPower or 50, 0)
            end
        end
        state.bhopGrounded = g
    end
    if config.freezeAtivo and not config.modoAstralAtivo then
        realRoot.Anchored                = true
        realRoot.AssemblyLinearVelocity  = Vector3.zero
        realRoot.AssemblyAngularVelocity = Vector3.zero
    end
    if config.noclipAtivo then
        local m = obterCharAtivo()
        if m then
            for _, p in ipairs(m:GetDescendants()) do
                if p:IsA("BasePart") then
                    if state.noclipOriginal[p] == nil then
                        state.noclipOriginal[p] = p.CanCollide
                    end
                    if p.CanCollide then
                        p.CanCollide = false
                    end
                end
            end
        end
    end
    if config.cameraLivreAtiva then
        local rcf = CFrame.fromEulerAnglesYXZ(state.freeCamPitch, state.freeCamYaw, 0)
        local mv  = Vector3.zero
        if keys.W then mv = mv + rcf.LookVector end
        if keys.S then mv = mv - rcf.LookVector end
        if keys.D then mv = mv + rcf.RightVector end
        if keys.A then mv = mv - rcf.RightVector end
        if keys.Space then mv = mv + Vector3.new(0, 1, 0) end
        if keys.LeftControl then mv = mv - Vector3.new(0, 1, 0) end
        state.freeCamCFrame = CFrame.new(state.freeCamCFrame.Position + mv * (config.freeCamSpeed * (keys.LeftShift and 2.5 or 1) * dt)) * rcf
        camera.CFrame       = state.freeCamCFrame
    end

    -- ESP THROTTLED, INSPECTOR, OUTLINE, MINI-HUD 7.0
    state.espThrottleTimer = state.espThrottleTimer + dt
    if config.espAtivo and state.espThrottleTimer >= 0.05 then
        state.espThrottleTimer = 0
        for _, p in ipairs(Players:GetPlayers()) do
            F.atualizarEspJogador(p)
        end
    end
    if config.inspectorAtivo and UI.inspectorBillboard and UI.inspectorLabel then
        local t = mouse.Target
        if t and t ~= state.inspectorTarget then
            state.inspectorTarget        = t
            UI.inspectorBillboard.Adornee = t
            UI.inspectorBillboard.Enabled = true
        elseif not t then
            UI.inspectorBillboard.Enabled = false
            state.inspectorTarget         = nil
        end
        if t then
            pcall(function()
                UI.inspectorLabel.Text = string.format(
                    "📦 %s [%s]\nPos: %.0f,%.0f,%.0f\nSz: %.1f×%.1f×%.1f\nMat: %s | CC:%s Anch:%s",
                    t.Name, t.ClassName,
                    t.Position.X, t.Position.Y, t.Position.Z,
                    t.Size.X, t.Size.Y, t.Size.Z,
                    tostring(t.Material):gsub("Enum.Material.", ""),
                    tostring(t.CanCollide), tostring(t.Anchored)
                )
            end)
        end
    end
    if config.outlineTrackerAtivo then
        local t = mouse.Target
        if t and t ~= state.outlineTarget then
            state.outlineTarget = t
            if state.outlineBox then
                state.outlineBox:Destroy()
            end
            local sb = Instance.new("SelectionBox", Workspace)
            sb.Adornee       = t
            local d          = (realRoot.Position - t.Position).Magnitude
            sb.Color3        = d < 20 and Color3.fromRGB(255, 50, 50) or d < 60 and Color3.fromRGB(255, 200, 0) or Color3.fromRGB(50, 200, 255)
            sb.LineThickness = 0.06
            state.outlineBox = sb
        elseif not t and state.outlineBox then
            state.outlineBox:Destroy()
            state.outlineBox    = nil
            state.outlineTarget = nil
        end
    end

    if config.miniHudAtivo and UI.hudCoords then
        local pos = realRoot.Position
        UI.hudCoords.Text      = string.format("🌐 X:%.0f  Y:%.0f  Z:%.0f", pos.X, pos.Y, pos.Z)
        UI.hudSpeed.Text       = string.format("⚡ %.0f st/s  •  FPS: %d", realRoot.AssemblyLinearVelocity.Magnitude, state.lastFps)
        UI.hudSpeed.TextColor3 = state.lastFps >= 45 and Color3.fromRGB(110, 255, 165) or state.lastFps >= 25 and Color3.fromRGB(250, 204, 21) or Color3.fromRGB(239, 68, 68)
        UI.hudCheckpoint.Text  = config.checkpointPos and string.format("📍 CP: %.0f,%.0f,%.0f (%.0fm)", config.checkpointPos.X, config.checkpointPos.Y, config.checkpointPos.Z, (pos - config.checkpointPos.Position).Magnitude) or "📍 CP: Nenhum [Shift+R]"
        local ad = 0
        for _, dk in ipairs({"antiFling", "antiVoid", "antiRagdoll", "antiAnchor", "autoEmergencyHp", "antiKillbrick", "antiFallDamage", "antiBlind", "antiSeat", "velocityCapAtivo"}) do
            if config[dk] then
                ad = ad + 1
            end
        end
        UI.hudShield.Text       = ad > 0 and ("🛡️ Escudo: " .. ad .. "/10 ATIVO") or "🛡️ Escudo: OFF"
        UI.hudShield.TextColor3 = ad > 0 and Color3.fromRGB(56, 189, 248) or Color3.fromRGB(148, 163, 184)
        UI.hudFov.Text          = string.format("🔭 FOV: %.0f° [F11 / Shift+Scroll]", camera.FieldOfView)
        local md = {}
        if config.modoAstralAtivo then table.insert(md, "👻AST") end
        if config.vooAtivo then table.insert(md, "🦅VOO") end
        if config.aimbotAtivo then table.insert(md, "🎯AIM") end
        if config.hitboxAtivo then table.insert(md, "📦HBX") end
        if config.espAtivo or config.esp2DBoxAtivo or config.espSkeletonAtivo then table.insert(md, "👁ESP") end
        if config.noclipAtivo then table.insert(md, "🧱NCP") end
        if config.vortexAtivo then table.insert(md, "🌀VTX") end
        if config.radar2DAtivo then table.insert(md, "📡RAD") end
        if config.speedHackAtivo then table.insert(md, "⚡SPD") end
        if config.magicFloorAtivo then table.insert(md, "🔮FLR") end
        if config.jetpackAtivo then table.insert(md, "🚀JET") end
        UI.hudModes.Text  = #md > 0 and table.concat(md, " ", 1, math.min(6, #md)) or "✅ Modos OFF"
        UI.hudModes2.Text = #md > 6 and table.concat(md, " ", 7, math.min(12, #md)) or ""
        local t           = mouse.Target
        UI.hudTarget.Text = t and ("🎯 " .. t.Name .. " (" .. t.ClassName .. ")") or "🎯 —"
        local ss          = "💾 "
        for i = 0, 9 do
            ss = ss .. (state.slotsPosicoes[i] and "■" or "□")
        end
        UI.hudSlots.Text = ss
    end
end))

atualizarRayParams()
if F.carregarPerfilJSON("A", true) then
    F.aplicarTemaVisual(config.temaIndice)
end
setToggleVisual("antiafk", config.antiAfkAtivo)
avisar("👻 Suite Astral V12.0 SINGULARITY!", "[F8] Menu • 10 Abas • 100+ Sistemas Carregados", 4, "ok")
