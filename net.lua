--[[
    ═══════════════════════════════════════════════════════════════════════════════
    👻 MODO ASTRAL PVP + FLASH ATTACK RELÂMPAGO [TECLA G]
    ═══════════════════════════════════════════════════════════════════════════════
    • Tecla G: Ativa o Modo Astral Completo.
      - Seu corpo real é enviado com segurança para a plataforma no céu (+850 studs).
      - Sua cópia astral fica grudada no jogador mais próximo (perseguição contínua).
    • Clique do Mouse Esquerdo:
      - Desce instantaneamente do céu para a posição do clone colado no jogador.
      - Desfere o golpe/ataque com o botão esquerdo e arma equipada.
      - Em milissegundos (ex: 60ms) retorna imediatamente para o céu no Modo Astral!
    • Tecla H: Salva ponto de espera / retorno seguro.
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
-- CONFIGURAÇÕES PRINCIPAIS
-- ════════════════════════════════════════════════════════════════════════════════
local config = {
    modoAstralAtivo    = false,  -- Alternado pela Tecla G ou botão da GUI
    alturaCeu          = 850,    -- Altura do pod de segurança no céu (studs)
    alturaCabeca       = 3.5,    -- Altura relativa ao jogador inimigo (studs)
    velocidadeVoo      = 130,    -- Velocidade de aproximação até grudar no alvo
    distanciaMaxima    = 650,    -- Alcance máximo para detecção de jogadores
    delayFlashMs       = 60,     -- Milissegundos em que o corpo real fica no chão para bater antes de voltar ao céu
    autoAttackAtivo    = false,  -- Se verdadeiro, além do clique manual, também desfere golpes automáticos periódicos
    delayAutoAttack    = 0.35,   -- Intervalo entre golpes se auto-attack estiver ligado
    distanciaGolpe     = 14,     -- Distância máxima do inimigo para golpear
    velocidadePadrao   = 16,     -- Velocidade de caminhada da cópia
    velocidadeSprint   = 32,     -- Velocidade de sprint da cópia
}

-- CORES DO TEMA
local COR_ACCENT = Color3.fromRGB(168, 85, 247)  -- Roxo Astral Neon
local COR_ROSA   = Color3.fromRGB(255, 50, 180)  -- Rosa Choque
local COR_FUNDO  = Color3.fromRGB(12, 15, 22)    -- Dark Black/Blue
local COR_CARD   = Color3.fromRGB(20, 24, 36)    -- Dark Slate

-- VARIÁVEIS DE ESTADO
local copiaPersonagem       = nil
local plataformaCeu         = nil
local animTracks            = {}
local currentTarget         = nil
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
plataformaCeu.Name = "AstralSkyPodSafe"
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
    local rootPart = model:FindFirstChild("HumanoidRootPart")
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
    currentTarget = nil
    targetHead = nil
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
                local head = model:FindFirstChild("Head") or model:FindFirstChild("HumanoidRootPart")
                if head then
                    local dist = (myPos - head.Position).Magnitude
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
-- SISTEMA DA TECLA G (MODO ASTRAL COMPLETO)
-- ════════════════════════════════════════════════════════════════════════════════
local atualizarBotoesGUI -- Declaração forward para a GUI

local function alternarModoAstral()
    config.modoAstralAtivo = not config.modoAstralAtivo
    local charReal = LocalPlayer.Character
    if not charReal then return end
    local realRoot = charReal:FindFirstChild("HumanoidRootPart")
    local realHum  = charReal:FindFirstChildOfClass("Humanoid")
    if not realRoot or not realHum then return end

    if config.modoAstralAtivo then
        -- 1. ATIVAR MODO ASTRAL
        local cframeAtual = realRoot.CFrame
        plataformaCeu.CFrame = CFrame.new(cframeAtual.X, config.alturaCeu, cframeAtual.Z)

        charReal.Archivable = true
        copiaPersonagem = charReal:Clone()
        copiaPersonagem.Name = LocalPlayer.Name .. "_AstralClone"

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

        -- Fixa o corpo real com segurança no céu
        realHum.PlatformStand = true
        realRoot.AssemblyLinearVelocity = Vector3.zero
        realRoot.AssemblyAngularVelocity = Vector3.zero
        realRoot.CFrame = CFrame.new(cframeAtual.X, config.alturaCeu + 3.5, cframeAtual.Z)

        if atualizarBotoesGUI then atualizarBotoesGUI() end
        avisar("👻 Modo Astral [G]: ATIVADO", "Corpo real seguro a +" .. config.alturaCeu .. " studs! Grudando no alvo...")
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

        realHum.PlatformStand = false
        camera.CameraSubject = realHum
        plataformaCeu.CFrame = CFrame.new(0, -9999, 0)

        for _, track in pairs(animTracks) do
            pcall(function() track:Stop() track:Destroy() end)
        end
        table.clear(animTracks)

        if atualizarBotoesGUI then atualizarBotoesGUI() end
        avisar("👻 Modo Astral [G]: DESATIVADO", "Retornado ao corpo físico com segurança.")
    end
end

-- ════════════════════════════════════════════════════════════════════════════════
-- FLASH ATTACK RELÂMPAGO (AO CLICAR COM O MOUSE ESQUERDO)
-- Desce instantaneamente do céu, clica/ataca, e volta ao Modo Astral em milissegundos!
-- ════════════════════════════════════════════════════════════════════════════════
local function executarFlashAtaque()
    if not config.modoAstralAtivo then return end
    if executandoFlashAtaque then return end
    if not copiaPersonagem or not copiaPersonagem.Parent then return end

    local charReal = LocalPlayer.Character
    if not charReal then return end
    local realRoot = charReal:FindFirstChild("HumanoidRootPart")
    local realHum  = charReal:FindFirstChildOfClass("Humanoid")
    local cRoot    = copiaPersonagem:FindFirstChild("HumanoidRootPart")
    if not realRoot or not realHum or not cRoot then return end

    executandoFlashAtaque = true

    -- 1. CAPTURA A POSIÇÃO ONDE A CÓPIA ESTÁ GRUDADA NO ALVO
    local posAtaque = cRoot.CFrame

    -- 2. DESCE O CORPO REAL INSTANTANEAMENTE PARA O LOCAL
    realHum.PlatformStand = false
    realRoot.AssemblyLinearVelocity = Vector3.zero
    realRoot.AssemblyAngularVelocity = Vector3.zero
    realRoot.CFrame = posAtaque
    camera.CameraSubject = realHum

    -- Oculta temporariamente a cópia para ataque limpo
    copiaPersonagem.Parent = nil

    -- 3. EXECUTA O CLIQUE DO MOUSE ESQUERDO E ATIVAÇÃO DA ARMA
    ensureWeaponEquipped()

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
            task.wait(0.01)
            VirtualUser:Button1Up(Vector2.new(0, 0))
        end
    end)

    -- 4. AGUARDA OS MILISSEGUNDOS DEFINIDOS (Padrão: 60ms)
    local esperaSegundos = math.clamp(config.delayFlashMs / 1000, 0.02, 0.5)
    task.wait(esperaSegundos)

    -- 5. RETORNA IMEDIATAMENTE PARA O MODO G NO CÉU
    if config.modoAstralAtivo and charReal and charReal.Parent and realRoot and realHum then
        local posRetorno = realRoot.CFrame

        -- Restaura a cópia no mundo exatamente onde o ataque ocorreu
        copiaPersonagem.Parent = Workspace
        copiaPersonagem:PivotTo(posRetorno)
        local cHum = copiaPersonagem:FindFirstChildOfClass("Humanoid")
        if cHum then
            camera.CameraSubject = cHum
        end

        -- Teleporta o corpo real de volta ao céu na plataforma
        realHum.PlatformStand = true
        realRoot.AssemblyLinearVelocity = Vector3.zero
        realRoot.AssemblyAngularVelocity = Vector3.zero
        local skyCenter = plataformaCeu.Position
        realRoot.CFrame = CFrame.new(skyCenter.X, skyCenter.Y + 3.5, skyCenter.Z)
    else
        -- Caso o modo astral tenha sido desativado no meio do ataque
        if copiaPersonagem and copiaPersonagem.Parent then
            copiaPersonagem:Destroy()
            copiaPersonagem = nil
        end
        realHum.PlatformStand = false
        camera.CameraSubject = realHum
    end

    executandoFlashAtaque = false
end

-- ════════════════════════════════════════════════════════════════════════════════
-- INTERFACE GRÁFICA HUD V9.1 (TOPO / ARRASTÁVEL)
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
if guiParent:FindFirstChild("AstralPvpGui") then
    guiParent["AstralPvpGui"]:Destroy()
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AstralPvpGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = guiParent

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainPvpFrame"
mainFrame.Size = UDim2.new(0, 260, 0, 335)
mainFrame.Position = UDim2.new(0.5, -130, 0, 25)
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
title.Text = "👻 Astral Stick + Flash Attack [G]"
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
        mainFrame:TweenSize(UDim2.new(0, 260, 0, 335), "Out", "Quad", 0.2, true)
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

-- Botão Auto-Attack Alternativo (Kill Aura opcional)
local autoAttackBtn = Instance.new("TextButton")
autoAttackBtn.Size = UDim2.new(1, -20, 0, 24)
autoAttackBtn.Position = UDim2.new(0, 10, 0, 108)
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
    f.Size = UDim2.new(1, -20, 0, 24)
    f.Position = UDim2.new(0, 10, 0, posY)
    f.BackgroundTransparency = 1
    f.Parent = mainFrame

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0, 95, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = tituloTexto
    lbl.TextColor3 = Color3.fromRGB(190, 200, 215)
    lbl.Font = Enum.Font.GothamMedium
    lbl.TextSize = 10
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = f

    local minus = Instance.new("TextButton")
    minus.Size = UDim2.new(0, 24, 1, 0)
    minus.Position = UDim2.new(0, 95, 0, 0)
    minus.BackgroundColor3 = Color3.fromRGB(32, 38, 52)
    minus.Text = "-"
    minus.TextColor3 = Color3.fromRGB(255, 255, 255)
    minus.Font = Enum.Font.GothamBold
    minus.TextSize = 11
    minus.Parent = f
    Instance.new("UICorner", minus).CornerRadius = UDim.new(0, 4)

    local box = Instance.new("TextBox")
    box.Size = UDim2.new(0, 65, 1, 0)
    box.Position = UDim2.new(0, 123, 0, 0)
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
criarControleLinha(136, "⚡ Flash Strike (ms):", config.delayFlashMs, 10, 20, 500, function(v) config.delayFlashMs = v end)
criarControleLinha(164, "📏 Altura do Alvo:",   config.alturaCabeca,  0.5, -5, 30,  function(v) config.alturaCabeca = v end)
criarControleLinha(192, "🦅 Vel. Perseguição:", config.velocidadeVoo, 10, 20, 600, function(v) config.velocidadeVoo = v end)
criarControleLinha(220, "🎯 Dist. Máxima:",     config.distanciaMaxima, 50, 50, 2500, function(v) config.distanciaMaxima = v end)

-- Botão Pular Alvo
local skipBtn = Instance.new("TextButton")
skipBtn.Size = UDim2.new(0.5, -14, 0, 24)
skipBtn.Position = UDim2.new(0, 10, 0, 248)
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

-- Botão Salvar Ponto [H]
local setSafeBtn = Instance.new("TextButton")
setSafeBtn.Size = UDim2.new(0.5, -14, 0, 24)
setSafeBtn.Position = UDim2.new(0.5, 4, 0, 248)
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
footer.Size = UDim2.new(1, -20, 0, 48)
footer.Position = UDim2.new(0, 10, 0, 276)
footer.BackgroundTransparency = 1
footer.Text = "🖱️ Clique Esquerdo: Flash Attack instantâneo\n[G] Modo Astral Grudado  •  [H] Ponto Base"
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
    -- Se estiver digitando no chat ou em caixas de texto, ignora
    if UserInputService:GetFocusedTextBox() then return end

    -- Tecla G: Ligar/Desligar Modo Astral
    if input.KeyCode == Enum.KeyCode.G then
        alternarModoAstral()
        return
    end

    -- Tecla H: Salvar Ponto Seguro
    if input.KeyCode == Enum.KeyCode.H then
        saveCurrentLocationAsSafe()
        return
    end

    -- Clique do Mouse Esquerdo: Flash Attack
    if not gameProcessed and input.UserInputType == Enum.UserInputType.MouseButton1 then
        if config.modoAstralAtivo then
            if tick() - lastManualClickTick >= 0.05 then
                lastManualClickTick = tick()
                task.spawn(executarFlashAtaque)
            end
        end
    end
end)

-- Suporte complementar para clique via mouse.Button1Down
mouse.Button1Down:Connect(function()
    if config.modoAstralAtivo and not executandoFlashAtaque then
        if tick() - lastManualClickTick >= 0.05 then
            lastManualClickTick = tick()
            task.spawn(executarFlashAtaque)
        end
    end
end)

-- ════════════════════════════════════════════════════════════════════════════════
-- THREAD GERENCIADORA DE ALVOS (RODA A CADA 0.1s)
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
                    currentTarget = nextEnemy
                    targetHead = nextEnemy:FindFirstChild("Head") or nextEnemy:FindFirstChild("HumanoidRootPart")

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
            if currentTarget and targetHead then
                local hum = currentTarget:FindFirstChildOfClass("Humanoid")
                local hp = hum and math.floor(hum.Health) or 0
                local maxHp = hum and math.max(math.floor(hum.MaxHealth), 1) or 100
                local cRoot = copiaPersonagem and copiaPersonagem:FindFirstChild("HumanoidRootPart")
                local dist = cRoot and math.floor((cRoot.Position - targetHead.Position).Magnitude) or 0

                statusLabel.Text = string.format("Alvo: %s (%d studs)\nVida: %d/%d HP ● GRUDADO", currentTarget.Name, dist, hp, maxHp)
                statusLabel.TextColor3 = Color3.fromRGB(80, 255, 140)
            else
                if safeSpotCFrame then
                    statusLabel.Text = "Procurando jogadores no alcance...\n(Aguardando no Ponto Seguro [H])"
                else
                    statusLabel.Text = "Procurando jogadores no alcance...\nNenhum jogador por perto"
                end
                statusLabel.TextColor3 = Color3.fromRGB(220, 200, 120)
            end
        end
    end
end)

-- ════════════════════════════════════════════════════════════════════════════════
-- LOOPS PRINCIPAIS (STEPPED: NOCLIP & HEARTBEAT: FÍSICA E PERSEGUIÇÃO)
-- ════════════════════════════════════════════════════════════════════════════════

-- NOCLIP ATIVO NO MODO ASTRAL (Evita colisões e empurrões indesejados)
RunService.Stepped:Connect(function()
    if not config.modoAstralAtivo then return end

    local char = LocalPlayer.Character
    if char then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
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

-- HEARTBEAT: MOVIMENTAÇÃO DA CÓPIA GRUDADA E PROTEÇÃO DO CORPO NO CÉU
RunService.Heartbeat:Connect(function(dt)
    if not config.modoAstralAtivo then return end

    -- Durante os milissegundos do flash attack, a física do Heartbeat não interfere no corpo real
    if executandoFlashAtaque then return end

    local charReal = LocalPlayer.Character
    if not charReal then return end
    local realRoot = charReal:FindFirstChild("HumanoidRootPart")
    local realHum  = charReal:FindFirstChildOfClass("Humanoid")
    if not realRoot or not realHum then return end

    -- Se o clone não existe, recria ou cancela
    if not copiaPersonagem or not copiaPersonagem.Parent then return end
    local cHum  = copiaPersonagem:FindFirstChildOfClass("Humanoid")
    local cRoot = copiaPersonagem:FindFirstChild("HumanoidRootPart")
    if not cHum or not cRoot then return end

    -- CASO 1: TEM ALVO JOGADOR SELECIONADO -> GRUDA NELE
    if currentTarget and targetHead and targetHead.Parent then
        cHum.PlatformStand = false
        cRoot.AssemblyLinearVelocity = Vector3.zero
        cRoot.AssemblyAngularVelocity = Vector3.zero

        local targetPos = targetHead.Position + Vector3.new(0, config.alturaCabeca, 0)
        local currentPos = cRoot.Position
        local dist = (targetPos - currentPos).Magnitude

        if dist > 2 then
            -- Aproximação em alta velocidade
            local direction = (targetPos - currentPos).Unit
            local step = math.min(dist, config.velocidadeVoo * dt)
            cRoot.CFrame = CFrame.new(currentPos + direction * step, targetHead.Position)

            -- Animação de corrida
            if animTracks.run and not animTracks.run.IsPlaying then animTracks.run:Play(0.1) end
            if animTracks.idle and animTracks.idle.IsPlaying then animTracks.idle:Stop(0.1) end
        else
            -- 100% Fixado e grudado na cabeça/corpo do jogador alvo
            cRoot.CFrame = CFrame.new(targetPos, targetHead.Position)

            -- Animação de idle
            if animTracks.idle and not animTracks.idle.IsPlaying then animTracks.idle:Play(0.1) end
            if animTracks.run and animTracks.run.IsPlaying then animTracks.run:Stop(0.1) end
        end

        -- Se o Auto-Attack contínuo estiver ativado e estiver no alcance de golpe
        if config.autoAttackAtivo and dist <= config.distanciaGolpe then
            if tick() - lastAutoAttackTick >= (config.delayAutoAttack or 0.35) then
                lastAutoAttackTick = tick()
                task.spawn(executarFlashAtaque)
            end
        end

    -- CASO 2: SEM ALVO -> AGUARDA NO PONTO SEGURO SALVO [H] OU PERMANECE IDLE
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

    -- MANTER O POD DO CÉU E O CORPO REAL EXATAMENTE SOBRE O CLONE A +850 STUDS
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
LocalPlayer.CharacterAdded:Connect(function()
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

avisar("👻 Astral PvP Pronto!", "[G] = Modo Astral Grudado  |  Clique Esquerdo = Flash Attack", 4)
print("[ASTRAL PVP] Script 1.lua carregado com sucesso!")
