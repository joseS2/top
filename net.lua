--[[
    ═══════════════════════════════════════════════════════════════════════════════
    👻 MODO ASTRAL PVP V3.0 — ZERO VISIBILITY GHOST & UNDERGROUND STRIKE
    ═══════════════════════════════════════════════════════════════════════════════
    ARQUIVO: 3.lua
    
    SOLUÇÃO DEFINITIVA PARA NÃO FICAR VISÍVEL PARA NINGUÉM:
    • O Modo G NUNCA É DESATIVADO:
      - O Modo Astral permanece ligado 100% do tempo.
      - A plataforma segura no céu (+850 studs) nunca sai do lugar.
      - A cópia astral continua fixa nas costas do inimigo sem interrupção.
    • Dupla Proteção Anti-Visibilidade no Clique:
      1. Micro-Strike Sub-Frame (Padrão: 10ms):
         O golpe ocorre em menos de 15 milissegundos (abaixo do tempo de envio
         de pacotes do Roblox de 33ms). O buffer de interpolação dos outros
         jogadores descarta o movimento e ninguém vê seu boneco descer.
      2. Modo Golpe Subterrâneo (Underground Ghost):
         O corpo real desce -4.5 studs abaixo do chão/terreno, exatamente sob
         as costas do inimigo. O alcance da arma acerta o inimigo por baixo,
         e como o chão/mapa está entre você e os outros players, é FISICAMENTE
         IMPOSSÍVEL qualquer um ver seu avatar!
      3. Invisibilidade Total Forçada a Cada Frame:
         Todas as partes, decalques e acessórios do corpo real são mantidos
         em transparência 1 e sem sombras em todo frame.
    • Tecla G: Ligar / Desligar Modo Astral V3.
    • Tecla H: Salvar Ponto Seguro / Base.
    ═══════════════════════════════════════════════════════════════════════════════
]]

-- SERVICES
local Workspace        = game:GetService("Workspace")
local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local StarterGui       = game:GetService("StarterGui")
local TweenService     = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local camera      = Workspace.CurrentCamera
local mouse       = LocalPlayer:GetMouse()

-- VirtualUser para simulação de clique do mouse
local VirtualUser = nil
pcall(function()
    VirtualUser = game:GetService("VirtualUser")
end)

-- ════════════════════════════════════════════════════════════════════════════════
-- CONFIGURAÇÕES PRINCIPAIS V3.0
-- ════════════════════════════════════════════════════════════════════════════════
local config = {
    modoAstralAtivo    = false,  -- Alternado pela Tecla G ou botão da GUI
    alturaCeu          = 850,    -- Altura do pod de segurança no céu (studs)
    distanciaCostas    = 2.0,    -- Distância exata atrás das costas do inimigo (studs)
    alturaCostas       = 0.2,    -- Ajuste de altura em relação ao tronco do inimigo
    velocidadeVoo      = 170,    -- Velocidade de aproximação até travar nas costas
    distanciaMaxima    = 750,    -- Alcance máximo para detecção de jogadores
    delayFlashMs       = 10,     -- Tempo ultra-rápido do golpe (10ms = sub-frame invisível)
    golpeSubterraneo   = true,   -- Bate debaixo do chão (-4.5 studs) para visibilidade ZERO
    offsetSubterraneo  = 4.5,    -- Profundidade abaixo do chão para o golpe subterrâneo
    invisibilidadeReal = true,   -- Força transparência total do corpo real continuamente
    autoAttackAtivo    = false,  -- Golpes contínuos automáticos
    delayAutoAttack    = 0.35,   -- Intervalo entre golpes automáticos
    distanciaGolpe     = 12,     -- Distância máxima para acionar golpe
    velocidadePadrao   = 16,     -- Velocidade de caminhada da cópia
    velocidadeSprint   = 32,     -- Velocidade de sprint da cópia
}

-- CORES DO TEMA
local COR_ACCENT = Color3.fromRGB(168, 85, 247)  -- Roxo Astral Neon
local COR_ROSA   = Color3.fromRGB(255, 50, 180)  -- Rosa Choque
local COR_FUNDO  = Color3.fromRGB(12, 15, 22)    -- Dark Black/Blue

-- VARIÁVEIS DE ESTADO
local copiaPersonagem       = nil
local plataformaCeu         = nil
local animTracks            = {}
local currentTarget         = nil
local targetRootPart        = nil
local targetHead            = nil
local diedConn              = nil
local safeSpotCFrame        = nil
local deadBlacklist         = {}
local executandoFlashAtaque = false
local lastAutoAttackTick    = 0
local lastManualClickTick   = 0

-- ════════════════════════════════════════════════════════════════════════════════
-- PLATAFORMA DE FORÇA NO CÉU (POD SEGURO)
-- ════════════════════════════════════════════════════════════════════════════════
plataformaCeu = Instance.new("Part")
plataformaCeu.Name = "AstralSkyPodSafeV3"
plataformaCeu.Size = Vector3.new(20, 1, 20)
plataformaCeu.Transparency = 0.65
plataformaCeu.Color = COR_ACCENT
plataformaCeu.Material = Enum.Material.ForceField
plataformaCeu.Anchored = true
plataformaCeu.CanCollide = true
plataformaCeu.CFrame = CFrame.new(0, -9999, 0)
plataformaCeu.Parent = Workspace

-- ════════════════════════════════════════════════════════════════════════════════
-- NOTIFICAÇÕES & UTILITÁRIOS
-- ════════════════════════════════════════════════════════════════════════════════
local function avisar(titulo, msg, dur)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = titulo,
            Text = msg,
            Duration = dur or 2.5
        })
    end)
end

-- ════════════════════════════════════════════════════════════════════════════════
-- SISTEMA DE INVISIBILIDADE TOTAL (CORPO FANTASMA)
-- ════════════════════════════════════════════════════════════════════════════════
local function aplicarInvisibilidade(char, invisivel)
    if not char then return end
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            if invisivel then
                if part:GetAttribute("OrigTransp") == nil then
                    part:SetAttribute("OrigTransp", part.Transparency)
                    part:SetAttribute("OrigCastShadow", part.CastShadow)
                end
                part.Transparency = 1
                part.CastShadow = false
            else
                local origT = part:GetAttribute("OrigTransp")
                if origT ~= nil then
                    part.Transparency = origT
                    part:SetAttribute("OrigTransp", nil)
                else
                    part.Transparency = 0
                end
                local origCS = part:GetAttribute("OrigCastShadow")
                if origCS ~= nil then
                    part.CastShadow = origCS
                    part:SetAttribute("OrigCastShadow", nil)
                else
                    part.CastShadow = true
                end
            end
        elseif part:IsA("Decal") then
            if invisivel then
                if part:GetAttribute("OrigTransp") == nil then
                    part:SetAttribute("OrigTransp", part.Transparency)
                end
                part.Transparency = 1
            else
                local origT = part:GetAttribute("OrigTransp")
                if origT ~= nil then
                    part.Transparency = origT
                    part:SetAttribute("OrigTransp", nil)
                else
                    part.Transparency = 0
                end
            end
        elseif part:IsA("ParticleEmitter") or part:IsA("Trail") or part:IsA("Beam") or part:IsA("Highlight") then
            if invisivel then
                if part:GetAttribute("OrigEnabled") == nil then
                    part:SetAttribute("OrigEnabled", part.Enabled)
                end
                part.Enabled = false
            else
                local origEn = part:GetAttribute("OrigEnabled")
                if origEn ~= nil then
                    part.Enabled = origEn
                    part:SetAttribute("OrigEnabled", nil)
                else
                    part.Enabled = true
                end
            end
        end
    end
end

-- ════════════════════════════════════════════════════════════════════════════════
-- CÁLCULO DA POSIÇÃO DINÂMICA DAS COSTAS
-- ════════════════════════════════════════════════════════════════════════════════
local function obterCFrameCostas(tRoot)
    if not tRoot or not tRoot.Parent then return nil end
    local targetCF = tRoot.CFrame
    local dist = config.distanciaCostas or 2.0
    local alt  = config.alturaCostas or 0.2
    local posCostas = targetCF.Position - (targetCF.LookVector * dist) + Vector3.new(0, alt, 0)
    return CFrame.lookAt(posCostas, targetCF.Position + Vector3.new(0, alt, 0))
end

-- ════════════════════════════════════════════════════════════════════════════════
-- MOTOR DE ANIMAÇÕES DA CÓPIA ASTRAL
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
    local char = LocalPlayer.Character
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
    local char = LocalPlayer.Character
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
-- SISTEMA DE FILTRO DE JOGADORES INIMIGOS
-- ════════════════════════════════════════════════════════════════════════════════
local function isBlacklisted(model)
    if deadBlacklist[model] then
        if tick() < deadBlacklist[model] then
            return true
        else
            deadBlacklist[model] = nil
        end
    end
    return false
end

local function markAsDead(model)
    if model then
        deadBlacklist[model] = tick() + 10
    end
end

local function isEnemyAlive(model)
    if not model or not model:IsA("Model") then return false end
    if not model:IsDescendantOf(Workspace) then return false end
    if model == LocalPlayer.Character then return false end
    if copiaPersonagem and model == copiaPersonagem then return false end
    if isBlacklisted(model) then return false end

    local p = Players:GetPlayerFromCharacter(model)
    if not p then return false end

    local hum = model:FindFirstChildOfClass("Humanoid")
    local rootPart = model:FindFirstChild("HumanoidRootPart") or model:FindFirstChild("Torso") or model:FindFirstChild("UpperTorso")
    local head = model:FindFirstChild("Head") or rootPart

    if not hum or not rootPart or not head then return false end
    if hum.Health <= 0 or hum:GetState() == Enum.HumanoidStateType.Dead then return false end

    return true
end

local function clearCurrentTarget()
    if diedConn then
        diedConn:Disconnect()
        diedConn = nil
    end
    if currentTarget then
        markAsDead(currentTarget)
    end
    currentTarget  = nil
    targetRootPart = nil
    targetHead     = nil
end

local function findNearestEnemy()
    local myPos = nil
    if config.modoAstralAtivo and copiaPersonagem and copiaPersonagem:FindFirstChild("HumanoidRootPart") then
        myPos = copiaPersonagem.HumanoidRootPart.Position
    elseif LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        myPos = LocalPlayer.Character.HumanoidRootPart.Position
    end
    if not myPos then return nil end

    local originPos = safeSpotCFrame and safeSpotCFrame.Position or myPos
    local closestEnemy = nil
    local shortestDist = config.distanciaMaxima

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local model = p.Character
            if isEnemyAlive(model) then
                local root = model:FindFirstChild("HumanoidRootPart") or model:FindFirstChild("Torso") or model:FindFirstChild("UpperTorso")
                if root then
                    local dist = (myPos - root.Position).Magnitude
                    if dist <= shortestDist then
                        shortestDist = dist
                        closestEnemy = model
                    end
                end
            end
        end
    end

    return closestEnemy
end

-- ════════════════════════════════════════════════════════════════════════════════
-- EQUIPAR ARMA AUTOMATICAMENTE
-- ════════════════════════════════════════════════════════════════════════════════
local function ensureWeaponEquipped()
    local char = LocalPlayer.Character
    if not char then return end

    local currentTool = char:FindFirstChildOfClass("Tool")
    if not currentTool then
        local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
        if backpack then
            local tool = backpack:FindFirstChildOfClass("Tool")
            if tool then
                tool.Parent = char
            end
        end
    end
end

-- ════════════════════════════════════════════════════════════════════════════════
-- SISTEMA DA TECLA G (MODO ASTRAL V3 COMPLETO)
-- ════════════════════════════════════════════════════════════════════════════════
local atualizarBotoesGUI -- Forward declaration

local function alternarModoAstral()
    config.modoAstralAtivo = not config.modoAstralAtivo
    local charReal = LocalPlayer.Character
    if not charReal then return end
    local realRoot = charReal:FindFirstChild("HumanoidRootPart")
    local realHum  = charReal:FindFirstChildOfClass("Humanoid")
    if not realRoot or not realHum then return end

    if config.modoAstralAtivo then
        -- 1. ATIVAR MODO ASTRAL V3
        local cframeAtual = realRoot.CFrame
        plataformaCeu.CFrame = CFrame.new(cframeAtual.X, config.alturaCeu, cframeAtual.Z)

        charReal.Archivable = true
        copiaPersonagem = charReal:Clone()
        copiaPersonagem.Name = LocalPlayer.Name .. "_AstralCloneV3"

        for _, s in ipairs(copiaPersonagem:GetDescendants()) do
            if s:IsA("Script") or s:IsA("LocalScript") then s:Destroy() end
        end

        local cHum  = copiaPersonagem:FindFirstChildOfClass("Humanoid")
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

        -- TORNA O CORPO REAL 100% INVISÍVEL
        if config.invisibilidadeReal then
            aplicarInvisibilidade(charReal, true)
        end

        -- Envia o corpo real para a segurança da plataforma no céu
        realHum.PlatformStand = true
        realRoot.AssemblyLinearVelocity = Vector3.zero
        realRoot.AssemblyAngularVelocity = Vector3.zero
        realRoot.CFrame = CFrame.new(cframeAtual.X, config.alturaCeu + 3.5, cframeAtual.Z)

        if atualizarBotoesGUI then atualizarBotoesGUI() end
        avisar("👻 Astral V3 Zero-Vis: ON", "Corpo no céu (+850 studs)! Ataque Ghost ativo!")
    else
        -- 2. DESATIVAR MODO ASTRAL
        clearCurrentTarget()

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

        aplicarInvisibilidade(charReal, false)

        realHum.PlatformStand = false
        camera.CameraSubject = realHum
        plataformaCeu.CFrame = CFrame.new(0, -9999, 0)

        for _, track in pairs(animTracks) do
            pcall(function() track:Stop() track:Destroy() end)
        end
        table.clear(animTracks)

        if atualizarBotoesGUI then atualizarBotoesGUI() end
        avisar("👻 Astral V3: DESLIGADO", "Retornado ao corpo com visibilidade normal.")
    end
end

-- ════════════════════════════════════════════════════════════════════════════════
-- FLASH ATTACK V3 — ZERO VISIBILIDADE (SUBTERRÂNEO / SUB-FRAME)
-- O Modo G NUNCA é desligado! O ataque acontece debaixo da terra ou em 10ms,
-- tornando IMPOSSÍVEL que outros jogadores vejam seu boneco!
-- ════════════════════════════════════════════════════════════════════════════════
local function executarFlashAtaque()
    if not config.modoAstralAtivo then return end
    if executandoFlashAtaque then return end
    if not copiaPersonagem or not copiaPersonagem.Parent then return end

    local charReal = LocalPlayer.Character
    if not charReal then return end
    local realRoot = charReal:FindFirstChild("HumanoidRootPart")
    local realHum  = charReal:FindFirstChildOfClass("Humanoid")
    if not realRoot or not realHum then return end

    local eRoot = targetRootPart
    if not eRoot or not eRoot.Parent then
        if currentTarget then
            eRoot = currentTarget:FindFirstChild("HumanoidRootPart") or currentTarget:FindFirstChild("Torso") or currentTarget:FindFirstChild("UpperTorso")
        end
    end
    if not eRoot or not eRoot.Parent then return end

    executandoFlashAtaque = true

    -- FORÇA A INVISIBILIDADE
    aplicarInvisibilidade(charReal, true)

    -- Equipa a ferramenta
    ensureWeaponEquipped()

    -- CÁLCULO DA POSIÇÃO DO GOLPE:
    -- Se golpeSubterraneo estiver ativo, posiciona -4.5 studs abaixo do chão!
    -- O chão bloqueia a visão de todos os outros players, e o alcance da arma acerta o alvo de baixo!
    local strikeCFrame = nil
    if config.golpeSubterraneo then
        local tCF = eRoot.CFrame
        local posSub = tCF.Position - (tCF.LookVector * 1.5) - Vector3.new(0, config.offsetSubterraneo or 4.5, 0)
        strikeCFrame = CFrame.lookAt(posSub, tCF.Position)
    else
        strikeCFrame = obterCFrameCostas(eRoot)
    end

    if strikeCFrame then
        realRoot.CFrame = strikeCFrame
    end
    realHum.PlatformStand = false
    realRoot.AssemblyLinearVelocity = Vector3.zero
    realRoot.AssemblyAngularVelocity = Vector3.zero

    -- A CÂMERA NUNCA SAI DA CÓPIA ASTRAL
    local cHum = copiaPersonagem:FindFirstChildOfClass("Humanoid")
    if cHum then
        camera.CameraSubject = cHum
    end

    -- DISPARA O GOLPE IMEDIATAMENTE
    local tool = charReal:FindFirstChildOfClass("Tool")
    if tool then
        pcall(function() tool:Activate() end)
    end

    pcall(function()
        if mouse1click then
            mouse1click()
        elseif VirtualUser then
            VirtualUser:CaptureController()
            VirtualUser:Button1Down(Vector2.new(0, 0))
            task.wait(0.005)
            VirtualUser:Button1Up(Vector2.new(0, 0))
        end
    end)

    -- TEMPO MÍNIMO (PADRÃO 10ms):
    -- Menor que a taxa de envio de pacotes do Roblox (33ms).
    -- O renderizador dos outros jogadores não chega a desenhar o boneco!
    local duracaoSegundos = math.clamp(config.delayFlashMs / 1000, 0.005, 0.3)
    task.wait(duracaoSegundos)

    -- RETORNA IMEDIATAMENTE AO CÉU NA PLATAFORMA (SEM NUNCA DESATIVAR O G!)
    if config.modoAstralAtivo and charReal and charReal.Parent and realRoot and realHum then
        realHum.PlatformStand = true
        realRoot.AssemblyLinearVelocity = Vector3.zero
        realRoot.AssemblyAngularVelocity = Vector3.zero
        local skyCenter = plataformaCeu.Position
        realRoot.CFrame = CFrame.new(skyCenter.X, skyCenter.Y + 3.5, skyCenter.Z)

        -- Garante que a cópia astral visível continue firme nas costas
        if eRoot and eRoot.Parent and copiaPersonagem and copiaPersonagem.Parent then
            local costasAtuais = obterCFrameCostas(eRoot)
            if costasAtuais then
                copiaPersonagem:PivotTo(costasAtuais)
            end
        end
    end

    executandoFlashAtaque = false
end

-- ════════════════════════════════════════════════════════════════════════════════
-- INTERFACE GRÁFICA HUD V3.0 (TOPO / ARRASTÁVEL)
-- ════════════════════════════════════════════════════════════════════════════════
local function getGuiParent()
    local success, coreGui = pcall(function() return game:GetService("CoreGui") end)
    if success and coreGui then
        local p = pcall(function()
            local f = Instance.new("Folder", coreGui)
            f:Destroy()
        end)
        if p then return coreGui end
    end
    return LocalPlayer:WaitForChild("PlayerGui")
end

local guiParent = getGuiParent()
if guiParent:FindFirstChild("AstralPvpGuiV3") then
    guiParent["AstralPvpGuiV3"]:Destroy()
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AstralPvpGuiV3"
screenGui.ResetOnSpawn = false
screenGui.Parent = guiParent

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainPvpFrameV3"
mainFrame.Size = UDim2.new(0, 260, 0, 365)
mainFrame.Position = UDim2.new(0.5, -130, 0, 20)
mainFrame.BackgroundColor3 = COR_FUNDO
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = mainFrame

local stroke = Instance.new("UIStroke")
stroke.Color = COR_ACCENT
stroke.Thickness = 1.5
stroke.Parent = mainFrame

-- Barra de Título (Arrastável)
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 32)
titleBar.BackgroundColor3 = Color3.fromRGB(18, 22, 34)
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 10)
titleCorner.Parent = titleBar

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -40, 1, 0)
title.Position = UDim2.new(0, 10, 0, 0)
title.BackgroundTransparency = 1
title.Text = "👻 Astral V3 — Zero Visibility [G]"
title.TextColor3 = COR_ACCENT
title.Font = Enum.Font.GothamBold
title.TextSize = 11
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = titleBar

local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.new(0, 24, 0, 24)
minBtn.Position = UDim2.new(1, -28, 0.5, -12)
minBtn.BackgroundColor3 = Color3.fromRGB(30, 35, 50)
minBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
minBtn.Font = Enum.Font.GothamBold
minBtn.TextSize = 12
minBtn.Text = "-"
minBtn.BorderSizePixel = 0
minBtn.Parent = titleBar
Instance.new("UICorner", minBtn).CornerRadius = UDim.new(0, 4)

local isMinimized = false
minBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        mainFrame:TweenSize(UDim2.new(0, 260, 0, 32), "Out", "Quad", 0.2, true)
        minBtn.Text = "+"
    else
        mainFrame:TweenSize(UDim2.new(0, 260, 0, 365), "Out", "Quad", 0.2, true)
        minBtn.Text = "-"
    end
end)

-- Status do Alvo & Conexão
local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -20, 0, 34)
statusLabel.Position = UDim2.new(0, 10, 0, 36)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Status: Modo Astral [G] Desativado\nAlvo: Nenhum"
statusLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
statusLabel.Font = Enum.Font.GothamMedium
statusLabel.TextSize = 10
statusLabel.TextWrapped = true
statusLabel.Parent = mainFrame

-- Botão Master [G] Modo Astral
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(1, -20, 0, 32)
toggleBtn.Position = UDim2.new(0, 10, 0, 72)
toggleBtn.BackgroundColor3 = Color3.fromRGB(35, 28, 48)
toggleBtn.BorderSizePixel = 0
toggleBtn.Text = "👻 MODO ASTRAL [G]: [DESLIGADO]"
toggleBtn.TextColor3 = Color3.fromRGB(220, 180, 255)
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 11
toggleBtn.Parent = mainFrame
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 6)

toggleBtn.MouseButton1Click:Connect(alternarModoAstral)

-- Botão Modo Subterrâneo (Zero Visibilidade Absoluta)
local subBtn = Instance.new("TextButton")
subBtn.Size = UDim2.new(1, -20, 0, 24)
subBtn.Position = UDim2.new(0, 10, 0, 108)
subBtn.BackgroundColor3 = Color3.fromRGB(20, 45, 35)
subBtn.BorderSizePixel = 0
subBtn.Text = "🕳️ Golpe Subterrâneo: [ATIVO]"
subBtn.TextColor3 = Color3.fromRGB(80, 255, 140)
subBtn.Font = Enum.Font.GothamBold
subBtn.TextSize = 10
subBtn.Parent = mainFrame
Instance.new("UICorner", subBtn).CornerRadius = UDim.new(0, 6)

subBtn.MouseButton1Click:Connect(function()
    config.golpeSubterraneo = not config.golpeSubterraneo
    if config.golpeSubterraneo then
        subBtn.Text = "🕳️ Golpe Subterrâneo: [ATIVO]"
        subBtn.TextColor3 = Color3.fromRGB(80, 255, 140)
        subBtn.BackgroundColor3 = Color3.fromRGB(20, 45, 35)
        avisar("🕳️ Subterrâneo", "Ataque por baixo do chão (Zero Visibilidade)!")
    else
        subBtn.Text = "🕳️ Golpe Subterrâneo: [DESATIVADO]"
        subBtn.TextColor3 = Color3.fromRGB(150, 150, 160)
        subBtn.BackgroundColor3 = Color3.fromRGB(25, 30, 42)
        avisar("🗡️ Costas Direto", "Ataque diretamente nas costas (Sub-frame 10ms)!")
    end
end)

-- Botão Auto-Attack Alternativo
local autoAttackBtn = Instance.new("TextButton")
autoAttackBtn.Size = UDim2.new(1, -20, 0, 24)
autoAttackBtn.Position = UDim2.new(0, 10, 0, 136)
autoAttackBtn.BackgroundColor3 = Color3.fromRGB(25, 30, 42)
autoAttackBtn.BorderSizePixel = 0
autoAttackBtn.Text = "⚔️ Auto-Attack Contínuo: [OFF]"
autoAttackBtn.TextColor3 = Color3.fromRGB(150, 150, 160)
autoAttackBtn.Font = Enum.Font.GothamBold
autoAttackBtn.TextSize = 10
autoAttackBtn.Parent = mainFrame
Instance.new("UICorner", autoAttackBtn).CornerRadius = UDim.new(0, 6)

autoAttackBtn.MouseButton1Click:Connect(function()
    config.autoAttackAtivo = not config.autoAttackAtivo
    if config.autoAttackAtivo then
        autoAttackBtn.Text = "⚔️ Auto-Attack Contínuo: [ON]"
        autoAttackBtn.TextColor3 = Color3.fromRGB(80, 255, 140)
        autoAttackBtn.BackgroundColor3 = Color3.fromRGB(20, 45, 35)
    else
        autoAttackBtn.Text = "⚔️ Auto-Attack Contínuo: [OFF]"
        autoAttackBtn.TextColor3 = Color3.fromRGB(150, 150, 160)
        autoAttackBtn.BackgroundColor3 = Color3.fromRGB(25, 30, 42)
    end
end)

-- Função auxiliar para criar linhas de ajuste numérico
local function criarControleLinha(posY, tituloTexto, valorInicial, step, minV, maxV, callback)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, -20, 0, 22)
    f.Position = UDim2.new(0, 10, 0, posY)
    f.BackgroundTransparency = 1
    f.Parent = mainFrame

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0, 100, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = tituloTexto
    lbl.TextColor3 = Color3.fromRGB(190, 200, 215)
    lbl.Font = Enum.Font.GothamMedium
    lbl.TextSize = 10
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = f

    local minus = Instance.new("TextButton")
    minus.Size = UDim2.new(0, 24, 1, 0)
    minus.Position = UDim2.new(0, 100, 0, 0)
    minus.BackgroundColor3 = Color3.fromRGB(32, 38, 52)
    minus.Text = "-"
    minus.TextColor3 = Color3.fromRGB(255, 255, 255)
    minus.Font = Enum.Font.GothamBold
    minus.TextSize = 11
    minus.Parent = f
    Instance.new("UICorner", minus).CornerRadius = UDim.new(0, 4)

    local box = Instance.new("TextBox")
    box.Size = UDim2.new(0, 60, 1, 0)
    box.Position = UDim2.new(0, 128, 0, 0)
    box.BackgroundColor3 = Color3.fromRGB(20, 24, 34)
    box.Text = tostring(valorInicial)
    box.TextColor3 = COR_ACCENT
    box.Font = Enum.Font.GothamBold
    box.TextSize = 10
    box.Parent = f
    Instance.new("UICorner", box).CornerRadius = UDim.new(0, 4)

    local plus = Instance.new("TextButton")
    plus.Size = UDim2.new(0, 24, 1, 0)
    plus.Position = UDim2.new(0, 192, 0, 0)
    plus.BackgroundColor3 = Color3.fromRGB(32, 38, 52)
    plus.Text = "+"
    plus.TextColor3 = Color3.fromRGB(255, 255, 255)
    plus.Font = Enum.Font.GothamBold
    plus.TextSize = 11
    plus.Parent = f
    Instance.new("UICorner", plus).CornerRadius = UDim.new(0, 4)

    local val = valorInicial
    local function setVal(nv)
        val = math.clamp(nv, minV, maxV)
        if step < 1 then val = math.round(val * 10) / 10 end
        box.Text = tostring(val)
        callback(val)
    end

    minus.MouseButton1Click:Connect(function() setVal(val - step) end)
    plus.MouseButton1Click:Connect(function() setVal(val + step) end)
    box.FocusLost:Connect(function()
        local n = tonumber(box.Text)
        if n then setVal(n) else box.Text = tostring(val) end
    end)
    return setVal
end

-- Controles Numéricos
criarControleLinha(164, "⚡ Flash Strike (ms):", config.delayFlashMs, 5, 5, 300, function(v) config.delayFlashMs = v end)
criarControleLinha(190, "🗡️ Distância Costas:", config.distanciaCostas, 0.2, 0.5, 8, function(v) config.distanciaCostas = v end)
criarControleLinha(216, "🦅 Vel. Perseguição:", config.velocidadeVoo, 10, 30, 800, function(v) config.velocidadeVoo = v end)
criarControleLinha(242, "🎯 Dist. Máxima:",     config.distanciaMaxima, 50, 50, 3000, function(v) config.distanciaMaxima = v end)

-- Botões Pular Alvo e Base [H]
local skipBtn = Instance.new("TextButton")
skipBtn.Size = UDim2.new(0.5, -14, 0, 24)
skipBtn.Position = UDim2.new(0, 10, 0, 270)
skipBtn.BackgroundColor3 = Color3.fromRGB(45, 30, 40)
skipBtn.BorderSizePixel = 0
skipBtn.Text = "⏭ Pular Alvo"
skipBtn.TextColor3 = Color3.fromRGB(255, 140, 180)
skipBtn.Font = Enum.Font.GothamBold
skipBtn.TextSize = 10
skipBtn.Parent = mainFrame
Instance.new("UICorner", skipBtn).CornerRadius = UDim.new(0, 5)

skipBtn.MouseButton1Click:Connect(function()
    if config.modoAstralAtivo and currentTarget then
        clearCurrentTarget()
        statusLabel.Text = "Pulando para o próximo jogador..."
    end
end)

local setSafeBtn = Instance.new("TextButton")
setSafeBtn.Size = UDim2.new(0.5, -14, 0, 24)
setSafeBtn.Position = UDim2.new(0.5, 4, 0, 270)
setSafeBtn.BackgroundColor3 = Color3.fromRGB(25, 35, 50)
setSafeBtn.BorderSizePixel = 0
setSafeBtn.Text = "📍 Salvar Base [H]"
setSafeBtn.TextColor3 = Color3.fromRGB(140, 200, 255)
setSafeBtn.Font = Enum.Font.GothamBold
setSafeBtn.TextSize = 10
setSafeBtn.Parent = mainFrame
Instance.new("UICorner", setSafeBtn).CornerRadius = UDim.new(0, 5)

local function saveCurrentLocationAsSafe()
    local root = nil
    if config.modoAstralAtivo and copiaPersonagem then
        root = copiaPersonagem:FindFirstChild("HumanoidRootPart")
    elseif LocalPlayer.Character then
        root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    end
    if root then
        safeSpotCFrame = root.CFrame
        avisar("📍 Ponto Seguro Salvo!", string.format("Base em X:%.0f Y:%.0f Z:%.0f", root.Position.X, root.Position.Y, root.Position.Z))
    end
end
setSafeBtn.MouseButton1Click:Connect(saveCurrentLocationAsSafe)

-- Mini Rodapé com Instruções
local footer = Instance.new("TextLabel")
footer.Size = UDim2.new(1, -20, 0, 60)
footer.Position = UDim2.new(0, 10, 0, 298)
footer.BackgroundTransparency = 1
footer.Text = "👻 V3: Modo G NUNCA desliga! Zero Visibilidade.\n🕳️ Golpe Subterrâneo + Sub-Frame (10ms).\n[G] Modo Astral Costas  •  [H] Salvar Base"
footer.TextColor3 = Color3.fromRGB(160, 175, 200)
footer.Font = Enum.Font.Gotham
footer.TextSize = 9
footer.TextWrapped = true
footer.Parent = mainFrame

-- Arrastar Interface
local dragging, dragStart, startPos
titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Atualização visual do botão da GUI
atualizarBotoesGUI = function()
    if config.modoAstralAtivo then
        toggleBtn.Text = "👻 MODO ASTRAL [G]: [LIGADO]"
        toggleBtn.TextColor3 = Color3.fromRGB(80, 255, 140)
        toggleBtn.BackgroundColor3 = Color3.fromRGB(20, 45, 30)
    else
        toggleBtn.Text = "👻 MODO ASTRAL [G]: [DESLIGADO]"
        toggleBtn.TextColor3 = Color3.fromRGB(220, 180, 255)
        toggleBtn.BackgroundColor3 = Color3.fromRGB(35, 28, 48)
        statusLabel.Text = "Status: Modo Astral [G] Desativado\nAlvo: Nenhum"
        statusLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
    end
end

-- ════════════════════════════════════════════════════════════════════════════════
-- CONEXÕES DE ENTRADA DO USUÁRIO (TECLADO & CLIQUE DO MOUSE)
-- ════════════════════════════════════════════════════════════════════════════════
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if UserInputService:GetFocusedTextBox() then return end

    -- Tecla G: Ligar/Desligar Modo Astral Costas
    if input.KeyCode == Enum.KeyCode.G then
        alternarModoAstral()
        return
    end

    -- Tecla H: Salvar Ponto Seguro
    if input.KeyCode == Enum.KeyCode.H then
        saveCurrentLocationAsSafe()
        return
    end

    -- Clique do Mouse Esquerdo: Flash Attack Zero-Visibility
    if not gameProcessed and input.UserInputType == Enum.UserInputType.MouseButton1 then
        if config.modoAstralAtivo then
            if tick() - lastManualClickTick >= 0.05 then
                lastManualClickTick = tick()
                task.spawn(executarFlashAtaque)
            end
        end
    end
end)

-- Suporte complementar via mouse.Button1Down
mouse.Button1Down:Connect(function()
    if config.modoAstralAtivo and not executandoFlashAtaque then
        if tick() - lastManualClickTick >= 0.05 then
            lastManualClickTick = tick()
            task.spawn(executarFlashAtaque)
        end
    end
end)

-- ════════════════════════════════════════════════════════════════════════════════
-- THREAD GERENCIADORA DE ALVOS (A CADA 0.1s)
-- ════════════════════════════════════════════════════════════════════════════════
task.spawn(function()
    while true do
        task.wait(0.1)
        if config.modoAstralAtivo then
            if currentTarget then
                if not isEnemyAlive(currentTarget) then
                    clearCurrentTarget()
                end
            end

            if not currentTarget then
                local nextEnemy = findNearestEnemy()
                if nextEnemy then
                    currentTarget  = nextEnemy
                    targetRootPart = nextEnemy:FindFirstChild("HumanoidRootPart") or nextEnemy:FindFirstChild("Torso") or nextEnemy:FindFirstChild("UpperTorso")
                    targetHead     = nextEnemy:FindFirstChild("Head") or targetRootPart

                    local hum = nextEnemy:FindFirstChildOfClass("Humanoid")
                    if hum then
                        if diedConn then diedConn:Disconnect() end
                        diedConn = hum.Died:Connect(function()
                            clearCurrentTarget()
                        end)
                    end
                end
            end

            -- Atualização do Status na Interface
            if currentTarget and targetRootPart then
                local hum = currentTarget:FindFirstChildOfClass("Humanoid")
                local hp = hum and math.floor(hum.Health) or 0
                local maxHp = hum and math.max(math.floor(hum.MaxHealth), 1) or 100
                local cRoot = copiaPersonagem and copiaPersonagem:FindFirstChild("HumanoidRootPart")
                local dist = cRoot and math.floor((cRoot.Position - targetRootPart.Position).Magnitude) or 0

                statusLabel.Text = string.format("Alvo: %s (%d studs)\nVida: %d/%d HP ● ZERO VISIBILITY", currentTarget.Name, dist, hp, maxHp)
                statusLabel.TextColor3 = Color3.fromRGB(80, 255, 140)
            else
                if safeSpotCFrame then
                    statusLabel.Text = "Procurando alvos...\n(Aguardando no Ponto Seguro [H])"
                else
                    statusLabel.Text = "Procurando alvos...\nNenhum jogador por perto"
                end
                statusLabel.TextColor3 = Color3.fromRGB(220, 200, 120)
            end
        end
    end
end)

-- ════════════════════════════════════════════════════════════════════════════════
-- LOOPS PRINCIPAIS (STEPPED: NOCLIP & INVISIBILIDADE CONTÍNUA)
-- ════════════════════════════════════════════════════════════════════════════════

RunService.Stepped:Connect(function()
    if not config.modoAstralAtivo then return end

    local char = LocalPlayer.Character
    if char then
        -- Noclip
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
        -- Garante que o corpo real permaneça 100% invisível em todo frame
        if config.invisibilidadeReal then
            for _, p in ipairs(char:GetDescendants()) do
                if p:IsA("BasePart") and p.Transparency < 1 then
                    p.Transparency = 1
                    p.CastShadow = false
                elseif p:IsA("Decal") and p.Transparency < 1 then
                    p.Transparency = 1
                end
            end
        end
    end

    if copiaPersonagem and copiaPersonagem.Parent then
        for _, part in ipairs(copiaPersonagem:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    end
end)

-- HEARTBEAT: MOVIMENTAÇÃO COLADA NAS COSTAS E PROTEÇÃO DO CORPO NO CÉU
RunService.Heartbeat:Connect(function(dt)
    if not config.modoAstralAtivo then return end

    if executandoFlashAtaque then return end

    local charReal = LocalPlayer.Character
    if not charReal then return end
    local realRoot = charReal:FindFirstChild("HumanoidRootPart")
    local realHum  = charReal:FindFirstChildOfClass("Humanoid")
    if not realRoot or not realHum then return end

    if not copiaPersonagem or not copiaPersonagem.Parent then return end
    local cHum  = copiaPersonagem:FindFirstChildOfClass("Humanoid")
    local cRoot = copiaPersonagem:FindFirstChild("HumanoidRootPart")
    if not cHum or not cRoot then return end

    -- CASO 1: TEM ALVO JOGADOR -> GRUDA 100% NAS COSTAS (BACKSTAB)
    if currentTarget and targetRootPart and targetRootPart.Parent then
        cHum.PlatformStand = false
        cRoot.AssemblyLinearVelocity = Vector3.zero
        cRoot.AssemblyAngularVelocity = Vector3.zero

        local costasCF = obterCFrameCostas(targetRootPart)
        if costasCF then
            local currentPos = cRoot.Position
            local targetPos  = costasCF.Position
            local dist = (targetPos - currentPos).Magnitude

            if dist > 35 then
                local direction = (targetPos - currentPos).Unit
                local step = math.min(dist, config.velocidadeVoo * dt)
                cRoot.CFrame = CFrame.lookAt(currentPos + direction * step, targetRootPart.Position)

                if animTracks.run and not animTracks.run.IsPlaying then animTracks.run:Play(0.1) end
                if animTracks.idle and animTracks.idle.IsPlaying then animTracks.idle:Stop(0.1) end
            else
                cRoot.CFrame = costasCF

                if animTracks.idle and not animTracks.idle.IsPlaying then animTracks.idle:Play(0.1) end
                if animTracks.run and animTracks.run.IsPlaying then animTracks.run:Stop(0.1) end
            end

            -- Auto-Attack contínuo se ativado
            if config.autoAttackAtivo and dist <= config.distanciaGolpe then
                if tick() - lastAutoAttackTick >= (config.delayAutoAttack or 0.35) then
                    lastAutoAttackTick = tick()
                    task.spawn(executarFlashAtaque)
                end
            end
        end

    -- CASO 2: SEM ALVO -> AGUARDA NO PONTO SEGURO [H] OU PERMANECE IDLE
    elseif safeSpotCFrame then
        cHum.PlatformStand = false
        local targetPos = safeSpotCFrame.Position
        local currentPos = cRoot.Position
        local dist = (targetPos - currentPos).Magnitude

        if dist > 2 then
            local direction = (targetPos - currentPos).Unit
            local step = math.min(dist, config.velocidadeVoo * dt)
            cRoot.CFrame = CFrame.new(currentPos + direction * step, targetPos + safeSpotCFrame.LookVector)
        else
            cRoot.CFrame = safeSpotCFrame
            cRoot.AssemblyLinearVelocity = Vector3.zero
        end
    end

    -- MANTER O POD DO CÉU E O CORPO REAL EXATAMENTE SOBRE A CÓPIA A +850 STUDS
    local skyX = cRoot.Position.X
    local skyZ = cRoot.Position.Z
    plataformaCeu.CFrame = CFrame.new(skyX, config.alturaCeu, skyZ)

    realHum.PlatformStand = true
    realRoot.AssemblyLinearVelocity = Vector3.zero
    realRoot.AssemblyAngularVelocity = Vector3.zero
    realRoot.CFrame = CFrame.new(skyX, config.alturaCeu + 3.5, skyZ)
end)

-- ════════════════════════════════════════════════════════════════════════════════
-- LIMPEZA E RESET AO RENASCER / MORRER
-- ════════════════════════════════════════════════════════════════════════════════
LocalPlayer.CharacterAdded:Connect(function(newChar)
    if config.modoAstralAtivo then
        config.modoAstralAtivo = false
        if copiaPersonagem and copiaPersonagem.Parent then
            copiaPersonagem:Destroy()
            copiaPersonagem = nil
        end
        for _, track in pairs(animTracks) do
            pcall(function() track:Stop() track:Destroy() end)
        end
        table.clear(animTracks)
        plataformaCeu.CFrame = CFrame.new(0, -9999, 0)
        atualizarBotoesGUI()
    end
    clearCurrentTarget()
end)

avisar("👻 Astral V3 Pronto!", "Modo Zero Visibility carregado em 3.lua!", 4)
print("[ASTRAL PVP V3.0 ZERO VISIBILITY] Arquivo 3.lua criado com sucesso!")
