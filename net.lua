--[[
    ═══════════════════════════════════════════════════════════════════════════════
    👻 SUITE ASTRAL V9.0 APEX DEFENDER & OVERLORD — FÍSICA, DEFESA & MOBILIDADE
    ═══════════════════════════════════════════════════════════════════════════════
    45+ Sistemas | 5 Abas com Rolagem | Mini-HUD 4.0 | Defesa Blindada Definitiva
    Anti-Fling | Anti-Void | Anti-Ragdoll | Anti-Anchor | Auto-Rescue HP Baixo
    Anti-Killbrick | No Fall Damage | Anti-Blind | Flash Dash [F10] | Super Pulo
    Auto-Walk [Home] | Spider Climb | Auto-Clicker Turbo [F9] | Auto-Interact Aura
    Coletor Magnético | FPS Booster | Tracers 3D | Backstab TP | Auto-Orbit 360°
    Gerenciador de Teclas Customizáveis (Remapear / Desativar Qualquer Atalho)
    Seletor de Temas Visuais Neon | Panic Mode [F12] | Checkpoint Blindado [R]
    ═══════════════════════════════════════════════════════════════════════════════
]]

-- SERVICES
local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace        = game:GetService("Workspace")
local StarterGui       = game:GetService("StarterGui")
local TweenService     = game:GetService("TweenService")
local Lighting         = game:GetService("Lighting")

local player = Players.LocalPlayer
local camera = Workspace.CurrentCamera
local mouse  = player:GetMouse()

-- ════════════════════════════════════════════════════════════════════════════════
-- CONFIGURAÇÕES GLOBAIS V9.0
-- ════════════════════════════════════════════════════════════════════════════════
local config = {
    -- Mobilidade
    modoAstralAtivo        = false,
    alturaCeu              = 850,
    vooAtivo               = false,
    velocidadeVoo          = 50,
    multiplicadorSprintVoo = 2.5,
    velocidadeSprint       = 32,
    velocidadePadrao       = 16,
    puloInfinitoAtivo      = false,
    andarParedesAtivo      = false,
    freezeAtivo            = false,
    cameraLivreAtiva       = false,
    checkpointPos          = nil,
    invisibilidadeAtiva    = false,
    freeCamSpeed           = 30,
    grappleAtivo           = false,
    magicFloorAtivo        = false,
    elevadorAtivo          = false,
    elevadorVelocidade     = 30,
    bhopAtivo              = false,
    dashForca              = 70,
    superPuloAtivo         = false,
    superPuloForca         = 120,
    autoWalkAtivo          = false,
    spiderClimbAtivo       = false,

    -- Visão & Óptica
    fullbrightAtivo        = false,
    droneModeAtivo         = false,
    fovIndice              = 1,
    cameraFovOriginal      = camera.FieldOfView,
    cameraZoomOriginal     = player.CameraMaxZoomDistance,
    xrayAtivo              = false,
    espAtivo               = false,
    corAuraIndice          = 1,
    outlineTrackerAtivo    = false,
    tracersAtivo           = false,
    orbitAtivo             = false,
    alvoOrbit              = nil,
    orbitRaio              = 14,
    orbitVel               = 2,
    orbitAngulo            = 0,

    -- Utilitários & Interações
    antiAfkAtivo           = true,
    radarInteracoesAtivo   = false,
    noclipAtivo            = false,
    deleteModeAtivo        = false,
    inspectorAtivo         = false,
    speedHackAtivo         = false,
    speedHackMultiplier    = 1,
    gravitacaoAtiva        = false,
    gravitacaoPercent      = 100,
    playerListAtiva        = false,
    detectorAurasAtivo     = false,
    spawnListAtiva         = false,
    miniHudAtivo           = true,
    slotAlturaOffset       = 15,
    slotAlturaDirecao      = "cima",
    autoClickerAtivo       = false,
    autoClickerInterval    = 0.05,
    autoInteractAtivo      = false,
    magnetAtivo            = false,
    fpsBoosterAtivo        = false,

    -- ABA DEFESA BLINDADA V9.0 (DESATIVADAS POR PADRÃO)
    antiFling              = false,
    antiVoid               = false,
    antiRagdoll            = false,
    antiAnchor             = false,
    autoEmergencyHp        = false,
    emergencyHpThreshold   = 0.3,
    antiKillbrick          = false,
    antiFallDamage         = false,
    antiBlind              = false,

    -- Configurações Gerais & Temas
    temaIndice             = 1,
    modoSilencioso         = false,
}

-- ════════════════════════════════════════════════════════════════════════════════
-- SISTEMA DE TECLAS & ATALHOS CUSTOMIZÁVEIS (REMAPEAR / DESATIVAR)
-- ════════════════════════════════════════════════════════════════════════════════
local teclasPadrao = {
    menu        = Enum.KeyCode.F8,
    hud         = Enum.KeyCode.Tab,
    panico      = Enum.KeyCode.F12,
    checkpoint  = Enum.KeyCode.R,
    dash        = Enum.KeyCode.F10,
    autowalk    = Enum.KeyCode.Home,
    autoclicker = Enum.KeyCode.F9,
    astral      = Enum.KeyCode.G,
    voo         = Enum.KeyCode.F,
    paredes     = Enum.KeyCode.L,
    pulo        = Enum.KeyCode.P,
    freeze      = Enum.KeyCode.Q,
    grapple     = Enum.KeyCode.Y,
    magicfloor  = Enum.KeyCode.U,
    elevador    = Enum.KeyCode.End,
    bhop        = Enum.KeyCode.F7,
    freecam     = Enum.KeyCode.C,
    invisivel   = Enum.KeyCode.T,
    choque      = Enum.KeyCode.Insert,
    limpar      = Enum.KeyCode.Delete,
    fullbright  = Enum.KeyCode.H,
    fov         = Enum.KeyCode.F11,
    drone       = Enum.KeyCode.F5,
    xray        = Enum.KeyCode.X,
    noclip      = Enum.KeyCode.N,
    delete      = Enum.KeyCode.B,
    undo        = Enum.KeyCode.Z,
    inspector   = Enum.KeyCode.E,
    outline     = Enum.KeyCode.O,
    speedhack   = Enum.KeyCode.F1,
    gravidade   = Enum.KeyCode.F2,
    spawns      = Enum.KeyCode.F3,
    radar       = Enum.KeyCode.F4,
    antiafk     = Enum.KeyCode.F6,
    esp         = Enum.KeyCode.V,
    cor         = Enum.KeyCode.M,
    playerlist  = Enum.KeyCode.J,
    auras       = Enum.KeyCode.K,
}

local teclasConfig = {}
for k, v in pairs(teclasPadrao) do
    teclasConfig[k] = v
end

local rebindAtivo = nil
local rebindBtnRef = nil

local fovPresets = {70, 90, 110, 30}

local coresAura = {
    {nome = "Ciano Neon",   cor = Color3.fromRGB(0,255,255)},
    {nome = "Verde Neon",   cor = Color3.fromRGB(50,255,120)},
    {nome = "Roxo Neon",    cor = Color3.fromRGB(168,85,247)},
    {nome = "Vermelho",     cor = Color3.fromRGB(255,60,60)},
    {nome = "Amarelo Ouro", cor = Color3.fromRGB(255,220,0)},
    {nome = "Laranja",      cor = Color3.fromRGB(255,120,0)},
    {nome = "Rosa Choque",  cor = Color3.fromRGB(255,50,200)},
    {nome = "Branco Puro",  cor = Color3.fromRGB(255,255,255)},
}

local temas = {
    {nome = "Roxo Astral",     accent = Color3.fromRGB(168,85,247), border = Color3.fromRGB(147,51,234)},
    {nome = "Ciano Cyber",     accent = Color3.fromRGB(6,182,212),  border = Color3.fromRGB(8,145,178)},
    {nome = "Verde Esmeralda", accent = Color3.fromRGB(16,185,129), border = Color3.fromRGB(5,150,105)},
    {nome = "Carmesim Rubro",  accent = Color3.fromRGB(239,68,68),  border = Color3.fromRGB(220,38,38)},
    {nome = "Dourado Ouro",    accent = Color3.fromRGB(234,179,8),  border = Color3.fromRGB(202,138,4)},
}

local slotsPosicoes = {}
local copiaPersonagem = nil
local plataformaCeu = nil
local magicFloorPart = nil
local xrayOriginalTransp = {}
local undoHistory = {}
local tempPlataformas = {}
local tracersCache = {}
local aurasBoxes = {}
local aurasOriginais = {}
local animTracks = {}
local espItens = {}
local espThrottleTimer = 0
local ESP_INTERVAL = 0.05
local lastSafeCFrame = nil
local lastEmergencyWarp = 0
local autoClickerTimer = 0
local autoInteractTimer = 0
local magnetTimer = 0
local killbrickTimer = 0
local lastDash = 0
local originalLighting = {
    GlobalShadows = Lighting.GlobalShadows,
    FogEnd = Lighting.FogEnd,
    Brightness = Lighting.Brightness,
    ClockTime = Lighting.ClockTime,
    Ambient = Lighting.Ambient,
    OutdoorAmbient = Lighting.OutdoorAmbient
}

-- TABELAS CENTRAIS PARA RESPEITAR O LIMITE DE 200 REGISTRADORES
local UI = {}
local state = {
    spectatingPlayer = nil,
    cameraOriginalSubject = nil,
    droneOriginalMaxZoom = player.CameraMaxZoomDistance,
    freeCamCFrame = CFrame.new(0,50,0),
    freeCamRotX = 0,
    freeCamRotY = 0,
    fullbrightConn = nil,
    origFogEnd = Lighting.FogEnd,
    origBrightness = Lighting.Brightness,
    origClockTime = Lighting.ClockTime,
    origAmbient = Lighting.Ambient,
    origOutdoorAmbient = Lighting.OutdoorAmbient,
    gravForce = nil,
    noclipConn = nil,
    antiAfkConn = nil,
    bhopGrounded = false,
    bhopVel = Vector3.zero,
    grappleBeams = {},
}

-- ESTRUTURA FÍSICA PARA O MODO ASTRAL (POD SEGURO NO CÉU)
plataformaCeu = Instance.new("Part")
plataformaCeu.Name = "SuiteV90AstralSkyPod"
plataformaCeu.Size = Vector3.new(20, 1, 20)
plataformaCeu.Transparency = 0.6
plataformaCeu.Color = Color3.fromRGB(168, 85, 247)
plataformaCeu.Material = Enum.Material.ForceField
plataformaCeu.Anchored = true
plataformaCeu.CanCollide = true
plataformaCeu.CFrame = CFrame.new(0, -9999, 0)
plataformaCeu.Parent = Workspace

local rayParams = RaycastParams.new()
rayParams.FilterType = Enum.RaycastFilterType.Exclude

local slotMapa = {
    [Enum.KeyCode.Zero]  = 0, [Enum.KeyCode.One]   = 1, [Enum.KeyCode.Two]   = 2,
    [Enum.KeyCode.Three] = 3, [Enum.KeyCode.Four]  = 4, [Enum.KeyCode.Five]  = 5,
    [Enum.KeyCode.Six]   = 6, [Enum.KeyCode.Seven] = 7, [Enum.KeyCode.Eight] = 8,
    [Enum.KeyCode.Nine]  = 9,
    [Enum.KeyCode.KeypadZero]  = 0, [Enum.KeyCode.KeypadOne]   = 1,
    [Enum.KeyCode.KeypadTwo]   = 2, [Enum.KeyCode.KeypadThree] = 3,
    [Enum.KeyCode.KeypadFour]  = 4, [Enum.KeyCode.KeypadFive]  = 5,
    [Enum.KeyCode.KeypadSix]   = 6, [Enum.KeyCode.KeypadSeven] = 7,
    [Enum.KeyCode.KeypadEight] = 8, [Enum.KeyCode.KeypadNine]  = 9,
}

local inspectorTarget = nil
local outlineTarget   = nil
local outlineBox      = nil

-- FPS
local frameCount, lastFps, fpsTimer = 0, 60, 0
local guiBotoes = {}

-- ════════════════════════════════════════════════════════════════════════════════
-- UTILITÁRIOS GERAIS
-- ════════════════════════════════════════════════════════════════════════════════
local function avisar(titulo, msg, dur)
    if config.modoSilencioso then return end
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = titulo,
            Text = msg,
            Duration = dur or 2.5
        })
    end)
end

local function atualizarBotaoEstado(nome, ativo)
    local info = guiBotoes[nome]
    if not info then return end
    info.isAtivo = ativo
    local btn = info.button
    if not (btn and btn.Parent) then return end
    btn.BackgroundColor3 = ativo and info.corAtiva or info.corInativa
    local sub = btn:FindFirstChild("SubLabel")
    if sub and sub:IsA("TextLabel") then
        sub.Text = ativo and "● ATIVO" or info.baseSub
        sub.TextColor3 = ativo and Color3.fromRGB(80, 255, 140) or Color3.fromRGB(180, 195, 215)
    end
end

local function obterRootAtivo()
    if config.modoAstralAtivo and copiaPersonagem then
        return copiaPersonagem:FindFirstChild("HumanoidRootPart")
    end
    local c = player.Character
    return c and c:FindFirstChild("HumanoidRootPart")
end

-- ════════════════════════════════════════════════════════════════════════════════
-- MOTOR DE ANIMAÇÕES UNIVERSAL
-- ════════════════════════════════════════════════════════════════════════════════
local function formatarId(id)
    if not id then return nil end
    local s = tostring(id):gsub("%s+", "")
    if s == "" or s == "0" then return nil end
    local num = s:match("%d+")
    if num then return "rbxassetid://" .. num end
    return s
end

local function extrairAnimId(pastaNome, nomeAnim)
    local char = player.Character
    if not char then return nil end
    local animateScript = char:FindFirstChild("Animate")
    if animateScript then
        local pasta = animateScript:FindFirstChild(pastaNome)
        if pasta then
            local anim = pasta:FindFirstChild(nomeAnim)
            if anim and anim:IsA("Animation") and anim.AnimationId ~= "" then
                return formatarId(anim.AnimationId)
            end
            for _, ch in ipairs(pasta:GetChildren()) do
                if ch:IsA("Animation") and ch.AnimationId ~= "" then
                    return formatarId(ch.AnimationId)
                elseif ch:IsA("StringValue") and ch.Value ~= "" then
                    return formatarId(ch.Value)
                end
            end
        end
    end
    return nil
end

local function obterAnimIdAtiva(keyword)
    local char = player.Character
    local h = char and char:FindFirstChildOfClass("Humanoid")
    if h then
        for _, t in ipairs(h:GetPlayingAnimationTracks()) do
            local n = t.Name:lower()
            if n:find(keyword) and t.Animation and t.Animation.AnimationId ~= "" then
                return formatarId(t.Animation.AnimationId)
            end
        end
    end
    return nil
end

local function configurarAnimacoes(modelo, humAlvo)
    if not modelo or not humAlvo then return end

    for _, track in pairs(animTracks) do
        pcall(function() track:Stop() track:Destroy() end)
    end
    table.clear(animTracks)

    local cAnimator = humAlvo:FindFirstChildOfClass("Animator")
    if not cAnimator then
        cAnimator = Instance.new("Animator")
        cAnimator.Parent = humAlvo
    end

    for _, trk in ipairs(cAnimator:GetPlayingAnimationTracks()) do
        pcall(function() trk:Stop() end)
    end

    local isR15 = (modelo:FindFirstChild("UpperTorso")) ~= nil

    local runId = obterAnimIdAtiva("run")
        or obterAnimIdAtiva("walk")
        or extrairAnimId("run", "RunAnim")
        or extrairAnimId("walk", "WalkAnim")
        or (isR15 and "rbxassetid://507767714" or "rbxassetid://180426354")

    local idleId = obterAnimIdAtiva("idle")
        or extrairAnimId("idle", "Animation1")
        or (isR15 and "rbxassetid://507766666" or "rbxassetid://180435571")

    local jumpId = obterAnimIdAtiva("jump")
        or extrairAnimId("jump", "JumpAnim")
        or (isR15 and "rbxassetid://507765000" or "rbxassetid://125750702")

    local fallId = obterAnimIdAtiva("fall")
        or extrairAnimId("fall", "FallAnim")
        or (isR15 and "rbxassetid://507767968" or "rbxassetid://180436148")

    local function carregar(id, prioridade, looped)
        id = formatarId(id)
        if not id or id == "" then return nil end
        local aObj = Instance.new("Animation")
        aObj.AnimationId = id
        local success, track = pcall(function()
            return cAnimator:LoadAnimation(aObj)
        end)
        if success and track then
            track.Priority = prioridade or Enum.AnimationPriority.Action4
            track.Looped = (looped ~= false)
            return track
        end
        return nil
    end

    animTracks.run  = carregar(runId,  Enum.AnimationPriority.Action4, true)
    animTracks.idle = carregar(idleId, Enum.AnimationPriority.Action4, true)
    animTracks.jump = carregar(jumpId, Enum.AnimationPriority.Action4, false)
    animTracks.fall = carregar(fallId, Enum.AnimationPriority.Action4, true)

    if animTracks.idle then
        animTracks.idle:Play(0.1)
    end
end

-- ════════════════════════════════════════════════════════════════════════════════
-- SISTEMAS DE FÍSICA & MOBILIDADE
-- ════════════════════════════════════════════════════════════════════════════════

-- MODO ASTRAL [G]
local function alternarModoAstral()
    config.modoAstralAtivo = not config.modoAstralAtivo
    local charReal = player.Character
    if not charReal then return end
    local realRoot = charReal:FindFirstChild("HumanoidRootPart")
    local realHum  = charReal:FindFirstChildOfClass("Humanoid")
    if not realRoot or not realHum then return end

    if config.modoAstralAtivo then
        local cframeAtual = realRoot.CFrame
        plataformaCeu.CFrame = CFrame.new(cframeAtual.X, config.alturaCeu, cframeAtual.Z)

        charReal.Archivable = true
        copiaPersonagem = charReal:Clone()
        copiaPersonagem.Name = player.Name .. "_AstralClone"

        for _, s in ipairs(copiaPersonagem:GetDescendants()) do
            if s:IsA("Script") or s:IsA("LocalScript") then s:Destroy() end
        end

        local cHum = copiaPersonagem:FindFirstChildOfClass("Humanoid")
        local cRoot = copiaPersonagem:FindFirstChild("HumanoidRootPart")
        if cHum and cRoot then
            cHum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
            cHum.HealthDisplayType   = Enum.HumanoidHealthDisplayType.AlwaysOff
            cHum.WalkSpeed           = config.velocidadePadrao
            cHum.PlatformStand       = false
            copiaPersonagem.Parent   = Workspace
            copiaPersonagem:PivotTo(cframeAtual)

            configurarAnimacoes(copiaPersonagem, cHum)
            camera.CameraSubject = cHum
        end

        realHum.PlatformStand = true
        realRoot.AssemblyLinearVelocity = Vector3.zero
        realRoot.AssemblyAngularVelocity = Vector3.zero
        realRoot.CFrame = CFrame.new(cframeAtual.X, config.alturaCeu + 3.5, cframeAtual.Z)

        atualizarBotaoEstado("astral", true)
        avisar("👻 Modo Astral: ATIVADO", "Corpo real seguro a +"..config.alturaCeu.." studs!")
    else
        if copiaPersonagem and copiaPersonagem.Parent then
            local cRoot = copiaPersonagem:FindFirstChild("HumanoidRootPart")
            if cRoot and realRoot then
                realRoot.AssemblyLinearVelocity = Vector3.zero
                realRoot.AssemblyAngularVelocity = Vector3.zero
                realRoot.CFrame = cRoot.CFrame
            end
            copiaPersonagem:Destroy()
            copiaPersonagem = nil
        end

        realHum.PlatformStand = false
        camera.CameraSubject = realHum
        plataformaCeu.CFrame = CFrame.new(0, -9999, 0)

        for _, track in pairs(animTracks) do
            pcall(function() track:Stop() track:Destroy() end)
        end
        table.clear(animTracks)

        atualizarBotaoEstado("astral", false)
        avisar("👻 Modo Astral: DESATIVADO", "Retornado ao corpo físico com segurança.")
    end
end

-- VOO LIVRE [F]
local function alternarVoo()
    config.vooAtivo = not config.vooAtivo
    local r = obterRootAtivo()
    if r then
        r.AssemblyLinearVelocity = Vector3.zero
        r.AssemblyAngularVelocity = Vector3.zero
    end
    atualizarBotaoEstado("voo", config.vooAtivo)
    avisar((config.vooAtivo and "🦅 Voo: ATIVADO" or "🦅 Voo: DESATIVADO"), "Velocidade: "..config.velocidadeVoo.." studs/s (Shift: Turbo)")
end

-- ANDAR EM PAREDES E TETOS [L]
local function alternarAndarParedes()
    config.andarParedesAtivo = not config.andarParedesAtivo
    atualizarBotaoEstado("paredes", config.andarParedesAtivo)
    avisar((config.andarParedesAtivo and "🧗 Andar em Paredes: ATIVADO" or "🧗 Andar em Paredes: DESATIVADO"), "Física de superfície 360° com câmera nativa")
end

-- PULO INFINITO [P]
local function alternarPuloInfinito()
    config.puloInfinitoAtivo = not config.puloInfinitoAtivo
    atualizarBotaoEstado("pulo", config.puloInfinitoAtivo)
    avisar((config.puloInfinitoAtivo and "🦘 Pulo Infinito: ATIVADO" or "🦘 Pulo Infinito: DESATIVADO"), "Aperte Espaço para pular no ar ilimitadamente")
end

-- FREEZE [Q]
local function alternarFreeze()
    config.freezeAtivo = not config.freezeAtivo
    local r = obterRootAtivo()
    if r then
        r.Anchored = config.freezeAtivo
        r.AssemblyLinearVelocity = Vector3.zero
        r.AssemblyAngularVelocity = Vector3.zero
    end
    atualizarBotaoEstado("freeze", config.freezeAtivo)
    avisar((config.freezeAtivo and "❄️ Freeze: ATIVADO" or "❄️ Freeze: DESATIVADO"), "Posição e física travadas no lugar")
end

-- CHECKPOINT [R] & [Shift+R]
local function salvarCheckpoint()
    local r = obterRootAtivo()
    if r then
        config.checkpointPos = r.CFrame
        if UI.hudCheckpoint then
            local pos = r.Position
            UI.hudCheckpoint.Text = string.format("📍 CP: X:%.0f Y:%.0f Z:%.0f", pos.X, pos.Y, pos.Z)
            UI.hudCheckpoint.TextColor3 = Color3.fromRGB(80, 255, 140)
        end
        avisar("💾 Checkpoint Gravado", string.format("Posição salva: X:%.0f Y:%.0f Z:%.0f", r.Position.X, r.Position.Y, r.Position.Z))
    else
        avisar("⚠️ Checkpoint", "Personagem não encontrado para salvar.")
    end
end

local function carregarCheckpoint()
    local r = obterRootAtivo()
    if not r then
        avisar("⚠️ Checkpoint", "Personagem não encontrado.")
        return
    end

    if not config.checkpointPos then
        salvarCheckpoint()
        avisar("📍 Ponto Inicial Salvo!", "Primeiro checkpoint gravado nesta posição. Pressione a tecla de novo para voltar.")
        return
    end

    local char = (config.modoAstralAtivo and copiaPersonagem) or player.Character
    if char then
        char:PivotTo(config.checkpointPos)
    else
        r.CFrame = config.checkpointPos
    end
    r.AssemblyLinearVelocity = Vector3.zero
    r.AssemblyAngularVelocity = Vector3.zero

    avisar("⚡ Teleporte Checkpoint", "Retornado com sucesso ao ponto salvo!")
end

-- GRAPPLING HOOK [Y] / [Scroll Click]
local function dispararGrapple()
    local r = obterRootAtivo()
    local hit = mouse.Hit
    if not r or not hit then return end

    local targetPos = hit.Position
    local dist = (targetPos - r.Position).Magnitude
    if dist < 4 or dist > 1500 then
        avisar("🪝 Grapple", "Ponto fora de alcance (" .. math.floor(dist) .. " studs)")
        return
    end

    local beamPart = Instance.new("Part")
    beamPart.Name = "GrappleBeam"
    beamPart.Anchored = true
    beamPart.CanCollide = false
    beamPart.Material = Enum.Material.Neon
    beamPart.Color = Color3.fromRGB(0, 255, 255)
    beamPart.Size = Vector3.new(0.3, 0.3, dist)
    beamPart.CFrame = CFrame.new(r.Position:Lerp(targetPos, 0.5), targetPos)
    beamPart.Parent = Workspace
    table.insert(state.grappleBeams, beamPart)

    local pullDir = (targetPos - r.Position).Unit
    r.AssemblyLinearVelocity = pullDir * math.clamp(dist * 2.2, 70, 260) + Vector3.new(0, 15, 0)

    avisar("🪝 Grappling Hook", "Puxando até o alvo (" .. math.floor(dist) .. " studs)!")

    task.delay(0.65, function()
        if beamPart and beamPart.Parent then beamPart:Destroy() end
    end)
end

-- MAGIC FLOOR [U]
local function alternarMagicFloor()
    config.magicFloorAtivo = not config.magicFloorAtivo
    local r = obterRootAtivo()
    if config.magicFloorAtivo and r then
        if not magicFloorPart or not magicFloorPart.Parent then
            magicFloorPart = Instance.new("Part")
            magicFloorPart.Name = "SuiteV90MagicFloor"
            magicFloorPart.Size = Vector3.new(12, 1, 12)
            magicFloorPart.Transparency = 0.5
            magicFloorPart.Material = Enum.Material.ForceField
            magicFloorPart.Color = Color3.fromRGB(0, 255, 200)
            magicFloorPart.Anchored = true
            magicFloorPart.CanCollide = true
            magicFloorPart.Parent = Workspace
        end
        magicFloorPart.CFrame = CFrame.new(r.Position.X, r.Position.Y - 3.5, r.Position.Z)
        avisar("🔮 Magic Floor: ATIVADO", "Piso de força gerado sob seus pés!")
    else
        if magicFloorPart and magicFloorPart.Parent then
            magicFloorPart:Destroy()
            magicFloorPart = nil
        end
        avisar("🔮 Magic Floor: DESATIVADO", "Piso removido.")
    end
    atualizarBotaoEstado("magicfloor", config.magicFloorAtivo)
end

-- ELEVADOR ASTRAL [End]
local function alternarElevador()
    config.elevadorAtivo = not config.elevadorAtivo
    local r = obterRootAtivo()
    if r then
        r.AssemblyLinearVelocity = Vector3.zero
        r.AssemblyAngularVelocity = Vector3.zero
    end
    atualizarBotaoEstado("elevador", config.elevadorAtivo)
    avisar((config.elevadorAtivo and "🛗 Elevador Astral: ATIVADO" or "🛗 Elevador Astral: DESATIVADO"), "Segure [Espaço] para subir e [Ctrl] para descer")
end

-- SUPER BHOP GLIDE [F7]
local function alternarBhop()
    config.bhopAtivo = not config.bhopAtivo
    atualizarBotaoEstado("bhop", config.bhopAtivo)
    avisar((config.bhopAtivo and "🦿 Bhop Glide: ATIVADO" or "🦿 Bhop Glide: DESATIVADO"), "Pule no chão para conservar e acumular impulso")
end

-- FLASH DASH [F10]
local function executarDash()
    if tick() - lastDash < 0.75 then return end
    lastDash = tick()
    local root = obterRootAtivo()
    if not root then return end

    local moveDir = Vector3.zero
    local hum = (copiaPersonagem and copiaPersonagem:FindFirstChildOfClass("Humanoid")) or (player.Character and player.Character:FindFirstChildOfClass("Humanoid"))
    if hum and hum.MoveDirection.Magnitude > 0.1 then
        moveDir = hum.MoveDirection
    else
        moveDir = Vector3.new(camera.CFrame.LookVector.X, 0, camera.CFrame.LookVector.Z).Unit
    end
    if moveDir.Magnitude < 0.1 then moveDir = root.CFrame.LookVector end

    local trailPart = Instance.new("Part")
    trailPart.Size = Vector3.new(3.5, 5.5, 3.5)
    trailPart.CFrame = root.CFrame
    trailPart.Anchored = true
    trailPart.CanCollide = false
    trailPart.Material = Enum.Material.Neon
    trailPart.Color = Color3.fromRGB(168, 85, 247)
    trailPart.Transparency = 0.4
    trailPart.Parent = Workspace
    TweenService:Create(trailPart, TweenInfo.new(0.4), {Transparency = 1, Size = Vector3.new(0.5, 0.5, 0.5)}):Play()
    task.delay(0.45, function() if trailPart and trailPart.Parent then trailPart:Destroy() end end)

    root.AssemblyLinearVelocity = moveDir * (config.dashForca or 70) + Vector3.new(0, 12, 0)
    avisar("⚡ Flash Dash", "Impulso supersônico de 70 studs!", 1)
end

-- SUPER PULO (HIGH JUMP)
local function alternarSuperPulo()
    config.superPuloAtivo = not config.superPuloAtivo
    local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
    if hum then
        if config.superPuloAtivo then
            hum.UseJumpPower = true
            hum.JumpPower = config.superPuloForca or 120
        else
            hum.JumpPower = 50
        end
    end
    atualizarBotaoEstado("superpulo", config.superPuloAtivo)
    avisar((config.superPuloAtivo and "🦘 Super Pulo: ATIVADO" or "🦘 Super Pulo: DESATIVADO"), "Altura do pulo: "..(config.superPuloAtivo and "120 studs" or "Padrão"))
end

-- PILOTO AUTOMÁTICO (AUTO-WALK) [Home]
local function alternarAutoWalk()
    config.autoWalkAtivo = not config.autoWalkAtivo
    atualizarBotaoEstado("autowalk", config.autoWalkAtivo)
    avisar((config.autoWalkAtivo and "🧭 Piloto Automático: LIGADO" or "🧭 Piloto Automático: DESLIGADO"), "Caminhando para frente automaticamente")
end

-- SPIDER CLIMB (ESCALADA VERTICAL)
local function alternarSpiderClimb()
    config.spiderClimbAtivo = not config.spiderClimbAtivo
    atualizarBotaoEstado("spiderclimb", config.spiderClimbAtivo)
    avisar((config.spiderClimbAtivo and "🕷️ Spider Climb: ATIVADO" or "🕷️ Spider Climb: DESATIVADO"), "Escala paredes verticais ao encostar segurando W")
end

-- CÂMERA LIVRE [C]
local function alternarCameraLivre()
    config.cameraLivreAtiva = not config.cameraLivreAtiva
    if config.cameraLivreAtiva then
        state.cameraOriginalSubject = camera.CameraSubject
        state.freeCamCFrame = camera.CFrame
        camera.CameraType = Enum.CameraType.Scriptable
        atualizarBotaoEstado("freecam", true)
        avisar("🎥 Câmera Livre: ATIVADA", "WASD para mover • Shift: Turbo • C: Desativar")
    else
        camera.CameraType = Enum.CameraType.Custom
        local h = (config.modoAstralAtivo and copiaPersonagem and copiaPersonagem:FindFirstChildOfClass("Humanoid"))
            or (player.Character and player.Character:FindFirstChildOfClass("Humanoid"))
        camera.CameraSubject = h or state.cameraOriginalSubject
        atualizarBotaoEstado("freecam", false)
        avisar("🎥 Câmera Livre: DESATIVADA", "Câmera retornada ao personagem.")
    end
end

-- INVISIBILIDADE [T]
local function alternarInvisibilidade()
    config.invisibilidadeAtiva = not config.invisibilidadeAtiva
    local char = (config.modoAstralAtivo and copiaPersonagem) or player.Character
    if not char then return end

    for _, p in ipairs(char:GetDescendants()) do
        if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then
            p.Transparency = config.invisibilidadeAtiva and 1 or 0
            p.CastShadow   = not config.invisibilidadeAtiva
        elseif p:IsA("Decal") then
            p.Transparency = config.invisibilidadeAtiva and 1 or 0
        end
    end
    atualizarBotaoEstado("invisivel", config.invisibilidadeAtiva)
    avisar((config.invisibilidadeAtiva and "👤 Invisibilidade: ATIVADA" or "👤 Invisibilidade: DESATIVADA"), "Transparência total e remoção de sombras")
end

-- ════════════════════════════════════════════════════════════════════════════════
-- SISTEMAS DE VISÃO & ÓPTICA
-- ════════════════════════════════════════════════════════════════════════════════

-- FULLBRIGHT [H]
local function alternarFullbright()
    config.fullbrightAtivo = not config.fullbrightAtivo
    if config.fullbrightAtivo then
        Lighting.FogEnd = 9e9
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.Ambient = Color3.fromRGB(255, 255, 255)
        Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
        avisar("💡 Fullbright: ATIVADO", "Mapas e cavernas 100% claros sem escuridão")
    else
        Lighting.FogEnd = originalLighting.FogEnd
        Lighting.Brightness = originalLighting.Brightness
        Lighting.ClockTime = originalLighting.ClockTime
        Lighting.Ambient = originalLighting.Ambient
        Lighting.OutdoorAmbient = originalLighting.OutdoorAmbient
        avisar("💡 Fullbright: DESATIVADO", "Iluminação padrão restaurada.")
    end
    atualizarBotaoEstado("fullbright", config.fullbrightAtivo)
end

-- SELETOR DE FOV [F11]
local function ciclarFov()
    config.fovIndice = (config.fovIndice % #fovPresets) + 1
    local novoFov = fovPresets[config.fovIndice]
    camera.FieldOfView = novoFov
    if UI.hudFov then
        UI.hudFov.Text = string.format("🔭 FOV: %d°", novoFov)
    end
    avisar("🔭 Campo de Visão (FOV)", "FOV ajustado para: " .. novoFov .. "°")
end

-- MODO DRONE [F5]
local function alternarDroneMode()
    config.droneModeAtivo = not config.droneModeAtivo
    if config.droneModeAtivo then
        state.droneOriginalMaxZoom = player.CameraMaxZoomDistance
        player.CameraMaxZoomDistance = 2000
        avisar("🛸 Modo Drone: ATIVADO", "Zoom máximo destravado até 2.000 studs!")
    else
        player.CameraMaxZoomDistance = state.droneOriginalMaxZoom or 128
        avisar("🛸 Modo Drone: DESATIVADO", "Distância de zoom restaurada.")
    end
    atualizarBotaoEstado("drone", config.droneModeAtivo)
end

-- RAIO-X [X]
local function alternarXRay()
    config.xrayAtivo = not config.xrayAtivo
    for _, part in ipairs(Workspace:GetDescendants()) do
        if part:IsA("BasePart") and not part:IsDescendantOf(player.Character or Instance.new("Model")) and part.Transparency < 0.9 then
            if config.xrayAtivo then
                if xrayOriginalTransp[part] == nil then
                    xrayOriginalTransp[part] = part.Transparency
                end
                part.Transparency = 0.65
            else
                if xrayOriginalTransp[part] ~= nil then
                    part.Transparency = xrayOriginalTransp[part]
                end
            end
        end
    end
    if not config.xrayAtivo then table.clear(xrayOriginalTransp) end
    atualizarBotaoEstado("xray", config.xrayAtivo)
    avisar((config.xrayAtivo and "🔍 Raio-X: ATIVADO" or "🔍 Raio-X: DESATIVADO"), "Visão através de estruturas e paredes")
end

-- ESP & CORES [V] e [M]
local function alternarCorAura()
    config.corAuraIndice = (config.corAuraIndice % #coresAura) + 1
    local sel = coresAura[config.corAuraIndice]
    for _, item in pairs(espItens) do
        if item.highlight then item.highlight.FillColor = sel.cor item.highlight.OutlineColor = sel.cor end
        if item.billboard and item.billboard:FindFirstChild("Texto") then
            item.billboard.Texto.TextColor3 = sel.cor
        end
    end
    if UI.corEspLblRef then
        UI.corEspLblRef.Text = "🎨 Cor ESP: " .. sel.nome .. " ●"
        UI.corEspLblRef.TextColor3 = sel.cor
    end
    avisar("🎨 Cor de ESP", "Cor: " .. sel.nome)
end

local function atualizarEspJogador(p)
    if p == player then return end
    local char = p.Character
    if not config.espAtivo or not char then
        if espItens[p] then
            pcall(function()
                if espItens[p].highlight then espItens[p].highlight:Destroy() end
                if espItens[p].billboard then espItens[p].billboard:Destroy() end
            end)
            espItens[p] = nil
        end
        return
    end

    local root = char:FindFirstChild("HumanoidRootPart")
    local hum  = char:FindFirstChildOfClass("Humanoid")
    if not root or not hum then return end

    local sel = coresAura[config.corAuraIndice]
    local item = espItens[p]
    if not item then
        local hl = Instance.new("Highlight")
        hl.Name = "ESP_HL_" .. p.Name
        hl.FillColor = sel.cor
        hl.OutlineColor = sel.cor
        hl.FillTransparency = 0.5
        hl.OutlineTransparency = 0
        hl.Adornee = char
        hl.Parent = char

        local bb = Instance.new("BillboardGui")
        bb.Name = "ESP_BB_" .. p.Name
        bb.Size = UDim2.new(0, 160, 0, 42)
        bb.StudsOffset = Vector3.new(0, 3.2, 0)
        bb.AlwaysOnTop = true
        bb.Adornee = root
        bb.Parent = char

        local txt = Instance.new("TextLabel")
        txt.Name = "Texto"
        txt.Size = UDim2.new(1, 0, 1, 0)
        txt.BackgroundTransparency = 1
        txt.Font = Enum.Font.GothamBold
        txt.TextSize = 10
        txt.TextColor3 = sel.cor
        txt.TextStrokeTransparency = 0.2
        txt.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        txt.Parent = bb

        item = {highlight = hl, billboard = bb}
        espItens[p] = item
    end

    local myRoot = obterRootAtivo()
    local dist = myRoot and (myRoot.Position - root.Position).Magnitude or 0
    local hpPct = math.clamp(math.floor((hum.Health / math.max(hum.MaxHealth, 1)) * 100), 0, 100)
    local txtLbl = item.billboard:FindFirstChild("Texto")
    if txtLbl then
        txtLbl.Text = string.format("👤 %s\n📏 %.0f studs  •  💚 %d%% HP", p.DisplayName, dist, hpPct)
    end
end

local function alternarEsp()
    config.espAtivo = not config.espAtivo
    if not config.espAtivo then
        for _, it in pairs(espItens) do
            pcall(function()
                if it.highlight then it.highlight:Destroy() end
                if it.billboard then it.billboard:Destroy() end
            end)
        end
        table.clear(espItens)
    else
        for _, p in ipairs(Players:GetPlayers()) do
            atualizarEspJogador(p)
        end
    end
    atualizarBotaoEstado("esp", config.espAtivo)
    avisar((config.espAtivo and "👁️ ESP Jogadores: ATIVADO" or "👁️ ESP Jogadores: DESATIVADO"), "Aura luminosa, distância e HP através de paredes")
end

-- TRACERS 3D ATÉ OS JOGADORES
local function alternarTracers()
    config.tracersAtivo = not config.tracersAtivo
    if not config.tracersAtivo then
        for _, t in pairs(tracersCache) do pcall(function() t:Destroy() end) end
        table.clear(tracersCache)
    end
    atualizarBotaoEstado("tracers", config.tracersAtivo)
    avisar((config.tracersAtivo and "📏 Tracers 3D: ATIVADOS" or "📏 Tracers 3D: DESATIVADOS"), "Linhas neon ligando seu avatar até cada jogador")
end

-- OUTLINE TRACKER [O]
local function alternarOutlineTracker()
    config.outlineTrackerAtivo = not config.outlineTrackerAtivo
    if not config.outlineTrackerAtivo and outlineBox then
        outlineBox:Destroy() outlineBox = nil outlineTarget = nil
    end
    atualizarBotaoEstado("outline", config.outlineTrackerAtivo)
    avisar((config.outlineTrackerAtivo and "📦 Outline Tracker: ATIVADO" or "📦 Outline Tracker: DESATIVADO"), "Bounding box colorida de objetos ao mirar")
end

-- ════════════════════════════════════════════════════════════════════════════════
-- SISTEMAS CINÉTICOS, UTILITÁRIOS & MOUSE
-- ════════════════════════════════════════════════════════════════════════════════

-- AUTO-CLICKER TURBO [F9]
local function alternarAutoClicker()
    config.autoClickerAtivo = not config.autoClickerAtivo
    atualizarBotaoEstado("autoclicker", config.autoClickerAtivo)
    avisar((config.autoClickerAtivo and "🖱️ Auto-Clicker: LIGADO" or "🖱️ Auto-Clicker: DESLIGADO"), config.autoClickerAtivo and "20 cliques/s contínuos no mouse" or "Pausado")
end

-- AUTO-INTERACT AURA (PROXIMITY PROMPTS)
local function alternarAutoInteract()
    config.autoInteractAtivo = not config.autoInteractAtivo
    atualizarBotaoEstado("autointeract", config.autoInteractAtivo)
    avisar((config.autoInteractAtivo and "⚡ Auto-Interact: ATIVADO" or "⚡ Auto-Interact: DESATIVADO"), "Dispara ProximityPrompts próximos sem segurar E")
end

-- COLETOR MAGNÉTICO (MAGNET)
local function alternarMagnet()
    config.magnetAtivo = not config.magnetAtivo
    atualizarBotaoEstado("magnet", config.magnetAtivo)
    avisar((config.magnetAtivo and "🧲 Magnet: ATIVADO" or "🧲 Magnet: DESATIVADO"), "Puxa peças móveis e aciona colecionáveis próximos")
end

-- FPS BOOSTER (OTIMIZADOR GRÁFICO)
local function alternarFpsBooster()
    config.fpsBoosterAtivo = not config.fpsBoosterAtivo
    atualizarBotaoEstado("fpsbooster", config.fpsBoosterAtivo)
    if config.fpsBoosterAtivo then
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 9e9
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") then
                obj.Material = Enum.Material.SmoothPlastic
                obj.CastShadow = false
            elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Smoke") or obj:IsA("Fire") then
                obj.Enabled = false
            end
        end
        avisar("🚀 FPS Booster: ATIVADO", "Sombras desativadas e texturas lisas (+FPS)!")
    else
        Lighting.GlobalShadows = true
        avisar("🚀 FPS Booster: DESATIVADO", "Gráficos restaurados.")
    end
end

-- ONDA DE CHOQUE CINÉTICA [Insert]
local function dispararOndaDeChoque()
    local root = obterRootAtivo()
    if not root then return end

    local char = (config.modoAstralAtivo and copiaPersonagem) or player.Character
    local pos = root.Position
    local count = 0
    local blastRadius = 48
    local blastForce  = 160

    for _, p in ipairs(Workspace:GetDescendants()) do
        if p:IsA("BasePart") and not p.Anchored and not p:IsDescendantOf(char) then
            local diff = p.Position - pos
            local dist = diff.Magnitude
            if dist <= blastRadius and dist > 0.5 then
                local dir = (diff.Unit + Vector3.new(0, 0.45, 0)).Unit
                local falloff = 1 - (dist / blastRadius)
                pcall(function()
                    p.AssemblyLinearVelocity = dir * (blastForce * falloff)
                end)
                count = count + 1
            end
        end
    end

    local ring = Instance.new("Part")
    ring.Name = "ShockwaveVisual"
    ring.Anchored = true
    ring.CanCollide = false
    ring.Material = Enum.Material.ForceField
    ring.Color = Color3.fromRGB(168, 85, 247)
    ring.Size = Vector3.new(4, 1, 4)
    ring.CFrame = CFrame.new(pos)
    ring.Parent = Workspace

    TweenService:Create(ring, TweenInfo.new(0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
        Size = Vector3.new(blastRadius * 2, 0.5, blastRadius * 2),
        Transparency = 1
    }):Play()

    task.delay(0.5, function()
        if ring and ring.Parent then ring:Destroy() end
    end)

    avisar("💥 Onda de Choque Cinética", "Impulso radial aplicado em " .. count .. " objetos móveis!")
end

-- LIMPAR VESTÍGIOS [Delete]
local function limparVestigios()
    local removidos = 0
    if magicFloorPart and magicFloorPart.Parent then
        magicFloorPart:Destroy() magicFloorPart = nil removidos = removidos + 1
    end
    for _, p in ipairs(tempPlataformas) do
        if p and p.Parent then p:Destroy() removidos = removidos + 1 end
    end
    table.clear(tempPlataformas)

    for _, b in ipairs(state.grappleBeams) do
        if b and b.Parent then b:Destroy() removidos = removidos + 1 end
    end
    table.clear(state.grappleBeams)

    for _, obj in ipairs(Workspace:GetChildren()) do
        if obj.Name == "GrappleBeam" or obj.Name == "ShockwaveVisual" or obj.Name:find("TempPlat") then
            obj:Destroy() removidos = removidos + 1
        end
    end

    avisar("🧹 Limpar Vestígios", "Removidos " .. removidos .. " objetos temporários.")
end

-- NOCLIP TOTAL [N]
local function alternarNoclip()
    config.noclipAtivo = not config.noclipAtivo
    atualizarBotaoEstado("noclip", config.noclipAtivo)
    avisar((config.noclipAtivo and "🧱 Noclip Total: ATIVADO" or "🧱 Noclip Total: DESATIVADO"), "Atravesse qualquer obstáculo com restauração de física")
end

-- MODO APAGAR & UNDO [B] e [Z]
local function apagarObjetoNoMouse()
    local t = mouse.Target
    if t and t:IsA("BasePart") and not t:IsDescendantOf(player.Character or Instance.new("Model")) then
        local nm = t.Name
        table.insert(undoHistory, {instance = t, parent = t.Parent, cframe = t.CFrame})
        if #undoHistory > 10 then table.remove(undoHistory, 1) end
        t.Parent = nil
        avisar("🗑️ Objeto Deletado", "'" .. nm .. "' apagado! [Z para restaurar]")
    end
end

local function alternarDeleteMode()
    config.deleteModeAtivo = not config.deleteModeAtivo
    atualizarBotaoEstado("delete", config.deleteModeAtivo)
    avisar((config.deleteModeAtivo and "🗑️ Modo Apagar: ATIVADO" or "🗑️ Modo Apagar: DESATIVADO"), "Clique em qualquer objeto com o mouse para apagá-lo")
end

local function executarUndoDelete()
    if #undoHistory > 0 then
        local item = table.remove(undoHistory)
        if item and item.instance then
            item.instance.Parent = item.parent or Workspace
            item.instance.CFrame = item.cframe
            avisar("↩️ Undo Realizado", "'" .. item.instance.Name .. "' restaurado com sucesso!")
        end
    else
        avisar("ℹ️ Histórico Vazio", "Nenhum objeto deletado para restaurar.")
    end
end

-- OBJECT INSPECTOR [E]
local function alternarInspector()
    config.inspectorAtivo = not config.inspectorAtivo
    if not config.inspectorAtivo and UI.inspectorBillboard then
        UI.inspectorBillboard.Enabled = false
        inspectorTarget = nil
    end
    atualizarBotaoEstado("inspector", config.inspectorAtivo)
    avisar((config.inspectorAtivo and "🔍 Inspector 3D: ATIVADO" or "🔍 Inspector 3D: DESATIVADO"), "Mire o mouse em qualquer bloco para ver suas propriedades")
end

-- SPEED HACK [F1]
local function alternarSpeedHack()
    config.speedHackAtivo = not config.speedHackAtivo
    local h = (config.modoAstralAtivo and copiaPersonagem and copiaPersonagem:FindFirstChildOfClass("Humanoid"))
        or (player.Character and player.Character:FindFirstChildOfClass("Humanoid"))
    if h then
        h.WalkSpeed = config.speedHackAtivo and (config.velocidadePadrao * config.speedHackMultiplier) or config.velocidadePadrao
    end
    atualizarBotaoEstado("speedhack", config.speedHackAtivo)
    avisar((config.speedHackAtivo and "⚡ Speed Hack: ATIVADO" or "⚡ Speed Hack: DESATIVADO"), "Multiplicador atual: " .. config.speedHackMultiplier .. "×")
end

-- GRAVIDADE CUSTOMIZADA [F2]
local function recalcularGravForce()
    local root = obterRootAtivo()
    if not root then return end
    if config.gravitacaoAtiva and config.gravitacaoPercent ~= 100 then
        if not state.gravForce or not state.gravForce.Parent then
            state.gravForce = Instance.new("VectorForce")
            state.gravForce.Name = "SuiteV90GravForce"
            state.gravForce.RelativeTo = Enum.ActuatorRelativeTo.World
            state.gravForce.ApplyAtCenterOfMass = true
            local att = root:FindFirstChild("SuiteV90GravAtt") or Instance.new("Attachment")
            att.Name = "SuiteV90GravAtt" att.Parent = root
            state.gravForce.Attachment0 = att
            state.gravForce.Parent = root
        end
        local mass = 0
        local char = (config.modoAstralAtivo and copiaPersonagem) or player.Character
        if char then
            for _, p in ipairs(char:GetDescendants()) do
                if p:IsA("BasePart") then mass = mass + p:GetMass() end
            end
        end
        local defaultG = Workspace.Gravity
        local targetG  = defaultG * (config.gravitacaoPercent / 100)
        local diffG    = defaultG - targetG
        state.gravForce.Force = Vector3.new(0, mass * diffG, 0)
    else
        if state.gravForce and state.gravForce.Parent then
            state.gravForce:Destroy()
            state.gravForce = nil
        end
    end
end

local function alternarGravidade()
    config.gravitacaoAtiva = not config.gravitacaoAtiva
    recalcularGravForce()
    atualizarBotaoEstado("gravidade", config.gravitacaoAtiva)
    avisar((config.gravitacaoAtiva and "🌍 Gravidade: ATIVADA" or "🌍 Gravidade: PADRÃO"), "Nível: " .. config.gravitacaoPercent .. "%")
end

-- RADAR DE INTERAÇÕES [F4]
local function alternarRadarInteracoes()
    config.radarInteracoesAtivo = not config.radarInteracoesAtivo
    atualizarBotaoEstado("radar", config.radarInteracoesAtivo)
    avisar((config.radarInteracoesAtivo and "🔘 Radar de Prompts: ATIVADO" or "🔘 Radar de Prompts: DESATIVADO"), "Destacando ClickDetectors e ProximityPrompts")
end

-- ANTI-AFK [F6]
local function alternarAntiAfk()
    config.antiAfkAtivo = not config.antiAfkAtivo
    atualizarBotaoEstado("antiafk", config.antiAfkAtivo)
    avisar((config.antiAfkAtivo and "🛡️ Anti-AFK: ATIVADO" or "🛡️ Anti-AFK: DESATIVADO"), "Prevenção de desconexão automática por inatividade de 20 min")
end

-- AURAS INVISÍVEIS [K]
local function alternarDetectorAuras()
    config.detectorAurasAtivo = not config.detectorAurasAtivo
    for _, part in ipairs(Workspace:GetDescendants()) do
        if part:IsA("BasePart") and not part:IsDescendantOf(player.Character or Instance.new("Model")) and part.Transparency >= 0.85 then
            if config.detectorAurasAtivo then
                if aurasOriginais[part] == nil then aurasOriginais[part] = part.Transparency end
                part.Transparency = 0.35
                local sb = Instance.new("SelectionBox")
                sb.Adornee = part
                sb.Color3 = Color3.fromRGB(244, 63, 94)
                sb.Parent = part
                aurasBoxes[part] = sb
            else
                if aurasOriginais[part] ~= nil then part.Transparency = aurasOriginais[part] end
                if aurasBoxes[part] then aurasBoxes[part]:Destroy() aurasBoxes[part] = nil end
            end
        end
    end
    if not config.detectorAurasAtivo then table.clear(aurasBoxes) table.clear(aurasOriginais) end
    atualizarBotaoEstado("auras", config.detectorAurasAtivo)
    avisar((config.detectorAurasAtivo and "🔮 Auras Invisíveis: VISÍVEIS" or "🔮 Auras Invisíveis: OCULTAS"), "Partes invisíveis destacadas (clique para apagar)")
end

-- CLICK TELEPORT
local function executarClickTeleport()
    local h = mouse.Hit
    local r = obterRootAtivo()
    if h and r then
        local targetPos = h.Position + Vector3.new(0, 3.2, 0)
        local char = (config.modoAstralAtivo and copiaPersonagem) or player.Character
        if char then
            char:PivotTo(CFrame.new(targetPos))
        else
            r.CFrame = CFrame.new(targetPos)
        end
        r.AssemblyLinearVelocity = Vector3.zero
        r.AssemblyAngularVelocity = Vector3.zero
        avisar("⚡ Click Teleport", "Teleportado para o ponto clicado!")
    end
end

-- TELEPORTE POR SLOTS
local function salvarSlot(s)
    local r = obterRootAtivo()
    if r then
        slotsPosicoes[s] = r.CFrame
        avisar("💾 Slot " .. s .. " Salvo", string.format("X:%.0f Y:%.0f Z:%.0f", r.Position.X, r.Position.Y, r.Position.Z))
    end
end

local function carregarSlot(s)
    local targetCF = slotsPosicoes[s]
    local r = obterRootAtivo()
    if not targetCF then
        avisar("⚠️ Slot Vazio", "O Slot " .. s .. " ainda não foi gravado! [Ctrl Dir + " .. s .. " para salvar]")
        return
    end
    if not r then return end

    local char = (config.modoAstralAtivo and copiaPersonagem) or player.Character
    if s >= 6 then
        local ray = Workspace:Raycast(targetCF.Position + Vector3.new(0, 20, 0), Vector3.new(0, -60, 0), rayParams)
        local groundY = ray and ray.Position.Y or targetCF.Position.Y
        local offset = (config.slotAlturaDirecao == "cima") and config.slotAlturaOffset or -config.slotAlturaOffset
        local finalCF = CFrame.new(targetCF.Position.X, groundY + offset, targetCF.Position.Z)
        if char then char:PivotTo(finalCF) else r.CFrame = finalCF end
        avisar("✈️ Fly Safe Slot " .. s, "Posicionado a " .. config.slotAlturaOffset .. " studs do chão (" .. config.slotAlturaDirecao .. ")")
    else
        if char then char:PivotTo(targetCF) else r.CFrame = targetCF end
        avisar("⚡ Slot " .. s .. " Carregado", "Teleportado para as coordenadas do Slot!")
    end
    r.AssemblyLinearVelocity = Vector3.zero
    r.AssemblyAngularVelocity = Vector3.zero
end

-- ════════════════════════════════════════════════════════════════════════════════
-- SISTEMAS DA ABA DEFESA (V9.0 COISAS REALMENTE ÚTEIS)
-- ════════════════════════════════════════════════════════════════════════════════

-- 1. ANTI-FLING & NO PLAYER COLLIDE
local function aplicarNoPlayerCollide()
    if not config.antiFling then return end
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

-- 2. ANTI-VOID RESCUE
local function processarAntiVoid(realRoot)
    if not config.antiVoid or not realRoot then return end
    local destroyY = Workspace.FallenPartsDestroyHeight + 40
    local isFallingHard = (realRoot.Position.Y < -60 and realRoot.AssemblyLinearVelocity.Y < -80)
    if realRoot.Position.Y < destroyY or isFallingHard then
        realRoot.AssemblyLinearVelocity = Vector3.zero
        realRoot.AssemblyAngularVelocity = Vector3.zero
        local targetCF = lastSafeCFrame or config.checkpointPos or CFrame.new(realRoot.Position.X, 60, realRoot.Position.Z)
        local char = player.Character
        if char then char:PivotTo(targetCF + Vector3.new(0, 3.5, 0)) end
        if not magicFloorPart or not magicFloorPart.Parent then
            alternarMagicFloor()
        end
        avisar("🕳️ Anti-Void Rescue", "Queda no abismo prevenida! Resgatado com sucesso.", 3)
    end
end

-- 3. ANTI-RAGDOLL & ANTI-SIT
local function processarAntiRagdoll(realHum)
    if not config.antiRagdoll or not realHum then return end
    if realHum.Sit then
        realHum.Sit = false
    end
    local st = realHum:GetState()
    if st == Enum.HumanoidStateType.Ragdoll or st == Enum.HumanoidStateType.FallingDown or st == Enum.HumanoidStateType.PlatformStanding then
        realHum:ChangeState(Enum.HumanoidStateType.GettingUp)
    end
end

-- 4. ANTI-ANCHOR
local function processarAntiAnchor(char)
    if not config.antiAnchor or not char or config.freezeAtivo or config.modoAstralAtivo then return end
    for _, part in ipairs(char:GetChildren()) do
        if part:IsA("BasePart") and part.Anchored then
            part.Anchored = false
        end
    end
end

-- 5. AUTO-EMERGENCY HP RESCUE
local function processarEmergencyHp(realRoot, realHum)
    if not config.autoEmergencyHp or not realHum or realHum.Health <= 0 then return end
    local pct = realHum.Health / math.max(realHum.MaxHealth, 1)
    if pct <= (config.emergencyHpThreshold or 0.3) and (tick() - lastEmergencyWarp > 7) then
        lastEmergencyWarp = tick()
        local safeTarget = config.checkpointPos or (realRoot.CFrame + Vector3.new(0, 80, 0))
        realRoot.AssemblyLinearVelocity = Vector3.zero
        realRoot.AssemblyAngularVelocity = Vector3.zero
        local char = player.Character
        if char then char:PivotTo(safeTarget) end
        avisar("🩸 Salvamento de Emergência", "HP crítico! Teleportado para área segura.", 3)
    end
end

-- 6. ANTI-KILLBRICK & HAZARD BYPASS
local function escanearKillbricks()
    if not config.antiKillbrick then return end
    local root = obterRootAtivo()
    if not root then return end
    local pos = root.Position
    for _, part in ipairs(Workspace:GetDescendants()) do
        if part:IsA("BasePart") and not part:IsDescendantOf(player.Character or Workspace) then
            local nm = part.Name:lower()
            if nm:find("lava") or nm:find("kill") or nm:find("acid") or nm:find("hazard") or nm:find("spike") or nm:find("deadly") or nm:find("death") or nm:find("dano") then
                if (part.Position - pos).Magnitude < 110 then
                    pcall(function()
                        part.CanTouch = false
                        part.CanCollide = false
                        local tt = part:FindFirstChildOfClass("TouchTransmitter")
                        if tt then tt:Destroy() end
                    end)
                end
            end
        end
    end
end

-- 7. ANTI-FALL DAMAGE
local function processarAntiFallDamage(realRoot, realHum)
    if not config.antiFallDamage or not realRoot or not realHum then return end
    if realHum:GetState() == Enum.HumanoidStateType.Freefall and realRoot.AssemblyLinearVelocity.Y < -55 then
        local ray = Workspace:Raycast(realRoot.Position, Vector3.new(0, -10, 0), rayParams)
        if ray and ray.Instance then
            realRoot.AssemblyLinearVelocity = Vector3.new(realRoot.AssemblyLinearVelocity.X, 0, realRoot.AssemblyLinearVelocity.Z)
            realHum:ChangeState(Enum.HumanoidStateType.RunningNoPhysics)
        end
    end
end

-- 8. ANTI-BLIND & SCREEN PURGE
local function limparEfeitosTela()
    if not config.antiBlind then return end
    for _, ef in ipairs(Lighting:GetChildren()) do
        if ef:IsA("BlurEffect") and ef.Size > 4 then
            ef.Size = 0
        elseif ef:IsA("ColorCorrectionEffect") and (ef.Brightness < -0.3 or ef.TintColor.R < 0.2) then
            ef.Brightness = 0
            ef.TintColor = Color3.fromRGB(255, 255, 255)
        end
    end
    Lighting.FogEnd = 9e9
    local atmo = Lighting:FindFirstChildOfClass("Atmosphere")
    if atmo and atmo.Density > 0.4 then atmo.Density = 0.2 end
end

-- ════════════════════════════════════════════════════════════════════════════════
-- SISTEMAS DE JOGADORES (BACKSTAB, ORBIT, TRACERS)
-- ════════════════════════════════════════════════════════════════════════════════
local function executarBackstab(alvo)
    if not alvo or not alvo.Character then
        avisar("🗡️ Backstab TP", "Jogador inválido ou sem personagem!")
        return
    end
    local tRoot = alvo.Character:FindFirstChild("HumanoidRootPart")
    local myChar = (config.modoAstralAtivo and copiaPersonagem) or player.Character
    local myRoot = obterRootAtivo()
    if tRoot and myChar and myRoot then
        local backCF = tRoot.CFrame * CFrame.new(0, 0, 4)
        myChar:PivotTo(backCF)
        myRoot.AssemblyLinearVelocity = Vector3.zero
        myRoot.AssemblyAngularVelocity = Vector3.zero
        avisar("🗡️ Backstab TP", "Teleportado para as costas de " .. alvo.DisplayName .. "!")
    end
end

local function alternarOrbit(alvo)
    if config.orbitAtivo and config.alvoOrbit == alvo then
        config.orbitAtivo = false
        config.alvoOrbit = nil
        avisar("🛸 Auto-Orbit: DESLIGADO", "Parado de orbitar.")
    else
        config.orbitAtivo = true
        config.alvoOrbit = alvo
        avisar("🛸 Auto-Orbit: ATIVADO", "Orbitando ao redor de " .. alvo.DisplayName .. "!")
    end
end

-- ════════════════════════════════════════════════════════════════════════════════
-- TEMAS VISUAIS & PÂNICO TOTAL [F12]
-- ════════════════════════════════════════════════════════════════════════════════
local function ciclarTema()
    config.temaIndice = (config.temaIndice % #temas) + 1
    local t = temas[config.temaIndice]
    if UI.mainStroke then UI.mainStroke.Color = t.accent end
    if UI.badgeLabel then UI.badgeLabel.BackgroundColor3 = t.accent end
    if UI.hudStroke  then UI.hudStroke.Color = t.accent end
    if UI.temaBtnLbl then UI.temaBtnLbl.Text = "🎨 Tema: " .. t.nome end
    if UI.tabBar then
        for _, b in ipairs(UI.tabBar:GetChildren()) do
            if b:IsA("TextButton") and b.LayoutOrder == UI.currentTabIdx then
                b.BackgroundColor3 = t.accent
            end
        end
    end
    avisar("🎨 Tema Alterado", "Novo tema visual: " .. t.nome)
end

local function ativarPanico()
    if config.modoAstralAtivo then alternarModoAstral() end
    if config.vooAtivo then alternarVoo() end
    if config.andarParedesAtivo then alternarAndarParedes() end
    if config.freezeAtivo then alternarFreeze() end
    if config.noclipAtivo then alternarNoclip() end
    if config.cameraLivreAtiva then alternarCameraLivre() end
    if config.magicFloorAtivo then alternarMagicFloor() end
    if config.elevadorAtivo then alternarElevador() end
    if config.invisibilidadeAtiva then alternarInvisibilidade() end
    if config.fullbrightAtivo then alternarFullbright() end
    if config.xrayAtivo then alternarXRay() end
    if config.espAtivo then alternarEsp() end
    if config.tracersAtivo then alternarTracers() end
    if config.autoClickerAtivo then alternarAutoClicker() end
    if config.autoWalkAtivo then alternarAutoWalk() end
    if config.superPuloAtivo then alternarSuperPulo() end
    if config.spiderClimbAtivo then alternarSpiderClimb() end
    if config.orbitAtivo then config.orbitAtivo = false config.alvoOrbit = nil end
    if config.bhopAtivo then config.bhopAtivo = false atualizarBotaoEstado("bhop", false) end
    if config.puloInfinitoAtivo then config.puloInfinitoAtivo = false atualizarBotaoEstado("pulo", false) end

    config.speedHackAtivo = false
    config.gravitacaoAtiva = false
    recalcularGravForce()

    local root = obterRootAtivo()
    if root then
        root.AssemblyLinearVelocity = Vector3.zero
        root.AssemblyAngularVelocity = Vector3.zero
        root.Anchored = false
    end

    limparVestigios()

    camera.FieldOfView = config.cameraFovOriginal or 70
    player.CameraMaxZoomDistance = state.droneOriginalMaxZoom or 128
    config.droneModeAtivo = false

    avisar("🚨 PÂNICO ATIVADO!", "TODOS os modos desligados e física normal restaurada!")
end

-- ════════════════════════════════════════════════════════════════════════════════
-- CONSTRUÇÃO DA INTERFACE GRÁFICA V9.0 (MODULAR EM BLOCOS DO ... END)
-- ════════════════════════════════════════════════════════════════════════════════
do
    local playerGui = player:WaitForChild("PlayerGui")
    local oldGui = playerGui:FindFirstChild("ColisaoV90Gui")
    if oldGui then oldGui:Destroy() end

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "ColisaoV90Gui"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = playerGui
    UI.screenGui = screenGui

    local function mkBtn(parent, x, y, w, h, titulo, sub, cor, key, cb)
        local corI = Color3.fromRGB(
            math.clamp(math.floor(cor.R*255*0.5),8,255),
            math.clamp(math.floor(cor.G*255*0.5),8,255),
            math.clamp(math.floor(cor.B*255*0.5),8,255))

        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(w,-8,0,h) btn.Position = UDim2.new(x,4,0,y)
        btn.BackgroundColor3 = corI btn.BorderSizePixel = 0 btn.Text = "" btn.AutoButtonColor = false
        btn.Parent = parent
        local bc = Instance.new("UICorner") bc.CornerRadius = UDim.new(0,7) bc.Parent = btn
        local bs = Instance.new("UIStroke") bs.Color = Color3.fromRGB(38,50,74) bs.Thickness = 1 bs.Parent = btn

        local t1 = Instance.new("TextLabel")
        t1.Name = "MainLabel" t1.Size = UDim2.new(1,-10,0,18) t1.Position = UDim2.new(0,8,0,4)
        t1.BackgroundTransparency = 1 t1.TextColor3 = Color3.fromRGB(255,255,255)
        t1.Font = Enum.Font.GothamBold t1.TextSize = 11 t1.Text = titulo
        t1.TextXAlignment = Enum.TextXAlignment.Left t1.Parent = btn

        local t2 = Instance.new("TextLabel")
        t2.Name = "SubLabel" t2.Size = UDim2.new(1,-10,0,14) t2.Position = UDim2.new(0,8,0,23)
        t2.BackgroundTransparency = 1 t2.TextColor3 = Color3.fromRGB(180,195,215)
        t2.Font = Enum.Font.Gotham t2.TextSize = 9 t2.Text = sub
        t2.TextXAlignment = Enum.TextXAlignment.Left t2.Parent = btn

        btn.MouseEnter:Connect(function() TweenService:Create(btn,TweenInfo.new(0.1),{BackgroundColor3=cor}):Play() end)
        btn.MouseLeave:Connect(function()
            local info = key and guiBotoes[key]
            TweenService:Create(btn,TweenInfo.new(0.1),{BackgroundColor3=(info and info.isAtivo) and cor or corI}):Play()
        end)
        btn.MouseButton1Click:Connect(cb)

        if key then
            guiBotoes[key] = {button=btn, corAtiva=cor, corInativa=corI, baseSub=sub, isAtivo=false}
        end
        return btn
    end

    local tabFrames = {}

    -- BLOCO 1: JANELA PRINCIPAL & ABAS COM SCROLL
    do
        local main = Instance.new("Frame")
        main.Name = "MainFrame"
        main.Size = UDim2.new(0,760,0,620)
        main.Position = UDim2.new(0.5,-380,0.5,-310)
        main.BackgroundColor3 = Color3.fromRGB(10,13,20)
        main.BorderSizePixel = 0
        main.Active = true main.Draggable = true main.ClipsDescendants = true main.Visible = false
        main.Parent = screenGui
        UI.main = main

        local mc = Instance.new("UICorner") mc.CornerRadius = UDim.new(0,12) mc.Parent = main
        local ms = Instance.new("UIStroke") ms.Color = Color3.fromRGB(168,85,247) ms.Thickness = 1.5 ms.Parent = main
        UI.mainStroke = ms

        local topBar = Instance.new("Frame")
        topBar.Size = UDim2.new(1,0,0,44) topBar.BackgroundColor3 = Color3.fromRGB(16,20,32)
        topBar.BorderSizePixel = 0 topBar.Parent = main
        local tbc = Instance.new("UICorner") tbc.CornerRadius = UDim.new(0,12) tbc.Parent = topBar

        local badge = Instance.new("TextLabel")
        badge.Size = UDim2.new(0,150,0,26) badge.Position = UDim2.new(0,10,0.5,-13)
        badge.BackgroundColor3 = Color3.fromRGB(168,85,247) badge.TextColor3 = Color3.fromRGB(255,255,255)
        badge.Font = Enum.Font.GothamBold badge.TextSize = 11 badge.Text = "👻 V9.0 DEFENDER" badge.Parent = topBar
        local bgc = Instance.new("UICorner") bgc.CornerRadius = UDim.new(0,6) bgc.Parent = badge
        UI.badgeLabel = badge

        local titLbl = Instance.new("TextLabel")
        titLbl.Size = UDim2.new(0,440,1,0) titLbl.Position = UDim2.new(0,168,0,0)
        titLbl.BackgroundTransparency = 1 titLbl.TextColor3 = Color3.fromRGB(210,220,255)
        titLbl.Font = Enum.Font.GothamBold titLbl.TextSize = 11 titLbl.TextXAlignment = Enum.TextXAlignment.Left
        titLbl.Text = "Suite Astral V9.0  •  45+ Sistemas  •  [F8] Menu  •  [F12] PÂNICO" titLbl.Parent = topBar

        local btnPanic = Instance.new("TextButton")
        btnPanic.Size = UDim2.new(0,80,0,26) btnPanic.Position = UDim2.new(1,-120,0.5,-13)
        btnPanic.BackgroundColor3 = Color3.fromRGB(220,38,38) btnPanic.TextColor3 = Color3.fromRGB(255,255,255)
        btnPanic.Font = Enum.Font.GothamBold btnPanic.TextSize = 10 btnPanic.Text = "🚨 PÂNICO"
        btnPanic.BorderSizePixel = 0 btnPanic.Parent = topBar
        local pcc = Instance.new("UICorner") pcc.CornerRadius = UDim.new(0,6) pcc.Parent = btnPanic
        btnPanic.MouseButton1Click:Connect(ativarPanico)

        local closeBtn = Instance.new("TextButton")
        closeBtn.Size = UDim2.new(0,28,0,28) closeBtn.Position = UDim2.new(1,-36,0.5,-14)
        closeBtn.BackgroundColor3 = Color3.fromRGB(239,68,68) closeBtn.TextColor3 = Color3.fromRGB(255,255,255)
        closeBtn.Font = Enum.Font.GothamBold closeBtn.TextSize = 13 closeBtn.Text = "✕"
        closeBtn.BorderSizePixel = 0 closeBtn.Parent = topBar
        local cbc = Instance.new("UICorner") cbc.CornerRadius = UDim.new(0,6) cbc.Parent = closeBtn
        closeBtn.MouseButton1Click:Connect(function() main.Visible = false end)

        local tabBar = Instance.new("Frame")
        tabBar.Size = UDim2.new(1,-20,0,32) tabBar.Position = UDim2.new(0,10,0,48)
        tabBar.BackgroundTransparency = 1 tabBar.Parent = main
        UI.tabBar = tabBar
        local tll = Instance.new("UIListLayout")
        tll.FillDirection = Enum.FillDirection.Horizontal tll.Padding = UDim.new(0,6) tll.Parent = tabBar

        local bodyFrame = Instance.new("Frame")
        bodyFrame.Size = UDim2.new(1,0,1,-(44+36))
        bodyFrame.Position = UDim2.new(0,0,0,44+36)
        bodyFrame.BackgroundTransparency = 1 bodyFrame.Parent = main

        local tabNames = {"🚀 Mobilidade","🛠️ Utilitários","👥 Jogadores","🛡️ Defesas","⚙️ Config"}
        local tabButtons = {}
        UI.currentTabIdx = 1
        local function switchTab(idx)
            UI.currentTabIdx = idx
            local curTema = temas[config.temaIndice]
            for j,f in pairs(tabFrames) do f.Visible = (j==idx) end
            for j,b in pairs(tabButtons) do
                b.BackgroundColor3 = j==idx and curTema.accent or Color3.fromRGB(22,28,42)
                b.TextColor3 = j==idx and Color3.fromRGB(255,255,255) or Color3.fromRGB(150,165,185)
            end
        end

        for i,name in ipairs(tabNames) do
            local tb = Instance.new("TextButton")
            tb.Size = UDim2.new(0,140,0,26)
            tb.BackgroundColor3 = i==1 and Color3.fromRGB(168,85,247) or Color3.fromRGB(22,28,42)
            tb.TextColor3 = i==1 and Color3.fromRGB(255,255,255) or Color3.fromRGB(150,165,185)
            tb.Font = Enum.Font.GothamBold tb.TextSize = 10 tb.Text = name
            tb.BorderSizePixel = 0 tb.LayoutOrder = i tb.Parent = tabBar
            local tc = Instance.new("UICorner") tc.CornerRadius = UDim.new(0,5) tc.Parent = tb
            tabButtons[i] = tb
            tb.MouseButton1Click:Connect(function() switchTab(i) end)

            local f = Instance.new("ScrollingFrame")
            f.Size = UDim2.new(1,0,1,0) f.BackgroundTransparency = 1 f.Visible = (i==1)
            f.ScrollBarThickness = 5 f.ScrollBarImageColor3 = Color3.fromRGB(168,85,247)
            f.BorderSizePixel = 0 f.Parent = bodyFrame
            tabFrames[i] = f
        end
    end

    -- BLOCO 2: TAB 1 - MOBILIDADE & FÍSICA
    do
        local t1f = tabFrames[1]
        t1f.CanvasSize = UDim2.new(0,0,0,510)
        local t1p = Instance.new("UIPadding") t1p.PaddingLeft = UDim.new(0,6) t1p.PaddingTop = UDim.new(0,8) t1p.Parent = t1f

        mkBtn(t1f,0,  0,  0.5,40,"👻 Modo Astral [G]",         "Cópia no chão • Corpo a +850 studs",        Color3.fromRGB(147,51,234),  "astral",    alternarModoAstral)
        mkBtn(t1f,0.5,0,  0.5,40,"🦅 Fly Mode [F]",             "Voo suave + Turbo [Shift]",                 Color3.fromRGB(37,99,235),   "voo",       alternarVoo)
        mkBtn(t1f,0,  44, 0.5,40,"🧗 Andar em Paredes [L]",     "Paredes/tetos com câmera nativa",           Color3.fromRGB(16,185,129),  "paredes",   alternarAndarParedes)
        mkBtn(t1f,0.5,44, 0.5,40,"🦘 Pulo Infinito [P]",        "Pule no ar ilimitadamente",                 Color3.fromRGB(5,150,105),   "pulo",      alternarPuloInfinito)
        mkBtn(t1f,0,  88, 0.5,40,"❄️ Freeze [Q]",               "Trava física absoluta no lugar",            Color3.fromRGB(56,189,248),  "freeze",    alternarFreeze)
        mkBtn(t1f,0.5,88, 0.5,40,"🪝 Grappling Hook [Y]",      "Gancho neon que puxa até o alvo",          Color3.fromRGB(6,182,212),   "grapple",   dispararGrapple)
        mkBtn(t1f,0,  132,0.5,40,"📍 Teleporte Checkpoint [R]", "Retorna ao ponto salvo imediatamente",      Color3.fromRGB(234,88,12),   "checkpoint",carregarCheckpoint)
        mkBtn(t1f,0.5,132,0.5,40,"💾 Gravar Checkpoint [Shift+R]","Salva a posição onde estiver",            Color3.fromRGB(249,115,22),  nil,         salvarCheckpoint)
        mkBtn(t1f,0,  176,0.5,40,"🔮 Magic Floor [U]",          "Plataforma sob os pés para andar no ar",    Color3.fromRGB(13,148,136),  "magicfloor",alternarMagicFloor)
        mkBtn(t1f,0.5,176,0.5,40,"🛗 Elevador Astral [End]",    "Subida/descida vertical com [Espaço/Ctrl]", Color3.fromRGB(124,58,237),  "elevador",  alternarElevador)
        mkBtn(t1f,0,  220,0.5,40,"🦿 Bhop Glide [F7]",          "Conserva e acumula impulso pulando",        Color3.fromRGB(20,184,166),  "bhop",      alternarBhop)
        mkBtn(t1f,0.5,220,0.5,40,"⚡ Flash Dash [F10]",         "Impulso supersônico de 70 studs",           Color3.fromRGB(217,70,239),  nil,         executarDash)
        mkBtn(t1f,0,  264,0.5,40,"🦘 Super Pulo (High Jump)",   "Pulos colossais de 120 studs de altura",    Color3.fromRGB(16,185,129),  "superpulo", alternarSuperPulo)
        mkBtn(t1f,0.5,264,0.5,40,"🧭 Piloto Auto [Home]",       "Caminha para frente sozinho",               Color3.fromRGB(14,165,233),  "autowalk",  alternarAutoWalk)
        mkBtn(t1f,0,  308,0.5,40,"🕷️ Spider Climb",            "Escala paredes verticais encostando nelas", Color3.fromRGB(234,88,12),   "spiderclimb",alternarSpiderClimb)
        mkBtn(t1f,0.5,308,0.5,40,"🎥 Câmera Livre [C]",         "Desacoplada do char • WASD+mouse",          Color3.fromRGB(100,116,139), "freecam",   alternarCameraLivre)

        local cardV = Instance.new("Frame")
        cardV.Size = UDim2.new(1,-16,0,38) cardV.Position = UDim2.new(0,8,0,356)
        cardV.BackgroundColor3 = Color3.fromRGB(14,18,28) cardV.BorderSizePixel = 0 cardV.Parent = t1f
        local cvc = Instance.new("UICorner") cvc.CornerRadius = UDim.new(0,6) cvc.Parent = cardV
        local cvs = Instance.new("UIStroke") cvs.Color = Color3.fromRGB(37,99,235) cvs.Thickness = 1 cvs.Parent = cardV

        local velLbl = Instance.new("TextLabel")
        velLbl.Size = UDim2.new(0,330,1,0) velLbl.Position = UDim2.new(0,10,0,0)
        velLbl.BackgroundTransparency = 1 velLbl.Font = Enum.Font.GothamBold velLbl.TextSize = 11
        velLbl.TextColor3 = Color3.fromRGB(210,225,255) velLbl.TextXAlignment = Enum.TextXAlignment.Left velLbl.Parent = cardV
        UI.velLbl = velLbl
        local function atualizarVelLbl()
            velLbl.Text = string.format("🦅 Velocidade de Voo: %d studs/s (Turbo: %d)", config.velocidadeVoo, math.floor(config.velocidadeVoo*config.multiplicadorSprintVoo))
        end
        atualizarVelLbl()

        for _,vi in ipairs({{"-10",-10,UDim2.new(1,-185,0.5,-13)},{"-1",-1,UDim2.new(1,-137,0.5,-13)},{"+1",1,UDim2.new(1,-89,0.5,-13)},{"+10",10,UDim2.new(1,-41,0.5,-13)}}) do
            local vb = Instance.new("TextButton")
            vb.Size = UDim2.new(0,40,0,26) vb.Position = vi[3] vb.BackgroundColor3 = Color3.fromRGB(28,38,58)
            vb.TextColor3 = Color3.fromRGB(255,255,255) vb.Font = Enum.Font.GothamBold vb.TextSize = 10
            vb.Text = vi[1] vb.BorderSizePixel = 0 vb.Parent = cardV
            local vbc = Instance.new("UICorner") vbc.CornerRadius = UDim.new(0,4) vbc.Parent = vb
            local d = vi[2]
            vb.MouseButton1Click:Connect(function()
                config.velocidadeVoo = math.clamp(config.velocidadeVoo + d, 5, 500)
                atualizarVelLbl()
                avisar("🦅 Voo","Velocidade: "..config.velocidadeVoo.." studs/s")
            end)
        end

        local cardA = Instance.new("Frame")
        cardA.Size = UDim2.new(1,-16,0,38) cardA.Position = UDim2.new(0,8,0,402)
        cardA.BackgroundColor3 = Color3.fromRGB(14,18,28) cardA.BorderSizePixel = 0 cardA.Parent = t1f
        local cac = Instance.new("UICorner") cac.CornerRadius = UDim.new(0,6) cac.Parent = cardA
        local cas = Instance.new("UIStroke") cas.Color = Color3.fromRGB(59,130,246) cas.Thickness = 1 cas.Parent = cardA

        local aLbl = Instance.new("TextLabel")
        aLbl.Size = UDim2.new(0,310,1,0) aLbl.Position = UDim2.new(0,10,0,0)
        aLbl.BackgroundTransparency = 1 aLbl.Font = Enum.Font.GothamBold aLbl.TextSize = 11
        aLbl.TextColor3 = Color3.fromRGB(210,225,255) aLbl.TextXAlignment = Enum.TextXAlignment.Left aLbl.Parent = cardA
        UI.aLbl = aLbl
        local function updALbl()
            aLbl.Text = string.format("✈️ Offset Fly Safe: %d studs (%s)", config.slotAlturaOffset, config.slotAlturaDirecao:upper())
        end
        updALbl()

        for _,ai in ipairs({{"-5",-5,UDim2.new(1,-185,0.5,-13)},{"+5",5,UDim2.new(1,-137,0.5,-13)}}) do
            local ab = Instance.new("TextButton")
            ab.Size = UDim2.new(0,40,0,26) ab.Position = ai[3] ab.BackgroundColor3 = Color3.fromRGB(28,38,58)
            ab.TextColor3 = Color3.fromRGB(255,255,255) ab.Font = Enum.Font.GothamBold ab.TextSize = 10
            ab.Text = ai[1] ab.BorderSizePixel = 0 ab.Parent = cardA
            local abc = Instance.new("UICorner") abc.CornerRadius = UDim.new(0,4) abc.Parent = ab
            local d = ai[2]
            ab.MouseButton1Click:Connect(function()
                config.slotAlturaOffset = math.clamp(config.slotAlturaOffset + d, 0, 300)
                updALbl()
            end)
        end

        local invBtn = Instance.new("TextButton")
        invBtn.Size = UDim2.new(0,80,0,26) invBtn.Position = UDim2.new(1,-89,0.5,-13)
        invBtn.BackgroundColor3 = Color3.fromRGB(59,130,246) invBtn.TextColor3 = Color3.fromRGB(255,255,255)
        invBtn.Font = Enum.Font.GothamBold invBtn.TextSize = 10 invBtn.Text = "INVERTER" invBtn.BorderSizePixel = 0 invBtn.Parent = cardA
        local ibc = Instance.new("UICorner") ibc.CornerRadius = UDim.new(0,4) ibc.Parent = invBtn
        invBtn.MouseButton1Click:Connect(function()
            config.slotAlturaDirecao = (config.slotAlturaDirecao == "cima") and "baixo" or "cima"
            updALbl()
        end)
    end

    -- BLOCO 3: TAB 2 - UTILITÁRIOS & VISÃO
    do
        local t2f = tabFrames[2]
        t2f.CanvasSize = UDim2.new(0,0,0,510)
        local t2p = Instance.new("UIPadding") t2p.PaddingLeft = UDim.new(0,6) t2p.PaddingTop = UDim.new(0,8) t2p.Parent = t2f

        mkBtn(t2f,0,  0,  0.5,40,"💥 Onda de Choque [Insert]",  "Lança peças móveis ao redor para longe",    Color3.fromRGB(168,85,247),  nil,          dispararOndaDeChoque)
        mkBtn(t2f,0.5,0,  0.5,40,"🛸 Modo Drone [F5]",          "Destrava zoom de câmera até 2000 studs",    Color3.fromRGB(99,102,241),  "drone",      alternarDroneMode)
        mkBtn(t2f,0,  44, 0.5,40,"🔭 Seletor de FOV [F11]",     "Alterna 70°, 90°, 110° e 30° (Sniper)",     Color3.fromRGB(59,130,246),  nil,          ciclarFov)
        mkBtn(t2f,0.5,44, 0.5,40,"💡 Fullbright [H]",            "Visão Noturna: mapas 100% claros",          Color3.fromRGB(234,179,8),   "fullbright", alternarFullbright)
        mkBtn(t2f,0,  88, 0.5,40,"🛡️ Anti-AFK [F6]",             "Nunca mais seja desconectado (20m)",        Color3.fromRGB(16,185,129),  "antiafk",    alternarAntiAfk)
        mkBtn(t2f,0.5,88, 0.5,40,"🔘 Radar Interações [F4]",    "Destaca Prompts e ClickDetectors",          Color3.fromRGB(217,119,6),   "radar",      alternarRadarInteracoes)
        mkBtn(t2f,0,  132,0.5,40,"🖱️ Auto-Clicker Turbo [F9]",  "20 cliques/s contínuos no mouse",           Color3.fromRGB(244,63,94),   "autoclicker",alternarAutoClicker)
        mkBtn(t2f,0.5,132,0.5,40,"⚡ Auto-Interact Aura",        "Dispara ProximityPrompts sem esperar",      Color3.fromRGB(234,88,12),   "autointeract",alternarAutoInteract)
        mkBtn(t2f,0,  176,0.5,40,"🧲 Coletor Magnético",        "Puxa itens móveis e colecionáveis",         Color3.fromRGB(13,148,136),  "magnet",     alternarMagnet)
        mkBtn(t2f,0.5,176,0.5,40,"🚀 FPS Booster",              "Otimiza texturas e sombras (+60 FPS)",      Color3.fromRGB(16,185,129),  "fpsbooster", alternarFpsBooster)
        mkBtn(t2f,0,  220,0.5,40,"👤 Invisível [T]",            "Transparência total + sem sombra",          Color3.fromRGB(71,85,105),   "invisivel",  alternarInvisibilidade)
        mkBtn(t2f,0.5,220,0.5,40,"🧱 Noclip Total [N]",         "Atravessa paredes c/ restauração ativa",    Color3.fromRGB(225,29,72),   "noclip",     alternarNoclip)
        mkBtn(t2f,0,  264,0.5,40,"🔍 Visão Raio-X [X]",         "Paredes transparentes (0.65)",              Color3.fromRGB(180,83,9),    "xray",       alternarXRay)
        mkBtn(t2f,0.5,264,0.5,40,"🗑️ Modo Apagar [B]",         "Clique nos objetos para destruí-los",       Color3.fromRGB(100,116,139), "delete",     alternarDeleteMode)
        mkBtn(t2f,0,  308,0.5,40,"↩️ Undo Delete [Z]",          "Restaura o último objeto deletado",         Color3.fromRGB(234,88,12),   nil,          executarUndoDelete)
        mkBtn(t2f,0.5,308,0.5,40,"🧹 Limpar Vestígios [Del]",   "Remove plataformas e efeitos temporários",  Color3.fromRGB(239,68,68),   nil,          limparVestigios)

        local cardSH = Instance.new("Frame")
        cardSH.Size = UDim2.new(1,-16,0,38) cardSH.Position = UDim2.new(0,8,0,356)
        cardSH.BackgroundColor3 = Color3.fromRGB(14,18,28) cardSH.BorderSizePixel = 0 cardSH.Parent = t2f
        local shc = Instance.new("UICorner") shc.CornerRadius = UDim.new(0,6) shc.Parent = cardSH
        local shs = Instance.new("UIStroke") shs.Color = Color3.fromRGB(161,98,7) shs.Thickness = 1 shs.Parent = cardSH

        local shLbl = Instance.new("TextLabel")
        shLbl.Size = UDim2.new(0,310,1,0) shLbl.Position = UDim2.new(0,10,0,0)
        shLbl.BackgroundTransparency = 1 shLbl.Font = Enum.Font.GothamBold shLbl.TextSize = 11
        shLbl.TextColor3 = Color3.fromRGB(210,225,255) shLbl.TextXAlignment = Enum.TextXAlignment.Left shLbl.Parent = cardSH
        UI.shLbl = shLbl
        local function updSHLbl()
            shLbl.Text = string.format("⚡ Speed Multiplier: %.1f× (%d studs/s)", config.speedHackMultiplier, math.floor(config.velocidadePadrao * config.speedHackMultiplier))
        end
        updSHLbl()

        for _,si in ipairs({{"-1",-1,UDim2.new(1,-185,0.5,-13)},{"-0.5",-0.5,UDim2.new(1,-137,0.5,-13)},{"+0.5",0.5,UDim2.new(1,-89,0.5,-13)},{"+1",1,UDim2.new(1,-41,0.5,-13)}}) do
            local sb2 = Instance.new("TextButton")
            sb2.Size = UDim2.new(0,40,0,26) sb2.Position = si[3] sb2.BackgroundColor3 = Color3.fromRGB(28,38,58)
            sb2.TextColor3 = Color3.fromRGB(255,255,255) sb2.Font = Enum.Font.GothamBold sb2.TextSize = 10
            sb2.Text = si[1] sb2.BorderSizePixel = 0 sb2.Parent = cardSH
            local sbc2 = Instance.new("UICorner") sbc2.CornerRadius = UDim.new(0,4) sbc2.Parent = sb2
            local d = si[2]
            sb2.MouseButton1Click:Connect(function()
                config.speedHackMultiplier = math.clamp(config.speedHackMultiplier + d, 1, 10)
                updSHLbl()
            end)
        end

        local cardGr = Instance.new("Frame")
        cardGr.Size = UDim2.new(1,-16,0,38) cardGr.Position = UDim2.new(0,8,0,402)
        cardGr.BackgroundColor3 = Color3.fromRGB(14,18,28) cardGr.BorderSizePixel = 0 cardGr.Parent = t2f
        local grc = Instance.new("UICorner") grc.CornerRadius = UDim.new(0,6) grc.Parent = cardGr
        local grs = Instance.new("UIStroke") grs.Color = Color3.fromRGB(21,128,61) grs.Thickness = 1 grs.Parent = cardGr

        local gravLbl = Instance.new("TextLabel")
        gravLbl.Size = UDim2.new(0,280,1,0) gravLbl.Position = UDim2.new(0,10,0,0)
        gravLbl.BackgroundTransparency = 1 gravLbl.Font = Enum.Font.GothamBold gravLbl.TextSize = 11
        gravLbl.TextColor3 = Color3.fromRGB(210,225,255) gravLbl.TextXAlignment = Enum.TextXAlignment.Left gravLbl.Parent = cardGr
        UI.gravLblRef = gravLbl
        local function updGravLbl()
            gravLbl.Text = string.format("🌍 Gravidade Custom: %d%% (%s)", config.gravitacaoPercent, config.gravitacaoAtiva and "ON" or "OFF")
        end
        updGravLbl()

        for _,gi in ipairs({{"Zero-G",0,UDim2.new(1,-222,0.5,-13)},{"-25%",-25,UDim2.new(1,-174,0.5,-13)},{"+25%",25,UDim2.new(1,-126,0.5,-13)},{"Normal",100,UDim2.new(1,-78,0.5,-13)},{"+100%",100,UDim2.new(1,-30,0.5,-13)}}) do
            local gb = Instance.new("TextButton")
            gb.Size = UDim2.new(0,44,0,26) gb.Position = gi[3] gb.BackgroundColor3 = Color3.fromRGB(28,38,58)
            gb.TextColor3 = Color3.fromRGB(255,255,255) gb.Font = Enum.Font.GothamBold gb.TextSize = 9
            gb.Text = gi[1] gb.BorderSizePixel = 0 gb.Parent = cardGr
            local gbc = Instance.new("UICorner") gbc.CornerRadius = UDim.new(0,4) gbc.Parent = gb
            local name2,val = gi[1], gi[2]
            gb.MouseButton1Click:Connect(function()
                if name2 == "Zero-G" then config.gravitacaoPercent = 0
                elseif name2 == "Normal" then config.gravitacaoPercent = 100
                else config.gravitacaoPercent = math.clamp(config.gravitacaoPercent + val, 0, 400) end
                updGravLbl()
                recalcularGravForce()
            end)
        end
    end

    -- BLOCO 4: TAB 3 - JOGADORES & RADAR
    do
        local t3f = tabFrames[3]
        t3f.CanvasSize = UDim2.new(0,0,0,420)
        local t3p = Instance.new("UIPadding") t3p.PaddingLeft = UDim.new(0,6) t3p.PaddingTop = UDim.new(0,8) t3p.Parent = t3f

        mkBtn(t3f,0,  0, 0.5,42,"👁️ ESP Jogadores [V]",        "Aura + nome + distância + HP",              Color3.fromRGB(13,148,136),  "esp",       alternarEsp)
        mkBtn(t3f,0.5,0, 0.5,42,"🎨 Cor da Aura [M]",           "Alterna entre 8 cores de ESP",              Color3.fromRGB(217,70,239),  nil,         alternarCorAura)
        mkBtn(t3f,0,  48,0.5,42,"👥 Lista Jogadores [J]",        "Avatares, TP, View, Backstab & Orbit",     Color3.fromRGB(99,102,241),  "playerlist",function() UI.plFrame.Visible = not UI.plFrame.Visible end)
        mkBtn(t3f,0.5,48,0.5,42,"📏 Tracers 3D",                "Linhas neon conectadas aos jogadores",      Color3.fromRGB(6,182,212),   "tracers",   alternarTracers)
        mkBtn(t3f,0,  96,0.5,42,"🔮 Auras Invisíveis [K]",      "Revela/apaga zonas de perigo",              Color3.fromRGB(244,63,94),   "auras",     alternarDetectorAuras)
        mkBtn(t3f,0.5,96,0.5,42,"📍 SpawnList [F3]",             "Lista SpawnLocations p/ teleporte",         Color3.fromRGB(234,88,12),   "spawnlist", function() UI.spFrame.Visible = not UI.spFrame.Visible end)
        mkBtn(t3f,0,  144,0.5,42,"📦 Outline Tracker [O]",       "SelectionBox colorida por distância",       Color3.fromRGB(99,102,241),  "outline",   alternarOutlineTracker)
        mkBtn(t3f,0.5,144,0.5,42,"🛸 Parar Orbit / Desengatar",  "Cancela qualquer perseguição orbital",      Color3.fromRGB(239,68,68),   nil,         function() config.orbitAtivo = false config.alvoOrbit = nil avisar("🛸 Orbit","Orbit cancelado.") end)

        local corCard = Instance.new("Frame")
        corCard.Size = UDim2.new(1,-16,0,32) corCard.Position = UDim2.new(0,8,0,196)
        corCard.BackgroundColor3 = Color3.fromRGB(14,18,28) corCard.BorderSizePixel = 0 corCard.Parent = t3f
        local ccc = Instance.new("UICorner") ccc.CornerRadius = UDim.new(0,6) ccc.Parent = corCard
        local corEspLbl = Instance.new("TextLabel")
        corEspLbl.Size = UDim2.new(1,-10,1,0) corEspLbl.Position = UDim2.new(0,10,0,0)
        corEspLbl.BackgroundTransparency = 1 corEspLbl.Font = Enum.Font.GothamBold corEspLbl.TextSize = 11
        corEspLbl.TextColor3 = coresAura[1].cor corEspLbl.TextXAlignment = Enum.TextXAlignment.Left
        corEspLbl.Text = "🎨 Cor ESP Ativa: "..coresAura[1].nome.."  ● ● ●" corEspLbl.Parent = corCard
        UI.corEspLblRef = corEspLbl
    end

    -- BLOCO 5: TAB 4 - DEFESAS BLINDADAS (DESATIVADAS POR PADRÃO)
    do
        local t4f = tabFrames[4]
        t4f.CanvasSize = UDim2.new(0,0,0,460)
        local t4p = Instance.new("UIPadding") t4p.PaddingLeft = UDim.new(0,8) t4p.PaddingTop = UDim.new(0,8) t4p.Parent = t4f

        local defensas = {
            {"🛡️ Anti-Fling & NoPlayerCollide", "antiFling",        "Impede que outros players te empurrem ou arremessem", Color3.fromRGB(56,189,248)},
            {"🕳️ Anti-Void & Queda Segura",    "antiVoid",         "Resgate automático de abismo, void e quedas no vazio", Color3.fromRGB(168,85,247)},
            {"⚡ Anti-Ragdoll & Anti-Sit",      "antiRagdoll",      "Levanta imediatamente de tombos e bloqueia sentar",   Color3.fromRGB(16,185,129)},
            {"⛓️ Anti-Anchor (Descongelar)",    "antiAnchor",       "Desancora o corpo caso scripts tentem te congelar",  Color3.fromRGB(234,88,12)},
            {"🩸 Auto-Rescue por HP Baixo",     "autoEmergencyHp",  "Teleporta para local seguro quando HP < 30%",         Color3.fromRGB(239,68,68)},
            {"☣️ Anti-Killbrick & Hazard",      "antiKillbrick",    "Desativa toque letal de lava, ácido e espinhos",      Color3.fromRGB(234,179,8)},
            {"🪂 Anti-Dano de Queda",          "antiFallDamage",   "Amortece a velocidade vertical antes do impacto",     Color3.fromRGB(20,184,166)},
            {"🌫️ Anti-Blind & Screen Purge",   "antiBlind",        "Limpa telas pretas, névoas escuras e overlays cegos", Color3.fromRGB(99,102,241)},
        }

        for idx,def in ipairs(defensas) do
            local titulo,key,sub,cor = def[1],def[2],def[3],def[4]
            local posY = (idx-1)*54
            local card = Instance.new("Frame")
            card.Size = UDim2.new(1,-16,0,48) card.Position = UDim2.new(0,8,0,posY)
            card.BackgroundColor3 = Color3.fromRGB(14,18,28) card.BorderSizePixel = 0 card.Parent = t4f
            local cc2 = Instance.new("UICorner") cc2.CornerRadius = UDim.new(0,6) cc2.Parent = card
            local cs2 = Instance.new("UIStroke")
            cs2.Color = config[key] and cor or Color3.fromRGB(38,50,70)
            cs2.Thickness = 1 cs2.Parent = card

            local lbl = Instance.new("TextLabel")
            lbl.Size = UDim2.new(1,-80,0,20) lbl.Position = UDim2.new(0,10,0,5)
            lbl.BackgroundTransparency = 1 lbl.Font = Enum.Font.GothamBold lbl.TextSize = 11
            lbl.TextColor3 = Color3.fromRGB(220,230,255) lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.Text = titulo lbl.Parent = card

            local sublbl = Instance.new("TextLabel")
            sublbl.Size = UDim2.new(1,-80,0,16) sublbl.Position = UDim2.new(0,10,0,26)
            sublbl.BackgroundTransparency = 1 sublbl.Font = Enum.Font.Gotham sublbl.TextSize = 9
            sublbl.TextColor3 = config[key] and Color3.fromRGB(80,255,140) or Color3.fromRGB(148,163,184)
            sublbl.TextXAlignment = Enum.TextXAlignment.Left
            sublbl.Text = config[key] and "● ATIVO & PROTEGENDO" or sub sublbl.Parent = card

            local tog = Instance.new("TextButton")
            tog.Size = UDim2.new(0,56,0,28) tog.Position = UDim2.new(1,-64,0.5,-14)
            tog.BackgroundColor3 = config[key] and Color3.fromRGB(16,185,129) or Color3.fromRGB(40,52,74)
            tog.TextColor3 = Color3.fromRGB(255,255,255) tog.Font = Enum.Font.GothamBold tog.TextSize = 11
            tog.Text = config[key] and "ON" or "OFF" tog.BorderSizePixel = 0 tog.Parent = card
            local tc2 = Instance.new("UICorner") tc2.CornerRadius = UDim.new(0,5) tc2.Parent = tog

            local k = key
            tog.MouseButton1Click:Connect(function()
                config[k] = not config[k]
                local at = config[k]
                tog.BackgroundColor3 = at and Color3.fromRGB(16,185,129) or Color3.fromRGB(40,52,74)
                tog.Text = at and "ON" or "OFF"
                cs2.Color = at and cor or Color3.fromRGB(38,50,70)
                sublbl.TextColor3 = at and Color3.fromRGB(80,255,140) or Color3.fromRGB(148,163,184)
                sublbl.Text = at and "● ATIVO & PROTEGENDO" or sub
                avisar((at and "🛡️ " or "❌ ")..titulo, at and "ATIVADO!" or "DESATIVADO.")
            end)
        end
    end

    -- BLOCO 6: TAB 5 - CONFIGURAÇÕES, TEMAS, GERENCIADOR DE TECLAS & GUIA V9.0
    do
        local t5f = tabFrames[5]
        local t5p = Instance.new("UIPadding") t5p.PaddingLeft = UDim.new(0,8) t5p.PaddingTop = UDim.new(0,8) t5p.Parent = t5f

        local themeCard = Instance.new("Frame")
        themeCard.Size = UDim2.new(1,-16,0,40) themeCard.Position = UDim2.new(0,8,0,0)
        themeCard.BackgroundColor3 = Color3.fromRGB(14,18,28) themeCard.BorderSizePixel = 0 themeCard.Parent = t5f
        local tmc = Instance.new("UICorner") tmc.CornerRadius = UDim.new(0,6) tmc.Parent = themeCard
        local tms = Instance.new("UIStroke") tms.Color = Color3.fromRGB(168,85,247) tms.Thickness = 1 tms.Parent = themeCard

        local temaLbl = Instance.new("TextLabel")
        temaLbl.Size = UDim2.new(0,310,1,0) temaLbl.Position = UDim2.new(0,10,0,0)
        temaLbl.BackgroundTransparency = 1 temaLbl.Font = Enum.Font.GothamBold temaLbl.TextSize = 11
        temaLbl.TextColor3 = Color3.fromRGB(210,225,255) temaLbl.TextXAlignment = Enum.TextXAlignment.Left
        temaLbl.Text = "🎨 Tema Visual Ativo: " .. temas[1].nome temaLbl.Parent = themeCard
        UI.temaBtnLbl = temaLbl

        local temaBtn = Instance.new("TextButton")
        temaBtn.Size = UDim2.new(0,130,0,26) temaBtn.Position = UDim2.new(1,-138,0.5,-13)
        temaBtn.BackgroundColor3 = Color3.fromRGB(168,85,247) temaBtn.TextColor3 = Color3.fromRGB(255,255,255)
        temaBtn.Font = Enum.Font.GothamBold temaBtn.TextSize = 10 temaBtn.Text = "CICLAR TEMA" temaBtn.BorderSizePixel = 0 temaBtn.Parent = themeCard
        local tmbc = Instance.new("UICorner") tmbc.CornerRadius = UDim.new(0,4) tmbc.Parent = temaBtn
        temaBtn.MouseButton1Click:Connect(ciclarTema)

        local cfgItems = {
            {"🏃 Velocidade Normal",    "velocidadePadrao",   8,   100, 2},
            {"💨 Velocidade Sprint",    "velocidadeSprint",   16,  200, 4},
            {"🦅 Velocidade Voo",       "velocidadeVoo",      5,   500, 5},
            {"🚀 Turbo Voo (×0.5)",     "multiplicadorSprintVoo",1, 10, 0.5},
            {"☁️ Altura Céu Astral",    "alturaCeu",          100, 2000,50},
            {"🎥 Vel. Free Cam",        "freeCamSpeed",       5,   200, 5},
        }

        for idx,cf2 in ipairs(cfgItems) do
            local lbl2,key2,mn,mx,step = cf2[1],cf2[2],cf2[3],cf2[4],cf2[5]
            local posY = 46 + (idx-1)*46
            local card2 = Instance.new("Frame")
            card2.Size = UDim2.new(1,-16,0,40) card2.Position = UDim2.new(0,8,0,posY)
            card2.BackgroundColor3 = Color3.fromRGB(14,18,28) card2.BorderSizePixel = 0 card2.Parent = t5f
            local cc3 = Instance.new("UICorner") cc3.CornerRadius = UDim.new(0,6) cc3.Parent = card2
            local cs3 = Instance.new("UIStroke") cs3.Color = Color3.fromRGB(50,65,100) cs3.Thickness = 1 cs3.Parent = card2

            local vl = Instance.new("TextLabel")
            vl.Size = UDim2.new(0,320,1,0) vl.Position = UDim2.new(0,10,0,0)
            vl.BackgroundTransparency = 1 vl.Font = Enum.Font.GothamBold vl.TextSize = 11
            vl.TextColor3 = Color3.fromRGB(210,225,255) vl.TextXAlignment = Enum.TextXAlignment.Left vl.Parent = card2

            local function updVl()
                vl.Text = lbl2..": "..tostring(config[key2])
            end
            updVl()

            for _,bi in ipairs({{"◀",-step,UDim2.new(1,-185,0.5,-13)},{"<<",-step*5,UDim2.new(1,-137,0.5,-13)},{">",step*5,UDim2.new(1,-89,0.5,-13)},{"▶",step,UDim2.new(1,-41,0.5,-13)}}) do
                local b3 = Instance.new("TextButton")
                b3.Size = UDim2.new(0,40,0,26) b3.Position = bi[3] b3.BackgroundColor3 = Color3.fromRGB(28,38,58)
                b3.TextColor3 = Color3.fromRGB(255,255,255) b3.Font = Enum.Font.GothamBold b3.TextSize = 11
                b3.Text = bi[1] b3.BorderSizePixel = 0 b3.Parent = card2
                local b3c = Instance.new("UICorner") b3c.CornerRadius = UDim.new(0,4) b3c.Parent = b3
                local d = bi[2] local k3 = key2
                b3.MouseButton1Click:Connect(function()
                    local nv = math.clamp(config[k3] + d, mn, mx)
                    if step < 1 then nv = math.floor(nv/step+0.5)*step end
                    config[k3] = nv
                    updVl()
                    if k3 == "velocidadeVoo" and UI.velLbl then
                        UI.velLbl.Text = string.format("🦅 Velocidade de Voo: %d studs/s (Turbo: %d)", config.velocidadeVoo, math.floor(config.velocidadeVoo*config.multiplicadorSprintVoo))
                    end
                end)
            end
        end

        -- SEÇÃO: GERENCIADOR DE TECLAS & ATALHOS CUSTOMIZÁVEIS
        local kbHead = Instance.new("Frame")
        kbHead.Size = UDim2.new(1,-16,0,42) kbHead.Position = UDim2.new(0,8,0,326)
        kbHead.BackgroundColor3 = Color3.fromRGB(16,20,32) kbHead.BorderSizePixel = 0 kbHead.Parent = t5f
        local khc = Instance.new("UICorner") khc.CornerRadius = UDim.new(0,6) khc.Parent = kbHead
        local khs = Instance.new("UIStroke") khs.Color = Color3.fromRGB(168,85,247) khs.Thickness = 1 khs.Parent = kbHead

        local kbTit = Instance.new("TextLabel")
        kbTit.Size = UDim2.new(1,-140,0,20) kbTit.Position = UDim2.new(0,10,0,3)
        kbTit.BackgroundTransparency = 1 kbTit.Font = Enum.Font.GothamBold kbTit.TextSize = 11
        kbTit.TextColor3 = Color3.fromRGB(255,255,255) kbTit.TextXAlignment = Enum.TextXAlignment.Left
        kbTit.Text = "⌨️ GERENCIADOR DE TECLAS & ATALHOS" kbTit.Parent = kbHead

        local kbSub = Instance.new("TextLabel")
        kbSub.Size = UDim2.new(1,-140,0,14) kbSub.Position = UDim2.new(0,10,0,22)
        kbSub.BackgroundTransparency = 1 kbSub.Font = Enum.Font.Gotham kbSub.TextSize = 9
        kbSub.TextColor3 = Color3.fromRGB(150,165,185) kbSub.TextXAlignment = Enum.TextXAlignment.Left
        kbSub.Text = "Clique na tecla para alterar • Clique em [✕] para desativar" kbSub.Parent = kbHead

        local resetKbBtn = Instance.new("TextButton")
        resetKbBtn.Size = UDim2.new(0,120,0,26) resetKbBtn.Position = UDim2.new(1,-128,0.5,-13)
        resetKbBtn.BackgroundColor3 = Color3.fromRGB(37,99,235) resetKbBtn.TextColor3 = Color3.fromRGB(255,255,255)
        resetKbBtn.Font = Enum.Font.GothamBold resetKbBtn.TextSize = 10 resetKbBtn.Text = "🔄 RESETAR TECLAS"
        resetKbBtn.BorderSizePixel = 0 resetKbBtn.Parent = kbHead
        local rkbc = Instance.new("UICorner") rkbc.CornerRadius = UDim.new(0,4) rkbc.Parent = resetKbBtn

        UI.keybindButtons = {}

        local listaTeclas = {
            {"menu",        "📋 Menu Principal"},
            {"hud",         "📊 Mini-HUD 4.0"},
            {"panico",      "🚨 Pânico Total"},
            {"checkpoint",  "📍 Checkpoint TP"},
            {"dash",        "⚡ Flash Dash"},
            {"autowalk",    "🧭 Piloto Auto"},
            {"autoclicker", "🖱️ Auto-Clicker"},
            {"astral",      "👻 Modo Astral"},
            {"voo",         "🦅 Voo Livre"},
            {"paredes",     "🧗 Andar Paredes"},
            {"pulo",        "🦘 Pulo Infinito"},
            {"freeze",      "❄️ Freeze"},
            {"grapple",     "🪝 Grappling Hook"},
            {"magicfloor",  "🔮 Magic Floor"},
            {"elevador",    "🛗 Elevador Astral"},
            {"bhop",        "🦿 Bhop Glide"},
            {"freecam",     "🎥 Câmera Livre"},
            {"invisivel",   "👤 Invisibilidade"},
            {"choque",      "💥 Onda de Choque"},
            {"limpar",      "🧹 Limpar Vestígios"},
            {"fullbright",  "💡 Fullbright"},
            {"fov",         "🔭 Seletor de FOV"},
            {"drone",       "🛸 Modo Drone"},
            {"xray",        "🔍 Visão Raio-X"},
            {"noclip",      "🧱 Noclip Total"},
            {"delete",      "🗑️ Modo Apagar"},
            {"undo",        "↩️ Undo Delete"},
            {"inspector",   "📦 Inspector 3D"},
            {"outline",     "📦 Outline Tracker"},
            {"speedhack",   "⚡ Speed Hack"},
            {"gravidade",   "🌍 Gravidade Custom"},
            {"spawns",      "📍 Radar de Spawns"},
            {"radar",       "🔘 Radar Prompts"},
            {"antiafk",     "🛡️ Anti-AFK"},
            {"esp",         "👁️ ESP Jogadores"},
            {"cor",         "🎨 Cor da Aura"},
            {"playerlist",  "👥 Lista Jogadores"},
            {"auras",       "🔮 Auras Invisíveis"},
        }

        local startY = 374
        for idx, item in ipairs(listaTeclas) do
            local acaoKey, nomeExibicao = item[1], item[2]
            local col = (idx - 1) % 2
            local row = math.floor((idx - 1) / 2)
            local posY = startY + (row * 38)

            local card = Instance.new("Frame")
            card.Size = UDim2.new(0.5,-12,0,34)
            card.Position = (col == 0) and UDim2.new(0,8,0,posY) or UDim2.new(0.5,4,0,posY)
            card.BackgroundColor3 = Color3.fromRGB(14,18,28) card.BorderSizePixel = 0 card.Parent = t5f
            local cc = Instance.new("UICorner") cc.CornerRadius = UDim.new(0,5) cc.Parent = card
            local cs = Instance.new("UIStroke") cs.Color = Color3.fromRGB(38,48,68) cs.Thickness = 1 cs.Parent = card

            local albl = Instance.new("TextLabel")
            albl.Size = UDim2.new(1,-105,1,0) albl.Position = UDim2.new(0,8,0,0)
            albl.BackgroundTransparency = 1 albl.Font = Enum.Font.GothamBold albl.TextSize = 10
            albl.TextColor3 = Color3.fromRGB(220,230,250) albl.TextXAlignment = Enum.TextXAlignment.Left
            albl.Text = nomeExibicao albl.Parent = card

            local currentKey = teclasConfig[acaoKey]
            local keyBtn = Instance.new("TextButton")
            keyBtn.Size = UDim2.new(0,68,0,24) keyBtn.Position = UDim2.new(1,-98,0.5,-12)
            keyBtn.BackgroundColor3 = currentKey and Color3.fromRGB(168,85,247) or Color3.fromRGB(35,45,60)
            keyBtn.TextColor3 = currentKey and Color3.fromRGB(255,255,255) or Color3.fromRGB(130,145,170)
            keyBtn.Font = Enum.Font.GothamBold keyBtn.TextSize = 10
            keyBtn.Text = currentKey and ("[" .. currentKey.Name .. "]") or "[OFF]"
            keyBtn.BorderSizePixel = 0 keyBtn.Parent = card
            local kbc = Instance.new("UICorner") kbc.CornerRadius = UDim.new(0,4) kbc.Parent = keyBtn

            UI.keybindButtons[acaoKey] = keyBtn

            local clrBtn = Instance.new("TextButton")
            clrBtn.Size = UDim2.new(0,24,0,24) clrBtn.Position = UDim2.new(1,-27,0.5,-12)
            clrBtn.BackgroundColor3 = Color3.fromRGB(28,36,52) clrBtn.TextColor3 = Color3.fromRGB(239,68,68)
            clrBtn.Font = Enum.Font.GothamBold clrBtn.TextSize = 11 clrBtn.Text = "✕" clrBtn.BorderSizePixel = 0 clrBtn.Parent = card
            local clrc = Instance.new("UICorner") clrc.CornerRadius = UDim.new(0,4) clrc.Parent = clrBtn

            local act = acaoKey
            keyBtn.MouseButton1Click:Connect(function()
                if rebindAtivo == act then
                    rebindAtivo = nil
                    rebindBtnRef = nil
                    local curK = teclasConfig[act]
                    keyBtn.Text = curK and ("[" .. curK.Name .. "]") or "[OFF]"
                    keyBtn.BackgroundColor3 = curK and Color3.fromRGB(168,85,247) or Color3.fromRGB(35,45,60)
                    keyBtn.TextColor3 = curK and Color3.fromRGB(255,255,255) or Color3.fromRGB(130,145,170)
                else
                    if rebindBtnRef then
                        local oldAct = rebindAtivo
                        local oldK = teclasConfig[oldAct]
                        rebindBtnRef.Text = oldK and ("[" .. oldK.Name .. "]") or "[OFF]"
                        rebindBtnRef.BackgroundColor3 = oldK and Color3.fromRGB(168,85,247) or Color3.fromRGB(35,45,60)
                        rebindBtnRef.TextColor3 = oldK and Color3.fromRGB(255,255,255) or Color3.fromRGB(130,145,170)
                    end
                    rebindAtivo = act
                    rebindBtnRef = keyBtn
                    keyBtn.Text = "[...]"
                    keyBtn.BackgroundColor3 = Color3.fromRGB(234,179,8)
                    keyBtn.TextColor3 = Color3.fromRGB(0,0,0)
                    avisar("⌨️ Remapear Tecla", "Pressione uma tecla para '" .. nomeExibicao .. "' [Backspace para desativar]")
                end
            end)

            clrBtn.MouseButton1Click:Connect(function()
                teclasConfig[act] = nil
                keyBtn.Text = "[OFF]"
                keyBtn.BackgroundColor3 = Color3.fromRGB(35,45,60)
                keyBtn.TextColor3 = Color3.fromRGB(130,145,170)
                if rebindAtivo == act then
                    rebindAtivo = nil
                    rebindBtnRef = nil
                end
                avisar("⌨️ Tecla Desativada", nomeExibicao .. " agora está desativado!")
            end)
        end

        resetKbBtn.MouseButton1Click:Connect(function()
            rebindAtivo = nil
            rebindBtnRef = nil
            local curTema = temas[config.temaIndice]
            for k, v in pairs(teclasPadrao) do
                teclasConfig[k] = v
                local b = UI.keybindButtons[k]
                if b then
                    b.Text = "[" .. v.Name .. "]"
                    b.BackgroundColor3 = curTema.accent
                    b.TextColor3 = Color3.fromRGB(255,255,255)
                end
            end
            avisar("🔄 Atalhos Restaurados", "Todas as teclas voltaram para o padrão original!")
        end)

        local totalRows = math.ceil(#listaTeclas / 2)
        local refPosY = startY + (totalRows * 38) + 10

        local refCard = Instance.new("Frame")
        refCard.Size = UDim2.new(1,-16,0,140) refCard.Position = UDim2.new(0,8,0,refPosY)
        refCard.BackgroundColor3 = Color3.fromRGB(12,15,22) refCard.BorderSizePixel = 0 refCard.Parent = t5f
        local rcc = Instance.new("UICorner") rcc.CornerRadius = UDim.new(0,8) rcc.Parent = refCard
        local rcs = Instance.new("UIStroke") rcs.Color = Color3.fromRGB(168,85,247) rcs.Thickness = 1 rcs.Parent = refCard

        local refTit = Instance.new("TextLabel")
        refTit.Size = UDim2.new(1,-10,0,18) refTit.Position = UDim2.new(0,10,0,4)
        refTit.BackgroundTransparency = 1 refTit.TextColor3 = Color3.fromRGB(168,85,247)
        refTit.Font = Enum.Font.GothamBold refTit.TextSize = 11 refTit.TextXAlignment = Enum.TextXAlignment.Left
        refTit.Text = "📋 GUIA DE COMANDOS V9.0 DEFENDER & OVERLORD:" refTit.Parent = refCard

        local refTxt = Instance.new("TextLabel")
        refTxt.Size = UDim2.new(1,-20,1,-24) refTxt.Position = UDim2.new(0,10,0,22)
        refTxt.BackgroundTransparency = 1 refTxt.TextColor3 = Color3.fromRGB(170,185,215)
        refTxt.Font = Enum.Font.Code refTxt.TextSize = 9 refTxt.TextXAlignment = Enum.TextXAlignment.Left
        refTxt.TextYAlignment = Enum.TextYAlignment.Top refTxt.TextWrapped = true refTxt.Parent = refCard
        refTxt.Text = [[R=TP Checkpoint | Shift+R=Gravar Checkpoint | F12=PÂNICO TOTAL | Insert=Onda Choque
F10=Flash Dash | Home=Piloto Auto | F9=Auto-Clicker | Y=Gancho | End=Elevador | F7=Bhop
F11=FOV | Shift+Scroll=Luneta Zoom | F5=Drone | U=Magic Floor | H=Fullbright | F6=Anti-AFK
Alt+Dir Click=Canhão Força | Shift+Dir Click=Criar Piso | Ctrl+Dir Click=Telecinese]]

        t5f.CanvasSize = UDim2.new(0,0,0,refPosY + 155)
    end

    -- BLOCO 7: MODAIS (PlayerList com TP/View/Backstab/Orbit & SpawnList)
    do
        local plFrame = Instance.new("Frame")
        plFrame.Name = "PlayerListFrame"
        plFrame.Size = UDim2.new(0,460,0,440)
        plFrame.Position = UDim2.new(0.5,-230,0.5,-220)
        plFrame.BackgroundColor3 = Color3.fromRGB(10,13,20)
        plFrame.BorderSizePixel = 0 plFrame.Active = true plFrame.Draggable = true plFrame.Visible = false
        plFrame.Parent = screenGui
        UI.plFrame = plFrame
        local plc = Instance.new("UICorner") plc.CornerRadius = UDim.new(0,10) plc.Parent = plFrame
        local pls = Instance.new("UIStroke") pls.Color = Color3.fromRGB(99,102,241) pls.Thickness = 1.5 pls.Parent = plFrame

        local plTop = Instance.new("Frame")
        plTop.Size = UDim2.new(1,0,0,40) plTop.BackgroundColor3 = Color3.fromRGB(16,20,32)
        plTop.BorderSizePixel = 0 plTop.Parent = plFrame
        local pltc = Instance.new("UICorner") pltc.CornerRadius = UDim.new(0,10) pltc.Parent = plTop

        local plTit = Instance.new("TextLabel")
        plTit.Size = UDim2.new(1,-40,1,0) plTit.Position = UDim2.new(0,12,0,0)
        plTit.BackgroundTransparency = 1 plTit.TextColor3 = Color3.fromRGB(255,255,255)
        plTit.Font = Enum.Font.GothamBold plTit.TextSize = 12 plTit.TextXAlignment = Enum.TextXAlignment.Left
        plTit.Text = "👥 Jogadores no Servidor (TP, View, Backstab, Orbit)" plTit.Parent = plTop

        local plClose = Instance.new("TextButton")
        plClose.Size = UDim2.new(0,26,0,26) plClose.Position = UDim2.new(1,-32,0.5,-13)
        plClose.BackgroundColor3 = Color3.fromRGB(239,68,68) plClose.TextColor3 = Color3.fromRGB(255,255,255)
        plClose.Font = Enum.Font.GothamBold plClose.TextSize = 12 plClose.Text = "✕"
        plClose.BorderSizePixel = 0 plClose.Parent = plTop
        local plcc = Instance.new("UICorner") plcc.CornerRadius = UDim.new(0,5) plcc.Parent = plClose
        plClose.MouseButton1Click:Connect(function() plFrame.Visible = false end)

        local plScroll = Instance.new("ScrollingFrame")
        plScroll.Size = UDim2.new(1,-16,1,-50) plScroll.Position = UDim2.new(0,8,0,44)
        plScroll.BackgroundTransparency = 1 plScroll.BorderSizePixel = 0 plScroll.ScrollBarThickness = 4
        plScroll.Parent = plFrame
        local plLayout = Instance.new("UIListLayout")
        plLayout.Padding = UDim.new(0,6) plLayout.Parent = plScroll

        local function atualizarListaJogadores()
            for _, ch in ipairs(plScroll:GetChildren()) do
                if ch:IsA("Frame") then ch:Destroy() end
            end
            local playersList = Players:GetPlayers()
            plScroll.CanvasSize = UDim2.new(0, 0, 0, #playersList * 52)

            for _, p in ipairs(playersList) do
                local row = Instance.new("Frame")
                row.Size = UDim2.new(1, -8, 0, 46)
                row.BackgroundColor3 = (p == player) and Color3.fromRGB(25, 35, 55) or Color3.fromRGB(15, 20, 32)
                row.BorderSizePixel = 0
                row.Parent = plScroll
                local rc = Instance.new("UICorner") rc.CornerRadius = UDim.new(0, 6) rc.Parent = row

                local thumb = Instance.new("ImageLabel")
                thumb.Size = UDim2.new(0, 36, 0, 36) thumb.Position = UDim2.new(0, 6, 0.5, -18)
                thumb.BackgroundTransparency = 1 thumb.Parent = row
                local tc = Instance.new("UICorner") tc.CornerRadius = UDim.new(1, 0) tc.Parent = thumb
                task.spawn(function()
                    local content = Players:GetUserThumbnailAsync(p.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
                    thumb.Image = content
                end)

                local pName = Instance.new("TextLabel")
                pName.Size = UDim2.new(0, 150, 0, 18) pName.Position = UDim2.new(0, 48, 0, 6)
                pName.BackgroundTransparency = 1 pName.TextColor3 = Color3.fromRGB(255, 255, 255)
                pName.Font = Enum.Font.GothamBold pName.TextSize = 11 pName.TextXAlignment = Enum.TextXAlignment.Left
                pName.Text = p.DisplayName .. (p == player and " (Você)" or "") pName.Parent = row

                local pUser = Instance.new("TextLabel")
                pUser.Size = UDim2.new(0, 150, 0, 14) pUser.Position = UDim2.new(0, 48, 0, 24)
                pUser.BackgroundTransparency = 1 pUser.TextColor3 = Color3.fromRGB(150, 165, 185)
                pUser.Font = Enum.Font.Gotham pUser.TextSize = 9 pUser.TextXAlignment = Enum.TextXAlignment.Left
                pUser.Text = "@" .. p.Name pUser.Parent = row

                if p ~= player then
                    local tpB = Instance.new("TextButton")
                    tpB.Size = UDim2.new(0, 44, 0, 26) tpB.Position = UDim2.new(1, -196, 0.5, -13)
                    tpB.BackgroundColor3 = Color3.fromRGB(37, 99, 235) tpB.TextColor3 = Color3.fromRGB(255, 255, 255)
                    tpB.Font = Enum.Font.GothamBold tpB.TextSize = 10 tpB.Text = "⚡ TP" tpB.BorderSizePixel = 0 tpB.Parent = row
                    local tpc = Instance.new("UICorner") tpc.CornerRadius = UDim.new(0, 4) tpc.Parent = tpB
                    tpB.MouseButton1Click:Connect(function()
                        local tr = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
                        local mr = obterRootAtivo()
                        if tr and mr then
                            local char = (config.modoAstralAtivo and copiaPersonagem) or player.Character
                            if char then char:PivotTo(tr.CFrame * CFrame.new(0, 0, -3)) else mr.CFrame = tr.CFrame end
                            mr.AssemblyLinearVelocity = Vector3.zero mr.AssemblyAngularVelocity = Vector3.zero
                            avisar("⚡ Teleporte", "Teleportado até " .. p.DisplayName)
                        end
                    end)

                    local viewB = Instance.new("TextButton")
                    viewB.Size = UDim2.new(0, 44, 0, 26) viewB.Position = UDim2.new(1, -148, 0.5, -13)
                    viewB.BackgroundColor3 = Color3.fromRGB(124, 58, 237) viewB.TextColor3 = Color3.fromRGB(255, 255, 255)
                    viewB.Font = Enum.Font.GothamBold viewB.TextSize = 10 viewB.Text = "👁️ View" viewB.BorderSizePixel = 0 viewB.Parent = row
                    local vc = Instance.new("UICorner") vc.CornerRadius = UDim.new(0, 4) vc.Parent = viewB
                    viewB.MouseButton1Click:Connect(function()
                        local th = p.Character and p.Character:FindFirstChildOfClass("Humanoid")
                        if th then
                            state.spectatingPlayer = p
                            camera.CameraSubject = th
                            avisar("👁️ Spectate", "Observando " .. p.DisplayName .. " [F8 para sair]")
                        end
                    end)

                    local bsB = Instance.new("TextButton")
                    bsB.Size = UDim2.new(0, 46, 0, 26) bsB.Position = UDim2.new(1, -100, 0.5, -13)
                    bsB.BackgroundColor3 = Color3.fromRGB(220, 38, 38) bsB.TextColor3 = Color3.fromRGB(255, 255, 255)
                    bsB.Font = Enum.Font.GothamBold bsB.TextSize = 9 bsB.Text = "🗡️ Costas" bsB.BorderSizePixel = 0 bsB.Parent = row
                    local bsc = Instance.new("UICorner") bsc.CornerRadius = UDim.new(0, 4) bsc.Parent = bsB
                    bsB.MouseButton1Click:Connect(function() executarBackstab(p) end)

                    local orbB = Instance.new("TextButton")
                    orbB.Size = UDim2.new(0, 46, 0, 26) orbB.Position = UDim2.new(1, -50, 0.5, -13)
                    orbB.BackgroundColor3 = Color3.fromRGB(16, 185, 129) orbB.TextColor3 = Color3.fromRGB(255, 255, 255)
                    orbB.Font = Enum.Font.GothamBold orbB.TextSize = 9 orbB.Text = "🛸 Orbit" orbB.BorderSizePixel = 0 orbB.Parent = row
                    local orbc = Instance.new("UICorner") orbc.CornerRadius = UDim.new(0, 4) orbc.Parent = orbB
                    orbB.MouseButton1Click:Connect(function() alternarOrbit(p) end)
                end
            end
        end

        plFrame:GetPropertyChangedSignal("Visible"):Connect(function()
            if plFrame.Visible then atualizarListaJogadores() end
        end)

        local spFrame = Instance.new("Frame")
        spFrame.Name = "SpawnListFrame"
        spFrame.Size = UDim2.new(0,340,0,320)
        spFrame.Position = UDim2.new(0.5,-170,0.5,-160)
        spFrame.BackgroundColor3 = Color3.fromRGB(10,13,20)
        spFrame.BorderSizePixel = 0 spFrame.Active = true spFrame.Draggable = true spFrame.Visible = false
        spFrame.Parent = screenGui
        UI.spFrame = spFrame
        local spc = Instance.new("UICorner") spc.CornerRadius = UDim.new(0,10) spc.Parent = spFrame
        local sps = Instance.new("UIStroke") sps.Color = Color3.fromRGB(234,88,12) sps.Thickness = 1.5 sps.Parent = spFrame

        local spTop = Instance.new("Frame")
        spTop.Size = UDim2.new(1,0,0,36) spTop.BackgroundColor3 = Color3.fromRGB(16,20,32)
        spTop.BorderSizePixel = 0 spTop.Parent = spFrame
        local sptc = Instance.new("UICorner") sptc.CornerRadius = UDim.new(0,10) sptc.Parent = spTop

        local spTit = Instance.new("TextLabel")
        spTit.Size = UDim2.new(1,-40,1,0) spTit.Position = UDim2.new(0,12,0,0)
        spTit.BackgroundTransparency = 1 spTit.TextColor3 = Color3.fromRGB(255,255,255)
        spTit.Font = Enum.Font.GothamBold spTit.TextSize = 11 spTit.TextXAlignment = Enum.TextXAlignment.Left
        spTit.Text = "📍 SpawnLocations do Mapa" spTit.Parent = spTop

        local spClose = Instance.new("TextButton")
        spClose.Size = UDim2.new(0,24,0,24) spClose.Position = UDim2.new(1,-28,0.5,-12)
        spClose.BackgroundColor3 = Color3.fromRGB(239,68,68) spClose.TextColor3 = Color3.fromRGB(255,255,255)
        spClose.Font = Enum.Font.GothamBold spClose.TextSize = 11 spClose.Text = "✕"
        spClose.BorderSizePixel = 0 spClose.Parent = spTop
        local spcc = Instance.new("UICorner") spcc.CornerRadius = UDim.new(0,4) spcc.Parent = spClose
        spClose.MouseButton1Click:Connect(function() spFrame.Visible = false end)

        local spScroll = Instance.new("ScrollingFrame")
        spScroll.Size = UDim2.new(1,-16,1,-44) spScroll.Position = UDim2.new(0,8,0,40)
        spScroll.BackgroundTransparency = 1 spScroll.BorderSizePixel = 0 spScroll.ScrollBarThickness = 4
        spScroll.Parent = spFrame
        local spl = Instance.new("UIListLayout") spl.Padding = UDim.new(0,4) spl.Parent = spScroll

        spFrame:GetPropertyChangedSignal("Visible"):Connect(function()
            if not spFrame.Visible then return end
            for _, ch in ipairs(spScroll:GetChildren()) do if ch:IsA("TextButton") then ch:Destroy() end end
            local spawns = {}
            for _, obj in ipairs(Workspace:GetDescendants()) do
                if obj:IsA("SpawnLocation") then table.insert(spawns, obj) end
            end
            spScroll.CanvasSize = UDim2.new(0,0,0,#spawns*34)
            for idx, sp in ipairs(spawns) do
                local b = Instance.new("TextButton")
                b.Size = UDim2.new(1,-8,0,30) b.BackgroundColor3 = Color3.fromRGB(18,24,38)
                b.TextColor3 = Color3.fromRGB(255,255,255) b.Font = Enum.Font.GothamBold b.TextSize = 10
                b.Text = string.format("Spawn #%d: %s (%.0f, %.0f, %.0f)", idx, sp.Name, sp.Position.X, sp.Position.Y, sp.Position.Z)
                b.BorderSizePixel = 0 b.Parent = spScroll
                local bc = Instance.new("UICorner") bc.CornerRadius = UDim.new(0,4) bc.Parent = b
                b.MouseButton1Click:Connect(function()
                    local r = obterRootAtivo()
                    local char = (config.modoAstralAtivo and copiaPersonagem) or player.Character
                    if r and char then
                        char:PivotTo(sp.CFrame + Vector3.new(0, 3.5, 0))
                        r.AssemblyLinearVelocity = Vector3.zero r.AssemblyAngularVelocity = Vector3.zero
                        avisar("📍 Spawn TP", "Teleportado para o Spawn: " .. sp.Name)
                    end
                end)
            end
        end)
    end

    -- BLOCO 8: INSPECTOR 3D & MINI-HUD 4.0
    do
        local inspGui = Instance.new("BillboardGui")
        inspGui.Name = "V90Inspector" inspGui.Size = UDim2.new(0,230,0,110)
        inspGui.AlwaysOnTop = true inspGui.Enabled = false inspGui.Parent = screenGui
        UI.inspectorBillboard = inspGui

        local inspFrame = Instance.new("Frame")
        inspFrame.Size = UDim2.new(1,0,1,0) inspFrame.BackgroundColor3 = Color3.fromRGB(10,13,20)
        inspFrame.BackgroundTransparency = 0.15 inspFrame.BorderSizePixel = 0 inspFrame.Parent = inspGui
        local ipc = Instance.new("UICorner") ipc.CornerRadius = UDim.new(0,6) ipc.Parent = inspFrame
        local ips = Instance.new("UIStroke") ips.Color = Color3.fromRGB(0,255,200) ips.Thickness = 1 ips.Parent = inspFrame

        local inspLbl = Instance.new("TextLabel")
        inspLbl.Size = UDim2.new(1,-10,1,-8) inspLbl.Position = UDim2.new(0,5,0,4)
        inspLbl.BackgroundTransparency = 1 inspLbl.TextColor3 = Color3.fromRGB(220,240,255)
        inspLbl.Font = Enum.Font.Code inspLbl.TextSize = 9 inspLbl.TextXAlignment = Enum.TextXAlignment.Left
        inspLbl.TextYAlignment = Enum.TextYAlignment.Top inspLbl.TextWrapped = true inspLbl.Parent = inspFrame
        UI.inspectorLabel = inspLbl

        local hud = Instance.new("Frame")
        hud.Name = "MiniHUD"
        hud.Size = UDim2.new(0,260,0,165)
        hud.Position = UDim2.new(0,12,0.5,-82)
        hud.BackgroundColor3 = Color3.fromRGB(10,13,20)
        hud.BackgroundTransparency = 0.18 hud.BorderSizePixel = 0 hud.Active = true hud.Draggable = true
        hud.Parent = screenGui
        UI.hud = hud

        local hc = Instance.new("UICorner") hc.CornerRadius = UDim.new(0,8) hc.Parent = hud
        local hs = Instance.new("UIStroke") hs.Color = Color3.fromRGB(168,85,247) hs.Thickness = 1 hs.Parent = hud
        UI.hudStroke = hs

        local function mkHudLbl(y, sz, bold, cor)
            local l = Instance.new("TextLabel")
            l.Size = UDim2.new(1,-12,0,sz) l.Position = UDim2.new(0,6,0,y)
            l.BackgroundTransparency = 1 l.TextColor3 = cor or Color3.fromRGB(200,215,240)
            l.Font = bold and Enum.Font.GothamBold or Enum.Font.Gotham
            l.TextSize = sz-2 l.TextXAlignment = Enum.TextXAlignment.Left l.Parent = hud
            return l
        end

        UI.hudTit        = mkHudLbl(4,  13, true,  Color3.fromRGB(168,85,247))
        UI.hudTit.Text   = "👻 SUITE ASTRAL V9.0 DEFENDER"
        UI.hudCoords     = mkHudLbl(20, 11, false, Color3.fromRGB(220,230,255))
        UI.hudSpeed      = mkHudLbl(33, 11, false, Color3.fromRGB(160,200,255))
        UI.hudCheckpoint = mkHudLbl(46, 11, false, Color3.fromRGB(255,160,60))
        UI.hudFov        = mkHudLbl(59, 11, false, Color3.fromRGB(100,220,255))
        UI.hudModes      = mkHudLbl(72, 10, true,  Color3.fromRGB(80,255,140))
        UI.hudModes2     = mkHudLbl(84, 10, true,  Color3.fromRGB(80,255,140))
        UI.hudTarget     = mkHudLbl(97, 10, false, Color3.fromRGB(255,200,80))
        UI.hudSlots      = mkHudLbl(110,10, false, Color3.fromRGB(180,180,200))
        UI.hudHelp       = mkHudLbl(124,10, false, Color3.fromRGB(150,150,170))
        UI.hudHelp.Text  = "[F8] Menu  •  [F12] PÂNICO  •  [Tab] HUD"
    end
end

-- ════════════════════════════════════════════════════════════════════════════════
-- CONEXÕES DE ENTRADA DO USUÁRIO (TECLADO & MOUSE) COM REMAPEAMENTO
-- ════════════════════════════════════════════════════════════════════════════════
UserInputService.InputBegan:Connect(function(input, processed)
    -- ESCUTA DE CAPTURA PARA REMAPEAR TECLAS
    if input.UserInputType == Enum.UserInputType.Keyboard then
        if rebindAtivo then
            local k = input.KeyCode
            if k ~= Enum.KeyCode.Unknown then
                if k == Enum.KeyCode.Escape or k == Enum.KeyCode.Backspace then
                    teclasConfig[rebindAtivo] = nil
                    if rebindBtnRef then
                        rebindBtnRef.Text = "[OFF]"
                        rebindBtnRef.BackgroundColor3 = Color3.fromRGB(35,45,60)
                        rebindBtnRef.TextColor3 = Color3.fromRGB(130,145,170)
                    end
                    avisar("⌨️ Atalho Desativado", "Ação agora está sem tecla associada.")
                else
                    teclasConfig[rebindAtivo] = k
                    if rebindBtnRef then
                        rebindBtnRef.Text = "[" .. k.Name .. "]"
                        local curTema = temas[config.temaIndice]
                        rebindBtnRef.BackgroundColor3 = curTema.accent
                        rebindBtnRef.TextColor3 = Color3.fromRGB(255,255,255)
                    end
                    avisar("⌨️ Tecla Configurada", "Nova tecla vinculada: [" .. k.Name .. "]")
                end
                rebindAtivo = nil
                rebindBtnRef = nil
            end
            return
        end
    end

    if processed then return end
    local k = input.KeyCode

    -- Painéis e Pânico
    if teclasConfig.menu and k == teclasConfig.menu  then UI.main.Visible = not UI.main.Visible return end
    if teclasConfig.hud  and k == teclasConfig.hud   then UI.hud.Visible  = not UI.hud.Visible  return end
    if teclasConfig.panico and k == teclasConfig.panico then ativarPanico() return end

    -- Checkpoint Blindado
    if teclasConfig.checkpoint and k == teclasConfig.checkpoint then
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) or UserInputService:IsKeyDown(Enum.KeyCode.RightShift) or UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
            salvarCheckpoint()
        else
            carregarCheckpoint()
        end
        return
    end

    -- Mobilidade V9.0
    if teclasConfig.astral      and k == teclasConfig.astral      then alternarModoAstral()     return end
    if teclasConfig.voo         and k == teclasConfig.voo         then alternarVoo()             return end
    if teclasConfig.paredes     and k == teclasConfig.paredes     then alternarAndarParedes()    return end
    if teclasConfig.pulo        and k == teclasConfig.pulo        then alternarPuloInfinito()    return end
    if teclasConfig.freeze      and k == teclasConfig.freeze      then alternarFreeze()          return end
    if teclasConfig.grapple     and k == teclasConfig.grapple     then dispararGrapple()         return end
    if teclasConfig.magicfloor  and k == teclasConfig.magicfloor  then alternarMagicFloor()      return end
    if teclasConfig.elevador    and k == teclasConfig.elevador    then alternarElevador()        return end
    if teclasConfig.bhop        and k == teclasConfig.bhop        then alternarBhop()            return end
    if teclasConfig.dash        and k == teclasConfig.dash        then executarDash()            return end
    if teclasConfig.autowalk    and k == teclasConfig.autowalk    then alternarAutoWalk()        return end
    if teclasConfig.freecam     and k == teclasConfig.freecam     then alternarCameraLivre()     return end
    if teclasConfig.invisivel   and k == teclasConfig.invisivel   then alternarInvisibilidade()  return end
    if teclasConfig.choque      and k == teclasConfig.choque      then dispararOndaDeChoque()    return end
    if teclasConfig.limpar      and k == teclasConfig.limpar      then limparVestigios()         return end

    if k == Enum.KeyCode.PageUp  then
        config.velocidadeVoo = math.clamp(config.velocidadeVoo + 10, 5, 500)
        if UI.velLbl then
            UI.velLbl.Text = string.format("🦅 Velocidade de Voo: %d studs/s (Turbo: %d)", config.velocidadeVoo, math.floor(config.velocidadeVoo*config.multiplicadorSprintVoo))
        end
        avisar("🦅","Voo: "..config.velocidadeVoo.." studs/s")
        return
    end
    if k == Enum.KeyCode.PageDown then
        config.velocidadeVoo = math.clamp(config.velocidadeVoo - 10, 5, 500)
        if UI.velLbl then
            UI.velLbl.Text = string.format("🦅 Velocidade de Voo: %d studs/s (Turbo: %d)", config.velocidadeVoo, math.floor(config.velocidadeVoo*config.multiplicadorSprintVoo))
        end
        avisar("🦅","Voo: "..config.velocidadeVoo.." studs/s")
        return
    end

    -- Visão & Óptica
    if teclasConfig.fullbright  and k == teclasConfig.fullbright  then alternarFullbright()      return end
    if teclasConfig.fov         and k == teclasConfig.fov         then ciclarFov()               return end
    if teclasConfig.drone       and k == teclasConfig.drone       then alternarDroneMode()       return end
    if teclasConfig.xray        and k == teclasConfig.xray        then alternarXRay()            return end

    -- Utilitários
    if teclasConfig.autoclicker and k == teclasConfig.autoclicker then alternarAutoClicker()     return end
    if teclasConfig.noclip      and k == teclasConfig.noclip      then alternarNoclip()          return end
    if teclasConfig.delete      and k == teclasConfig.delete      then alternarDeleteMode()      return end
    if teclasConfig.undo        and k == teclasConfig.undo        then executarUndoDelete()      return end
    if teclasConfig.inspector   and k == teclasConfig.inspector   then alternarInspector()       return end
    if teclasConfig.outline     and k == teclasConfig.outline     then alternarOutlineTracker()  return end
    if teclasConfig.speedhack   and k == teclasConfig.speedhack   then alternarSpeedHack()       return end
    if teclasConfig.gravidade   and k == teclasConfig.gravidade   then alternarGravidade()       return end
    if teclasConfig.spawns      and k == teclasConfig.spawns      then UI.spFrame.Visible = not UI.spFrame.Visible return end
    if teclasConfig.radar       and k == teclasConfig.radar       then alternarRadarInteracoes() return end
    if teclasConfig.antiafk     and k == teclasConfig.antiafk     then alternarAntiAfk()         return end

    -- ESP & Players
    if teclasConfig.esp         and k == teclasConfig.esp         then alternarEsp()             return end
    if teclasConfig.cor         and k == teclasConfig.cor         then alternarCorAura()         return end
    if teclasConfig.playerlist  and k == teclasConfig.playerlist  then UI.plFrame.Visible = not UI.plFrame.Visible return end
    if teclasConfig.auras       and k == teclasConfig.auras       then alternarDetectorAuras()   return end

    -- Slots de Posição
    if UserInputService:IsKeyDown(Enum.KeyCode.RightControl) then
        local s = slotMapa[k]
        if s ~= nil then salvarSlot(s) return end
    end
    if UserInputService:IsKeyDown(Enum.KeyCode.RightAlt) or UserInputService:IsKeyDown(Enum.KeyCode.Alt) then
        local s = slotMapa[k]
        if s ~= nil then carregarSlot(s) return end
    end
end)

-- Scroll do Mouse: Luneta Zoom (Shift + Scroll) & Grapple (Scroll Click)
UserInputService.InputChanged:Connect(function(input, processed)
    if input.UserInputType == Enum.UserInputType.MouseWheel then
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
            local delta = input.Position.Z
            camera.FieldOfView = math.clamp(camera.FieldOfView - (delta * 5), 15, 120)
            if UI.hudFov then
                UI.hudFov.Text = string.format("🔭 FOV: %.0f° (Luneta Dinâmica)", camera.FieldOfView)
            end
        end
    end
end)

UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.UserInputType == Enum.UserInputType.MouseButton3 then
        dispararGrapple()
    end
end)

-- Cliques do Mouse
mouse.Button1Down:Connect(function()
    if config.cameraLivreAtiva then return end

    if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
        executarClickTeleport()
        return
    end

    if config.detectorAurasAtivo then
        local t = mouse.Target
        if t and t:IsA("BasePart") and not t:IsDescendantOf(player.Character or Instance.new("Model")) then
            if aurasBoxes[t] then
                pcall(function() aurasBoxes[t]:Destroy() end) aurasBoxes[t] = nil aurasOriginais[t] = nil
                local nm = t.Name t:Destroy()
                avisar("🗑️ Aura","'"..nm.."' apagada!")
                return
            end
        end
    end

    if UserInputService:IsKeyDown(Enum.KeyCode.LeftAlt) or config.deleteModeAtivo then
        apagarObjetoNoMouse()
        return
    end
end)

mouse.Button2Down:Connect(function()
    -- Alt + Clique Direito: Canhão de Força
    if UserInputService:IsKeyDown(Enum.KeyCode.LeftAlt) then
        local t = mouse.Target
        local root = obterRootAtivo()
        if t and t:IsA("BasePart") and root and not t.Anchored and not t:IsDescendantOf(player.Character) then
            local shootDir = (t.Position - root.Position).Unit + Vector3.new(0, 0.25, 0)
            pcall(function()
                t.AssemblyLinearVelocity = shootDir * 140
            end)
            avisar("🚀 Canhão de Força", "Objeto arremessado para longe!")
        end
        return
    end

    -- Shift + Clique Direito: Criar Plataforma Mágica Temporária no ponto clicado
    if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
        local h = mouse.Hit
        if h then
            local plat = Instance.new("Part")
            plat.Name = "SuiteV90TempPlat"
            plat.Size = Vector3.new(10, 1, 10)
            plat.CFrame = CFrame.new(h.Position)
            plat.Anchored = true
            plat.CanCollide = true
            plat.Color = Color3.fromRGB(0, 255, 200)
            plat.Material = Enum.Material.ForceField
            plat.Parent = Workspace
            table.insert(tempPlataformas, plat)
            avisar("🔮 Plataforma Mágica", "Plataforma criada no ponto clicado!")
            task.delay(15, function()
                if plat and plat.Parent then plat:Destroy() end
            end)
        end
        return
    end

    -- Ctrl + Clique Direito: Telecinese Local
    if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
        local t = mouse.Target
        local root = obterRootAtivo()
        if t and t:IsA("BasePart") and root and not t.Anchored and not t:IsDescendantOf(player.Character) then
            pcall(function()
                t.AssemblyLinearVelocity = (root.Position - t.Position).Unit * 65
            end)
            avisar("🧲 Telecinese", "Puxando '" .. t.Name .. "' em sua direção!")
        end
        return
    end
end)

-- ════════════════════════════════════════════════════════════════════════════════
-- LOOP PRINCIPAL — HEARTBEAT V9.0 DEFENDER & OVERLORD
-- ════════════════════════════════════════════════════════════════════════════════
RunService.Heartbeat:Connect(function(dt)
    local char = player.Character
    if not char then return end
    local realRoot = char:FindFirstChild("HumanoidRootPart")
    local realHum  = char:FindFirstChildOfClass("Humanoid")
    if not realRoot or not realHum then return end

    local keys = {
        W          = UserInputService:IsKeyDown(Enum.KeyCode.W),
        S          = UserInputService:IsKeyDown(Enum.KeyCode.S),
        A          = UserInputService:IsKeyDown(Enum.KeyCode.A),
        D          = UserInputService:IsKeyDown(Enum.KeyCode.D),
        Space      = UserInputService:IsKeyDown(Enum.KeyCode.Space),
        LeftShift  = UserInputService:IsKeyDown(Enum.KeyCode.LeftShift),
        LeftControl= UserInputService:IsKeyDown(Enum.KeyCode.LeftControl),
    }

    -- FPS Counter
    frameCount = frameCount + 1
    fpsTimer = fpsTimer + dt
    if fpsTimer >= 1 then
        lastFps = frameCount
        frameCount = 0
        fpsTimer = 0
    end

    -- GRAVAÇÃO DE POSIÇÃO SEGURA EM TERRA FIRME (ANTI-VOID)
    if realHum.FloorMaterial ~= Enum.Material.Air and realHum.Health > 0 and realRoot.Position.Y > -50 then
        lastSafeCFrame = realRoot.CFrame
    end

    -- DEFESA 1: ANTI-FLING (NO PLAYER COLLIDE + CLAMP DE VELOCIDADE)
    if config.antiFling then
        aplicarNoPlayerCollide()
        if not config.vooAtivo and realRoot.AssemblyLinearVelocity.Magnitude > 250 then
            realRoot.AssemblyLinearVelocity = Vector3.zero
            realRoot.AssemblyAngularVelocity = Vector3.zero
        end
    end

    -- DEFESA 2: ANTI-VOID RESCUE
    processarAntiVoid(realRoot)

    -- DEFESA 3: ANTI-RAGDOLL & ANTI-SIT
    processarAntiRagdoll(realHum)

    -- DEFESA 4: ANTI-ANCHOR
    processarAntiAnchor(char)

    -- DEFESA 5: AUTO-EMERGENCY HP RESCUE
    processarEmergencyHp(realRoot, realHum)

    -- DEFESA 6: ANTI-FALL DAMAGE
    processarAntiFallDamage(realRoot, realHum)

    -- DEFESA 7: ANTI-BLIND & SCREEN PURGE
    limparEfeitosTela()

    -- DEFESA 8: ANTI-KILLBRICK SCANNER (a cada 0.35s)
    killbrickTimer = killbrickTimer + dt
    if killbrickTimer >= 0.35 then
        killbrickTimer = 0
        escanearKillbricks()
    end

    -- AUTO-CLICKER TURBO
    if config.autoClickerAtivo then
        autoClickerTimer = autoClickerTimer + dt
        if autoClickerTimer >= (config.autoClickerInterval or 0.05) then
            autoClickerTimer = 0
            pcall(function()
                if mouse1click then
                    mouse1click()
                else
                    local t = mouse.Target
                    if t then
                        local cd = t:FindFirstChildOfClass("ClickDetector") or (t.Parent and t.Parent:FindFirstChildOfClass("ClickDetector"))
                        if cd and fireclickdetector then fireclickdetector(cd) end
                    end
                end
            end)
        end
    end

    -- AUTO-INTERACT AURA (PROXIMITY PROMPTS)
    if config.autoInteractAtivo then
        autoInteractTimer = autoInteractTimer + dt
        if autoInteractTimer >= 0.25 then
            autoInteractTimer = 0
            local root = obterRootAtivo()
            if root then
                for _, p in ipairs(Workspace:GetDescendants()) do
                    if p:IsA("ProximityPrompt") and p.Enabled then
                        local pPart = p.Parent
                        if pPart and pPart:IsA("BasePart") and (pPart.Position - root.Position).Magnitude <= (p.MaxActivationDistance or 18) then
                            pcall(function()
                                if fireproximityprompt then
                                    fireproximityprompt(p)
                                else
                                    p:InputHoldBegin() task.wait(0.05) p:InputHoldEnd()
                                end
                            end)
                        end
                    end
                end
            end
        end
    end

    -- COLETOR MAGNÉTICO (MAGNET)
    if config.magnetAtivo then
        magnetTimer = magnetTimer + dt
        if magnetTimer >= 0.3 then
            magnetTimer = 0
            local root = obterRootAtivo()
            if root then
                for _, obj in ipairs(Workspace:GetChildren()) do
                    if obj:IsA("BasePart") and not obj.Anchored and not obj:IsDescendantOf(char) then
                        local diff = root.Position - obj.Position
                        if diff.Magnitude < 45 then
                            pcall(function() obj.AssemblyLinearVelocity = diff.Unit * 40 end)
                        end
                    end
                end
            end
        end
    end

    -- PILOTO AUTOMÁTICO (AUTO-WALK)
    if config.autoWalkAtivo and not config.vooAtivo and not config.andarParedesAtivo then
        local look = camera.CFrame.LookVector
        realHum:Move(Vector3.new(look.X, 0, look.Z).Unit, false)
    end

    -- SPIDER CLIMB
    if config.spiderClimbAtivo and not config.vooAtivo and keys.W then
        local forwardRay = Workspace:Raycast(realRoot.Position, realRoot.CFrame.LookVector * 2.5, rayParams)
        if forwardRay and forwardRay.Instance and math.abs(forwardRay.Normal.Y) < 0.4 then
            realRoot.AssemblyLinearVelocity = Vector3.new(realRoot.AssemblyLinearVelocity.X, 26, realRoot.AssemblyLinearVelocity.Z)
        end
    end

    -- AUTO-ORBIT AO REDOR DO JOGADOR ALVO
    if config.orbitAtivo and config.alvoOrbit and config.alvoOrbit.Character then
        local tRoot = config.alvoOrbit.Character:FindFirstChild("HumanoidRootPart")
        local myRoot = obterRootAtivo()
        if tRoot and myRoot then
            config.orbitAngulo = (config.orbitAngulo or 0) + (dt * (config.orbitVel or 2))
            local offsetX = math.cos(config.orbitAngulo) * (config.orbitRaio or 14)
            local offsetZ = math.sin(config.orbitAngulo) * (config.orbitRaio or 14)
            local targetPos = tRoot.Position + Vector3.new(offsetX, 5, offsetZ)
            myRoot.CFrame = CFrame.new(targetPos, tRoot.Position)
            myRoot.AssemblyLinearVelocity = Vector3.zero
        end
    end

    -- TRACERS 3D
    if config.tracersAtivo then
        local myRoot = obterRootAtivo()
        if myRoot then
            local sel = coresAura[config.corAuraIndice]
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= player and p.Character then
                    local targetRoot = p.Character:FindFirstChild("HumanoidRootPart")
                    if targetRoot then
                        local tracer = tracersCache[p]
                        if not tracer or not tracer.Parent then
                            tracer = Instance.new("LineHandleAdornment")
                            tracer.Name = "V90Tracer"
                            tracer.Length = 0 tracer.Thickness = 2 tracer.ZIndex = 5
                            tracer.AlwaysOnTop = true tracer.Parent = Workspace.CurrentCamera
                            tracersCache[p] = tracer
                        end
                        local fromPos = myRoot.Position
                        local toPos = targetRoot.Position
                        local dir = (toPos - fromPos)
                        tracer.Adornee = Workspace.Terrain
                        tracer.CFrame = CFrame.new(fromPos, toPos)
                        tracer.Length = dir.Magnitude
                        tracer.Color3 = sel.cor
                    else
                        if tracersCache[p] then tracersCache[p]:Destroy() tracersCache[p] = nil end
                    end
                end
            end
        end
    end

    -- MODO ASTRAL: CONTROLE DA CÓPIA NO CHÃO
    if config.modoAstralAtivo and copiaPersonagem and copiaPersonagem.Parent then
        local cHum  = copiaPersonagem:FindFirstChildOfClass("Humanoid")
        local cRoot = copiaPersonagem:FindFirstChild("HumanoidRootPart")

        if cHum and cRoot then
            local camCF = camera.CFrame
            local forward = Vector3.new(camCF.LookVector.X, 0, camCF.LookVector.Z)
            local right   = Vector3.new(camCF.RightVector.X, 0, camCF.RightVector.Z)
            if forward.Magnitude > 0.001 then forward = forward.Unit end
            if right.Magnitude > 0.001 then right = right.Unit end

            local moveDir = Vector3.zero
            if keys.W then moveDir = moveDir + forward end
            if keys.S then moveDir = moveDir - forward end
            if keys.D then moveDir = moveDir + right end
            if keys.A then moveDir = moveDir - right end

            local isMoving = moveDir.Magnitude > 0.1
            if isMoving then moveDir = moveDir.Unit end

            local spd = keys.LeftShift and config.velocidadeSprint or config.velocidadePadrao
            if config.speedHackAtivo then spd = spd * config.speedHackMultiplier end
            cHum.WalkSpeed = spd

            cHum:Move(moveDir, false)

            if isMoving then
                local targetLook = cRoot.Position + moveDir
                cRoot.CFrame = CFrame.new(cRoot.Position, targetLook)
            end

            if keys.Space and cHum.FloorMaterial ~= Enum.Material.Air then
                cHum:ChangeState(Enum.HumanoidStateType.Jumping)
            end

            -- ANIMAÇÕES ACTION PRIORITY
            local isAir = (cHum.FloorMaterial == Enum.Material.Air)
            local yVel = cRoot.AssemblyLinearVelocity.Y

            if isAir then
                if yVel > 1 then
                    if animTracks.jump and not animTracks.jump.IsPlaying then animTracks.jump:Play(0.1) end
                    if animTracks.fall and animTracks.fall.IsPlaying then animTracks.fall:Stop(0.1) end
                    if animTracks.run and animTracks.run.IsPlaying then animTracks.run:Stop(0.1) end
                    if animTracks.idle and animTracks.idle.IsPlaying then animTracks.idle:Stop(0.1) end
                else
                    if animTracks.fall and not animTracks.fall.IsPlaying then animTracks.fall:Play(0.1) end
                    if animTracks.jump and animTracks.jump.IsPlaying then animTracks.jump:Stop(0.1) end
                    if animTracks.run and animTracks.run.IsPlaying then animTracks.run:Stop(0.1) end
                    if animTracks.idle and animTracks.idle.IsPlaying then animTracks.idle:Stop(0.1) end
                end
            elseif isMoving then
                if animTracks.jump and animTracks.jump.IsPlaying then animTracks.jump:Stop(0.1) end
                if animTracks.fall and animTracks.fall.IsPlaying then animTracks.fall:Stop(0.1) end
                if animTracks.idle and animTracks.idle.IsPlaying then animTracks.idle:Stop(0.1) end
                if animTracks.run and not animTracks.run.IsPlaying then animTracks.run:Play(0.1) end
                if animTracks.run then animTracks.run:AdjustSpeed(keys.LeftShift and 1.5 or 1.0) end
            else
                if animTracks.jump and animTracks.jump.IsPlaying then animTracks.jump:Stop(0.1) end
                if animTracks.fall and animTracks.fall.IsPlaying then animTracks.fall:Stop(0.1) end
                if animTracks.run and animTracks.run.IsPlaying then animTracks.run:Stop(0.1) end
                if animTracks.idle and not animTracks.idle.IsPlaying then animTracks.idle:Play(0.1) end
            end
        end

        -- FIXAÇÃO DO CORPO REAL NA PLATAFORMA DO CÉU
        realHum.PlatformStand = true
        realRoot.AssemblyLinearVelocity = Vector3.zero
        realRoot.AssemblyAngularVelocity = Vector3.zero
        local skyCenter = plataformaCeu.Position
        realRoot.CFrame = CFrame.new(skyCenter.X, skyCenter.Y + 3.5, skyCenter.Z)
    end

    -- PULO INFINITO
    if config.puloInfinitoAtivo and keys.Space and not config.vooAtivo and not config.andarParedesAtivo then
        local h = (config.modoAstralAtivo and copiaPersonagem and copiaPersonagem:FindFirstChildOfClass("Humanoid")) or realHum
        if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
    end

    -- MODO VOO LIVRE
    if config.vooAtivo and not config.modoAstralAtivo then
        local r = realRoot
        local camCF = camera.CFrame
        local flyDir = Vector3.zero
        if keys.W then flyDir = flyDir + camCF.LookVector end
        if keys.S then flyDir = flyDir - camCF.LookVector end
        if keys.D then flyDir = flyDir + camCF.RightVector end
        if keys.A then flyDir = flyDir - camCF.RightVector end
        if keys.Space then flyDir = flyDir + Vector3.new(0, 1, 0) end
        if keys.LeftControl then flyDir = flyDir - Vector3.new(0, 1, 0) end

        local vel = config.velocidadeVoo
        if keys.LeftShift then vel = vel * config.multiplicadorSprintVoo end
        if config.speedHackAtivo then vel = vel * config.speedHackMultiplier end

        if flyDir.Magnitude > 0.001 then
            r.AssemblyLinearVelocity = flyDir.Unit * vel
        else
            r.AssemblyLinearVelocity = Vector3.zero
        end
        r.AssemblyAngularVelocity = Vector3.zero
    end

    -- ANDAR EM PAREDES E TETOS (SUPERFÍCIE 360°)
    if config.andarParedesAtivo and not config.modoAstralAtivo then
        local r = realRoot
        local charModel = player.Character

        local directions = {
            Vector3.new(0, -3.8, 0),
            Vector3.new(0, 3.8, 0),
            r.CFrame.LookVector * 3.5,
            -r.CFrame.LookVector * 3.5,
            r.CFrame.RightVector * 3.5,
            -r.CFrame.RightVector * 3.5
        }

        local closestHit = nil
        local closestDist = 999

        for _, dir in ipairs(directions) do
            local ray = Workspace:Raycast(r.Position, dir, rayParams)
            if ray and ray.Instance and ray.Instance.CanCollide then
                local d = (ray.Position - r.Position).Magnitude
                if d < closestDist then
                    closestDist = d
                    closestHit = ray
                end
            end
        end

        if closestHit then
            local surfaceNormal = closestHit.Normal
            local hitPos = closestHit.Position
            local desiredPos = hitPos + (surfaceNormal * 3.0)

            local camCF = camera.CFrame
            local forwardProj = camCF.LookVector - surfaceNormal * camCF.LookVector:Dot(surfaceNormal)
            local rightProj   = camCF.RightVector - surfaceNormal * camCF.RightVector:Dot(surfaceNormal)
            if forwardProj.Magnitude > 0.001 then forwardProj = forwardProj.Unit end
            if rightProj.Magnitude > 0.001 then rightProj = rightProj.Unit end

            local moveDir = Vector3.zero
            if keys.W then moveDir = moveDir + forwardProj end
            if keys.S then moveDir = moveDir - forwardProj end
            if keys.D then moveDir = moveDir + rightProj end
            if keys.A then moveDir = moveDir - rightProj end

            local isMoving = moveDir.Magnitude > 0.001
            local speed = keys.LeftShift and config.velocidadeSprint or config.velocidadePadrao
            if config.speedHackAtivo then speed = speed * config.speedHackMultiplier end

            local newPos = desiredPos
            if isMoving then
                newPos = r.Position + (moveDir.Unit * speed * dt)
                local wallRay = Workspace:Raycast(newPos, -surfaceNormal * 4.5, rayParams)
                if wallRay and wallRay.Instance then
                    newPos = wallRay.Position + (surfaceNormal * 3.0)
                    surfaceNormal = wallRay.Normal
                end
            end

            local lookTarget = isMoving and (newPos + moveDir.Unit) or (newPos + forwardProj)
            local newCF = CFrame.lookAt(newPos, lookTarget, surfaceNormal)

            r.CFrame = newCF
            r.AssemblyLinearVelocity = Vector3.zero
            r.AssemblyAngularVelocity = Vector3.zero
            realHum.PlatformStand = true
        else
            realHum.PlatformStand = false
        end
    end

    -- ELEVADOR ASTRAL
    if config.elevadorAtivo and not config.vooAtivo and not config.modoAstralAtivo then
        local vy = 0
        if keys.Space then vy = config.elevadorVelocidade end
        if keys.LeftControl then vy = -config.elevadorVelocidade end
        realRoot.AssemblyLinearVelocity = Vector3.new(realRoot.AssemblyLinearVelocity.X, vy, realRoot.AssemblyLinearVelocity.Z)
    end

    -- BHOP GLIDE
    if config.bhopAtivo and not config.vooAtivo and not config.modoAstralAtivo then
        local isGrounded = (realHum.FloorMaterial ~= Enum.Material.Air)
        if isGrounded and not state.bhopGrounded then
            local flatVel = Vector3.new(realRoot.AssemblyLinearVelocity.X, 0, realRoot.AssemblyLinearVelocity.Z)
            if flatVel.Magnitude > 5 then
                realHum:ChangeState(Enum.HumanoidStateType.Jumping)
                realRoot.AssemblyLinearVelocity = flatVel * 1.08 + Vector3.new(0, realHum.JumpPower or 50, 0)
            end
        end
        state.bhopGrounded = isGrounded
    end

    -- FREEZE
    if config.freezeAtivo and not config.modoAstralAtivo then
        realRoot.Anchored = true
        realRoot.AssemblyLinearVelocity = Vector3.zero
        realRoot.AssemblyAngularVelocity = Vector3.zero
    end

    -- NOCLIP
    if config.noclipAtivo then
        local m = (config.modoAstralAtivo and copiaPersonagem) or char
        if m then
            for _, p in ipairs(m:GetDescendants()) do
                if p:IsA("BasePart") and p.CanCollide then
                    p.CanCollide = false
                end
            end
        end
    end

    -- CÂMERA LIVRE (FREECAM)
    if config.cameraLivreAtiva then
        local camCF = state.freeCamCFrame
        local move = Vector3.zero
        if keys.W then move = move + camCF.LookVector end
        if keys.S then move = move - camCF.LookVector end
        if keys.D then move = move + camCF.RightVector end
        if keys.A then move = move - camCF.RightVector end
        if keys.Space then move = move + Vector3.new(0, 1, 0) end
        if keys.LeftControl then move = move - Vector3.new(0, 1, 0) end

        local spd = config.freeCamSpeed
        if keys.LeftShift then spd = spd * 2.5 end
        state.freeCamCFrame = state.freeCamCFrame + (move * (spd * dt))
        camera.CFrame = state.freeCamCFrame
    end

    -- ESP THROTTLED (~20 FPS)
    espThrottleTimer = espThrottleTimer + dt
    if config.espAtivo and espThrottleTimer >= ESP_INTERVAL then
        espThrottleTimer = 0
        for _, p in ipairs(Players:GetPlayers()) do atualizarEspJogador(p) end
    end

    -- OBJECT INSPECTOR
    if config.inspectorAtivo and UI.inspectorBillboard and UI.inspectorLabel then
        local t = mouse.Target
        if t and t ~= inspectorTarget then
            inspectorTarget = t
            UI.inspectorBillboard.Adornee = t
            UI.inspectorBillboard.Enabled = true
        elseif not t then
            UI.inspectorBillboard.Enabled = false inspectorTarget = nil
        end
        if t and UI.inspectorLabel then
            pcall(function()
                UI.inspectorLabel.Text = string.format(
                    "📦 %s [%s]\nPos: %.0f, %.0f, %.0f\nSz: %.1f × %.1f × %.1f\nMat: %s | CC:%s Anch:%s\nParent: %s",
                    t.Name, t.ClassName,
                    t.Position.X, t.Position.Y, t.Position.Z,
                    t.Size.X, t.Size.Y, t.Size.Z,
                    tostring(t.Material):gsub("Enum.Material.",""),
                    tostring(t.CanCollide), tostring(t.Anchored),
                    t.Parent and t.Parent.Name or "—"
                )
            end)
        end
    end

    -- OUTLINE TRACKER
    if config.outlineTrackerAtivo then
        local t = mouse.Target
        if t and t ~= outlineTarget then
            outlineTarget = t
            if outlineBox then outlineBox:Destroy() end
            outlineBox = Instance.new("SelectionBox")
            outlineBox.Adornee = t
            local d = realRoot and (realRoot.Position - t.Position).Magnitude or 999
            outlineBox.Color3 = d<20 and Color3.fromRGB(255,50,50) or d<60 and Color3.fromRGB(255,200,0) or Color3.fromRGB(50,200,255)
            outlineBox.LineThickness = 0.06 outlineBox.Parent = Workspace
        elseif not t and outlineBox then
            outlineBox:Destroy() outlineBox = nil outlineTarget = nil
        end
    end

    -- MINI-HUD 4.0
    if config.miniHudAtivo and UI.hudCoords then
        local pos = realRoot.Position
        local vel = realRoot.AssemblyLinearVelocity.Magnitude
        UI.hudCoords.Text = string.format("🌐 X:%.0f  Y:%.0f  Z:%.0f", pos.X, pos.Y, pos.Z)
        UI.hudSpeed.Text  = string.format("⚡ Vel: %.0f studs/s  •  FPS: %d", vel, lastFps)

        if config.checkpointPos then
            local cpPos = config.checkpointPos.Position
            local cpDist = (pos - cpPos).Magnitude
            UI.hudCheckpoint.Text = string.format("📍 CP: X:%.0f Y:%.0f Z:%.0f (%.0f studs)", cpPos.X, cpPos.Y, cpPos.Z, cpDist)
            UI.hudCheckpoint.TextColor3 = Color3.fromRGB(80, 255, 140)
        else
            UI.hudCheckpoint.Text = "📍 CP: Nenhum salvo [Shift+R]"
            UI.hudCheckpoint.TextColor3 = Color3.fromRGB(255, 160, 60)
        end

        UI.hudFov.Text = string.format("🔭 FOV: %.0f° [F11 / Shift+Scroll]", camera.FieldOfView)

        local modos = {}
        if config.modoAstralAtivo   then table.insert(modos,"👻AST") end
        if config.vooAtivo          then table.insert(modos,"🦅VOO") end
        if config.andarParedesAtivo then table.insert(modos,"🧗PAR") end
        if config.noclipAtivo       then table.insert(modos,"🧱NCP") end
        if config.freezeAtivo       then table.insert(modos,"❄️FRZ") end
        if config.grappleAtivo      then table.insert(modos,"🪝GRP") end
        if config.magicFloorAtivo   then table.insert(modos,"🔮FLR") end
        if config.elevadorAtivo     then table.insert(modos,"🛗ELV") end
        if config.bhopAtivo         then table.insert(modos,"🦿BHP") end
        if config.droneModeAtivo    then table.insert(modos,"🛸DRN") end
        if config.fullbrightAtivo   then table.insert(modos,"💡LGT") end
        if config.antiAfkAtivo      then table.insert(modos,"🛡️AFK") end
        if config.invisibilidadeAtiva then table.insert(modos,"👤INV") end
        if config.cameraLivreAtiva  then table.insert(modos,"🎥CAM") end
        if config.espAtivo          then table.insert(modos,"👁ESP") end
        if config.speedHackAtivo    then table.insert(modos,"⚡SPD") end
        if config.gravitacaoAtiva   then table.insert(modos,"🌍GRV") end
        if config.xrayAtivo         then table.insert(modos,"🔍XRY") end
        if config.puloInfinitoAtivo then table.insert(modos,"🦘PUL") end
        if config.autoClickerAtivo  then table.insert(modos,"🖱️CLK") end
        if config.autoWalkAtivo     then table.insert(modos,"🧭WLK") end
        if config.tracersAtivo      then table.insert(modos,"📏TRC") end

        UI.hudModes.Text  = #modos>0 and table.concat(modos," ",1,math.min(7,#modos)) or "✅ Modos OFF"
        UI.hudModes2.Text = #modos>7 and table.concat(modos," ",8) or ""

        local t = mouse.Target
        UI.hudTarget.Text = t and ("🎯 "..t.Name.." ("..t.ClassName..")") or "🎯 —"

        local ss = "💾 "
        for i=0,9 do ss = ss..(slotsPosicoes[i] and "■" or "□") end
        UI.hudSlots.Text = ss
    end
end)

-- ════════════════════════════════════════════════════════════════════════════════
avisar("👻 Suite Astral V9.0 Atualizada!", "[F8]=Menu  [Tab]=HUD  [Config]=Remapear Teclas  Defesas=OFF", 4)
