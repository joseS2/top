--[[
    ═══════════════════════════════════════════════════════════════════════════════
    👻 MODO ASTRAL PVP V6.0 — QUANTUM GHOST FREE-WALK & SKILL STRIKE (Z, X, C, V)
    ═══════════════════════════════════════════════════════════════════════════════
    ARQUIVO: 6.lua

    COMO FUNCIONA ESTA VERSÃO:
    
    1. Modo G com Caminhada Livre (SEM GRUDAR AUTOMÁTICO):
       • Ao apertar [G], você NÃO gruda em nenhum jogador automaticamente.
       • Você ganha controle total do seu clone no chão: pode andar (W, A, S, D),
         correr com [Shift] e pular com [Espaço] livremente pelo mapa!
       • O seu corpo físico real fica 100% seguro na plataforma celestial a +850 studs,
         acompanhando a sua posição X e Z em tempo real pelo céu.

    2. Ataque com Clique do Mouse:
       • Ao clicar com o [Botão Esquerdo do Mouse]:
         O seu corpo real desce instantaneamente na posição da cópia, fica visível
         por milissegundos, desferindo o ataque da sua arma/clique, e retorna em
         milissegundos com segurança para o céu!

    3. Ataque com Habilidades / Skills [Z], [X], [C], [V]:
       • Ao apertar qualquer tecla de skill: [Z], [X], [C] ou [V]:
         O seu corpo real desce imediatamente onde você está andando com a cópia,
         torna-se visível no chão pelo tempo exato para disparar a skill do jogo,
         e imediatamente retorna em segurança para a plataforma no céu!

    4. Blindagem Anti-Dano Ativa (God-Shield):
       • Suas partes do corpo real têm CanTouch = FALSE (espadas e golpes inimigos
         passam direto por você sem causar dano).
       • A sua arma mantém CanTouch = TRUE para acertar o inimigo com força máxima.

    5. Trava Opcional de Jogador [R] e Alternador de Lado [T]:
       • Se quiser travar nas costas de alguém manualmente, basta apertar [R].
       • Aperte [T] para alternar entre ficar nas [COSTAS] ou na [FRENTE].
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

-- VirtualUser para simulação de cliques e teclas
local VirtualUser = nil
pcall(function()
    VirtualUser = game:GetService("VirtualUser")
end)

-- ════════════════════════════════════════════════════════════════════════════════
-- CONFIGURAÇÕES PRINCIPAIS V6.0
-- ════════════════════════════════════════════════════════════════════════════════
local config = {
    modoAstralAtivo     = false,      -- Começa desligado até apertar [G]
    grudarAuto          = false,      -- NÃO gruda automaticamente (anda livre pelo mapa!)
    travaManualAtiva    = false,      -- Trava manual opcional no alvo mais próximo [R]
    posicaoAlvo         = "costas",   -- "costas" ou "frente" (quando a trava manual estiver ligada)
    alturaCeu           = 850,        -- Altura segura no céu (studs)
    velocidadePadrao    = 16,         -- Velocidade padrão da cópia ao andar
    velocidadeSprint    = 32,         -- Velocidade ao correr com [Shift]
    distanciaRelativa   = 2.2,        -- Distância do alvo na trava manual
    alturaRelativa      = 0.2,        -- Altura relativa ao alvo
    distanciaMaxima     = 800,        -- Alcance máximo do radar

    -- Temporizadores de Visibilidade / Retorno
    delayFlashMouseMs   = 70,         -- Tempo visível no chão ao clicar com o Mouse (70ms)
    delayFlashSkillMs   = 110,        -- Tempo visível no chão ao usar Z, X, C, V (110ms)
    
    -- Blindagem & Defesa
    godShieldAtivo      = true,       -- CanTouch = false no corpo para evitar tomar dano
    forceFieldAtivo     = true,       -- ForceField invisível para proteção de scripts
    golpeSubterraneo    = false,      -- Golpe subterrâneo opcional (-4.5 studs)
    offsetSubterraneo   = 4.5,

    -- Auto Attack Opcional
    autoAttackAtivo     = false,
    delayAutoAttack     = 0.35,
}

-- CORES DO TEMA
local COR_ACCENT = Color3.fromRGB(168, 85, 247)  -- Roxo Neon Astral
local COR_VERDE  = Color3.fromRGB(80, 255, 140)  -- Verde Neon
local COR_AZUL   = Color3.fromRGB(56, 189, 248)  -- Azul Celeste
local COR_FUNDO  = Color3.fromRGB(10, 13, 20)    -- Dark Void

-- VARIÁVEIS DE ESTADO
local copiaPersonagem       = nil
local plataformaCeu         = nil
local animTracks            = {}
local currentTarget         = nil
local targetRootPart        = nil
local targetHead            = nil
local diedConn              = nil
local safeSpotCFrame        = nil
local executandoFlashAcao   = false
local lastAutoAttackTick    = 0
local activeForceField      = nil

-- ESTADO DAS TECLAS DE MOVIMENTAÇÃO (WASD + SHIFT + SPACE)
local teclasPressionadas = {
    W     = false,
    A     = false,
    S     = false,
    D     = false,
    Shift = false,
    Space = false,
}

-- ════════════════════════════════════════════════════════════════════════════════
-- SISTEMA DE NOTIFICAÇÕES VISUAIS
-- ════════════════════════════════════════════════════════════════════════════════
local function avisar(titulo, texto, tempo)
    tempo = tempo or 3
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title    = titulo,
            Text     = texto,
            Duration = tempo
        })
    end)
end

-- ════════════════════════════════════════════════════════════════════════════════
-- CRIAÇÃO DA PLATAFORMA CELESTIAL SEGURA (+850 STUDS)
-- ════════════════════════════════════════════════════════════════════════════════
local function obterPlataformaCeu()
    if plataformaCeu and plataformaCeu.Parent then
        return plataformaCeu
    end

    local existing = Workspace:FindFirstChild("PlataformaCeu_AstralV6")
    if existing then
        plataformaCeu = existing
        return plataformaCeu
    end

    local p = Instance.new("Part")
    p.Name         = "PlataformaCeu_AstralV6"
    p.Size         = Vector3.new(20, 2, 20)
    p.CFrame       = CFrame.new(0, -9999, 0)
    p.Anchored     = true
    p.CanCollide   = true
    p.Transparency = 1
    p.Material     = Enum.Material.ForceField
    p.Color        = Color3.fromRGB(168, 85, 247)
    p.Parent       = Workspace
    plataformaCeu  = p
    return plataformaCeu
end
obterPlataformaCeu()

-- ════════════════════════════════════════════════════════════════════════════════
-- BLINDAGEM GOD-SHIELD (CanTouch = false no corpo, CanTouch = true na arma)
-- ════════════════════════════════════════════════════════════════════════════════
local function aplicarBlindagemReal(char)
    if not char then return end

    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            local isToolPart = part:FindFirstAncestorOfClass("Tool") ~= nil
            if not isToolPart then
                pcall(function()
                    part.CanTouch   = false
                    part.CanCollide = false
                end)
            else
                pcall(function()
                    part.CanTouch = true
                end)
            end
        end
    end

    if config.forceFieldAtivo then
        local ff = char:FindFirstChildOfClass("ForceField")
        if not ff then
            ff = Instance.new("ForceField")
            ff.Name = "AstralShield_Protected"
            ff.Visible = false
            ff.Parent = char
        end
        activeForceField = ff
    end
end

local function removerBlindagemReal(char)
    if not char then return end

    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            pcall(function()
                part.CanTouch = true
            end)
        end
    end

    if activeForceField and activeForceField.Parent then
        activeForceField:Destroy()
        activeForceField = nil
    end
end

-- ════════════════════════════════════════════════════════════════════════════════
-- SISTEMA DE ANIMAÇÕES DA CÓPIA (IDLE, WALK, RUN, JUMP)
-- ════════════════════════════════════════════════════════════════════════════════
local function obterAnimIdAtiva(nome)
    local char = LocalPlayer.Character
    if not char then return nil end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return nil end
    local anim = hum:FindFirstChildOfClass("Animator")
    if not anim then return nil end

    for _, track in ipairs(anim:GetPlayingAnimationTracks()) do
        local n = string.lower(track.Name)
        if string.find(n, nome) and track.Animation and track.Animation.AnimationId ~= "" then
            return track.Animation.AnimationId
        end
    end
    return nil
end

local function extrairAnimId(nomeChild, nomeVal)
    local char = LocalPlayer.Character
    if not char then return nil end
    local animate = char:FindFirstChild("Animate")
    if not animate then return nil end
    local folder = animate:FindFirstChild(nomeChild)
    if not folder then return nil end
    local animVal = folder:FindFirstChild(nomeVal) or folder:FindFirstChildOfClass("Animation")
    if animVal and animVal:IsA("Animation") and animVal.AnimationId ~= "" then
        return animVal.AnimationId
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

    local walkId = obterAnimIdAtiva("walk")
        or extrairAnimId("walk", "WalkAnim")
        or runId

    local idleId = obterAnimIdAtiva("idle")
        or extrairAnimId("idle", "Animation1")
        or (isR15 and "rbxassetid://507766666" or "rbxassetid://180435571")

    local jumpId = obterAnimIdAtiva("jump")
        or extrairAnimId("jump", "JumpAnim")
        or (isR15 and "rbxassetid://507765000" or "rbxassetid://125750702")

    pcall(function()
        local aRun = Instance.new("Animation")
        aRun.AnimationId = runId
        animTracks.run = cAnimator:LoadAnimation(aRun)
        animTracks.run.Looped = true
        animTracks.run.Priority = Enum.AnimationPriority.Movement

        local aWalk = Instance.new("Animation")
        aWalk.AnimationId = walkId
        animTracks.walk = cAnimator:LoadAnimation(aWalk)
        animTracks.walk.Looped = true
        animTracks.walk.Priority = Enum.AnimationPriority.Movement

        local aIdle = Instance.new("Animation")
        aIdle.AnimationId = idleId
        animTracks.idle = cAnimator:LoadAnimation(aIdle)
        animTracks.idle.Looped = true
        animTracks.idle.Priority = Enum.AnimationPriority.Idle
        animTracks.idle:Play(0.1)

        local aJump = Instance.new("Animation")
        aJump.AnimationId = jumpId
        animTracks.jump = cAnimator:LoadAnimation(aJump)
        animTracks.jump.Looped = false
        animTracks.jump.Priority = Enum.AnimationPriority.Action
    end)
end

-- ════════════════════════════════════════════════════════════════════════════════
-- SISTEMA DE DETECÇÃO DE INIMIGOS (PARA A TRAVA MANUAL [R])
-- ════════════════════════════════════════════════════════════════════════════════
local function isEnemyAlive(model)
    if not model or not model:IsA("Model") then return false end
    if not model:IsDescendantOf(Workspace) then return false end
    if model == LocalPlayer.Character then return false end
    if copiaPersonagem and model == copiaPersonagem then return false end

    local p = Players:GetPlayerFromCharacter(model)
    if not p then return false end

    local hum = model:FindFirstChildOfClass("Humanoid")
    local rootPart = model:FindFirstChild("HumanoidRootPart") or model:FindFirstChild("Torso")
    local head = model:FindFirstChild("Head") or rootPart

    if not hum or not rootPart or not head then return false end
    if hum.Health <= 0 then return false end

    return true
end

local function clearCurrentTarget()
    if diedConn then
        diedConn:Disconnect()
        diedConn = nil
    end
    currentTarget  = nil
    targetRootPart = nil
    targetHead     = nil
end

local function findNearestEnemy()
    local myPos = nil
    if copiaPersonagem and copiaPersonagem:FindFirstChild("HumanoidRootPart") then
        myPos = copiaPersonagem.HumanoidRootPart.Position
    elseif LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        myPos = LocalPlayer.Character.HumanoidRootPart.Position
    end
    if not myPos then return nil end

    local closestEnemy = nil
    local shortestDist = config.distanciaMaxima

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local model = p.Character
            if isEnemyAlive(model) then
                local root = model:FindFirstChild("HumanoidRootPart") or model:FindFirstChild("Torso")
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

local function calcularCFrameTrava(enemyRoot)
    if not enemyRoot then return nil end

    local dir = enemyRoot.CFrame.LookVector
    local targetPos = nil
    local lookAtPos = nil

    if config.posicaoAlvo == "costas" then
        targetPos = enemyRoot.Position - (dir * config.distanciaRelativa) + Vector3.new(0, config.alturaRelativa, 0)
        lookAtPos = enemyRoot.Position + (dir * 5)
    else
        targetPos = enemyRoot.Position + (dir * config.distanciaRelativa) + Vector3.new(0, config.alturaRelativa, 0)
        lookAtPos = enemyRoot.Position
    end

    return CFrame.lookAt(targetPos, lookAtPos)
end

-- ════════════════════════════════════════════════════════════════════════════════
-- GARANTIR ARMA EQUIPADA
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
-- ALTERNAR MODO ASTRAL (TECLA G)
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
        -- ATIVAR MODO ASTRAL (LIVRE PARA ANDAR NO CHÃO)
        config.travaManualAtiva = false
        clearCurrentTarget()

        local cframeAtual = realRoot.CFrame
        plataformaCeu.CFrame = CFrame.new(cframeAtual.X, config.alturaCeu, cframeAtual.Z)

        charReal.Archivable = true
        copiaPersonagem = charReal:Clone()
        copiaPersonagem.Name = LocalPlayer.Name .. "_AstralWalkClone"

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

        -- Aplica God-Shield no corpo real
        if config.godShieldAtivo then
            aplicarBlindagemReal(charReal)
        end

        -- Fixa o corpo real com segurança no céu
        realHum.PlatformStand = true
        realRoot.AssemblyLinearVelocity = Vector3.zero
        realRoot.AssemblyAngularVelocity = Vector3.zero
        realRoot.CFrame = CFrame.new(cframeAtual.X, config.alturaCeu + 3.5, cframeAtual.Z)

        if atualizarBotoesGUI then atualizarBotoesGUI() end
        avisar("👻 Modo Astral: ATIVADO", "Você está livre para andar (WASD/Espaço)! Use o Mouse ou [Z, X, C, V] para atacar.")
    else
        -- DESATIVAR MODO ASTRAL (RETORNA AO CORPO REAL)
        config.travaManualAtiva = false
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

        removerBlindagemReal(charReal)
        realHum.PlatformStand = false
        camera.CameraSubject = realHum
        plataformaCeu.CFrame = CFrame.new(0, -9999, 0)

        for _, track in pairs(animTracks) do
            pcall(function() track:Stop() track:Destroy() end)
        end
        table.clear(animTracks)

        if atualizarBotoesGUI then atualizarBotoesGUI() end
        avisar("👻 Modo Astral: DESATIVADO", "Retornado ao corpo físico com sucesso.")
    end
end

-- ════════════════════════════════════════════════════════════════════════════════
-- SISTEMA DE FLASH ATTACK / SKILL (MOUSE E TECLAS Z, X, C, V)
-- ════════════════════════════════════════════════════════════════════════════════
local function executarFlashAcao(origem, keyCode)
    if not config.modoAstralAtivo then return end
    if executandoFlashAcao then return end
    if not copiaPersonagem or not copiaPersonagem.Parent then return end

    local cRoot = copiaPersonagem:FindFirstChild("HumanoidRootPart")
    if not cRoot then return end

    local charReal = LocalPlayer.Character
    if not charReal then return end
    local realRoot = charReal:FindFirstChild("HumanoidRootPart")
    local realHum  = charReal:FindFirstChildOfClass("Humanoid")
    if not realRoot or not realHum then return end

    executandoFlashAcao = true

    -- Posição do golpe: onde você está andando com o clone
    local targetCF = cRoot.CFrame
    if config.golpeSubterraneo then
        targetCF = targetCF * CFrame.new(0, -config.offsetSubterraneo, 0)
    end

    -- 1. Oculta temporariamente a cópia para que apenas o corpo real seja visível
    for _, part in ipairs(copiaPersonagem:GetDescendants()) do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
            part.Transparency = 1
        elseif part:IsA("Decal") then
            part.Transparency = 1
        end
    end

    -- 2. Assegura a blindagem God-Shield
    if config.godShieldAtivo then
        aplicarBlindagemReal(charReal)
    end

    -- 3. Torna o corpo real totalmente visível no local exato
    for _, part in ipairs(charReal:GetDescendants()) do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
            part.Transparency = 0
        elseif part:IsA("Decal") then
            part.Transparency = 0
        end
    end

    -- 4. Move o corpo real para a posição do chão
    realHum.PlatformStand = false
    realRoot.AssemblyLinearVelocity = Vector3.zero
    realRoot.AssemblyAngularVelocity = Vector3.zero
    realRoot.CFrame = targetCF

    -- 5. Dispara a ação de combate
    if origem == "Mouse" then
        ensureWeaponEquipped()
        local tool = charReal:FindFirstChildOfClass("Tool")
        if tool then
            pcall(function() tool:Activate() end)
        end
        pcall(function()
            if VirtualUser then
                VirtualUser:CaptureController()
                VirtualUser:ClickButton1(Vector2.new(mouse.X, mouse.Y))
            end
        end)
    elseif keyCode then
        -- Dispara a tecla da skill (Z, X, C, V) no motor do jogo
        pcall(function()
            if keypress then
                keypress(keyCode.Value)
                task.spawn(function()
                    task.wait(0.04)
                    pcall(function() keyrelease(keyCode.Value) end)
                end)
            end
        end)
    end

    -- 6. Duração em milissegundos que o corpo fica visível desferindo o ataque
    local duracaoSec = (origem == "Mouse" and config.delayFlashMouseMs or config.delayFlashSkillMs) / 1000
    task.wait(duracaoSec)

    -- 7. Retorna imediatamente com segurança para o céu celestial (+850 studs)
    local skyX = cRoot.Position.X
    local skyZ = cRoot.Position.Z
    plataformaCeu.CFrame = CFrame.new(skyX, config.alturaCeu, skyZ)

    realHum.PlatformStand = true
    realRoot.AssemblyLinearVelocity = Vector3.zero
    realRoot.AssemblyAngularVelocity = Vector3.zero
    realRoot.CFrame = CFrame.new(skyX, config.alturaCeu + 3.5, skyZ)

    -- 8. Restaura a visibilidade da cópia para continuar andando normalmente
    for _, part in ipairs(copiaPersonagem:GetDescendants()) do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
            part.Transparency = 0
        elseif part:IsA("Decal") then
            part.Transparency = 0
        end
    end

    executandoFlashAcao = false
end

-- ════════════════════════════════════════════════════════════════════════════════
-- CAPTURA DE TECLADO E MOUSE (WASD, SHIFT, SPACE, Z, X, C, V, G, R, T)
-- ════════════════════════════════════════════════════════════════════════════════
UserInputService.InputBegan:Connect(function(input, gpe)
    -- Se o jogador estiver digitando no chat do Roblox, ignora comandos de combate
    if UserInputService:GetFocusedTextBox() ~= nil then
        return
    end

    -- TECLA G: Alternar Modo Astral
    if input.KeyCode == Enum.KeyCode.G then
        alternarModoAstral()
        return
    end

    -- MOVIMENTAÇÃO DO CLONE (WASD + SHIFT + SPACE)
    if input.KeyCode == Enum.KeyCode.W then teclasPressionadas.W = true end
    if input.KeyCode == Enum.KeyCode.A then teclasPressionadas.A = true end
    if input.KeyCode == Enum.KeyCode.S then teclasPressionadas.S = true end
    if input.KeyCode == Enum.KeyCode.D then teclasPressionadas.D = true end
    if input.KeyCode == Enum.KeyCode.LeftShift or input.KeyCode == Enum.KeyCode.RightShift then
        teclasPressionadas.Shift = true
    end
    if input.KeyCode == Enum.KeyCode.Space then
        teclasPressionadas.Space = true
        if config.modoAstralAtivo and copiaPersonagem then
            local cHum = copiaPersonagem:FindFirstChildOfClass("Humanoid")
            if cHum then
                cHum.Jump = true
                if animTracks.jump and not animTracks.jump.IsPlaying then
                    animTracks.jump:Play(0.05)
                end
            end
        end
    end

    -- COMANDOS QUANDO O MODO ASTRAL ESTÁ LIGADO
    if config.modoAstralAtivo then
        -- CLIQUE ESQUERDO DO MOUSE: Ataque Flash
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            task.spawn(executarFlashAcao, "Mouse", nil)
            return
        end

        -- TECLAS DE SKILL [Z], [X], [C], [V]: Execução Quântica da Skill
        if input.KeyCode == Enum.KeyCode.Z or
           input.KeyCode == Enum.KeyCode.X or
           input.KeyCode == Enum.KeyCode.C or
           input.KeyCode == Enum.KeyCode.V then
            task.spawn(executarFlashAcao, input.KeyCode.Name, input.KeyCode)
            return
        end

        -- TECLA [R]: Travar / Destravar manualmente em um jogador
        if input.KeyCode == Enum.KeyCode.R then
            config.travaManualAtiva = not config.travaManualAtiva
            if config.travaManualAtiva then
                local enemy = findNearestEnemy()
                if enemy then
                    currentTarget = enemy
                    targetRootPart = enemy:FindFirstChild("HumanoidRootPart") or enemy:FindFirstChild("Torso")
                    targetHead = enemy:FindFirstChild("Head") or targetRootPart
                    avisar("🎯 Trava Manual: ATIVA", "Travado em " .. enemy.Name .. " (" .. config.posicaoAlvo .. ")")
                else
                    config.travaManualAtiva = false
                    avisar("⚠️ Trava Manual", "Nenhum jogador encontrado no alcance.")
                end
            else
                clearCurrentTarget()
                avisar("🚶 Modo Livre", "Trava desativada. Andando livremente.")
            end
            if atualizarBotoesGUI then atualizarBotoesGUI() end
            return
        end

        -- TECLA [T]: Alternar Frente / Costas na trava
        if input.KeyCode == Enum.KeyCode.T then
            if config.posicaoAlvo == "costas" then
                config.posicaoAlvo = "frente"
            else
                config.posicaoAlvo = "costas"
            end
            avisar("🔄 Posição Alterada", "Posição definida para: " .. string.upper(config.posicaoAlvo))
            if atualizarBotoesGUI then atualizarBotoesGUI() end
            return
        end
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.W then teclasPressionadas.W = false end
    if input.KeyCode == Enum.KeyCode.A then teclasPressionadas.A = false end
    if input.KeyCode == Enum.KeyCode.S then teclasPressionadas.S = false end
    if input.KeyCode == Enum.KeyCode.D then teclasPressionadas.D = false end
    if input.KeyCode == Enum.KeyCode.LeftShift or input.KeyCode == Enum.KeyCode.RightShift then
        teclasPressionadas.Shift = false
    end
    if input.KeyCode == Enum.KeyCode.Space then teclasPressionadas.Space = false end
end)

-- ════════════════════════════════════════════════════════════════════════════════
-- LOOP PRINCIPAL DE MOVIMENTAÇÃO (RENDERSTEPPED / HEARTBEAT)
-- ════════════════════════════════════════════════════════════════════════════════
RunService.RenderStepped:Connect(function(dt)
    if not config.modoAstralAtivo then return end
    if executandoFlashAcao then return end

    if not copiaPersonagem or not copiaPersonagem.Parent then return end
    local cHum  = copiaPersonagem:FindFirstChildOfClass("Humanoid")
    local cRoot = copiaPersonagem:FindFirstChild("HumanoidRootPart")
    if not cHum or not cRoot then return end

    -- Se a trava manual [R] estiver ativa e houver alvo válido
    if config.travaManualAtiva and currentTarget and targetRootPart and targetRootPart.Parent then
        local lockCF = calcularCFrameTrava(targetRootPart)
        if lockCF then
            cHum.PlatformStand = false
            cRoot.AssemblyLinearVelocity = Vector3.zero
            cRoot.AssemblyAngularVelocity = Vector3.zero
            cRoot.CFrame = lockCF
        end
    else
        -- CAMINHADA LIVRE COM O CLONE (WASD + SHIFT)
        cHum.WalkSpeed = teclasPressionadas.Shift and config.velocidadeSprint or config.velocidadePadrao

        local camCF = camera.CFrame
        local forward = Vector3.new(camCF.LookVector.X, 0, camCF.LookVector.Z)
        local right   = Vector3.new(camCF.RightVector.X, 0, camCF.RightVector.Z)

        if forward.Magnitude > 0 then forward = forward.Unit end
        if right.Magnitude > 0 then right = right.Unit end

        local moveDir = Vector3.zero
        if teclasPressionadas.W then moveDir = moveDir + forward end
        if teclasPressionadas.S then moveDir = moveDir - forward end
        if teclasPressionadas.D then moveDir = moveDir + right end
        if teclasPressionadas.A then moveDir = moveDir - right end

        if moveDir.Magnitude > 0 then
            moveDir = moveDir.Unit
            cHum:Move(moveDir, false)

            -- Animações de Movimento
            if teclasPressionadas.Shift then
                if animTracks.run and not animTracks.run.IsPlaying then animTracks.run:Play(0.1) end
                if animTracks.walk and animTracks.walk.IsPlaying then animTracks.walk:Stop(0.1) end
                if animTracks.idle and animTracks.idle.IsPlaying then animTracks.idle:Stop(0.1) end
            else
                if animTracks.walk and not animTracks.walk.IsPlaying then animTracks.walk:Play(0.1) end
                if animTracks.run and animTracks.run.IsPlaying then animTracks.run:Stop(0.1) end
                if animTracks.idle and animTracks.idle.IsPlaying then animTracks.idle:Stop(0.1) end
            end
        else
            cHum:Move(Vector3.zero, false)
            if animTracks.idle and not animTracks.idle.IsPlaying then animTracks.idle:Play(0.1) end
            if animTracks.walk and animTracks.walk.IsPlaying then animTracks.walk:Stop(0.1) end
            if animTracks.run and animTracks.run.IsPlaying then animTracks.run:Stop(0.1) end
        end
    end

    -- MANTÉM O CORPO REAL E A PLATAFORMA NO CÉU EXATAMENTE ACIMA DA CÓPIA (+850 STUDS)
    local skyX = cRoot.Position.X
    local skyZ = cRoot.Position.Z
    plataformaCeu.CFrame = CFrame.new(skyX, config.alturaCeu, skyZ)

    local charReal = LocalPlayer.Character
    if charReal then
        local realRoot = charReal:FindFirstChild("HumanoidRootPart")
        local realHum  = charReal:FindFirstChildOfClass("Humanoid")
        if realRoot and realHum then
            realHum.PlatformStand = true
            realRoot.AssemblyLinearVelocity = Vector3.zero
            realRoot.AssemblyAngularVelocity = Vector3.zero
            realRoot.CFrame = CFrame.new(skyX, config.alturaCeu + 3.5, skyZ)
        end
    end
end)

-- ════════════════════════════════════════════════════════════════════════════════
-- INTERFACE GRÁFICA HUD V6.0 COMPLETA
-- ════════════════════════════════════════════════════════════════════════════════
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ModoAstralV6_GUI"
screenGui.ResetOnSpawn = false
pcall(function() screenGui.Parent = game:GetService("CoreGui") end)
if not screenGui.Parent then screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 310, 0, 410)
mainFrame.Position = UDim2.new(0.02, 0, 0.25, 0)
mainFrame.BackgroundColor3 = COR_FUNDO
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 10)
mainCorner.Parent = mainFrame

local mainStroke = Instance.new("UIStroke")
mainStroke.Color = COR_ACCENT
mainStroke.Thickness = 1.5
mainStroke.Parent = mainFrame

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 0, 38)
titleLabel.BackgroundColor3 = Color3.fromRGB(15, 20, 30)
titleLabel.Text = "👻 ASTRAL V6.0 — FREE WALK & SKILLS"
titleLabel.TextColor3 = COR_ACCENT
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 13
titleLabel.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 10)
titleCorner.Parent = titleLabel

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(0.9, 0, 0, 42)
statusLabel.Position = UDim2.new(0.05, 0, 0.11, 0)
statusLabel.BackgroundColor3 = Color3.fromRGB(16, 20, 28)
statusLabel.Text = "Modo Astral: DESATIVADO [G]\nLivre para andar pelo mapa"
statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
statusLabel.Font = Enum.Font.GothamMedium
statusLabel.TextSize = 11
statusLabel.Parent = mainFrame

local statusCorner = Instance.new("UICorner")
statusCorner.CornerRadius = UDim.new(0, 6)
statusCorner.Parent = statusLabel

-- BOTÃO 1: MODO ASTRAL (G)
local astralBtn = Instance.new("TextButton")
astralBtn.Size = UDim2.new(0.9, 0, 0, 34)
astralBtn.Position = UDim2.new(0.05, 0, 0.23, 0)
astralBtn.BackgroundColor3 = Color3.fromRGB(24, 30, 44)
astralBtn.Text = "👻 Modo Astral: DESLIGADO [G]"
astralBtn.TextColor3 = Color3.fromRGB(220, 220, 220)
astralBtn.Font = Enum.Font.GothamBold
astralBtn.TextSize = 12
astralBtn.Parent = mainFrame
Instance.new("UICorner", astralBtn).CornerRadius = UDim.new(0, 6)

astralBtn.MouseButton1Click:Connect(alternarModoAstral)

-- BOTÃO 2: TRAVA MANUAL EM ALVO (R)
local lockBtn = Instance.new("TextButton")
lockBtn.Size = UDim2.new(0.9, 0, 0, 34)
lockBtn.Position = UDim2.new(0.05, 0, 0.33, 0)
lockBtn.BackgroundColor3 = Color3.fromRGB(24, 30, 44)
lockBtn.Text = "🎯 Trava em Alvo: DESLIGADA [R]"
lockBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
lockBtn.Font = Enum.Font.GothamBold
lockBtn.TextSize = 12
lockBtn.Parent = mainFrame
Instance.new("UICorner", lockBtn).CornerRadius = UDim.new(0, 6)

lockBtn.MouseButton1Click:Connect(function()
    if not config.modoAstralAtivo then
        avisar("Aviso", "Ligue primeiro o Modo Astral [G]!")
        return
    end
    config.travaManualAtiva = not config.travaManualAtiva
    if config.travaManualAtiva then
        local enemy = findNearestEnemy()
        if enemy then
            currentTarget = enemy
            targetRootPart = enemy:FindFirstChild("HumanoidRootPart") or enemy:FindFirstChild("Torso")
            targetHead = enemy:FindFirstChild("Head") or targetRootPart
        else
            config.travaManualAtiva = false
            avisar("Alvo", "Nenhum jogador por perto.")
        end
    else
        clearCurrentTarget()
    end
    atualizarBotoesGUI()
end)

-- BOTÃO 3: POSIÇÃO FRENTE / COSTAS (T)
local posBtn = Instance.new("TextButton")
posBtn.Size = UDim2.new(0.9, 0, 0, 34)
posBtn.Position = UDim2.new(0.05, 0, 0.43, 0)
posBtn.BackgroundColor3 = Color3.fromRGB(24, 30, 44)
posBtn.Text = "🔄 Posição Trava: COSTAS [T]"
posBtn.TextColor3 = COR_AZUL
posBtn.Font = Enum.Font.GothamBold
posBtn.TextSize = 12
posBtn.Parent = mainFrame
Instance.new("UICorner", posBtn).CornerRadius = UDim.new(0, 6)

posBtn.MouseButton1Click:Connect(function()
    if config.posicaoAlvo == "costas" then
        config.posicaoAlvo = "frente"
    else
        config.posicaoAlvo = "costas"
    end
    atualizarBotoesGUI()
end)

-- BOTÃO 4: GOD-SHIELD ANTI-DANO
local shieldBtn = Instance.new("TextButton")
shieldBtn.Size = UDim2.new(0.9, 0, 0, 34)
shieldBtn.Position = UDim2.new(0.05, 0, 0.53, 0)
shieldBtn.BackgroundColor3 = Color3.fromRGB(24, 30, 44)
shieldBtn.Text = "🛡️ God-Shield Anti-Dano: ATIVO"
shieldBtn.TextColor3 = COR_VERDE
shieldBtn.Font = Enum.Font.GothamBold
shieldBtn.TextSize = 12
shieldBtn.Parent = mainFrame
Instance.new("UICorner", shieldBtn).CornerRadius = UDim.new(0, 6)

shieldBtn.MouseButton1Click:Connect(function()
    config.godShieldAtivo = not config.godShieldAtivo
    atualizarBotoesGUI()
end)

-- PAINEL INFORMATIVO DE TECLAS
local infoBox = Instance.new("TextLabel")
infoBox.Size = UDim2.new(0.9, 0, 0, 120)
infoBox.Position = UDim2.new(0.05, 0, 0.64, 0)
infoBox.BackgroundColor3 = Color3.fromRGB(14, 18, 26)
infoBox.Text = "⌨️ GUIA DE COMBATE:\n• [W,A,S,D] = Andar Livre com o Clone\n• [Shift] = Correr | [Espaço] = Pular\n• [Clique Esquerdo] = Ataque Rápido Flash\n• [Z, X, C, V] = Soltar Skills do Jogo\n• [G] = Ligar/Desligar Modo Astral\n• [F8] = Ocultar/Mostrar Menu"
infoBox.TextColor3 = Color3.fromRGB(180, 190, 210)
infoBox.Font = Enum.Font.Gotham
infoBox.TextSize = 10
infoBox.TextWrapped = true
infoBox.Parent = mainFrame
Instance.new("UICorner", infoBox).CornerRadius = UDim.new(0, 6)

atualizarBotoesGUI = function()
    if config.modoAstralAtivo then
        astralBtn.Text = "👻 Modo Astral: ATIVADO [G]"
        astralBtn.TextColor3 = COR_VERDE
        if config.travaManualAtiva and currentTarget then
            statusLabel.Text = "Alvo: " .. currentTarget.Name .. " ● TRAVADO (" .. string.upper(config.posicaoAlvo) .. ")"
            statusLabel.TextColor3 = COR_VERDE
        else
            statusLabel.Text = "Modo Astral: ATIVO ● ANDANDO LIVRE\nUse Mouse ou [Z,X,C,V] para atacar"
            statusLabel.TextColor3 = COR_AZUL
        end
    else
        astralBtn.Text = "👻 Modo Astral: DESLIGADO [G]"
        astralBtn.TextColor3 = Color3.fromRGB(220, 220, 220)
        statusLabel.Text = "Modo Astral: DESATIVADO [G]\nLivre para andar pelo mapa"
        statusLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
    end

    if config.travaManualAtiva then
        lockBtn.Text = "🎯 Trava em Alvo: ATIVA [R]"
        lockBtn.TextColor3 = COR_VERDE
    else
        lockBtn.Text = "🎯 Trava em Alvo: DESLIGADA [R]"
        lockBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
    end

    posBtn.Text = "🔄 Posição Trava: " .. string.upper(config.posicaoAlvo) .. " [T]"
    shieldBtn.Text = config.godShieldAtivo and "🛡️ God-Shield Anti-Dano: ATIVO" or "🛡️ God-Shield Anti-Dano: DESLIGADO"
    shieldBtn.TextColor3 = config.godShieldAtivo and COR_VERDE or Color3.fromRGB(255, 90, 90)
end

-- TECLA [F8]: MOSTRAR / OCULTAR GUI
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.F8 then
        mainFrame.Visible = not mainFrame.Visible
    end
end)

-- LIMPEZA AO MORRER / RENASCER
LocalPlayer.CharacterAdded:Connect(function()
    if config.modoAstralAtivo then
        alternarModoAstral()
    end
end)

atualizarBotoesGUI()
avisar("👻 Astral V6.0 Carregado!", "Pressione [G] para ativar o modo livre. Clique ou use [Z,X,C,V] para atacar!", 5)
print("[ASTRAL V6.0] Script carregado com sucesso. Andar livre + Skills Z, X, C, V configuradas!")
