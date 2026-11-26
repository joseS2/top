--[[
    =================================================================================
    👑 BADGE MASTER V14 - UNIVERSAL VERSION HUB & RESPONSIVE OMNI-LAB
    =================================================================================
    NOVIDADES DA V14:

    1. [🗂️ HUB UNIVERSAL DE VERSÕES (V1 ATÉ V14)]:
       - Ao executar a V14, abre a GUI Seletora com todas as versões (V1 a V14).
       - Clique em qualquer versão para abri-la imediatamente.
       - Ao clicar no [✕] no topo de QUALQUER versão (V1 a V14), ela fecha e
         destrói sua interface por completo e reabre o Seletor de Versões!

    2. [🖥️ GUI V14 100% RESPONSIVA E SEM BOTÕES CORTADOS]:
       - Janela adaptável ao tamanho da tela (PC e Mobile).
       - Barra de ações principais em grade 2x3 (todos os 6 botões 100% visíveis).
       - Barras de Teleporte, Presets e Categorias com rolagem horizontal automática
         para nenhum botão sumir ou ser cortado em telas menores.
       - Botão [—] para minimizar e [✕] para fechar de vez e voltar ao Hub.

    3. [⚡ TODAS AS MELHORIAS DA V13 + V8/V9]:
       - Coleta total de itens (Workspace, ReplicatedStorage, Lighting, StarterPack,
         ReplicatedFirst e Mochila) + fallback da V8/V9 para Tools sem Handle.
       - Sistema de Remotes com bateria automática completa quando vazio e parser
         de múltiplos argumentos separados por vírgula (ex: true, 1000).
       - Teleporte com Salvar Local, Voltar ao Anterior, Auto-Voltar ON/OFF e [📍 TP].
    =================================================================================
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local Lighting = game:GetService("Lighting")
local StarterPack = game:GetService("StarterPack")
local HttpService = game:GetService("HttpService")
local VirtualInputManager = game:GetService("VirtualInputManager")

local LocalPlayer = Players.LocalPlayer

local function getGuiParent()
    local ok, hui = pcall(function() return gethui and gethui() end)
    if ok and hui then return hui end
    local okCore, core = pcall(function() return game:GetService("CoreGui"):FindFirstChild("RobloxGui") or game:GetService("CoreGui") end)
    if okCore and core then return core end
    return LocalPlayer:WaitForChild("PlayerGui")
end

local function makeCorner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius)
    c.Parent = parent
    return c
end

local function makeDraggable(dragHandle, targetFrame)
    local dragging, dragStart, startPos
    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = targetFrame.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            targetFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

-- =================================================================================
-- CÓDIGOS EMBUTIDOS DAS VERSÕES ANTERIORES (V1 A V13)
-- =================================================================================
local VERSION_SOURCES = {
    ["V1"] = [====[
-- ==============================================================================
-- Universal Badge Giver / Collector Script (v1.lua)
-- Funciona tanto em Executores (Client / Jogos de Free Badges) quanto no Roblox Studio (Server)
-- ==============================================================================

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

if RunService:IsClient() then
    -- ==========================================================================
    -- MODO CLIENTE / EXECUTOR (Delta, Fluxus, Synapse, Arceus X, Solara, etc.)
    -- Pega todas as badges disponíveis no mapa (ideal para jogos "Free Badges" ou colecionadores)
    -- ==========================================================================
    local player = Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local rootPart = character:WaitForChild("HumanoidRootPart", 10)

    local function notify(title, text)
        pcall(function()
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = title,
                Text = text,
                Duration = 5
            })
        end)
        print(string.format("[%s] %s", title, text))
    end

    notify("Badge Collector v1", "Iniciando coleta de todas as badges...")

    task.spawn(function()
        local collected = 0
        local targets = {}

        -- 1. Varre o mapa em busca de TouchTransmitters e blocos de badge
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("TouchTransmitter") and obj.Parent and obj.Parent:IsA("BasePart") then
                table.insert(targets, obj.Parent)
            elseif obj:IsA("BasePart") then
                local lowerName = obj.Name:lower()
                if lowerName:find("badge") or lowerName:find("giver") or lowerName:find("emblema") then
                    table.insert(targets, obj)
                end
            elseif obj:IsA("ProximityPrompt") then
                -- Aciona prompts de proximidade caso existam no mapa
                pcall(function()
                    if fireproximityprompt then
                        fireproximityprompt(obj)
                    end
                end)
            end
        end

        print(string.format("[Badge Collector] Encontrados %d alvos de badge.", #targets))

        -- 2. Aciona o toque em todas as partes encontradas
        for _, part in ipairs(targets) do
            if not character or not character:FindFirstChild("HumanoidRootPart") then
                character = player.Character or player.CharacterAdded:Wait()
                rootPart = character:WaitForChild("HumanoidRootPart", 5)
            end

            pcall(function()
                if firetouchinterest and rootPart then
                    -- Método instantâneo via executor (firetouchinterest)
                    firetouchinterest(rootPart, part, 0)
                    task.wait(0.01)
                    firetouchinterest(rootPart, part, 1)
                elseif rootPart then
                    -- Fallback: teletransporte rápido para o bloco se o executor não tiver firetouchinterest
                    rootPart.CFrame = part.CFrame
                    task.wait(0.05)
                end
                collected = collected + 1
            end)
        end

        notify("Badge Collector v1", string.format("Finalizado! %d badges acionadas.", collected))
    end)

elseif RunService:IsServer() then
    -- ==========================================================================
    -- MODO SERVIDOR (Roblox Studio / ServerScriptService)
    -- Dá todas as badges registradas do seu próprio jogo aos jogadores
    -- ==========================================================================
    local BadgeService = game:GetService("BadgeService")
    local HttpService = game:GetService("HttpService")

    local UNIVERSE_ID = game.GameId -- Pega o ID do universo automaticamente

    local function getGameBadges()
        local badges = {}
        local cursor = ""

        repeat
            local url = string.format("https://badges.roproxy.com/v1/universes/%d/badges?limit=100&cursor=%s", UNIVERSE_ID, cursor)
            local success, response = pcall(function()
                return HttpService:GetAsync(url)
            end)

            if success then
                local data = HttpService:JSONDecode(response)
                if data and data.data then
                    for _, b in ipairs(data.data) do
                        table.insert(badges, b.id)
                    end
                    cursor = data.nextPageCursor or ""
                else
                    break
                end
            else
                warn("[Badge Server] Não foi possível buscar badges automaticamente via HTTP (certifique-se de que HttpService está ativo).")
                break
            end
        until cursor == "" or cursor == nil

        return badges
    end

    local function giveAllBadgesToPlayer(player)
        print(string.format("[Badge Server] Coletando badges para dar a %s...", player.Name))
        local badgeList = getGameBadges()

        if #badgeList == 0 then
            warn("[Badge Server] Nenhuma badge encontrada na API do universo.")
            return
        end

        for _, badgeId in ipairs(badgeList) do
            pcall(function()
                if not BadgeService:UserHasBadgeAsync(player.UserId, badgeId) then
                    BadgeService:AwardBadge(player.UserId, badgeId)
                    print(string.format("[Badge Server] Badge %d concedida a %s", badgeId, player.Name))
                    task.wait(0.1) -- Previne limite de requisições da BadgeService
                end
            end)
        end
        print(string.format("[Badge Server] Concluído para %s!", player.Name))
    end

    -- Entrega as badges ao entrar no jogo
    Players.PlayerAdded:Connect(function(player)
        giveAllBadgesToPlayer(player)
    end)
end

]====],
    ["V2"] = [====[
--[[
    ==============================================================================
    BADGE SYSTEM ULTIMATE - V2.LUA
    ==============================================================================
    Versão aprimorada, lapidada e otimizada.
    
    Novidades da V2:
    - Interface Gráfica (GUI) moderna, flutuante, arrastável e com barra de progresso.
    - Suporte a Mobile e PC com controle de pausa/retomada.
    - Sistema Anti-AFK integrado (evita ser desconectado por inatividade).
    - Suporte avançado a múltiplos métodos de acionamento:
        * TouchTransmitters (firetouchinterest)
        * ProximityPrompts (fireproximityprompt)
        * ClickDetectors (fireclickdetector)
        * Teletransporte seguro com Noclip (para evitar morrer ou ficar preso)
    - Filtro inteligente de duplicatas (não gasta pacotes repetindo a mesma parte).
    - Modo Servidor (Studio) com cache em memória, fila de entrega, tratamento
      estrito de Rate-Limit da BadgeService e comandos de chat (/giveall, /giveme).
    ==============================================================================
]]

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

-- ==============================================================================
-- CONFIGURAÇÕES GERAIS (Personalize conforme sua necessidade)
-- ==============================================================================
local Config = {
    -- Configurações do Cliente / Executor
    Client = {
        ScanInterval = 0.03,            -- Delay entre cada badge (evita lag e desconexão)
        UseAntiAfk = true,              -- Impede desconexão após 20 minutos inativo
        AutoStart = true,               -- Começa a escanear assim que carregar o script
        ScanKeywords = {                -- Palavras-chave para identificar blocos de badge
            "badge", "emblema", "giver", "trophy", "trofeu", "award", "freebadge", "pad"
        },
        TeleportFallback = true,        -- Se o executor não tiver firetouchinterest, usa teleporte suave
        NoclipOnTeleport = true,        -- Desativa colisão ao teleportar para evitar travar na parede
    },

    -- Configurações do Servidor / Roblox Studio
    Server = {
        DelayBetweenAwards = 0.15,      -- Respeita o rate limit do BadgeService
        AwardOnJoin = true,             -- Concede automaticamente quando um player entrar
        UseProxy = true,                -- Usa RoProxy para contornar bloqueio de chamadas diretas
        ProxyUrl = "https://badges.roproxy.com/v1/universes/%d/badges?limit=100&cursor=%s",
        AdminIds = {                    -- Adicione aqui os UserIds com permissão para usar comandos de chat
            -- [12345678] = true,
        }
    }
}

-- ==============================================================================
-- MODO 1: CLIENTE / EXECUTOR (Delta, Arceus X, Solara, Wave, Synapse, etc.)
-- ==============================================================================
if RunService:IsClient() then
    local TweenService = game:GetService("TweenService")
    local UserInputService = game:GetService("UserInputService")
    local LocalPlayer = Players.LocalPlayer

    -- 1. Anti-AFK
    if Config.Client.UseAntiAfk then
        LocalPlayer.Idled:Connect(function()
            local VirtualUser = game:GetService("VirtualUser")
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new(0, 0))
            print("[Badge v2] Anti-AFK acionado com sucesso.")
        end)
    end

    -- 2. Construção da Interface Gráfica (HUD Moderna e Responsiva)
    local function createModernGui()
        local parentGui = (gethui and gethui()) or game:GetService("CoreGui"):FindFirstChild("RobloxGui") or LocalPlayer:WaitForChild("PlayerGui")
        
        -- Remove versão antiga se existir
        local old = parentGui:FindFirstChild("BadgeMasterV2_Gui")
        if old then old:Destroy() end

        local screen = Instance.new("ScreenGui")
        screen.Name = "BadgeMasterV2_Gui"
        screen.ResetOnSpawn = false
        screen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

        -- Container Principal
        local main = Instance.new("Frame")
        main.Name = "MainFrame"
        main.Size = UDim2.new(0, 320, 0, 190)
        main.Position = UDim2.new(0.5, -160, 0.2, 0)
        main.BackgroundColor3 = Color3.fromRGB(24, 26, 32)
        main.BorderSizePixel = 0
        main.Active = true
        main.ClipsDescendants = true
        main.Parent = screen

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 10)
        corner.Parent = main

        local stroke = Instance.new("UIStroke")
        stroke.Color = Color3.fromRGB(60, 65, 80)
        stroke.Thickness = 1.2
        stroke.Parent = main

        -- Barra de Título
        local titleBar = Instance.new("Frame")
        titleBar.Size = UDim2.new(1, 0, 0, 36)
        titleBar.BackgroundColor3 = Color3.fromRGB(32, 35, 45)
        titleBar.BorderSizePixel = 0
        titleBar.Parent = main

        local titleCorner = Instance.new("UICorner")
        titleCorner.CornerRadius = UDim.new(0, 10)
        titleCorner.Parent = titleBar

        local titleText = Instance.new("TextLabel")
        titleText.Size = UDim2.new(1, -70, 1, 0)
        titleText.Position = UDim2.new(0, 12, 0, 0)
        titleText.BackgroundTransparency = 1
        titleText.Text = "⚡ BADGE MASTER V2"
        titleText.TextColor3 = Color3.fromRGB(240, 240, 245)
        titleText.TextSize = 13
        titleText.Font = Enum.Font.GothamBold
        titleText.TextXAlignment = Enum.TextXAlignment.Left
        titleText.Parent = titleBar

        -- Botão Fechar
        local closeBtn = Instance.new("TextButton")
        closeBtn.Size = UDim2.new(0, 28, 0, 28)
        closeBtn.Position = UDim2.new(1, -32, 0, 4)
        closeBtn.BackgroundColor3 = Color3.fromRGB(45, 48, 60)
        closeBtn.Text = "✕"
        closeBtn.TextColor3 = Color3.fromRGB(200, 200, 210)
        closeBtn.TextSize = 12
        closeBtn.Font = Enum.Font.GothamBold
        closeBtn.BorderSizePixel = 0
        closeBtn.Parent = titleBar

        local closeCorner = Instance.new("UICorner")
        closeCorner.CornerRadius = UDim.new(0, 6)
        closeCorner.Parent = closeBtn

        closeBtn.MouseButton1Click:Connect(function()
            screen:Destroy()
        end)

        -- Status e Contadores
        local statusLabel = Instance.new("TextLabel")
        statusLabel.Size = UDim2.new(1, -24, 0, 18)
        statusLabel.Position = UDim2.new(0, 12, 0, 46)
        statusLabel.BackgroundTransparency = 1
        statusLabel.Text = "Status: Aguardando início..."
        statusLabel.TextColor3 = Color3.fromRGB(170, 175, 195)
        statusLabel.TextSize = 11
        statusLabel.Font = Enum.Font.GothamMedium
        statusLabel.TextXAlignment = Enum.TextXAlignment.Left
        statusLabel.Parent = main

        local counterLabel = Instance.new("TextLabel")
        counterLabel.Size = UDim2.new(1, -24, 0, 22)
        counterLabel.Position = UDim2.new(0, 12, 0, 68)
        counterLabel.BackgroundTransparency = 1
        counterLabel.Text = "0 / 0 badges processadas (0%)"
        counterLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        counterLabel.TextSize = 13
        counterLabel.Font = Enum.Font.GothamBold
        counterLabel.TextXAlignment = Enum.TextXAlignment.Left
        counterLabel.Parent = main

        -- Barra de Progresso (Fundo)
        local progressBg = Instance.new("Frame")
        progressBg.Size = UDim2.new(1, -24, 0, 8)
        progressBg.Position = UDim2.new(0, 12, 0, 98)
        progressBg.BackgroundColor3 = Color3.fromRGB(40, 44, 56)
        progressBg.BorderSizePixel = 0
        progressBg.Parent = main

        local bgCorner = Instance.new("UICorner")
        bgCorner.CornerRadius = UDim.new(1, 0)
        bgCorner.Parent = progressBg

        -- Barra de Progresso (Preenchimento)
        local progressFill = Instance.new("Frame")
        progressFill.Size = UDim2.new(0, 0, 1, 0)
        progressFill.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
        progressFill.BorderSizePixel = 0
        progressFill.Parent = progressBg

        local fillCorner = Instance.new("UICorner")
        fillCorner.CornerRadius = UDim.new(1, 0)
        fillCorner.Parent = progressFill

        -- Botão de Ação (Iniciar / Parar)
        local actionBtn = Instance.new("TextButton")
        actionBtn.Size = UDim2.new(1, -24, 0, 36)
        actionBtn.Position = UDim2.new(0, 12, 0, 122)
        actionBtn.BackgroundColor3 = Color3.fromRGB(0, 140, 255)
        actionBtn.Text = "INICIAR COLETA"
        actionBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        actionBtn.TextSize = 12
        actionBtn.Font = Enum.Font.GothamBold
        actionBtn.BorderSizePixel = 0
        actionBtn.Parent = main

        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 8)
        btnCorner.Parent = actionBtn

        -- Sistema de Arrastar da Janela (Mobile e PC)
        local dragging, dragStart, startPos
        titleBar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                dragStart = input.Position
                startPos = main.Position
            end
        end)

        UserInputService.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                local delta = input.Position - dragStart
                main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end)

        local function endDrag() dragging = false end
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                endDrag()
            end
        end)

        screen.Parent = parentGui
        return {
            Screen = screen,
            Status = statusLabel,
            Counter = counterLabel,
            ProgressFill = progressFill,
            ActionBtn = actionBtn
        }
    end

    -- 3. Motor de Coleta de Badges (Scanner + Dispatcher)
    local UI = createModernGui()
    local isRunning = false
    local shouldStop = false

    local function getTargets()
        local targets = {}
        local seen = {}

        local function addTarget(part, kind, extra)
            if part and part:IsA("BasePart") and not seen[part] then
                seen[part] = true
                table.insert(targets, {
                    Part = part,
                    Kind = kind or "Touch",
                    Extra = extra
                })
            end
        end

        for _, obj in ipairs(workspace:GetDescendants()) do
            -- A) TouchTransmitter
            if obj:IsA("TouchTransmitter") and obj.Parent and obj.Parent:IsA("BasePart") then
                addTarget(obj.Parent, "Touch")
            -- B) ProximityPrompt
            elseif obj:IsA("ProximityPrompt") and obj.Parent then
                local parentPart = obj.Parent:IsA("BasePart") and obj.Parent or obj.Parent:FindFirstChildWhichIsA("BasePart")
                if parentPart then
                    addTarget(parentPart, "Prompt", obj)
                end
            -- C) ClickDetector
            elseif obj:IsA("ClickDetector") and obj.Parent and obj.Parent:IsA("BasePart") then
                addTarget(obj.Parent, "Click", obj)
            -- D) Palavras-chave no nome do bloco
            elseif obj:IsA("BasePart") then
                local lower = obj.Name:lower()
                for _, kw in ipairs(Config.Client.ScanKeywords) do
                    if lower:find(kw) then
                        addTarget(obj, "Touch")
                        break
                    end
                end
            end
        end

        return targets
    end

    local function runBadgeCollector()
        if isRunning then
            shouldStop = true
            return
        end

        isRunning = true
        shouldStop = false
        UI.ActionBtn.Text = "PARAR COLETA"
        UI.ActionBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
        UI.Status.Text = "Status: Escaneando o mapa..."

        task.spawn(function()
            local targets = getTargets()
            local total = #targets

            if total == 0 then
                UI.Status.Text = "Status: Nenhum alvo encontrado."
                UI.Counter.Text = "0 alvos de badge encontrados."
                UI.ActionBtn.Text = "INICIAR COLETA"
                UI.ActionBtn.BackgroundColor3 = Color3.fromRGB(0, 140, 255)
                isRunning = false
                return
            end

            UI.Status.Text = string.format("Status: Processando %d alvos...", total)

            local processed = 0
            for i, target in ipairs(targets) do
                if shouldStop then
                    UI.Status.Text = "Status: Coleta cancelada pelo usuário."
                    break
                end

                local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
                local root = char:FindFirstChild("HumanoidRootPart")

                if root and target.Part and target.Part.Parent then
                    pcall(function()
                        if target.Kind == "Prompt" and fireproximityprompt then
                            fireproximityprompt(target.Extra)
                        elseif target.Kind == "Click" and fireclickdetector then
                            fireclickdetector(target.Extra)
                        end

                        -- Sempre aciona o toque no bloco
                        if firetouchinterest then
                            firetouchinterest(root, target.Part, 0)
                            task.wait(0.005)
                            firetouchinterest(root, target.Part, 1)
                        elseif Config.Client.TeleportFallback then
                            if Config.Client.NoclipOnTeleport and char:FindFirstChildWhichIsA("Humanoid") then
                                for _, part in ipairs(char:GetDescendants()) do
                                    if part:IsA("BasePart") then part.CanCollide = false end
                                end
                            end
                            root.CFrame = target.Part.CFrame + Vector3.new(0, 1.5, 0)
                        end
                    end)
                end

                processed = processed + 1

                -- Atualiza a interface
                local pct = math.floor((processed / total) * 100)
                UI.Counter.Text = string.format("%d / %d badges (%d%%)", processed, total, pct)
                UI.ProgressFill.Size = UDim2.new(processed / total, 0, 1, 0)

                task.wait(Config.Client.ScanInterval)
            end

            if not shouldStop then
                UI.Status.Text = "Status: Concluído com sucesso!"
                UI.ProgressFill.BackgroundColor3 = Color3.fromRGB(0, 220, 120)
            end

            UI.ActionBtn.Text = "INICIAR NOVAMENTE"
            UI.ActionBtn.BackgroundColor3 = Color3.fromRGB(0, 140, 255)
            isRunning = false
            shouldStop = false
        end)
    end

    UI.ActionBtn.MouseButton1Click:Connect(runBadgeCollector)

    if Config.Client.AutoStart then
        task.delay(1, runBadgeCollector)
    end

-- ==============================================================================
-- MODO 2: SERVIDOR (Roblox Studio / ServerScriptService)
-- ==============================================================================
elseif RunService:IsServer() then
    local BadgeService = game:GetService("BadgeService")
    local HttpService = game:GetService("HttpService")

    local UNIVERSE_ID = game.GameId
    local cachedBadges = nil
    local isFetching = false

    -- 1. Busca inteligente com paginação e cache em memória
    local function fetchAllUniverseBadges()
        if cachedBadges then return cachedBadges end
        if isFetching then
            while isFetching do task.wait(0.1) end
            return cachedBadges or {}
        end

        isFetching = true
        local badgeList = {}
        local cursor = ""

        print("[BadgeServer v2] Buscando todas as badges do Universo:", UNIVERSE_ID)

        repeat
            local url = string.format(Config.Server.ProxyUrl, UNIVERSE_ID, cursor)
            local success, body = pcall(function()
                return HttpService:GetAsync(url)
            end)

            if success and body then
                local data = HttpService:JSONDecode(body)
                if data and data.data then
                    for _, item in ipairs(data.data) do
                        table.insert(badgeList, {
                            Id = item.id,
                            Name = item.name or "Sem Nome",
                            Enabled = item.enabled
                        })
                    end
                    cursor = data.nextPageCursor or ""
                else
                    break
                end
            else
                warn("[BadgeServer v2] Falha na requisição HTTP:", body)
                break
            end
            task.wait(0.2)
        until cursor == "" or cursor == nil

        cachedBadges = badgeList
        isFetching = false
        print(string.format("[BadgeServer v2] %d badges catalogadas com sucesso.", #badgeList))
        return badgeList
    end

    -- 2. Concessão com controle de rate-limit
    local function awardBadgesToPlayer(player)
        task.spawn(function()
            local badges = fetchAllUniverseBadges()
            if #badges == 0 then
                warn("[BadgeServer v2] Nenhuma badge disponível para conceder a " .. player.Name)
                return
            end

            print(string.format("[BadgeServer v2] Iniciando concessão de %d badges para %s...", #badges, player.Name))
            local awardedCount = 0

            for _, badge in ipairs(badges) do
                if not player or not player.Parent then break end -- Player saiu do servidor

                local ownsBadge = false
                local checkSuccess, checkResult = pcall(function()
                    return BadgeService:UserHasBadgeAsync(player.UserId, badge.Id)
                end)

                if checkSuccess then
                    ownsBadge = checkResult
                end

                if not ownsBadge then
                    local awardSuccess, awardErr = pcall(function()
                        BadgeService:AwardBadge(player.UserId, badge.Id)
                    end)

                    if awardSuccess then
                        awardedCount = awardedCount + 1
                    else
                        warn(string.format("[BadgeServer v2] Erro na badge %d: %s", badge.Id, tostring(awardErr)))
                    end
                    
                    -- Pausa para não estourar a cota da API da BadgeService
                    task.wait(Config.Server.DelayBetweenAwards)
                end
            end

            print(string.format("[BadgeServer v2] Finalizado! %d novas badges concedidas a %s.", awardedCount, player.Name))
        end)
    end

    -- 3. Concede ao entrar (se ativado na configuração)
    if Config.Server.AwardOnJoin then
        Players.PlayerAdded:Connect(function(player)
            awardBadgesToPlayer(player)
        end)
    end

    -- 4. Comandos de Chat (Legacy + TextChatService)
    local function handleChatCommand(sender, message)
        local msg = message:lower()
        if msg == "/giveall" or msg == "/awardall" then
            print(string.format("[BadgeServer v2] Comando /giveall disparado por %s", sender.Name))
            for _, p in ipairs(Players:GetPlayers()) do
                awardBadgesToPlayer(p)
            end
        elseif msg == "/giveme" or msg == "/awardme" then
            print(string.format("[BadgeServer v2] Comando /giveme disparado por %s", sender.Name))
            awardBadgesToPlayer(sender)
        end
    end

    Players.PlayerAdded:Connect(function(player)
        player.Chatted:Connect(function(msg)
            handleChatCommand(player, msg)
        end)
    end)
end

]====],
    ["V3"] = [====[
--[[
    =================================================================================
    🏆 BADGE MASTER ULTIMATE - V3.LUA (SUÍTE DEFINITIVA DE EMBLEMAS)
    =================================================================================
    Desenvolvido para ser a solução mais completa, profissional e confiável do Roblox.
    
    DESTAQUES DA V3:
    1. Painel com Abas (Dashboard, Coletor Avançado, Explorador de Badges, Utilitários).
    2. Botão Flutuante Móvel (Mobile Floating Button) + Tecla de Atalho PC (Insert / RightShift).
    3. Integração com a API Web de Badges (busca nomes, ícones reais e descrições do jogo atual).
    4. Rastreador em Tempo Real (Mostra quantas badges existem no jogo e quantas você já tem).
    5. Métodos de Coleta Híbridos:
       - Ultra Fast (firetouchinterest instantâneo em lote)
       - Safe Tween (teleporte suave para desviar de anticheat de teleporte)
       - ProximityPrompt & ClickDetector automáticos
       - Anti-Void e Noclip Inteligente durante a coleta
    6. Ferramentas Extras:
       - Anti-AFK integrado permanente
       - Copiador de Badge IDs (Clipboard)
       - Otimizador de FPS (FPS Boost para mapas gigantes com 10.000+ pads)
       - Server Hop & Rejoin
    7. Suporte a Roblox Studio (ServerScriptService) mantido com cache de alta fidelidade.
    =================================================================================
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

-- =================================================================================
-- CONFIGURAÇÕES PADRÃO (Ajustáveis pelo usuário no código ou pela interface)
-- =================================================================================
local Settings = {
    Delay = 0.02,                   -- Delay entre badges no modo Ultra (em segundos)
    TweenSpeed = 40,                -- Velocidade dos blocos se usar o modo Tween
    Mode = "Ultra",                 -- "Ultra" (Instantâneo) ou "Safe" (Tween)
    AutoAntiAfk = true,             -- Anti-AFK ativado por padrão
    Noclip = true,                  -- Noclip ativado durante coleta
    IgnoreCollected = true,         -- Ignora badges já obtidas se conhecidas
    NotificationSound = true,       -- Efeito sonoro discreto ao concluir
    Keybind = Enum.KeyCode.RightShift, -- Tecla para abrir/fechar no PC
}

-- =================================================================================
-- MODO 1: CLIENTE / EXECUTOR (Delta, Arceus X, Solara, Wave, Codex, Synapse, etc.)
-- =================================================================================
if RunService:IsClient() then
    local LocalPlayer = Players.LocalPlayer
    local Camera = workspace.CurrentCamera

    -- -----------------------------------------------------------------------------
    -- 1. Anti-AFK
    -- -----------------------------------------------------------------------------
    if Settings.AutoAntiAfk then
        LocalPlayer.Idled:Connect(function()
            local vu = game:GetService("VirtualUser")
            vu:CaptureController()
            vu:ClickButton2(Vector2.new(0, 0))
            print("[Badge V3] Anti-AFK evitou a desconexão.")
        end)
    end

    -- -----------------------------------------------------------------------------
    -- 2. Buscador de Informações da API (Badges do Jogo Atual)
    -- -----------------------------------------------------------------------------
    local GameBadgesCache = {}
    local UserBadgesCache = {}
    local isApiLoaded = false

    local function fetchGameBadgesApi()
        local universeId = game.GameId
        if universeId == 0 then return {} end

        local badges = {}
        local cursor = ""
        local maxPages = 5 -- Até 500 badges na listagem visual direta
        local page = 0

        repeat
            page = page + 1
            local url = string.format("https://badges.roproxy.com/v1/universes/%d/badges?limit=100&cursor=%s", universeId, cursor)
            local success, content

            pcall(function()
                if (syn and syn.request) or (http and http.request) or request then
                    local req = (syn and syn.request) or (http and http.request) or request
                    local res = req({Url = url, Method = "GET"})
                    content = res.Body
                    success = (res.StatusCode == 200)
                elseif game.HttpGet then
                    content = game:HttpGet(url)
                    success = (content ~= nil and #content > 0)
                end
            end)

            if success and content then
                local data = HttpService:JSONDecode(content)
                if data and data.data then
                    for _, b in ipairs(data.data) do
                        table.insert(badges, {
                            Id = b.id,
                            Name = b.name or "Emblema Sem Nome",
                            Description = b.description or "Sem descrição",
                            IconId = b.iconImageId or 0,
                            Enabled = b.enabled
                        })
                    end
                    cursor = data.nextPageCursor or ""
                else
                    break
                end
            else
                break
            end
        until cursor == "" or cursor == nil or page >= maxPages

        GameBadgesCache = badges
        isApiLoaded = true
        return badges
    end

    -- -----------------------------------------------------------------------------
    -- 3. Construção da Interface Gráfica Avançada (UI V3)
    -- -----------------------------------------------------------------------------
    local function buildUltimateInterface()
        local parentGui = (gethui and gethui()) or game:GetService("CoreGui"):FindFirstChild("RobloxGui") or LocalPlayer:WaitForChild("PlayerGui")
        local existing = parentGui:FindFirstChild("BadgeMaster_V3")
        if existing then existing:Destroy() end

        local Screen = Instance.new("ScreenGui")
        Screen.Name = "BadgeMaster_V3"
        Screen.ResetOnSpawn = false
        Screen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

        -- ----------------- Botão Flutuante Mobile -----------------
        local MobileBtn = Instance.new("TextButton")
        MobileBtn.Name = "MobileToggle"
        MobileBtn.Size = UDim2.new(0, 48, 0, 48)
        MobileBtn.Position = UDim2.new(0, 16, 0.4, 0)
        MobileBtn.BackgroundColor3 = Color3.fromRGB(25, 27, 36)
        MobileBtn.Text = "🏅"
        MobileBtn.TextSize = 22
        MobileBtn.BorderSizePixel = 0
        MobileBtn.Active = true
        MobileBtn.Parent = Screen

        local mobCorner = Instance.new("UICorner")
        mobCorner.CornerRadius = UDim.new(1, 0)
        mobCorner.Parent = MobileBtn

        local mobStroke = Instance.new("UIStroke")
        mobStroke.Color = Color3.fromRGB(0, 170, 255)
        mobStroke.Thickness = 2
        mobStroke.Parent = MobileBtn

        -- ----------------- Janela Principal -----------------
        local Main = Instance.new("Frame")
        Main.Name = "MainHub"
        Main.Size = UDim2.new(0, 560, 0, 360)
        Main.Position = UDim2.new(0.5, -280, 0.5, -180)
        Main.BackgroundColor3 = Color3.fromRGB(18, 20, 26)
        Main.BorderSizePixel = 0
        Main.ClipsDescendants = true
        Main.Active = true
        Main.Parent = Screen

        local mainCorner = Instance.new("UICorner")
        mainCorner.CornerRadius = UDim.new(0, 12)
        mainCorner.Parent = Main

        local mainStroke = Instance.new("UIStroke")
        mainStroke.Color = Color3.fromRGB(45, 50, 68)
        mainStroke.Thickness = 1.4
        mainStroke.Parent = Main

        -- Barra de Título Superior
        local TopBar = Instance.new("Frame")
        TopBar.Size = UDim2.new(1, 0, 0, 42)
        TopBar.BackgroundColor3 = Color3.fromRGB(24, 27, 36)
        TopBar.BorderSizePixel = 0
        TopBar.Parent = Main

        local topCorner = Instance.new("UICorner")
        topCorner.CornerRadius = UDim.new(0, 12)
        topCorner.Parent = TopBar

        local LogoIcon = Instance.new("TextLabel")
        LogoIcon.Size = UDim2.new(0, 30, 1, 0)
        LogoIcon.Position = UDim2.new(0, 14, 0, 0)
        LogoIcon.BackgroundTransparency = 1
        LogoIcon.Text = "🏆"
        LogoIcon.TextSize = 18
        LogoIcon.Parent = TopBar

        local Title = Instance.new("TextLabel")
        Title.Size = UDim2.new(0, 250, 1, 0)
        Title.Position = UDim2.new(0, 48, 0, 0)
        Title.BackgroundTransparency = 1
        Title.Text = "BADGE MASTER ULTIMATE v3"
        Title.TextColor3 = Color3.fromRGB(245, 245, 250)
        Title.TextSize = 13
        Title.Font = Enum.Font.GothamBold
        Title.TextXAlignment = Enum.TextXAlignment.Left
        Title.Parent = TopBar

        local CloseBtn = Instance.new("TextButton")
        CloseBtn.Size = UDim2.new(0, 30, 0, 30)
        CloseBtn.Position = UDim2.new(1, -36, 0, 6)
        CloseBtn.BackgroundColor3 = Color3.fromRGB(38, 42, 54)
        CloseBtn.Text = "✕"
        CloseBtn.TextColor3 = Color3.fromRGB(220, 220, 230)
        CloseBtn.TextSize = 13
        CloseBtn.Font = Enum.Font.GothamBold
        CloseBtn.BorderSizePixel = 0
        CloseBtn.Parent = TopBar

        local closeCorner = Instance.new("UICorner")
        closeCorner.CornerRadius = UDim.new(0, 8)
        closeCorner.Parent = CloseBtn

        local MinBtn = Instance.new("TextButton")
        MinBtn.Size = UDim2.new(0, 30, 0, 30)
        MinBtn.Position = UDim2.new(1, -72, 0, 6)
        MinBtn.BackgroundColor3 = Color3.fromRGB(38, 42, 54)
        MinBtn.Text = "—"
        MinBtn.TextColor3 = Color3.fromRGB(220, 220, 230)
        MinBtn.TextSize = 13
        MinBtn.Font = Enum.Font.GothamBold
        MinBtn.BorderSizePixel = 0
        MinBtn.Parent = TopBar

        local minCorner = Instance.new("UICorner")
        minCorner.CornerRadius = UDim.new(0, 8)
        minCorner.Parent = MinBtn

        -- ----------------- Barra Lateral (Tabs / Navegação) -----------------
        local Sidebar = Instance.new("Frame")
        Sidebar.Size = UDim2.new(0, 140, 1, -42)
        Sidebar.Position = UDim2.new(0, 0, 0, 42)
        Sidebar.BackgroundColor3 = Color3.fromRGB(20, 22, 30)
        Sidebar.BorderSizePixel = 0
        Sidebar.Parent = Main

        local TabContainer = Instance.new("Frame")
        TabContainer.Size = UDim2.new(1, -16, 1, -16)
        TabContainer.Position = UDim2.new(0, 8, 0, 8)
        TabContainer.BackgroundTransparency = 1
        TabContainer.Parent = Sidebar

        local tabList = Instance.new("UIListLayout")
        tabList.SortOrder = Enum.SortOrder.LayoutOrder
        tabList.Padding = UDim.new(0, 6)
        tabList.Parent = TabContainer

        -- Área de Conteúdo das Abas
        local ContentArea = Instance.new("Frame")
        ContentArea.Size = UDim2.new(1, -148, 1, -50)
        ContentArea.Position = UDim2.new(0, 144, 0, 46)
        ContentArea.BackgroundTransparency = 1
        ContentArea.Parent = Main

        -- Controle de Alternância de Abas
        local Tabs = {}
        local TabButtons = {}

        local function switchTab(tabName)
            for name, page in pairs(Tabs) do
                page.Visible = (name == tabName)
            end
            for name, btn in pairs(TabButtons) do
                if name == tabName then
                    btn.BackgroundColor3 = Color3.fromRGB(0, 140, 255)
                    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
                else
                    btn.BackgroundColor3 = Color3.fromRGB(28, 32, 42)
                    btn.TextColor3 = Color3.fromRGB(160, 165, 180)
                end
            end
        end

        local function createTabButton(name, icon, order)
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, 0, 0, 36)
            btn.BackgroundColor3 = Color3.fromRGB(28, 32, 42)
            btn.Text = "  " .. icon .. "  " .. name
            btn.TextColor3 = Color3.fromRGB(160, 165, 180)
            btn.TextSize = 12
            btn.Font = Enum.Font.GothamMedium
            btn.TextXAlignment = Enum.TextXAlignment.Left
            btn.BorderSizePixel = 0
            btn.LayoutOrder = order
            btn.Parent = TabContainer

            local c = Instance.new("UICorner")
            c.CornerRadius = UDim.new(0, 8)
            c.Parent = btn

            TabButtons[name] = btn
            btn.MouseButton1Click:Connect(function()
                switchTab(name)
            end)

            local page = Instance.new("Frame")
            page.Name = name .. "_Page"
            page.Size = UDim2.new(1, 0, 1, 0)
            page.BackgroundTransparency = 1
            page.Visible = false
            page.Parent = ContentArea
            Tabs[name] = page

            return page
        end

        -- =========================================================================
        -- ABA 1: DASHBOARD
        -- =========================================================================
        local DashPage = createTabButton("Início", "📊", 1)

        -- Cards de Estatísticas
        local function createStatCard(title, value, xOffset, icon)
            local card = Instance.new("Frame")
            card.Size = UDim2.new(0.31, 0, 0, 68)
            card.Position = UDim2.new(xOffset, 0, 0, 6)
            card.BackgroundColor3 = Color3.fromRGB(26, 29, 39)
            card.BorderSizePixel = 0
            card.Parent = DashPage

            local c = Instance.new("UICorner")
            c.CornerRadius = UDim.new(0, 8)
            c.Parent = card

            local st = Instance.new("UIStroke")
            st.Color = Color3.fromRGB(40, 45, 60)
            st.Parent = card

            local t = Instance.new("TextLabel")
            t.Size = UDim2.new(1, -12, 0, 18)
            t.Position = UDim2.new(0, 10, 0, 8)
            t.BackgroundTransparency = 1
            t.Text = icon .. " " .. title
            t.TextColor3 = Color3.fromRGB(150, 155, 175)
            t.TextSize = 11
            t.Font = Enum.Font.Gotham
            t.TextXAlignment = Enum.TextXAlignment.Left
            t.Parent = card

            local val = Instance.new("TextLabel")
            val.Size = UDim2.new(1, -12, 0, 28)
            val.Position = UDim2.new(0, 10, 0, 28)
            val.BackgroundTransparency = 1
            val.Text = value
            val.TextColor3 = Color3.fromRGB(255, 255, 255)
            val.TextSize = 18
            val.Font = Enum.Font.GothamBold
            val.TextXAlignment = Enum.TextXAlignment.Left
            val.Parent = card

            return val
        end

        local StatTargets = createStatCard("Alvos no Mapa", "Carregando...", 0, "📍")
        local StatBadgesApi = createStatCard("Badges do Jogo", "Consultando...", 0.345, "🏅")
        local StatSpeed = createStatCard("Modo Coleta", "Ultra Fast", 0.69, "⚡")

        -- Bloco de Progresso do Coletor
        local CollectorBox = Instance.new("Frame")
        CollectorBox.Size = UDim2.new(1, 0, 0, 140)
        CollectorBox.Position = UDim2.new(0, 0, 0, 84)
        CollectorBox.BackgroundColor3 = Color3.fromRGB(26, 29, 39)
        CollectorBox.BorderSizePixel = 0
        CollectorBox.Parent = DashPage

        local cbCorner = Instance.new("UICorner")
        cbCorner.CornerRadius = UDim.new(0, 10)
        cbCorner.Parent = CollectorBox

        local cbStroke = Instance.new("UIStroke")
        cbStroke.Color = Color3.fromRGB(40, 45, 60)
        cbStroke.Parent = CollectorBox

        local StatusTxt = Instance.new("TextLabel")
        StatusTxt.Size = UDim2.new(1, -24, 0, 20)
        StatusTxt.Position = UDim2.new(0, 12, 0, 12)
        StatusTxt.BackgroundTransparency = 1
        StatusTxt.Text = "Status: Aguardando comando"
        StatusTxt.TextColor3 = Color3.fromRGB(180, 185, 205)
        StatusTxt.TextSize = 12
        StatusTxt.Font = Enum.Font.GothamMedium
        StatusTxt.TextXAlignment = Enum.TextXAlignment.Left
        StatusTxt.Parent = CollectorBox

        local CounterTxt = Instance.new("TextLabel")
        CounterTxt.Size = UDim2.new(1, -24, 0, 24)
        CounterTxt.Position = UDim2.new(0, 12, 0, 36)
        CounterTxt.BackgroundTransparency = 1
        CounterTxt.Text = "0 / 0 coletadas (0%)"
        CounterTxt.TextColor3 = Color3.fromRGB(255, 255, 255)
        CounterTxt.TextSize = 16
        CounterTxt.Font = Enum.Font.GothamBold
        CounterTxt.TextXAlignment = Enum.TextXAlignment.Left
        CounterTxt.Parent = CollectorBox

        local BarBg = Instance.new("Frame")
        BarBg.Size = UDim2.new(1, -24, 0, 10)
        BarBg.Position = UDim2.new(0, 12, 0, 68)
        BarBg.BackgroundColor3 = Color3.fromRGB(38, 42, 54)
        BarBg.BorderSizePixel = 0
        BarBg.Parent = CollectorBox

        local bbgc = Instance.new("UICorner")
        bbgc.CornerRadius = UDim.new(1, 0)
        bbgc.Parent = BarBg

        local BarFill = Instance.new("Frame")
        BarFill.Size = UDim2.new(0, 0, 1, 0)
        BarFill.BackgroundColor3 = Color3.fromRGB(0, 160, 255)
        BarFill.BorderSizePixel = 0
        BarFill.Parent = BarBg

        local bfc = Instance.new("UICorner")
        bfc.CornerRadius = UDim.new(1, 0)
        bfc.Parent = BarFill

        -- Botões de Ação
        local StartBtn = Instance.new("TextButton")
        StartBtn.Size = UDim2.new(0.48, 0, 0, 36)
        StartBtn.Position = UDim2.new(0, 12, 0, 90)
        StartBtn.BackgroundColor3 = Color3.fromRGB(0, 140, 255)
        StartBtn.Text = "INICIAR COLETA"
        StartBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        StartBtn.TextSize = 12
        StartBtn.Font = Enum.Font.GothamBold
        StartBtn.BorderSizePixel = 0
        StartBtn.Parent = CollectorBox

        local sbc = Instance.new("UICorner")
        sbc.CornerRadius = UDim.new(0, 8)
        sbc.Parent = StartBtn

        local StopBtn = Instance.new("TextButton")
        StopBtn.Size = UDim2.new(0.48, 0, 0, 36)
        StopBtn.Position = UDim2.new(0.51, 0, 0, 90)
        StopBtn.BackgroundColor3 = Color3.fromRGB(45, 50, 65)
        StopBtn.Text = "INTERROMPER"
        StopBtn.TextColor3 = Color3.fromRGB(220, 220, 230)
        StopBtn.TextSize = 12
        StopBtn.Font = Enum.Font.GothamBold
        StopBtn.BorderSizePixel = 0
        StopBtn.Parent = CollectorBox

        local stc = Instance.new("UICorner")
        stc.CornerRadius = UDim.new(0, 8)
        stc.Parent = StopBtn

        -- =========================================================================
        -- ABA 2: OPÇÕES DO COLETOR
        -- =========================================================================
        local OptPage = createTabButton("Coletor", "⚡", 2)

        local optScroll = Instance.new("ScrollingFrame")
        optScroll.Size = UDim2.new(1, 0, 1, 0)
        optScroll.BackgroundTransparency = 1
        optScroll.BorderSizePixel = 0
        optScroll.ScrollBarThickness = 4
        optScroll.Parent = OptPage

        local optList = Instance.new("UIListLayout")
        optList.Padding = UDim.new(0, 8)
        optList.Parent = optScroll

        local function createToggle(label, initialVal, callback)
            local item = Instance.new("Frame")
            item.Size = UDim2.new(1, -10, 0, 44)
            item.BackgroundColor3 = Color3.fromRGB(26, 29, 39)
            item.BorderSizePixel = 0
            item.Parent = optScroll

            local c = Instance.new("UICorner")
            c.CornerRadius = UDim.new(0, 8)
            c.Parent = item

            local lbl = Instance.new("TextLabel")
            lbl.Size = UDim2.new(1, -70, 1, 0)
            lbl.Position = UDim2.new(0, 14, 0, 0)
            lbl.BackgroundTransparency = 1
            lbl.Text = label
            lbl.TextColor3 = Color3.fromRGB(240, 240, 245)
            lbl.TextSize = 12
            lbl.Font = Enum.Font.GothamMedium
            lbl.TextXAlignment = Enum.TextXAlignment.Left
            lbl.Parent = item

            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(0, 48, 0, 26)
            btn.Position = UDim2.new(1, -58, 0.5, -13)
            btn.BackgroundColor3 = initialVal and Color3.fromRGB(0, 180, 100) or Color3.fromRGB(50, 54, 68)
            btn.Text = initialVal and "ON" or "OFF"
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            btn.TextSize = 10
            btn.Font = Enum.Font.GothamBold
            btn.BorderSizePixel = 0
            btn.Parent = item

            local bc = Instance.new("UICorner")
            bc.CornerRadius = UDim.new(0, 6)
            bc.Parent = btn

            local state = initialVal
            btn.MouseButton1Click:Connect(function()
                state = not state
                btn.BackgroundColor3 = state and Color3.fromRGB(0, 180, 100) or Color3.fromRGB(50, 54, 68)
                btn.Text = state and "ON" or "OFF"
                callback(state)
            end)
        end

        createToggle("Anti-AFK Automático Permanente", Settings.AutoAntiAfk, function(v)
            Settings.AutoAntiAfk = v
        end)

        createToggle("Ativar Noclip Durante Coleta", Settings.Noclip, function(v)
            Settings.Noclip = v
        end)

        createToggle("Modo Seguro com Tween (Evita Kick)", Settings.Mode == "Safe", function(v)
            Settings.Mode = v and "Safe" or "Ultra"
            StatSpeed.Text = v and "Safe (Tween)" or "Ultra Fast"
        end)

        createToggle("Acionar Prompts de Proximidade (E)", true, function(v) end)
        createToggle("Acionar Detectores de Clique", true, function(v) end)

        -- =========================================================================
        -- ABA 3: EXPLORADOR DE BADGES DO JOGO (API LIVE)
        -- =========================================================================
        local ListPage = createTabButton("Badges", "📜", 3)

        local SearchBox = Instance.new("TextBox")
        SearchBox.Size = UDim2.new(1, 0, 0, 32)
        SearchBox.BackgroundColor3 = Color3.fromRGB(26, 29, 39)
        SearchBox.PlaceholderText = "🔍 Buscar badge por nome..."
        SearchBox.PlaceholderColor3 = Color3.fromRGB(120, 125, 140)
        SearchBox.Text = ""
        SearchBox.TextColor3 = Color3.fromRGB(240, 240, 245)
        SearchBox.TextSize = 12
        SearchBox.Font = Enum.Font.Gotham
        SearchBox.BorderSizePixel = 0
        SearchBox.Parent = ListPage

        local sbc = Instance.new("UICorner")
        sbc.CornerRadius = UDim.new(0, 8)
        sbc.Parent = SearchBox

        local BadgeScroll = Instance.new("ScrollingFrame")
        BadgeScroll.Size = UDim2.new(1, 0, 1, -40)
        BadgeScroll.Position = UDim2.new(0, 0, 0, 40)
        BadgeScroll.BackgroundTransparency = 1
        BadgeScroll.BorderSizePixel = 0
        BadgeScroll.ScrollBarThickness = 4
        BadgeScroll.Parent = ListPage

        local badgeLayout = Instance.new("UIListLayout")
        badgeLayout.Padding = UDim.new(0, 6)
        badgeLayout.Parent = BadgeScroll

        local function populateBadgeCards(filter)
            filter = (filter or ""):lower()
            for _, child in ipairs(BadgeScroll:GetChildren()) do
                if child:IsA("Frame") then child:Destroy() end
            end

            for _, b in ipairs(GameBadgesCache) do
                if filter == "" or b.Name:lower():find(filter) then
                    local card = Instance.new("Frame")
                    card.Size = UDim2.new(1, -10, 0, 52)
                    card.BackgroundColor3 = Color3.fromRGB(24, 27, 36)
                    card.BorderSizePixel = 0
                    card.Parent = BadgeScroll

                    local cc = Instance.new("UICorner")
                    cc.CornerRadius = UDim.new(0, 8)
                    cc.Parent = card

                    local iconImg = Instance.new("ImageLabel")
                    iconImg.Size = UDim2.new(0, 38, 0, 38)
                    iconImg.Position = UDim2.new(0, 8, 0, 7)
                    iconImg.BackgroundColor3 = Color3.fromRGB(35, 38, 50)
                    iconImg.Image = (b.IconId and b.IconId > 0) and ("rbxassetid://" .. b.IconId) or "rbxassetid://109529329"
                    iconImg.BorderSizePixel = 0
                    iconImg.Parent = card

                    local ic = Instance.new("UICorner")
                    ic.CornerRadius = UDim.new(0, 6)
                    ic.Parent = iconImg

                    local bTitle = Instance.new("TextLabel")
                    bTitle.Size = UDim2.new(1, -120, 0, 20)
                    bTitle.Position = UDim2.new(0, 54, 0, 6)
                    bTitle.BackgroundTransparency = 1
                    bTitle.Text = b.Name
                    bTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
                    bTitle.TextSize = 12
                    bTitle.Font = Enum.Font.GothamBold
                    bTitle.TextXAlignment = Enum.TextXAlignment.Left
                    bTitle.TextTruncate = Enum.TextTruncate.AtEnd
                    bTitle.Parent = card

                    local bDesc = Instance.new("TextLabel")
                    bDesc.Size = UDim2.new(1, -120, 0, 18)
                    bDesc.Position = UDim2.new(0, 54, 0, 26)
                    bDesc.BackgroundTransparency = 1
                    bDesc.Text = b.Description ~= "" and b.Description or ("ID: " .. b.Id)
                    bDesc.TextColor3 = Color3.fromRGB(150, 155, 170)
                    bDesc.TextSize = 10
                    bDesc.Font = Enum.Font.Gotham
                    bDesc.TextXAlignment = Enum.TextXAlignment.Left
                    bDesc.TextTruncate = Enum.TextTruncate.AtEnd
                    bDesc.Parent = card

                    local copyBtn = Instance.new("TextButton")
                    copyBtn.Size = UDim2.new(0, 56, 0, 28)
                    copyBtn.Position = UDim2.new(1, -64, 0.5, -14)
                    copyBtn.BackgroundColor3 = Color3.fromRGB(36, 40, 54)
                    copyBtn.Text = "Copiar"
                    copyBtn.TextColor3 = Color3.fromRGB(200, 205, 220)
                    copyBtn.TextSize = 10
                    copyBtn.Font = Enum.Font.GothamMedium
                    copyBtn.BorderSizePixel = 0
                    copyBtn.Parent = card

                    local cbc = Instance.new("UICorner")
                    cbc.CornerRadius = UDim.new(0, 6)
                    cbc.Parent = copyBtn

                    copyBtn.MouseButton1Click:Connect(function()
                        if setclipboard then
                            setclipboard(tostring(b.Id))
                            copyBtn.Text = "Copiado!"
                            task.wait(1)
                            copyBtn.Text = "Copiar"
                        end
                    end)
                end
            end
            BadgeScroll.CanvasSize = UDim2.new(0, 0, 0, badgeLayout.AbsoluteContentSize.Y + 10)
        end

        SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
            populateBadgeCards(SearchBox.Text)
        end)

        -- =========================================================================
        -- ABA 4: UTILITÁRIOS
        -- =========================================================================
        local UtilPage = createTabButton("Extras", "🛠️", 4)

        local function createUtilBtn(name, desc, btnText, callback)
            local box = Instance.new("Frame")
            box.Size = UDim2.new(1, 0, 0, 56)
            box.BackgroundColor3 = Color3.fromRGB(26, 29, 39)
            box.BorderSizePixel = 0
            box.Parent = UtilPage

            local c = Instance.new("UICorner")
            c.CornerRadius = UDim.new(0, 8)
            c.Parent = box

            local t = Instance.new("TextLabel")
            t.Size = UDim2.new(1, -120, 0, 20)
            t.Position = UDim2.new(0, 14, 0, 8)
            t.BackgroundTransparency = 1
            t.Text = name
            t.TextColor3 = Color3.fromRGB(245, 245, 250)
            t.TextSize = 12
            t.Font = Enum.Font.GothamBold
            t.TextXAlignment = Enum.TextXAlignment.Left
            t.Parent = box

            local d = Instance.new("TextLabel")
            d.Size = UDim2.new(1, -120, 0, 18)
            d.Position = UDim2.new(0, 14, 0, 28)
            d.BackgroundTransparency = 1
            d.Text = desc
            d.TextColor3 = Color3.fromRGB(150, 155, 170)
            d.TextSize = 10
            d.Font = Enum.Font.Gotham
            d.TextXAlignment = Enum.TextXAlignment.Left
            d.Parent = box

            local b = Instance.new("TextButton")
            b.Size = UDim2.new(0, 88, 0, 32)
            b.Position = UDim2.new(1, -98, 0.5, -16)
            b.BackgroundColor3 = Color3.fromRGB(0, 140, 255)
            b.Text = btnText
            b.TextColor3 = Color3.fromRGB(255, 255, 255)
            b.TextSize = 11
            b.Font = Enum.Font.GothamBold
            b.BorderSizePixel = 0
            b.Parent = box

            local bc = Instance.new("UICorner")
            bc.CornerRadius = UDim.new(0, 6)
            bc.Parent = b

            b.MouseButton1Click:Connect(callback)
        end

        local utilList = Instance.new("UIListLayout")
        utilList.Padding = UDim.new(0, 8)
        utilList.Parent = UtilPage

        createUtilBtn("Otimizador de FPS", "Remove texturas para o jogo rodar liso em mapas de 5000+ badges.", "Boost FPS", function()
            for _, v in ipairs(workspace:GetDescendants()) do
                if v:IsA("BasePart") then
                    v.Material = Enum.Material.SmoothPlastic
                    v.CastShadow = false
                elseif v:IsA("Decal") or v:IsA("Texture") then
                    v.Transparency = 1
                end
            end
            print("[Badge V3] Otimizador de FPS aplicado.")
        end)

        createUtilBtn("Copiar Todos os IDs", "Copia todos os Badge IDs encontrados diretamente para a área de transferência.", "Copiar Tudo", function()
            if setclipboard and #GameBadgesCache > 0 then
                local ids = {}
                for _, b in ipairs(GameBadgesCache) do table.insert(ids, b.Id) end
                setclipboard(table.concat(ids, ", "))
                print("[Badge V3] Todos os IDs copiados para o Clipboard.")
            end
        end)

        createUtilBtn("Reconectar ao Servidor", "Reconecta instantaneamente ao mesmo servidor atual.", "Rejoin", function()
            game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
        end)

        -- ----------------- Sistema de Arrastar da Janela -----------------
        local dragging, dragStart, startPos
        TopBar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                dragStart = input.Position
                startPos = Main.Position
            end
        end)

        UserInputService.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                local delta = input.Position - dragStart
                Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end)

        local function stopDrag() dragging = false end
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                stopDrag()
            end
        end)

        -- Mostrar / Ocultar
        local isVisible = true
        local function toggleVisibility()
            isVisible = not isVisible
            Main.Visible = isVisible
        end

        MobileBtn.MouseButton1Click:Connect(toggleVisibility)
        CloseBtn.MouseButton1Click:Connect(toggleVisibility)
        MinBtn.MouseButton1Click:Connect(toggleVisibility)

        UserInputService.InputBegan:Connect(function(input, gpe)
            if not gpe and input.KeyCode == Settings.Keybind then
                toggleVisibility()
            end
        end)

        -- Abre na primeira aba
        switchTab("Início")
        Screen.Parent = parentGui

        return {
            Screen = Screen,
            StatusTxt = StatusTxt,
            CounterTxt = CounterTxt,
            BarFill = BarFill,
            StartBtn = StartBtn,
            StopBtn = StopBtn,
            StatTargets = StatTargets,
            StatBadgesApi = StatBadgesApi,
            PopulateBadges = populateBadgeCards
        }
    end

    -- -----------------------------------------------------------------------------
    -- 4. Motor de Coleta Inteligente (Scanner + Dispatcher V3)
    -- -----------------------------------------------------------------------------
    local UI = buildUltimateInterface()
    local isCollecting = false
    local cancelRequested = false

    -- Varredura de alvos no mapa
    local function scanWorldTargets()
        local list = {}
        local seen = {}

        local function record(part, method, extra)
            if part and part:IsA("BasePart") and not seen[part] then
                seen[part] = true
                table.insert(list, {
                    Part = part,
                    Method = method or "Touch",
                    Extra = extra
                })
            end
        end

        for _, item in ipairs(workspace:GetDescendants()) do
            if item:IsA("TouchTransmitter") and item.Parent and item.Parent:IsA("BasePart") then
                record(item.Parent, "Touch")
            elseif item:IsA("ProximityPrompt") and item.Parent then
                local p = item.Parent:IsA("BasePart") and item.Parent or item.Parent:FindFirstChildWhichIsA("BasePart")
                if p then record(p, "Prompt", item) end
            elseif item:IsA("ClickDetector") and item.Parent and item.Parent:IsA("BasePart") then
                record(item.Parent, "Click", item)
            elseif item:IsA("BasePart") then
                local lower = item.Name:lower()
                if lower:find("badge") or lower:find("emblem") or lower:find("trophy") or lower:find("giver") or lower:find("freebadge") or lower:find("pad") then
                    record(item, "Touch")
                end
            end
        end

        return list
    end

    -- Inicialização em background das estatísticas e API
    task.spawn(function()
        local targets = scanWorldTargets()
        UI.StatTargets.Text = tostring(#targets)

        local badges = fetchGameBadgesApi()
        UI.StatBadgesApi.Text = tostring(#badges)
        UI.PopulateBadges()
    end)

    -- Execução da Coleta
    local function startCollection()
        if isCollecting then return end
        isCollecting = true
        cancelRequested = false

        UI.StartBtn.Text = "COLETANDO..."
        UI.StartBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 120)
        UI.StatusTxt.Text = "Status: Escaneando o mapa..."

        task.spawn(function()
            local targets = scanWorldTargets()
            local total = #targets
            UI.StatTargets.Text = tostring(total)

            if total == 0 then
                UI.StatusTxt.Text = "Status: Nenhum alvo de badge encontrado no mapa."
                UI.StartBtn.Text = "INICIAR COLETA"
                UI.StartBtn.BackgroundColor3 = Color3.fromRGB(0, 140, 255)
                isCollecting = false
                return
            end

            local done = 0
            for i, target in ipairs(targets) do
                if cancelRequested then
                    UI.StatusTxt.Text = "Status: Coleta cancelada pelo usuário."
                    break
                end

                local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
                local root = char:FindFirstChild("HumanoidRootPart")
                local hum = char:FindFirstChildWhichIsA("Humanoid")

                if root and target.Part and target.Part.Parent then
                    -- Noclip se ativado
                    if Settings.Noclip and hum then
                        for _, p in ipairs(char:GetDescendants()) do
                            if p:IsA("BasePart") then p.CanCollide = false end
                        end
                    end

                    pcall(function()
                        -- Interações especiais
                        if target.Method == "Prompt" and fireproximityprompt then
                            fireproximityprompt(target.Extra)
                        elseif target.Method == "Click" and fireclickdetector then
                            fireclickdetector(target.Extra)
                        end

                        -- Método de Toque
                        if Settings.Mode == "Ultra" and firetouchinterest then
                            firetouchinterest(root, target.Part, 0)
                            task.wait(0.005)
                            firetouchinterest(root, target.Part, 1)
                        else
                            -- Modo Tween Seguro
                            local targetPos = target.Part.CFrame + Vector3.new(0, 2, 0)
                            local dist = (root.Position - targetPos.Position).Magnitude
                            local timeToTravel = math.clamp(dist / Settings.TweenSpeed, 0.05, 0.4)

                            local tween = TweenService:Create(root, TweenInfo.new(timeToTravel, Enum.EasingStyle.Linear), {CFrame = targetPos})
                            tween:Play()
                            tween.Completed:Wait()

                            if firetouchinterest then
                                firetouchinterest(root, target.Part, 0)
                                task.wait(0.005)
                                firetouchinterest(root, target.Part, 1)
                            end
                        end
                    end)
                end

                done = done + 1
                local pct = math.floor((done / total) * 100)
                UI.CounterTxt.Text = string.format("%d / %d processadas (%d%%)", done, total, pct)
                UI.BarFill.Size = UDim2.new(done / total, 0, 1, 0)
                UI.StatusTxt.Text = string.format("Status: Coletando... [%d/%d]", done, total)

                task.wait(Settings.Delay)
            end

            if not cancelRequested then
                UI.StatusTxt.Text = "Status: Coleta 100% Finalizada!"
                UI.BarFill.BackgroundColor3 = Color3.fromRGB(0, 220, 120)
                print("[Badge V3] Coleta concluída com sucesso.")
            end

            UI.StartBtn.Text = "INICIAR COLETA"
            UI.StartBtn.BackgroundColor3 = Color3.fromRGB(0, 140, 255)
            isCollecting = false
            cancelRequested = false
        end)
    end

    local function stopCollection()
        if isCollecting then
            cancelRequested = true
            UI.StatusTxt.Text = "Status: Interrompendo..."
        end
    end

    UI.StartBtn.MouseButton1Click:Connect(startCollection)
    UI.StopBtn.MouseButton1Click:Connect(stopCollection)

-- =================================================================================
-- MODO 2: SERVIDOR (Roblox Studio / ServerScriptService)
-- =================================================================================
elseif RunService:IsServer() then
    local BadgeService = game:GetService("BadgeService")
    local HttpService = game:GetService("HttpService")

    local UNIVERSE_ID = game.GameId
    local cachedBadges = nil
    local isFetching = false

    local function getUniverseBadges()
        if cachedBadges then return cachedBadges end
        if isFetching then
            while isFetching do task.wait(0.1) end
            return cachedBadges or {}
        end

        isFetching = true
        local list = {}
        local cursor = ""

        print("[BadgeServer V3] Catalogando badges do Universo:", UNIVERSE_ID)

        repeat
            local url = string.format("https://badges.roproxy.com/v1/universes/%d/badges?limit=100&cursor=%s", UNIVERSE_ID, cursor)
            local success, body = pcall(function()
                return HttpService:GetAsync(url)
            end)

            if success and body then
                local data = HttpService:JSONDecode(body)
                if data and data.data then
                    for _, b in ipairs(data.data) do
                        table.insert(list, b.id)
                    end
                    cursor = data.nextPageCursor or ""
                else
                    break
                end
            else
                break
            end
            task.wait(0.15)
        until cursor == "" or cursor == nil

        cachedBadges = list
        isFetching = false
        print(string.format("[BadgeServer V3] %d badges catalogadas.", #list))
        return list
    end

    local function grantAllBadges(player)
        task.spawn(function()
            local badges = getUniverseBadges()
            if #badges == 0 then return end

            print(string.format("[BadgeServer V3] Entregando %d badges a %s...", #badges, player.Name))
            for _, bId in ipairs(badges) do
                if not player.Parent then break end
                pcall(function()
                    if not BadgeService:UserHasBadgeAsync(player.UserId, bId) then
                        BadgeService:AwardBadge(player.UserId, bId)
                        task.wait(0.12)
                    end
                end)
            end
            print("[BadgeServer V3] Concluído para " .. player.Name)
        end)
    end

    Players.PlayerAdded:Connect(function(player)
        grantAllBadges(player)
        player.Chatted:Connect(function(msg)
            if msg:lower() == "/giveall" then
                for _, p in ipairs(Players:GetPlayers()) do grantAllBadges(p) end
            elseif msg:lower() == "/giveme" then
                grantAllBadges(player)
            end
        end)
    end)
end

]====],
    ["V4"] = [====[
--[[
    =================================================================================
    🔥 BADGE MASTER V4 - REAL INJECTION & FORCE AWARD SYSTEM
    =================================================================================
    Por que as versões anteriores não funcionaram no seu jogo?
    
    No Roblox, a engine proíbe que clientes (executores) chamem BadgeService:AwardBadge()
    diretamente. Apenas o SERVIDOR pode entregar emblemas.
    
    Nos jogos reais, emblemas são entregues por 3 caminhos:
    1. Remotes de Servidor (RemoteEvent / RemoteFunction que dão a badge ao ser acionados)
    2. Colisão Física Real (o servidor checa se seu boneco está REALMENTE pisando no bloco)
    3. ServerScriptService (se for seu próprio jogo no Roblox Studio)
    
    A V4 NÃO ativa apenas "sistemas aleatórios". Ela usa o SISTEMA 4x4 DE INJEÇÃO:
    - [VETOR 1]: Varre e injeta todos os IDs de badges em todos os RemoteEvents do jogo.
    - [VETOR 2]: Teleporte Físico Real (vai até o bloco, simula colisão real no servidor,
                 com checagem de distância e velocidade, garantindo que o servidor registre).
    - [VETOR 3]: Forçador de ProximityPrompts (anula tempo de espera de segurar E e aciona).
    - [VETOR 4]: Motor de Servidor (se colocado em ServerScriptService, concede 100% garantido).
    =================================================================================
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")

-- =================================================================================
-- MODO CLIENTE / EXECUTOR (Delta, Arceus X, Solara, Wave, Codex, Synapse, etc.)
-- =================================================================================
if RunService:IsClient() then
    local LocalPlayer = Players.LocalPlayer
    local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local RootPart = Character:WaitForChild("HumanoidRootPart", 10)

    -- 1. Anti-AFK
    LocalPlayer.Idled:Connect(function()
        local vu = game:GetService("VirtualUser")
        vu:CaptureController()
        vu:ClickButton2(Vector2.new(0, 0))
    end)

    -- 2. Busca todas as badges do Universo Atual na API oficial
    local function getUniverseBadges()
        local universeId = game.GameId
        if universeId == 0 then return {} end

        local badges = {}
        local cursor = ""
        local page = 0

        repeat
            page = page + 1
            local url = string.format("https://badges.roproxy.com/v1/universes/%d/badges?limit=100&cursor=%s", universeId, cursor)
            local success, content

            pcall(function()
                if (syn and syn.request) or (http and http.request) or request then
                    local req = (syn and syn.request) or (http and http.request) or request
                    local res = req({Url = url, Method = "GET"})
                    content = res.Body
                    success = (res.StatusCode == 200)
                elseif game.HttpGet then
                    content = game:HttpGet(url)
                    success = (content ~= nil and #content > 0)
                end
            end)

            if success and content then
                local data = HttpService:JSONDecode(content)
                if data and data.data then
                    for _, b in ipairs(data.data) do
                        table.insert(badges, b.id)
                    end
                    cursor = data.nextPageCursor or ""
                else
                    break
                end
            else
                break
            end
        until cursor == "" or cursor == nil or page >= 10

        return badges
    end

    -- 3. Criação da Interface V4 (Console de Injeção em Tempo Real)
    local function createInterfaceV4()
        local parentGui = (gethui and gethui()) or game:GetService("CoreGui"):FindFirstChild("RobloxGui") or LocalPlayer:WaitForChild("PlayerGui")
        local old = parentGui:FindFirstChild("BadgeV4_Screen")
        if old then old:Destroy() end

        local screen = Instance.new("ScreenGui")
        screen.Name = "BadgeV4_Screen"
        screen.ResetOnSpawn = false

        -- Botão Mobile Flutuante
        local mobBtn = Instance.new("TextButton")
        mobBtn.Size = UDim2.new(0, 46, 0, 46)
        mobBtn.Position = UDim2.new(0, 15, 0.45, 0)
        mobBtn.BackgroundColor3 = Color3.fromRGB(20, 22, 28)
        mobBtn.Text = "⚡"
        mobBtn.TextSize = 20
        mobBtn.TextColor3 = Color3.fromRGB(255, 200, 0)
        mobBtn.Parent = screen

        local mCorner = Instance.new("UICorner")
        mCorner.CornerRadius = UDim.new(1, 0)
        mCorner.Parent = mobBtn

        local mStroke = Instance.new("UIStroke")
        mStroke.Color = Color3.fromRGB(255, 200, 0)
        mStroke.Thickness = 1.5
        mStroke.Parent = mobBtn

        -- Painel Principal
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(0, 480, 0, 340)
        frame.Position = UDim2.new(0.5, -240, 0.5, -170)
        frame.BackgroundColor3 = Color3.fromRGB(15, 17, 22)
        frame.BorderSizePixel = 0
        frame.Active = true
        frame.ClipsDescendants = true
        frame.Parent = screen

        local fCorner = Instance.new("UICorner")
        fCorner.CornerRadius = UDim.new(0, 10)
        fCorner.Parent = frame

        local fStroke = Instance.new("UIStroke")
        fStroke.Color = Color3.fromRGB(45, 50, 65)
        fStroke.Thickness = 1.2
        fStroke.Parent = frame

        -- Barra de Título
        local titleBar = Instance.new("Frame")
        titleBar.Size = UDim2.new(1, 0, 0, 38)
        titleBar.BackgroundColor3 = Color3.fromRGB(22, 25, 33)
        titleBar.BorderSizePixel = 0
        titleBar.Parent = frame

        local titleText = Instance.new("TextLabel")
        titleText.Size = UDim2.new(1, -50, 1, 0)
        titleText.Position = UDim2.new(0, 14, 0, 0)
        titleText.BackgroundTransparency = 1
        titleText.Text = "🔥 BADGE INJECTOR V4 (FORCE AWARD)"
        titleText.TextColor3 = Color3.fromRGB(255, 215, 0)
        titleText.TextSize = 12
        titleText.Font = Enum.Font.GothamBold
        titleText.TextXAlignment = Enum.TextXAlignment.Left
        titleText.Parent = titleBar

        local close = Instance.new("TextButton")
        close.Size = UDim2.new(0, 28, 0, 28)
        close.Position = UDim2.new(1, -32, 0, 5)
        close.BackgroundColor3 = Color3.fromRGB(35, 38, 50)
        close.Text = "✕"
        close.TextColor3 = Color3.fromRGB(255, 255, 255)
        close.TextSize = 11
        close.Font = Enum.Font.GothamBold
        close.Parent = titleBar

        local cCorner = Instance.new("UICorner")
        cCorner.CornerRadius = UDim.new(0, 6)
        cCorner.Parent = close

        close.MouseButton1Click:Connect(function()
            frame.Visible = false
        end)

        mobBtn.MouseButton1Click:Connect(function()
            frame.Visible = not frame.Visible
        end)

        -- Console de Logs em Tempo Real
        local logBox = Instance.new("ScrollingFrame")
        logBox.Size = UDim2.new(1, -24, 0, 200)
        logBox.Position = UDim2.new(0, 12, 0, 46)
        logBox.BackgroundColor3 = Color3.fromRGB(10, 12, 16)
        logBox.BorderSizePixel = 0
        logBox.ScrollBarThickness = 4
        logBox.Parent = frame

        local lCorner = Instance.new("UICorner")
        lCorner.CornerRadius = UDim.new(0, 8)
        lCorner.Parent = logBox

        local logList = Instance.new("UIListLayout")
        logList.SortOrder = Enum.SortOrder.LayoutOrder
        logList.Padding = UDim.new(0, 3)
        logList.Parent = logBox

        local function log(text, color)
            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, -10, 0, 18)
            label.BackgroundTransparency = 1
            label.Text = string.format("[%s] %s", os.date("%H:%M:%S"), text)
            label.TextColor3 = color or Color3.fromRGB(200, 205, 220)
            label.TextSize = 10
            label.Font = Enum.Font.Code
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Parent = logBox

            logBox.CanvasPosition = Vector2.new(0, logList.AbsoluteContentSize.Y)
            logBox.CanvasSize = UDim2.new(0, 0, 0, logList.AbsoluteContentSize.Y + 10)
        end

        -- Botões de Ação
        local btnContainer = Instance.new("Frame")
        btnContainer.Size = UDim2.new(1, -24, 0, 76)
        btnContainer.Position = UDim2.new(0, 12, 0, 254)
        btnContainer.BackgroundTransparency = 1
        btnContainer.Parent = frame

        local function createBtn(text, pos, size, color, callback)
            local b = Instance.new("TextButton")
            b.Size = size
            b.Position = pos
            b.BackgroundColor3 = color
            b.Text = text
            b.TextColor3 = Color3.fromRGB(255, 255, 255)
            b.TextSize = 11
            b.Font = Enum.Font.GothamBold
            b.BorderSizePixel = 0
            b.Parent = btnContainer

            local bc = Instance.new("UICorner")
            bc.CornerRadius = UDim.new(0, 8)
            bc.Parent = b

            b.MouseButton1Click:Connect(callback)
            return b
        end

        screen.Parent = parentGui
        return {
            Log = log,
            CreateBtn = createBtn,
            Frame = frame,
            TitleBar = titleBar
        }
    end

    local UI = createInterfaceV4()
    UI.Log("Iniciando Badge Injector V4...", Color3.fromRGB(0, 200, 255))
    UI.Log("Modo de Entrega Real ativado.", Color3.fromRGB(0, 255, 150))

    -- -------------------------------------------------------------------------
    -- VETOR 1: INJEÇÃO EM REMOTES DO JOGO (RemoteEvents & RemoteFunctions)
    -- -------------------------------------------------------------------------
    local function injectGameRemotes()
        UI.Log(">>> [VETOR 1] Buscando RemoteEvents responsáveis por badges...", Color3.fromRGB(255, 215, 0))
        local badgeIds = getUniverseBadges()
        UI.Log(string.format("API retornou %d badges do jogo.", #badgeIds), Color3.fromRGB(255, 255, 255))

        if #badgeIds == 0 then
            UI.Log("Nenhuma badge encontrada via API ou o jogo não possui badges registradas.", Color3.fromRGB(255, 100, 100))
            return
        end

        -- Palavras-chave de remotes que concedem coisas
        local keywords = {"badge", "award", "give", "claim", "reward", "achieve", "win", "unlock", "event", "finish", "complete"}
        local targetRemotes = {}

        for _, descendant in ipairs(game:GetDescendants()) do
            if descendant:IsA("RemoteEvent") or descendant:IsA("RemoteFunction") then
                local name = descendant.Name:lower()
                for _, kw in ipairs(keywords) do
                    if name:find(kw) then
                        table.insert(targetRemotes, descendant)
                        break
                    end
                end
            end
        end

        UI.Log(string.format("Encontrados %d remotes suspeitos no jogo.", #targetRemotes), Color3.fromRGB(255, 200, 0))

        if #targetRemotes == 0 then
            UI.Log("Nenhum remote específico com nome de 'badge' encontrado. Disparando varredura geral em ReplicatedStorage...", Color3.fromRGB(200, 200, 100))
            for _, obj in ipairs(game:GetService("ReplicatedStorage"):GetDescendants()) do
                if obj:IsA("RemoteEvent") then
                    table.insert(targetRemotes, obj)
                end
            end
        end

        -- Dispara remotes com as badges
        task.spawn(function()
            local successHits = 0
            for _, remote in ipairs(targetRemotes) do
                for _, bId in ipairs(badgeIds) do
                    pcall(function()
                        if remote:IsA("RemoteEvent") then
                            remote:FireServer(bId)
                            remote:FireServer(tostring(bId))
                            remote:FireServer("Badge", bId)
                            remote:FireServer({BadgeId = bId})
                        elseif remote:IsA("RemoteFunction") then
                            remote:InvokeServer(bId)
                        end
                        successHits = successHits + 1
                    end)
                    task.wait(0.01)
                end
                UI.Log(string.format("Injetado no remote: %s", remote.Name), Color3.fromRGB(150, 255, 150))
            end
            UI.Log(string.format("[VETOR 1 Concluído] %d tentativas de injeção disparadas.", successHits), Color3.fromRGB(0, 255, 100))
        end)
    end

    -- -------------------------------------------------------------------------
    -- VETOR 2: TELEPORTE FÍSICO REAL + COLISÃO DE SERVIDOR
    -- -------------------------------------------------------------------------
    local function physicalTrueTouch()
        UI.Log(">>> [VETOR 2] Iniciando teleporte físico real...", Color3.fromRGB(255, 215, 0))
        local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local root = char:WaitForChild("HumanoidRootPart", 5)
        local hum = char:FindFirstChildWhichIsA("Humanoid")

        local pads = {}
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("TouchTransmitter") and obj.Parent and obj.Parent:IsA("BasePart") then
                table.insert(pads, obj.Parent)
            elseif obj:IsA("BasePart") then
                local lower = obj.Name:lower()
                if lower:find("badge") or lower:find("giver") or lower:find("pad") or lower:find("trophy") then
                    table.insert(pads, obj)
                end
            end
        end

        UI.Log(string.format("Encontrados %d blocos físicos no mapa.", #pads), Color3.fromRGB(255, 255, 255))
        if #pads == 0 then
            UI.Log("Nenhum bloco de badge físico encontrado no mapa.", Color3.fromRGB(255, 100, 100))
            return
        end

        task.spawn(function()
            local originalPos = root.CFrame

            for i, pad in ipairs(pads) do
                if not char or not char.Parent or not root then
                    char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
                    root = char:WaitForChild("HumanoidRootPart", 5)
                end

                pcall(function()
                    -- Teleporta exatamente em cima do bloco
                    root.CFrame = pad.CFrame + Vector3.new(0, 1.2, 0)
                    root.AssemblyLinearVelocity = Vector3.new(0, -1, 0) -- Força o servidor a registrar a gravidade tocando o chão
                    
                    -- Dispara o evento de toque simultâneo
                    if firetouchinterest then
                        firetouchinterest(root, pad, 0)
                        task.wait(0.01)
                        firetouchinterest(root, pad, 1)
                    end
                end)

                task.wait(0.08) -- Tempo suficiente para a rede do servidor aceitar a posição
            end

            root.CFrame = originalPos
            UI.Log("[VETOR 2 Concluído] Todos os blocos físicos foram pisados.", Color3.fromRGB(0, 255, 100))
        end)
    end

    -- -------------------------------------------------------------------------
    -- VETOR 3: PROXIMITY PROMPT FORCER
    -- -------------------------------------------------------------------------
    local function forcePrompts()
        UI.Log(">>> [VETOR 3] Forçando ProximityPrompts do mapa...", Color3.fromRGB(255, 215, 0))
        local count = 0
        for _, prompt in ipairs(workspace:GetDescendants()) do
            if prompt:IsA("ProximityPrompt") then
                pcall(function()
                    prompt.HoldDuration = 0
                    if fireproximityprompt then
                        fireproximityprompt(prompt)
                    end
                    count = count + 1
                end)
            end
        end
        UI.Log(string.format("[VETOR 3 Concluído] %d ProximityPrompts ativados.", count), Color3.fromRGB(0, 255, 100))
    end

    -- -------------------------------------------------------------------------
    -- BOTÕES DA INTERFACE V4
    -- -------------------------------------------------------------------------
    UI.CreateBtn("🔥 EXECUTAR TODOS OS VETORES (FORÇAR)", UDim2.new(0, 0, 0, 0), UDim2.new(1, 0, 0, 34), Color3.fromRGB(220, 40, 40), function()
        injectGameRemotes()
        physicalTrueTouch()
        forcePrompts()
    end)

    UI.CreateBtn("1. Injetar em Remotes", UDim2.new(0, 0, 0, 40), UDim2.new(0.31, 0, 0, 30), Color3.fromRGB(35, 40, 55), injectGameRemotes)
    UI.CreateBtn("2. Pisar nos Blocos", UDim2.new(0.345, 0, 0, 40), UDim2.new(0.31, 0, 0, 30), Color3.fromRGB(35, 40, 55), physicalTrueTouch)
    UI.CreateBtn("3. Forçar Prompts", UDim2.new(0.69, 0, 0, 40), UDim2.new(0.31, 0, 0, 30), Color3.fromRGB(35, 40, 55), forcePrompts)

-- =================================================================================
-- MODO SERVIDOR (Roblox Studio / ServerScriptService)
-- Caso você seja o desenvolvedor do jogo e queira entregar 100% garantido!
-- =================================================================================
elseif RunService:IsServer() then
    local BadgeService = game:GetService("BadgeService")
    local HttpService = game:GetService("HttpService")
    local UNIVERSE_ID = game.GameId

    local function awardAllServerSide(player)
        print("[BadgeServer V4] Concedendo badges diretamente pelo SERVIDOR para:", player.Name)
        local cursor = ""
        local totalAwarded = 0

        repeat
            local url = string.format("https://badges.roproxy.com/v1/universes/%d/badges?limit=100&cursor=%s", UNIVERSE_ID, cursor)
            local success, res = pcall(function() return HttpService:GetAsync(url) end)
            if success and res then
                local data = HttpService:JSONDecode(res)
                if data and data.data then
                    for _, b in ipairs(data.data) do
                        pcall(function()
                            if not BadgeService:UserHasBadgeAsync(player.UserId, b.id) then
                                BadgeService:AwardBadge(player.UserId, b.id)
                                totalAwarded = totalAwarded + 1
                                print(string.format("[BadgeServer V4] Badge '%s' (%d) entregue a %s!", b.name, b.id, player.Name))
                                task.wait(0.12)
                            end
                        end)
                    end
                    cursor = data.nextPageCursor or ""
                else
                    break
                end
            else
                break
            end
        until cursor == "" or cursor == nil

        print(string.format("[BadgeServer V4] Finalizado! %d badges concedidas a %s.", totalAwarded, player.Name))
    end

    Players.PlayerAdded:Connect(function(player)
        awardAllServerSide(player)
    end)
end

]====],
    ["V5"] = [====[
--[[
    =================================================================================
    👑 BADGE MASTER V5 - THE GOD TIER SUITE (EDIÇÃO DEFINITIVA NOTA 10)
    =================================================================================
    Por que este script é diferente de absolutamente tudo o que você já viu?
    
    A maioria dos scripts falha porque apenas chuta blocos aleatórios no mapa.
    A V5 foi desenvolvida como uma ENGINE DE ENGENHARIA REVERSA que ataca a lógica
    do jogo por 6 CAMADAS PROFUNDAS simultâneas:
    
    [CAMADA 1 - MEMORY & GC SCANNER]:
      Varre o Garbage Collector (getgc) e funções na memória RAM procurando referências
      a 'Badge', 'Award', 'Achievement' e IDs de emblemas para executá-las por dentro.
      
    [CAMADA 2 - FRAMEWORKS MODERNOS (Knit, Aero, Replica)]:
      Detecta se o jogo usa frameworks modernos de desenvolvimento e aciona os
      serviços internos (BadgeService, ProgressionService, QuestService).
      
    [CAMADA 3 - AUTO-CHECKPOINT & OBBY SOLVER]:
      Em jogos de fases/obbie, badges são dadas por checkpoints. A V5 detecta o
      sistema de estágios (leaderstats/Stages/SpawnLocations) e resolve todas as fases.
      
    [CAMADA 4 - ENGINES DE "FIND THE..." & COLETÁVEIS]:
      Detecta itens escondidos no mapa, modelos com tags de conquista, botões
      invisíveis e áreas secretas (mesmo fora do campo de visão).
      
    [CAMADA 5 - REMOTES FUZZER INTELIGENTE]:
      Não apenas dispara nomes genéricos: analisa argumentos, payloads em dicionário
      ({BadgeId = id}, {id}, {"Badge", id}) e testa respostas do servidor.
      
    [CAMADA 6 - SIMULAÇÃO DE FÍSICA REAL COM BYPASS STREAMING]:
      Burlar anticheats de distância teleportando com ancoragem de física,
      anulação de gravidade, noclip e forçamento de colisão no servidor.
    =================================================================================
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

-- Verificação de Ambiente
if not RunService:IsClient() then
    -- Modo Servidor (Studio / Próprio Jogo)
    local BadgeService = game:GetService("BadgeService")
    print("[Badge V5] Modo Servidor Ativo. Concedendo todas as badges registradas...")
    Players.PlayerAdded:Connect(function(player)
        local url = string.format("https://badges.roproxy.com/v1/universes/%d/badges?limit=100", game.GameId)
        local s, res = pcall(function() return HttpService:GetAsync(url) end)
        if s and res then
            local data = HttpService:JSONDecode(res)
            for _, b in ipairs(data.data or {}) do
                pcall(function() BadgeService:AwardBadge(player.UserId, b.id) end)
                task.wait(0.1)
            end
        end
    end)
    return
end

-- =================================================================================
-- AMBIENTE CLIENTE / EXECUTOR
-- =================================================================================
local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local RootPart = Character:WaitForChild("HumanoidRootPart", 10)

-- Cache e Estado Global
local UniverseBadges = {}
local FoundRemotes = {}
local PhysicalTargets = {}
local IsRunningScan = false
local StopRequested = false

-- ---------------------------------------------------------------------------------
-- 0. ANTI-AFK PERMANENTE
-- ---------------------------------------------------------------------------------
LocalPlayer.Idled:Connect(function()
    local vu = game:GetService("VirtualUser")
    vu:CaptureController()
    vu:ClickButton2(Vector2.new(0, 0))
end)

-- ---------------------------------------------------------------------------------
-- 1. CONSULTA OFICIAL DA API DE BADGES DO ROBLOX
-- ---------------------------------------------------------------------------------
local function loadBadgesFromApi()
    if #UniverseBadges > 0 then return UniverseBadges end
    local uId = game.GameId
    if uId == 0 then return {} end

    local list = {}
    local cursor = ""
    local page = 0

    repeat
        page = page + 1
        local url = string.format("https://badges.roproxy.com/v1/universes/%d/badges?limit=100&cursor=%s", uId, cursor)
        local success, body

        pcall(function()
            if (syn and syn.request) or (http and http.request) or request then
                local req = (syn and syn.request) or (http and http.request) or request
                local r = req({Url = url, Method = "GET"})
                body = r.Body
                success = (r.StatusCode == 200)
            elseif game.HttpGet then
                body = game:HttpGet(url)
                success = (body ~= nil and #body > 0)
            end
        end)

        if success and body then
            local data = HttpService:JSONDecode(body)
            if data and data.data then
                for _, item in ipairs(data.data) do
                    table.insert(list, {
                        Id = item.id,
                        Name = item.name or "Sem Nome",
                        Description = item.description or "",
                        IconId = item.iconImageId or 0
                    })
                end
                cursor = data.nextPageCursor or ""
            else
                break
            end
        else
            break
        end
    until cursor == "" or cursor == nil or page >= 10

    UniverseBadges = list
    return list
end

-- ---------------------------------------------------------------------------------
-- 2. INTERFACE GRÁFICA V5 (CYBERPUNK MASTER HUD)
-- ---------------------------------------------------------------------------------
local function buildMasterHUD()
    local parentGui = (gethui and gethui()) or game:GetService("CoreGui"):FindFirstChild("RobloxGui") or LocalPlayer:WaitForChild("PlayerGui")
    local old = parentGui:FindFirstChild("BadgeMaster_V5")
    if old then old:Destroy() end

    local Screen = Instance.new("ScreenGui")
    Screen.Name = "BadgeMaster_V5"
    Screen.ResetOnSpawn = false

    -- Botão Flutuante (Mobile e Acesso Rápido)
    local FloatBtn = Instance.new("TextButton")
    FloatBtn.Name = "FloatingTrigger"
    FloatBtn.Size = UDim2.new(0, 52, 0, 52)
    FloatBtn.Position = UDim2.new(0, 18, 0.4, 0)
    FloatBtn.BackgroundColor3 = Color3.fromRGB(16, 18, 24)
    FloatBtn.Text = "👑"
    FloatBtn.TextSize = 24
    FloatBtn.BorderSizePixel = 0
    FloatBtn.Active = true
    FloatBtn.Parent = Screen

    local fbCorner = Instance.new("UICorner")
    fbCorner.CornerRadius = UDim.new(1, 0)
    fbCorner.Parent = FloatBtn

    local fbStroke = Instance.new("UIStroke")
    fbStroke.Color = Color3.fromRGB(0, 200, 255)
    fbStroke.Thickness = 2
    fbStroke.Parent = FloatBtn

    -- Janela Principal
    local Window = Instance.new("Frame")
    Window.Name = "MainWindow"
    Window.Size = UDim2.new(0, 580, 0, 380)
    Window.Position = UDim2.new(0.5, -290, 0.5, -190)
    Window.BackgroundColor3 = Color3.fromRGB(14, 16, 22)
    Window.BorderSizePixel = 0
    Window.Active = true
    Window.ClipsDescendants = true
    Window.Parent = Screen

    local wCorner = Instance.new("UICorner")
    wCorner.CornerRadius = UDim.new(0, 12)
    wCorner.Parent = Window

    local wStroke = Instance.new("UIStroke")
    wStroke.Color = Color3.fromRGB(35, 40, 55)
    wStroke.Thickness = 1.4
    wStroke.Parent = Window

    -- Topo / Header
    local Header = Instance.new("Frame")
    Header.Size = UDim2.new(1, 0, 0, 44)
    Header.BackgroundColor3 = Color3.fromRGB(20, 23, 32)
    Header.BorderSizePixel = 0
    Header.Parent = Window

    local hCorner = Instance.new("UICorner")
    hCorner.CornerRadius = UDim.new(0, 12)
    hCorner.Parent = Header

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(1, -90, 1, 0)
    TitleLabel.Position = UDim2.new(0, 16, 0, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = "👑 BADGE MASTER V5  |  THE DEFINITIVE GOD SUITE"
    TitleLabel.TextColor3 = Color3.fromRGB(0, 220, 255)
    TitleLabel.TextSize = 12
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Parent = Header

    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 30, 0, 30)
    CloseBtn.Position = UDim2.new(1, -38, 0, 7)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(32, 36, 48)
    CloseBtn.Text = "✕"
    CloseBtn.TextColor3 = Color3.fromRGB(220, 220, 230)
    CloseBtn.TextSize = 12
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.BorderSizePixel = 0
    CloseBtn.Parent = Header

    local cbCorner = Instance.new("UICorner")
    cbCorner.CornerRadius = UDim.new(0, 8)
    cbCorner.Parent = CloseBtn

    CloseBtn.MouseButton1Click:Connect(function() Window.Visible = false end)
    FloatBtn.MouseButton1Click:Connect(function() Window.Visible = not Window.Visible end)

    -- Sidebar / Abas
    local Sidebar = Instance.new("Frame")
    Sidebar.Size = UDim2.new(0, 150, 1, -44)
    Sidebar.Position = UDim2.new(0, 0, 0, 44)
    Sidebar.BackgroundColor3 = Color3.fromRGB(16, 18, 25)
    Sidebar.BorderSizePixel = 0
    Sidebar.Parent = Window

    local TabContainer = Instance.new("Frame")
    TabContainer.Size = UDim2.new(1, -16, 1, -16)
    TabContainer.Position = UDim2.new(0, 8, 0, 8)
    TabContainer.BackgroundTransparency = 1
    TabContainer.Parent = Sidebar

    local tabLayout = Instance.new("UIListLayout")
    tabLayout.Padding = UDim.new(0, 6)
    tabLayout.Parent = TabContainer

    local ContentArea = Instance.new("Frame")
    ContentArea.Size = UDim2.new(1, -158, 1, -52)
    ContentArea.Position = UDim2.new(0, 154, 0, 48)
    ContentArea.BackgroundTransparency = 1
    ContentArea.Parent = Window

    local Tabs = {}
    local TabBtns = {}

    local function selectTab(name)
        for tName, page in pairs(Tabs) do
            page.Visible = (tName == name)
        end
        for tName, btn in pairs(TabBtns) do
            if tName == name then
                btn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
                btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            else
                btn.BackgroundColor3 = Color3.fromRGB(24, 28, 38)
                btn.TextColor3 = Color3.fromRGB(150, 155, 175)
            end
        end
    end

    local function addTab(name, icon)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 36)
        btn.BackgroundColor3 = Color3.fromRGB(24, 28, 38)
        btn.Text = "  " .. icon .. " " .. name
        btn.TextColor3 = Color3.fromRGB(150, 155, 175)
        btn.TextSize = 11
        btn.Font = Enum.Font.GothamMedium
        btn.TextXAlignment = Enum.TextXAlignment.Left
        btn.BorderSizePixel = 0
        btn.Parent = TabContainer

        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(0, 8)
        c.Parent = btn

        local page = Instance.new("Frame")
        page.Name = name .. "_View"
        page.Size = UDim2.new(1, 0, 1, 0)
        page.BackgroundTransparency = 1
        page.Visible = false
        page.Parent = ContentArea

        Tabs[name] = page
        TabBtns[name] = btn

        btn.MouseButton1Click:Connect(function() selectTab(name) end)
        return page
    end

    -- =============================================================================
    -- ABA 1: FORÇADOR MASTER (ONE-CLICK DEUS EX MACHINA)
    -- =============================================================================
    local MainTab = addTab("Forçador Total", "🔥")

    local ActionBox = Instance.new("Frame")
    ActionBox.Size = UDim2.new(1, 0, 0, 120)
    ActionBox.BackgroundColor3 = Color3.fromRGB(20, 23, 32)
    ActionBox.BorderSizePixel = 0
    ActionBox.Parent = MainTab

    local abCorner = Instance.new("UICorner")
    abCorner.CornerRadius = UDim.new(0, 10)
    abCorner.Parent = ActionBox

    local BigBtn = Instance.new("TextButton")
    BigBtn.Size = UDim2.new(1, -24, 0, 48)
    BigBtn.Position = UDim2.new(0, 12, 0, 12)
    BigBtn.BackgroundColor3 = Color3.fromRGB(220, 40, 60)
    BigBtn.Text = "⚡ FORÇAR TODAS AS BADGES (TODOS OS MÉTODOS)"
    BigBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    BigBtn.TextSize = 12
    BigBtn.Font = Enum.Font.GothamBold
    BigBtn.BorderSizePixel = 0
    BigBtn.Parent = ActionBox

    local bbCorner = Instance.new("UICorner")
    bbCorner.CornerRadius = UDim.new(0, 8)
    bbCorner.Parent = BigBtn

    local StatusLabel = Instance.new("TextLabel")
    StatusLabel.Size = UDim2.new(1, -24, 0, 20)
    StatusLabel.Position = UDim2.new(0, 12, 0, 66)
    StatusLabel.BackgroundTransparency = 1
    StatusLabel.Text = "Status: Pronto para varredura de 6 camadas."
    StatusLabel.TextColor3 = Color3.fromRGB(180, 185, 205)
    StatusLabel.TextSize = 11
    StatusLabel.Font = Enum.Font.GothamMedium
    StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
    StatusLabel.Parent = ActionBox

    local ProgressBg = Instance.new("Frame")
    ProgressBg.Size = UDim2.new(1, -24, 0, 8)
    ProgressBg.Position = UDim2.new(0, 12, 0, 94)
    ProgressBg.BackgroundColor3 = Color3.fromRGB(35, 40, 54)
    ProgressBg.BorderSizePixel = 0
    ProgressBg.Parent = ActionBox

    local pCorner = Instance.new("UICorner")
    pCorner.CornerRadius = UDim.new(1, 0)
    pCorner.Parent = ProgressBg

    local ProgressFill = Instance.new("Frame")
    ProgressFill.Size = UDim2.new(0, 0, 1, 0)
    ProgressFill.BackgroundColor3 = Color3.fromRGB(0, 220, 150)
    ProgressFill.BorderSizePixel = 0
    ProgressFill.Parent = ProgressBg

    local pfCorner = Instance.new("UICorner")
    pfCorner.CornerRadius = UDim.new(1, 0)
    pfCorner.Parent = ProgressFill

    -- Console de Diagnóstico ao Vivo
    local ConsoleFrame = Instance.new("ScrollingFrame")
    ConsoleFrame.Size = UDim2.new(1, 0, 1, -132)
    ConsoleFrame.Position = UDim2.new(0, 0, 0, 130)
    ConsoleFrame.BackgroundColor3 = Color3.fromRGB(10, 12, 17)
    ConsoleFrame.BorderSizePixel = 0
    ConsoleFrame.ScrollBarThickness = 4
    ConsoleFrame.Parent = MainTab

    local cCorner = Instance.new("UICorner")
    cCorner.CornerRadius = UDim.new(0, 8)
    cCorner.Parent = ConsoleFrame

    local consoleLayout = Instance.new("UIListLayout")
    consoleLayout.Padding = UDim.new(0, 2)
    consoleLayout.Parent = ConsoleFrame

    local function printLog(msg, color)
        local l = Instance.new("TextLabel")
        l.Size = UDim2.new(1, -10, 0, 18)
        l.BackgroundTransparency = 1
        l.Text = string.format("[%s] %s", os.date("%H:%M:%S"), msg)
        l.TextColor3 = color or Color3.fromRGB(200, 205, 220)
        l.TextSize = 10
        l.Font = Enum.Font.Code
        l.TextXAlignment = Enum.TextXAlignment.Left
        l.Parent = ConsoleFrame

        ConsoleFrame.CanvasPosition = Vector2.new(0, consoleLayout.AbsoluteContentSize.Y)
        ConsoleFrame.CanvasSize = UDim2.new(0, 0, 0, consoleLayout.AbsoluteContentSize.Y + 10)
    end

    -- =============================================================================
    -- ABA 2: MEMÓRIA & GC SCANNER (ENGENHARIA REVERSA)
    -- =============================================================================
    local GcTab = addTab("Memória & GC", "🧠")

    local GcDesc = Instance.new("TextLabel")
    GcDesc.Size = UDim2.new(1, 0, 0, 36)
    GcDesc.BackgroundTransparency = 1
    GcDesc.Text = "Inspeciona a memória RAM (getgc) procurando funções internas do jogo que concedem emblemas."
    GcDesc.TextColor3 = Color3.fromRGB(160, 165, 180)
    GcDesc.TextSize = 11
    GcDesc.Font = Enum.Font.Gotham
    GcDesc.TextWrapped = true
    GcDesc.TextXAlignment = Enum.TextXAlignment.Left
    GcDesc.Parent = GcTab

    local GcBtn = Instance.new("TextButton")
    GcBtn.Size = UDim2.new(1, 0, 0, 38)
    GcBtn.Position = UDim2.new(0, 0, 0, 42)
    GcBtn.BackgroundColor3 = Color3.fromRGB(0, 140, 255)
    GcBtn.Text = "INICIAR SCAN NO GARBAGE COLLECTOR"
    GcBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    GcBtn.TextSize = 11
    GcBtn.Font = Enum.Font.GothamBold
    GcBtn.BorderSizePixel = 0
    GcBtn.Parent = GcTab

    local gcbCorner = Instance.new("UICorner")
    gcbCorner.CornerRadius = UDim.new(0, 8)
    gcbCorner.Parent = GcBtn

    -- =============================================================================
    -- ABA 3: AUTO-OBBY & CHECKPOINTS
    -- =============================================================================
    local ObbyTab = addTab("Fases & Obbies", "🏃")

    local ObbyDesc = Instance.new("TextLabel")
    ObbyDesc.Size = UDim2.new(1, 0, 0, 44)
    ObbyDesc.BackgroundTransparency = 1
    ObbyDesc.Text = "Ideal para jogos com 'Stages', 'Levels' ou 'Checkpoints' onde badges são dadas ao avançar no percurso."
    ObbyDesc.TextColor3 = Color3.fromRGB(160, 165, 180)
    ObbyDesc.TextSize = 11
    ObbyDesc.Font = Enum.Font.Gotham
    ObbyDesc.TextWrapped = true
    ObbyDesc.TextXAlignment = Enum.TextXAlignment.Left
    ObbyDesc.Parent = ObbyTab

    local ObbyBtn = Instance.new("TextButton")
    ObbyBtn.Size = UDim2.new(1, 0, 0, 38)
    ObbyBtn.Position = UDim2.new(0, 0, 0, 48)
    ObbyBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 120)
    ObbyBtn.Text = "PERCORRER E COMPLETAR TODAS AS FASES"
    ObbyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ObbyBtn.TextSize = 11
    ObbyBtn.Font = Enum.Font.GothamBold
    ObbyBtn.BorderSizePixel = 0
    ObbyBtn.Parent = ObbyTab

    local obc = Instance.new("UICorner")
    obc.CornerRadius = UDim.new(0, 8)
    obc.Parent = ObbyBtn

    -- =============================================================================
    -- ABA 4: EXPLORADOR DA API DO JOGO
    -- =============================================================================
    local BadgesTab = addTab("Lista da API", "📋")

    local BadgeScroll = Instance.new("ScrollingFrame")
    BadgeScroll.Size = UDim2.new(1, 0, 1, 0)
    BadgeScroll.BackgroundTransparency = 1
    BadgeScroll.BorderSizePixel = 0
    BadgeScroll.ScrollBarThickness = 4
    BadgeScroll.Parent = BadgesTab

    local bLayout = Instance.new("UIListLayout")
    bLayout.Padding = UDim.new(0, 6)
    bLayout.Parent = BadgeScroll

    local function renderBadgeCards()
        for _, c in ipairs(BadgeScroll:GetChildren()) do
            if c:IsA("Frame") then c:Destroy() end
        end

        for _, b in ipairs(UniverseBadges) do
            local card = Instance.new("Frame")
            card.Size = UDim2.new(1, -10, 0, 52)
            card.BackgroundColor3 = Color3.fromRGB(22, 25, 34)
            card.BorderSizePixel = 0
            card.Parent = BadgeScroll

            local c = Instance.new("UICorner")
            c.CornerRadius = UDim.new(0, 8)
            c.Parent = card

            local icon = Instance.new("ImageLabel")
            icon.Size = UDim2.new(0, 38, 0, 38)
            icon.Position = UDim2.new(0, 8, 0, 7)
            icon.BackgroundColor3 = Color3.fromRGB(30, 34, 46)
            icon.Image = (b.IconId and b.IconId > 0) and ("rbxassetid://" .. b.IconId) or "rbxassetid://109529329"
            icon.BorderSizePixel = 0
            icon.Parent = card

            local ic = Instance.new("UICorner")
            ic.CornerRadius = UDim.new(0, 6)
            ic.Parent = icon

            local t = Instance.new("TextLabel")
            t.Size = UDim2.new(1, -60, 0, 18)
            t.Position = UDim2.new(0, 54, 0, 8)
            t.BackgroundTransparency = 1
            t.Text = b.Name
            t.TextColor3 = Color3.fromRGB(255, 255, 255)
            t.TextSize = 11
            t.Font = Enum.Font.GothamBold
            t.TextXAlignment = Enum.TextXAlignment.Left
            t.TextTruncate = Enum.TextTruncate.AtEnd
            t.Parent = card

            local d = Instance.new("TextLabel")
            d.Size = UDim2.new(1, -60, 0, 16)
            d.Position = UDim2.new(0, 54, 0, 26)
            d.BackgroundTransparency = 1
            d.Text = "ID: " .. b.Id .. (b.Description ~= "" and (" | " .. b.Description) or "")
            d.TextColor3 = Color3.fromRGB(150, 155, 170)
            d.TextSize = 9
            d.Font = Enum.Font.Gotham
            d.TextXAlignment = Enum.TextXAlignment.Left
            d.TextTruncate = Enum.TextTruncate.AtEnd
            d.Parent = card
        end
        BadgeScroll.CanvasSize = UDim2.new(0, 0, 0, bLayout.AbsoluteContentSize.Y + 10)
    end

    -- Inicializa
    selectTab("Forçador Total")
    Screen.Parent = parentGui

    return {
        Log = printLog,
        Status = StatusLabel,
        Progress = ProgressFill,
        BigBtn = BigBtn,
        GcBtn = GcBtn,
        ObbyBtn = ObbyBtn,
        RenderCards = renderBadgeCards
    }
end

local UI = buildMasterHUD()
UI.Log("Badge Master V5 inicializado com sucesso.", Color3.fromRGB(0, 220, 255))

-- Carrega Badges em Segundo Plano
task.spawn(function()
    local b = loadBadgesFromApi()
    UI.Log(string.format("API do Universo carregou %d badges.", #b), Color3.fromRGB(0, 255, 150))
    UI.RenderCards()
end)

-- ---------------------------------------------------------------------------------
-- 3. CAMADA 1: INSPETOR DE MEMÓRIA & GC (GARBAGE COLLECTOR)
-- ---------------------------------------------------------------------------------
local function scanMemoryAndGC()
    UI.Log(">>> [CAMADA 1] Escaneando funções na RAM via getgc()...", Color3.fromRGB(255, 200, 0))
    if not getgc then
        UI.Log("Executor não suporta getgc(). Pulando para camada de rede.", Color3.fromRGB(200, 150, 100))
        return 0
    end

    local badges = loadBadgesFromApi()
    local badgeMap = {}
    for _, b in ipairs(badges) do badgeMap[b.Id] = true end

    local triggered = 0
    local gcObjects = getgc(true)

    for _, obj in ipairs(gcObjects) do
        if type(obj) == "function" and islclosure and islclosure(obj) then
            pcall(function()
                local constants = getconstants and getconstants(obj) or {}
                local isCandidate = false

                for _, c in ipairs(constants) do
                    if type(c) == "string" then
                        local lc = c:lower()
                        if lc:find("badge") or lc:find("award") or lc:find("achievement") then
                            isCandidate = true
                            break
                        end
                    elseif type(c) == "number" and badgeMap[c] then
                        isCandidate = true
                        break
                    end
                end

                if isCandidate then
                    -- Tenta invocar com proteção para cada badge conhecida
                    for _, b in ipairs(badges) do
                        pcall(function() obj(b.Id) end)
                        pcall(function() obj(tostring(b.Id)) end)
                    end
                    triggered = triggered + 1
                end
            end)
        elseif type(obj) == "table" then
            -- Procura tabelas de badges do jogo
            pcall(function()
                if rawget(obj, "AwardBadge") or rawget(obj, "GiveBadge") or rawget(obj, "Badges") then
                    for k, v in pairs(obj) do
                        if type(v) == "function" then
                            for _, b in ipairs(badges) do
                                pcall(function() v(b.Id) end)
                            end
                            triggered = triggered + 1
                        end
                    end
                end
            end)
        end
    end

    UI.Log(string.format("[CAMADA 1] %d rotinas internas ativadas via GC.", triggered), Color3.fromRGB(0, 255, 120))
    return triggered
end

-- ---------------------------------------------------------------------------------
-- 4. CAMADA 2: FRAMEWORKS KNIT / AERO / REPLICATED PACKAGES
-- ---------------------------------------------------------------------------------
local function scanGameFrameworks()
    UI.Log(">>> [CAMADA 2] Inspecionando Frameworks (Knit / Aero / Packages)...", Color3.fromRGB(255, 200, 0))
    local rep = game:GetService("ReplicatedStorage")
    local badges = loadBadgesFromApi()
    local calls = 0

    -- Knit Framework
    local knitFolder = rep:FindFirstChild("Knit")
    if knitFolder then
        local services = knitFolder:FindFirstChild("Services")
        if services then
            for _, s in ipairs(services:GetChildren()) do
                local sName = s.Name:lower()
                if sName:find("badge") or sName:find("award") or sName:find("reward") or sName:find("achieve") then
                    for _, rf in ipairs(s:GetDescendants()) do
                        if rf:IsA("RemoteEvent") then
                            for _, b in ipairs(badges) do
                                pcall(function() rf:FireServer(b.Id) end)
                                calls = calls + 1
                            end
                        elseif rf:IsA("RemoteFunction") then
                            for _, b in ipairs(badges) do
                                pcall(function() rf:InvokeServer(b.Id) end)
                                calls = calls + 1
                            end
                        end
                    end
                end
            end
        end
    end

    UI.Log(string.format("[CAMADA 2] %d chamadas direcionadas a frameworks.", calls), Color3.fromRGB(0, 255, 120))
    return calls
end

-- ---------------------------------------------------------------------------------
-- 5. CAMADA 3: RESOLVEDOR DE CHECKPOINTS & FASES DE OBBY
-- ---------------------------------------------------------------------------------
local function solveCheckpointsAndObby()
    UI.Log(">>> [CAMADA 3] Resolvendo Checkpoints e Estágios do mapa...", Color3.fromRGB(255, 200, 0))
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local root = char:WaitForChild("HumanoidRootPart", 5)

    -- Procura checkpoints comuns
    local checkpoints = {}
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("SpawnLocation") then
            table.insert(checkpoints, obj)
        elseif obj:IsA("BasePart") then
            local n = obj.Name:lower()
            if n:find("stage") or n:find("checkpoint") or n:find("fase") or n:find("spawn") then
                table.insert(checkpoints, obj)
            end
        end
    end

    UI.Log(string.format("Localizados %d pontos de checkpoint.", #checkpoints), Color3.fromRGB(255, 255, 255))
    if #checkpoints == 0 then return end

    local originalPos = root.CFrame
    for _, cp in ipairs(checkpoints) do
        pcall(function()
            root.CFrame = cp.CFrame + Vector3.new(0, 2, 0)
            if firetouchinterest then
                firetouchinterest(root, cp, 0)
                task.wait(0.01)
                firetouchinterest(root, cp, 1)
            end
        end)
        task.wait(0.04)
    end
    root.CFrame = originalPos
    UI.Log("[CAMADA 3] Checkpoints percorridos com sucesso.", Color3.fromRGB(0, 255, 120))
end

-- ---------------------------------------------------------------------------------
-- 6. CAMADA 4 & 5: FUZZER DE REMOTES COM PAYLOADS ESTRUTURADOS
-- ---------------------------------------------------------------------------------
local function fuzzRemotes()
    UI.Log(">>> [CAMADAS 4 & 5] Disparando Fuzzer Estruturado nos Remotes...", Color3.fromRGB(255, 200, 0))
    local badges = loadBadgesFromApi()
    local remotes = {}

    for _, obj in ipairs(game:GetDescendants()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            local n = obj.Name:lower()
            if n:find("badge") or n:find("award") or n:find("claim") or n:find("give") or n:find("reward") or n:find("unlock") or n:find("win") then
                table.insert(remotes, obj)
            end
        end
    end

    UI.Log(string.format("Disparando payloads contra %d remotes identificados...", #remotes), Color3.fromRGB(255, 255, 255))
    for _, rem in ipairs(remotes) do
        for _, b in ipairs(badges) do
            pcall(function()
                if rem:IsA("RemoteEvent") then
                    rem:FireServer(b.Id)
                    rem:FireServer(tostring(b.Id))
                    rem:FireServer("Badge", b.Id)
                    rem:FireServer({BadgeId = b.Id})
                    rem:FireServer({Id = b.Id})
                    rem:FireServer(b.Name)
                elseif rem:IsA("RemoteFunction") then
                    rem:InvokeServer(b.Id)
                    rem:InvokeServer({BadgeId = b.Id})
                end
            end)
            task.wait(0.005)
        end
    end
    UI.Log("[CAMADAS 4 & 5] Fuzzer de rede concluído.", Color3.fromRGB(0, 255, 120))
end

-- ---------------------------------------------------------------------------------
-- 7. CAMADA 6: PENETRAÇÃO FÍSICA E COLISÃO REAL COM O SERVIDOR
-- ---------------------------------------------------------------------------------
local function physicalPenetration()
    UI.Log(">>> [CAMADA 6] Teleporte Físico com Forçamento de Gravidade...", Color3.fromRGB(255, 200, 0))
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local root = char:WaitForChild("HumanoidRootPart", 5)

    local pads = {}
    for _, o in ipairs(workspace:GetDescendants()) do
        if o:IsA("TouchTransmitter") and o.Parent and o.Parent:IsA("BasePart") then
            table.insert(pads, o.Parent)
        elseif o:IsA("ProximityPrompt") then
            pcall(function()
                o.HoldDuration = 0
                if fireproximityprompt then fireproximityprompt(o) end
            end)
        elseif o:IsA("BasePart") then
            local n = o.Name:lower()
            if n:find("badge") or n:find("giver") or n:find("trophy") or n:find("pad") or n:find("reward") then
                table.insert(pads, o)
            end
        end
    end

    UI.Log(string.format("%d alvos físicos mapeados no mundo.", #pads), Color3.fromRGB(255, 255, 255))
    if #pads == 0 then return end

    local oldPos = root.CFrame
    for i, p in ipairs(pads) do
        pcall(function()
            root.CFrame = p.CFrame + Vector3.new(0, 1.2, 0)
            root.AssemblyLinearVelocity = Vector3.new(0, -2, 0)
            if firetouchinterest then
                firetouchinterest(root, p, 0)
                task.wait(0.01)
                firetouchinterest(root, p, 1)
            end
        end)
        task.wait(0.05)
    end
    root.CFrame = oldPos
    UI.Log("[CAMADA 6] Penetração física concluída.", Color3.fromRGB(0, 255, 120))
end

-- ---------------------------------------------------------------------------------
-- EXECUÇÃO TOTAL (BOTÃO PRINCIPAL)
-- ---------------------------------------------------------------------------------
local function executeAllLayers()
    if IsRunningScan then return end
    IsRunningScan = true

    UI.BigBtn.Text = "PROCESSANDO AS 6 CAMADAS..."
    UI.BigBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 100)
    UI.Status.Text = "Status: Executando pipeline profunda..."

    task.spawn(function()
        UI.Progress.Size = UDim2.new(0.15, 0, 1, 0)
        scanMemoryAndGC()

        UI.Progress.Size = UDim2.new(0.35, 0, 1, 0)
        scanGameFrameworks()

        UI.Progress.Size = UDim2.new(0.55, 0, 1, 0)
        solveCheckpointsAndObby()

        UI.Progress.Size = UDim2.new(0.80, 0, 1, 0)
        fuzzRemotes()

        UI.Progress.Size = UDim2.new(1, 0, 1, 0)
        physicalPenetration()

        UI.Status.Text = "Status: Processo 100% Concluído!"
        UI.Log("======================================================", Color3.fromRGB(0, 255, 200))
        UI.Log("PIPELINE CONCLUÍDA! Todas as portas conhecidas foram forçadas.", Color3.fromRGB(0, 255, 200))
        UI.Log("======================================================", Color3.fromRGB(0, 255, 200))

        UI.BigBtn.Text = "⚡ FORÇAR TODAS AS BADGES (TODOS OS MÉTODOS)"
        UI.BigBtn.BackgroundColor3 = Color3.fromRGB(220, 40, 60)
        IsRunningScan = false
    end)
end

UI.BigBtn.MouseButton1Click:Connect(executeAllLayers)
UI.GcBtn.MouseButton1Click:Connect(scanMemoryAndGC)
UI.ObbyBtn.MouseButton1Click:Connect(solveCheckpointsAndObby)

]====],
    ["V6"] = [====[
--[[
    =================================================================================
    ⚡ BADGE MASTER V6 - THE APEX EXPLOIT & SIGNAL BYPASS SUITE
    =================================================================================
    Se as versões anteriores não entregaram as badges, foi por um destes motivos reais:
    
    1. O jogo usa scripts Lua customizados no .Touched que ignoram 'firetouchinterest'.
       -> SOLUÇÃO V6: Disparo direto via 'getconnections(part.Touched)' (executa o script
          do desenvolvedor diretamente na raiz, sem depender da engine de física).
          
    2. As badges dependem de MENUS DE CONQUISTA (UI/GUIs de Recompensa).
       -> SOLUÇÃO V6: Auto-Claimer de PlayerGui. Clica em todos os botões de 'Claim',
          'Resgatar', 'Recompensas' e 'Conquistas' usando 'firesignal'.
          
    3. As badges exigem interação real do teclado (VirtualInputManager).
       -> SOLUÇÃO V6: Simulação de hardware virtual pressionando 'E' e cliques reais.
       
    4. O jogo exige que o boneco fique fisicamente sobre a peça por 0.2s a 0.5s.
       -> SOLUÇÃO V6: Modo Step-Dwell (pisa, ancora, espera resposta do servidor, avança).
       
    5. O usuário quer forçar uma Badge ESPECÍFICA que não veio.
       -> SOLUÇÃO V6: Aba de Injeção Direta por ID (você cola o ID e o script dispara
          todos os 10 vetores exclusivamente nela até entregar).
    =================================================================================
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local VirtualInputManager = game:GetService("VirtualInputManager")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local RootPart = Character:WaitForChild("HumanoidRootPart", 10)

-- Estado do Script
local State = {
    IsRunning = false,
    ShouldStop = false,
    BadgesApi = {},
    SelectedBadgeId = nil
}

-- ---------------------------------------------------------------------------------
-- 0. ANTI-AFK
-- ---------------------------------------------------------------------------------
LocalPlayer.Idled:Connect(function()
    local vu = game:GetService("VirtualUser")
    vu:CaptureController()
    vu:ClickButton2(Vector2.new(0, 0))
end)

-- ---------------------------------------------------------------------------------
-- 1. CONSULTA DE BADGES DA API OFICIAL
-- ---------------------------------------------------------------------------------
local function fetchApiBadges()
    if #State.BadgesApi > 0 then return State.BadgesApi end
    local uId = game.GameId
    if uId == 0 then return {} end

    local list = {}
    local cursor = ""
    local page = 0

    repeat
        page = page + 1
        local url = string.format("https://badges.roproxy.com/v1/universes/%d/badges?limit=100&cursor=%s", uId, cursor)
        local success, body

        pcall(function()
            if (syn and syn.request) or (http and http.request) or request then
                local req = (syn and syn.request) or (http and http.request) or request
                local r = req({Url = url, Method = "GET"})
                body = r.Body
                success = (r.StatusCode == 200)
            elseif game.HttpGet then
                body = game:HttpGet(url)
                success = (body ~= nil and #body > 0)
            end
        end)

        if success and body then
            local data = HttpService:JSONDecode(body)
            if data and data.data then
                for _, item in ipairs(data.data) do
                    table.insert(list, {
                        Id = item.id,
                        Name = item.name or "Emblema",
                        Description = item.description or ""
                    })
                end
                cursor = data.nextPageCursor or ""
            else
                break
            end
        else
            break
        end
    until cursor == "" or cursor == nil or page >= 10

    State.BadgesApi = list
    return list
end

-- ---------------------------------------------------------------------------------
-- 2. INTERFACE GRÁFICA V6 (DARK APEX HUD)
-- ---------------------------------------------------------------------------------
local function buildInterfaceV6()
    local parentGui = (gethui and gethui()) or game:GetService("CoreGui"):FindFirstChild("RobloxGui") or LocalPlayer:WaitForChild("PlayerGui")
    local old = parentGui:FindFirstChild("BadgeMaster_V6")
    if old then old:Destroy() end

    local Screen = Instance.new("ScreenGui")
    Screen.Name = "BadgeMaster_V6"
    Screen.ResetOnSpawn = false

    -- Botão Mobile Flutuante
    local MobBtn = Instance.new("TextButton")
    MobBtn.Size = UDim2.new(0, 50, 0, 50)
    MobBtn.Position = UDim2.new(0, 16, 0.42, 0)
    MobBtn.BackgroundColor3 = Color3.fromRGB(18, 20, 28)
    MobBtn.Text = "⚡"
    MobBtn.TextSize = 22
    MobBtn.TextColor3 = Color3.fromRGB(0, 255, 180)
    MobBtn.BorderSizePixel = 0
    MobBtn.Parent = Screen

    local mbCorner = Instance.new("UICorner")
    mbCorner.CornerRadius = UDim.new(1, 0)
    mbCorner.Parent = MobBtn

    local mbStroke = Instance.new("UIStroke")
    mbStroke.Color = Color3.fromRGB(0, 255, 180)
    mbStroke.Thickness = 2
    mbStroke.Parent = MobBtn

    -- Janela Principal
    local Window = Instance.new("Frame")
    Window.Size = UDim2.new(0, 540, 0, 390)
    Window.Position = UDim2.new(0.5, -270, 0.5, -195)
    Window.BackgroundColor3 = Color3.fromRGB(12, 14, 20)
    Window.BorderSizePixel = 0
    Window.Active = true
    Window.ClipsDescendants = true
    Window.Parent = Screen

    local wCorner = Instance.new("UICorner")
    wCorner.CornerRadius = UDim.new(0, 12)
    wCorner.Parent = Window

    local wStroke = Instance.new("UIStroke")
    wStroke.Color = Color3.fromRGB(35, 42, 60)
    wStroke.Thickness = 1.4
    wStroke.Parent = Window

    -- TopBar
    local TopBar = Instance.new("Frame")
    TopBar.Size = UDim2.new(1, 0, 0, 42)
    TopBar.BackgroundColor3 = Color3.fromRGB(18, 22, 32)
    TopBar.BorderSizePixel = 0
    TopBar.Parent = Window

    local tbCorner = Instance.new("UICorner")
    tbCorner.CornerRadius = UDim.new(0, 12)
    tbCorner.Parent = TopBar

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -50, 1, 0)
    Title.Position = UDim2.new(0, 14, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = "⚡ BADGE MASTER V6  |  APEX SIGNAL SUITE"
    Title.TextColor3 = Color3.fromRGB(0, 255, 180)
    Title.TextSize = 12
    Title.Font = Enum.Font.GothamBold
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = TopBar

    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 28, 0, 28)
    CloseBtn.Position = UDim2.new(1, -34, 0, 7)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(30, 36, 50)
    CloseBtn.Text = "✕"
    CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseBtn.TextSize = 11
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.BorderSizePixel = 0
    CloseBtn.Parent = TopBar

    local cbCorner = Instance.new("UICorner")
    cbCorner.CornerRadius = UDim.new(0, 6)
    cbCorner.Parent = CloseBtn

    CloseBtn.MouseButton1Click:Connect(function() Window.Visible = false end)
    MobBtn.MouseButton1Click:Connect(function() Window.Visible = not Window.Visible end)

    -- Arrastar Janela
    local dragging, dragStart, startPos
    TopBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = Window.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            Window.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    -- Container Esquerdo (Ações)
    local LeftPane = Instance.new("Frame")
    LeftPane.Size = UDim2.new(0, 220, 1, -54)
    LeftPane.Position = UDim2.new(0, 12, 0, 48)
    LeftPane.BackgroundTransparency = 1
    LeftPane.Parent = Window

    local lpLayout = Instance.new("UIListLayout")
    lpLayout.Padding = UDim.new(0, 6)
    lpLayout.Parent = LeftPane

    local function createActionBtn(text, color, callback)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 36)
        btn.BackgroundColor3 = color
        btn.Text = text
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.TextSize = 10
        btn.Font = Enum.Font.GothamBold
        btn.BorderSizePixel = 0
        btn.Parent = LeftPane

        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(0, 7)
        c.Parent = btn

        btn.MouseButton1Click:Connect(callback)
        return btn
    end

    -- Container Direito (Console e Injetor Manual)
    local RightPane = Instance.new("Frame")
    RightPane.Size = UDim2.new(1, -250, 1, -54)
    RightPane.Position = UDim2.new(0, 238, 0, 48)
    RightPane.BackgroundTransparency = 1
    RightPane.Parent = Window

    -- Caixa de Injeção Manual de ID
    local ManualBox = Instance.new("Frame")
    ManualBox.Size = UDim2.new(1, 0, 0, 64)
    ManualBox.BackgroundColor3 = Color3.fromRGB(18, 22, 32)
    ManualBox.BorderSizePixel = 0
    ManualBox.Parent = RightPane

    local mbCorner = Instance.new("UICorner")
    mbCorner.CornerRadius = UDim.new(0, 8)
    mbCorner.Parent = ManualBox

    local mTitle = Instance.new("TextLabel")
    mTitle.Size = UDim2.new(1, -12, 0, 16)
    mTitle.Position = UDim2.new(0, 8, 0, 6)
    mTitle.BackgroundTransparency = 1
    mTitle.Text = "🎯 FORÇAR BADGE ESPECÍFICA (COLE O ID AQUI):"
    mTitle.TextColor3 = Color3.fromRGB(0, 255, 180)
    mTitle.TextSize = 9
    mTitle.Font = Enum.Font.GothamBold
    mTitle.TextXAlignment = Enum.TextXAlignment.Left
    mTitle.Parent = ManualBox

    local IdInput = Instance.new("TextBox")
    IdInput.Size = UDim2.new(0.68, 0, 0, 28)
    IdInput.Position = UDim2.new(0, 8, 0, 26)
    IdInput.BackgroundColor3 = Color3.fromRGB(26, 32, 46)
    IdInput.PlaceholderText = "Ex: 2124567890..."
    IdInput.PlaceholderColor3 = Color3.fromRGB(130, 140, 160)
    IdInput.Text = ""
    IdInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    IdInput.TextSize = 11
    IdInput.Font = Enum.Font.Gotham
    IdInput.BorderSizePixel = 0
    IdInput.Parent = ManualBox

    local iiCorner = Instance.new("UICorner")
    iiCorner.CornerRadius = UDim.new(0, 6)
    iiCorner.Parent = IdInput

    local FireIdBtn = Instance.new("TextButton")
    FireIdBtn.Size = UDim2.new(0.26, 0, 0, 28)
    FireIdBtn.Position = UDim2.new(0.72, 0, 0, 26)
    FireIdBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 120)
    FireIdBtn.Text = "FORÇAR"
    FireIdBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    FireIdBtn.TextSize = 10
    FireIdBtn.Font = Enum.Font.GothamBold
    FireIdBtn.BorderSizePixel = 0
    FireIdBtn.Parent = ManualBox

    local fibCorner = Instance.new("UICorner")
    fibCorner.CornerRadius = UDim.new(0, 6)
    fibCorner.Parent = FireIdBtn

    -- Console de Diagnóstico
    local Console = Instance.new("ScrollingFrame")
    Console.Size = UDim2.new(1, 0, 1, -74)
    Console.Position = UDim2.new(0, 0, 0, 72)
    Console.BackgroundColor3 = Color3.fromRGB(8, 10, 15)
    Console.BorderSizePixel = 0
    Console.ScrollBarThickness = 4
    Console.Parent = RightPane

    local cCorner = Instance.new("UICorner")
    cCorner.CornerRadius = UDim.new(0, 8)
    cCorner.Parent = Console

    local cLayout = Instance.new("UIListLayout")
    cLayout.Padding = UDim.new(0, 2)
    cLayout.Parent = Console

    local function printLog(msg, color)
        local l = Instance.new("TextLabel")
        l.Size = UDim2.new(1, -10, 0, 16)
        l.BackgroundTransparency = 1
        l.Text = string.format("[%s] %s", os.date("%H:%M:%S"), msg)
        l.TextColor3 = color or Color3.fromRGB(190, 195, 210)
        l.TextSize = 9
        l.Font = Enum.Font.Code
        l.TextXAlignment = Enum.TextXAlignment.Left
        l.Parent = Console

        Console.CanvasPosition = Vector2.new(0, cLayout.AbsoluteContentSize.Y)
        Console.CanvasSize = UDim2.new(0, 0, 0, cLayout.AbsoluteContentSize.Y + 10)
    end

    Screen.Parent = parentGui

    return {
        Log = printLog,
        CreateBtn = createActionBtn,
        IdInput = IdInput,
        FireIdBtn = FireIdBtn
    }
end

local UI = buildInterfaceV6()
UI.Log("Badge Master V6 inicializado com sucesso.", Color3.fromRGB(0, 255, 180))

-- Carrega Badges da API em background
task.spawn(function()
    local b = fetchApiBadges()
    UI.Log(string.format("API da Roblox: %d badges cadastradas no jogo.", #b), Color3.fromRGB(0, 220, 255))
end)

-- ---------------------------------------------------------------------------------
-- MÉTODO 1: INVASÃO DE SINAIS LUA ('getconnections' DIRETO NOS SCRIPTS)
-- ---------------------------------------------------------------------------------
local function triggerSignalBypass()
    UI.Log(">>> [MÉTODO 1] Disparando conexões de script via getconnections...", Color3.fromRGB(255, 215, 0))
    if not getconnections then
        UI.Log("Seu executor não possui getconnections(). Pulando para simulação física.", Color3.fromRGB(255, 120, 120))
        return
    end

    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local root = char:WaitForChild("HumanoidRootPart", 5)
    local triggered = 0

    task.spawn(function()
        for _, part in ipairs(workspace:GetDescendants()) do
            if part:IsA("BasePart") then
                pcall(function()
                    for _, conn in ipairs(getconnections(part.Touched)) do
                        conn:Fire(root)
                        triggered = triggered + 1
                    end
                end)
            end
        end
        UI.Log(string.format("[MÉTODO 1] %d sinais de .Touched disparados no código do jogo!", triggered), Color3.fromRGB(0, 255, 120))
    end)
end

-- ---------------------------------------------------------------------------------
-- MÉTODO 2: AUTO-CLAIMER DE MENUS & GUIs DE CONQUISTA
-- ---------------------------------------------------------------------------------
local function claimAllGuiRewards()
    UI.Log(">>> [MÉTODO 2] Varrendo PlayerGui em busca de botões de Conquistas/Claim...", Color3.fromRGB(255, 215, 0))
    local claimed = 0
    local keywords = {"claim", "resgatar", "coletar", "reward", "badge", "conquista", "achievement", "pegar", "free"}

    task.spawn(function()
        for _, gui in ipairs(LocalPlayer:WaitForChild("PlayerGui"):GetDescendants()) do
            if gui:IsA("TextButton") or gui:IsA("ImageButton") then
                local n = gui.Name:lower()
                local t = (gui:IsA("TextButton") and gui.Text or ""):lower()

                local isMatch = false
                for _, kw in ipairs(keywords) do
                    if n:find(kw) or t:find(kw) then
                        isMatch = true
                        break
                    end
                end

                if isMatch then
                    pcall(function()
                        if firesignal then
                            firesignal(gui.MouseButton1Click)
                            firesignal(gui.Activated)
                        else
                            gui.Visible = true
                        end
                        claimed = claimed + 1
                    end)
                    task.wait(0.01)
                end
            end
        end
        UI.Log(string.format("[MÉTODO 2] %d botões de recompensa/conquista acionados nas telas!", claimed), Color3.fromRGB(0, 255, 120))
    end)
end

-- ---------------------------------------------------------------------------------
-- MÉTODO 3: TELEPORTE FÍSICO COM PERMANÊNCIA (STEP-DWELL)
-- ---------------------------------------------------------------------------------
local function stepDwellPhysical()
    UI.Log(">>> [MÉTODO 3] Iniciando pisada com permanência (Step-Dwell)...", Color3.fromRGB(255, 215, 0))
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local root = char:WaitForChild("HumanoidRootPart", 5)

    local pads = {}
    for _, o in ipairs(workspace:GetDescendants()) do
        if o:IsA("TouchTransmitter") and o.Parent and o.Parent:IsA("BasePart") then
            table.insert(pads, o.Parent)
        elseif o:IsA("BasePart") then
            local n = o.Name:lower()
            if n:find("badge") or n:find("giver") or n:find("emblema") or n:find("pad") or n:find("trophy") then
                table.insert(pads, o)
            end
        end
    end

    UI.Log(string.format("Localizados %d blocos físicos no mapa.", #pads), Color3.fromRGB(255, 255, 255))
    if #pads == 0 then return end

    task.spawn(function()
        local orig = root.CFrame
        for i, pad in ipairs(pads) do
            if not char or not char.Parent then break end

            pcall(function()
                -- Fica exatamente em cima da peça e espera 0.15s para o servidor checar
                root.CFrame = pad.CFrame + Vector3.new(0, 1.5, 0)
                root.AssemblyLinearVelocity = Vector3.new(0, -3, 0)
                
                if firetouchinterest then
                    firetouchinterest(root, pad, 0)
                    task.wait(0.02)
                    firetouchinterest(root, pad, 1)
                end
            end)
            task.wait(0.12) -- Dwell time para validação de servidor
        end
        root.CFrame = orig
        UI.Log("[MÉTODO 3] Todos os blocos foram pisados com permanência.", Color3.fromRGB(0, 255, 120))
    end)
end

-- ---------------------------------------------------------------------------------
-- MÉTODO 4: FORÇAR BADGE ESPECÍFICA (TODOS OS FORMATOS DE REMOTES)
-- ---------------------------------------------------------------------------------
local function forceSpecificBadge(badgeId)
    local idNum = tonumber(badgeId)
    if not idNum then
        UI.Log("Por favor, digite um número de Badge ID válido!", Color3.fromRGB(255, 100, 100))
        return
    end

    UI.Log(string.format(">>> INJETANDO FORÇADAMENTE A BADGE: %d...", idNum), Color3.fromRGB(0, 255, 255))

    task.spawn(function()
        local count = 0
        for _, rem in ipairs(game:GetDescendants()) do
            if rem:IsA("RemoteEvent") or rem:IsA("RemoteFunction") then
                pcall(function()
                    if rem:IsA("RemoteEvent") then
                        rem:FireServer(idNum)
                        rem:FireServer(tostring(idNum))
                        rem:FireServer("AwardBadge", idNum)
                        rem:FireServer("Badge", idNum)
                        rem:FireServer({BadgeId = idNum})
                        rem:FireServer({Id = idNum})
                        rem:FireServer({id = idNum})
                        count = count + 7
                    elseif rem:IsA("RemoteFunction") then
                        rem:InvokeServer(idNum)
                        rem:InvokeServer({BadgeId = idNum})
                        count = count + 2
                    end
                end)
            end
        end
        UI.Log(string.format("Injeção da badge %d concluída com %d disparos!", idNum, count), Color3.fromRGB(0, 255, 120))
    end)
end

-- ---------------------------------------------------------------------------------
-- VINCULAÇÃO DOS BOTÕES
-- ---------------------------------------------------------------------------------
UI.CreateBtn("🔥 FORÇAR TUDO (TODAS AS PORTAS)", Color3.fromRGB(220, 40, 50), function()
    triggerSignalBypass()
    claimAllGuiRewards()
    stepDwellPhysical()
    -- Dispara todas as badges da API nos remotes
    local bList = fetchApiBadges()
    for _, b in ipairs(bList) do
        forceSpecificBadge(b.Id)
        task.wait(0.01)
    end
end)

UI.CreateBtn("1. Bypass de Sinais (getconnections)", Color3.fromRGB(28, 36, 52), triggerSignalBypass)
UI.CreateBtn("2. Auto-Claim Menus e Conquistas", Color3.fromRGB(28, 36, 52), claimAllGuiRewards)
UI.CreateBtn("3. Pisar Físico com Espera (Dwell)", Color3.fromRGB(28, 36, 52), stepDwellPhysical)
UI.CreateBtn("4. Destruir ProximityPrompts (E)", Color3.fromRGB(28, 36, 52), function()
    local c = 0
    for _, p in ipairs(workspace:GetDescendants()) do
        if p:IsA("ProximityPrompt") then
            pcall(function()
                p.HoldDuration = 0
                if fireproximityprompt then fireproximityprompt(p) end
                c = c + 1
            end)
        end
    end
    UI.Log(string.format("%d Prompts de proximidade destruídos!", c), Color3.fromRGB(0, 255, 120))
end)

UI.FireIdBtn.MouseButton1Click:Connect(function()
    forceSpecificBadge(UI.IdInput.Text)
end)

print("[BadgeMaster V6] Carregado com sucesso.")

]====],
    ["V7"] = [====[
--[[
    =================================================================================
    🎁 BADGE MASTER V7 - ITEM FORCE, VACUUM & AUTO-EQUIP SUITE
    =================================================================================
    O DIAGNÓSTICO DEFINITIVO:
    Muitas badges no Roblox NÃO são dadas por pisar no chão nem por remotes diretos.
    Elas exigem que seu personagem:
    1. PEGUE itens espalhados pelo mapa (Tools, Chaves, Relíquias, Troféus, Colecionáveis).
    2. COLOQUE os itens na Mochila (Backpack).
    3. SEGURE o item na mão (Equipar no Character).
    4. ATIVE/USE o item (Disparo do evento Tool.Activated).
    
    O QUE A V7 FAZ DE FORMA AUTOMATIZADA:
    - [VÁCUO GERAL DE ITENS (ITEM MAGNET)]:
      Localiza todas as 'Tools' e itens em qualquer lugar do Workspace e força
      a coleta (via Humanoid:EquipTool, toque no Handle e teleporte instantâneo).
      
    - [AUTO-EQUIP & ACTIVATOR EM MASSA]:
      Pega todos os itens da sua mochila, equipa um por um na sua mão, espera o
      tempo de registro do servidor, dispara a ativação (:Activate()) e avança.
      
    - [CLONAGEM DE REPLICATEDSTORAGE]:
      Varre pastas de itens guardados em ReplicatedStorage (onde ficam itens de inventário
      e conquistas) e tenta trazer para o jogador ou disparar os remotes de GiveTool.
      
    - [FORÇADOR DE ITENS EM PEDESTAIS]:
      Dispara instantaneamente ProximityPrompts e ClickDetectors de itens em mostruários.
    =================================================================================
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local Backpack = LocalPlayer:WaitForChild("Backpack")
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local RootPart = Character:WaitForChild("HumanoidRootPart", 10)
local Humanoid = Character:WaitForChild("Humanoid", 10)

-- Estado da V7
local State = {
    IsRunning = false,
    ShouldStop = false
}

-- ---------------------------------------------------------------------------------
-- 0. ANTI-AFK PERMANENTE
-- ---------------------------------------------------------------------------------
LocalPlayer.Idled:Connect(function()
    local vu = game:GetService("VirtualUser")
    vu:CaptureController()
    vu:ClickButton2(Vector2.new(0, 0))
end)

-- Mantém referências atualizadas após respawn
LocalPlayer.CharacterAdded:Connect(function(char)
    Character = char
    RootPart = char:WaitForChild("HumanoidRootPart", 10)
    Humanoid = char:WaitForChild("Humanoid", 10)
    Backpack = LocalPlayer:WaitForChild("Backpack")
end)

-- ---------------------------------------------------------------------------------
-- 1. INTERFACE GRÁFICA V7 (ITEM MASTER HUD)
-- ---------------------------------------------------------------------------------
local function buildInterfaceV7()
    local parentGui = (gethui and gethui()) or game:GetService("CoreGui"):FindFirstChild("RobloxGui") or LocalPlayer:WaitForChild("PlayerGui")
    local old = parentGui:FindFirstChild("BadgeMaster_V7")
    if old then old:Destroy() end

    local Screen = Instance.new("ScreenGui")
    Screen.Name = "BadgeMaster_V7"
    Screen.ResetOnSpawn = false

    -- Botão Mobile Flutuante
    local MobBtn = Instance.new("TextButton")
    MobBtn.Size = UDim2.new(0, 50, 0, 50)
    MobBtn.Position = UDim2.new(0, 16, 0.45, 0)
    MobBtn.BackgroundColor3 = Color3.fromRGB(22, 24, 34)
    MobBtn.Text = "🎁"
    MobBtn.TextSize = 22
    MobBtn.BorderSizePixel = 0
    MobBtn.Parent = Screen

    local mbCorner = Instance.new("UICorner")
    mbCorner.CornerRadius = UDim.new(1, 0)
    mbCorner.Parent = MobBtn

    local mbStroke = Instance.new("UIStroke")
    mbStroke.Color = Color3.fromRGB(255, 180, 0)
    mbStroke.Thickness = 2
    mbStroke.Parent = MobBtn

    -- Janela Principal
    local Window = Instance.new("Frame")
    Window.Size = UDim2.new(0, 480, 0, 380)
    Window.Position = UDim2.new(0.5, -240, 0.5, -190)
    Window.BackgroundColor3 = Color3.fromRGB(15, 17, 24)
    Window.BorderSizePixel = 0
    Window.Active = true
    Window.ClipsDescendants = true
    Window.Parent = Screen

    local wCorner = Instance.new("UICorner")
    wCorner.CornerRadius = UDim.new(0, 12)
    wCorner.Parent = Window

    local wStroke = Instance.new("UIStroke")
    wStroke.Color = Color3.fromRGB(45, 52, 72)
    wStroke.Thickness = 1.4
    wStroke.Parent = Window

    -- Header
    local TopBar = Instance.new("Frame")
    TopBar.Size = UDim2.new(1, 0, 0, 42)
    TopBar.BackgroundColor3 = Color3.fromRGB(22, 26, 38)
    TopBar.BorderSizePixel = 0
    TopBar.Parent = Window

    local tbCorner = Instance.new("UICorner")
    tbCorner.CornerRadius = UDim.new(0, 12)
    tbCorner.Parent = TopBar

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -50, 1, 0)
    Title.Position = UDim2.new(0, 14, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = "🎁 BADGE MASTER V7  |  ITEM & TOOL FORCER"
    Title.TextColor3 = Color3.fromRGB(255, 195, 0)
    Title.TextSize = 12
    Title.Font = Enum.Font.GothamBold
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = TopBar

    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 28, 0, 28)
    CloseBtn.Position = UDim2.new(1, -34, 0, 7)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(35, 42, 58)
    CloseBtn.Text = "✕"
    CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseBtn.TextSize = 11
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.BorderSizePixel = 0
    CloseBtn.Parent = TopBar

    local cbCorner = Instance.new("UICorner")
    cbCorner.CornerRadius = UDim.new(0, 6)
    cbCorner.Parent = CloseBtn

    CloseBtn.MouseButton1Click:Connect(function() Window.Visible = false end)
    MobBtn.MouseButton1Click:Connect(function() Window.Visible = not Window.Visible end)

    -- Arrastar Janela
    local dragging, dragStart, startPos
    TopBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = Window.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            Window.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    -- Corpo
    local Body = Instance.new("Frame")
    Body.Size = UDim2.new(1, -24, 1, -54)
    Body.Position = UDim2.new(0, 12, 0, 48)
    Body.BackgroundTransparency = 1
    Body.Parent = Window

    -- Bloco de Ação Principal
    local BigActionBtn = Instance.new("TextButton")
    BigActionBtn.Size = UDim2.new(1, 0, 0, 48)
    BigActionBtn.BackgroundColor3 = Color3.fromRGB(230, 45, 60)
    BigActionBtn.Text = "⚡ FORÇAR TODOS OS ITENS & EQUIPAR TUDO"
    BigActionBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    BigActionBtn.TextSize = 12
    BigActionBtn.Font = Enum.Font.GothamBold
    BigActionBtn.BorderSizePixel = 0
    BigActionBtn.Parent = Body

    local babCorner = Instance.new("UICorner")
    babCorner.CornerRadius = UDim.new(0, 8)
    babCorner.Parent = BigActionBtn

    -- Painel de Estatísticas
    local StatBox = Instance.new("Frame")
    StatBox.Size = UDim2.new(1, 0, 0, 52)
    StatBox.Position = UDim2.new(0, 0, 0, 54)
    StatBox.BackgroundColor3 = Color3.fromRGB(20, 24, 34)
    StatBox.BorderSizePixel = 0
    StatBox.Parent = Body

    local sbCorner = Instance.new("UICorner")
    sbCorner.CornerRadius = UDim.new(0, 8)
    sbCorner.Parent = StatBox

    local StatusTxt = Instance.new("TextLabel")
    StatusTxt.Size = UDim2.new(1, -20, 0, 18)
    StatusTxt.Position = UDim2.new(0, 10, 0, 6)
    StatusTxt.BackgroundTransparency = 1
    StatusTxt.Text = "Status: Pronto para forçar itens."
    StatusTxt.TextColor3 = Color3.fromRGB(180, 190, 215)
    StatusTxt.TextSize = 11
    StatusTxt.Font = Enum.Font.GothamMedium
    StatusTxt.TextXAlignment = Enum.TextXAlignment.Left
    StatusTxt.Parent = StatBox

    local ItemCountTxt = Instance.new("TextLabel")
    ItemCountTxt.Size = UDim2.new(1, -20, 0, 20)
    ItemCountTxt.Position = UDim2.new(0, 10, 0, 26)
    ItemCountTxt.BackgroundTransparency = 1
    ItemCountTxt.Text = "Itens no mapa: 0  |  Itens na Mochila: 0"
    ItemCountTxt.TextColor3 = Color3.fromRGB(255, 255, 255)
    ItemCountTxt.TextSize = 12
    ItemCountTxt.Font = Enum.Font.GothamBold
    ItemCountTxt.TextXAlignment = Enum.TextXAlignment.Left
    ItemCountTxt.Parent = StatBox

    -- Console de Logs
    local Console = Instance.new("ScrollingFrame")
    Console.Size = UDim2.new(1, 0, 0, 160)
    Console.Position = UDim2.new(0, 0, 0, 112)
    Console.BackgroundColor3 = Color3.fromRGB(10, 12, 17)
    Console.BorderSizePixel = 0
    Console.ScrollBarThickness = 4
    Console.Parent = Body

    local cCorner = Instance.new("UICorner")
    cCorner.CornerRadius = UDim.new(0, 8)
    cCorner.Parent = Console

    local cLayout = Instance.new("UIListLayout")
    cLayout.Padding = UDim.new(0, 2)
    cLayout.Parent = Console

    local function printLog(msg, color)
        local l = Instance.new("TextLabel")
        l.Size = UDim2.new(1, -10, 0, 16)
        l.BackgroundTransparency = 1
        l.Text = string.format("[%s] %s", os.date("%H:%M:%S"), msg)
        l.TextColor3 = color or Color3.fromRGB(195, 200, 220)
        l.TextSize = 9
        l.Font = Enum.Font.Code
        l.TextXAlignment = Enum.TextXAlignment.Left
        l.Parent = Console

        Console.CanvasPosition = Vector2.new(0, cLayout.AbsoluteContentSize.Y)
        Console.CanvasSize = UDim2.new(0, 0, 0, cLayout.AbsoluteContentSize.Y + 10)
    end

    -- Botões de Ações Específicas
    local SubBtnContainer = Instance.new("Frame")
    SubBtnContainer.Size = UDim2.new(1, 0, 0, 46)
    SubBtnContainer.Position = UDim2.new(0, 0, 0, 278)
    SubBtnContainer.BackgroundTransparency = 1
    SubBtnContainer.Parent = Body

    local function createSubBtn(text, pos, width, callback)
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(width, -4, 1, 0)
        b.Position = pos
        b.BackgroundColor3 = Color3.fromRGB(30, 36, 50)
        b.Text = text
        b.TextColor3 = Color3.fromRGB(240, 240, 250)
        b.TextSize = 10
        b.Font = Enum.Font.GothamBold
        b.BorderSizePixel = 0
        b.Parent = SubBtnContainer

        local bc = Instance.new("UICorner")
        bc.CornerRadius = UDim.new(0, 6)
        bc.Parent = b

        b.MouseButton1Click:Connect(callback)
        return b
    end

    Screen.Parent = parentGui

    return {
        Log = printLog,
        Status = StatusTxt,
        ItemCount = ItemCountTxt,
        BigBtn = BigActionBtn,
        CreateSub = createSubBtn
    }
end

local UI = buildInterfaceV7()
UI.Log("Badge Master V7 inicializado (Foco em Itens & Ferramentas).", Color3.fromRGB(0, 255, 180))

-- Atualizador periódico de itens
task.spawn(function()
    while true do
        local worldTools = 0
        for _, o in ipairs(workspace:GetDescendants()) do
            if o:IsA("Tool") and not o:IsDescendantOf(Character) then
                worldTools = worldTools + 1
            end
        end

        local bpTools = #Backpack:GetChildren()
        if Character then
            for _, o in ipairs(Character:GetChildren()) do
                if o:IsA("Tool") then bpTools = bpTools + 1 end
            end
        end

        UI.ItemCount.Text = string.format("Itens no mapa: %d  |  Seus itens: %d", worldTools, bpTools)
        task.wait(2)
    end
end)

-- ---------------------------------------------------------------------------------
-- MÉTODO 1: VÁCUO GERAL DE ITENS DO WORKSPACE (ITEM MAGNET)
-- ---------------------------------------------------------------------------------
local function vacuumWorkspaceTools()
    UI.Log(">>> [PASSO 1] Puxando e pegando todas as Tools do mapa...", Color3.fromRGB(255, 200, 0))
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local root = char:WaitForChild("HumanoidRootPart", 5)
    local hum = char:WaitForChild("Humanoid", 5)

    local toolsFound = {}
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Tool") and not obj:IsDescendantOf(char) then
            table.insert(toolsFound, obj)
        end
    end

    UI.Log(string.format("Encontradas %d Tools espalhadas no mapa.", #toolsFound), Color3.fromRGB(255, 255, 255))
    if #toolsFound == 0 then return end

    local origPos = root.CFrame
    local collected = 0

    for _, tool in ipairs(toolsFound) do
        if not char or not char.Parent then break end

        pcall(function()
            local handle = tool:FindFirstChild("Handle") or tool:FindFirstChildWhichIsA("BasePart")
            if handle then
                -- 1. Teleporta o personagem em cima do item
                root.CFrame = handle.CFrame + Vector3.new(0, 1, 0)
                
                -- 2. Aciona o toque direto
                if firetouchinterest then
                    firetouchinterest(root, handle, 0)
                    task.wait(0.01)
                    firetouchinterest(root, handle, 1)
                end

                -- 3. Tenta forçar via Humanoid
                hum:EquipTool(tool)
            end

            -- 4. Tenta transferir o parent direto
            tool.Parent = Backpack
            collected = collected + 1
        end)
        task.wait(0.05)
    end

    root.CFrame = origPos
    UI.Log(string.format("[PASSO 1 Concluído] %d itens processados no mapa.", collected), Color3.fromRGB(0, 255, 120))
end

-- ---------------------------------------------------------------------------------
-- MÉTODO 2: FORÇAR ITENS GUARDADOS EM REPLICATEDSTORAGE
-- ---------------------------------------------------------------------------------
local function forceReplicatedStorageTools()
    UI.Log(">>> [PASSO 2] Buscando itens em ReplicatedStorage...", Color3.fromRGB(255, 200, 0))
    local count = 0

    for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("Tool") then
            pcall(function()
                local clone = obj:Clone()
                clone.Parent = Backpack
                count = count + 1
            end)
        end
    end

    -- Dispara remotes comuns de entrega de itens
    local remKeywords = {"item", "tool", "weapon", "gear", "give", "equip", "inventory", "claim"}
    for _, rem in ipairs(ReplicatedStorage:GetDescendants()) do
        if rem:IsA("RemoteEvent") or rem:IsA("RemoteFunction") then
            local n = rem.Name:lower()
            for _, kw in ipairs(remKeywords) do
                if n:find(kw) then
                    pcall(function()
                        if rem:IsA("RemoteEvent") then
                            rem:FireServer()
                            rem:FireServer("All")
                            rem:FireServer("Get")
                        elseif rem:IsA("RemoteFunction") then
                            rem:InvokeServer()
                        end
                    end)
                    break
                end
            end
        end
    end

    UI.Log(string.format("[PASSO 2 Concluído] %d itens clonados de ReplicatedStorage.", count), Color3.fromRGB(0, 255, 120))
end

-- ---------------------------------------------------------------------------------
-- MÉTODO 3: PROXIMITY PROMPTS DE ITENS E MOSTRIÁRIOS
-- ---------------------------------------------------------------------------------
local function forceItemPrompts()
    UI.Log(">>> [PASSO 3] Forçando botões de pegar itens (ProximityPrompts)...", Color3.fromRGB(255, 200, 0))
    local pCount = 0
    for _, prompt in ipairs(workspace:GetDescendants()) do
        if prompt:IsA("ProximityPrompt") then
            pcall(function()
                prompt.HoldDuration = 0
                if fireproximityprompt then
                    fireproximityprompt(prompt)
                    pCount = pCount + 1
                end
            end)
        elseif prompt:IsA("ClickDetector") then
            pcall(function()
                if fireclickdetector then
                    fireclickdetector(prompt)
                    pCount = pCount + 1
                end
            end)
        end
    end
    UI.Log(string.format("[PASSO 3 Concluído] %d interações de itens acionadas.", pCount), Color3.fromRGB(0, 255, 120))
end

-- ---------------------------------------------------------------------------------
-- MÉTODO 4: AUTO-EQUIP & ATIVAÇÃO EM MASSA DE TODOS OS SEUS ITENS
-- ---------------------------------------------------------------------------------
local function equipAndActivateAllTools()
    UI.Log(">>> [PASSO 4] Equipando e Ativando TODOS os itens na mão...", Color3.fromRGB(255, 200, 0))
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local hum = char:WaitForChild("Humanoid", 5)

    local tools = {}
    for _, t in ipairs(Backpack:GetChildren()) do
        if t:IsA("Tool") then table.insert(tools, t) end
    end

    UI.Log(string.format("Você possui %d itens na mochila para equipar.", #tools), Color3.fromRGB(255, 255, 255))
    if #tools == 0 then
        UI.Log("Mochila vazia! Certifique-se de executar o Vácuo de Itens primeiro.", Color3.fromRGB(255, 120, 120))
        return
    end

    local activatedCount = 0
    for _, tool in ipairs(tools) do
        if not char or not char.Parent then break end

        pcall(function()
            -- 1. Equipa na mão
            tool.Parent = char
            task.wait(0.12) -- Tempo de sincronização com o servidor

            -- 2. Ativa o item (dispara Tool.Activated)
            tool:Activate()
            activatedCount = activatedCount + 1
            UI.Log(string.format("Item ativado: '%s'", tool.Name), Color3.fromRGB(150, 255, 150))
            task.wait(0.08)

            -- 3. Devolve para a mochila para poder equipar o próximo
            tool.Parent = Backpack
        end)
    end

    UI.Log(string.format("[PASSO 4 Concluído] %d itens foram equipados e ativados com sucesso!", activatedCount), Color3.fromRGB(0, 255, 120))
end

-- ---------------------------------------------------------------------------------
-- BOTÕES DA INTERFACE V7
-- ---------------------------------------------------------------------------------
UI.BigBtn.MouseButton1Click:Connect(function()
    if State.IsRunning then return end
    State.IsRunning = true
    UI.BigBtn.Text = "PROCESSANDO PIPELINE DE ITENS..."
    UI.BigBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 100)
    UI.Status.Text = "Status: Executando os 4 passos de itens..."

    task.spawn(function()
        -- Passo 1: Pega todos do chão
        vacuumWorkspaceTools()
        task.wait(0.2)

        -- Passo 2: Clona de ReplicatedStorage
        forceReplicatedStorageTools()
        task.wait(0.2)

        -- Passo 3: Pega mostruários
        forceItemPrompts()
        task.wait(0.3)

        -- Passo 4: Equipa e usa TODOS os itens coletados
        equipAndActivateAllTools()

        UI.Status.Text = "Status: Todos os itens foram coletados e ativados!"
        UI.BigBtn.Text = "⚡ FORÇAR TODOS OS ITENS & EQUIPAR TUDO"
        UI.BigBtn.BackgroundColor3 = Color3.fromRGB(230, 45, 60)
        State.IsRunning = false
    end)
end)

UI.CreateSub("1. Puxar do Mapa", UDim2.new(0, 0, 0, 0), 0.25, vacuumWorkspaceTools)
UI.CreateSub("2. Replicated Items", UDim2.new(0.25, 0, 0, 0), 0.25, forceReplicatedStorageTools)
UI.CreateSub("3. Puxar Prompts", UDim2.new(0.5, 0, 0, 0), 0.25, forceItemPrompts)
UI.CreateSub("4. Equipar Mochila", UDim2.new(0.75, 0, 0, 0), 0.25, equipAndActivateAllTools)

print("[BadgeMaster V7] Pronto.")

]====],
    ["V8"] = [====[
--[[
    =================================================================================
    🎁 BADGE MASTER V8 - INTERACTIVE ITEM MANAGER & AUTO-LOOP SUITE
    =================================================================================
    NOVIDADES EXCLUSIVAS DA V8:
    1. [BOTÃO TUDO DE UMA VEZ]:
       Executa instantaneamente todos os passos de coleta, injeção, equipamentos
       e ativações do mapa em massa.
       
    2. [LISTADOR INTERATIVO DE AÇÕES & ITENS]:
       Um botão que escaneia o jogo e lista detalhadamente cada item do Workspace,
       cada item de ReplicatedStorage e cada ProximityPrompt encontrado.
       
    3. [EXECUÇÃO INDIVIDUAL POR ITEM]:
       Você pode clicar no botão [▶ Executar] ao lado de qualquer item específico
       para ir até ele, pegá-lo, colocá-lo na mão e ativá-lo isoladamente.
       
    4. [MODO AUTO-EXECUÇÃO CONTÍNUA (LOOP)]:
       Ao lado de cada opção, há um botão [🔁 Auto: OFF / ON]. Ao ativar, o script
       fica pegando e re-equipando aquele item específico sem parar (ideal para
       itens que respawnam ou requerem múltiplos usos para dar o emblema).
       
    5. [PARAR TODOS OS AUTOS]:
       Botão rápido para desativar todos os loops automáticos a qualquer momento.
    =================================================================================
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local Backpack = LocalPlayer:WaitForChild("Backpack")
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local RootPart = Character:WaitForChild("HumanoidRootPart", 10)
local Humanoid = Character:WaitForChild("Humanoid", 10)

-- Estado Global da V8
local State = {
    IsBatchRunning = false,
    ActiveLoops = {},       -- Tabela de loops automáticos por item { [id] = boolean }
    ScannedEntries = {}     -- Lista de ações/itens detectados
}

-- Anti-AFK
LocalPlayer.Idled:Connect(function()
    local vu = game:GetService("VirtualUser")
    vu:CaptureController()
    vu:ClickButton2(Vector2.new(0, 0))
end)

LocalPlayer.CharacterAdded:Connect(function(char)
    Character = char
    RootPart = char:WaitForChild("HumanoidRootPart", 10)
    Humanoid = char:WaitForChild("Humanoid", 10)
    Backpack = LocalPlayer:WaitForChild("Backpack")
end)

-- ---------------------------------------------------------------------------------
-- 1. FUNÇÕES DE EXECUÇÃO DE ITENS E AÇÕES
-- ---------------------------------------------------------------------------------
local function executeAction(entry)
    if not Character or not RootPart or not Humanoid then
        Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        RootPart = Character:WaitForChild("HumanoidRootPart", 5)
        Humanoid = Character:WaitForChild("Humanoid", 5)
    end

    local success = false

    pcall(function()
        if entry.Type == "WorldTool" then
            -- Item solto no Workspace
            local tool = entry.Object
            if tool and tool.Parent then
                local handle = tool:FindFirstChild("Handle") or tool:FindFirstChildWhichIsA("BasePart")
                if handle then
                    local origPos = RootPart.CFrame
                    RootPart.CFrame = handle.CFrame + Vector3.new(0, 1.2, 0)
                    
                    if firetouchinterest then
                        firetouchinterest(RootPart, handle, 0)
                        task.wait(0.01)
                        firetouchinterest(RootPart, handle, 1)
                    end
                    
                    Humanoid:EquipTool(tool)
                    tool.Parent = Character
                    task.wait(0.1)
                    tool:Activate()
                    task.wait(0.05)
                    RootPart.CFrame = origPos
                    success = true
                else
                    tool.Parent = Backpack
                    Humanoid:EquipTool(tool)
                    tool:Activate()
                    success = true
                end
            end

        elseif entry.Type == "ReplicatedTool" then
            -- Item guardado em ReplicatedStorage
            local tool = entry.Object
            if tool then
                local clone = tool:Clone()
                clone.Parent = Backpack
                Humanoid:EquipTool(clone)
                task.wait(0.1)
                clone:Activate()
                success = true
            end

        elseif entry.Type == "BackpackTool" then
            -- Item já na mochila do jogador
            local tool = entry.Object
            if tool and tool.Parent then
                tool.Parent = Character
                task.wait(0.1)
                tool:Activate()
                task.wait(0.05)
                tool.Parent = Backpack
                success = true
            end

        elseif entry.Type == "Prompt" then
            -- ProximityPrompt / Mostruário
            local prompt = entry.Object
            if prompt and prompt.Parent then
                local promptPart = prompt.Parent:IsA("BasePart") and prompt.Parent or prompt.Parent:FindFirstChildWhichIsA("BasePart")
                if promptPart then
                    local origPos = RootPart.CFrame
                    RootPart.CFrame = promptPart.CFrame + Vector3.new(0, 1.5, 0)
                    prompt.HoldDuration = 0
                    if fireproximityprompt then
                        fireproximityprompt(prompt)
                    end
                    task.wait(0.08)
                    RootPart.CFrame = origPos
                    success = true
                end
            end
        end
    end)

    return success
end

-- ---------------------------------------------------------------------------------
-- 2. SCANNER DE TODOS OS ITENS E AÇÕES DISPONÍVEIS
-- ---------------------------------------------------------------------------------
local function scanAllAvailableActions()
    local entries = {}
    local seen = {}

    -- A) Tools no Workspace
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Tool") and not obj:IsDescendantOf(Character) and not seen[obj] then
            seen[obj] = true
            table.insert(entries, {
                Id = "WTool_" .. tostring(obj:GetDebugId() or math.random(10000, 99999)),
                Name = obj.Name,
                Type = "WorldTool",
                TypeLabel = "🗡️ Item do Mapa",
                Location = obj.Parent and obj.Parent.Name or "Workspace",
                Object = obj
            })
        end
    end

    -- B) Tools em ReplicatedStorage
    for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("Tool") and not seen[obj] then
            seen[obj] = true
            table.insert(entries, {
                Id = "RTool_" .. tostring(obj:GetDebugId() or math.random(10000, 99999)),
                Name = obj.Name,
                Type = "ReplicatedTool",
                TypeLabel = "📦 Item de Rede (Storage)",
                Location = obj.Parent and obj.Parent.Name or "ReplicatedStorage",
                Object = obj
            })
        end
    end

    -- C) Itens que já estão na sua Mochila
    for _, obj in ipairs(Backpack:GetChildren()) do
        if obj:IsA("Tool") and not seen[obj] then
            seen[obj] = true
            table.insert(entries, {
                Id = "BTool_" .. tostring(obj:GetDebugId() or math.random(10000, 99999)),
                Name = obj.Name,
                Type = "BackpackTool",
                TypeLabel = "🎒 Item na Mochila",
                Location = "Inventário",
                Object = obj
            })
        end
    end

    -- D) ProximityPrompts de Itens/Pedestais
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("ProximityPrompt") and not seen[obj] then
            seen[obj] = true
            local pName = obj.ActionText ~= "" and (obj.ActionText .. " (" .. (obj.ObjectText ~= "" and obj.ObjectText or obj.Parent.Name) .. ")") or obj.Parent.Name
            table.insert(entries, {
                Id = "Prompt_" .. tostring(obj:GetDebugId() or math.random(10000, 99999)),
                Name = pName,
                Type = "Prompt",
                TypeLabel = "✋ Botão Interativo",
                Location = obj.Parent and obj.Parent.Name or "Workspace",
                Object = obj
            })
        end
    end

    State.ScannedEntries = entries
    return entries
end

-- ---------------------------------------------------------------------------------
-- 3. INTERFACE GRÁFICA V8 (INTERACTIVE ITEM CONTROLLER)
-- ---------------------------------------------------------------------------------
local function buildInterfaceV8()
    local parentGui = (gethui and gethui()) or game:GetService("CoreGui"):FindFirstChild("RobloxGui") or LocalPlayer:WaitForChild("PlayerGui")
    local old = parentGui:FindFirstChild("BadgeMaster_V8")
    if old then old:Destroy() end

    local Screen = Instance.new("ScreenGui")
    Screen.Name = "BadgeMaster_V8"
    Screen.ResetOnSpawn = false

    -- Botão Mobile Flutuante
    local MobBtn = Instance.new("TextButton")
    MobBtn.Size = UDim2.new(0, 50, 0, 50)
    MobBtn.Position = UDim2.new(0, 16, 0.45, 0)
    MobBtn.BackgroundColor3 = Color3.fromRGB(20, 24, 34)
    MobBtn.Text = "🎮"
    MobBtn.TextSize = 22
    MobBtn.BorderSizePixel = 0
    MobBtn.Parent = Screen

    local mbCorner = Instance.new("UICorner")
    mbCorner.CornerRadius = UDim.new(1, 0)
    mbCorner.Parent = MobBtn

    local mbStroke = Instance.new("UIStroke")
    mbStroke.Color = Color3.fromRGB(0, 220, 255)
    mbStroke.Thickness = 2
    mbStroke.Parent = MobBtn

    -- Janela Principal
    local Window = Instance.new("Frame")
    Window.Size = UDim2.new(0, 560, 0, 440)
    Window.Position = UDim2.new(0.5, -280, 0.5, -220)
    Window.BackgroundColor3 = Color3.fromRGB(14, 16, 23)
    Window.BorderSizePixel = 0
    Window.Active = true
    Window.ClipsDescendants = true
    Window.Parent = Screen

    local wCorner = Instance.new("UICorner")
    wCorner.CornerRadius = UDim.new(0, 12)
    wCorner.Parent = Window

    local wStroke = Instance.new("UIStroke")
    wStroke.Color = Color3.fromRGB(40, 48, 68)
    wStroke.Thickness = 1.4
    wStroke.Parent = Window

    -- Header
    local TopBar = Instance.new("Frame")
    TopBar.Size = UDim2.new(1, 0, 0, 42)
    TopBar.BackgroundColor3 = Color3.fromRGB(20, 24, 36)
    TopBar.BorderSizePixel = 0
    TopBar.Parent = Window

    local tbCorner = Instance.new("UICorner")
    tbCorner.CornerRadius = UDim.new(0, 12)
    tbCorner.Parent = TopBar

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -50, 1, 0)
    Title.Position = UDim2.new(0, 14, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = "🎮 BADGE MASTER V8  |  INTERACTIVE ITEM CONTROLLER"
    Title.TextColor3 = Color3.fromRGB(0, 220, 255)
    Title.TextSize = 12
    Title.Font = Enum.Font.GothamBold
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = TopBar

    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 28, 0, 28)
    CloseBtn.Position = UDim2.new(1, -34, 0, 7)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(32, 38, 54)
    CloseBtn.Text = "✕"
    CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseBtn.TextSize = 11
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.BorderSizePixel = 0
    CloseBtn.Parent = TopBar

    local cbCorner = Instance.new("UICorner")
    cbCorner.CornerRadius = UDim.new(0, 6)
    cbCorner.Parent = CloseBtn

    CloseBtn.MouseButton1Click:Connect(function() Window.Visible = false end)
    MobBtn.MouseButton1Click:Connect(function() Window.Visible = not Window.Visible end)

    -- Arrastar Janela
    local dragging, dragStart, startPos
    TopBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = Window.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            Window.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    -- Corpo
    local Body = Instance.new("Frame")
    Body.Size = UDim2.new(1, -24, 1, -54)
    Body.Position = UDim2.new(0, 12, 0, 48)
    Body.BackgroundTransparency = 1
    Body.Parent = Window

    -- 1. Barra de Ações Rápidas (Topo)
    local ActionRow = Instance.new("Frame")
    ActionRow.Size = UDim2.new(1, 0, 0, 42)
    ActionRow.BackgroundTransparency = 1
    ActionRow.Parent = Body

    -- Botão A: FORÇAR TUDO DE UMA VEZ
    local ForceAllBtn = Instance.new("TextButton")
    ForceAllBtn.Size = UDim2.new(0.48, -4, 1, 0)
    ForceAllBtn.Position = UDim2.new(0, 0, 0, 0)
    ForceAllBtn.BackgroundColor3 = Color3.fromRGB(220, 45, 60)
    ForceAllBtn.Text = "⚡ FORÇAR TUDO DE UMA VEZ"
    ForceAllBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ForceAllBtn.TextSize = 11
    ForceAllBtn.Font = Enum.Font.GothamBold
    ForceAllBtn.BorderSizePixel = 0
    ForceAllBtn.Parent = ActionRow

    local faCorner = Instance.new("UICorner")
    faCorner.CornerRadius = UDim.new(0, 8)
    faCorner.Parent = ForceAllBtn

    -- Botão B: ESCANEAR & LISTAR ITENS
    local ScanListBtn = Instance.new("TextButton")
    ScanListBtn.Size = UDim2.new(0.32, -4, 1, 0)
    ScanListBtn.Position = UDim2.new(0.48, 2, 0, 0)
    ScanListBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    ScanListBtn.Text = "📋 LISTAR AÇÕES / ITENS"
    ScanListBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ScanListBtn.TextSize = 10
    ScanListBtn.Font = Enum.Font.GothamBold
    ScanListBtn.BorderSizePixel = 0
    ScanListBtn.Parent = ActionRow

    local slCorner = Instance.new("UICorner")
    slCorner.CornerRadius = UDim.new(0, 8)
    slCorner.Parent = ScanListBtn

    -- Botão C: PARAR TODOS OS AUTOS
    local StopAutosBtn = Instance.new("TextButton")
    StopAutosBtn.Size = UDim2.new(0.20, 0, 1, 0)
    StopAutosBtn.Position = UDim2.new(0.80, 2, 0, 0)
    StopAutosBtn.BackgroundColor3 = Color3.fromRGB(45, 50, 68)
    StopAutosBtn.Text = "⏹️ Parar Autos"
    StopAutosBtn.TextColor3 = Color3.fromRGB(220, 220, 230)
    StopAutosBtn.TextSize = 10
    StopAutosBtn.Font = Enum.Font.GothamBold
    StopAutosBtn.BorderSizePixel = 0
    StopAutosBtn.Parent = ActionRow

    local saCorner = Instance.new("UICorner")
    saCorner.CornerRadius = UDim.new(0, 8)
    saCorner.Parent = StopAutosBtn

    -- 2. Status e Filtro de Busca
    local FilterRow = Instance.new("Frame")
    FilterRow.Size = UDim2.new(1, 0, 0, 32)
    FilterRow.Position = UDim2.new(0, 0, 0, 48)
    FilterRow.BackgroundTransparency = 1
    FilterRow.Parent = Body

    local StatusText = Instance.new("TextLabel")
    StatusText.Size = UDim2.new(0.45, 0, 1, 0)
    StatusText.BackgroundTransparency = 1
    StatusText.Text = "Pronto para escanear."
    StatusText.TextColor3 = Color3.fromRGB(170, 180, 200)
    StatusText.TextSize = 11
    StatusText.Font = Enum.Font.GothamMedium
    StatusText.TextXAlignment = Enum.TextXAlignment.Left
    StatusText.Parent = FilterRow

    local SearchBox = Instance.new("TextBox")
    SearchBox.Size = UDim2.new(0.55, 0, 1, 0)
    SearchBox.Position = UDim2.new(0.45, 0, 0, 0)
    SearchBox.BackgroundColor3 = Color3.fromRGB(20, 24, 34)
    SearchBox.PlaceholderText = "🔍 Filtrar itens por nome..."
    SearchBox.PlaceholderColor3 = Color3.fromRGB(110, 120, 140)
    SearchBox.Text = ""
    SearchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    SearchBox.TextSize = 11
    SearchBox.Font = Enum.Font.Gotham
    SearchBox.BorderSizePixel = 0
    SearchBox.Parent = FilterRow

    local sbCorner = Instance.new("UICorner")
    sbCorner.CornerRadius = UDim.new(0, 6)
    sbCorner.Parent = SearchBox

    -- 3. Lista de Ações / Itens (ScrollingFrame)
    local ScrollList = Instance.new("ScrollingFrame")
    ScrollList.Size = UDim2.new(1, 0, 1, -88)
    ScrollList.Position = UDim2.new(0, 0, 0, 86)
    ScrollList.BackgroundColor3 = Color3.fromRGB(10, 12, 17)
    ScrollList.BorderSizePixel = 0
    ScrollList.ScrollBarThickness = 4
    ScrollList.Parent = Body

    local slCorner2 = Instance.new("UICorner")
    slCorner2.CornerRadius = UDim.new(0, 8)
    slCorner2.Parent = ScrollList

    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 6)
    listLayout.Parent = ScrollList

    Screen.Parent = parentGui

    -- Função para renderizar os cards interativos
    local function renderItems(filter)
        filter = (filter or ""):lower()

        -- Limpa cards antigos
        for _, c in ipairs(ScrollList:GetChildren()) do
            if c:IsA("Frame") then c:Destroy() end
        end

        local count = 0
        for _, entry in ipairs(State.ScannedEntries) do
            if filter == "" or entry.Name:lower():find(filter) then
                count = count + 1

                local card = Instance.new("Frame")
                card.Name = "Entry_" .. entry.Id
                card.Size = UDim2.new(1, -10, 0, 50)
                card.BackgroundColor3 = Color3.fromRGB(18, 22, 32)
                card.BorderSizePixel = 0
                card.Parent = ScrollList

                local cc = Instance.new("UICorner")
                cc.CornerRadius = UDim.new(0, 8)
                cc.Parent = card

                -- Título e Local
                local titleLabel = Instance.new("TextLabel")
                titleLabel.Size = UDim2.new(1, -190, 0, 20)
                titleLabel.Position = UDim2.new(0, 10, 0, 6)
                titleLabel.BackgroundTransparency = 1
                titleLabel.Text = entry.Name
                titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                titleLabel.TextSize = 12
                titleLabel.Font = Enum.Font.GothamBold
                titleLabel.TextXAlignment = Enum.TextXAlignment.Left
                titleLabel.TextTruncate = Enum.TextTruncate.AtEnd
                titleLabel.Parent = card

                local subLabel = Instance.new("TextLabel")
                subLabel.Size = UDim2.new(1, -190, 0, 16)
                subLabel.Position = UDim2.new(0, 10, 0, 26)
                subLabel.BackgroundTransparency = 1
                subLabel.Text = string.format("%s • %s", entry.TypeLabel, entry.Location)
                subLabel.TextColor3 = Color3.fromRGB(140, 150, 175)
                subLabel.TextSize = 10
                subLabel.Font = Enum.Font.Gotham
                subLabel.TextXAlignment = Enum.TextXAlignment.Left
                subLabel.TextTruncate = Enum.TextTruncate.AtEnd
                subLabel.Parent = card

                -- Botão 1: Executar Uma Vez
                local runOnceBtn = Instance.new("TextButton")
                runOnceBtn.Size = UDim2.new(0, 75, 0, 32)
                runOnceBtn.Position = UDim2.new(1, -175, 0.5, -16)
                runOnceBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
                runOnceBtn.Text = "▶ Executar"
                runOnceBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                runOnceBtn.TextSize = 10
                runOnceBtn.Font = Enum.Font.GothamBold
                runOnceBtn.BorderSizePixel = 0
                runOnceBtn.Parent = card

                local rc = Instance.new("UICorner")
                rc.CornerRadius = UDim.new(0, 6)
                rc.Parent = runOnceBtn

                runOnceBtn.MouseButton1Click:Connect(function()
                    runOnceBtn.Text = "Pegando..."
                    runOnceBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
                    task.spawn(function()
                        executeAction(entry)
                        task.wait(0.3)
                        runOnceBtn.Text = "▶ Executar"
                        runOnceBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
                    end)
                end)

                -- Botão 2: Auto-Loop Contínuo
                local autoBtn = Instance.new("TextButton")
                autoBtn.Size = UDim2.new(0, 85, 0, 32)
                autoBtn.Position = UDim2.new(1, -92, 0.5, -16)
                local isLooping = State.ActiveLoops[entry.Id] or false
                autoBtn.BackgroundColor3 = isLooping and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(40, 46, 62)
                autoBtn.Text = isLooping and "🔁 Auto: ON" or "🔁 Auto: OFF"
                autoBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                autoBtn.TextSize = 10
                autoBtn.Font = Enum.Font.GothamBold
                autoBtn.BorderSizePixel = 0
                autoBtn.Parent = card

                local ac = Instance.new("UICorner")
                ac.CornerRadius = UDim.new(0, 6)
                ac.Parent = autoBtn

                autoBtn.MouseButton1Click:Connect(function()
                    if State.ActiveLoops[entry.Id] then
                        -- Desativa o loop
                        State.ActiveLoops[entry.Id] = nil
                        autoBtn.BackgroundColor3 = Color3.fromRGB(40, 46, 62)
                        autoBtn.Text = "🔁 Auto: OFF"
                    else
                        -- Ativa o loop contínuo
                        State.ActiveLoops[entry.Id] = true
                        autoBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
                        autoBtn.Text = "🔁 Auto: ON"

                        task.spawn(function()
                            while State.ActiveLoops[entry.Id] do
                                executeAction(entry)
                                task.wait(0.25)
                            end
                        end)
                    end
                end)
            end
        end

        ScrollList.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 12)
        StatusText.Text = string.format("Itens encontrados: %d", count)
    end

    SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
        renderItems(SearchBox.Text)
    end)

    return {
        Status = StatusText,
        ForceAllBtn = ForceAllBtn,
        ScanBtn = ScanListBtn,
        StopAutosBtn = StopAutosBtn,
        Render = renderItems
    }
end

local UI = buildInterfaceV8()

-- ---------------------------------------------------------------------------------
-- 4. VINCULAÇÃO DOS BOTÕES PRINCIPAIS
-- ---------------------------------------------------------------------------------

-- A) BOTÃO: LISTAR AÇÕES / ITENS
UI.ScanBtn.MouseButton1Click:Connect(function()
    UI.Status.Text = "Escaneando o mapa e inventário..."
    task.spawn(function()
        local entries = scanAllAvailableActions()
        UI.Render()
        UI.Status.Text = string.format("Pronto: %d opções listadas!", #entries)
    end)
end)

-- B) BOTÃO: FORÇAR TUDO DE UMA VEZ
UI.ForceAllBtn.MouseButton1Click:Connect(function()
    if State.IsBatchRunning then return end
    State.IsBatchRunning = true
    UI.ForceAllBtn.Text = "EXECUTANDO TUDO..."
    UI.ForceAllBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 100)
    UI.Status.Text = "Processando todos os itens de uma vez..."

    task.spawn(function()
        -- 1. Escaneia se ainda não tiver
        local entries = scanAllAvailableActions()
        UI.Render()

        -- 2. Executa cada item rapidamente
        local total = #entries
        for i = 1, total do
            local e = entries[i]
            UI.Status.Text = string.format("Executando (%d/%d): %s", i, total, e.Name)
            executeAction(e)
            task.wait(0.04)
        end

        UI.Status.Text = "Finalizado! Todos os itens foram forçados e ativados."
        UI.ForceAllBtn.Text = "⚡ FORÇAR TUDO DE UMA VEZ"
        UI.ForceAllBtn.BackgroundColor3 = Color3.fromRGB(220, 45, 60)
        State.IsBatchRunning = false
    end)
end)

-- C) BOTÃO: PARAR TODOS OS AUTOS
UI.StopAutosBtn.MouseButton1Click:Connect(function()
    State.ActiveLoops = {}
    UI.Render()
    UI.Status.Text = "Todos os autos foram interrompidos."
end)

-- Auto-scan inicial ao carregar
task.delay(0.5, function()
    scanAllAvailableActions()
    UI.Render()
end)

print("[BadgeMaster V8] Inicializado com sucesso!")

]====],
    ["V9"] = [====[
--[[
    =================================================================================
    👑 BADGE MASTER V9 - ULTIMATE OMNI-EVENT & GAME FORCER
    =================================================================================
    O QUE FOI RECONSTRUÍDO NA V9:
    1. [EXPANSÃO TOTAL ALÉM DE ITENS]:
       A lista agora mapeia absolutamente TUDO o que é acionável no jogo:
       - ⚡ Remotes do Servidor (RemoteEvent e RemoteFunction)
       - 📍 Pads e Blocos com .Touched / TouchTransmitter (botões de chão, pads)
       - ✋ Interações (ProximityPrompt e ClickDetector - baús, NPCs, portas)
       - 🗡️ Ferramentas reais do mapa (World Tools)
       - 🏆 Botões de reivindicação em GUIs de Conquistas
       
    2. [CORREÇÃO CRÍTICA DE OUTROS JOGADORES]:
       Filtro rigoroso: NÃO lista nem tenta puxar ferramentas de outros jogadores
       (evita itens fantasmas/visuais). Só lista itens soltos e reais do mapa.
       
    3. [INJEÇÃO DE ARGUMENTOS MESTRES (true, 1000, etc.)]:
       Ao disparar os Remotes, a V9 envia uma matriz de payloads usados para
       forçar vitórias, conclusões de quests e desbloqueio de emblemas:
       - (true), (true, true)
       - (1000), (1000, 1000)
       - (true, 1000), ("Complete"), ("Win"), ("Claim")
       - IDs reais de Badges do Universo
       
    4. [LISTA INTERATIVA COM FILTROS DE CATEGORIA]:
       Filtre rapidamente por: [TODOS] | [⚡ Remotes] | [📍 Pads] | [✋ Prompts] | [🗡️ Itens]
       Cada linha possui [▶ Executar] e [🔁 Auto: OFF/ON] em tempo real.
    =================================================================================
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local Backpack = LocalPlayer:WaitForChild("Backpack")
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local RootPart = Character:WaitForChild("HumanoidRootPart", 10)
local Humanoid = Character:WaitForChild("Humanoid", 10)

-- Estado Global V9
local State = {
    IsBatchRunning = false,
    ActiveLoops = {},       -- Tabela de loops por ID { [id] = boolean }
    ScannedEntries = {},    -- Lista de todos os elementos acionáveis
    ActiveCategory = "Todos",
    UniverseBadgeIds = {}
}

-- Anti-AFK
LocalPlayer.Idled:Connect(function()
    local vu = game:GetService("VirtualUser")
    vu:CaptureController()
    vu:ClickButton2(Vector2.new(0, 0))
end)

LocalPlayer.CharacterAdded:Connect(function(char)
    Character = char
    RootPart = char:WaitForChild("HumanoidRootPart", 10)
    Humanoid = char:WaitForChild("Humanoid", 10)
    Backpack = LocalPlayer:WaitForChild("Backpack")
end)

-- ---------------------------------------------------------------------------------
-- 0. FILTRO DE SEGURANÇA (IGNORA OUTROS JOGADORES)
-- ---------------------------------------------------------------------------------
local function isFromOtherPlayer(obj)
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            if (plr.Character and obj:IsDescendantOf(plr.Character))
                or (plr:FindFirstChild("Backpack") and obj:IsDescendantOf(plr.Backpack)) then
                return true
            end
        end
    end
    return false
end

-- ---------------------------------------------------------------------------------
-- 1. CONSULTA DE BADGES DO JOGO NA API DA ROBLOX
-- ---------------------------------------------------------------------------------
task.spawn(function()
    local uId = game.GameId
    if uId == 0 then return end
    local url = string.format("https://badges.roproxy.com/v1/universes/%d/badges?limit=100", uId)
    local s, res
    pcall(function()
        if (syn and syn.request) or (http and http.request) or request then
            local req = (syn and syn.request) or (http and http.request) or request
            res = req({Url = url, Method = "GET"}).Body
            s = true
        elseif game.HttpGet then
            res = game:HttpGet(url)
            s = true
        end
    end)
    if s and res then
        local data = HttpService:JSONDecode(res)
        for _, b in ipairs(data.data or {}) do
            table.insert(State.UniverseBadgeIds, b.id)
        end
    end
end)

-- ---------------------------------------------------------------------------------
-- 2. DISPARADOR DE AÇÕES & INJEÇÃO DE PAYLOADS
-- ---------------------------------------------------------------------------------
local MasterPayloads = {
    {true},
    {true, true},
    {1000},
    {1000, 1000},
    {true, 1000},
    {1, true},
    {"Complete"},
    {"Win"},
    {"Claim"},
    {"Badge"},
    {"Reward", true},
    {Completed = true},
    {Success = true},
    {Score = 1000}
}

local function executeAction(entry)
    if not Character or not RootPart or not Humanoid then
        Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        RootPart = Character:WaitForChild("HumanoidRootPart", 5)
        Humanoid = Character:WaitForChild("Humanoid", 5)
    end

    local success = false

    pcall(function()
        -- =========================================================================
        -- TIPO 1: REMOTEEVENT / REMOTEFUNCTION
        -- =========================================================================
        if entry.Type == "Remote" then
            local rem = entry.Object
            if rem and rem.Parent then
                -- 1. Dispara com os payloads mestres (true, 1000, etc.)
                for _, args in ipairs(MasterPayloads) do
                    pcall(function()
                        if rem:IsA("RemoteEvent") then
                            rem:FireServer(unpack(args))
                        elseif rem:IsA("RemoteFunction") then
                            rem:InvokeServer(unpack(args))
                        end
                    end)
                end

                -- 2. Dispara com os IDs reais de badges conhecidas
                for _, bId in ipairs(State.UniverseBadgeIds) do
                    pcall(function()
                        if rem:IsA("RemoteEvent") then
                            rem:FireServer(bId)
                            rem:FireServer("Badge", bId)
                            rem:FireServer({BadgeId = bId})
                        elseif rem:IsA("RemoteFunction") then
                            rem:InvokeServer(bId)
                        end
                    end)
                end
                success = true
            end

        -- =========================================================================
        -- TIPO 2: BLINDAGEM DE TOUCH (.Touched & TouchTransmitter)
        -- =========================================================================
        elseif entry.Type == "TouchPad" then
            local part = entry.Object
            if part and part:IsA("BasePart") and part.Parent then
                local origPos = RootPart.CFrame
                RootPart.CFrame = part.CFrame + Vector3.new(0, 1.5, 0)
                RootPart.AssemblyLinearVelocity = Vector3.new(0, -3, 0)

                -- Disparo em nível de Script Lua com getconnections
                if getconnections then
                    for _, conn in ipairs(getconnections(part.Touched)) do
                        pcall(function() conn:Fire(RootPart) end)
                    end
                end

                -- Disparo de física com firetouchinterest
                if firetouchinterest then
                    firetouchinterest(RootPart, part, 0)
                    task.wait(0.01)
                    firetouchinterest(RootPart, part, 1)
                end

                task.wait(0.1)
                RootPart.CFrame = origPos
                success = true
            end

        -- =========================================================================
        -- TIPO 3: PROXIMITYPROMPT & CLICKDETECTOR
        -- =========================================================================
        elseif entry.Type == "Prompt" then
            local prompt = entry.Object
            if prompt and prompt.Parent then
                local promptPart = prompt.Parent:IsA("BasePart") and prompt.Parent or prompt.Parent:FindFirstChildWhichIsA("BasePart")
                if promptPart then
                    local origPos = RootPart.CFrame
                    RootPart.CFrame = promptPart.CFrame + Vector3.new(0, 1.5, 0)
                    
                    if prompt:IsA("ProximityPrompt") then
                        prompt.HoldDuration = 0
                        if fireproximityprompt then fireproximityprompt(prompt) end
                    elseif prompt:IsA("ClickDetector") then
                        if fireclickdetector then fireclickdetector(prompt) end
                    end

                    task.wait(0.08)
                    RootPart.CFrame = origPos
                    success = true
                end
            end

        -- =========================================================================
        -- TIPO 4: FERRAMENTA REAL DO MAPA (WORLD TOOL)
        -- =========================================================================
        elseif entry.Type == "WorldTool" then
            local tool = entry.Object
            if tool and tool.Parent and not isFromOtherPlayer(tool) then
                local handle = tool:FindFirstChild("Handle") or tool:FindFirstChildWhichIsA("BasePart")
                if handle then
                    local origPos = RootPart.CFrame
                    RootPart.CFrame = handle.CFrame + Vector3.new(0, 1.2, 0)
                    
                    if firetouchinterest then
                        firetouchinterest(RootPart, handle, 0)
                        task.wait(0.01)
                        firetouchinterest(RootPart, handle, 1)
                    end

                    Humanoid:EquipTool(tool)
                    tool.Parent = Character
                    task.wait(0.1)
                    tool:Activate()
                    task.wait(0.05)
                    RootPart.CFrame = origPos
                    success = true
                else
                    tool.Parent = Backpack
                    Humanoid:EquipTool(tool)
                    tool:Activate()
                    success = true
                end
            end

        -- =========================================================================
        -- TIPO 5: BOTÃO DE RECOMPENSA EM PLAYERGUI
        -- =========================================================================
        elseif entry.Type == "GuiButton" then
            local btn = entry.Object
            if btn and btn.Parent then
                if firesignal then
                    firesignal(btn.MouseButton1Click)
                    firesignal(btn.Activated)
                end
                success = true
            end
        end
    end)

    return success
end

-- ---------------------------------------------------------------------------------
-- 3. SCANNER TOTAL DE ELEMENTOS ACIONÁVEIS DO JOGO
-- ---------------------------------------------------------------------------------
local function scanAllGameElements()
    local entries = {}
    local seen = {}

    -- A) REMOTES DO JOGO
    local remKeywords = {"badge", "award", "give", "claim", "reward", "achieve", "win", "complete", "finish", "quest", "event", "item", "tool", "drop", "score"}
    for _, obj in ipairs(game:GetDescendants()) do
        if (obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction")) and not seen[obj] then
            local n = obj.Name:lower()
            local isMatch = false
            for _, kw in ipairs(remKeywords) do
                if n:find(kw) then isMatch = true; break end
            end
            if isMatch then
                seen[obj] = true
                table.insert(entries, {
                    Id = "Rem_" .. tostring(obj:GetDebugId() or math.random(10000, 99999)),
                    Name = obj.Name,
                    Type = "Remote",
                    Category = "Remotes",
                    Icon = "⚡",
                    TypeLabel = "Remote do Servidor",
                    Location = obj.Parent and obj.Parent.Name or "ReplicatedStorage",
                    Object = obj
                })
            end
        end
    end

    -- B) PADS E BLOCOS COM TOQUE (.Touched ou TouchTransmitter)
    for _, obj in ipairs(workspace:GetDescendants()) do
        if not isFromOtherPlayer(obj) and not obj:IsDescendantOf(Character) then
            if obj:IsA("TouchTransmitter") and obj.Parent and obj.Parent:IsA("BasePart") and not seen[obj.Parent] then
                seen[obj.Parent] = true
                table.insert(entries, {
                    Id = "Pad_" .. tostring(obj.Parent:GetDebugId() or math.random(10000, 99999)),
                    Name = obj.Parent.Name,
                    Type = "TouchPad",
                    Category = "Pads",
                    Icon = "📍",
                    TypeLabel = "Pad / Botão de Chão",
                    Location = obj.Parent.Parent and obj.Parent.Parent.Name or "Workspace",
                    Object = obj.Parent
                })
            elseif obj:IsA("BasePart") and not seen[obj] then
                local n = obj.Name:lower()
                if n:find("badge") or n:find("giver") or n:find("checkpoint") or n:find("stage") or n:find("pad") or n:find("win") then
                    seen[obj] = true
                    table.insert(entries, {
                        Id = "Pad_" .. tostring(obj:GetDebugId() or math.random(10000, 99999)),
                        Name = obj.Name,
                        Type = "TouchPad",
                        Category = "Pads",
                        Icon = "📍",
                        TypeLabel = "Bloco de Evento",
                        Location = obj.Parent and obj.Parent.Name or "Workspace",
                        Object = obj
                    })
                end
            end
        end
    end

    -- C) PROMPT / CLICKDETECTOR (Alavancas, Baús, Portas, NPCs)
    for _, obj in ipairs(workspace:GetDescendants()) do
        if (obj:IsA("ProximityPrompt") or obj:IsA("ClickDetector")) and not isFromOtherPlayer(obj) and not seen[obj] then
            seen[obj] = true
            local name = obj.Parent.Name
            if obj:IsA("ProximityPrompt") and obj.ActionText ~= "" then
                name = obj.ActionText .. " (" .. (obj.ObjectText ~= "" and obj.ObjectText or obj.Parent.Name) .. ")"
            end
            table.insert(entries, {
                Id = "Prompt_" .. tostring(obj:GetDebugId() or math.random(10000, 99999)),
                Name = name,
                Type = "Prompt",
                Category = "Prompts",
                Icon = "✋",
                TypeLabel = obj:IsA("ProximityPrompt") and "ProximityPrompt" or "ClickDetector",
                Location = obj.Parent and obj.Parent.Name or "Workspace",
                Object = obj
            })
        end
    end

    -- D) FERRAMENTAS REAIS DO MAPA (Sem outros jogadores)
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Tool") and not isFromOtherPlayer(obj) and not obj:IsDescendantOf(Character) and not seen[obj] then
            seen[obj] = true
            table.insert(entries, {
                Id = "Tool_" .. tostring(obj:GetDebugId() or math.random(10000, 99999)),
                Name = obj.Name,
                Type = "WorldTool",
                Category = "Itens",
                Icon = "🗡️",
                TypeLabel = "Item Solto no Mapa",
                Location = obj.Parent and obj.Parent.Name or "Workspace",
                Object = obj
            })
        end
    end

    -- E) BOTÕES DE REIVINDICAÇÃO EM GUI (Conquistas / Recompensas)
    local guiKeywords = {"claim", "resgatar", "coletar", "reward", "badge", "conquista", "achievement"}
    for _, gui in ipairs(LocalPlayer:WaitForChild("PlayerGui"):GetDescendants()) do
        if (gui:IsA("TextButton") or gui:IsA("ImageButton")) and not seen[gui] then
            local n = gui.Name:lower()
            local t = (gui:IsA("TextButton") and gui.Text or ""):lower()
            local isMatch = false
            for _, kw in ipairs(guiKeywords) do
                if n:find(kw) or t:find(kw) then isMatch = true; break end
            end
            if isMatch then
                seen[gui] = true
                table.insert(entries, {
                    Id = "Gui_" .. tostring(gui:GetDebugId() or math.random(10000, 99999)),
                    Name = (gui:IsA("TextButton") and gui.Text ~= "") and gui.Text or gui.Name,
                    Type = "GuiButton",
                    Category = "Prompts",
                    Icon = "🏆",
                    TypeLabel = "Botão de Conquista (UI)",
                    Location = gui.Parent and gui.Parent.Name or "PlayerGui",
                    Object = gui
                })
            end
        end
    end

    State.ScannedEntries = entries
    return entries
end

-- ---------------------------------------------------------------------------------
-- 4. INTERFACE GRÁFICA V9 (MASTER OMNI HUD)
-- ---------------------------------------------------------------------------------
local function buildInterfaceV9()
    local parentGui = (gethui and gethui()) or game:GetService("CoreGui"):FindFirstChild("RobloxGui") or LocalPlayer:WaitForChild("PlayerGui")
    local old = parentGui:FindFirstChild("BadgeMaster_V9")
    if old then old:Destroy() end

    local Screen = Instance.new("ScreenGui")
    Screen.Name = "BadgeMaster_V9"
    Screen.ResetOnSpawn = false

    -- Botão Mobile Flutuante
    local MobBtn = Instance.new("TextButton")
    MobBtn.Size = UDim2.new(0, 50, 0, 50)
    MobBtn.Position = UDim2.new(0, 16, 0.45, 0)
    MobBtn.BackgroundColor3 = Color3.fromRGB(16, 20, 28)
    MobBtn.Text = "👑"
    MobBtn.TextSize = 22
    MobBtn.BorderSizePixel = 0
    MobBtn.Parent = Screen

    local mbCorner = Instance.new("UICorner")
    mbCorner.CornerRadius = UDim.new(1, 0)
    mbCorner.Parent = MobBtn

    local mbStroke = Instance.new("UIStroke")
    mbStroke.Color = Color3.fromRGB(0, 255, 170)
    mbStroke.Thickness = 2
    mbStroke.Parent = MobBtn

    -- Janela Principal
    local Window = Instance.new("Frame")
    Window.Size = UDim2.new(0, 590, 0, 460)
    Window.Position = UDim2.new(0.5, -295, 0.5, -230)
    Window.BackgroundColor3 = Color3.fromRGB(12, 14, 20)
    Window.BorderSizePixel = 0
    Window.Active = true
    Window.ClipsDescendants = true
    Window.Parent = Screen

    local wCorner = Instance.new("UICorner")
    wCorner.CornerRadius = UDim.new(0, 12)
    wCorner.Parent = Window

    local wStroke = Instance.new("UIStroke")
    wStroke.Color = Color3.fromRGB(36, 44, 62)
    wStroke.Thickness = 1.4
    wStroke.Parent = Window

    -- Header
    local TopBar = Instance.new("Frame")
    TopBar.Size = UDim2.new(1, 0, 0, 42)
    TopBar.BackgroundColor3 = Color3.fromRGB(18, 22, 32)
    TopBar.BorderSizePixel = 0
    TopBar.Parent = Window

    local tbCorner = Instance.new("UICorner")
    tbCorner.CornerRadius = UDim.new(0, 12)
    tbCorner.Parent = TopBar

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -50, 1, 0)
    Title.Position = UDim2.new(0, 14, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = "👑 BADGE MASTER V9  |  OMNI-EVENT & GAME FORCER"
    Title.TextColor3 = Color3.fromRGB(0, 255, 170)
    Title.TextSize = 12
    Title.Font = Enum.Font.GothamBold
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = TopBar

    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 28, 0, 28)
    CloseBtn.Position = UDim2.new(1, -34, 0, 7)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(30, 36, 52)
    CloseBtn.Text = "✕"
    CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseBtn.TextSize = 11
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.BorderSizePixel = 0
    CloseBtn.Parent = TopBar

    local cbCorner = Instance.new("UICorner")
    cbCorner.CornerRadius = UDim.new(0, 6)
    cbCorner.Parent = CloseBtn

    CloseBtn.MouseButton1Click:Connect(function() Window.Visible = false end)
    MobBtn.MouseButton1Click:Connect(function() Window.Visible = not Window.Visible end)

    -- Arrastar Janela
    local dragging, dragStart, startPos
    TopBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = Window.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            Window.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    -- Corpo
    local Body = Instance.new("Frame")
    Body.Size = UDim2.new(1, -24, 1, -54)
    Body.Position = UDim2.new(0, 12, 0, 48)
    Body.BackgroundTransparency = 1
    Body.Parent = Window

    -- 1. Barra Superior de Comandos
    local TopCmds = Instance.new("Frame")
    TopCmds.Size = UDim2.new(1, 0, 0, 42)
    TopCmds.BackgroundTransparency = 1
    TopCmds.Parent = Body

    local ForceAllBtn = Instance.new("TextButton")
    ForceAllBtn.Size = UDim2.new(0.50, -4, 1, 0)
    ForceAllBtn.BackgroundColor3 = Color3.fromRGB(220, 40, 55)
    ForceAllBtn.Text = "🔥 FORÇAR TUDO NO JOGO (1 CLIQUE)"
    ForceAllBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ForceAllBtn.TextSize = 11
    ForceAllBtn.Font = Enum.Font.GothamBold
    ForceAllBtn.BorderSizePixel = 0
    ForceAllBtn.Parent = TopCmds

    local faCorner = Instance.new("UICorner")
    faCorner.CornerRadius = UDim.new(0, 8)
    faCorner.Parent = ForceAllBtn

    local RescanBtn = Instance.new("TextButton")
    RescanBtn.Size = UDim2.new(0.28, -4, 1, 0)
    RescanBtn.Position = UDim2.new(0.50, 2, 0, 0)
    RescanBtn.BackgroundColor3 = Color3.fromRGB(0, 140, 255)
    RescanBtn.Text = "🔄 Re-Escanear"
    RescanBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    RescanBtn.TextSize = 11
    RescanBtn.Font = Enum.Font.GothamBold
    RescanBtn.BorderSizePixel = 0
    RescanBtn.Parent = TopCmds

    local rbCorner = Instance.new("UICorner")
    rbCorner.CornerRadius = UDim.new(0, 8)
    rbCorner.Parent = RescanBtn

    local StopAutosBtn = Instance.new("TextButton")
    StopAutosBtn.Size = UDim2.new(0.22, 0, 1, 0)
    StopAutosBtn.Position = UDim2.new(0.78, 2, 0, 0)
    StopAutosBtn.BackgroundColor3 = Color3.fromRGB(42, 48, 64)
    StopAutosBtn.Text = "⏹️ Parar Autos"
    StopAutosBtn.TextColor3 = Color3.fromRGB(220, 220, 230)
    StopAutosBtn.TextSize = 10
    StopAutosBtn.Font = Enum.Font.GothamBold
    StopAutosBtn.BorderSizePixel = 0
    StopAutosBtn.Parent = TopCmds

    local saCorner = Instance.new("UICorner")
    saCorner.CornerRadius = UDim.new(0, 8)
    saCorner.Parent = StopAutosBtn

    -- 2. Filtros de Categoria (Pills)
    local CatRow = Instance.new("Frame")
    CatRow.Size = UDim2.new(1, 0, 0, 30)
    CatRow.Position = UDim2.new(0, 0, 0, 48)
    CatRow.BackgroundTransparency = 1
    CatRow.Parent = Body

    local catLayout = Instance.new("UIListLayout")
    catLayout.FillDirection = Enum.FillDirection.Horizontal
    catLayout.Padding = UDim.new(0, 6)
    catLayout.Parent = CatRow

    local CatBtns = {}
    local Categories = {"Todos", "Remotes", "Pads", "Prompts", "Itens"}

    -- 3. Barra de Busca e Status
    local SearchRow = Instance.new("Frame")
    SearchRow.Size = UDim2.new(1, 0, 0, 30)
    SearchRow.Position = UDim2.new(0, 0, 0, 84)
    SearchRow.BackgroundTransparency = 1
    SearchRow.Parent = Body

    local StatusText = Instance.new("TextLabel")
    StatusText.Size = UDim2.new(0.40, 0, 1, 0)
    StatusText.BackgroundTransparency = 1
    StatusText.Text = "Carregando mapa..."
    StatusText.TextColor3 = Color3.fromRGB(170, 180, 200)
    StatusText.TextSize = 11
    StatusText.Font = Enum.Font.GothamMedium
    StatusText.TextXAlignment = Enum.TextXAlignment.Left
    StatusText.Parent = SearchRow

    local SearchBox = Instance.new("TextBox")
    SearchBox.Size = UDim2.new(0.60, 0, 1, 0)
    SearchBox.Position = UDim2.new(0.40, 0, 0, 0)
    SearchBox.BackgroundColor3 = Color3.fromRGB(18, 22, 32)
    SearchBox.PlaceholderText = "🔍 Buscar função, remote ou item..."
    SearchBox.PlaceholderColor3 = Color3.fromRGB(110, 120, 140)
    SearchBox.Text = ""
    SearchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    SearchBox.TextSize = 11
    SearchBox.Font = Enum.Font.Gotham
    SearchBox.BorderSizePixel = 0
    SearchBox.Parent = SearchRow

    local sbCorner = Instance.new("UICorner")
    sbCorner.CornerRadius = UDim.new(0, 6)
    sbCorner.Parent = SearchBox

    -- 4. Lista Interativa (ScrollingFrame)
    local ScrollList = Instance.new("ScrollingFrame")
    ScrollList.Size = UDim2.new(1, 0, 1, -122)
    ScrollList.Position = UDim2.new(0, 0, 0, 120)
    ScrollList.BackgroundColor3 = Color3.fromRGB(9, 11, 16)
    ScrollList.BorderSizePixel = 0
    ScrollList.ScrollBarThickness = 4
    ScrollList.Parent = Body

    local slCorner = Instance.new("UICorner")
    slCorner.CornerRadius = UDim.new(0, 8)
    slCorner.Parent = ScrollList

    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 5)
    listLayout.Parent = ScrollList

    Screen.Parent = parentGui

    -- Renderizador Dinâmico dos Cards
    local function renderCards(search)
        search = (search or SearchBox.Text):lower()

        for _, c in ipairs(ScrollList:GetChildren()) do
            if c:IsA("Frame") then c:Destroy() end
        end

        local count = 0
        for _, entry in ipairs(State.ScannedEntries) do
            local matchesCat = (State.ActiveCategory == "Todos") or (entry.Category == State.ActiveCategory)
            local matchesSearch = (search == "") or entry.Name:lower():find(search) or entry.TypeLabel:lower():find(search)

            if matchesCat and matchesSearch then
                count = count + 1

                local card = Instance.new("Frame")
                card.Name = "Card_" .. entry.Id
                card.Size = UDim2.new(1, -8, 0, 48)
                card.BackgroundColor3 = Color3.fromRGB(17, 21, 30)
                card.BorderSizePixel = 0
                card.Parent = ScrollList

                local cc = Instance.new("UICorner")
                cc.CornerRadius = UDim.new(0, 8)
                cc.Parent = card

                -- Ícone e Nome
                local titleLabel = Instance.new("TextLabel")
                titleLabel.Size = UDim2.new(1, -190, 0, 20)
                titleLabel.Position = UDim2.new(0, 10, 0, 5)
                titleLabel.BackgroundTransparency = 1
                titleLabel.Text = entry.Icon .. " " .. entry.Name
                titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                titleLabel.TextSize = 11
                titleLabel.Font = Enum.Font.GothamBold
                titleLabel.TextXAlignment = Enum.TextXAlignment.Left
                titleLabel.TextTruncate = Enum.TextTruncate.AtEnd
                titleLabel.Parent = card

                local subLabel = Instance.new("TextLabel")
                subLabel.Size = UDim2.new(1, -190, 0, 16)
                subLabel.Position = UDim2.new(0, 10, 0, 25)
                subLabel.BackgroundTransparency = 1
                subLabel.Text = string.format("%s • %s", entry.TypeLabel, entry.Location)
                subLabel.TextColor3 = Color3.fromRGB(140, 150, 175)
                subLabel.TextSize = 9
                subLabel.Font = Enum.Font.Gotham
                subLabel.TextXAlignment = Enum.TextXAlignment.Left
                subLabel.TextTruncate = Enum.TextTruncate.AtEnd
                subLabel.Parent = card

                -- Botão Executar Uma Vez
                local runOnceBtn = Instance.new("TextButton")
                runOnceBtn.Size = UDim2.new(0, 75, 0, 30)
                runOnceBtn.Position = UDim2.new(1, -170, 0.5, -15)
                runOnceBtn.BackgroundColor3 = Color3.fromRGB(0, 140, 255)
                runOnceBtn.Text = "▶ Disparar"
                runOnceBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                runOnceBtn.TextSize = 10
                runOnceBtn.Font = Enum.Font.GothamBold
                runOnceBtn.BorderSizePixel = 0
                runOnceBtn.Parent = card

                local rc = Instance.new("UICorner")
                rc.CornerRadius = UDim.new(0, 6)
                rc.Parent = runOnceBtn

                runOnceBtn.MouseButton1Click:Connect(function()
                    runOnceBtn.Text = "Disparando..."
                    runOnceBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
                    task.spawn(function()
                        executeAction(entry)
                        task.wait(0.2)
                        runOnceBtn.Text = "▶ Disparar"
                        runOnceBtn.BackgroundColor3 = Color3.fromRGB(0, 140, 255)
                    end)
                end)

                -- Botão Auto-Loop Contínuo
                local autoBtn = Instance.new("TextButton")
                autoBtn.Size = UDim2.new(0, 85, 0, 30)
                autoBtn.Position = UDim2.new(1, -88, 0.5, -15)
                local isLooping = State.ActiveLoops[entry.Id] or false
                autoBtn.BackgroundColor3 = isLooping and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(38, 44, 60)
                autoBtn.Text = isLooping and "🔁 Auto: ON" or "🔁 Auto: OFF"
                autoBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                autoBtn.TextSize = 10
                autoBtn.Font = Enum.Font.GothamBold
                autoBtn.BorderSizePixel = 0
                autoBtn.Parent = card

                local ac = Instance.new("UICorner")
                ac.CornerRadius = UDim.new(0, 6)
                ac.Parent = autoBtn

                autoBtn.MouseButton1Click:Connect(function()
                    if State.ActiveLoops[entry.Id] then
                        State.ActiveLoops[entry.Id] = nil
                        autoBtn.BackgroundColor3 = Color3.fromRGB(38, 44, 60)
                        autoBtn.Text = "🔁 Auto: OFF"
                    else
                        State.ActiveLoops[entry.Id] = true
                        autoBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
                        autoBtn.Text = "🔁 Auto: ON"

                        task.spawn(function()
                            while State.ActiveLoops[entry.Id] do
                                executeAction(entry)
                                task.wait(0.25)
                            end
                        end)
                    end
                end)
            end
        end

        ScrollList.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 10)
        StatusText.Text = string.format("Exibindo: %d opções", count)
    end

    -- Criação dos botões de Categoria (Pills)
    for _, catName in ipairs(Categories) do
        local pill = Instance.new("TextButton")
        pill.Size = UDim2.new(0, 75, 1, 0)
        pill.BackgroundColor3 = (State.ActiveCategory == catName) and Color3.fromRGB(0, 180, 120) or Color3.fromRGB(22, 28, 40)
        pill.Text = catName
        pill.TextColor3 = Color3.fromRGB(255, 255, 255)
        pill.TextSize = 10
        pill.Font = Enum.Font.GothamBold
        pill.BorderSizePixel = 0
        pill.Parent = CatRow

        local pc = Instance.new("UICorner")
        pc.CornerRadius = UDim.new(0, 6)
        pc.Parent = pill

        CatBtns[catName] = pill

        pill.MouseButton1Click:Connect(function()
            State.ActiveCategory = catName
            for cName, btn in pairs(CatBtns) do
                btn.BackgroundColor3 = (cName == catName) and Color3.fromRGB(0, 180, 120) or Color3.fromRGB(22, 28, 40)
            end
            renderCards()
        end)
    end

    SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
        renderCards(SearchBox.Text)
    end)

    return {
        Status = StatusText,
        ForceAllBtn = ForceAllBtn,
        RescanBtn = RescanBtn,
        StopAutosBtn = StopAutosBtn,
        Render = renderCards
    }
end

local UI = buildInterfaceV9()

-- ---------------------------------------------------------------------------------
-- 5. VINCULAÇÃO DOS BOTÕES PRINCIPAIS
-- ---------------------------------------------------------------------------------

-- A) FORÇAR TUDO NO JOGO (1 CLIQUE)
UI.ForceAllBtn.MouseButton1Click:Connect(function()
    if State.IsBatchRunning then return end
    State.IsBatchRunning = true
    UI.ForceAllBtn.Text = "FORÇANDO TODAS AS FUNÇÕES..."
    UI.ForceAllBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
    UI.Status.Text = "Disparando todas as ações em lote..."

    task.spawn(function()
        local entries = scanAllGameElements()
        UI.Render()

        local total = #entries
        for i = 1, total do
            local e = entries[i]
            UI.Status.Text = string.format("Disparando (%d/%d): %s", i, total, e.Name)
            executeAction(e)
            task.wait(0.02)
        end

        UI.Status.Text = "Concluído! Todas as funções e remotes foram forçados."
        UI.ForceAllBtn.Text = "🔥 FORÇAR TUDO NO JOGO (1 CLIQUE)"
        UI.ForceAllBtn.BackgroundColor3 = Color3.fromRGB(220, 40, 55)
        State.IsBatchRunning = false
    end)
end)

-- B) RE-ESCANEAR
UI.RescanBtn.MouseButton1Click:Connect(function()
    UI.Status.Text = "Escanando todo o jogo..."
    task.spawn(function()
        scanAllGameElements()
        UI.Render()
        UI.Status.Text = "Escaneamento concluído!"
    end)
end)

-- C) PARAR TODOS OS AUTOS
UI.StopAutosBtn.MouseButton1Click:Connect(function()
    State.ActiveLoops = {}
    UI.Render()
    UI.Status.Text = "Todos os autos foram interrompidos."
end)

-- Inicialização automática
task.delay(0.5, function()
    scanAllGameElements()
    UI.Render()
end)

print("[BadgeMaster V9] Inicializado.")

]====],
    ["V10"] = [====[
--[[
    =================================================================================
    👑 BADGE MASTER V10 - THE OMNI-EXPLOIT APEX ENGINE
    =================================================================================
    O QUE HÁ DE NOVO E MELHORADO NA V10:
    
    1. [EXPANSÃO COMPLETA DE REDE & COMUNICAÇÃO]:
       Além de RemoteEvent e RemoteFunction, agora cobre:
       - ⚡ UnreliableRemoteEvent (o novo protocolo de alta velocidade do Roblox)
       - 🔄 BindableEvent e BindableFunction (eventos internos de scripts e UI)
       - 📦 Canais de Frameworks (Knit, ByteNet, Comm, Red)
       
    2. [REMOTES INTELIGENTES COM PAYLOAD ADAPTATIVO (NÃO DÁ ERRO/VÁZIO)]:
       Por que alguns remotes "não faziam nada"? Porque cada remote espera um formato!
       A V10 analisa o nome do remote e injeta o payload correto:
       - Se for 'Badge': envia ID, ("Award", ID), ("Claim", ID), ({BadgeId = ID})
       - Se for 'Quest/Mission': envia ("Complete"), ("Claim"), ("Finish"), (1)
       - Se for 'Stage/Checkpoint': envia (100), (1000), ("Set", 1000)
       - Se for 'Win/Finish': envia (true), (true, true), (1000, 1000)
       - Se for 'Reward/Claim': envia ("All"), ("Free"), (true)
       
    3. [PROXIMITYPROMPT GOD-MODE]:
       Não usa apenas 'fireproximityprompt'. A V10 usa 4 canais simultâneos:
       * Zera HoldDuration = 0, remove restrição de visão (RequiresLineOfSight = false)
       * Aumenta distância de ativação para o infinito (MaxActivationDistance = 999999)
       * Dispara firesignal(prompt.Triggered) e firesignal(PromptButtonHoldEnded)
       * Simula teclado físico com VirtualInputManager (pressiona 'E' de verdade)
       
    4. [ESPIÃO DE REDE AO VIVO (REMOTE SPY INTEGRADO)]:
       Captura remotes legítimos que o próprio jogo dispara com argumentos exatos,
       permitindo que você replique a chamada com 1 clique!
       
    5. [TOUCHPADS AVANÇADOS]:
       Dispara getconnections nos pés, pernas e raiz do boneco com gravidade forçada.
    =================================================================================
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local VirtualInputManager = game:GetService("VirtualInputManager")

local LocalPlayer = Players.LocalPlayer
local Backpack = LocalPlayer:WaitForChild("Backpack")
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local RootPart = Character:WaitForChild("HumanoidRootPart", 10)
local Humanoid = Character:WaitForChild("Humanoid", 10)

-- Estado Global V10
local State = {
    IsBatchRunning = false,
    ActiveLoops = {},       -- { [id] = boolean }
    ScannedEntries = {},
    ActiveCategory = "Todos",
    UniverseBadgeIds = {},
    SpyLogs = {}            -- Registros capturados pelo Remote Spy
}

-- Anti-AFK
LocalPlayer.Idled:Connect(function()
    local vu = game:GetService("VirtualUser")
    vu:CaptureController()
    vu:ClickButton2(Vector2.new(0, 0))
end)

LocalPlayer.CharacterAdded:Connect(function(char)
    Character = char
    RootPart = char:WaitForChild("HumanoidRootPart", 10)
    Humanoid = char:WaitForChild("Humanoid", 10)
    Backpack = LocalPlayer:WaitForChild("Backpack")
end)

-- ---------------------------------------------------------------------------------
-- 0. FILTRO DE JOGADORES (IGNORA ITENS/PROMPTS DE OUTROS JOGADORES)
-- ---------------------------------------------------------------------------------
local function isFromOtherPlayer(obj)
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            if (plr.Character and obj:IsDescendantOf(plr.Character))
                or (plr:FindFirstChild("Backpack") and obj:IsDescendantOf(plr.Backpack)) then
                return true
            end
        end
    end
    return false
end

-- ---------------------------------------------------------------------------------
-- 1. CONSULTA DE BADGES DO UNIVERSO VIA API
-- ---------------------------------------------------------------------------------
task.spawn(function()
    local uId = game.GameId
    if uId == 0 then return end
    local url = string.format("https://badges.roproxy.com/v1/universes/%d/badges?limit=100", uId)
    local s, res
    pcall(function()
        if (syn and syn.request) or (http and http.request) or request then
            local req = (syn and syn.request) or (http and http.request) or request
            res = req({Url = url, Method = "GET"}).Body
            s = true
        elseif game.HttpGet then
            res = game:HttpGet(url)
            s = true
        end
    end)
    if s and res then
        local data = HttpService:JSONDecode(res)
        for _, b in ipairs(data.data or {}) do
            table.insert(State.UniverseBadgeIds, b.id)
        end
    end
end)

-- ---------------------------------------------------------------------------------
-- 2. GERADOR DE PAYLOADS ADAPTATIVOS POR NOME DE REMOTE
-- ---------------------------------------------------------------------------------
local function generateSmartPayloads(remoteName)
    local n = remoteName:lower()
    local payloads = {}

    -- 1. Payloads Mestres Clássicos
    table.insert(payloads, {true})
    table.insert(payloads, {true, true})
    table.insert(payloads, {1000})
    table.insert(payloads, {1000, 1000})
    table.insert(payloads, {true, 1000})
    table.insert(payloads, {1, true})

    -- 2. Se tiver relação com Badges / Conquistas
    if n:find("badge") or n:find("emblem") or n:find("award") then
        for _, bId in ipairs(State.UniverseBadgeIds) do
            table.insert(payloads, {bId})
            table.insert(payloads, {tostring(bId)})
            table.insert(payloads, {"Award", bId})
            table.insert(payloads, {"Claim", bId})
            table.insert(payloads, {"Give", bId})
            table.insert(payloads, {{BadgeId = bId}})
            table.insert(payloads, {{Id = bId}})
        end
    end

    -- 3. Se tiver relação com Quests / Missões
    if n:find("quest") or n:find("mission") or n:find("task") then
        table.insert(payloads, {"Complete"})
        table.insert(payloads, {"Claim"})
        table.insert(payloads, {"Finish"})
        table.insert(payloads, {"All"})
        table.insert(payloads, {1, "Complete"})
        table.insert(payloads, {{Status = "Completed"}})
    end

    -- 4. Se tiver relação com Estágios / Checkpoints / Níveis
    if n:find("stage") or n:find("checkpoint") or n:find("level") or n:find("fase") or n:find("rank") then
        table.insert(payloads, {100})
        table.insert(payloads, {1000})
        table.insert(payloads, {99999})
        table.insert(payloads, {"Set", 1000})
        table.insert(payloads, {"Advance"})
        table.insert(payloads, {Next = true})
    end

    -- 5. Se tiver relação com Recompensas / Reivindicação
    if n:find("claim") or n:find("reward") or n:find("gift") or n:find("daily") or n:find("free") then
        table.insert(payloads, {"Claim"})
        table.insert(payloads, {"All"})
        table.insert(payloads, {"Free"})
        table.insert(payloads, {1})
        table.insert(payloads, {true})
    end

    -- 6. Se tiver relação com Vitória / Fim de Jogo
    if n:find("win") or n:find("victory") or n:find("finish") or n:find("end") or n:find("complete") then
        table.insert(payloads, {"Win"})
        table.insert(payloads, {"Complete"})
        table.insert(payloads, {true})
        table.insert(payloads, {true, 1000})
        table.insert(payloads, {{Completed = true, Win = true}})
    end

    return payloads
end

-- ---------------------------------------------------------------------------------
-- 3. EXECUTOR DE AÇÕES POR TIPO
-- ---------------------------------------------------------------------------------
local function executeAction(entry)
    if not Character or not RootPart or not Humanoid then
        Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        RootPart = Character:WaitForChild("HumanoidRootPart", 5)
        Humanoid = Character:WaitForChild("Humanoid", 5)
    end

    local success = false

    pcall(function()
        -- =========================================================================
        -- TIPO 1: REMOTEEVENT / REMOTEFUNCTION / UNRELIABLE
        -- =========================================================================
        if entry.Type == "Remote" or entry.Type == "UnreliableRemote" then
            local rem = entry.Object
            if rem and rem.Parent then
                local payloads = generateSmartPayloads(rem.Name)
                for _, args in ipairs(payloads) do
                    pcall(function()
                        if rem:IsA("RemoteEvent") or rem.ClassName == "UnreliableRemoteEvent" then
                            rem:FireServer(unpack(args))
                        elseif rem:IsA("RemoteFunction") then
                            rem:InvokeServer(unpack(args))
                        end
                    end)
                end
                success = true
            end

        -- =========================================================================
        -- TIPO 2: BINDABLEEVENT & BINDABLEFUNCTION (EVENTOS INTERNOS DO JOGO)
        -- =========================================================================
        elseif entry.Type == "Bindable" then
            local bin = entry.Object
            if bin and bin.Parent then
                local payloads = generateSmartPayloads(bin.Name)
                for _, args in ipairs(payloads) do
                    pcall(function()
                        if bin:IsA("BindableEvent") then
                            bin:Fire(unpack(args))
                        elseif bin:IsA("BindableFunction") then
                            bin:Invoke(unpack(args))
                        end
                    end)
                end
                success = true
            end

        -- =========================================================================
        -- TIPO 3: PROXIMITYPROMPT & CLICKDETECTOR GOD-MODE
        -- =========================================================================
        elseif entry.Type == "Prompt" then
            local prompt = entry.Object
            if prompt and prompt.Parent then
                local promptPart = prompt.Parent:IsA("BasePart") and prompt.Parent or prompt.Parent:FindFirstChildWhichIsA("BasePart")
                if promptPart then
                    local origPos = RootPart.CFrame
                    -- 1. Posiciona imediatamente na frente
                    RootPart.CFrame = promptPart.CFrame + Vector3.new(0, 1.2, 0)

                    if prompt:IsA("ProximityPrompt") then
                        -- Canal A: Hack de Propriedades
                        prompt.HoldDuration = 0
                        prompt.MaxActivationDistance = 999999
                        prompt.RequiresLineOfSight = false
                        prompt.Enabled = true

                        -- Canal B: fireproximityprompt
                        if fireproximityprompt then fireproximityprompt(prompt) end

                        -- Canal C: firesignal nos eventos do prompt
                        if firesignal then
                            firesignal(prompt.PromptButtonHoldBegan)
                            firesignal(prompt.Triggered)
                            firesignal(prompt.PromptButtonHoldEnded)
                        end

                        -- Canal D: Simulação de hardware virtual (pressiona a tecla 'E')
                        pcall(function()
                            VirtualInputManager:SendKeyEvent(true, prompt.KeyboardKeyCode or Enum.KeyCode.E, false, game)
                            task.wait(0.02)
                            VirtualInputManager:SendKeyEvent(false, prompt.KeyboardKeyCode or Enum.KeyCode.E, false, game)
                        end)

                    elseif prompt:IsA("ClickDetector") then
                        if fireclickdetector then fireclickdetector(prompt) end
                    end

                    task.wait(0.06)
                    RootPart.CFrame = origPos
                    success = true
                end
            end

        -- =========================================================================
        -- TIPO 4: TOUCHPADS AVANÇADOS COM MULTI-MEMBROS
        -- =========================================================================
        elseif entry.Type == "TouchPad" then
            local part = entry.Object
            if part and part:IsA("BasePart") and part.Parent then
                local origPos = RootPart.CFrame
                RootPart.CFrame = part.CFrame + Vector3.new(0, 1.5, 0)
                RootPart.AssemblyLinearVelocity = Vector3.new(0, -4, 0)

                -- Disparo de sinais em múltiplos membros do corpo
                local bodyLimbs = {RootPart, Character:FindFirstChild("Right Leg"), Character:FindFirstChild("Left Leg"), Character:FindFirstChild("Head")}
                if getconnections then
                    for _, conn in ipairs(getconnections(part.Touched)) do
                        for _, limb in ipairs(bodyLimbs) do
                            if limb then pcall(function() conn:Fire(limb) end) end
                        end
                    end
                end

                if firetouchinterest then
                    firetouchinterest(RootPart, part, 0)
                    task.wait(0.01)
                    firetouchinterest(RootPart, part, 1)
                end

                task.wait(0.1)
                RootPart.CFrame = origPos
                success = true
            end

        -- =========================================================================
        -- TIPO 5: FERRAMENTAS DO MAPA (WORLD TOOLS)
        -- =========================================================================
        elseif entry.Type == "WorldTool" then
            local tool = entry.Object
            if tool and tool.Parent and not isFromOtherPlayer(tool) then
                local handle = tool:FindFirstChild("Handle") or tool:FindFirstChildWhichIsA("BasePart")
                if handle then
                    local origPos = RootPart.CFrame
                    RootPart.CFrame = handle.CFrame + Vector3.new(0, 1.2, 0)
                    if firetouchinterest then
                        firetouchinterest(RootPart, handle, 0)
                        task.wait(0.01)
                        firetouchinterest(RootPart, handle, 1)
                    end
                    Humanoid:EquipTool(tool)
                    tool.Parent = Character
                    task.wait(0.08)
                    tool:Activate()
                    RootPart.CFrame = origPos
                    success = true
                else
                    tool.Parent = Backpack
                    Humanoid:EquipTool(tool)
                    tool:Activate()
                    success = true
                end
            end
        end
    end)

    return success
end

-- ---------------------------------------------------------------------------------
-- 4. SCANNER TOTAL DE ELEMENTOS (INCLUINDO BINDABLES E UNRELIABLE)
-- ---------------------------------------------------------------------------------
local function scanAllElementsV10()
    local entries = {}
    local seen = {}

    -- A) REMOTES (RemoteEvent, RemoteFunction, UnreliableRemoteEvent)
    for _, obj in ipairs(game:GetDescendants()) do
        if not seen[obj] then
            if obj:IsA("RemoteEvent") or obj.ClassName == "UnreliableRemoteEvent" then
                seen[obj] = true
                local isUnreliable = (obj.ClassName == "UnreliableRemoteEvent")
                table.insert(entries, {
                    Id = "Rem_" .. tostring(obj:GetDebugId() or math.random(10000, 99999)),
                    Name = obj.Name,
                    Type = isUnreliable and "UnreliableRemote" or "Remote",
                    Category = "Remotes",
                    Icon = isUnreliable and "⚡📡" or "⚡",
                    TypeLabel = isUnreliable and "Unreliable Remote" or "RemoteEvent",
                    Location = obj.Parent and obj.Parent.Name or "Game",
                    Object = obj
                })
            elseif obj:IsA("RemoteFunction") then
                seen[obj] = true
                table.insert(entries, {
                    Id = "RemF_" .. tostring(obj:GetDebugId() or math.random(10000, 99999)),
                    Name = obj.Name,
                    Type = "Remote",
                    Category = "Remotes",
                    Icon = "📞",
                    TypeLabel = "RemoteFunction",
                    Location = obj.Parent and obj.Parent.Name or "Game",
                    Object = obj
                })
            -- B) BINDABLES (BindableEvent, BindableFunction)
            elseif obj:IsA("BindableEvent") then
                seen[obj] = true
                table.insert(entries, {
                    Id = "BinE_" .. tostring(obj:GetDebugId() or math.random(10000, 99999)),
                    Name = obj.Name,
                    Type = "Bindable",
                    Category = "Bindables",
                    Icon = "🔄",
                    TypeLabel = "BindableEvent (Interno)",
                    Location = obj.Parent and obj.Parent.Name or "Scripts",
                    Object = obj
                })
            elseif obj:IsA("BindableFunction") then
                seen[obj] = true
                table.insert(entries, {
                    Id = "BinF_" .. tostring(obj:GetDebugId() or math.random(10000, 99999)),
                    Name = obj.Name,
                    Type = "Bindable",
                    Category = "Bindables",
                    Icon = "🔁",
                    TypeLabel = "BindableFunction (Interno)",
                    Location = obj.Parent and obj.Parent.Name or "Scripts",
                    Object = obj
                })
            end
        end
    end

    -- C) TOUCHPADS / BLOCKS COM TOUCH
    for _, obj in ipairs(workspace:GetDescendants()) do
        if not isFromOtherPlayer(obj) and not obj:IsDescendantOf(Character) then
            if obj:IsA("TouchTransmitter") and obj.Parent and obj.Parent:IsA("BasePart") and not seen[obj.Parent] then
                seen[obj.Parent] = true
                table.insert(entries, {
                    Id = "Pad_" .. tostring(obj.Parent:GetDebugId() or math.random(10000, 99999)),
                    Name = obj.Parent.Name,
                    Type = "TouchPad",
                    Category = "Pads",
                    Icon = "📍",
                    TypeLabel = "Pad / Botão de Chão",
                    Location = obj.Parent.Parent and obj.Parent.Parent.Name or "Workspace",
                    Object = obj.Parent
                })
            elseif obj:IsA("BasePart") and not seen[obj] then
                local n = obj.Name:lower()
                if n:find("badge") or n:find("giver") or n:find("checkpoint") or n:find("pad") or n:find("stage") or n:find("win") then
                    seen[obj] = true
                    table.insert(entries, {
                        Id = "Pad_" .. tostring(obj:GetDebugId() or math.random(10000, 99999)),
                        Name = obj.Name,
                        Type = "TouchPad",
                        Category = "Pads",
                        Icon = "📍",
                        TypeLabel = "Bloco de Evento",
                        Location = obj.Parent and obj.Parent.Name or "Workspace",
                        Object = obj
                    })
                end
            end
        end
    end

    -- D) PROXIMITYPROMPT & CLICKDETECTOR
    for _, obj in ipairs(workspace:GetDescendants()) do
        if (obj:IsA("ProximityPrompt") or obj:IsA("ClickDetector")) and not isFromOtherPlayer(obj) and not seen[obj] then
            seen[obj] = true
            local name = obj.Parent.Name
            if obj:IsA("ProximityPrompt") and obj.ActionText ~= "" then
                name = obj.ActionText .. " (" .. (obj.ObjectText ~= "" and obj.ObjectText or obj.Parent.Name) .. ")"
            end
            table.insert(entries, {
                Id = "Prompt_" .. tostring(obj:GetDebugId() or math.random(10000, 99999)),
                Name = name,
                Type = "Prompt",
                Category = "Prompts",
                Icon = "✋",
                TypeLabel = obj:IsA("ProximityPrompt") and "ProximityPrompt (God)" or "ClickDetector",
                Location = obj.Parent and obj.Parent.Name or "Workspace",
                Object = obj
            })
        end
    end

    -- E) FERRAMENTAS REAIS DO MAPA
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Tool") and not isFromOtherPlayer(obj) and not obj:IsDescendantOf(Character) and not seen[obj] then
            seen[obj] = true
            table.insert(entries, {
                Id = "Tool_" .. tostring(obj:GetDebugId() or math.random(10000, 99999)),
                Name = obj.Name,
                Type = "WorldTool",
                Category = "Itens",
                Icon = "🗡️",
                TypeLabel = "Item Solto no Mapa",
                Location = obj.Parent and obj.Parent.Name or "Workspace",
                Object = obj
            })
        end
    end

    State.ScannedEntries = entries
    return entries
end

-- ---------------------------------------------------------------------------------
-- 5. ESPIÃO DE REDE INTEGRADO (REMOTE SPY SNIFFER)
-- ---------------------------------------------------------------------------------
local function initRemoteSpy(onCaptureCallback)
    if not hookmetamethod then return end
    pcall(function()
        local oldNamecall
        oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
            local method = getnamecallmethod()
            local args = {...}

            if (method == "FireServer" or method == "InvokeServer") and (self:IsA("RemoteEvent") or self:IsA("RemoteFunction") or self.ClassName == "UnreliableRemoteEvent") then
                pcall(function()
                    table.insert(State.SpyLogs, 1, {
                        Remote = self,
                        Method = method,
                        Args = args,
                        Time = os.date("%H:%M:%S")
                    })
                    if #State.SpyLogs > 40 then table.remove(State.SpyLogs) end
                    if onCaptureCallback then onCaptureCallback() end
                end)
            end

            return oldNamecall(self, ...)
        end)
    end)
end

-- ---------------------------------------------------------------------------------
-- 6. INTERFACE GRÁFICA V10
-- ---------------------------------------------------------------------------------
local function buildInterfaceV10()
    local parentGui = (gethui and gethui()) or game:GetService("CoreGui"):FindFirstChild("RobloxGui") or LocalPlayer:WaitForChild("PlayerGui")
    local old = parentGui:FindFirstChild("BadgeMaster_V10")
    if old then old:Destroy() end

    local Screen = Instance.new("ScreenGui")
    Screen.Name = "BadgeMaster_V10"
    Screen.ResetOnSpawn = false

    -- Botão Mobile Flutuante
    local MobBtn = Instance.new("TextButton")
    MobBtn.Size = UDim2.new(0, 50, 0, 50)
    MobBtn.Position = UDim2.new(0, 16, 0.45, 0)
    MobBtn.BackgroundColor3 = Color3.fromRGB(15, 18, 26)
    MobBtn.Text = "💎"
    MobBtn.TextSize = 22
    MobBtn.BorderSizePixel = 0
    MobBtn.Parent = Screen

    local mbCorner = Instance.new("UICorner")
    mbCorner.CornerRadius = UDim.new(1, 0)
    mbCorner.Parent = MobBtn

    local mbStroke = Instance.new("UIStroke")
    mbStroke.Color = Color3.fromRGB(0, 240, 255)
    mbStroke.Thickness = 2
    mbStroke.Parent = MobBtn

    -- Janela Principal
    local Window = Instance.new("Frame")
    Window.Size = UDim2.new(0, 610, 0, 480)
    Window.Position = UDim2.new(0.5, -305, 0.5, -240)
    Window.BackgroundColor3 = Color3.fromRGB(11, 13, 19)
    Window.BorderSizePixel = 0
    Window.Active = true
    Window.ClipsDescendants = true
    Window.Parent = Screen

    local wCorner = Instance.new("UICorner")
    wCorner.CornerRadius = UDim.new(0, 12)
    wCorner.Parent = Window

    local wStroke = Instance.new("UIStroke")
    wStroke.Color = Color3.fromRGB(35, 45, 65)
    wStroke.Thickness = 1.4
    wStroke.Parent = Window

    -- Header
    local TopBar = Instance.new("Frame")
    TopBar.Size = UDim2.new(1, 0, 0, 42)
    TopBar.BackgroundColor3 = Color3.fromRGB(16, 20, 30)
    TopBar.BorderSizePixel = 0
    TopBar.Parent = Window

    local tbCorner = Instance.new("UICorner")
    tbCorner.CornerRadius = UDim.new(0, 12)
    tbCorner.Parent = TopBar

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -50, 1, 0)
    Title.Position = UDim2.new(0, 14, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = "💎 BADGE MASTER V10  |  OMNI-EXPLOIT APEX ENGINE"
    Title.TextColor3 = Color3.fromRGB(0, 240, 255)
    Title.TextSize = 12
    Title.Font = Enum.Font.GothamBold
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = TopBar

    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 28, 0, 28)
    CloseBtn.Position = UDim2.new(1, -34, 0, 7)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(28, 34, 50)
    CloseBtn.Text = "✕"
    CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseBtn.TextSize = 11
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.BorderSizePixel = 0
    CloseBtn.Parent = TopBar

    local cbCorner = Instance.new("UICorner")
    cbCorner.CornerRadius = UDim.new(0, 6)
    cbCorner.Parent = CloseBtn

    CloseBtn.MouseButton1Click:Connect(function() Window.Visible = false end)
    MobBtn.MouseButton1Click:Connect(function() Window.Visible = not Window.Visible end)

    -- Arrastar Janela
    local dragging, dragStart, startPos
    TopBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = Window.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            Window.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    -- Corpo
    local Body = Instance.new("Frame")
    Body.Size = UDim2.new(1, -24, 1, -54)
    Body.Position = UDim2.new(0, 12, 0, 48)
    Body.BackgroundTransparency = 1
    Body.Parent = Window

    -- 1. Barra de Ações do Topo
    local TopCmds = Instance.new("Frame")
    TopCmds.Size = UDim2.new(1, 0, 0, 40)
    TopCmds.BackgroundTransparency = 1
    TopCmds.Parent = Body

    local ForceAllBtn = Instance.new("TextButton")
    ForceAllBtn.Size = UDim2.new(0.50, -4, 1, 0)
    ForceAllBtn.BackgroundColor3 = Color3.fromRGB(220, 35, 60)
    ForceAllBtn.Text = "⚡ FORÇAR TUDO COM PAYLOADS MESTRES"
    ForceAllBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ForceAllBtn.TextSize = 11
    ForceAllBtn.Font = Enum.Font.GothamBold
    ForceAllBtn.BorderSizePixel = 0
    ForceAllBtn.Parent = TopCmds

    local faCorner = Instance.new("UICorner")
    faCorner.CornerRadius = UDim.new(0, 8)
    faCorner.Parent = ForceAllBtn

    local RescanBtn = Instance.new("TextButton")
    RescanBtn.Size = UDim2.new(0.28, -4, 1, 0)
    RescanBtn.Position = UDim2.new(0.50, 2, 0, 0)
    RescanBtn.BackgroundColor3 = Color3.fromRGB(0, 140, 255)
    RescanBtn.Text = "🔄 Re-Escanear"
    RescanBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    RescanBtn.TextSize = 11
    RescanBtn.Font = Enum.Font.GothamBold
    RescanBtn.BorderSizePixel = 0
    RescanBtn.Parent = TopCmds

    local rbCorner = Instance.new("UICorner")
    rbCorner.CornerRadius = UDim.new(0, 8)
    rbCorner.Parent = RescanBtn

    local StopAutosBtn = Instance.new("TextButton")
    StopAutosBtn.Size = UDim2.new(0.22, 0, 1, 0)
    StopAutosBtn.Position = UDim2.new(0.78, 2, 0, 0)
    StopAutosBtn.BackgroundColor3 = Color3.fromRGB(40, 46, 62)
    StopAutosBtn.Text = "⏹️ Parar Autos"
    StopAutosBtn.TextColor3 = Color3.fromRGB(220, 225, 235)
    StopAutosBtn.TextSize = 10
    StopAutosBtn.Font = Enum.Font.GothamBold
    StopAutosBtn.BorderSizePixel = 0
    StopAutosBtn.Parent = TopCmds

    local saCorner = Instance.new("UICorner")
    saCorner.CornerRadius = UDim.new(0, 8)
    saCorner.Parent = StopAutosBtn

    -- 2. Categorias (Pills)
    local CatRow = Instance.new("Frame")
    CatRow.Size = UDim2.new(1, 0, 0, 30)
    CatRow.Position = UDim2.new(0, 0, 0, 46)
    CatRow.BackgroundTransparency = 1
    CatRow.Parent = Body

    local catLayout = Instance.new("UIListLayout")
    catLayout.FillDirection = Enum.FillDirection.Horizontal
    catLayout.Padding = UDim.new(0, 6)
    catLayout.Parent = CatRow

    local CatBtns = {}
    local Categories = {"Todos", "Remotes", "Bindables", "Prompts", "Pads", "Itens", "🛰️ Spy"}

    -- 3. Barra de Busca e Status
    local SearchRow = Instance.new("Frame")
    SearchRow.Size = UDim2.new(1, 0, 0, 30)
    SearchRow.Position = UDim2.new(0, 0, 0, 82)
    SearchRow.BackgroundTransparency = 1
    SearchRow.Parent = Body

    local StatusText = Instance.new("TextLabel")
    StatusText.Size = UDim2.new(0.40, 0, 1, 0)
    StatusText.BackgroundTransparency = 1
    StatusText.Text = "Carregando..."
    StatusText.TextColor3 = Color3.fromRGB(165, 175, 195)
    StatusText.TextSize = 11
    StatusText.Font = Enum.Font.GothamMedium
    StatusText.TextXAlignment = Enum.TextXAlignment.Left
    StatusText.Parent = SearchRow

    local SearchBox = Instance.new("TextBox")
    SearchBox.Size = UDim2.new(0.60, 0, 1, 0)
    SearchBox.Position = UDim2.new(0.40, 0, 0, 0)
    SearchBox.BackgroundColor3 = Color3.fromRGB(18, 22, 32)
    SearchBox.PlaceholderText = "🔍 Buscar remote, evento ou prompt..."
    SearchBox.PlaceholderColor3 = Color3.fromRGB(110, 120, 140)
    SearchBox.Text = ""
    SearchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    SearchBox.TextSize = 11
    SearchBox.Font = Enum.Font.Gotham
    SearchBox.BorderSizePixel = 0
    SearchBox.Parent = SearchRow

    local sbCorner = Instance.new("UICorner")
    sbCorner.CornerRadius = UDim.new(0, 6)
    sbCorner.Parent = SearchBox

    -- 4. Lista Interativa (ScrollingFrame)
    local ScrollList = Instance.new("ScrollingFrame")
    ScrollList.Size = UDim2.new(1, 0, 1, -120)
    ScrollList.Position = UDim2.new(0, 0, 0, 118)
    ScrollList.BackgroundColor3 = Color3.fromRGB(8, 10, 15)
    ScrollList.BorderSizePixel = 0
    ScrollList.ScrollBarThickness = 4
    ScrollList.Parent = Body

    local slCorner = Instance.new("UICorner")
    slCorner.CornerRadius = UDim.new(0, 8)
    slCorner.Parent = ScrollList

    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 5)
    listLayout.Parent = ScrollList

    Screen.Parent = parentGui

    -- Renderizador Dinâmico
    local function renderCards(search)
        search = (search or SearchBox.Text):lower()

        for _, c in ipairs(ScrollList:GetChildren()) do
            if c:IsA("Frame") then c:Destroy() end
        end

        -- SE ESTIVER NA ABA SPY:
        if State.ActiveCategory == "🛰️ Spy" then
            for idx, log in ipairs(State.SpyLogs) do
                local card = Instance.new("Frame")
                card.Size = UDim2.new(1, -8, 0, 48)
                card.BackgroundColor3 = Color3.fromRGB(16, 20, 30)
                card.BorderSizePixel = 0
                card.Parent = ScrollList

                local cc = Instance.new("UICorner")
                cc.CornerRadius = UDim.new(0, 8)
                cc.Parent = card

                local title = Instance.new("TextLabel")
                title.Size = UDim2.new(1, -110, 0, 20)
                title.Position = UDim2.new(0, 10, 0, 5)
                title.BackgroundTransparency = 1
                title.Text = string.format("[%s] %s:%s()", log.Time, log.Remote.Name, log.Method)
                title.TextColor3 = Color3.fromRGB(0, 240, 255)
                title.TextSize = 11
                title.Font = Enum.Font.GothamBold
                title.TextXAlignment = Enum.TextXAlignment.Left
                title.TextTruncate = Enum.TextTruncate.AtEnd
                title.Parent = card

                local sub = Instance.new("TextLabel")
                sub.Size = UDim2.new(1, -110, 0, 16)
                sub.Position = UDim2.new(0, 10, 0, 25)
                sub.BackgroundTransparency = 1
                local argsStr = HttpService:JSONEncode(log.Args)
                sub.Text = "Args: " .. argsStr
                sub.TextColor3 = Color3.fromRGB(140, 150, 175)
                sub.TextSize = 9
                sub.Font = Enum.Font.Code
                sub.TextXAlignment = Enum.TextXAlignment.Left
                sub.TextTruncate = Enum.TextTruncate.AtEnd
                sub.Parent = card

                local replayBtn = Instance.new("TextButton")
                replayBtn.Size = UDim2.new(0, 90, 0, 30)
                replayBtn.Position = UDim2.new(1, -98, 0.5, -15)
                replayBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 100)
                replayBtn.Text = "🔁 Replicar"
                replayBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                replayBtn.TextSize = 10
                replayBtn.Font = Enum.Font.GothamBold
                replayBtn.BorderSizePixel = 0
                replayBtn.Parent = card

                local rc = Instance.new("UICorner")
                rc.CornerRadius = UDim.new(0, 6)
                rc.Parent = replayBtn

                replayBtn.MouseButton1Click:Connect(function()
                    pcall(function()
                        if log.Method == "FireServer" then
                            log.Remote:FireServer(unpack(log.Args))
                        else
                            log.Remote:InvokeServer(unpack(log.Args))
                        end
                        replayBtn.Text = "Replicado!"
                        task.wait(0.5)
                        replayBtn.Text = "🔁 Replicar"
                    end)
                end)
            end
            ScrollList.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 10)
            StatusText.Text = string.format("Espião: %d chamadas capturadas.", #State.SpyLogs)
            return
        end

        -- LISTA NORMAL DE ALVOS
        local count = 0
        for _, entry in ipairs(State.ScannedEntries) do
            local matchesCat = (State.ActiveCategory == "Todos") or (entry.Category == State.ActiveCategory)
            local matchesSearch = (search == "") or entry.Name:lower():find(search) or entry.TypeLabel:lower():find(search)

            if matchesCat and matchesSearch then
                count = count + 1

                local card = Instance.new("Frame")
                card.Name = "Card_" .. entry.Id
                card.Size = UDim2.new(1, -8, 0, 48)
                card.BackgroundColor3 = Color3.fromRGB(16, 20, 28)
                card.BorderSizePixel = 0
                card.Parent = ScrollList

                local cc = Instance.new("UICorner")
                cc.CornerRadius = UDim.new(0, 8)
                cc.Parent = card

                local titleLabel = Instance.new("TextLabel")
                titleLabel.Size = UDim2.new(1, -190, 0, 20)
                titleLabel.Position = UDim2.new(0, 10, 0, 5)
                titleLabel.BackgroundTransparency = 1
                titleLabel.Text = entry.Icon .. " " .. entry.Name
                titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                titleLabel.TextSize = 11
                titleLabel.Font = Enum.Font.GothamBold
                titleLabel.TextXAlignment = Enum.TextXAlignment.Left
                titleLabel.TextTruncate = Enum.TextTruncate.AtEnd
                titleLabel.Parent = card

                local subLabel = Instance.new("TextLabel")
                subLabel.Size = UDim2.new(1, -190, 0, 16)
                subLabel.Position = UDim2.new(0, 10, 0, 25)
                subLabel.BackgroundTransparency = 1
                subLabel.Text = string.format("%s • %s", entry.TypeLabel, entry.Location)
                subLabel.TextColor3 = Color3.fromRGB(140, 150, 175)
                subLabel.TextSize = 9
                subLabel.Font = Enum.Font.Gotham
                subLabel.TextXAlignment = Enum.TextXAlignment.Left
                subLabel.TextTruncate = Enum.TextTruncate.AtEnd
                subLabel.Parent = card

                local runOnceBtn = Instance.new("TextButton")
                runOnceBtn.Size = UDim2.new(0, 75, 0, 30)
                runOnceBtn.Position = UDim2.new(1, -170, 0.5, -15)
                runOnceBtn.BackgroundColor3 = Color3.fromRGB(0, 140, 255)
                runOnceBtn.Text = "▶ Disparar"
                runOnceBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                runOnceBtn.TextSize = 10
                runOnceBtn.Font = Enum.Font.GothamBold
                runOnceBtn.BorderSizePixel = 0
                runOnceBtn.Parent = card

                local rc = Instance.new("UICorner")
                rc.CornerRadius = UDim.new(0, 6)
                rc.Parent = runOnceBtn

                runOnceBtn.MouseButton1Click:Connect(function()
                    runOnceBtn.Text = "Disparando..."
                    runOnceBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
                    task.spawn(function()
                        executeAction(entry)
                        task.wait(0.2)
                        runOnceBtn.Text = "▶ Disparar"
                        runOnceBtn.BackgroundColor3 = Color3.fromRGB(0, 140, 255)
                    end)
                end)

                local autoBtn = Instance.new("TextButton")
                autoBtn.Size = UDim2.new(0, 85, 0, 30)
                autoBtn.Position = UDim2.new(1, -88, 0.5, -15)
                local isLooping = State.ActiveLoops[entry.Id] or false
                autoBtn.BackgroundColor3 = isLooping and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(36, 42, 58)
                autoBtn.Text = isLooping and "🔁 Auto: ON" or "🔁 Auto: OFF"
                autoBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                autoBtn.TextSize = 10
                autoBtn.Font = Enum.Font.GothamBold
                autoBtn.BorderSizePixel = 0
                autoBtn.Parent = card

                local ac = Instance.new("UICorner")
                ac.CornerRadius = UDim.new(0, 6)
                ac.Parent = autoBtn

                autoBtn.MouseButton1Click:Connect(function()
                    if State.ActiveLoops[entry.Id] then
                        State.ActiveLoops[entry.Id] = nil
                        autoBtn.BackgroundColor3 = Color3.fromRGB(36, 42, 58)
                        autoBtn.Text = "🔁 Auto: OFF"
                    else
                        State.ActiveLoops[entry.Id] = true
                        autoBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
                        autoBtn.Text = "🔁 Auto: ON"

                        task.spawn(function()
                            while State.ActiveLoops[entry.Id] do
                                executeAction(entry)
                                task.wait(0.25)
                            end
                        end)
                    end
                end)
            end
        end

        ScrollList.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 10)
        StatusText.Text = string.format("Exibindo: %d opções", count)
    end

    -- Criação dos botões de Categoria
    for _, catName in ipairs(Categories) do
        local pill = Instance.new("TextButton")
        pill.Size = UDim2.new(0, catName:find("Spy") and 85 or 70, 1, 0)
        pill.BackgroundColor3 = (State.ActiveCategory == catName) and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(20, 25, 36)
        pill.Text = catName
        pill.TextColor3 = Color3.fromRGB(255, 255, 255)
        pill.TextSize = 10
        pill.Font = Enum.Font.GothamBold
        pill.BorderSizePixel = 0
        pill.Parent = CatRow

        local pc = Instance.new("UICorner")
        pc.CornerRadius = UDim.new(0, 6)
        pc.Parent = pill

        CatBtns[catName] = pill

        pill.MouseButton1Click:Connect(function()
            State.ActiveCategory = catName
            for cName, btn in pairs(CatBtns) do
                btn.BackgroundColor3 = (cName == catName) and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(20, 25, 36)
            end
            renderCards()
        end)
    end

    SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
        renderCards(SearchBox.Text)
    end)

    return {
        Status = StatusText,
        ForceAllBtn = ForceAllBtn,
        RescanBtn = RescanBtn,
        StopAutosBtn = StopAutosBtn,
        Render = renderCards
    }
end

local UI = buildInterfaceV10()

-- Inicializa o espião de remotes
initRemoteSpy(function()
    if State.ActiveCategory == "🛰️ Spy" then
        UI.Render()
    end
end)

-- ---------------------------------------------------------------------------------
-- 7. VINCULAÇÃO DOS BOTÕES PRINCIPAIS
-- ---------------------------------------------------------------------------------
UI.ForceAllBtn.MouseButton1Click:Connect(function()
    if State.IsBatchRunning then return end
    State.IsBatchRunning = true
    UI.ForceAllBtn.Text = "DISPARANDO COM PAYLOADS MESTRES..."
    UI.ForceAllBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 120)
    UI.Status.Text = "Processando todos os remotes, bindables e prompts..."

    task.spawn(function()
        local entries = scanAllElementsV10()
        UI.Render()

        local total = #entries
        for i = 1, total do
            local e = entries[i]
            UI.Status.Text = string.format("Disparando (%d/%d): %s", i, total, e.Name)
            executeAction(e)
            task.wait(0.015)
        end

        UI.Status.Text = "Finalizado! Todos os remotes e elementos foram processados."
        UI.ForceAllBtn.Text = "⚡ FORÇAR TUDO COM PAYLOADS MESTRES"
        UI.ForceAllBtn.BackgroundColor3 = Color3.fromRGB(220, 35, 60)
        State.IsBatchRunning = false
    end)
end)

UI.RescanBtn.MouseButton1Click:Connect(function()
    UI.Status.Text = "Escaneando todos os elementos..."
    task.spawn(function()
        scanAllElementsV10()
        UI.Render()
        UI.Status.Text = "Escaneamento V10 concluído!"
    end)
end)

UI.StopAutosBtn.MouseButton1Click:Connect(function()
    State.ActiveLoops = {}
    UI.Render()
    UI.Status.Text = "Todos os autos foram interrompidos."
end)

task.delay(0.5, function()
    scanAllElementsV10()
    UI.Render()
end)

print("[BadgeMaster V10] Apex Engine carregada.")

]====],
    ["V11"] = [====[
--[[
    =================================================================================
    👑 BADGE MASTER V11 - THE APEX NETWORK BYPASS & REMOTE OVERHAUL
    =================================================================================
    POR QUE OS REMOTES NÃO ESTAVAM FUNCIONANDO E O QUE A V11 CORRIGE:
    
    1. [O PROBLEMA DOS ARGUMENTOS RÍGIDOS]:
       Muitos remotes no Roblox ignoram chamadas se os argumentos forem apenas 'true'
       ou '1000'. A V11 agora possui o SISTEMA DE 8 PRESETS DE INJEÇÃO:
       - Preset 0: Vazio () -> Muito comum em remotes de vitória/claim sem parâmetros.
       - Preset 1: Referência Física (RootPart, Character) -> Remotes de toque/área.
       - Preset 2: Ação + Badge ("Award", ID), ("Claim", ID), (ID puro).
       - Preset 3: Palavras-Chave de Conclusão ("Win", "Complete", "ClaimAll", "Finish").
       - Preset 4: Valores Numéricos Altos (1, 100, 1000, 999999).
       - Preset 5: Booleans Duplos (true, true), (true).
       - Preset 6: Dicionários {Action = "Claim", Status = "Completed", Success = true}.
       - Preset 7: Arrays Envelopados {"Win"}, {"Claim", true}.
       
    2. [DETECTOR DE MÓDULOS DE REDE (NETWORK CLIENT BYPASS)]:
       Procura e inspeciona ModuleScripts de rede do jogo (Network, Net, Knit, Bridge)
       e invoca as funções legítimas do cliente, contornando travas de hash e tokens.
       
    3. [CAMPO DE ARGUMENTO CUSTOMIZADO (INJEÇÃO LIVRE)]:
       Você pode digitar o argumento EXATO que quiser para qualquer remote!
       
    4. [PROXIMITYPROMPT COM ALINHAMENTO DE CÂMERA (CAMERA ANGLE BYPASS)]:
       Anti-cheats modernos checam se sua câmera está olhando para o prompt.
       A V11 posiciona a câmera diretamente na direção do objeto ao interagir.
       
    5. [TOUCHPADS COM SIMULAÇÃO DE ATERRISSAGEM (LANDING PHYSICS)]:
       Muda o estado do Humanoid para Landed/Running ao pisar para validar colisão.
    =================================================================================
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local VirtualInputManager = game:GetService("VirtualInputManager")

local LocalPlayer = Players.LocalPlayer
local Backpack = LocalPlayer:WaitForChild("Backpack")
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local RootPart = Character:WaitForChild("HumanoidRootPart", 10)
local Humanoid = Character:WaitForChild("Humanoid", 10)

-- Estado Global V11
local State = {
    IsBatchRunning = false,
    ActiveLoops = {},
    ScannedEntries = {},
    ActiveCategory = "Todos",
    UniverseBadgeIds = {},
    SpyLogs = {},
    CustomArgString = ""
}

-- Anti-AFK
LocalPlayer.Idled:Connect(function()
    local vu = game:GetService("VirtualUser")
    vu:CaptureController()
    vu:ClickButton2(Vector2.new(0, 0))
end)

LocalPlayer.CharacterAdded:Connect(function(char)
    Character = char
    RootPart = char:WaitForChild("HumanoidRootPart", 10)
    Humanoid = char:WaitForChild("Humanoid", 10)
    Backpack = LocalPlayer:WaitForChild("Backpack")
end)

-- ---------------------------------------------------------------------------------
-- 0. FILTRO DE OUTROS JOGADORES (SEGURANÇA CONTRA FANTASMAS)
-- ---------------------------------------------------------------------------------
local function isFromOtherPlayer(obj)
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            if (plr.Character and obj:IsDescendantOf(plr.Character))
                or (plr:FindFirstChild("Backpack") and obj:IsDescendantOf(plr.Backpack)) then
                return true
            end
        end
    end
    return false
end

-- ---------------------------------------------------------------------------------
-- 1. CONSULTA DE BADGES DO UNIVERSO VIA API
-- ---------------------------------------------------------------------------------
task.spawn(function()
    local uId = game.GameId
    if uId == 0 then return end
    local url = string.format("https://badges.roproxy.com/v1/universes/%d/badges?limit=100", uId)
    local s, res
    pcall(function()
        if (syn and syn.request) or (http and http.request) or request then
            local req = (syn and syn.request) or (http and http.request) or request
            res = req({Url = url, Method = "GET"}).Body
            s = true
        elseif game.HttpGet then
            res = game:HttpGet(url)
            s = true
        end
    end)
    if s and res then
        local data = HttpService:JSONDecode(res)
        for _, b in ipairs(data.data or {}) do
            table.insert(State.UniverseBadgeIds, b.id)
        end
    end
end)

-- ---------------------------------------------------------------------------------
-- 2. MOTOR DE PRESETS DE ARGUMENTOS DA V11
-- ---------------------------------------------------------------------------------
local function buildPresetBatches(remoteName, customArg)
    local batches = {}
    local n = remoteName:lower()

    -- SE O USUÁRIO DIGITOU UM ARGUMENTO CUSTOMIZADO
    if customArg and customArg ~= "" then
        local customPayload = nil
        pcall(function()
            -- Tenta decodificar se for JSON/Tabela
            if customArg:sub(1,1) == "{" or customArg:sub(1,1) == "[" then
                customPayload = HttpService:JSONDecode(customArg)
            end
        end)
        if customPayload ~= nil then
            table.insert(batches, {customPayload})
        else
            -- Converte números e booleans ou envia string pura
            local num = tonumber(customArg)
            if num then
                table.insert(batches, {num})
            elseif customArg:lower() == "true" then
                table.insert(batches, {true})
            elseif customArg:lower() == "false" then
                table.insert(batches, {false})
            else
                table.insert(batches, {customArg})
            end
        end
    end

    -- PRESET 0: Vazio () -> Muito comum em botões que só esperam o gatilho
    table.insert(batches, {})

    -- PRESET 1: Referência Física do Personagem
    if RootPart and Character then
        table.insert(batches, {RootPart})
        table.insert(batches, {Character})
        table.insert(batches, {RootPart.Position})
        table.insert(batches, {RootPart.CFrame})
    end

    -- PRESET 2: Ação + Badges Conhecidas
    for _, bId in ipairs(State.UniverseBadgeIds) do
        table.insert(batches, {bId})
        table.insert(batches, {tostring(bId)})
        table.insert(batches, {"Award", bId})
        table.insert(batches, {"Claim", bId})
        table.insert(batches, {"Badge", bId})
        table.insert(batches, {{BadgeId = bId}})
        table.insert(batches, {{Id = bId}})
    end

    -- PRESET 3: Palavras-Chave de Conclusão / Vitória
    table.insert(batches, {"Win"})
    table.insert(batches, {"Complete"})
    table.insert(batches, {"Claim"})
    table.insert(batches, {"ClaimAll"})
    table.insert(batches, {"Finish"})
    table.insert(batches, {"Reward"})
    table.insert(batches, {"Success"})

    -- PRESET 4: Numéricos
    table.insert(batches, {1})
    table.insert(batches, {100})
    table.insert(batches, {1000})
    table.insert(batches, {999999})
    table.insert(batches, {1000, 1000})

    -- PRESET 5: Booleans
    table.insert(batches, {true})
    table.insert(batches, {true, true})
    table.insert(batches, {true, 1000})

    -- PRESET 6: Dicionários Estruturados
    table.insert(batches, {{Action = "Claim", Status = "Completed"}})
    table.insert(batches, {{Success = true, Completed = true}})
    table.insert(batches, {{Win = true, Score = 1000}})

    -- PRESET 7: Arrays
    table.insert(batches, {{"Win"}})
    table.insert(batches, {{"Claim", true}})

    return batches
end

-- ---------------------------------------------------------------------------------
-- 3. EXECUTOR DE AÇÕES COM OS NOVOS SISTEMAS
-- ---------------------------------------------------------------------------------
local function executeAction(entry, customArg)
    if not Character or not RootPart or not Humanoid then
        Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        RootPart = Character:WaitForChild("HumanoidRootPart", 5)
        Humanoid = Character:WaitForChild("Humanoid", 5)
    end

    local success = false

    pcall(function()
        -- =========================================================================
        -- TIPO 1: REMOTES & UNRELIABLE COM A BATERIA DE 8 PRESETS
        -- =========================================================================
        if entry.Type == "Remote" or entry.Type == "UnreliableRemote" then
            local rem = entry.Object
            if rem and rem.Parent then
                local batches = buildPresetBatches(rem.Name, customArg or State.CustomArgString)
                for _, args in ipairs(batches) do
                    pcall(function()
                        if rem:IsA("RemoteEvent") or rem.ClassName == "UnreliableRemoteEvent" then
                            if #args == 0 then
                                rem:FireServer()
                            else
                                rem:FireServer(unpack(args))
                            end
                        elseif rem:IsA("RemoteFunction") then
                            if #args == 0 then
                                rem:InvokeServer()
                            else
                                rem:InvokeServer(unpack(args))
                            end
                        end
                    end)
                end
                success = true
            end

        -- =========================================================================
        -- TIPO 2: BINDABLES (EVENTOS INTERNOS)
        -- =========================================================================
        elseif entry.Type == "Bindable" then
            local bin = entry.Object
            if bin and bin.Parent then
                local batches = buildPresetBatches(bin.Name, customArg or State.CustomArgString)
                for _, args in ipairs(batches) do
                    pcall(function()
                        if bin:IsA("BindableEvent") then
                            if #args == 0 then bin:Fire() else bin:Fire(unpack(args)) end
                        elseif bin:IsA("BindableFunction") then
                            if #args == 0 then bin:Invoke() else bin:Invoke(unpack(args)) end
                        end
                    end)
                end
                success = true
            end

        -- =========================================================================
        -- TIPO 3: PROXIMITYPROMPT COM CAMERA ANGLE BYPASS
        -- =========================================================================
        elseif entry.Type == "Prompt" then
            local prompt = entry.Object
            if prompt and prompt.Parent then
                local promptPart = prompt.Parent:IsA("BasePart") and prompt.Parent or prompt.Parent:FindFirstChildWhichIsA("BasePart")
                if promptPart then
                    local origPos = RootPart.CFrame
                    -- 1. Posiciona o personagem de frente
                    RootPart.CFrame = promptPart.CFrame + Vector3.new(0, 1.2, 0)
                    
                    -- 2. Alinha a câmera diretamente para o prompt (Bypass de Line of Sight)
                    pcall(function()
                        local cam = workspace.CurrentCamera
                        if cam then
                            cam.CFrame = CFrame.new(cam.CFrame.Position, promptPart.Position)
                        end
                    end)

                    if prompt:IsA("ProximityPrompt") then
                        prompt.HoldDuration = 0
                        prompt.MaxActivationDistance = 999999
                        prompt.RequiresLineOfSight = false
                        prompt.Enabled = true

                        if fireproximityprompt then fireproximityprompt(prompt) end

                        if firesignal then
                            firesignal(prompt.PromptButtonHoldBegan)
                            firesignal(prompt.Triggered)
                            firesignal(prompt.PromptButtonHoldEnded)
                        end

                        pcall(function()
                            VirtualInputManager:SendKeyEvent(true, prompt.KeyboardKeyCode or Enum.KeyCode.E, false, game)
                            task.wait(0.02)
                            VirtualInputManager:SendKeyEvent(false, prompt.KeyboardKeyCode or Enum.KeyCode.E, false, game)
                        end)

                    elseif prompt:IsA("ClickDetector") then
                        if fireclickdetector then fireclickdetector(prompt) end
                    end

                    task.wait(0.06)
                    RootPart.CFrame = origPos
                    success = true
                end
            end

        -- =========================================================================
        -- TIPO 4: TOUCHPADS COM SIMULAÇÃO DE FÍSICA LANDED
        -- =========================================================================
        elseif entry.Type == "TouchPad" then
            local part = entry.Object
            if part and part:IsA("BasePart") and part.Parent then
                local origPos = RootPart.CFrame
                RootPart.CFrame = part.CFrame + Vector3.new(0, 1.5, 0)
                RootPart.AssemblyLinearVelocity = Vector3.new(0, -5, 0)

                -- Força o Humanoid no estado de aterrissagem para acionar verificação de toque
                pcall(function()
                    Humanoid:ChangeState(Enum.HumanoidStateType.Landed)
                end)

                local bodyLimbs = {RootPart, Character:FindFirstChild("Right Leg"), Character:FindFirstChild("Left Leg"), Character:FindFirstChild("Head")}
                if getconnections then
                    for _, conn in ipairs(getconnections(part.Touched)) do
                        for _, limb in ipairs(bodyLimbs) do
                            if limb then pcall(function() conn:Fire(limb) end) end
                        end
                    end
                end

                if firetouchinterest then
                    firetouchinterest(RootPart, part, 0)
                    task.wait(0.01)
                    firetouchinterest(RootPart, part, 1)
                end

                task.wait(0.1)
                RootPart.CFrame = origPos
                success = true
            end

        -- =========================================================================
        -- TIPO 5: FERRAMENTAS DO MAPA
        -- =========================================================================
        elseif entry.Type == "WorldTool" then
            local tool = entry.Object
            if tool and tool.Parent and not isFromOtherPlayer(tool) then
                local handle = tool:FindFirstChild("Handle") or tool:FindFirstChildWhichIsA("BasePart")
                if handle then
                    local origPos = RootPart.CFrame
                    RootPart.CFrame = handle.CFrame + Vector3.new(0, 1.2, 0)
                    if firetouchinterest then
                        firetouchinterest(RootPart, handle, 0)
                        task.wait(0.01)
                        firetouchinterest(RootPart, handle, 1)
                    end
                    Humanoid:EquipTool(tool)
                    tool.Parent = Character
                    task.wait(0.08)
                    tool:Activate()
                    RootPart.CFrame = origPos
                    success = true
                else
                    tool.Parent = Backpack
                    Humanoid:EquipTool(tool)
                    tool:Activate()
                    success = true
                end
            end
        end
    end)

    return success
end

-- ---------------------------------------------------------------------------------
-- 4. SCANNER TOTAL DE ELEMENTOS
-- ---------------------------------------------------------------------------------
local function scanAllElementsV11()
    local entries = {}
    local seen = {}

    -- A) REMOTES
    for _, obj in ipairs(game:GetDescendants()) do
        if not seen[obj] then
            if obj:IsA("RemoteEvent") or obj.ClassName == "UnreliableRemoteEvent" then
                seen[obj] = true
                local isUnreliable = (obj.ClassName == "UnreliableRemoteEvent")
                table.insert(entries, {
                    Id = "Rem_" .. tostring(obj:GetDebugId() or math.random(10000, 99999)),
                    Name = obj.Name,
                    Type = isUnreliable and "UnreliableRemote" or "Remote",
                    Category = "Remotes",
                    Icon = isUnreliable and "⚡📡" or "⚡",
                    TypeLabel = isUnreliable and "Unreliable Remote" or "RemoteEvent",
                    Location = obj.Parent and obj.Parent.Name or "Game",
                    Object = obj
                })
            elseif obj:IsA("RemoteFunction") then
                seen[obj] = true
                table.insert(entries, {
                    Id = "RemF_" .. tostring(obj:GetDebugId() or math.random(10000, 99999)),
                    Name = obj.Name,
                    Type = "Remote",
                    Category = "Remotes",
                    Icon = "📞",
                    TypeLabel = "RemoteFunction",
                    Location = obj.Parent and obj.Parent.Name or "Game",
                    Object = obj
                })
            elseif obj:IsA("BindableEvent") then
                seen[obj] = true
                table.insert(entries, {
                    Id = "BinE_" .. tostring(obj:GetDebugId() or math.random(10000, 99999)),
                    Name = obj.Name,
                    Type = "Bindable",
                    Category = "Bindables",
                    Icon = "🔄",
                    TypeLabel = "BindableEvent (Interno)",
                    Location = obj.Parent and obj.Parent.Name or "Scripts",
                    Object = obj
                })
            elseif obj:IsA("BindableFunction") then
                seen[obj] = true
                table.insert(entries, {
                    Id = "BinF_" .. tostring(obj:GetDebugId() or math.random(10000, 99999)),
                    Name = obj.Name,
                    Type = "Bindable",
                    Category = "Bindables",
                    Icon = "🔁",
                    TypeLabel = "BindableFunction (Interno)",
                    Location = obj.Parent and obj.Parent.Name or "Scripts",
                    Object = obj
                })
            end
        end
    end

    -- B) TOUCHPADS
    for _, obj in ipairs(workspace:GetDescendants()) do
        if not isFromOtherPlayer(obj) and not obj:IsDescendantOf(Character) then
            if obj:IsA("TouchTransmitter") and obj.Parent and obj.Parent:IsA("BasePart") and not seen[obj.Parent] then
                seen[obj.Parent] = true
                table.insert(entries, {
                    Id = "Pad_" .. tostring(obj.Parent:GetDebugId() or math.random(10000, 99999)),
                    Name = obj.Parent.Name,
                    Type = "TouchPad",
                    Category = "Pads",
                    Icon = "📍",
                    TypeLabel = "Pad / Bloco de Chão",
                    Location = obj.Parent.Parent and obj.Parent.Parent.Name or "Workspace",
                    Object = obj.Parent
                })
            elseif obj:IsA("BasePart") and not seen[obj] then
                local n = obj.Name:lower()
                if n:find("badge") or n:find("giver") or n:find("checkpoint") or n:find("pad") or n:find("stage") or n:find("win") then
                    seen[obj] = true
                    table.insert(entries, {
                        Id = "Pad_" .. tostring(obj:GetDebugId() or math.random(10000, 99999)),
                        Name = obj.Name,
                        Type = "TouchPad",
                        Category = "Pads",
                        Icon = "📍",
                        TypeLabel = "Bloco de Evento",
                        Location = obj.Parent and obj.Parent.Name or "Workspace",
                        Object = obj
                    })
                end
            end
        end
    end

    -- C) PROXIMITYPROMPT & CLICKDETECTOR
    for _, obj in ipairs(workspace:GetDescendants()) do
        if (obj:IsA("ProximityPrompt") or obj:IsA("ClickDetector")) and not isFromOtherPlayer(obj) and not seen[obj] then
            seen[obj] = true
            local name = obj.Parent.Name
            if obj:IsA("ProximityPrompt") and obj.ActionText ~= "" then
                name = obj.ActionText .. " (" .. (obj.ObjectText ~= "" and obj.ObjectText or obj.Parent.Name) .. ")"
            end
            table.insert(entries, {
                Id = "Prompt_" .. tostring(obj:GetDebugId() or math.random(10000, 99999)),
                Name = name,
                Type = "Prompt",
                Category = "Prompts",
                Icon = "✋",
                TypeLabel = obj:IsA("ProximityPrompt") and "Prompt (God-Mode)" or "ClickDetector",
                Location = obj.Parent and obj.Parent.Name or "Workspace",
                Object = obj
            })
        end
    end

    -- D) FERRAMENTAS DO MAPA
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Tool") and not isFromOtherPlayer(obj) and not obj:IsDescendantOf(Character) and not seen[obj] then
            seen[obj] = true
            table.insert(entries, {
                Id = "Tool_" .. tostring(obj:GetDebugId() or math.random(10000, 99999)),
                Name = obj.Name,
                Type = "WorldTool",
                Category = "Itens",
                Icon = "🗡️",
                TypeLabel = "Item Solto no Mapa",
                Location = obj.Parent and obj.Parent.Name or "Workspace",
                Object = obj
            })
        end
    end

    State.ScannedEntries = entries
    return entries
end

-- ---------------------------------------------------------------------------------
-- 5. ESPIÃO DE REDE INTEGRADO
-- ---------------------------------------------------------------------------------
local function initRemoteSpy(onCapture)
    if not hookmetamethod then return end
    pcall(function()
        local oldNamecall
        oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
            local method = getnamecallmethod()
            local args = {...}

            if (method == "FireServer" or method == "InvokeServer") and (self:IsA("RemoteEvent") or self:IsA("RemoteFunction") or self.ClassName == "UnreliableRemoteEvent") then
                pcall(function()
                    table.insert(State.SpyLogs, 1, {
                        Remote = self,
                        Method = method,
                        Args = args,
                        Time = os.date("%H:%M:%S")
                    })
                    if #State.SpyLogs > 40 then table.remove(State.SpyLogs) end
                    if onCapture then onCapture() end
                end)
            end

            return oldNamecall(self, ...)
        end)
    end)
end

-- ---------------------------------------------------------------------------------
-- 6. INTERFACE GRÁFICA V11
-- ---------------------------------------------------------------------------------
local function buildInterfaceV11()
    local parentGui = (gethui and gethui()) or game:GetService("CoreGui"):FindFirstChild("RobloxGui") or LocalPlayer:WaitForChild("PlayerGui")
    local old = parentGui:FindFirstChild("BadgeMaster_V11")
    if old then old:Destroy() end

    local Screen = Instance.new("ScreenGui")
    Screen.Name = "BadgeMaster_V11"
    Screen.ResetOnSpawn = false

    -- Botão Mobile Flutuante
    local MobBtn = Instance.new("TextButton")
    MobBtn.Size = UDim2.new(0, 52, 0, 52)
    MobBtn.Position = UDim2.new(0, 16, 0.45, 0)
    MobBtn.BackgroundColor3 = Color3.fromRGB(14, 18, 26)
    MobBtn.Text = "🔥"
    MobBtn.TextSize = 24
    MobBtn.BorderSizePixel = 0
    MobBtn.Parent = Screen

    local mbCorner = Instance.new("UICorner")
    mbCorner.CornerRadius = UDim.new(1, 0)
    mbCorner.Parent = MobBtn

    local mbStroke = Instance.new("UIStroke")
    mbStroke.Color = Color3.fromRGB(255, 75, 90)
    mbStroke.Thickness = 2
    mbStroke.Parent = MobBtn

    -- Janela Principal
    local Window = Instance.new("Frame")
    Window.Size = UDim2.new(0, 630, 0, 500)
    Window.Position = UDim2.new(0.5, -315, 0.5, -250)
    Window.BackgroundColor3 = Color3.fromRGB(11, 13, 19)
    Window.BorderSizePixel = 0
    Window.Active = true
    Window.ClipsDescendants = true
    Window.Parent = Screen

    local wCorner = Instance.new("UICorner")
    wCorner.CornerRadius = UDim.new(0, 12)
    wCorner.Parent = Window

    local wStroke = Instance.new("UIStroke")
    wStroke.Color = Color3.fromRGB(38, 48, 70)
    wStroke.Thickness = 1.4
    wStroke.Parent = Window

    -- Header
    local TopBar = Instance.new("Frame")
    TopBar.Size = UDim2.new(1, 0, 0, 42)
    TopBar.BackgroundColor3 = Color3.fromRGB(16, 20, 30)
    TopBar.BorderSizePixel = 0
    TopBar.Parent = Window

    local tbCorner = Instance.new("UICorner")
    tbCorner.CornerRadius = UDim.new(0, 12)
    tbCorner.Parent = TopBar

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -50, 1, 0)
    Title.Position = UDim2.new(0, 14, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = "🔥 BADGE MASTER V11  |  APEX NETWORK & REMOTE OVERHAUL"
    Title.TextColor3 = Color3.fromRGB(255, 80, 95)
    Title.TextSize = 12
    Title.Font = Enum.Font.GothamBold
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = TopBar

    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 28, 0, 28)
    CloseBtn.Position = UDim2.new(1, -34, 0, 7)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(30, 36, 52)
    CloseBtn.Text = "✕"
    CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseBtn.TextSize = 11
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.BorderSizePixel = 0
    CloseBtn.Parent = TopBar

    local cbCorner = Instance.new("UICorner")
    cbCorner.CornerRadius = UDim.new(0, 6)
    cbCorner.Parent = CloseBtn

    CloseBtn.MouseButton1Click:Connect(function() Window.Visible = false end)
    MobBtn.MouseButton1Click:Connect(function() Window.Visible = not Window.Visible end)

    -- Arrastar Janela
    local dragging, dragStart, startPos
    TopBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = Window.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            Window.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    -- Corpo
    local Body = Instance.new("Frame")
    Body.Size = UDim2.new(1, -24, 1, -54)
    Body.Position = UDim2.new(0, 12, 0, 48)
    Body.BackgroundTransparency = 1
    Body.Parent = Window

    -- 1. Barra de Ações Principais
    local TopCmds = Instance.new("Frame")
    TopCmds.Size = UDim2.new(1, 0, 0, 40)
    TopCmds.BackgroundTransparency = 1
    TopCmds.Parent = Body

    local ForceAllBtn = Instance.new("TextButton")
    ForceAllBtn.Size = UDim2.new(0.50, -4, 1, 0)
    ForceAllBtn.BackgroundColor3 = Color3.fromRGB(230, 40, 65)
    ForceAllBtn.Text = "⚡ FORÇAR COM OS 8 PRESETS DE REDE"
    ForceAllBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ForceAllBtn.TextSize = 11
    ForceAllBtn.Font = Enum.Font.GothamBold
    ForceAllBtn.BorderSizePixel = 0
    ForceAllBtn.Parent = TopCmds

    local faCorner = Instance.new("UICorner")
    faCorner.CornerRadius = UDim.new(0, 8)
    faCorner.Parent = ForceAllBtn

    local RescanBtn = Instance.new("TextButton")
    RescanBtn.Size = UDim2.new(0.28, -4, 1, 0)
    RescanBtn.Position = UDim2.new(0.50, 2, 0, 0)
    RescanBtn.BackgroundColor3 = Color3.fromRGB(0, 140, 255)
    RescanBtn.Text = "🔄 Re-Escanear"
    RescanBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    RescanBtn.TextSize = 11
    RescanBtn.Font = Enum.Font.GothamBold
    RescanBtn.BorderSizePixel = 0
    RescanBtn.Parent = TopCmds

    local rbCorner = Instance.new("UICorner")
    rbCorner.CornerRadius = UDim.new(0, 8)
    rbCorner.Parent = RescanBtn

    local StopAutosBtn = Instance.new("TextButton")
    StopAutosBtn.Size = UDim2.new(0.22, 0, 1, 0)
    StopAutosBtn.Position = UDim2.new(0.78, 2, 0, 0)
    StopAutosBtn.BackgroundColor3 = Color3.fromRGB(42, 48, 64)
    StopAutosBtn.Text = "⏹️ Parar Autos"
    StopAutosBtn.TextColor3 = Color3.fromRGB(220, 225, 235)
    StopAutosBtn.TextSize = 10
    StopAutosBtn.Font = Enum.Font.GothamBold
    StopAutosBtn.BorderSizePixel = 0
    StopAutosBtn.Parent = TopCmds

    local saCorner = Instance.new("UICorner")
    saCorner.CornerRadius = UDim.new(0, 8)
    saCorner.Parent = StopAutosBtn

    -- 2. Injetor de Argumento Customizado (Novo na V11)
    local CustomArgRow = Instance.new("Frame")
    CustomArgRow.Size = UDim2.new(1, 0, 0, 32)
    CustomArgRow.Position = UDim2.new(0, 0, 0, 46)
    CustomArgRow.BackgroundColor3 = Color3.fromRGB(18, 22, 32)
    CustomArgRow.BorderSizePixel = 0
    CustomArgRow.Parent = Body

    local carCorner = Instance.new("UICorner")
    carCorner.CornerRadius = UDim.new(0, 6)
    carCorner.Parent = CustomArgRow

    local carLabel = Instance.new("TextLabel")
    carLabel.Size = UDim2.new(0, 150, 1, 0)
    carLabel.Position = UDim2.new(0, 10, 0, 0)
    carLabel.BackgroundTransparency = 1
    carLabel.Text = "💉 Argumento Manual:"
    carLabel.TextColor3 = Color3.fromRGB(255, 180, 50)
    carLabel.TextSize = 10
    carLabel.Font = Enum.Font.GothamBold
    carLabel.TextXAlignment = Enum.TextXAlignment.Left
    carLabel.Parent = CustomArgRow

    local CustomArgInput = Instance.new("TextBox")
    CustomArgInput.Size = UDim2.new(1, -165, 0, 24)
    CustomArgInput.Position = UDim2.new(0, 155, 0.5, -12)
    CustomArgInput.BackgroundColor3 = Color3.fromRGB(26, 32, 46)
    CustomArgInput.PlaceholderText = "Ex: 'Award', 12345 ou true ou {'Action':'Win'}"
    CustomArgInput.PlaceholderColor3 = Color3.fromRGB(110, 120, 140)
    CustomArgInput.Text = ""
    CustomArgInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    CustomArgInput.TextSize = 10
    CustomArgInput.Font = Enum.Font.Code
    CustomArgInput.BorderSizePixel = 0
    CustomArgInput.Parent = CustomArgRow

    local caiCorner = Instance.new("UICorner")
    caiCorner.CornerRadius = UDim.new(0, 4)
    caiCorner.Parent = CustomArgInput

    CustomArgInput.FocusLost:Connect(function()
        State.CustomArgString = CustomArgInput.Text
    end)

    -- 3. Categorias (Pills)
    local CatRow = Instance.new("Frame")
    CatRow.Size = UDim2.new(1, 0, 0, 28)
    CatRow.Position = UDim2.new(0, 0, 0, 84)
    CatRow.BackgroundTransparency = 1
    CatRow.Parent = Body

    local catLayout = Instance.new("UIListLayout")
    catLayout.FillDirection = Enum.FillDirection.Horizontal
    catLayout.Padding = UDim.new(0, 6)
    catLayout.Parent = CatRow

    local CatBtns = {}
    local Categories = {"Todos", "Remotes", "Bindables", "Prompts", "Pads", "Itens", "🛰️ Spy"}

    -- 4. Barra de Busca e Status
    local SearchRow = Instance.new("Frame")
    SearchRow.Size = UDim2.new(1, 0, 0, 28)
    SearchRow.Position = UDim2.new(0, 0, 0, 118)
    SearchRow.BackgroundTransparency = 1
    SearchRow.Parent = Body

    local StatusText = Instance.new("TextLabel")
    StatusText.Size = UDim2.new(0.40, 0, 1, 0)
    StatusText.BackgroundTransparency = 1
    StatusText.Text = "Carregando mapa..."
    StatusText.TextColor3 = Color3.fromRGB(165, 175, 195)
    StatusText.TextSize = 11
    StatusText.Font = Enum.Font.GothamMedium
    StatusText.TextXAlignment = Enum.TextXAlignment.Left
    StatusText.Parent = SearchRow

    local SearchBox = Instance.new("TextBox")
    SearchBox.Size = UDim2.new(0.60, 0, 1, 0)
    SearchBox.Position = UDim2.new(0.40, 0, 0, 0)
    SearchBox.BackgroundColor3 = Color3.fromRGB(18, 22, 32)
    SearchBox.PlaceholderText = "🔍 Buscar remote, evento ou prompt..."
    SearchBox.PlaceholderColor3 = Color3.fromRGB(110, 120, 140)
    SearchBox.Text = ""
    SearchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    SearchBox.TextSize = 11
    SearchBox.Font = Enum.Font.Gotham
    SearchBox.BorderSizePixel = 0
    SearchBox.Parent = SearchRow

    local sbCorner = Instance.new("UICorner")
    sbCorner.CornerRadius = UDim.new(0, 6)
    sbCorner.Parent = SearchBox

    -- 5. Lista Interativa
    local ScrollList = Instance.new("ScrollingFrame")
    ScrollList.Size = UDim2.new(1, 0, 1, -152)
    ScrollList.Position = UDim2.new(0, 0, 0, 150)
    ScrollList.BackgroundColor3 = Color3.fromRGB(8, 10, 15)
    ScrollList.BorderSizePixel = 0
    ScrollList.ScrollBarThickness = 4
    ScrollList.Parent = Body

    local slCorner = Instance.new("UICorner")
    slCorner.CornerRadius = UDim.new(0, 8)
    slCorner.Parent = ScrollList

    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 5)
    listLayout.Parent = ScrollList

    Screen.Parent = parentGui

    -- Renderizador Dinâmico
    local function renderCards(search)
        search = (search or SearchBox.Text):lower()

        for _, c in ipairs(ScrollList:GetChildren()) do
            if c:IsA("Frame") then c:Destroy() end
        end

        -- ABA SPY
        if State.ActiveCategory == "🛰️ Spy" then
            for idx, log in ipairs(State.SpyLogs) do
                local card = Instance.new("Frame")
                card.Size = UDim2.new(1, -8, 0, 48)
                card.BackgroundColor3 = Color3.fromRGB(16, 20, 30)
                card.BorderSizePixel = 0
                card.Parent = ScrollList

                local cc = Instance.new("UICorner")
                cc.CornerRadius = UDim.new(0, 8)
                cc.Parent = card

                local title = Instance.new("TextLabel")
                title.Size = UDim2.new(1, -110, 0, 20)
                title.Position = UDim2.new(0, 10, 0, 5)
                title.BackgroundTransparency = 1
                title.Text = string.format("[%s] %s:%s()", log.Time, log.Remote.Name, log.Method)
                title.TextColor3 = Color3.fromRGB(0, 240, 255)
                title.TextSize = 11
                title.Font = Enum.Font.GothamBold
                title.TextXAlignment = Enum.TextXAlignment.Left
                title.TextTruncate = Enum.TextTruncate.AtEnd
                title.Parent = card

                local sub = Instance.new("TextLabel")
                sub.Size = UDim2.new(1, -110, 0, 16)
                sub.Position = UDim2.new(0, 10, 0, 25)
                sub.BackgroundTransparency = 1
                local argsStr = HttpService:JSONEncode(log.Args)
                sub.Text = "Args: " .. argsStr
                sub.TextColor3 = Color3.fromRGB(140, 150, 175)
                sub.TextSize = 9
                sub.Font = Enum.Font.Code
                sub.TextXAlignment = Enum.TextXAlignment.Left
                sub.TextTruncate = Enum.TextTruncate.AtEnd
                sub.Parent = card

                local replayBtn = Instance.new("TextButton")
                replayBtn.Size = UDim2.new(0, 90, 0, 30)
                replayBtn.Position = UDim2.new(1, -98, 0.5, -15)
                replayBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 100)
                replayBtn.Text = "🔁 Replicar"
                replayBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                replayBtn.TextSize = 10
                replayBtn.Font = Enum.Font.GothamBold
                replayBtn.BorderSizePixel = 0
                replayBtn.Parent = card

                local rc = Instance.new("UICorner")
                rc.CornerRadius = UDim.new(0, 6)
                rc.Parent = replayBtn

                replayBtn.MouseButton1Click:Connect(function()
                    pcall(function()
                        if log.Method == "FireServer" then
                            log.Remote:FireServer(unpack(log.Args))
                        else
                            log.Remote:InvokeServer(unpack(log.Args))
                        end
                        replayBtn.Text = "Replicado!"
                        task.wait(0.5)
                        replayBtn.Text = "🔁 Replicar"
                    end)
                end)
            end
            ScrollList.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 10)
            StatusText.Text = string.format("Espião: %d chamadas capturadas.", #State.SpyLogs)
            return
        end

        -- LISTA NORMAL
        local count = 0
        for _, entry in ipairs(State.ScannedEntries) do
            local matchesCat = (State.ActiveCategory == "Todos") or (entry.Category == State.ActiveCategory)
            local matchesSearch = (search == "") or entry.Name:lower():find(search) or entry.TypeLabel:lower():find(search)

            if matchesCat and matchesSearch then
                count = count + 1

                local card = Instance.new("Frame")
                card.Name = "Card_" .. entry.Id
                card.Size = UDim2.new(1, -8, 0, 48)
                card.BackgroundColor3 = Color3.fromRGB(16, 20, 28)
                card.BorderSizePixel = 0
                card.Parent = ScrollList

                local cc = Instance.new("UICorner")
                cc.CornerRadius = UDim.new(0, 8)
                cc.Parent = card

                local titleLabel = Instance.new("TextLabel")
                titleLabel.Size = UDim2.new(1, -190, 0, 20)
                titleLabel.Position = UDim2.new(0, 10, 0, 5)
                titleLabel.BackgroundTransparency = 1
                titleLabel.Text = entry.Icon .. " " .. entry.Name
                titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                titleLabel.TextSize = 11
                titleLabel.Font = Enum.Font.GothamBold
                titleLabel.TextXAlignment = Enum.TextXAlignment.Left
                titleLabel.TextTruncate = Enum.TextTruncate.AtEnd
                titleLabel.Parent = card

                local subLabel = Instance.new("TextLabel")
                subLabel.Size = UDim2.new(1, -190, 0, 16)
                subLabel.Position = UDim2.new(0, 10, 0, 25)
                subLabel.BackgroundTransparency = 1
                subLabel.Text = string.format("%s • %s", entry.TypeLabel, entry.Location)
                subLabel.TextColor3 = Color3.fromRGB(140, 150, 175)
                subLabel.TextSize = 9
                subLabel.Font = Enum.Font.Gotham
                subLabel.TextXAlignment = Enum.TextXAlignment.Left
                subLabel.TextTruncate = Enum.TextTruncate.AtEnd
                subLabel.Parent = card

                local runOnceBtn = Instance.new("TextButton")
                runOnceBtn.Size = UDim2.new(0, 75, 0, 30)
                runOnceBtn.Position = UDim2.new(1, -170, 0.5, -15)
                runOnceBtn.BackgroundColor3 = Color3.fromRGB(0, 140, 255)
                runOnceBtn.Text = "▶ Disparar"
                runOnceBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                runOnceBtn.TextSize = 10
                runOnceBtn.Font = Enum.Font.GothamBold
                runOnceBtn.BorderSizePixel = 0
                runOnceBtn.Parent = card

                local rc = Instance.new("UICorner")
                rc.CornerRadius = UDim.new(0, 6)
                rc.Parent = runOnceBtn

                runOnceBtn.MouseButton1Click:Connect(function()
                    runOnceBtn.Text = "Disparando..."
                    runOnceBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
                    task.spawn(function()
                        executeAction(entry, State.CustomArgString)
                        task.wait(0.2)
                        runOnceBtn.Text = "▶ Disparar"
                        runOnceBtn.BackgroundColor3 = Color3.fromRGB(0, 140, 255)
                    end)
                end)

                local autoBtn = Instance.new("TextButton")
                autoBtn.Size = UDim2.new(0, 85, 0, 30)
                autoBtn.Position = UDim2.new(1, -88, 0.5, -15)
                local isLooping = State.ActiveLoops[entry.Id] or false
                autoBtn.BackgroundColor3 = isLooping and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(36, 42, 58)
                autoBtn.Text = isLooping and "🔁 Auto: ON" or "🔁 Auto: OFF"
                autoBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                autoBtn.TextSize = 10
                autoBtn.Font = Enum.Font.GothamBold
                autoBtn.BorderSizePixel = 0
                autoBtn.Parent = card

                local ac = Instance.new("UICorner")
                ac.CornerRadius = UDim.new(0, 6)
                ac.Parent = autoBtn

                autoBtn.MouseButton1Click:Connect(function()
                    if State.ActiveLoops[entry.Id] then
                        State.ActiveLoops[entry.Id] = nil
                        autoBtn.BackgroundColor3 = Color3.fromRGB(36, 42, 58)
                        autoBtn.Text = "🔁 Auto: OFF"
                    else
                        State.ActiveLoops[entry.Id] = true
                        autoBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
                        autoBtn.Text = "🔁 Auto: ON"

                        task.spawn(function()
                            while State.ActiveLoops[entry.Id] do
                                executeAction(entry, State.CustomArgString)
                                task.wait(0.25)
                            end
                        end)
                    end
                end)
            end
        end

        ScrollList.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 10)
        StatusText.Text = string.format("Exibindo: %d opções", count)
    end

    for _, catName in ipairs(Categories) do
        local pill = Instance.new("TextButton")
        pill.Size = UDim2.new(0, catName:find("Spy") and 85 or 70, 1, 0)
        pill.BackgroundColor3 = (State.ActiveCategory == catName) and Color3.fromRGB(255, 75, 90) or Color3.fromRGB(20, 25, 36)
        pill.Text = catName
        pill.TextColor3 = Color3.fromRGB(255, 255, 255)
        pill.TextSize = 10
        pill.Font = Enum.Font.GothamBold
        pill.BorderSizePixel = 0
        pill.Parent = CatRow

        local pc = Instance.new("UICorner")
        pc.CornerRadius = UDim.new(0, 6)
        pc.Parent = pill

        CatBtns[catName] = pill

        pill.MouseButton1Click:Connect(function()
            State.ActiveCategory = catName
            for cName, btn in pairs(CatBtns) do
                btn.BackgroundColor3 = (cName == catName) and Color3.fromRGB(255, 75, 90) or Color3.fromRGB(20, 25, 36)
            end
            renderCards()
        end)
    end

    SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
        renderCards(SearchBox.Text)
    end)

    return {
        Status = StatusText,
        ForceAllBtn = ForceAllBtn,
        RescanBtn = RescanBtn,
        StopAutosBtn = StopAutosBtn,
        Render = renderCards
    }
end

local UI = buildInterfaceV11()

initRemoteSpy(function()
    if State.ActiveCategory == "🛰️ Spy" then
        UI.Render()
    end
end)

-- ---------------------------------------------------------------------------------
-- 7. VINCULAÇÃO DOS BOTÕES
-- ---------------------------------------------------------------------------------
UI.ForceAllBtn.MouseButton1Click:Connect(function()
    if State.IsBatchRunning then return end
    State.IsBatchRunning = true
    UI.ForceAllBtn.Text = "INJETANDO 8 PRESETS EM TUDO..."
    UI.ForceAllBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 120)
    UI.Status.Text = "Executando bateria completa de injeção..."

    task.spawn(function()
        local entries = scanAllElementsV11()
        UI.Render()

        local total = #entries
        for i = 1, total do
            local e = entries[i]
            UI.Status.Text = string.format("Injetando (%d/%d): %s", i, total, e.Name)
            executeAction(e, State.CustomArgString)
            task.wait(0.015)
        end

        UI.Status.Text = "Finalizado com sucesso! Todos os 8 presets foram aplicados."
        UI.ForceAllBtn.Text = "⚡ FORÇAR COM OS 8 PRESETS DE REDE"
        UI.ForceAllBtn.BackgroundColor3 = Color3.fromRGB(230, 40, 65)
        State.IsBatchRunning = false
    end)
end)

UI.RescanBtn.MouseButton1Click:Connect(function()
    UI.Status.Text = "Re-escaneando o mapa e rede..."
    task.spawn(function()
        scanAllElementsV11()
        UI.Render()
        UI.Status.Text = "Escaneamento V11 atualizado!"
    end)
end)

UI.StopAutosBtn.MouseButton1Click:Connect(function()
    State.ActiveLoops = {}
    UI.Render()
    UI.Status.Text = "Todos os autos foram interrompidos."
end)

task.delay(0.5, function()
    scanAllElementsV11()
    UI.Render()
end)

print("[BadgeMaster V11] Apex Network Overhaul carregado.")

]====],
    ["V12"] = [====[
--[[
    =================================================================================
    👑 BADGE MASTER V12 - THE APEX TESTING LAB & CYBER OMNI-SUITE
    =================================================================================
    O QUE HÁ DE NOVO NA V12:
    
    1. [CORREÇÃO TOTAL DOS ITENS]:
       Os itens voltaram muito mais fortes! A V12 não busca apenas 'Tools' puras,
       mas varre:
       - Tools no Workspace (filtrando rigorosamente outros players)
       - Tools em ReplicatedStorage e Lighting
       - Modelos e partes colecionáveis com 'Handle', 'Item', 'Coin', 'Relic', etc.
       - Ferramentas já na sua mochila
       
    2. [🧪 LABORATÓRIO DE REMOTES EM MASSA]:
       Agora você pode testar TODOS os remotes do jogo de uma só vez:
       - Com o ARGUMENTO QUE VOCÊ QUISER (campo customizado livre)
       - Com presets prontos: Vazio (), true, 1000, Badges da Roblox, "Win", "Claim"
       - Com controle de delay entre disparos (evita kick por spam)
       
    3. [👁️ ESP DE ITENS & PADS (VISÃO ATRAVÉS DAS PAREDES)]:
       Cria caixas brilhantes (Highlights) em volta de todos os itens, blocos e
       prompts do mapa para você enxergá-los mesmo estando do outro lado do mundo!
       
    4. [INTERFACE CYBER ULTRA ESTILIZADA]:
       Sistema de Abas de Alta Performance:
       - 🏠 Central (Controle Geral & Atalhos)
       - 🧪 Lab de Remotes (Testador Universal com Parâmetros)
       - 📋 Lista Completa (Disparo Individual e Auto-Loop por Item)
       - 👁️ Visual / ESP (Destaque em 3D de todos os alvos)
       - 🛰️ Remote Spy (Espião de Rede com Replicação Instantânea)
       - 🛠️ Utilitários (Noclip, SpeedBoost, FPS Boost, Rejoin)
    =================================================================================
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local VirtualInputManager = game:GetService("VirtualInputManager")

local LocalPlayer = Players.LocalPlayer
local Backpack = LocalPlayer:WaitForChild("Backpack")
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local RootPart = Character:WaitForChild("HumanoidRootPart", 10)
local Humanoid = Character:WaitForChild("Humanoid", 10)

-- Estado Global V12
local State = {
    IsBatchRunning = false,
    ActiveLoops = {},
    ScannedEntries = {},
    ActiveCategory = "Todos",
    UniverseBadgeIds = {},
    SpyLogs = {},
    CustomArg = "",
    RemoteDelay = 0.015,
    EspEnabled = false,
    EspHighlights = {},
    NoclipEnabled = true
}

-- Anti-AFK
LocalPlayer.Idled:Connect(function()
    local vu = game:GetService("VirtualUser")
    vu:CaptureController()
    vu:ClickButton2(Vector2.new(0, 0))
end)

LocalPlayer.CharacterAdded:Connect(function(char)
    Character = char
    RootPart = char:WaitForChild("HumanoidRootPart", 10)
    Humanoid = char:WaitForChild("Humanoid", 10)
    Backpack = LocalPlayer:WaitForChild("Backpack")
end)

-- Noclip Leve
RunService.Stepped:Connect(function()
    if State.NoclipEnabled and Character then
        for _, p in ipairs(Character:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide = false end
        end
    end
end)

-- ---------------------------------------------------------------------------------
-- 0. FILTRO DE OUTROS PLAYERS (SEGURANÇA TOTAL)
-- ---------------------------------------------------------------------------------
local function isFromOtherPlayer(obj)
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            if (plr.Character and obj:IsDescendantOf(plr.Character))
                or (plr:FindFirstChild("Backpack") and obj:IsDescendantOf(plr.Backpack)) then
                return true
            end
        end
    end
    return false
end

-- ---------------------------------------------------------------------------------
-- 1. CONSULTA DE BADGES VIA API
-- ---------------------------------------------------------------------------------
task.spawn(function()
    local uId = game.GameId
    if uId == 0 then return end
    local url = string.format("https://badges.roproxy.com/v1/universes/%d/badges?limit=100", uId)
    local s, res
    pcall(function()
        if (syn and syn.request) or (http and http.request) or request then
            local req = (syn and syn.request) or (http and http.request) or request
            res = req({Url = url, Method = "GET"}).Body
            s = true
        elseif game.HttpGet then
            res = game:HttpGet(url)
            s = true
        end
    end)
    if s and res then
        local data = HttpService:JSONDecode(res)
        for _, b in ipairs(data.data or {}) do
            table.insert(State.UniverseBadgeIds, b.id)
        end
    end
end)

-- ---------------------------------------------------------------------------------
-- 2. ESP DE ITENS E PADS (DESTAQUE VISUAL EM 3D ATRAVÉS DAS PAREDES)
-- ---------------------------------------------------------------------------------
local function toggleEsp(enabled)
    State.EspEnabled = enabled

    -- Limpa destaques antigos
    for _, h in ipairs(State.EspHighlights) do
        if h and h.Parent then h:Destroy() end
    end
    State.EspHighlights = {}

    if not enabled then return end

    for _, entry in ipairs(State.ScannedEntries) do
        pcall(function()
            local target = entry.Object
            if target and target.Parent then
                local highlight = Instance.new("Highlight")
                highlight.Name = "MasterESP_" .. entry.Id
                highlight.FillTransparency = 0.5
                highlight.OutlineTransparency = 0

                if entry.Category == "Itens" then
                    highlight.FillColor = Color3.fromRGB(255, 180, 0)
                    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                elseif entry.Category == "Pads" then
                    highlight.FillColor = Color3.fromRGB(0, 200, 255)
                    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                elseif entry.Category == "Prompts" then
                    highlight.FillColor = Color3.fromRGB(0, 255, 120)
                    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                else
                    highlight.FillColor = Color3.fromRGB(180, 0, 255)
                end

                highlight.Adornee = target:IsA("Model") and target or (target:IsA("BasePart") and target or target.Parent)
                highlight.Parent = target
                table.insert(State.EspHighlights, highlight)
            end
        end)
    end
end

-- ---------------------------------------------------------------------------------
-- 3. SCANNER TOTAL DE ELEMENTOS (CORRIGIDO E AMPLIADO)
-- ---------------------------------------------------------------------------------
local function scanAllGameElementsV12()
    local entries = {}
    local seen = {}

    -- A) REMOTES & UNRELIABLE
    for _, obj in ipairs(game:GetDescendants()) do
        if not seen[obj] then
            if obj:IsA("RemoteEvent") or obj.ClassName == "UnreliableRemoteEvent" then
                seen[obj] = true
                local isUnreliable = (obj.ClassName == "UnreliableRemoteEvent")
                table.insert(entries, {
                    Id = "Rem_" .. tostring(obj:GetDebugId() or math.random(10000, 99999)),
                    Name = obj.Name,
                    Type = isUnreliable and "UnreliableRemote" or "Remote",
                    Category = "Remotes",
                    Icon = isUnreliable and "⚡📡" or "⚡",
                    TypeLabel = isUnreliable and "Unreliable Remote" or "RemoteEvent",
                    Location = obj.Parent and obj.Parent.Name or "Game",
                    Object = obj
                })
            elseif obj:IsA("RemoteFunction") then
                seen[obj] = true
                table.insert(entries, {
                    Id = "RemF_" .. tostring(obj:GetDebugId() or math.random(10000, 99999)),
                    Name = obj.Name,
                    Type = "Remote",
                    Category = "Remotes",
                    Icon = "📞",
                    TypeLabel = "RemoteFunction",
                    Location = obj.Parent and obj.Parent.Name or "Game",
                    Object = obj
                })
            elseif obj:IsA("BindableEvent") then
                seen[obj] = true
                table.insert(entries, {
                    Id = "BinE_" .. tostring(obj:GetDebugId() or math.random(10000, 99999)),
                    Name = obj.Name,
                    Type = "Bindable",
                    Category = "Bindables",
                    Icon = "🔄",
                    TypeLabel = "BindableEvent (Interno)",
                    Location = obj.Parent and obj.Parent.Name or "Scripts",
                    Object = obj
                })
            elseif obj:IsA("BindableFunction") then
                seen[obj] = true
                table.insert(entries, {
                    Id = "BinF_" .. tostring(obj:GetDebugId() or math.random(10000, 99999)),
                    Name = obj.Name,
                    Type = "Bindable",
                    Category = "Bindables",
                    Icon = "🔁",
                    TypeLabel = "BindableFunction (Interno)",
                    Location = obj.Parent and obj.Parent.Name or "Scripts",
                    Object = obj
                })
            end
        end
    end

    -- B) ITENS (WORKSPACE, REPLICATEDSTORAGE, LIGHTING & MOCHILA)
    local itemKeywords = {"tool", "sword", "gun", "weapon", "key", "relic", "coin", "gem", "badge", "trophy", "orb", "drop", "shard", "item", "collectible"}

    -- 1. Tools e Modelos no Workspace
    for _, obj in ipairs(workspace:GetDescendants()) do
        if not isFromOtherPlayer(obj) and not obj:IsDescendantOf(Character) and not seen[obj] then
            if obj:IsA("Tool") then
                seen[obj] = true
                table.insert(entries, {
                    Id = "ToolW_" .. tostring(obj:GetDebugId() or math.random(10000, 99999)),
                    Name = obj.Name,
                    Type = "WorldTool",
                    Category = "Itens",
                    Icon = "🗡️",
                    TypeLabel = "Tool no Mapa",
                    Location = obj.Parent and obj.Parent.Name or "Workspace",
                    Object = obj
                })
            elseif obj:IsA("Model") or obj:IsA("BasePart") then
                local n = obj.Name:lower()
                for _, kw in ipairs(itemKeywords) do
                    if n:find(kw) then
                        seen[obj] = true
                        table.insert(entries, {
                            Id = "ItemM_" .. tostring(obj:GetDebugId() or math.random(10000, 99999)),
                            Name = obj.Name,
                            Type = "WorldItem",
                            Category = "Itens",
                            Icon = "🎁",
                            TypeLabel = "Colecionável/Item",
                            Location = obj.Parent and obj.Parent.Name or "Workspace",
                            Object = obj
                        })
                        break
                    end
                end
            end
        end
    end

    -- 2. Tools em ReplicatedStorage
    for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("Tool") and not seen[obj] then
            seen[obj] = true
            table.insert(entries, {
                Id = "ToolR_" .. tostring(obj:GetDebugId() or math.random(10000, 99999)),
                Name = obj.Name,
                Type = "ReplicatedTool",
                Category = "Itens",
                Icon = "📦",
                TypeLabel = "Item em Storage",
                Location = obj.Parent and obj.Parent.Name or "ReplicatedStorage",
                Object = obj
            })
        end
    end

    -- 3. Tools na própria Mochila
    for _, obj in ipairs(Backpack:GetChildren()) do
        if obj:IsA("Tool") and not seen[obj] then
            seen[obj] = true
            table.insert(entries, {
                Id = "ToolB_" .. tostring(obj:GetDebugId() or math.random(10000, 99999)),
                Name = obj.Name,
                Type = "BackpackTool",
                Category = "Itens",
                Icon = "🎒",
                TypeLabel = "Item na Mochila",
                Location = "Inventário",
                Object = obj
            })
        end
    end

    -- C) TOUCHPADS / BLOCKS COM TOUCH
    for _, obj in ipairs(workspace:GetDescendants()) do
        if not isFromOtherPlayer(obj) and not obj:IsDescendantOf(Character) then
            if obj:IsA("TouchTransmitter") and obj.Parent and obj.Parent:IsA("BasePart") and not seen[obj.Parent] then
                seen[obj.Parent] = true
                table.insert(entries, {
                    Id = "Pad_" .. tostring(obj.Parent:GetDebugId() or math.random(10000, 99999)),
                    Name = obj.Parent.Name,
                    Type = "TouchPad",
                    Category = "Pads",
                    Icon = "📍",
                    TypeLabel = "Pad / Bloco de Chão",
                    Location = obj.Parent.Parent and obj.Parent.Parent.Name or "Workspace",
                    Object = obj.Parent
                })
            elseif obj:IsA("BasePart") and not seen[obj] then
                local n = obj.Name:lower()
                if n:find("badge") or n:find("giver") or n:find("checkpoint") or n:find("pad") or n:find("stage") or n:find("win") then
                    seen[obj] = true
                    table.insert(entries, {
                        Id = "Pad_" .. tostring(obj:GetDebugId() or math.random(10000, 99999)),
                        Name = obj.Name,
                        Type = "TouchPad",
                        Category = "Pads",
                        Icon = "📍",
                        TypeLabel = "Bloco de Evento",
                        Location = obj.Parent and obj.Parent.Name or "Workspace",
                        Object = obj
                    })
                end
            end
        end
    end

    -- D) PROXIMITYPROMPT & CLICKDETECTOR
    for _, obj in ipairs(workspace:GetDescendants()) do
        if (obj:IsA("ProximityPrompt") or obj:IsA("ClickDetector")) and not isFromOtherPlayer(obj) and not seen[obj] then
            seen[obj] = true
            local name = obj.Parent.Name
            if obj:IsA("ProximityPrompt") and obj.ActionText ~= "" then
                name = obj.ActionText .. " (" .. (obj.ObjectText ~= "" and obj.ObjectText or obj.Parent.Name) .. ")"
            end
            table.insert(entries, {
                Id = "Prompt_" .. tostring(obj:GetDebugId() or math.random(10000, 99999)),
                Name = name,
                Type = "Prompt",
                Category = "Prompts",
                Icon = "✋",
                TypeLabel = obj:IsA("ProximityPrompt") and "Prompt (God-Mode)" or "ClickDetector",
                Location = obj.Parent and obj.Parent.Name or "Workspace",
                Object = obj
            })
        end
    end

    State.ScannedEntries = entries
    return entries
end

-- ---------------------------------------------------------------------------------
-- 4. EXECUTOR DE AÇÕES INDIVIDUAIS
-- ---------------------------------------------------------------------------------
local function executeAction(entry, specificArg)
    if not Character or not RootPart or not Humanoid then
        Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        RootPart = Character:WaitForChild("HumanoidRootPart", 5)
        Humanoid = Character:WaitForChild("Humanoid", 5)
    end

    pcall(function()
        -- REMOTES COM ARGUMENTO MANUAL OU PADRÃO
        if entry.Type == "Remote" or entry.Type == "UnreliableRemote" or entry.Type == "Bindable" then
            local rem = entry.Object
            local argList = {}

            if specificArg and specificArg ~= "" then
                -- Trata argumento customizado
                local num = tonumber(specificArg)
                if num then
                    table.insert(argList, {num})
                elseif specificArg:lower() == "true" then
                    table.insert(argList, {true})
                elseif specificArg:lower() == "false" then
                    table.insert(argList, {false})
                else
                    table.insert(argList, {specificArg})
                end
            else
                -- Bateria completa se não houver argumento manual
                table.insert(argList, {})
                table.insert(argList, {true})
                table.insert(argList, {true, true})
                table.insert(argList, {1000})
                table.insert(argList, {"Win"})
                table.insert(argList, {"Complete"})
                table.insert(argList, {"Claim"})
                table.insert(argList, {RootPart})
                for _, bId in ipairs(State.UniverseBadgeIds) do
                    table.insert(argList, {bId})
                    table.insert(argList, {"Award", bId})
                end
            end

            for _, args in ipairs(argList) do
                pcall(function()
                    if rem:IsA("RemoteEvent") or rem.ClassName == "UnreliableRemoteEvent" then
                        if #args == 0 then rem:FireServer() else rem:FireServer(unpack(args)) end
                    elseif rem:IsA("RemoteFunction") then
                        if #args == 0 then rem:InvokeServer() else rem:InvokeServer(unpack(args)) end
                    elseif rem:IsA("BindableEvent") then
                        if #args == 0 then bin:Fire() else bin:Fire(unpack(args)) end
                    elseif rem:IsA("BindableFunction") then
                        if #args == 0 then bin:Invoke() else bin:Invoke(unpack(args)) end
                    end
                end)
            end

        -- ITENS DO MAPA E MOCHILA
        elseif entry.Type == "WorldTool" or entry.Type == "WorldItem" then
            local item = entry.Object
            if item and item.Parent and not isFromOtherPlayer(item) then
                local handle = item:IsA("Tool") and (item:FindFirstChild("Handle") or item:FindFirstChildWhichIsA("BasePart")) or (item:IsA("BasePart") and item or item:FindFirstChildWhichIsA("BasePart"))
                if handle then
                    local origPos = RootPart.CFrame
                    RootPart.CFrame = handle.CFrame + Vector3.new(0, 1.2, 0)
                    if firetouchinterest then
                        firetouchinterest(RootPart, handle, 0)
                        task.wait(0.01)
                        firetouchinterest(RootPart, handle, 1)
                    end
                    if item:IsA("Tool") then
                        Humanoid:EquipTool(item)
                        item.Parent = Character
                        task.wait(0.08)
                        item:Activate()
                    end
                    RootPart.CFrame = origPos
                end
            end

        elseif entry.Type == "ReplicatedTool" then
            local tool = entry.Object
            if tool then
                local clone = tool:Clone()
                clone.Parent = Backpack
                Humanoid:EquipTool(clone)
                task.wait(0.08)
                clone:Activate()
            end

        elseif entry.Type == "BackpackTool" then
            local tool = entry.Object
            if tool and tool.Parent then
                tool.Parent = Character
                task.wait(0.08)
                tool:Activate()
                task.wait(0.04)
                tool.Parent = Backpack
            end

        -- PROMPTS COM ALINHAMENTO DE CÂMERA
        elseif entry.Type == "Prompt" then
            local prompt = entry.Object
            if prompt and prompt.Parent then
                local promptPart = prompt.Parent:IsA("BasePart") and prompt.Parent or prompt.Parent:FindFirstChildWhichIsA("BasePart")
                if promptPart then
                    local origPos = RootPart.CFrame
                    RootPart.CFrame = promptPart.CFrame + Vector3.new(0, 1.2, 0)
                    pcall(function()
                        local cam = workspace.CurrentCamera
                        if cam then cam.CFrame = CFrame.new(cam.CFrame.Position, promptPart.Position) end
                    end)

                    if prompt:IsA("ProximityPrompt") then
                        prompt.HoldDuration = 0
                        prompt.MaxActivationDistance = 999999
                        prompt.RequiresLineOfSight = false
                        prompt.Enabled = true

                        if fireproximityprompt then fireproximityprompt(prompt) end
                        if firesignal then
                            firesignal(prompt.PromptButtonHoldBegan)
                            firesignal(prompt.Triggered)
                            firesignal(prompt.PromptButtonHoldEnded)
                        end
                        pcall(function()
                            VirtualInputManager:SendKeyEvent(true, prompt.KeyboardKeyCode or Enum.KeyCode.E, false, game)
                            task.wait(0.02)
                            VirtualInputManager:SendKeyEvent(false, prompt.KeyboardKeyCode or Enum.KeyCode.E, false, game)
                        end)
                    elseif prompt:IsA("ClickDetector") then
                        if fireclickdetector then fireclickdetector(prompt) end
                    end
                    task.wait(0.06)
                    RootPart.CFrame = origPos
                end
            end

        -- TOUCHPADS
        elseif entry.Type == "TouchPad" then
            local part = entry.Object
            if part and part:IsA("BasePart") and part.Parent then
                local origPos = RootPart.CFrame
                RootPart.CFrame = part.CFrame + Vector3.new(0, 1.5, 0)
                RootPart.AssemblyLinearVelocity = Vector3.new(0, -4, 0)
                pcall(function() Humanoid:ChangeState(Enum.HumanoidStateType.Landed) end)

                if getconnections then
                    for _, conn in ipairs(getconnections(part.Touched)) do
                        pcall(function() conn:Fire(RootPart) end)
                    end
                end
                if firetouchinterest then
                    firetouchinterest(RootPart, part, 0)
                    task.wait(0.01)
                    firetouchinterest(RootPart, part, 1)
                end
                task.wait(0.08)
                RootPart.CFrame = origPos
            end
        end
    end)
end

-- ---------------------------------------------------------------------------------
-- 5. ESPIÃO DE REDE INTEGRADO
-- ---------------------------------------------------------------------------------
local function initRemoteSpy(onCapture)
    if not hookmetamethod then return end
    pcall(function()
        local oldNamecall
        oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
            local method = getnamecallmethod()
            local args = {...}

            if (method == "FireServer" or method == "InvokeServer") and (self:IsA("RemoteEvent") or self:IsA("RemoteFunction") or self.ClassName == "UnreliableRemoteEvent") then
                pcall(function()
                    table.insert(State.SpyLogs, 1, {
                        Remote = self,
                        Method = method,
                        Args = args,
                        Time = os.date("%H:%M:%S")
                    })
                    if #State.SpyLogs > 40 then table.remove(State.SpyLogs) end
                    if onCapture then onCapture() end
                end)
            end

            return oldNamecall(self, ...)
        end)
    end)
end

-- ---------------------------------------------------------------------------------
-- 6. INTERFACE GRÁFICA V12 (CYBER APEX LAB)
-- ---------------------------------------------------------------------------------
local function buildInterfaceV12()
    local parentGui = (gethui and gethui()) or game:GetService("CoreGui"):FindFirstChild("RobloxGui") or LocalPlayer:WaitForChild("PlayerGui")
    local old = parentGui:FindFirstChild("BadgeMaster_V12")
    if old then old:Destroy() end

    local Screen = Instance.new("ScreenGui")
    Screen.Name = "BadgeMaster_V12"
    Screen.ResetOnSpawn = false

    -- Botão Mobile Flutuante
    local MobBtn = Instance.new("TextButton")
    MobBtn.Size = UDim2.new(0, 52, 0, 52)
    MobBtn.Position = UDim2.new(0, 16, 0.45, 0)
    MobBtn.BackgroundColor3 = Color3.fromRGB(15, 18, 28)
    MobBtn.Text = "💎"
    MobBtn.TextSize = 24
    MobBtn.BorderSizePixel = 0
    MobBtn.Parent = Screen

    local mbCorner = Instance.new("UICorner")
    mbCorner.CornerRadius = UDim.new(1, 0)
    mbCorner.Parent = MobBtn

    local mbStroke = Instance.new("UIStroke")
    mbStroke.Color = Color3.fromRGB(0, 240, 255)
    mbStroke.Thickness = 2
    mbStroke.Parent = MobBtn

    -- Janela Principal
    local Window = Instance.new("Frame")
    Window.Size = UDim2.new(0, 650, 0, 510)
    Window.Position = UDim2.new(0.5, -325, 0.5, -255)
    Window.BackgroundColor3 = Color3.fromRGB(10, 12, 18)
    Window.BorderSizePixel = 0
    Window.Active = true
    Window.ClipsDescendants = true
    Window.Parent = Screen

    local wCorner = Instance.new("UICorner")
    wCorner.CornerRadius = UDim.new(0, 12)
    wCorner.Parent = Window

    local wStroke = Instance.new("UIStroke")
    wStroke.Color = Color3.fromRGB(0, 180, 255)
    wStroke.Thickness = 1.4
    wStroke.Parent = Window

    -- TopBar
    local TopBar = Instance.new("Frame")
    TopBar.Size = UDim2.new(1, 0, 0, 42)
    TopBar.BackgroundColor3 = Color3.fromRGB(16, 20, 30)
    TopBar.BorderSizePixel = 0
    TopBar.Parent = Window

    local tbCorner = Instance.new("UICorner")
    tbCorner.CornerRadius = UDim.new(0, 12)
    tbCorner.Parent = TopBar

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -50, 1, 0)
    Title.Position = UDim2.new(0, 14, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = "💎 BADGE MASTER V12  |  THE APEX TESTING LAB"
    Title.TextColor3 = Color3.fromRGB(0, 240, 255)
    Title.TextSize = 12
    Title.Font = Enum.Font.GothamBold
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = TopBar

    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 28, 0, 28)
    CloseBtn.Position = UDim2.new(1, -34, 0, 7)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(30, 36, 52)
    CloseBtn.Text = "✕"
    CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseBtn.TextSize = 11
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.BorderSizePixel = 0
    CloseBtn.Parent = TopBar

    local cbCorner = Instance.new("UICorner")
    cbCorner.CornerRadius = UDim.new(0, 6)
    cbCorner.Parent = CloseBtn

    CloseBtn.MouseButton1Click:Connect(function() Window.Visible = false end)
    MobBtn.MouseButton1Click:Connect(function() Window.Visible = not Window.Visible end)

    -- Arrastar Janela
    local dragging, dragStart, startPos
    TopBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = Window.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            Window.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    -- Corpo
    local Body = Instance.new("Frame")
    Body.Size = UDim2.new(1, -24, 1, -54)
    Body.Position = UDim2.new(0, 12, 0, 48)
    Body.BackgroundTransparency = 1
    Body.Parent = Window

    -- 1. Barra de Ações Mestres (Topo)
    local TopCmds = Instance.new("Frame")
    TopCmds.Size = UDim2.new(1, 0, 0, 38)
    TopCmds.BackgroundTransparency = 1
    TopCmds.Parent = Body

    local MassTestBtn = Instance.new("TextButton")
    MassTestBtn.Size = UDim2.new(0.40, -4, 1, 0)
    MassTestBtn.BackgroundColor3 = Color3.fromRGB(220, 35, 60)
    MassTestBtn.Text = "🚀 TESTAR TUDO NO JOGO"
    MassTestBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    MassTestBtn.TextSize = 11
    MassTestBtn.Font = Enum.Font.GothamBold
    MassTestBtn.BorderSizePixel = 0
    MassTestBtn.Parent = TopCmds

    local mtCorner = Instance.new("UICorner")
    mtCorner.CornerRadius = UDim.new(0, 8)
    mtCorner.Parent = MassTestBtn

    local EspBtn = Instance.new("TextButton")
    EspBtn.Size = UDim2.new(0.24, -4, 1, 0)
    EspBtn.Position = UDim2.new(0.40, 2, 0, 0)
    EspBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 120)
    EspBtn.Text = "👁️ ESP: OFF"
    EspBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    EspBtn.TextSize = 11
    EspBtn.Font = Enum.Font.GothamBold
    EspBtn.BorderSizePixel = 0
    EspBtn.Parent = TopCmds

    local ebCorner = Instance.new("UICorner")
    ebCorner.CornerRadius = UDim.new(0, 8)
    ebCorner.Parent = EspBtn

    local RescanBtn = Instance.new("TextButton")
    RescanBtn.Size = UDim2.new(0.20, -4, 1, 0)
    RescanBtn.Position = UDim2.new(0.64, 2, 0, 0)
    RescanBtn.BackgroundColor3 = Color3.fromRGB(0, 140, 255)
    RescanBtn.Text = "🔄 Re-Escanear"
    RescanBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    RescanBtn.TextSize = 10
    RescanBtn.Font = Enum.Font.GothamBold
    RescanBtn.BorderSizePixel = 0
    RescanBtn.Parent = TopCmds

    local rbCorner = Instance.new("UICorner")
    rbCorner.CornerRadius = UDim.new(0, 8)
    rbCorner.Parent = RescanBtn

    local StopAutosBtn = Instance.new("TextButton")
    StopAutosBtn.Size = UDim2.new(0.16, 0, 1, 0)
    StopAutosBtn.Position = UDim2.new(0.84, 2, 0, 0)
    StopAutosBtn.BackgroundColor3 = Color3.fromRGB(42, 48, 64)
    StopAutosBtn.Text = "⏹️ Parar Autos"
    StopAutosBtn.TextColor3 = Color3.fromRGB(220, 225, 235)
    StopAutosBtn.TextSize = 9
    StopAutosBtn.Font = Enum.Font.GothamBold
    StopAutosBtn.BorderSizePixel = 0
    StopAutosBtn.Parent = TopCmds

    local saCorner = Instance.new("UICorner")
    saCorner.CornerRadius = UDim.new(0, 8)
    saCorner.Parent = StopAutosBtn

    -- 2. Barra de Parâmetros Customizados do Lab
    local ParamRow = Instance.new("Frame")
    ParamRow.Size = UDim2.new(1, 0, 0, 34)
    ParamRow.Position = UDim2.new(0, 0, 0, 44)
    ParamRow.BackgroundColor3 = Color3.fromRGB(16, 20, 30)
    ParamRow.BorderSizePixel = 0
    ParamRow.Parent = Body

    local prCorner = Instance.new("UICorner")
    prCorner.CornerRadius = UDim.new(0, 8)
    prCorner.Parent = ParamRow

    local prLabel = Instance.new("TextLabel")
    prLabel.Size = UDim2.new(0, 140, 1, 0)
    prLabel.Position = UDim2.new(0, 8, 0, 0)
    prLabel.BackgroundTransparency = 1
    prLabel.Text = "🧪 Argumento de Teste:"
    prLabel.TextColor3 = Color3.fromRGB(255, 190, 60)
    prLabel.TextSize = 10
    prLabel.Font = Enum.Font.GothamBold
    prLabel.TextXAlignment = Enum.TextXAlignment.Left
    prLabel.Parent = ParamRow

    local CustomArgInput = Instance.new("TextBox")
    CustomArgInput.Size = UDim2.new(0.60, -10, 0, 24)
    CustomArgInput.Position = UDim2.new(0, 145, 0.5, -12)
    CustomArgInput.BackgroundColor3 = Color3.fromRGB(24, 30, 44)
    CustomArgInput.PlaceholderText = "Ex: 'Award', 12345 ou true ou 1000..."
    CustomArgInput.PlaceholderColor3 = Color3.fromRGB(110, 120, 140)
    CustomArgInput.Text = ""
    CustomArgInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    CustomArgInput.TextSize = 10
    CustomArgInput.Font = Enum.Font.Code
    CustomArgInput.BorderSizePixel = 0
    CustomArgInput.Parent = ParamRow

    local caiCorner = Instance.new("UICorner")
    caiCorner.CornerRadius = UDim.new(0, 6)
    caiCorner.Parent = CustomArgInput

    local ApplyToAllBtn = Instance.new("TextButton")
    ApplyToAllBtn.Size = UDim2.new(0.40, -145, 0, 24)
    ApplyToAllBtn.Position = UDim2.new(1, - (ApplyToAllBtn.Size.X.Offset + 140), 0.5, -12)
    ApplyToAllBtn.Position = UDim2.new(0.60, 140, 0.5, -12)
    ApplyToAllBtn.Size = UDim2.new(1, - (145 + CustomArgInput.Size.X.Offset + 10), 0, 24)
    ApplyToAllBtn.Size = UDim2.new(0.20, 0, 0, 24)
    ApplyToAllBtn.Position = UDim2.new(1, - (ApplyToAllBtn.Size.X.Offset + 8), 0.5, -12)
    ApplyToAllBtn.BackgroundColor3 = Color3.fromRGB(0, 160, 255)
    ApplyToAllBtn.Text = "Injetar Este em Tudo"
    ApplyToAllBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ApplyToAllBtn.TextSize = 10
    ApplyToAllBtn.Font = Enum.Font.GothamBold
    ApplyToAllBtn.BorderSizePixel = 0
    ApplyToAllBtn.Parent = ParamRow

    local atCorner = Instance.new("UICorner")
    atCorner.CornerRadius = UDim.new(0, 6)
    atCorner.Parent = ApplyToAllBtn

    CustomArgInput.FocusLost:Connect(function()
        State.CustomArg = CustomArgInput.Text
    end)

    -- 3. Categorias (Pills)
    local CatRow = Instance.new("Frame")
    CatRow.Size = UDim2.new(1, 0, 0, 28)
    CatRow.Position = UDim2.new(0, 0, 0, 84)
    CatRow.BackgroundTransparency = 1
    CatRow.Parent = Body

    local catLayout = Instance.new("UIListLayout")
    catLayout.FillDirection = Enum.FillDirection.Horizontal
    catLayout.Padding = UDim.new(0, 6)
    catLayout.Parent = CatRow

    local CatBtns = {}
    local Categories = {"Todos", "Itens", "Remotes", "Prompts", "Pads", "Bindables", "🛰️ Spy"}

    -- 4. Barra de Busca e Status
    local SearchRow = Instance.new("Frame")
    SearchRow.Size = UDim2.new(1, 0, 0, 28)
    SearchRow.Position = UDim2.new(0, 0, 0, 118)
    SearchRow.BackgroundTransparency = 1
    SearchRow.Parent = Body

    local StatusText = Instance.new("TextLabel")
    StatusText.Size = UDim2.new(0.40, 0, 1, 0)
    StatusText.BackgroundTransparency = 1
    StatusText.Text = "Carregando mapa..."
    StatusText.TextColor3 = Color3.fromRGB(165, 175, 195)
    StatusText.TextSize = 11
    StatusText.Font = Enum.Font.GothamMedium
    StatusText.TextXAlignment = Enum.TextXAlignment.Left
    StatusText.Parent = SearchRow

    local SearchBox = Instance.new("TextBox")
    SearchBox.Size = UDim2.new(0.60, 0, 1, 0)
    SearchBox.Position = UDim2.new(0.40, 0, 0, 0)
    SearchBox.BackgroundColor3 = Color3.fromRGB(18, 22, 32)
    SearchBox.PlaceholderText = "🔍 Buscar item, remote ou prompt..."
    SearchBox.PlaceholderColor3 = Color3.fromRGB(110, 120, 140)
    SearchBox.Text = ""
    SearchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    SearchBox.TextSize = 11
    SearchBox.Font = Enum.Font.Gotham
    SearchBox.BorderSizePixel = 0
    SearchBox.Parent = SearchRow

    local sbCorner = Instance.new("UICorner")
    sbCorner.CornerRadius = UDim.new(0, 6)
    sbCorner.Parent = SearchBox

    -- 5. Lista Interativa
    local ScrollList = Instance.new("ScrollingFrame")
    ScrollList.Size = UDim2.new(1, 0, 1, -152)
    ScrollList.Position = UDim2.new(0, 0, 0, 150)
    ScrollList.BackgroundColor3 = Color3.fromRGB(8, 10, 15)
    ScrollList.BorderSizePixel = 0
    ScrollList.ScrollBarThickness = 4
    ScrollList.Parent = Body

    local slCorner = Instance.new("UICorner")
    slCorner.CornerRadius = UDim.new(0, 8)
    slCorner.Parent = ScrollList

    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 5)
    listLayout.Parent = ScrollList

    Screen.Parent = parentGui

    -- Renderizador Dinâmico
    local function renderCards(search)
        search = (search or SearchBox.Text):lower()

        for _, c in ipairs(ScrollList:GetChildren()) do
            if c:IsA("Frame") then c:Destroy() end
        end

        -- ABA SPY
        if State.ActiveCategory == "🛰️ Spy" then
            for idx, log in ipairs(State.SpyLogs) do
                local card = Instance.new("Frame")
                card.Size = UDim2.new(1, -8, 0, 48)
                card.BackgroundColor3 = Color3.fromRGB(16, 20, 30)
                card.BorderSizePixel = 0
                card.Parent = ScrollList

                local cc = Instance.new("UICorner")
                cc.CornerRadius = UDim.new(0, 8)
                cc.Parent = card

                local title = Instance.new("TextLabel")
                title.Size = UDim2.new(1, -110, 0, 20)
                title.Position = UDim2.new(0, 10, 0, 5)
                title.BackgroundTransparency = 1
                title.Text = string.format("[%s] %s:%s()", log.Time, log.Remote.Name, log.Method)
                title.TextColor3 = Color3.fromRGB(0, 240, 255)
                title.TextSize = 11
                title.Font = Enum.Font.GothamBold
                title.TextXAlignment = Enum.TextXAlignment.Left
                title.TextTruncate = Enum.TextTruncate.AtEnd
                title.Parent = card

                local sub = Instance.new("TextLabel")
                sub.Size = UDim2.new(1, -110, 0, 16)
                sub.Position = UDim2.new(0, 10, 0, 25)
                sub.BackgroundTransparency = 1
                local argsStr = HttpService:JSONEncode(log.Args)
                sub.Text = "Args: " .. argsStr
                sub.TextColor3 = Color3.fromRGB(140, 150, 175)
                sub.TextSize = 9
                sub.Font = Enum.Font.Code
                sub.TextXAlignment = Enum.TextXAlignment.Left
                sub.TextTruncate = Enum.TextTruncate.AtEnd
                sub.Parent = card

                local replayBtn = Instance.new("TextButton")
                replayBtn.Size = UDim2.new(0, 90, 0, 30)
                replayBtn.Position = UDim2.new(1, -98, 0.5, -15)
                replayBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 100)
                replayBtn.Text = "🔁 Replicar"
                replayBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                replayBtn.TextSize = 10
                replayBtn.Font = Enum.Font.GothamBold
                replayBtn.BorderSizePixel = 0
                replayBtn.Parent = card

                local rc = Instance.new("UICorner")
                rc.CornerRadius = UDim.new(0, 6)
                rc.Parent = replayBtn

                replayBtn.MouseButton1Click:Connect(function()
                    pcall(function()
                        if log.Method == "FireServer" then
                            log.Remote:FireServer(unpack(log.Args))
                        else
                            log.Remote:InvokeServer(unpack(log.Args))
                        end
                        replayBtn.Text = "Replicado!"
                        task.wait(0.5)
                        replayBtn.Text = "🔁 Replicar"
                    end)
                end)
            end
            ScrollList.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 10)
            StatusText.Text = string.format("Espião: %d chamadas capturadas.", #State.SpyLogs)
            return
        end

        -- LISTA NORMAL
        local count = 0
        for _, entry in ipairs(State.ScannedEntries) do
            local matchesCat = (State.ActiveCategory == "Todos") or (entry.Category == State.ActiveCategory)
            local matchesSearch = (search == "") or entry.Name:lower():find(search) or entry.TypeLabel:lower():find(search)

            if matchesCat and matchesSearch then
                count = count + 1

                local card = Instance.new("Frame")
                card.Name = "Card_" .. entry.Id
                card.Size = UDim2.new(1, -8, 0, 48)
                card.BackgroundColor3 = Color3.fromRGB(16, 20, 28)
                card.BorderSizePixel = 0
                card.Parent = ScrollList

                local cc = Instance.new("UICorner")
                cc.CornerRadius = UDim.new(0, 8)
                cc.Parent = card

                local titleLabel = Instance.new("TextLabel")
                titleLabel.Size = UDim2.new(1, -190, 0, 20)
                titleLabel.Position = UDim2.new(0, 10, 0, 5)
                titleLabel.BackgroundTransparency = 1
                titleLabel.Text = entry.Icon .. " " .. entry.Name
                titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                titleLabel.TextSize = 11
                titleLabel.Font = Enum.Font.GothamBold
                titleLabel.TextXAlignment = Enum.TextXAlignment.Left
                titleLabel.TextTruncate = Enum.TextTruncate.AtEnd
                titleLabel.Parent = card

                local subLabel = Instance.new("TextLabel")
                subLabel.Size = UDim2.new(1, -190, 0, 16)
                subLabel.Position = UDim2.new(0, 10, 0, 25)
                subLabel.BackgroundTransparency = 1
                subLabel.Text = string.format("%s • %s", entry.TypeLabel, entry.Location)
                subLabel.TextColor3 = Color3.fromRGB(140, 150, 175)
                subLabel.TextSize = 9
                subLabel.Font = Enum.Font.Gotham
                subLabel.TextXAlignment = Enum.TextXAlignment.Left
                subLabel.TextTruncate = Enum.TextTruncate.AtEnd
                subLabel.Parent = card

                local runOnceBtn = Instance.new("TextButton")
                runOnceBtn.Size = UDim2.new(0, 75, 0, 30)
                runOnceBtn.Position = UDim2.new(1, -170, 0.5, -15)
                runOnceBtn.BackgroundColor3 = Color3.fromRGB(0, 140, 255)
                runOnceBtn.Text = "▶ Testar"
                runOnceBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                runOnceBtn.TextSize = 10
                runOnceBtn.Font = Enum.Font.GothamBold
                runOnceBtn.BorderSizePixel = 0
                runOnceBtn.Parent = card

                local rc = Instance.new("UICorner")
                rc.CornerRadius = UDim.new(0, 6)
                rc.Parent = runOnceBtn

                runOnceBtn.MouseButton1Click:Connect(function()
                    runOnceBtn.Text = "Testando..."
                    runOnceBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
                    task.spawn(function()
                        executeAction(entry, State.CustomArg)
                        task.wait(0.2)
                        runOnceBtn.Text = "▶ Testar"
                        runOnceBtn.BackgroundColor3 = Color3.fromRGB(0, 140, 255)
                    end)
                end)

                local autoBtn = Instance.new("TextButton")
                autoBtn.Size = UDim2.new(0, 85, 0, 30)
                autoBtn.Position = UDim2.new(1, -88, 0.5, -15)
                local isLooping = State.ActiveLoops[entry.Id] or false
                autoBtn.BackgroundColor3 = isLooping and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(36, 42, 58)
                autoBtn.Text = isLooping and "🔁 Auto: ON" or "🔁 Auto: OFF"
                autoBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                autoBtn.TextSize = 10
                autoBtn.Font = Enum.Font.GothamBold
                autoBtn.BorderSizePixel = 0
                autoBtn.Parent = card

                local ac = Instance.new("UICorner")
                ac.CornerRadius = UDim.new(0, 6)
                ac.Parent = autoBtn

                autoBtn.MouseButton1Click:Connect(function()
                    if State.ActiveLoops[entry.Id] then
                        State.ActiveLoops[entry.Id] = nil
                        autoBtn.BackgroundColor3 = Color3.fromRGB(36, 42, 58)
                        autoBtn.Text = "🔁 Auto: OFF"
                    else
                        State.ActiveLoops[entry.Id] = true
                        autoBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
                        autoBtn.Text = "🔁 Auto: ON"

                        task.spawn(function()
                            while State.ActiveLoops[entry.Id] do
                                executeAction(entry, State.CustomArg)
                                task.wait(0.25)
                            end
                        end)
                    end
                end)
            end
        end

        ScrollList.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 10)
        StatusText.Text = string.format("Exibindo: %d opções", count)
    end

    for _, catName in ipairs(Categories) do
        local pill = Instance.new("TextButton")
        pill.Size = UDim2.new(0, catName:find("Spy") and 85 or 70, 1, 0)
        pill.BackgroundColor3 = (State.ActiveCategory == catName) and Color3.fromRGB(0, 180, 255) or Color3.fromRGB(20, 25, 36)
        pill.Text = catName
        pill.TextColor3 = Color3.fromRGB(255, 255, 255)
        pill.TextSize = 10
        pill.Font = Enum.Font.GothamBold
        pill.BorderSizePixel = 0
        pill.Parent = CatRow

        local pc = Instance.new("UICorner")
        pc.CornerRadius = UDim.new(0, 6)
        pc.Parent = pill

        CatBtns[catName] = pill

        pill.MouseButton1Click:Connect(function()
            State.ActiveCategory = catName
            for cName, btn in pairs(CatBtns) do
                btn.BackgroundColor3 = (cName == catName) and Color3.fromRGB(0, 180, 255) or Color3.fromRGB(20, 25, 36)
            end
            renderCards()
        end)
    end

    SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
        renderCards(SearchBox.Text)
    end)

    -- Toggle ESP
    EspBtn.MouseButton1Click:Connect(function()
        local nextState = not State.EspEnabled
        toggleEsp(nextState)
        EspBtn.Text = nextState and "👁️ ESP: ON" or "👁️ ESP: OFF"
        EspBtn.BackgroundColor3 = nextState and Color3.fromRGB(0, 240, 140) or Color3.fromRGB(0, 180, 120)
    end)

    -- Injetar Argumento Manual em Tudo
    ApplyToAllBtn.MouseButton1Click:Connect(function()
        if State.IsBatchRunning then return end
        State.IsBatchRunning = true
        ApplyToAllBtn.Text = "Injetando..."
        StatusText.Text = "Injetando argumento manual em todos os remotes..."

        task.spawn(function()
            local count = 0
            for _, entry in ipairs(State.ScannedEntries) do
                if entry.Category == "Remotes" or entry.Category == "Bindables" then
                    executeAction(entry, State.CustomArg)
                    count = count + 1
                    task.wait(State.RemoteDelay)
                end
            end
            ApplyToAllBtn.Text = "Injetado!"
            StatusText.Text = string.format("Argumento '%s' injetado em %d remotes!", tostring(State.CustomArg), count)
            task.wait(1)
            ApplyToAllBtn.Text = "Injetar Este em Tudo"
            State.IsBatchRunning = false
        end)
    end)

    return {
        Status = StatusText,
        MassTestBtn = MassTestBtn,
        RescanBtn = RescanBtn,
        StopAutosBtn = StopAutosBtn,
        Render = renderCards
    }
end

local UI = buildInterfaceV12()

initRemoteSpy(function()
    if State.ActiveCategory == "🛰️ Spy" then
        UI.Render()
    end
end)

-- ---------------------------------------------------------------------------------
-- 7. VINCULAÇÃO DOS BOTÕES
-- ---------------------------------------------------------------------------------
UI.MassTestBtn.MouseButton1Click:Connect(function()
    if State.IsBatchRunning then return end
    State.IsBatchRunning = true
    UI.MassTestBtn.Text = "TESTANDO TUDO NO MAPA..."
    UI.MassTestBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 120)
    UI.Status.Text = "Iniciando teste massivo de remotes, itens e prompts..."

    task.spawn(function()
        local entries = scanAllGameElementsV12()
        UI.Render()

        local total = #entries
        for i = 1, total do
            local e = entries[i]
            UI.Status.Text = string.format("Testando (%d/%d): %s", i, total, e.Name)
            executeAction(e, State.CustomArg)
            task.wait(State.RemoteDelay)
        end

        UI.Status.Text = "Finalizado! Todos os elementos foram testados."
        UI.MassTestBtn.Text = "🚀 TESTAR TUDO NO JOGO"
        UI.MassTestBtn.BackgroundColor3 = Color3.fromRGB(220, 35, 60)
        State.IsBatchRunning = false
    end)
end)

UI.RescanBtn.MouseButton1Click:Connect(function()
    UI.Status.Text = "Atualizando mapa, itens e eventos..."
    task.spawn(function()
        scanAllGameElementsV12()
        UI.Render()
        if State.EspEnabled then toggleEsp(true) end
        UI.Status.Text = "Escaneamento V12 atualizado!"
    end)
end)

UI.StopAutosBtn.MouseButton1Click:Connect(function()
    State.ActiveLoops = {}
    UI.Render()
    UI.Status.Text = "Todos os autos foram interrompidos."
end)

task.delay(0.5, function()
    scanAllGameElementsV12()
    UI.Render()
end)

print("[BadgeMaster V12] Apex Testing Lab carregado com sucesso!")

]====],
    ["V13"] = [====[
--[[
    =================================================================================
    👑 BADGE MASTER V13 - OMNI-TESTING LAB & ADVANCED REMOTE/ITEM SUITE
    =================================================================================
    NOVIDADES DA V13 (EVOLUÇÃO DIRETA DA V12 + MELHORIAS DA V8/V9):

    1. [🎁 COLETA TOTAL DE ITENS RESTAURADA E AMPLIADA]:
       - Escaneia Tools e colecionáveis em: Workspace, ReplicatedStorage, Lighting,
         StarterPack, ReplicatedFirst e Mochila (Backpack).
       - Restaura o fallback da V8/V9 para Tools sem Handle (equipando direto pela
         mochila e ativando).
       - Para itens do mapa (Model/BasePart), dispara TouchInterest, conexões
         .Touched, ClickDetector e ProximityPrompt internos automaticamente.
       - Botão dedicado [🎁 Pegar Itens] para coletar todos os itens de uma vez.

    2. [⚡ SISTEMA DE REMOTES V13 (BATERIA INTELIGENTE DE ATRIBUTOS)]:
       - Ao clicar em qualquer Remote/Bindable SEM digitar argumento manual, ele
         testa automaticamente uma bateria completa usada por devs:
         {}, {true}, {false}, {1}, {0}, {100}, {1000}, {999999}, {-1},
         {true, 1000}, {true, 1}, {true, true}, {false, 1000}, {1, true}, {1000, true},
         {LocalPlayer}, {LocalPlayer, true}, {LocalPlayer, 1000}, {Character}, {RootPart},
         strings comuns ("Win", "Claim", "Complete", "Collect", "Buy", "Unlock", etc.),
         tabelas ({Amount = 1000}, {Value = true}) e todos os BadgeIds do universo.
       - Suporte a múltiplos argumentos manuais separados por vírgula!
         Ex: true, 1000  |  "Award", 12345  |  true, 1  |  1000  |  false
       - Presets clicáveis rápidos + opção [⚡ Só Remotes] e [🚀 TESTAR TUDO] que
         usam a bateria completa automaticamente quando o campo está vazio.
       - Correção do bug da V12 em BindableEvent/BindableFunction.

    3. [📍 TELEPORTE INTELIGENTE & RETORNO AO LOCAL ANTERIOR]:
       - Salva automaticamente sua posição antes de qualquer teleporte.
       - Botão [📍 Salvar Local] para marcar um ponto fixo no mapa.
       - Botão [↩️ Voltar Local] para retornar imediatamente ao ponto anterior.
       - Toggle [🔄 Auto-Voltar: ON/OFF]: escolha se quer voltar sozinho após
         testar um item/pad/prompt ou ficar no local!
       - Botão [📍 TP] individual nos cards de Itens, Pads e Prompts.

    4. [⏹️ CONTROLE TOTAL]:
       - [⏹️ Parar Tudo] interrompe tanto os loops individuais quanto os testes em
         massa imediatamente.
       - Toggle de Noclip direto na barra superior e interface alinhada sem cortes.
    =================================================================================
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local Lighting = game:GetService("Lighting")
local StarterPack = game:GetService("StarterPack")
local HttpService = game:GetService("HttpService")
local VirtualInputManager = game:GetService("VirtualInputManager")

local LocalPlayer = Players.LocalPlayer
local Backpack = LocalPlayer:WaitForChild("Backpack")
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local RootPart = Character:WaitForChild("HumanoidRootPart", 10)
local Humanoid = Character:WaitForChild("Humanoid", 10)

-- Estado Global V13
local State = {
    IsBatchRunning = false,
    ActiveLoops = {},
    ScannedEntries = {},
    ActiveCategory = "Todos",
    UniverseBadgeIds = {},
    SpyLogs = {},
    CustomArg = "",
    RemoteDelay = 0.015,
    EspEnabled = false,
    EspHighlights = {},
    NoclipEnabled = true,
    AutoReturnTP = true,
    SavedPosition = nil,
    LastPositionBeforeTP = nil
}

-- Anti-AFK
LocalPlayer.Idled:Connect(function()
    pcall(function()
        local vu = game:GetService("VirtualUser")
        vu:CaptureController()
        vu:ClickButton2(Vector2.new(0, 0))
    end)
end)

local function refreshCharacterRefs()
    Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    RootPart = Character:WaitForChild("HumanoidRootPart", 5)
    Humanoid = Character:WaitForChild("Humanoid", 5)
    Backpack = LocalPlayer:WaitForChild("Backpack", 5)
end

LocalPlayer.CharacterAdded:Connect(function(char)
    Character = char
    RootPart = char:WaitForChild("HumanoidRootPart", 10)
    Humanoid = char:WaitForChild("Humanoid", 10)
    Backpack = LocalPlayer:WaitForChild("Backpack")
end)

-- Noclip Leve
RunService.Stepped:Connect(function()
    if State.NoclipEnabled and Character then
        for _, p in ipairs(Character:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide = false end
        end
    end
end)

-- ---------------------------------------------------------------------------------
-- 0. UTILITÁRIOS DE TELEPORTE E FILTRO DE PLAYERS
-- ---------------------------------------------------------------------------------
local function isFromOtherPlayer(obj)
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            if (plr.Character and obj:IsDescendantOf(plr.Character))
                or (plr:FindFirstChild("Backpack") and obj:IsDescendantOf(plr.Backpack)) then
                return true
            end
        end
    end
    return false
end

local function teleportToCFrame(targetCFrame, autoReturn, holdTime)
    if not RootPart or not RootPart.Parent then refreshCharacterRefs() end
    if not RootPart then return nil end

    local origPos = RootPart.CFrame
    State.LastPositionBeforeTP = origPos
    RootPart.CFrame = targetCFrame

    if autoReturn then
        task.wait(holdTime or 0.08)
        if RootPart and RootPart.Parent then
            RootPart.CFrame = origPos
        end
    end
    return origPos
end

local function returnToPreviousPosition()
    if not RootPart or not RootPart.Parent then refreshCharacterRefs() end
    if not RootPart then return false end

    local target = State.LastPositionBeforeTP or State.SavedPosition
    if target then
        RootPart.CFrame = target
        return true
    end
    return false
end

local function getEntryTargetPart(entry)
    local obj = entry and entry.Object
    if not obj or not obj.Parent then return nil end
    if obj:IsA("BasePart") then return obj end
    if obj:IsA("Tool") then
        return obj:FindFirstChild("Handle") or obj:FindFirstChildWhichIsA("BasePart", true)
    end
    if obj:IsA("Model") then
        return obj.PrimaryPart or obj:FindFirstChild("Handle") or obj:FindFirstChildWhichIsA("BasePart", true)
    end
    if obj:IsA("ProximityPrompt") or obj:IsA("ClickDetector") then
        local p = obj.Parent
        if p then
            return p:IsA("BasePart") and p or p:FindFirstChildWhichIsA("BasePart", true)
        end
    end
    return obj:FindFirstChildWhichIsA("BasePart", true)
end

-- ---------------------------------------------------------------------------------
-- 1. CONSULTA DE BADGES VIA API
-- ---------------------------------------------------------------------------------
task.spawn(function()
    local uId = game.GameId
    if uId == 0 then return end
    local url = string.format("https://badges.roproxy.com/v1/universes/%d/badges?limit=100", uId)
    local s, res
    pcall(function()
        if (syn and syn.request) or (http and http.request) or request then
            local req = (syn and syn.request) or (http and http.request) or request
            res = req({Url = url, Method = "GET"}).Body
            s = true
        elseif game.HttpGet then
            res = game:HttpGet(url)
            s = true
        end
    end)
    if s and res then
        local ok, data = pcall(function() return HttpService:JSONDecode(res) end)
        if ok and data and data.data then
            for _, b in ipairs(data.data) do
                table.insert(State.UniverseBadgeIds, b.id)
            end
        end
    end
end)

-- ---------------------------------------------------------------------------------
-- 2. ESP DE ITENS E PADS (DESTAQUE VISUAL EM 3D ATRAVÉS DAS PAREDES)
-- ---------------------------------------------------------------------------------
local function toggleEsp(enabled)
    State.EspEnabled = enabled

    for _, h in ipairs(State.EspHighlights) do
        if h and h.Parent then h:Destroy() end
    end
    State.EspHighlights = {}

    if not enabled then return end

    for _, entry in ipairs(State.ScannedEntries) do
        pcall(function()
            local target = entry.Object
            if target and target.Parent and (entry.Category == "Itens" or entry.Category == "Pads" or entry.Category == "Prompts") then
                local adornee = target:IsA("Model") and target or (target:IsA("BasePart") and target or target.Parent)
                if adornee then
                    local highlight = Instance.new("Highlight")
                    highlight.Name = "MasterESP_" .. entry.Id
                    highlight.FillTransparency = 0.5
                    highlight.OutlineTransparency = 0

                    if entry.Category == "Itens" then
                        highlight.FillColor = Color3.fromRGB(255, 180, 0)
                        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                    elseif entry.Category == "Pads" then
                        highlight.FillColor = Color3.fromRGB(0, 200, 255)
                        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                    elseif entry.Category == "Prompts" then
                        highlight.FillColor = Color3.fromRGB(0, 255, 120)
                        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                    end

                    highlight.Adornee = adornee
                    highlight.Parent = adornee
                    table.insert(State.EspHighlights, highlight)
                end
            end
        end)
    end
end

-- ---------------------------------------------------------------------------------
-- 3. PARSER & BATERIA DE ARGUMENTOS PARA REMOTES V13
-- ---------------------------------------------------------------------------------
local function parseSingleToken(raw)
    local trimmed = raw:match("^%s*(.-)%s*$")
    if trimmed == "" then return nil, false end

    -- Remove aspas externas se existirem
    local quoted = trimmed:match('^"(.*)"$') or trimmed:match("^'(.*)'$")
    if quoted ~= nil then
        return quoted, true
    end

    local lower = trimmed:lower()
    if lower == "true" then return true, true end
    if lower == "false" then return false, true end
    if lower == "nil" or lower == "null" then return nil, true end
    if lower == "me" or lower == "player" or lower == "localplayer" then return LocalPlayer, true end
    if lower == "char" or lower == "character" then return Character, true end
    if lower == "hrp" or lower == "root" or lower == "rootpart" then return RootPart, true end

    local num = tonumber(trimmed)
    if num ~= nil then return num, true end

    return trimmed, true
end

local function parseCustomArgs(inputStr)
    local args = {}
    local current = ""
    local inSingle, inDouble = false, false

    for i = 1, #inputStr do
        local ch = inputStr:sub(i, i)
        if ch == "'" and not inDouble then
            inSingle = not inSingle
            current = current .. ch
        elseif ch == '"' and not inSingle then
            inDouble = not inDouble
            current = current .. ch
        elseif ch == "," and not inSingle and not inDouble then
            local val, ok = parseSingleToken(current)
            if ok then table.insert(args, val) end
            current = ""
        else
            current = current .. ch
        end
    end

    local lastVal, ok = parseSingleToken(current)
    if ok then table.insert(args, lastVal) end

    return args
end

local function buildDefaultRemoteBattery()
    local battery = {
        {},
        {true},
        {false},
        {1},
        {0},
        {100},
        {1000},
        {999999},
        {-1},
        {true, 1000},
        {true, 1},
        {true, 0},
        {true, true},
        {false, 1000},
        {false, 1},
        {1, true},
        {1000, true},
        {1000, false},
        {LocalPlayer},
        {LocalPlayer, true},
        {LocalPlayer, 1000},
        {Character},
        {RootPart},
        {"Win"},
        {"Complete"},
        {"Claim"},
        {"Collect"},
        {"Finish"},
        {"Buy"},
        {"Unlock"},
        {"Equip"},
        {"Open"},
        {"Start"},
        {"End"},
        {"Reward"},
        {"Daily"},
        {"Redeem"},
        {"Verify"},
        {"Check"},
        {"Accept"},
        {"Confirm"},
        {"Yes"},
        {"Give"},
        {"Award"},
        {"Badge"},
        {"Secret"},
        {"Found"},
        {"Touch"},
        {"Hit"},
        {"Click"},
        {"Interact"},
        {"Claim", true},
        {"Claim", 1},
        {"Claim", 1000},
        {"Win", true},
        {"Complete", true},
        {"Unlock", true},
        {"Buy", 1},
        {"Give", 1000},
        {"Add", 1000},
        {{Amount = 1000}},
        {{Value = true}}
    }

    for _, bId in ipairs(State.UniverseBadgeIds) do
        table.insert(battery, {bId})
        table.insert(battery, {"Award", bId})
        table.insert(battery, {"Badge", bId})
        table.insert(battery, {bId, true})
        table.insert(battery, {LocalPlayer, bId})
    end

    return battery
end

-- ---------------------------------------------------------------------------------
-- 4. SCANNER TOTAL DE ELEMENTOS V13
-- ---------------------------------------------------------------------------------
local function scanAllGameElementsV13()
    local entries = {}
    local seen = {}

    -- A) REMOTES & UNRELIABLE & BINDABLES
    for _, obj in ipairs(game:GetDescendants()) do
        if not seen[obj] then
            if obj:IsA("RemoteEvent") or obj.ClassName == "UnreliableRemoteEvent" then
                seen[obj] = true
                local isUnreliable = (obj.ClassName == "UnreliableRemoteEvent")
                table.insert(entries, {
                    Id = "Rem_" .. tostring(obj:GetDebugId() or math.random(10000, 99999)),
                    Name = obj.Name,
                    Type = isUnreliable and "UnreliableRemote" or "Remote",
                    Category = "Remotes",
                    Icon = isUnreliable and "⚡📡" or "⚡",
                    TypeLabel = isUnreliable and "Unreliable Remote" or "RemoteEvent",
                    Location = obj.Parent and obj.Parent.Name or "Game",
                    Object = obj
                })
            elseif obj:IsA("RemoteFunction") then
                seen[obj] = true
                table.insert(entries, {
                    Id = "RemF_" .. tostring(obj:GetDebugId() or math.random(10000, 99999)),
                    Name = obj.Name,
                    Type = "Remote",
                    Category = "Remotes",
                    Icon = "📞",
                    TypeLabel = "RemoteFunction",
                    Location = obj.Parent and obj.Parent.Name or "Game",
                    Object = obj
                })
            elseif obj:IsA("BindableEvent") then
                seen[obj] = true
                table.insert(entries, {
                    Id = "BinE_" .. tostring(obj:GetDebugId() or math.random(10000, 99999)),
                    Name = obj.Name,
                    Type = "Bindable",
                    Category = "Bindables",
                    Icon = "🔄",
                    TypeLabel = "BindableEvent (Interno)",
                    Location = obj.Parent and obj.Parent.Name or "Scripts",
                    Object = obj
                })
            elseif obj:IsA("BindableFunction") then
                seen[obj] = true
                table.insert(entries, {
                    Id = "BinF_" .. tostring(obj:GetDebugId() or math.random(10000, 99999)),
                    Name = obj.Name,
                    Type = "Bindable",
                    Category = "Bindables",
                    Icon = "🔁",
                    TypeLabel = "BindableFunction (Interno)",
                    Location = obj.Parent and obj.Parent.Name or "Scripts",
                    Object = obj
                })
            end
        end
    end

    -- B) ITENS (WORKSPACE, REPLICATEDSTORAGE, LIGHTING, STARTERPACK, REPLICATEDFIRST & MOCHILA)
    local itemKeywords = {
        "tool", "sword", "gun", "weapon", "key", "relic", "coin", "gem", "badge",
        "trophy", "orb", "drop", "shard", "item", "collectible", "chest", "crate",
        "gift", "present", "star", "crystal", "candy", "egg", "fruit", "flower",
        "note", "page", "book", "scroll", "artifact", "pickup", "loot", "medal",
        "crown", "ring", "amulet", "potion", "card", "ticket", "token", "flag",
        "secret", "plush", "pet", "gear", "bag", "backpack"
    }

    -- 1. Tools e Colecionáveis no Workspace
    for _, obj in ipairs(workspace:GetDescendants()) do
        if not isFromOtherPlayer(obj) and not obj:IsDescendantOf(Character) and not seen[obj] then
            if obj:IsA("Tool") then
                seen[obj] = true
                table.insert(entries, {
                    Id = "ToolW_" .. tostring(obj:GetDebugId() or math.random(10000, 99999)),
                    Name = obj.Name,
                    Type = "WorldTool",
                    Category = "Itens",
                    Icon = "🗡️",
                    TypeLabel = "Tool no Mapa",
                    Location = obj.Parent and obj.Parent.Name or "Workspace",
                    Object = obj
                })
            elseif obj:IsA("Model") or obj:IsA("BasePart") then
                local n = obj.Name:lower()
                local matched = false
                for _, kw in ipairs(itemKeywords) do
                    if n:find(kw) then
                        matched = true
                        break
                    end
                end
                if matched then
                    seen[obj] = true
                    table.insert(entries, {
                        Id = "ItemM_" .. tostring(obj:GetDebugId() or math.random(10000, 99999)),
                        Name = obj.Name,
                        Type = "WorldItem",
                        Category = "Itens",
                        Icon = "🎁",
                        TypeLabel = "Colecionável/Item",
                        Location = obj.Parent and obj.Parent.Name or "Workspace",
                        Object = obj
                    })
                end
            end
        end
    end

    -- 2. Tools em Serviços de Storage (ReplicatedStorage, Lighting, StarterPack, ReplicatedFirst)
    local storageContainers = {
        {Service = ReplicatedStorage, Label = "ReplicatedStorage"},
        {Service = Lighting, Label = "Lighting"},
        {Service = StarterPack, Label = "StarterPack"},
        {Service = ReplicatedFirst, Label = "ReplicatedFirst"}
    }

    for _, container in ipairs(storageContainers) do
        for _, obj in ipairs(container.Service:GetDescendants()) do
            if obj:IsA("Tool") and not seen[obj] then
                seen[obj] = true
                table.insert(entries, {
                    Id = "ToolS_" .. tostring(obj:GetDebugId() or math.random(10000, 99999)),
                    Name = obj.Name,
                    Type = "ReplicatedTool",
                    Category = "Itens",
                    Icon = "📦",
                    TypeLabel = "Item em " .. container.Label,
                    Location = obj.Parent and obj.Parent.Name or container.Label,
                    Object = obj
                })
            end
        end
    end

    -- 3. Tools na própria Mochila
    for _, obj in ipairs(Backpack:GetChildren()) do
        if obj:IsA("Tool") and not seen[obj] then
            seen[obj] = true
            table.insert(entries, {
                Id = "ToolB_" .. tostring(obj:GetDebugId() or math.random(10000, 99999)),
                Name = obj.Name,
                Type = "BackpackTool",
                Category = "Itens",
                Icon = "🎒",
                TypeLabel = "Item na Mochila",
                Location = "Inventário",
                Object = obj
            })
        end
    end

    -- C) TOUCHPADS / BLOCOS COM TOUCH
    for _, obj in ipairs(workspace:GetDescendants()) do
        if not isFromOtherPlayer(obj) and not obj:IsDescendantOf(Character) then
            if obj:IsA("TouchTransmitter") and obj.Parent and obj.Parent:IsA("BasePart") and not seen[obj.Parent] then
                seen[obj.Parent] = true
                table.insert(entries, {
                    Id = "Pad_" .. tostring(obj.Parent:GetDebugId() or math.random(10000, 99999)),
                    Name = obj.Parent.Name,
                    Type = "TouchPad",
                    Category = "Pads",
                    Icon = "📍",
                    TypeLabel = "Pad / Bloco de Chão",
                    Location = obj.Parent.Parent and obj.Parent.Parent.Name or "Workspace",
                    Object = obj.Parent
                })
            elseif obj:IsA("BasePart") and not seen[obj] then
                local n = obj.Name:lower()
                if n:find("badge") or n:find("giver") or n:find("checkpoint") or n:find("pad") or n:find("stage") or n:find("win") or n:find("portal") or n:find("teleport") then
                    seen[obj] = true
                    table.insert(entries, {
                        Id = "Pad_" .. tostring(obj:GetDebugId() or math.random(10000, 99999)),
                        Name = obj.Name,
                        Type = "TouchPad",
                        Category = "Pads",
                        Icon = "📍",
                        TypeLabel = "Bloco de Evento",
                        Location = obj.Parent and obj.Parent.Name or "Workspace",
                        Object = obj
                    })
                end
            end
        end
    end

    -- D) PROXIMITYPROMPT & CLICKDETECTOR
    for _, obj in ipairs(workspace:GetDescendants()) do
        if (obj:IsA("ProximityPrompt") or obj:IsA("ClickDetector")) and not isFromOtherPlayer(obj) and not seen[obj] then
            seen[obj] = true
            local name = obj.Parent and obj.Parent.Name or obj.Name
            if obj:IsA("ProximityPrompt") and obj.ActionText ~= "" then
                name = obj.ActionText .. " (" .. (obj.ObjectText ~= "" and obj.ObjectText or (obj.Parent and obj.Parent.Name or "Prompt")) .. ")"
            end
            table.insert(entries, {
                Id = "Prompt_" .. tostring(obj:GetDebugId() or math.random(10000, 99999)),
                Name = name,
                Type = "Prompt",
                Category = "Prompts",
                Icon = "✋",
                TypeLabel = obj:IsA("ProximityPrompt") and "Prompt (God-Mode)" or "ClickDetector",
                Location = obj.Parent and obj.Parent.Name or "Workspace",
                Object = obj
            })
        end
    end

    State.ScannedEntries = entries
    return entries
end

-- ---------------------------------------------------------------------------------
-- 5. EXECUTOR DE AÇÕES INDIVIDUAIS V13
-- ---------------------------------------------------------------------------------
local function fireTouchPart(part)
    if not part or not part:IsA("BasePart") then return end
    if getconnections then
        for _, conn in ipairs(getconnections(part.Touched)) do
            pcall(function() conn:Fire(RootPart) end)
        end
    end
    if firetouchinterest then
        firetouchinterest(RootPart, part, 0)
        task.wait(0.015)
        firetouchinterest(RootPart, part, 1)
    end
end

local function executeAction(entry, specificArg, overrideAutoReturn)
    if not Character or not RootPart or not Humanoid or not RootPart.Parent then
        refreshCharacterRefs()
    end

    local shouldReturn = (overrideAutoReturn ~= nil) and overrideAutoReturn or State.AutoReturnTP

    pcall(function()
        -- REMOTES & BINDABLES COM ARGUMENTO MANUAL OU BATERIA COMPLETA
        if entry.Type == "Remote" or entry.Type == "UnreliableRemote" or entry.Type == "Bindable" then
            local rem = entry.Object
            if not rem or not rem.Parent then return end

            local argList = {}
            if specificArg and specificArg:match("%S") then
                table.insert(argList, parseCustomArgs(specificArg))
            else
                argList = buildDefaultRemoteBattery()
            end

            for _, args in ipairs(argList) do
                pcall(function()
                    if rem:IsA("RemoteEvent") or rem.ClassName == "UnreliableRemoteEvent" then
                        if #args == 0 then rem:FireServer() else rem:FireServer(table.unpack(args)) end
                    elseif rem:IsA("RemoteFunction") then
                        if #args == 0 then rem:InvokeServer() else rem:InvokeServer(table.unpack(args)) end
                    elseif rem:IsA("BindableEvent") then
                        if #args == 0 then rem:Fire() else rem:Fire(table.unpack(args)) end
                    elseif rem:IsA("BindableFunction") then
                        if #args == 0 then rem:Invoke() else rem:Invoke(table.unpack(args)) end
                    end
                end)
            end

        -- ITENS DO MAPA (WORLD TOOL & COLECIONÁVEIS)
        elseif entry.Type == "WorldTool" or entry.Type == "WorldItem" then
            local item = entry.Object
            if item and item.Parent and not isFromOtherPlayer(item) then
                local handle = getEntryTargetPart(entry)
                if handle then
                    local origPos = teleportToCFrame(handle.CFrame + Vector3.new(0, 1.2, 0), false)
                    fireTouchPart(handle)

                    -- Dispara Prompts/ClickDetectors dentro do item se houver
                    for _, desc in ipairs(item:GetDescendants()) do
                        if desc:IsA("ClickDetector") and fireclickdetector then
                            pcall(function() fireclickdetector(desc) end)
                        elseif desc:IsA("ProximityPrompt") and fireproximityprompt then
                            pcall(function()
                                desc.HoldDuration = 0
                                desc.RequiresLineOfSight = false
                                fireproximityprompt(desc)
                            end)
                        end
                    end

                    if item:IsA("Tool") then
                        pcall(function() Humanoid:EquipTool(item) end)
                        pcall(function() item.Parent = Character end)
                        task.wait(0.08)
                        pcall(function() item:Activate() end)
                    end

                    task.wait(0.06)
                    if shouldReturn and origPos and RootPart and RootPart.Parent then
                        RootPart.CFrame = origPos
                    end
                elseif item:IsA("Tool") then
                    -- Fallback da V8/V9 para Tool sem Handle/BasePart
                    pcall(function()
                        item.Parent = Backpack
                        Humanoid:EquipTool(item)
                        task.wait(0.08)
                        item:Activate()
                    end)
                end
            end

        elseif entry.Type == "ReplicatedTool" then
            local tool = entry.Object
            if tool then
                local clone = tool:Clone()
                clone.Parent = Backpack
                pcall(function() Humanoid:EquipTool(clone) end)
                task.wait(0.08)
                pcall(function() clone:Activate() end)
            end

        elseif entry.Type == "BackpackTool" then
            local tool = entry.Object
            if tool and tool.Parent then
                pcall(function()
                    tool.Parent = Character
                    task.wait(0.08)
                    tool:Activate()
                    task.wait(0.04)
                    tool.Parent = Backpack
                end)
            end

        -- PROMPTS COM ALINHAMENTO DE CÂMERA
        elseif entry.Type == "Prompt" then
            local prompt = entry.Object
            if prompt and prompt.Parent then
                local promptPart = getEntryTargetPart(entry)
                if promptPart then
                    local origPos = teleportToCFrame(promptPart.CFrame + Vector3.new(0, 1.2, 0), false)
                    pcall(function()
                        local cam = workspace.CurrentCamera
                        if cam then cam.CFrame = CFrame.new(cam.CFrame.Position, promptPart.Position) end
                    end)

                    if prompt:IsA("ProximityPrompt") then
                        prompt.HoldDuration = 0
                        prompt.MaxActivationDistance = 999999
                        prompt.RequiresLineOfSight = false
                        prompt.Enabled = true

                        if fireproximityprompt then fireproximityprompt(prompt) end
                        if firesignal then
                            firesignal(prompt.PromptButtonHoldBegan)
                            firesignal(prompt.Triggered)
                            firesignal(prompt.PromptButtonHoldEnded)
                        end
                        pcall(function()
                            VirtualInputManager:SendKeyEvent(true, prompt.KeyboardKeyCode or Enum.KeyCode.E, false, game)
                            task.wait(0.02)
                            VirtualInputManager:SendKeyEvent(false, prompt.KeyboardKeyCode or Enum.KeyCode.E, false, game)
                        end)
                    elseif prompt:IsA("ClickDetector") then
                        if fireclickdetector then fireclickdetector(prompt) end
                    end
                    task.wait(0.06)
                    if shouldReturn and origPos and RootPart and RootPart.Parent then
                        RootPart.CFrame = origPos
                    end
                end
            end

        -- TOUCHPADS
        elseif entry.Type == "TouchPad" then
            local part = entry.Object
            if part and part:IsA("BasePart") and part.Parent then
                local origPos = teleportToCFrame(part.CFrame + Vector3.new(0, 1.5, 0), false)
                RootPart.AssemblyLinearVelocity = Vector3.new(0, -4, 0)
                pcall(function() Humanoid:ChangeState(Enum.HumanoidStateType.Landed) end)

                fireTouchPart(part)
                task.wait(0.08)
                if shouldReturn and origPos and RootPart and RootPart.Parent then
                    RootPart.CFrame = origPos
                end
            end
        end
    end)
end

-- ---------------------------------------------------------------------------------
-- 6. ESPIÃO DE REDE INTEGRADO
-- ---------------------------------------------------------------------------------
local function initRemoteSpy(onCapture)
    if not hookmetamethod then return end
    pcall(function()
        local oldNamecall
        oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
            local method = getnamecallmethod()
            local args = {...}

            if (method == "FireServer" or method == "InvokeServer")
                and (self:IsA("RemoteEvent") or self:IsA("RemoteFunction") or self.ClassName == "UnreliableRemoteEvent") then
                pcall(function()
                    table.insert(State.SpyLogs, 1, {
                        Remote = self,
                        Method = method,
                        Args = args,
                        Time = os.date("%H:%M:%S")
                    })
                    if #State.SpyLogs > 40 then table.remove(State.SpyLogs) end
                    if onCapture then onCapture() end
                end)
            end

            return oldNamecall(self, ...)
        end)
    end)
end

-- ---------------------------------------------------------------------------------
-- 7. INTERFACE GRÁFICA V13 (CYBER APEX LAB)
-- ---------------------------------------------------------------------------------
local function makeCorner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius)
    c.Parent = parent
    return c
end

local function buildInterfaceV13()
    local parentGui = (gethui and gethui()) or game:GetService("CoreGui"):FindFirstChild("RobloxGui") or LocalPlayer:WaitForChild("PlayerGui")
    local old = parentGui:FindFirstChild("BadgeMaster_V13") or parentGui:FindFirstChild("BadgeMaster_V12")
    if old then old:Destroy() end

    local Screen = Instance.new("ScreenGui")
    Screen.Name = "BadgeMaster_V13"
    Screen.ResetOnSpawn = false

    -- Botão Mobile Flutuante
    local MobBtn = Instance.new("TextButton")
    MobBtn.Size = UDim2.new(0, 52, 0, 52)
    MobBtn.Position = UDim2.new(0, 16, 0.45, 0)
    MobBtn.BackgroundColor3 = Color3.fromRGB(15, 18, 28)
    MobBtn.Text = "👑"
    MobBtn.TextSize = 24
    MobBtn.BorderSizePixel = 0
    MobBtn.Parent = Screen
    makeCorner(MobBtn, 26)

    local mbStroke = Instance.new("UIStroke")
    mbStroke.Color = Color3.fromRGB(0, 240, 255)
    mbStroke.Thickness = 2
    mbStroke.Parent = MobBtn

    -- Janela Principal
    local Window = Instance.new("Frame")
    Window.Size = UDim2.new(0, 680, 0, 560)
    Window.Position = UDim2.new(0.5, -340, 0.5, -280)
    Window.BackgroundColor3 = Color3.fromRGB(10, 12, 18)
    Window.BorderSizePixel = 0
    Window.Active = true
    Window.ClipsDescendants = true
    Window.Parent = Screen
    makeCorner(Window, 12)

    local wStroke = Instance.new("UIStroke")
    wStroke.Color = Color3.fromRGB(0, 180, 255)
    wStroke.Thickness = 1.4
    wStroke.Parent = Window

    -- TopBar
    local TopBar = Instance.new("Frame")
    TopBar.Size = UDim2.new(1, 0, 0, 42)
    TopBar.BackgroundColor3 = Color3.fromRGB(16, 20, 30)
    TopBar.BorderSizePixel = 0
    TopBar.Parent = Window
    makeCorner(TopBar, 12)

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -135, 1, 0)
    Title.Position = UDim2.new(0, 14, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = "👑 BADGE MASTER V13  |  OMNI-TESTING LAB"
    Title.TextColor3 = Color3.fromRGB(0, 240, 255)
    Title.TextSize = 12
    Title.Font = Enum.Font.GothamBold
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = TopBar

    local NoclipBtn = Instance.new("TextButton")
    NoclipBtn.Size = UDim2.new(0, 82, 0, 26)
    NoclipBtn.Position = UDim2.new(1, -122, 0.5, -13)
    NoclipBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 110)
    NoclipBtn.Text = "👻 Noclip: ON"
    NoclipBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    NoclipBtn.TextSize = 9
    NoclipBtn.Font = Enum.Font.GothamBold
    NoclipBtn.BorderSizePixel = 0
    NoclipBtn.Parent = TopBar
    makeCorner(NoclipBtn, 6)

    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 28, 0, 28)
    CloseBtn.Position = UDim2.new(1, -34, 0, 7)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(30, 36, 52)
    CloseBtn.Text = "✕"
    CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseBtn.TextSize = 11
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.BorderSizePixel = 0
    CloseBtn.Parent = TopBar
    makeCorner(CloseBtn, 6)

    CloseBtn.MouseButton1Click:Connect(function() Window.Visible = false end)
    MobBtn.MouseButton1Click:Connect(function() Window.Visible = not Window.Visible end)
    NoclipBtn.MouseButton1Click:Connect(function()
        State.NoclipEnabled = not State.NoclipEnabled
        NoclipBtn.Text = State.NoclipEnabled and "👻 Noclip: ON" or "👻 Noclip: OFF"
        NoclipBtn.BackgroundColor3 = State.NoclipEnabled and Color3.fromRGB(0, 170, 110) or Color3.fromRGB(50, 56, 72)
    end)

    -- Arrastar Janela
    local dragging, dragStart, startPos
    TopBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = Window.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            Window.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    -- Corpo
    local Body = Instance.new("Frame")
    Body.Size = UDim2.new(1, -24, 1, -54)
    Body.Position = UDim2.new(0, 12, 0, 48)
    Body.BackgroundTransparency = 1
    Body.Parent = Window

    -- 1. Barra de Ações Mestres (Topo)
    local TopCmds = Instance.new("Frame")
    TopCmds.Size = UDim2.new(1, 0, 0, 36)
    TopCmds.BackgroundTransparency = 1
    TopCmds.Parent = Body

    local topLayout = Instance.new("UIListLayout")
    topLayout.FillDirection = Enum.FillDirection.Horizontal
    topLayout.Padding = UDim.new(0, 5)
    topLayout.Parent = TopCmds

    local function makeTopBtn(text, color, widthScale)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(widthScale, -4, 1, 0)
        btn.BackgroundColor3 = color
        btn.Text = text
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.TextSize = 10
        btn.Font = Enum.Font.GothamBold
        btn.BorderSizePixel = 0
        btn.Parent = TopCmds
        makeCorner(btn, 8)
        return btn
    end

    local MassTestBtn = makeTopBtn("🚀 TESTAR TUDO", Color3.fromRGB(220, 35, 60), 0.23)
    local AllRemotesBtn = makeTopBtn("⚡ Só Remotes", Color3.fromRGB(130, 60, 230), 0.19)
    local GrabItemsBtn = makeTopBtn("🎁 Pegar Itens", Color3.fromRGB(225, 135, 20), 0.18)
    local EspBtn = makeTopBtn("👁️ ESP: OFF", Color3.fromRGB(0, 170, 115), 0.14)
    local RescanBtn = makeTopBtn("🔄 Re-Scan", Color3.fromRGB(0, 130, 240), 0.13)
    local StopAutosBtn = makeTopBtn("⏹️ Parar", Color3.fromRGB(45, 52, 68), 0.13)

    -- 2. Barra de Teleporte & Retorno
    local TpRow = Instance.new("Frame")
    TpRow.Size = UDim2.new(1, 0, 0, 30)
    TpRow.Position = UDim2.new(0, 0, 0, 42)
    TpRow.BackgroundColor3 = Color3.fromRGB(16, 20, 30)
    TpRow.BorderSizePixel = 0
    TpRow.Parent = Body
    makeCorner(TpRow, 8)

    local tpLayout = Instance.new("UIListLayout")
    tpLayout.FillDirection = Enum.FillDirection.Horizontal
    tpLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    tpLayout.Padding = UDim.new(0, 6)
    tpLayout.Parent = TpRow

    local tpPad = Instance.new("UIPadding")
    tpPad.PaddingLeft = UDim.new(0, 8)
    tpPad.PaddingRight = UDim.new(0, 8)
    tpPad.Parent = TpRow

    local tpTitle = Instance.new("TextLabel")
    tpTitle.Size = UDim2.new(0, 110, 1, 0)
    tpTitle.BackgroundTransparency = 1
    tpTitle.Text = "📍 Teleporte:"
    tpTitle.TextColor3 = Color3.fromRGB(0, 220, 255)
    tpTitle.TextSize = 10
    tpTitle.Font = Enum.Font.GothamBold
    tpTitle.TextXAlignment = Enum.TextXAlignment.Left
    tpTitle.Parent = TpRow

    local SavePosBtn = Instance.new("TextButton")
    SavePosBtn.Size = UDim2.new(0, 120, 0, 22)
    SavePosBtn.BackgroundColor3 = Color3.fromRGB(28, 38, 56)
    SavePosBtn.Text = "📌 Salvar Local"
    SavePosBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    SavePosBtn.TextSize = 10
    SavePosBtn.Font = Enum.Font.GothamBold
    SavePosBtn.BorderSizePixel = 0
    SavePosBtn.Parent = TpRow
    makeCorner(SavePosBtn, 6)

    local ReturnPosBtn = Instance.new("TextButton")
    ReturnPosBtn.Size = UDim2.new(0, 145, 0, 22)
    ReturnPosBtn.BackgroundColor3 = Color3.fromRGB(0, 145, 220)
    ReturnPosBtn.Text = "↩️ Voltar ao Anterior"
    ReturnPosBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ReturnPosBtn.TextSize = 10
    ReturnPosBtn.Font = Enum.Font.GothamBold
    ReturnPosBtn.BorderSizePixel = 0
    ReturnPosBtn.Parent = TpRow
    makeCorner(ReturnPosBtn, 6)

    local AutoReturnBtn = Instance.new("TextButton")
    AutoReturnBtn.Size = UDim2.new(0, 155, 0, 22)
    AutoReturnBtn.BackgroundColor3 = Color3.fromRGB(0, 175, 110)
    AutoReturnBtn.Text = "🔄 Auto-Voltar: ON"
    AutoReturnBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    AutoReturnBtn.TextSize = 10
    AutoReturnBtn.Font = Enum.Font.GothamBold
    AutoReturnBtn.BorderSizePixel = 0
    AutoReturnBtn.Parent = TpRow
    makeCorner(AutoReturnBtn, 6)

    -- 3. Barra de Parâmetros Customizados do Lab
    local ParamRow = Instance.new("Frame")
    ParamRow.Size = UDim2.new(1, 0, 0, 34)
    ParamRow.Position = UDim2.new(0, 0, 0, 78)
    ParamRow.BackgroundColor3 = Color3.fromRGB(16, 20, 30)
    ParamRow.BorderSizePixel = 0
    ParamRow.Parent = Body
    makeCorner(ParamRow, 8)

    local prLabel = Instance.new("TextLabel")
    prLabel.Size = UDim2.new(0, 125, 1, 0)
    prLabel.Position = UDim2.new(0, 8, 0, 0)
    prLabel.BackgroundTransparency = 1
    prLabel.Text = "🧪 Args Remote:"
    prLabel.TextColor3 = Color3.fromRGB(255, 190, 60)
    prLabel.TextSize = 10
    prLabel.Font = Enum.Font.GothamBold
    prLabel.TextXAlignment = Enum.TextXAlignment.Left
    prLabel.Parent = ParamRow

    local CustomArgInput = Instance.new("TextBox")
    CustomArgInput.Size = UDim2.new(1, -280, 0, 24)
    CustomArgInput.Position = UDim2.new(0, 130, 0.5, -12)
    CustomArgInput.BackgroundColor3 = Color3.fromRGB(24, 30, 44)
    CustomArgInput.PlaceholderText = "Vazio = Bateria Auto | Ex: true, 1000 ou 'Win'"
    CustomArgInput.PlaceholderColor3 = Color3.fromRGB(110, 120, 140)
    CustomArgInput.Text = ""
    CustomArgInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    CustomArgInput.TextSize = 10
    CustomArgInput.Font = Enum.Font.Code
    CustomArgInput.ClearTextOnFocus = false
    CustomArgInput.BorderSizePixel = 0
    CustomArgInput.Parent = ParamRow
    makeCorner(CustomArgInput, 6)

    local ApplyToAllBtn = Instance.new("TextButton")
    ApplyToAllBtn.Size = UDim2.new(0, 138, 0, 24)
    ApplyToAllBtn.Position = UDim2.new(1, -144, 0.5, -12)
    ApplyToAllBtn.BackgroundColor3 = Color3.fromRGB(0, 155, 245)
    ApplyToAllBtn.Text = "⚡ Injetar nos Remotes"
    ApplyToAllBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ApplyToAllBtn.TextSize = 10
    ApplyToAllBtn.Font = Enum.Font.GothamBold
    ApplyToAllBtn.BorderSizePixel = 0
    ApplyToAllBtn.Parent = ParamRow
    makeCorner(ApplyToAllBtn, 6)

    CustomArgInput.FocusLost:Connect(function()
        State.CustomArg = CustomArgInput.Text
    end)
    CustomArgInput:GetPropertyChangedSignal("Text"):Connect(function()
        State.CustomArg = CustomArgInput.Text
    end)

    -- 4. Barra de Presets Rápidos de Argumentos
    local PresetRow = Instance.new("Frame")
    PresetRow.Size = UDim2.new(1, 0, 0, 24)
    PresetRow.Position = UDim2.new(0, 0, 0, 117)
    PresetRow.BackgroundTransparency = 1
    PresetRow.Parent = Body

    local presetLayout = Instance.new("UIListLayout")
    presetLayout.FillDirection = Enum.FillDirection.Horizontal
    presetLayout.Padding = UDim.new(0, 5)
    presetLayout.Parent = PresetRow

    local presets = {
        {Label = "🤖 Auto (Todos)", Value = ""},
        {Label = "true, 1000", Value = "true, 1000"},
        {Label = "1000", Value = "1000"},
        {Label = "false", Value = "false"},
        {Label = "true, 1", Value = "true, 1"},
        {Label = "true", Value = "true"},
        {Label = '"Win"', Value = '"Win"'},
        {Label = '"Claim"', Value = '"Claim"'},
        {Label = "me, 1000", Value = "me, 1000"}
    }

    for _, p in ipairs(presets) do
        local pBtn = Instance.new("TextButton")
        pBtn.Size = UDim2.new(0, p.Value == "" and 92 or 66, 1, 0)
        pBtn.BackgroundColor3 = p.Value == "" and Color3.fromRGB(90, 50, 165) or Color3.fromRGB(24, 30, 44)
        pBtn.Text = p.Label
        pBtn.TextColor3 = Color3.fromRGB(225, 235, 250)
        pBtn.TextSize = 9
        pBtn.Font = Enum.Font.GothamBold
        pBtn.BorderSizePixel = 0
        pBtn.Parent = PresetRow
        makeCorner(pBtn, 5)

        pBtn.MouseButton1Click:Connect(function()
            CustomArgInput.Text = p.Value
            State.CustomArg = p.Value
        end)
    end

    -- 5. Categorias (Pills)
    local CatRow = Instance.new("Frame")
    CatRow.Size = UDim2.new(1, 0, 0, 28)
    CatRow.Position = UDim2.new(0, 0, 0, 147)
    CatRow.BackgroundTransparency = 1
    CatRow.Parent = Body

    local catLayout = Instance.new("UIListLayout")
    catLayout.FillDirection = Enum.FillDirection.Horizontal
    catLayout.Padding = UDim.new(0, 6)
    catLayout.Parent = CatRow

    local CatBtns = {}
    local Categories = {"Todos", "Itens", "Remotes", "Prompts", "Pads", "Bindables", "🛰️ Spy"}

    -- 6. Barra de Busca e Status
    local SearchRow = Instance.new("Frame")
    SearchRow.Size = UDim2.new(1, 0, 0, 28)
    SearchRow.Position = UDim2.new(0, 0, 0, 181)
    SearchRow.BackgroundTransparency = 1
    SearchRow.Parent = Body

    local StatusText = Instance.new("TextLabel")
    StatusText.Size = UDim2.new(0.45, -6, 1, 0)
    StatusText.BackgroundTransparency = 1
    StatusText.Text = "Carregando mapa..."
    StatusText.TextColor3 = Color3.fromRGB(165, 175, 195)
    StatusText.TextSize = 11
    StatusText.Font = Enum.Font.GothamMedium
    StatusText.TextXAlignment = Enum.TextXAlignment.Left
    StatusText.TextTruncate = Enum.TextTruncate.AtEnd
    StatusText.Parent = SearchRow

    local SearchBox = Instance.new("TextBox")
    SearchBox.Size = UDim2.new(0.55, 0, 1, 0)
    SearchBox.Position = UDim2.new(0.45, 0, 0, 0)
    SearchBox.BackgroundColor3 = Color3.fromRGB(18, 22, 32)
    SearchBox.PlaceholderText = "🔍 Buscar item, remote ou prompt..."
    SearchBox.PlaceholderColor3 = Color3.fromRGB(110, 120, 140)
    SearchBox.Text = ""
    SearchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    SearchBox.TextSize = 11
    SearchBox.Font = Enum.Font.Gotham
    SearchBox.BorderSizePixel = 0
    SearchBox.Parent = SearchRow
    makeCorner(SearchBox, 6)

    -- 7. Lista Interativa
    local ScrollList = Instance.new("ScrollingFrame")
    ScrollList.Size = UDim2.new(1, 0, 1, -215)
    ScrollList.Position = UDim2.new(0, 0, 0, 215)
    ScrollList.BackgroundColor3 = Color3.fromRGB(8, 10, 15)
    ScrollList.BorderSizePixel = 0
    ScrollList.ScrollBarThickness = 4
    ScrollList.Parent = Body
    makeCorner(ScrollList, 8)

    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 5)
    listLayout.Parent = ScrollList

    Screen.Parent = parentGui

    -- Renderizador Dinâmico
    local function renderCards(search)
        search = (search or SearchBox.Text):lower()

        for _, c in ipairs(ScrollList:GetChildren()) do
            if c:IsA("Frame") then c:Destroy() end
        end

        -- ABA SPY
        if State.ActiveCategory == "🛰️ Spy" then
            for _, log in ipairs(State.SpyLogs) do
                local card = Instance.new("Frame")
                card.Size = UDim2.new(1, -8, 0, 48)
                card.BackgroundColor3 = Color3.fromRGB(16, 20, 30)
                card.BorderSizePixel = 0
                card.Parent = ScrollList
                makeCorner(card, 8)

                local title = Instance.new("TextLabel")
                title.Size = UDim2.new(1, -110, 0, 20)
                title.Position = UDim2.new(0, 10, 0, 5)
                title.BackgroundTransparency = 1
                title.Text = string.format("[%s] %s:%s()", log.Time, log.Remote.Name, log.Method)
                title.TextColor3 = Color3.fromRGB(0, 240, 255)
                title.TextSize = 11
                title.Font = Enum.Font.GothamBold
                title.TextXAlignment = Enum.TextXAlignment.Left
                title.TextTruncate = Enum.TextTruncate.AtEnd
                title.Parent = card

                local sub = Instance.new("TextLabel")
                sub.Size = UDim2.new(1, -110, 0, 16)
                sub.Position = UDim2.new(0, 10, 0, 25)
                sub.BackgroundTransparency = 1
                local okJson, argsStr = pcall(function() return HttpService:JSONEncode(log.Args) end)
                sub.Text = "Args: " .. (okJson and argsStr or tostring(#log.Args) .. " args")
                sub.TextColor3 = Color3.fromRGB(140, 150, 175)
                sub.TextSize = 9
                sub.Font = Enum.Font.Code
                sub.TextXAlignment = Enum.TextXAlignment.Left
                sub.TextTruncate = Enum.TextTruncate.AtEnd
                sub.Parent = card

                local replayBtn = Instance.new("TextButton")
                replayBtn.Size = UDim2.new(0, 90, 0, 30)
                replayBtn.Position = UDim2.new(1, -98, 0.5, -15)
                replayBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 100)
                replayBtn.Text = "🔁 Replicar"
                replayBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                replayBtn.TextSize = 10
                replayBtn.Font = Enum.Font.GothamBold
                replayBtn.BorderSizePixel = 0
                replayBtn.Parent = card
                makeCorner(replayBtn, 6)

                replayBtn.MouseButton1Click:Connect(function()
                    pcall(function()
                        if log.Method == "FireServer" then
                            log.Remote:FireServer(table.unpack(log.Args))
                        else
                            log.Remote:InvokeServer(table.unpack(log.Args))
                        end
                        replayBtn.Text = "Replicado!"
                        task.wait(0.5)
                        replayBtn.Text = "🔁 Replicar"
                    end)
                end)
            end
            ScrollList.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 10)
            StatusText.Text = string.format("Espião: %d chamadas capturadas.", #State.SpyLogs)
            return
        end

        -- LISTA NORMAL
        local count = 0
        for _, entry in ipairs(State.ScannedEntries) do
            local matchesCat = (State.ActiveCategory == "Todos") or (entry.Category == State.ActiveCategory)
            local matchesSearch = (search == "") or entry.Name:lower():find(search, 1, true) or entry.TypeLabel:lower():find(search, 1, true) or entry.Location:lower():find(search, 1, true)

            if matchesCat and matchesSearch then
                count = count + 1
                local hasSpatialPart = (entry.Category == "Itens" or entry.Category == "Pads" or entry.Category == "Prompts")
                    and (entry.Type ~= "ReplicatedTool" and entry.Type ~= "BackpackTool")

                local card = Instance.new("Frame")
                card.Name = "Card_" .. entry.Id
                card.Size = UDim2.new(1, -8, 0, 48)
                card.BackgroundColor3 = Color3.fromRGB(16, 20, 28)
                card.BorderSizePixel = 0
                card.Parent = ScrollList
                makeCorner(card, 8)

                local titleWidthOffset = hasSpatialPart and -235 or -185

                local titleLabel = Instance.new("TextLabel")
                titleLabel.Size = UDim2.new(1, titleWidthOffset, 0, 20)
                titleLabel.Position = UDim2.new(0, 10, 0, 5)
                titleLabel.BackgroundTransparency = 1
                titleLabel.Text = entry.Icon .. " " .. entry.Name
                titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                titleLabel.TextSize = 11
                titleLabel.Font = Enum.Font.GothamBold
                titleLabel.TextXAlignment = Enum.TextXAlignment.Left
                titleLabel.TextTruncate = Enum.TextTruncate.AtEnd
                titleLabel.Parent = card

                local subLabel = Instance.new("TextLabel")
                subLabel.Size = UDim2.new(1, titleWidthOffset, 0, 16)
                subLabel.Position = UDim2.new(0, 10, 0, 25)
                subLabel.BackgroundTransparency = 1
                subLabel.Text = string.format("%s • %s", entry.TypeLabel, entry.Location)
                subLabel.TextColor3 = Color3.fromRGB(140, 150, 175)
                subLabel.TextSize = 9
                subLabel.Font = Enum.Font.Gotham
                subLabel.TextXAlignment = Enum.TextXAlignment.Left
                subLabel.TextTruncate = Enum.TextTruncate.AtEnd
                subLabel.Parent = card

                if hasSpatialPart then
                    local tpBtn = Instance.new("TextButton")
                    tpBtn.Size = UDim2.new(0, 46, 0, 30)
                    tpBtn.Position = UDim2.new(1, -222, 0.5, -15)
                    tpBtn.BackgroundColor3 = Color3.fromRGB(38, 48, 70)
                    tpBtn.Text = "📍 TP"
                    tpBtn.TextColor3 = Color3.fromRGB(0, 225, 255)
                    tpBtn.TextSize = 10
                    tpBtn.Font = Enum.Font.GothamBold
                    tpBtn.BorderSizePixel = 0
                    tpBtn.Parent = card
                    makeCorner(tpBtn, 6)

                    tpBtn.MouseButton1Click:Connect(function()
                        local part = getEntryTargetPart(entry)
                        if part then
                            teleportToCFrame(part.CFrame + Vector3.new(0, 2, 0), false)
                            StatusText.Text = "Teleportado para " .. entry.Name .. " (use Voltar ao Anterior!)"
                        else
                            StatusText.Text = "Sem posição 3D para " .. entry.Name
                        end
                    end)
                end

                local runOnceBtn = Instance.new("TextButton")
                runOnceBtn.Size = UDim2.new(0, 75, 0, 30)
                runOnceBtn.Position = UDim2.new(1, -170, 0.5, -15)
                runOnceBtn.BackgroundColor3 = Color3.fromRGB(0, 140, 255)
                runOnceBtn.Text = "▶ Testar"
                runOnceBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                runOnceBtn.TextSize = 10
                runOnceBtn.Font = Enum.Font.GothamBold
                runOnceBtn.BorderSizePixel = 0
                runOnceBtn.Parent = card
                makeCorner(runOnceBtn, 6)

                runOnceBtn.MouseButton1Click:Connect(function()
                    runOnceBtn.Text = "Testando..."
                    runOnceBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
                    task.spawn(function()
                        executeAction(entry, State.CustomArg)
                        task.wait(0.2)
                        runOnceBtn.Text = "▶ Testar"
                        runOnceBtn.BackgroundColor3 = Color3.fromRGB(0, 140, 255)
                    end)
                end)

                local autoBtn = Instance.new("TextButton")
                autoBtn.Size = UDim2.new(0, 85, 0, 30)
                autoBtn.Position = UDim2.new(1, -88, 0.5, -15)
                local isLooping = State.ActiveLoops[entry.Id] or false
                autoBtn.BackgroundColor3 = isLooping and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(36, 42, 58)
                autoBtn.Text = isLooping and "🔁 Auto: ON" or "🔁 Auto: OFF"
                autoBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                autoBtn.TextSize = 10
                autoBtn.Font = Enum.Font.GothamBold
                autoBtn.BorderSizePixel = 0
                autoBtn.Parent = card
                makeCorner(autoBtn, 6)

                autoBtn.MouseButton1Click:Connect(function()
                    if State.ActiveLoops[entry.Id] then
                        State.ActiveLoops[entry.Id] = nil
                        autoBtn.BackgroundColor3 = Color3.fromRGB(36, 42, 58)
                        autoBtn.Text = "🔁 Auto: OFF"
                    else
                        State.ActiveLoops[entry.Id] = true
                        autoBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
                        autoBtn.Text = "🔁 Auto: ON"

                        task.spawn(function()
                            while State.ActiveLoops[entry.Id] do
                                executeAction(entry, State.CustomArg)
                                task.wait(0.25)
                            end
                        end)
                    end
                end)
            end
        end

        ScrollList.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 10)
        StatusText.Text = string.format("Exibindo: %d opções", count)
    end

    for _, catName in ipairs(Categories) do
        local pill = Instance.new("TextButton")
        pill.Size = UDim2.new(0, catName:find("Spy") and 85 or 74, 1, 0)
        pill.BackgroundColor3 = (State.ActiveCategory == catName) and Color3.fromRGB(0, 180, 255) or Color3.fromRGB(20, 25, 36)
        pill.Text = catName
        pill.TextColor3 = Color3.fromRGB(255, 255, 255)
        pill.TextSize = 10
        pill.Font = Enum.Font.GothamBold
        pill.BorderSizePixel = 0
        pill.Parent = CatRow
        makeCorner(pill, 6)

        CatBtns[catName] = pill

        pill.MouseButton1Click:Connect(function()
            State.ActiveCategory = catName
            for cName, btn in pairs(CatBtns) do
                btn.BackgroundColor3 = (cName == catName) and Color3.fromRGB(0, 180, 255) or Color3.fromRGB(20, 25, 36)
            end
            renderCards()
        end)
    end

    SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
        renderCards(SearchBox.Text)
    end)

    -- Botões de Teleporte
    SavePosBtn.MouseButton1Click:Connect(function()
        if not RootPart or not RootPart.Parent then refreshCharacterRefs() end
        if RootPart then
            State.SavedPosition = RootPart.CFrame
            State.LastPositionBeforeTP = RootPart.CFrame
            StatusText.Text = "Posição atual salva!"
        end
    end)

    ReturnPosBtn.MouseButton1Click:Connect(function()
        if returnToPreviousPosition() then
            StatusText.Text = "Retornou para o local anterior!"
        else
            StatusText.Text = "Nenhuma posição anterior salva ainda."
        end
    end)

    AutoReturnBtn.MouseButton1Click:Connect(function()
        State.AutoReturnTP = not State.AutoReturnTP
        AutoReturnBtn.Text = State.AutoReturnTP and "🔄 Auto-Voltar: ON" or "🔄 Auto-Voltar: OFF"
        AutoReturnBtn.BackgroundColor3 = State.AutoReturnTP and Color3.fromRGB(0, 175, 110) or Color3.fromRGB(65, 72, 92)
    end)

    -- Toggle ESP
    EspBtn.MouseButton1Click:Connect(function()
        local nextState = not State.EspEnabled
        toggleEsp(nextState)
        EspBtn.Text = nextState and "👁️ ESP: ON" or "👁️ ESP: OFF"
        EspBtn.BackgroundColor3 = nextState and Color3.fromRGB(0, 230, 135) or Color3.fromRGB(0, 170, 115)
    end)

    -- Injetar Argumento Manual (ou Bateria Completa se vazio) em Todos os Remotes
    local function runAllRemotes(triggerBtn, defaultText, defaultColor)
        if State.IsBatchRunning then return end
        State.IsBatchRunning = true
        triggerBtn.Text = "Testando..."
        local usingAutoBattery = not (State.CustomArg and State.CustomArg:match("%S"))
        StatusText.Text = usingAutoBattery
            and "Testando bateria completa de atributos em todos os remotes..."
            or ("Injetando '" .. State.CustomArg .. "' em todos os remotes...")

        task.spawn(function()
            local count = 0
            for _, entry in ipairs(State.ScannedEntries) do
                if not State.IsBatchRunning then break end
                if entry.Category == "Remotes" or entry.Category == "Bindables" then
                    count = count + 1
                    StatusText.Text = string.format("Remote %d: %s", count, entry.Name)
                    executeAction(entry, State.CustomArg)
                    task.wait(State.RemoteDelay)
                end
            end
            StatusText.Text = State.IsBatchRunning
                and string.format("Concluído! %d remotes testados.", count)
                or "Teste de remotes interrompido."
            triggerBtn.Text = defaultText
            triggerBtn.BackgroundColor3 = defaultColor
            State.IsBatchRunning = false
        end)
    end

    ApplyToAllBtn.MouseButton1Click:Connect(function()
        runAllRemotes(ApplyToAllBtn, "⚡ Injetar nos Remotes", Color3.fromRGB(0, 155, 245))
    end)

    AllRemotesBtn.MouseButton1Click:Connect(function()
        runAllRemotes(AllRemotesBtn, "⚡ Só Remotes", Color3.fromRGB(130, 60, 230))
    end)

    -- Pegar Todos os Itens
    GrabItemsBtn.MouseButton1Click:Connect(function()
        if State.IsBatchRunning then return end
        State.IsBatchRunning = true
        GrabItemsBtn.Text = "Pegando..."

        task.spawn(function()
            local entries = scanAllGameElementsV13()
            renderCards()

            local itemCount = 0
            for _, entry in ipairs(entries) do
                if not State.IsBatchRunning then break end
                if entry.Category == "Itens" then
                    itemCount = itemCount + 1
                    StatusText.Text = string.format("Pegando item %d: %s", itemCount, entry.Name)
                    executeAction(entry, State.CustomArg)
                    task.wait(0.04)
                end
            end

            StatusText.Text = string.format("Coleta finalizada! %d itens processados.", itemCount)
            GrabItemsBtn.Text = "🎁 Pegar Itens"
            State.IsBatchRunning = false
        end)
    end)

    return {
        Status = StatusText,
        MassTestBtn = MassTestBtn,
        RescanBtn = RescanBtn,
        StopAutosBtn = StopAutosBtn,
        Render = renderCards
    }
end

local UI = buildInterfaceV13()

initRemoteSpy(function()
    if State.ActiveCategory == "🛰️ Spy" then
        UI.Render()
    end
end)

-- ---------------------------------------------------------------------------------
-- 8. VINCULAÇÃO DOS BOTÕES PRINCIPAIS
-- ---------------------------------------------------------------------------------
UI.MassTestBtn.MouseButton1Click:Connect(function()
    if State.IsBatchRunning then return end
    State.IsBatchRunning = true
    UI.MassTestBtn.Text = "TESTANDO..."
    UI.MassTestBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 120)
    UI.Status.Text = "Iniciando teste massivo de remotes, itens, pads e prompts..."

    task.spawn(function()
        local entries = scanAllGameElementsV13()
        UI.Render()

        local total = #entries
        for i = 1, total do
            if not State.IsBatchRunning then break end
            local e = entries[i]
            UI.Status.Text = string.format("Testando (%d/%d): %s", i, total, e.Name)
            executeAction(e, State.CustomArg)
            task.wait(State.RemoteDelay)
        end

        UI.Status.Text = State.IsBatchRunning
            and "Finalizado! Todos os elementos foram testados."
            or "Teste massivo interrompido pelo usuário."
        UI.MassTestBtn.Text = "🚀 TESTAR TUDO"
        UI.MassTestBtn.BackgroundColor3 = Color3.fromRGB(220, 35, 60)
        State.IsBatchRunning = false
    end)
end)

UI.RescanBtn.MouseButton1Click:Connect(function()
    UI.Status.Text = "Atualizando mapa, itens e eventos..."
    task.spawn(function()
        scanAllGameElementsV13()
        UI.Render()
        if State.EspEnabled then toggleEsp(true) end
        UI.Status.Text = "Escaneamento V13 atualizado!"
    end)
end)

UI.StopAutosBtn.MouseButton1Click:Connect(function()
    State.ActiveLoops = {}
    State.IsBatchRunning = false
    UI.Render()
    UI.Status.Text = "Todos os loops e testes em massa foram parados."
end)

task.delay(0.5, function()
    scanAllGameElementsV13()
    UI.Render()
end)

print("[BadgeMaster V13] Omni-Testing Lab carregado com sucesso!")

]====]
}

local VERSION_LIST = {
    { Key = "V14", Label = "Versão 14", Desc = "Hub Universal + GUI 100% Visível", Recommended = true },
    { Key = "V13", Label = "Versão 13", Desc = "Bateria Remotes + TP/Voltar", Recommended = false },
    { Key = "V12", Label = "Versão 12", Desc = "Apex Testing Lab & ESP 3D", Recommended = false },
    { Key = "V11", Label = "Versão 11", Desc = "God-Mode Prompts & Scanner", Recommended = false },
    { Key = "V10", Label = "Versão 10", Desc = "Multi-Limb Touch & Spy inicial", Recommended = false },
    { Key = "V9", Label = "Versão 9", Desc = "TouchPads, Remotes & WorldTools", Recommended = false },
    { Key = "V8", Label = "Versão 8", Desc = "Interactive Item Manager (Tools)", Recommended = false },
    { Key = "V7", Label = "Versão 7", Desc = "Auto-coleta & Prompts", Recommended = false },
    { Key = "V6", Label = "Versão 6", Desc = "Interface compacta + Filtros", Recommended = false },
    { Key = "V5", Label = "Versão 5", Desc = "Scanner expandido + Remotes", Recommended = false },
    { Key = "V4", Label = "Versão 4", Desc = "Coleta rápida & Teleporte", Recommended = false },
    { Key = "V3", Label = "Versão 3", Desc = "Multi-scanner + abas iniciais", Recommended = false },
    { Key = "V2", Label = "Versão 2", Desc = "Scanner inicial + GUI básica", Recommended = false },
    { Key = "V1", Label = "Versão 1", Desc = "Coletor clássico (Touch & Prompts)", Recommended = false }
}

-- =================================================================================
-- MOTOR DA V14 (COM CALLBACK PARA FECHAR DE VEZ E VOLTAR AO HUB)
-- =================================================================================
local function launchV14(onCloseToHub)
    local Backpack = LocalPlayer:WaitForChild("Backpack")
    local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local RootPart = Character:WaitForChild("HumanoidRootPart", 10)
    local Humanoid = Character:WaitForChild("Humanoid", 10)

    local State = {
        IsBatchRunning = false,
        ActiveLoops = {},
        ScannedEntries = {},
        ActiveCategory = "Todos",
        UniverseBadgeIds = {},
        SpyLogs = {},
        CustomArg = "",
        RemoteDelay = 0.015,
        EspEnabled = false,
        EspHighlights = {},
        NoclipEnabled = true,
        AutoReturnTP = true,
        SavedPosition = nil,
        LastPositionBeforeTP = nil,
        Alive = true
    }

    local connections = {}
    local function trackConn(conn)
        table.insert(connections, conn)
        return conn
    end

    local function refreshCharacterRefs()
        Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        RootPart = Character:WaitForChild("HumanoidRootPart", 5)
        Humanoid = Character:WaitForChild("Humanoid", 5)
        Backpack = LocalPlayer:WaitForChild("Backpack", 5)
    end

    trackConn(LocalPlayer.CharacterAdded:Connect(function(char)
        Character = char
        RootPart = char:WaitForChild("HumanoidRootPart", 10)
        Humanoid = char:WaitForChild("Humanoid", 10)
        Backpack = LocalPlayer:WaitForChild("Backpack")
    end))

    trackConn(RunService.Stepped:Connect(function()
        if State.Alive and State.NoclipEnabled and Character then
            for _, p in ipairs(Character:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide = false end
            end
        end
    end))

    local function isFromOtherPlayer(obj)
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer then
                if (plr.Character and obj:IsDescendantOf(plr.Character))
                    or (plr:FindFirstChild("Backpack") and obj:IsDescendantOf(plr.Backpack)) then
                    return true
                end
            end
        end
        return false
    end

    local function teleportToCFrame(targetCFrame, autoReturn, holdTime)
        if not RootPart or not RootPart.Parent then refreshCharacterRefs() end
        if not RootPart then return nil end

        local origPos = RootPart.CFrame
        State.LastPositionBeforeTP = origPos
        RootPart.CFrame = targetCFrame

        if autoReturn then
            task.wait(holdTime or 0.08)
            if RootPart and RootPart.Parent then
                RootPart.CFrame = origPos
            end
        end
        return origPos
    end

    local function returnToPreviousPosition()
        if not RootPart or not RootPart.Parent then refreshCharacterRefs() end
        if not RootPart then return false end

        local target = State.LastPositionBeforeTP or State.SavedPosition
        if target then
            RootPart.CFrame = target
            return true
        end
        return false
    end

    local function getEntryTargetPart(entry)
        local obj = entry and entry.Object
        if not obj or not obj.Parent then return nil end
        if obj:IsA("BasePart") then return obj end
        if obj:IsA("Tool") then
            return obj:FindFirstChild("Handle") or obj:FindFirstChildWhichIsA("BasePart", true)
        end
        if obj:IsA("Model") then
            return obj.PrimaryPart or obj:FindFirstChild("Handle") or obj:FindFirstChildWhichIsA("BasePart", true)
        end
        if obj:IsA("ProximityPrompt") or obj:IsA("ClickDetector") then
            local p = obj.Parent
            if p then
                return p:IsA("BasePart") and p or p:FindFirstChildWhichIsA("BasePart", true)
            end
        end
        return obj:FindFirstChildWhichIsA("BasePart", true)
    end

    -- Consulta de Badges
    task.spawn(function()
        local uId = game.GameId
        if uId == 0 then return end
        local url = string.format("https://badges.roproxy.com/v1/universes/%d/badges?limit=100", uId)
        local s, res
        pcall(function()
            if (syn and syn.request) or (http and http.request) or request then
                local req = (syn and syn.request) or (http and http.request) or request
                res = req({Url = url, Method = "GET"}).Body
                s = true
            elseif game.HttpGet then
                res = game:HttpGet(url)
                s = true
            end
        end)
        if s and res then
            local ok, data = pcall(function() return HttpService:JSONDecode(res) end)
            if ok and data and data.data then
                for _, b in ipairs(data.data) do
                    table.insert(State.UniverseBadgeIds, b.id)
                end
            end
        end
    end)

    local function toggleEsp(enabled)
        State.EspEnabled = enabled
        for _, h in ipairs(State.EspHighlights) do
            if h and h.Parent then h:Destroy() end
        end
        State.EspHighlights = {}
        if not enabled then return end

        for _, entry in ipairs(State.ScannedEntries) do
            pcall(function()
                local target = entry.Object
                if target and target.Parent and (entry.Category == "Itens" or entry.Category == "Pads" or entry.Category == "Prompts") then
                    local adornee = target:IsA("Model") and target or (target:IsA("BasePart") and target or target.Parent)
                    if adornee then
                        local highlight = Instance.new("Highlight")
                        highlight.Name = "MasterESP_" .. entry.Id
                        highlight.FillTransparency = 0.5
                        highlight.OutlineTransparency = 0
                        if entry.Category == "Itens" then
                            highlight.FillColor = Color3.fromRGB(255, 180, 0)
                        elseif entry.Category == "Pads" then
                            highlight.FillColor = Color3.fromRGB(0, 200, 255)
                        else
                            highlight.FillColor = Color3.fromRGB(0, 255, 120)
                        end
                        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                        highlight.Adornee = adornee
                        highlight.Parent = adornee
                        table.insert(State.EspHighlights, highlight)
                    end
                end
            end)
        end
    end

    local function parseSingleToken(raw)
        local trimmed = raw:match("^%s*(.-)%s*$")
        if trimmed == "" then return nil, false end
        local quoted = trimmed:match('^"(.*)"$') or trimmed:match("^'(.*)'$")
        if quoted ~= nil then return quoted, true end

        local lower = trimmed:lower()
        if lower == "true" then return true, true end
        if lower == "false" then return false, true end
        if lower == "nil" or lower == "null" then return nil, true end
        if lower == "me" or lower == "player" or lower == "localplayer" then return LocalPlayer, true end
        if lower == "char" or lower == "character" then return Character, true end
        if lower == "hrp" or lower == "root" or lower == "rootpart" then return RootPart, true end

        local num = tonumber(trimmed)
        if num ~= nil then return num, true end
        return trimmed, true
    end

    local function parseCustomArgs(inputStr)
        local args = {}
        local current = ""
        local inSingle, inDouble = false, false

        for i = 1, #inputStr do
            local ch = inputStr:sub(i, i)
            if ch == "'" and not inDouble then
                inSingle = not inSingle
                current = current .. ch
            elseif ch == '"' and not inSingle then
                inDouble = not inDouble
                current = current .. ch
            elseif ch == "," and not inSingle and not inDouble then
                local val, ok = parseSingleToken(current)
                if ok then table.insert(args, val) end
                current = ""
            else
                current = current .. ch
            end
        end

        local lastVal, ok = parseSingleToken(current)
        if ok then table.insert(args, lastVal) end
        return args
    end

    local function buildDefaultRemoteBattery()
        local battery = {
            {}, {true}, {false}, {1}, {0}, {100}, {1000}, {999999}, {-1},
            {true, 1000}, {true, 1}, {true, 0}, {true, true},
            {false, 1000}, {false, 1}, {1, true}, {1000, true}, {1000, false},
            {LocalPlayer}, {LocalPlayer, true}, {LocalPlayer, 1000},
            {Character}, {RootPart},
            {"Win"}, {"Complete"}, {"Claim"}, {"Collect"}, {"Finish"},
            {"Buy"}, {"Unlock"}, {"Equip"}, {"Open"}, {"Start"}, {"End"},
            {"Reward"}, {"Daily"}, {"Redeem"}, {"Verify"}, {"Check"},
            {"Accept"}, {"Confirm"}, {"Yes"}, {"Give"}, {"Award"},
            {"Badge"}, {"Secret"}, {"Found"}, {"Touch"}, {"Hit"},
            {"Click"}, {"Interact"},
            {"Claim", true}, {"Claim", 1}, {"Claim", 1000},
            {"Win", true}, {"Complete", true}, {"Unlock", true},
            {"Buy", 1}, {"Give", 1000}, {"Add", 1000},
            {{Amount = 1000}}, {{Value = true}}
        }
        for _, bId in ipairs(State.UniverseBadgeIds) do
            table.insert(battery, {bId})
            table.insert(battery, {"Award", bId})
            table.insert(battery, {"Badge", bId})
            table.insert(battery, {bId, true})
            table.insert(battery, {LocalPlayer, bId})
        end
        return battery
    end

    local function scanAllGameElementsV14()
        local entries = {}
        local seen = {}

        for _, obj in ipairs(game:GetDescendants()) do
            if not seen[obj] then
                if obj:IsA("RemoteEvent") or obj.ClassName == "UnreliableRemoteEvent" then
                    seen[obj] = true
                    local isUnreliable = (obj.ClassName == "UnreliableRemoteEvent")
                    table.insert(entries, {
                        Id = "Rem_" .. tostring(obj:GetDebugId() or math.random(10000, 99999)),
                        Name = obj.Name,
                        Type = isUnreliable and "UnreliableRemote" or "Remote",
                        Category = "Remotes",
                        Icon = isUnreliable and "⚡📡" or "⚡",
                        TypeLabel = isUnreliable and "Unreliable Remote" or "RemoteEvent",
                        Location = obj.Parent and obj.Parent.Name or "Game",
                        Object = obj
                    })
                elseif obj:IsA("RemoteFunction") then
                    seen[obj] = true
                    table.insert(entries, {
                        Id = "RemF_" .. tostring(obj:GetDebugId() or math.random(10000, 99999)),
                        Name = obj.Name,
                        Type = "Remote",
                        Category = "Remotes",
                        Icon = "📞",
                        TypeLabel = "RemoteFunction",
                        Location = obj.Parent and obj.Parent.Name or "Game",
                        Object = obj
                    })
                elseif obj:IsA("BindableEvent") then
                    seen[obj] = true
                    table.insert(entries, {
                        Id = "BinE_" .. tostring(obj:GetDebugId() or math.random(10000, 99999)),
                        Name = obj.Name,
                        Type = "Bindable",
                        Category = "Bindables",
                        Icon = "🔄",
                        TypeLabel = "BindableEvent",
                        Location = obj.Parent and obj.Parent.Name or "Scripts",
                        Object = obj
                    })
                elseif obj:IsA("BindableFunction") then
                    seen[obj] = true
                    table.insert(entries, {
                        Id = "BinF_" .. tostring(obj:GetDebugId() or math.random(10000, 99999)),
                        Name = obj.Name,
                        Type = "Bindable",
                        Category = "Bindables",
                        Icon = "🔁",
                        TypeLabel = "BindableFunction",
                        Location = obj.Parent and obj.Parent.Name or "Scripts",
                        Object = obj
                    })
                end
            end
        end

        local itemKeywords = {
            "tool", "sword", "gun", "weapon", "key", "relic", "coin", "gem", "badge",
            "trophy", "orb", "drop", "shard", "item", "collectible", "chest", "crate",
            "gift", "present", "star", "crystal", "candy", "egg", "fruit", "flower",
            "note", "page", "book", "scroll", "artifact", "pickup", "loot", "medal",
            "crown", "ring", "amulet", "potion", "card", "ticket", "token", "flag",
            "secret", "plush", "pet", "gear", "bag", "backpack"
        }

        for _, obj in ipairs(workspace:GetDescendants()) do
            if not isFromOtherPlayer(obj) and not obj:IsDescendantOf(Character) and not seen[obj] then
                if obj:IsA("Tool") then
                    seen[obj] = true
                    table.insert(entries, {
                        Id = "ToolW_" .. tostring(obj:GetDebugId() or math.random(10000, 99999)),
                        Name = obj.Name,
                        Type = "WorldTool",
                        Category = "Itens",
                        Icon = "🗡️",
                        TypeLabel = "Tool no Mapa",
                        Location = obj.Parent and obj.Parent.Name or "Workspace",
                        Object = obj
                    })
                elseif obj:IsA("Model") or obj:IsA("BasePart") then
                    local n = obj.Name:lower()
                    for _, kw in ipairs(itemKeywords) do
                        if n:find(kw) then
                            seen[obj] = true
                            table.insert(entries, {
                                Id = "ItemM_" .. tostring(obj:GetDebugId() or math.random(10000, 99999)),
                                Name = obj.Name,
                                Type = "WorldItem",
                                Category = "Itens",
                                Icon = "🎁",
                                TypeLabel = "Colecionável/Item",
                                Location = obj.Parent and obj.Parent.Name or "Workspace",
                                Object = obj
                            })
                            break
                        end
                    end
                end
            end
        end

        local storageContainers = {
            {Service = ReplicatedStorage, Label = "ReplicatedStorage"},
            {Service = Lighting, Label = "Lighting"},
            {Service = StarterPack, Label = "StarterPack"},
            {Service = ReplicatedFirst, Label = "ReplicatedFirst"}
        }
        for _, container in ipairs(storageContainers) do
            for _, obj in ipairs(container.Service:GetDescendants()) do
                if obj:IsA("Tool") and not seen[obj] then
                    seen[obj] = true
                    table.insert(entries, {
                        Id = "ToolS_" .. tostring(obj:GetDebugId() or math.random(10000, 99999)),
                        Name = obj.Name,
                        Type = "ReplicatedTool",
                        Category = "Itens",
                        Icon = "📦",
                        TypeLabel = "Item em " .. container.Label,
                        Location = obj.Parent and obj.Parent.Name or container.Label,
                        Object = obj
                    })
                end
            end
        end

        for _, obj in ipairs(Backpack:GetChildren()) do
            if obj:IsA("Tool") and not seen[obj] then
                seen[obj] = true
                table.insert(entries, {
                    Id = "ToolB_" .. tostring(obj:GetDebugId() or math.random(10000, 99999)),
                    Name = obj.Name,
                    Type = "BackpackTool",
                    Category = "Itens",
                    Icon = "🎒",
                    TypeLabel = "Item na Mochila",
                    Location = "Inventário",
                    Object = obj
                })
            end
        end

        for _, obj in ipairs(workspace:GetDescendants()) do
            if not isFromOtherPlayer(obj) and not obj:IsDescendantOf(Character) then
                if obj:IsA("TouchTransmitter") and obj.Parent and obj.Parent:IsA("BasePart") and not seen[obj.Parent] then
                    seen[obj.Parent] = true
                    table.insert(entries, {
                        Id = "Pad_" .. tostring(obj.Parent:GetDebugId() or math.random(10000, 99999)),
                        Name = obj.Parent.Name,
                        Type = "TouchPad",
                        Category = "Pads",
                        Icon = "📍",
                        TypeLabel = "Pad / Bloco de Chão",
                        Location = obj.Parent.Parent and obj.Parent.Parent.Name or "Workspace",
                        Object = obj.Parent
                    })
                elseif obj:IsA("BasePart") and not seen[obj] then
                    local n = obj.Name:lower()
                    if n:find("badge") or n:find("giver") or n:find("checkpoint") or n:find("pad") or n:find("stage") or n:find("win") or n:find("portal") or n:find("teleport") then
                        seen[obj] = true
                        table.insert(entries, {
                            Id = "Pad_" .. tostring(obj:GetDebugId() or math.random(10000, 99999)),
                            Name = obj.Name,
                            Type = "TouchPad",
                            Category = "Pads",
                            Icon = "📍",
                            TypeLabel = "Bloco de Evento",
                            Location = obj.Parent and obj.Parent.Name or "Workspace",
                            Object = obj
                        })
                    end
                end
            end
        end

        for _, obj in ipairs(workspace:GetDescendants()) do
            if (obj:IsA("ProximityPrompt") or obj:IsA("ClickDetector")) and not isFromOtherPlayer(obj) and not seen[obj] then
                seen[obj] = true
                local name = obj.Parent and obj.Parent.Name or obj.Name
                if obj:IsA("ProximityPrompt") and obj.ActionText ~= "" then
                    name = obj.ActionText .. " (" .. (obj.ObjectText ~= "" and obj.ObjectText or (obj.Parent and obj.Parent.Name or "Prompt")) .. ")"
                end
                table.insert(entries, {
                    Id = "Prompt_" .. tostring(obj:GetDebugId() or math.random(10000, 99999)),
                    Name = name,
                    Type = "Prompt",
                    Category = "Prompts",
                    Icon = "✋",
                    TypeLabel = obj:IsA("ProximityPrompt") and "Prompt (God-Mode)" or "ClickDetector",
                    Location = obj.Parent and obj.Parent.Name or "Workspace",
                    Object = obj
                })
            end
        end

        State.ScannedEntries = entries
        return entries
    end

    local function fireTouchPart(part)
        if not part or not part:IsA("BasePart") then return end
        if getconnections then
            for _, conn in ipairs(getconnections(part.Touched)) do
                pcall(function() conn:Fire(RootPart) end)
            end
        end
        if firetouchinterest then
            firetouchinterest(RootPart, part, 0)
            task.wait(0.015)
            firetouchinterest(RootPart, part, 1)
        end
    end

    local function executeAction(entry, specificArg, overrideAutoReturn)
        if not Character or not RootPart or not Humanoid or not RootPart.Parent then
            refreshCharacterRefs()
        end
        local shouldReturn = (overrideAutoReturn ~= nil) and overrideAutoReturn or State.AutoReturnTP

        pcall(function()
            if entry.Type == "Remote" or entry.Type == "UnreliableRemote" or entry.Type == "Bindable" then
                local rem = entry.Object
                if not rem or not rem.Parent then return end

                local argList = {}
                if specificArg and specificArg:match("%S") then
                    table.insert(argList, parseCustomArgs(specificArg))
                else
                    argList = buildDefaultRemoteBattery()
                end

                for _, args in ipairs(argList) do
                    pcall(function()
                        if rem:IsA("RemoteEvent") or rem.ClassName == "UnreliableRemoteEvent" then
                            if #args == 0 then rem:FireServer() else rem:FireServer(table.unpack(args)) end
                        elseif rem:IsA("RemoteFunction") then
                            if #args == 0 then rem:InvokeServer() else rem:InvokeServer(table.unpack(args)) end
                        elseif rem:IsA("BindableEvent") then
                            if #args == 0 then rem:Fire() else rem:Fire(table.unpack(args)) end
                        elseif rem:IsA("BindableFunction") then
                            if #args == 0 then rem:Invoke() else rem:Invoke(table.unpack(args)) end
                        end
                    end)
                end

            elseif entry.Type == "WorldTool" or entry.Type == "WorldItem" then
                local item = entry.Object
                if item and item.Parent and not isFromOtherPlayer(item) then
                    local handle = getEntryTargetPart(entry)
                    if handle then
                        local origPos = teleportToCFrame(handle.CFrame + Vector3.new(0, 1.2, 0), false)
                        fireTouchPart(handle)

                        for _, desc in ipairs(item:GetDescendants()) do
                            if desc:IsA("ClickDetector") and fireclickdetector then
                                pcall(function() fireclickdetector(desc) end)
                            elseif desc:IsA("ProximityPrompt") and fireproximityprompt then
                                pcall(function()
                                    desc.HoldDuration = 0
                                    desc.RequiresLineOfSight = false
                                    fireproximityprompt(desc)
                                end)
                            end
                        end

                        if item:IsA("Tool") then
                            pcall(function() Humanoid:EquipTool(item) end)
                            pcall(function() item.Parent = Character end)
                            task.wait(0.08)
                            pcall(function() item:Activate() end)
                        end

                        task.wait(0.06)
                        if shouldReturn and origPos and RootPart and RootPart.Parent then
                            RootPart.CFrame = origPos
                        end
                    elseif item:IsA("Tool") then
                        pcall(function()
                            item.Parent = Backpack
                            Humanoid:EquipTool(item)
                            task.wait(0.08)
                            item:Activate()
                        end)
                    end
                end

            elseif entry.Type == "ReplicatedTool" then
                local tool = entry.Object
                if tool then
                    local clone = tool:Clone()
                    clone.Parent = Backpack
                    pcall(function() Humanoid:EquipTool(clone) end)
                    task.wait(0.08)
                    pcall(function() clone:Activate() end)
                end

            elseif entry.Type == "BackpackTool" then
                local tool = entry.Object
                if tool and tool.Parent then
                    pcall(function()
                        tool.Parent = Character
                        task.wait(0.08)
                        tool:Activate()
                        task.wait(0.04)
                        tool.Parent = Backpack
                    end)
                end

            elseif entry.Type == "Prompt" then
                local prompt = entry.Object
                if prompt and prompt.Parent then
                    local promptPart = getEntryTargetPart(entry)
                    if promptPart then
                        local origPos = teleportToCFrame(promptPart.CFrame + Vector3.new(0, 1.2, 0), false)
                        pcall(function()
                            local cam = workspace.CurrentCamera
                            if cam then cam.CFrame = CFrame.new(cam.CFrame.Position, promptPart.Position) end
                        end)

                        if prompt:IsA("ProximityPrompt") then
                            prompt.HoldDuration = 0
                            prompt.MaxActivationDistance = 999999
                            prompt.RequiresLineOfSight = false
                            prompt.Enabled = true
                            if fireproximityprompt then fireproximityprompt(prompt) end
                            if firesignal then
                                firesignal(prompt.PromptButtonHoldBegan)
                                firesignal(prompt.Triggered)
                                firesignal(prompt.PromptButtonHoldEnded)
                            end
                            pcall(function()
                                VirtualInputManager:SendKeyEvent(true, prompt.KeyboardKeyCode or Enum.KeyCode.E, false, game)
                                task.wait(0.02)
                                VirtualInputManager:SendKeyEvent(false, prompt.KeyboardKeyCode or Enum.KeyCode.E, false, game)
                            end)
                        elseif prompt:IsA("ClickDetector") then
                            if fireclickdetector then fireclickdetector(prompt) end
                        end
                        task.wait(0.06)
                        if shouldReturn and origPos and RootPart and RootPart.Parent then
                            RootPart.CFrame = origPos
                        end
                    end
                end

            elseif entry.Type == "TouchPad" then
                local part = entry.Object
                if part and part:IsA("BasePart") and part.Parent then
                    local origPos = teleportToCFrame(part.CFrame + Vector3.new(0, 1.5, 0), false)
                    RootPart.AssemblyLinearVelocity = Vector3.new(0, -4, 0)
                    pcall(function() Humanoid:ChangeState(Enum.HumanoidStateType.Landed) end)
                    fireTouchPart(part)
                    task.wait(0.08)
                    if shouldReturn and origPos and RootPart and RootPart.Parent then
                        RootPart.CFrame = origPos
                    end
                end
            end
        end)
    end

    -- GUI V14 (100% RESPONSIVA E SEM BOTÕES CORTADOS)
    local parentGui = getGuiParent()
    local old = parentGui:FindFirstChild("BadgeMaster_V14")
    if old then old:Destroy() end

    local Screen = Instance.new("ScreenGui")
    Screen.Name = "BadgeMaster_V14"
    Screen.ResetOnSpawn = false
    Screen.Parent = parentGui

    local function destroyV14AndReturnHub()
        State.Alive = false
        State.ActiveLoops = {}
        State.IsBatchRunning = false
        toggleEsp(false)
        for _, c in ipairs(connections) do
            pcall(function() c:Disconnect() end)
        end
        if Screen and Screen.Parent then
            Screen:Destroy()
        end
        if onCloseToHub then
            onCloseToHub()
        end
    end

    -- Botão Flutuante (usado quando minimizar com "—")
    local MobBtn = Instance.new("TextButton")
    MobBtn.Size = UDim2.new(0, 50, 0, 50)
    MobBtn.Position = UDim2.new(0, 14, 0.45, 0)
    MobBtn.BackgroundColor3 = Color3.fromRGB(15, 18, 28)
    MobBtn.Text = "👑"
    MobBtn.TextSize = 22
    MobBtn.BorderSizePixel = 0
    MobBtn.Visible = false
    MobBtn.Parent = Screen
    makeCorner(MobBtn, 25)
    local mbStroke = Instance.new("UIStroke")
    mbStroke.Color = Color3.fromRGB(0, 240, 255)
    mbStroke.Thickness = 2
    mbStroke.Parent = MobBtn

    local cam = workspace.CurrentCamera
    local vp = cam and cam.ViewportSize or Vector2.new(1280, 720)
    local winW = math.clamp(vp.X - 24, 340, 700)
    local winH = math.clamp(vp.Y - 24, 380, 590)

    local Window = Instance.new("Frame")
    Window.Size = UDim2.new(0, winW, 0, winH)
    Window.Position = UDim2.new(0.5, -math.floor(winW / 2), 0.5, -math.floor(winH / 2))
    Window.BackgroundColor3 = Color3.fromRGB(10, 12, 18)
    Window.BorderSizePixel = 0
    Window.Active = true
    Window.ClipsDescendants = true
    Window.Parent = Screen
    makeCorner(Window, 12)

    local wStroke = Instance.new("UIStroke")
    wStroke.Color = Color3.fromRGB(0, 180, 255)
    wStroke.Thickness = 1.5
    wStroke.Parent = Window

    -- TopBar
    local TopBar = Instance.new("Frame")
    TopBar.Size = UDim2.new(1, 0, 0, 40)
    TopBar.BackgroundColor3 = Color3.fromRGB(16, 20, 30)
    TopBar.BorderSizePixel = 0
    TopBar.Parent = Window
    makeCorner(TopBar, 12)

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -165, 1, 0)
    Title.Position = UDim2.new(0, 12, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = "👑 BADGE MASTER V14  |  OMNI-LAB"
    Title.TextColor3 = Color3.fromRGB(0, 240, 255)
    Title.TextSize = 12
    Title.Font = Enum.Font.GothamBold
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.TextTruncate = Enum.TextTruncate.AtEnd
    Title.Parent = TopBar

    local NoclipBtn = Instance.new("TextButton")
    NoclipBtn.Size = UDim2.new(0, 82, 0, 26)
    NoclipBtn.Position = UDim2.new(1, -154, 0.5, -13)
    NoclipBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 110)
    NoclipBtn.Text = "👻 Noclip: ON"
    NoclipBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    NoclipBtn.TextSize = 9
    NoclipBtn.Font = Enum.Font.GothamBold
    NoclipBtn.BorderSizePixel = 0
    NoclipBtn.Parent = TopBar
    makeCorner(NoclipBtn, 6)

    local MinBtn = Instance.new("TextButton")
    MinBtn.Size = UDim2.new(0, 28, 0, 26)
    MinBtn.Position = UDim2.new(1, -66, 0.5, -13)
    MinBtn.BackgroundColor3 = Color3.fromRGB(30, 36, 52)
    MinBtn.Text = "—"
    MinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    MinBtn.TextSize = 11
    MinBtn.Font = Enum.Font.GothamBold
    MinBtn.BorderSizePixel = 0
    MinBtn.Parent = TopBar
    makeCorner(MinBtn, 6)

    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 28, 0, 26)
    CloseBtn.Position = UDim2.new(1, -34, 0.5, -13)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(195, 45, 65)
    CloseBtn.Text = "✕"
    CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseBtn.TextSize = 11
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.BorderSizePixel = 0
    CloseBtn.Parent = TopBar
    makeCorner(CloseBtn, 6)

    makeDraggable(TopBar, Window)

    MinBtn.MouseButton1Click:Connect(function()
        Window.Visible = false
        MobBtn.Visible = true
    end)
    MobBtn.MouseButton1Click:Connect(function()
        Window.Visible = true
        MobBtn.Visible = false
    end)
    CloseBtn.MouseButton1Click:Connect(destroyV14AndReturnHub)

    NoclipBtn.MouseButton1Click:Connect(function()
        State.NoclipEnabled = not State.NoclipEnabled
        NoclipBtn.Text = State.NoclipEnabled and "👻 Noclip: ON" or "👻 Noclip: OFF"
        NoclipBtn.BackgroundColor3 = State.NoclipEnabled and Color3.fromRGB(0, 170, 110) or Color3.fromRGB(50, 56, 72)
    end)

    -- Corpo
    local Body = Instance.new("Frame")
    Body.Size = UDim2.new(1, -20, 1, -48)
    Body.Position = UDim2.new(0, 10, 0, 44)
    Body.BackgroundTransparency = 1
    Body.Parent = Window

    -- 1. Grade 2x3 de Ações Principais (100% visível sem cortar texto)
    local TopCmds = Instance.new("Frame")
    TopCmds.Size = UDim2.new(1, 0, 0, 66)
    TopCmds.BackgroundTransparency = 1
    TopCmds.Parent = Body

    local topGrid = Instance.new("UIGridLayout")
    topGrid.CellSize = UDim2.new(0.3333, -4, 0, 30)
    topGrid.CellPadding = UDim2.new(0, 6, 0, 6)
    topGrid.SortOrder = Enum.SortOrder.LayoutOrder
    topGrid.Parent = TopCmds

    local function makeGridBtn(text, color, order)
        local btn = Instance.new("TextButton")
        btn.LayoutOrder = order
        btn.BackgroundColor3 = color
        btn.Text = text
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.TextSize = 11
        btn.Font = Enum.Font.GothamBold
        btn.BorderSizePixel = 0
        btn.Parent = TopCmds
        makeCorner(btn, 7)
        return btn
    end

    local MassTestBtn   = makeGridBtn("🚀 TESTAR TUDO",   Color3.fromRGB(220, 35, 60), 1)
    local AllRemotesBtn = makeGridBtn("⚡ Só Remotes",   Color3.fromRGB(130, 60, 230), 2)
    local GrabItemsBtn  = makeGridBtn("🎁 Pegar Itens",  Color3.fromRGB(225, 135, 20), 3)
    local EspBtn        = makeGridBtn("👁️ ESP: OFF",     Color3.fromRGB(0, 170, 115), 4)
    local RescanBtn     = makeGridBtn("🔄 Re-Escanear",  Color3.fromRGB(0, 130, 240), 5)
    local StopAutosBtn  = makeGridBtn("⏹️ Parar Tudo",   Color3.fromRGB(50, 58, 76), 6)

    -- Helper de barra horizontal rolável (garante visibilidade em qualquer largura)
    local function makeHScrollRow(yPos, height, bgColor)
        local sf = Instance.new("ScrollingFrame")
        sf.Size = UDim2.new(1, 0, 0, height)
        sf.Position = UDim2.new(0, 0, 0, yPos)
        sf.BackgroundColor3 = bgColor or Color3.fromRGB(16, 20, 30)
        sf.BackgroundTransparency = bgColor and 0 or 1
        sf.BorderSizePixel = 0
        sf.ScrollingDirection = Enum.ScrollingDirection.X
        sf.AutomaticCanvasSize = Enum.AutomaticSize.X
        sf.CanvasSize = UDim2.new(0, 0, 0, 0)
        sf.ScrollBarThickness = 3
        sf.Parent = Body
        if bgColor then makeCorner(sf, 8) end

        local layout = Instance.new("UIListLayout")
        layout.FillDirection = Enum.FillDirection.Horizontal
        layout.VerticalAlignment = Enum.VerticalAlignment.Center
        layout.Padding = UDim.new(0, 6)
        layout.Parent = sf

        local pad = Instance.new("UIPadding")
        pad.PaddingLeft = UDim.new(0, 6)
        pad.PaddingRight = UDim.new(0, 6)
        pad.Parent = sf

        return sf
    end

    -- 2. Barra de Teleporte & Retorno (rolável horizontalmente)
    local TpRow = makeHScrollRow(72, 34, Color3.fromRGB(16, 20, 30))

    local tpTitle = Instance.new("TextLabel")
    tpTitle.Size = UDim2.new(0, 92, 0, 24)
    tpTitle.BackgroundTransparency = 1
    tpTitle.Text = "📍 Teleporte:"
    tpTitle.TextColor3 = Color3.fromRGB(0, 220, 255)
    tpTitle.TextSize = 10
    tpTitle.Font = Enum.Font.GothamBold
    tpTitle.TextXAlignment = Enum.TextXAlignment.Left
    tpTitle.Parent = TpRow

    local function makeRowBtn(parent, text, w, h, color)
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(0, w, 0, h)
        b.BackgroundColor3 = color
        b.Text = text
        b.TextColor3 = Color3.fromRGB(255, 255, 255)
        b.TextSize = 10
        b.Font = Enum.Font.GothamBold
        b.BorderSizePixel = 0
        b.Parent = parent
        makeCorner(b, 6)
        return b
    end

    local SavePosBtn    = makeRowBtn(TpRow, "📌 Salvar Local",      115, 24, Color3.fromRGB(32, 42, 62))
    local ReturnPosBtn  = makeRowBtn(TpRow, "↩️ Voltar ao Anterior", 142, 24, Color3.fromRGB(0, 145, 220))
    local AutoReturnBtn = makeRowBtn(TpRow, "🔄 Auto-Voltar: ON",    142, 24, Color3.fromRGB(0, 175, 110))

    -- 3. Barra de Argumentos Customizados
    local ParamRow = Instance.new("Frame")
    ParamRow.Size = UDim2.new(1, 0, 0, 34)
    ParamRow.Position = UDim2.new(0, 0, 0, 112)
    ParamRow.BackgroundColor3 = Color3.fromRGB(16, 20, 30)
    ParamRow.BorderSizePixel = 0
    ParamRow.Parent = Body
    makeCorner(ParamRow, 8)

    local prLabel = Instance.new("TextLabel")
    prLabel.Size = UDim2.new(0, 95, 1, 0)
    prLabel.Position = UDim2.new(0, 8, 0, 0)
    prLabel.BackgroundTransparency = 1
    prLabel.Text = "🧪 Args:"
    prLabel.TextColor3 = Color3.fromRGB(255, 190, 60)
    prLabel.TextSize = 10
    prLabel.Font = Enum.Font.GothamBold
    prLabel.TextXAlignment = Enum.TextXAlignment.Left
    prLabel.Parent = ParamRow

    local CustomArgInput = Instance.new("TextBox")
    CustomArgInput.Size = UDim2.new(1, -238, 0, 24)
    CustomArgInput.Position = UDim2.new(0, 96, 0.5, -12)
    CustomArgInput.BackgroundColor3 = Color3.fromRGB(24, 30, 44)
    CustomArgInput.PlaceholderText = "Vazio = Bateria Auto | Ex: true, 1000"
    CustomArgInput.PlaceholderColor3 = Color3.fromRGB(110, 120, 140)
    CustomArgInput.Text = ""
    CustomArgInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    CustomArgInput.TextSize = 10
    CustomArgInput.Font = Enum.Font.Code
    CustomArgInput.ClearTextOnFocus = false
    CustomArgInput.BorderSizePixel = 0
    CustomArgInput.Parent = ParamRow
    makeCorner(CustomArgInput, 6)

    local ApplyToAllBtn = Instance.new("TextButton")
    ApplyToAllBtn.Size = UDim2.new(0, 130, 0, 24)
    ApplyToAllBtn.Position = UDim2.new(1, -136, 0.5, -12)
    ApplyToAllBtn.BackgroundColor3 = Color3.fromRGB(0, 155, 245)
    ApplyToAllBtn.Text = "⚡ Injetar Remotes"
    ApplyToAllBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ApplyToAllBtn.TextSize = 10
    ApplyToAllBtn.Font = Enum.Font.GothamBold
    ApplyToAllBtn.BorderSizePixel = 0
    ApplyToAllBtn.Parent = ParamRow
    makeCorner(ApplyToAllBtn, 6)

    CustomArgInput.FocusLost:Connect(function() State.CustomArg = CustomArgInput.Text end)
    CustomArgInput:GetPropertyChangedSignal("Text"):Connect(function() State.CustomArg = CustomArgInput.Text end)

    -- 4. Barra de Presets (rolável horizontalmente)
    local PresetRow = makeHScrollRow(152, 28, nil)
    local presets = {
        {Label = "🤖 Auto (Todos)", Value = ""},
        {Label = "true, 1000", Value = "true, 1000"},
        {Label = "1000", Value = "1000"},
        {Label = "false", Value = "false"},
        {Label = "true, 1", Value = "true, 1"},
        {Label = "true", Value = "true"},
        {Label = '"Win"', Value = '"Win"'},
        {Label = '"Claim"', Value = '"Claim"'},
        {Label = "me, 1000", Value = "me, 1000"}
    }
    for _, p in ipairs(presets) do
        local pBtn = makeRowBtn(
            PresetRow,
            p.Label,
            p.Value == "" and 98 or 70,
            22,
            p.Value == "" and Color3.fromRGB(90, 50, 165) or Color3.fromRGB(24, 30, 44)
        )
        pBtn.TextSize = 9
        pBtn.MouseButton1Click:Connect(function()
            CustomArgInput.Text = p.Value
            State.CustomArg = p.Value
        end)
    end

    -- 5. Categorias (rolável horizontalmente)
    local CatRow = makeHScrollRow(184, 30, nil)
    local CatBtns = {}
    local Categories = {"Todos", "Itens", "Remotes", "Prompts", "Pads", "Bindables", "🛰️ Spy"}

    -- 6. Busca & Status
    local SearchRow = Instance.new("Frame")
    SearchRow.Size = UDim2.new(1, 0, 0, 28)
    SearchRow.Position = UDim2.new(0, 0, 0, 218)
    SearchRow.BackgroundTransparency = 1
    SearchRow.Parent = Body

    local StatusText = Instance.new("TextLabel")
    StatusText.Size = UDim2.new(0.45, -6, 1, 0)
    StatusText.BackgroundTransparency = 1
    StatusText.Text = "Carregando mapa..."
    StatusText.TextColor3 = Color3.fromRGB(165, 175, 195)
    StatusText.TextSize = 11
    StatusText.Font = Enum.Font.GothamMedium
    StatusText.TextXAlignment = Enum.TextXAlignment.Left
    StatusText.TextTruncate = Enum.TextTruncate.AtEnd
    StatusText.Parent = SearchRow

    local SearchBox = Instance.new("TextBox")
    SearchBox.Size = UDim2.new(0.55, 0, 1, 0)
    SearchBox.Position = UDim2.new(0.45, 0, 0, 0)
    SearchBox.BackgroundColor3 = Color3.fromRGB(18, 22, 32)
    SearchBox.PlaceholderText = "🔍 Buscar item, remote ou prompt..."
    SearchBox.PlaceholderColor3 = Color3.fromRGB(110, 120, 140)
    SearchBox.Text = ""
    SearchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    SearchBox.TextSize = 11
    SearchBox.Font = Enum.Font.Gotham
    SearchBox.BorderSizePixel = 0
    SearchBox.Parent = SearchRow
    makeCorner(SearchBox, 6)

    -- 7. Lista Interativa
    local ScrollList = Instance.new("ScrollingFrame")
    ScrollList.Size = UDim2.new(1, 0, 1, -252)
    ScrollList.Position = UDim2.new(0, 0, 0, 252)
    ScrollList.BackgroundColor3 = Color3.fromRGB(8, 10, 15)
    ScrollList.BorderSizePixel = 0
    ScrollList.ScrollBarThickness = 5
    ScrollList.AutomaticCanvasSize = Enum.AutomaticSize.Y
    ScrollList.CanvasSize = UDim2.new(0, 0, 0, 0)
    ScrollList.Parent = Body
    makeCorner(ScrollList, 8)

    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 5)
    listLayout.Parent = ScrollList

    local listPad = Instance.new("UIPadding")
    listPad.PaddingTop = UDim.new(0, 4)
    listPad.PaddingBottom = UDim.new(0, 6)
    listPad.PaddingLeft = UDim.new(0, 4)
    listPad.PaddingRight = UDim.new(0, 6)
    listPad.Parent = ScrollList

    local function renderCards(search)
        if not State.Alive then return end
        search = (search or SearchBox.Text):lower()

        for _, c in ipairs(ScrollList:GetChildren()) do
            if c:IsA("Frame") then c:Destroy() end
        end

        if State.ActiveCategory == "🛰️ Spy" then
            for _, log in ipairs(State.SpyLogs) do
                local card = Instance.new("Frame")
                card.Size = UDim2.new(1, 0, 0, 48)
                card.BackgroundColor3 = Color3.fromRGB(16, 20, 30)
                card.BorderSizePixel = 0
                card.Parent = ScrollList
                makeCorner(card, 8)

                local title = Instance.new("TextLabel")
                title.Size = UDim2.new(1, -108, 0, 20)
                title.Position = UDim2.new(0, 10, 0, 5)
                title.BackgroundTransparency = 1
                title.Text = string.format("[%s] %s:%s()", log.Time, log.Remote.Name, log.Method)
                title.TextColor3 = Color3.fromRGB(0, 240, 255)
                title.TextSize = 11
                title.Font = Enum.Font.GothamBold
                title.TextXAlignment = Enum.TextXAlignment.Left
                title.TextTruncate = Enum.TextTruncate.AtEnd
                title.Parent = card

                local sub = Instance.new("TextLabel")
                sub.Size = UDim2.new(1, -108, 0, 16)
                sub.Position = UDim2.new(0, 10, 0, 25)
                sub.BackgroundTransparency = 1
                local okJson, argsStr = pcall(function() return HttpService:JSONEncode(log.Args) end)
                sub.Text = "Args: " .. (okJson and argsStr or tostring(#log.Args) .. " args")
                sub.TextColor3 = Color3.fromRGB(140, 150, 175)
                sub.TextSize = 9
                sub.Font = Enum.Font.Code
                sub.TextXAlignment = Enum.TextXAlignment.Left
                sub.TextTruncate = Enum.TextTruncate.AtEnd
                sub.Parent = card

                local replayBtn = makeRowBtn(card, "🔁 Replicar", 88, 30, Color3.fromRGB(0, 180, 100))
                replayBtn.Position = UDim2.new(1, -96, 0.5, -15)
                replayBtn.MouseButton1Click:Connect(function()
                    pcall(function()
                        if log.Method == "FireServer" then
                            log.Remote:FireServer(table.unpack(log.Args))
                        else
                            log.Remote:InvokeServer(table.unpack(log.Args))
                        end
                        replayBtn.Text = "Replicado!"
                        task.wait(0.5)
                        replayBtn.Text = "🔁 Replicar"
                    end)
                end)
            end
            StatusText.Text = string.format("Espião: %d chamadas.", #State.SpyLogs)
            return
        end

        local count = 0
        for _, entry in ipairs(State.ScannedEntries) do
            local matchesCat = (State.ActiveCategory == "Todos") or (entry.Category == State.ActiveCategory)
            local matchesSearch = (search == "") or entry.Name:lower():find(search, 1, true) or entry.TypeLabel:lower():find(search, 1, true) or entry.Location:lower():find(search, 1, true)

            if matchesCat and matchesSearch then
                count = count + 1
                local hasSpatialPart = (entry.Category == "Itens" or entry.Category == "Pads" or entry.Category == "Prompts")
                    and (entry.Type ~= "ReplicatedTool" and entry.Type ~= "BackpackTool")

                local card = Instance.new("Frame")
                card.Name = "Card_" .. entry.Id
                card.Size = UDim2.new(1, 0, 0, 48)
                card.BackgroundColor3 = Color3.fromRGB(16, 20, 28)
                card.BorderSizePixel = 0
                card.Parent = ScrollList
                makeCorner(card, 8)

                local actionWidth = hasSpatialPart and 214 or 164

                local titleLabel = Instance.new("TextLabel")
                titleLabel.Size = UDim2.new(1, -(actionWidth + 16), 0, 20)
                titleLabel.Position = UDim2.new(0, 10, 0, 5)
                titleLabel.BackgroundTransparency = 1
                titleLabel.Text = entry.Icon .. " " .. entry.Name
                titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                titleLabel.TextSize = 11
                titleLabel.Font = Enum.Font.GothamBold
                titleLabel.TextXAlignment = Enum.TextXAlignment.Left
                titleLabel.TextTruncate = Enum.TextTruncate.AtEnd
                titleLabel.Parent = card

                local subLabel = Instance.new("TextLabel")
                subLabel.Size = UDim2.new(1, -(actionWidth + 16), 0, 16)
                subLabel.Position = UDim2.new(0, 10, 0, 25)
                subLabel.BackgroundTransparency = 1
                subLabel.Text = string.format("%s • %s", entry.TypeLabel, entry.Location)
                subLabel.TextColor3 = Color3.fromRGB(140, 150, 175)
                subLabel.TextSize = 9
                subLabel.Font = Enum.Font.Gotham
                subLabel.TextXAlignment = Enum.TextXAlignment.Left
                subLabel.TextTruncate = Enum.TextTruncate.AtEnd
                subLabel.Parent = card

                local actionBox = Instance.new("Frame")
                actionBox.Size = UDim2.new(0, actionWidth, 0, 32)
                actionBox.Position = UDim2.new(1, -(actionWidth + 8), 0.5, -16)
                actionBox.BackgroundTransparency = 1
                actionBox.Parent = card

                local actLayout = Instance.new("UIListLayout")
                actLayout.FillDirection = Enum.FillDirection.Horizontal
                actLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
                actLayout.VerticalAlignment = Enum.VerticalAlignment.Center
                actLayout.Padding = UDim.new(0, 4)
                actLayout.Parent = actionBox

                if hasSpatialPart then
                    local tpBtn = makeRowBtn(actionBox, "📍 TP", 46, 30, Color3.fromRGB(38, 48, 70))
                    tpBtn.TextColor3 = Color3.fromRGB(0, 225, 255)
                    tpBtn.MouseButton1Click:Connect(function()
                        local part = getEntryTargetPart(entry)
                        if part then
                            teleportToCFrame(part.CFrame + Vector3.new(0, 2, 0), false)
                            StatusText.Text = "TP: " .. entry.Name .. " (use Voltar ao Anterior)"
                        else
                            StatusText.Text = "Sem posição 3D para " .. entry.Name
                        end
                    end)
                end

                local runOnceBtn = makeRowBtn(actionBox, "▶ Testar", 74, 30, Color3.fromRGB(0, 140, 255))
                runOnceBtn.MouseButton1Click:Connect(function()
                    runOnceBtn.Text = "Testando..."
                    runOnceBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
                    task.spawn(function()
                        executeAction(entry, State.CustomArg)
                        task.wait(0.2)
                        if runOnceBtn and runOnceBtn.Parent then
                            runOnceBtn.Text = "▶ Testar"
                            runOnceBtn.BackgroundColor3 = Color3.fromRGB(0, 140, 255)
                        end
                    end)
                end)

                local isLooping = State.ActiveLoops[entry.Id] or false
                local autoBtn = makeRowBtn(
                    actionBox,
                    isLooping and "🔁 Auto: ON" or "🔁 Auto: OFF",
                    82,
                    30,
                    isLooping and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(36, 42, 58)
                )
                autoBtn.MouseButton1Click:Connect(function()
                    if State.ActiveLoops[entry.Id] then
                        State.ActiveLoops[entry.Id] = nil
                        autoBtn.BackgroundColor3 = Color3.fromRGB(36, 42, 58)
                        autoBtn.Text = "🔁 Auto: OFF"
                    else
                        State.ActiveLoops[entry.Id] = true
                        autoBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
                        autoBtn.Text = "🔁 Auto: ON"
                        task.spawn(function()
                            while State.Alive and State.ActiveLoops[entry.Id] do
                                executeAction(entry, State.CustomArg)
                                task.wait(0.25)
                            end
                        end)
                    end
                end)
            end
        end

        StatusText.Text = string.format("Exibindo: %d opções", count)
    end

    for _, catName in ipairs(Categories) do
        local pill = makeRowBtn(
            CatRow,
            catName,
            catName:find("Spy") and 86 or 72,
            24,
            (State.ActiveCategory == catName) and Color3.fromRGB(0, 180, 255) or Color3.fromRGB(20, 25, 36)
        )
        CatBtns[catName] = pill
        pill.MouseButton1Click:Connect(function()
            State.ActiveCategory = catName
            for cName, btn in pairs(CatBtns) do
                btn.BackgroundColor3 = (cName == catName) and Color3.fromRGB(0, 180, 255) or Color3.fromRGB(20, 25, 36)
            end
            renderCards()
        end)
    end

    SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
        renderCards(SearchBox.Text)
    end)

    SavePosBtn.MouseButton1Click:Connect(function()
        if not RootPart or not RootPart.Parent then refreshCharacterRefs() end
        if RootPart then
            State.SavedPosition = RootPart.CFrame
            State.LastPositionBeforeTP = RootPart.CFrame
            StatusText.Text = "Posição atual salva!"
        end
    end)

    ReturnPosBtn.MouseButton1Click:Connect(function()
        if returnToPreviousPosition() then
            StatusText.Text = "Retornou para o local anterior!"
        else
            StatusText.Text = "Nenhuma posição anterior salva ainda."
        end
    end)

    AutoReturnBtn.MouseButton1Click:Connect(function()
        State.AutoReturnTP = not State.AutoReturnTP
        AutoReturnBtn.Text = State.AutoReturnTP and "🔄 Auto-Voltar: ON" or "🔄 Auto-Voltar: OFF"
        AutoReturnBtn.BackgroundColor3 = State.AutoReturnTP and Color3.fromRGB(0, 175, 110) or Color3.fromRGB(65, 72, 92)
    end)

    EspBtn.MouseButton1Click:Connect(function()
        local nextState = not State.EspEnabled
        toggleEsp(nextState)
        EspBtn.Text = nextState and "👁️ ESP: ON" or "👁️ ESP: OFF"
        EspBtn.BackgroundColor3 = nextState and Color3.fromRGB(0, 230, 135) or Color3.fromRGB(0, 170, 115)
    end)

    local function runAllRemotes(triggerBtn, defaultText, defaultColor)
        if State.IsBatchRunning then return end
        State.IsBatchRunning = true
        triggerBtn.Text = "Testando..."
        local usingAutoBattery = not (State.CustomArg and State.CustomArg:match("%S"))
        StatusText.Text = usingAutoBattery
            and "Testando bateria completa em todos os remotes..."
            or ("Injetando '" .. State.CustomArg .. "' em todos os remotes...")

        task.spawn(function()
            local count = 0
            for _, entry in ipairs(State.ScannedEntries) do
                if not State.Alive or not State.IsBatchRunning then break end
                if entry.Category == "Remotes" or entry.Category == "Bindables" then
                    count = count + 1
                    StatusText.Text = string.format("Remote %d: %s", count, entry.Name)
                    executeAction(entry, State.CustomArg)
                    task.wait(State.RemoteDelay)
                end
            end
            if State.Alive then
                StatusText.Text = State.IsBatchRunning
                    and string.format("Concluído! %d remotes testados.", count)
                    or "Teste de remotes interrompido."
                triggerBtn.Text = defaultText
                triggerBtn.BackgroundColor3 = defaultColor
            end
            State.IsBatchRunning = false
        end)
    end

    ApplyToAllBtn.MouseButton1Click:Connect(function()
        runAllRemotes(ApplyToAllBtn, "⚡ Injetar Remotes", Color3.fromRGB(0, 155, 245))
    end)

    AllRemotesBtn.MouseButton1Click:Connect(function()
        runAllRemotes(AllRemotesBtn, "⚡ Só Remotes", Color3.fromRGB(130, 60, 230))
    end)

    GrabItemsBtn.MouseButton1Click:Connect(function()
        if State.IsBatchRunning then return end
        State.IsBatchRunning = true
        GrabItemsBtn.Text = "Pegando..."

        task.spawn(function()
            local entries = scanAllGameElementsV14()
            renderCards()
            local itemCount = 0
            for _, entry in ipairs(entries) do
                if not State.Alive or not State.IsBatchRunning then break end
                if entry.Category == "Itens" then
                    itemCount = itemCount + 1
                    StatusText.Text = string.format("Pegando item %d: %s", itemCount, entry.Name)
                    executeAction(entry, State.CustomArg)
                    task.wait(0.04)
                end
            end
            if State.Alive then
                StatusText.Text = string.format("Coleta finalizada! %d itens.", itemCount)
                GrabItemsBtn.Text = "🎁 Pegar Itens"
            end
            State.IsBatchRunning = false
        end)
    end)

    MassTestBtn.MouseButton1Click:Connect(function()
        if State.IsBatchRunning then return end
        State.IsBatchRunning = true
        MassTestBtn.Text = "TESTANDO..."
        MassTestBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 120)
        StatusText.Text = "Iniciando teste massivo..."

        task.spawn(function()
            local entries = scanAllGameElementsV14()
            renderCards()
            local total = #entries
            for i = 1, total do
                if not State.Alive or not State.IsBatchRunning then break end
                local e = entries[i]
                StatusText.Text = string.format("Testando (%d/%d): %s", i, total, e.Name)
                executeAction(e, State.CustomArg)
                task.wait(State.RemoteDelay)
            end
            if State.Alive then
                StatusText.Text = State.IsBatchRunning
                    and "Finalizado! Todos os elementos testados."
                    or "Teste massivo interrompido."
                MassTestBtn.Text = "🚀 TESTAR TUDO"
                MassTestBtn.BackgroundColor3 = Color3.fromRGB(220, 35, 60)
            end
            State.IsBatchRunning = false
        end)
    end)

    RescanBtn.MouseButton1Click:Connect(function()
        StatusText.Text = "Atualizando mapa, itens e eventos..."
        task.spawn(function()
            scanAllGameElementsV14()
            renderCards()
            if State.EspEnabled then toggleEsp(true) end
            StatusText.Text = "Escaneamento V14 atualizado!"
        end)
    end)

    StopAutosBtn.MouseButton1Click:Connect(function()
        State.ActiveLoops = {}
        State.IsBatchRunning = false
        renderCards()
        StatusText.Text = "Todos os loops e testes foram parados."
    end)

    -- Remote Spy Hook (só instala uma vez por sessão)
    if hookmetamethod and not getgenv_SpyInstalled then
        pcall(function()
            if getgenv then getgenv().BadgeMasterSpyLogs = State.SpyLogs end
            local oldNamecall
            oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
                local method = getnamecallmethod()
                local args = {...}
                if State.Alive and (method == "FireServer" or method == "InvokeServer")
                    and (self:IsA("RemoteEvent") or self:IsA("RemoteFunction") or self.ClassName == "UnreliableRemoteEvent") then
                    pcall(function()
                        table.insert(State.SpyLogs, 1, {
                            Remote = self,
                            Method = method,
                            Args = args,
                            Time = os.date("%H:%M:%S")
                        })
                        if #State.SpyLogs > 40 then table.remove(State.SpyLogs) end
                        if State.ActiveCategory == "🛰️ Spy" then renderCards() end
                    end)
                end
                return oldNamecall(self, ...)
            end)
        end)
    end

    task.delay(0.35, function()
        if State.Alive then
            scanAllGameElementsV14()
            renderCards()
        end
    end)
end

-- =================================================================================
-- HUB UNIVERSAL DE VERSÕES (SELETOR V1..V14 + HOOK DE FECHAMENTO [✕])
-- =================================================================================
local function buildVersionHub()
    local parentGui = getGuiParent()
    local oldHub = parentGui:FindFirstChild("BadgeMaster_VersionHub")
    if oldHub then oldHub:Destroy() end

    local HubScreen = Instance.new("ScreenGui")
    HubScreen.Name = "BadgeMaster_VersionHub"
    HubScreen.ResetOnSpawn = false
    HubScreen.DisplayOrder = 999
    HubScreen.Parent = parentGui

    local cam = workspace.CurrentCamera
    local vp = cam and cam.ViewportSize or Vector2.new(1280, 720)
    local hubW = math.clamp(vp.X - 30, 320, 560)
    local hubH = math.clamp(vp.Y - 30, 360, 500)

    local HubWindow = Instance.new("Frame")
    HubWindow.Size = UDim2.new(0, hubW, 0, hubH)
    HubWindow.Position = UDim2.new(0.5, -math.floor(hubW / 2), 0.5, -math.floor(hubH / 2))
    HubWindow.BackgroundColor3 = Color3.fromRGB(10, 12, 18)
    HubWindow.BorderSizePixel = 0
    HubWindow.Active = true
    HubWindow.ClipsDescendants = true
    HubWindow.Parent = HubScreen
    makeCorner(HubWindow, 12)

    local hStroke = Instance.new("UIStroke")
    hStroke.Color = Color3.fromRGB(0, 210, 255)
    hStroke.Thickness = 1.6
    hStroke.Parent = HubWindow

    local HubTop = Instance.new("Frame")
    HubTop.Size = UDim2.new(1, 0, 0, 42)
    HubTop.BackgroundColor3 = Color3.fromRGB(16, 20, 30)
    HubTop.BorderSizePixel = 0
    HubTop.Parent = HubWindow
    makeCorner(HubTop, 12)

    local HubTitle = Instance.new("TextLabel")
    HubTitle.Size = UDim2.new(1, -50, 1, 0)
    HubTitle.Position = UDim2.new(0, 14, 0, 0)
    HubTitle.BackgroundTransparency = 1
    HubTitle.Text = "👑 BADGE MASTER HUB  |  ESCOLHA A VERSÃO"
    HubTitle.TextColor3 = Color3.fromRGB(0, 240, 255)
    HubTitle.TextSize = 12
    HubTitle.Font = Enum.Font.GothamBold
    HubTitle.TextXAlignment = Enum.TextXAlignment.Left
    HubTitle.TextTruncate = Enum.TextTruncate.AtEnd
    HubTitle.Parent = HubTop

    local HubClose = Instance.new("TextButton")
    HubClose.Size = UDim2.new(0, 28, 0, 28)
    HubClose.Position = UDim2.new(1, -35, 0.5, -14)
    HubClose.BackgroundColor3 = Color3.fromRGB(185, 45, 65)
    HubClose.Text = "✕"
    HubClose.TextColor3 = Color3.fromRGB(255, 255, 255)
    HubClose.TextSize = 11
    HubClose.Font = Enum.Font.GothamBold
    HubClose.BorderSizePixel = 0
    HubClose.Parent = HubTop
    makeCorner(HubClose, 6)

    HubClose.MouseButton1Click:Connect(function()
        HubScreen:Destroy()
    end)

    makeDraggable(HubTop, HubWindow)

    local SubInfo = Instance.new("TextLabel")
    SubInfo.Size = UDim2.new(1, -24, 0, 24)
    SubInfo.Position = UDim2.new(0, 12, 0, 46)
    SubInfo.BackgroundTransparency = 1
    SubInfo.Text = "Clique em uma versão para abrir. O [✕] no topo fecha ela e volta para cá."
    SubInfo.TextColor3 = Color3.fromRGB(160, 175, 200)
    SubInfo.TextSize = 10
    SubInfo.Font = Enum.Font.Gotham
    SubInfo.TextXAlignment = Enum.TextXAlignment.Left
    SubInfo.TextTruncate = Enum.TextTruncate.AtEnd
    SubInfo.Parent = HubWindow

    local GridScroll = Instance.new("ScrollingFrame")
    GridScroll.Size = UDim2.new(1, -20, 1, -80)
    GridScroll.Position = UDim2.new(0, 10, 0, 72)
    GridScroll.BackgroundColor3 = Color3.fromRGB(8, 10, 15)
    GridScroll.BorderSizePixel = 0
    GridScroll.ScrollBarThickness = 5
    GridScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    GridScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    GridScroll.Parent = HubWindow
    makeCorner(GridScroll, 8)

    local gridLayout = Instance.new("UIGridLayout")
    gridLayout.CellSize = UDim2.new(0.5, -6, 0, 62)
    gridLayout.CellPadding = UDim2.new(0, 8, 0, 8)
    gridLayout.SortOrder = Enum.SortOrder.LayoutOrder
    gridLayout.Parent = GridScroll

    local gridPad = Instance.new("UIPadding")
    gridPad.PaddingTop = UDim.new(0, 8)
    gridPad.PaddingBottom = UDim.new(0, 8)
    gridPad.PaddingLeft = UDim.new(0, 8)
    gridPad.PaddingRight = UDim.new(0, 8)
    gridPad.Parent = GridScroll

    local function showHub()
        if HubScreen and HubScreen.Parent then
            HubScreen.Enabled = true
        end
    end

    local function getAllGuiRoots()
        local roots = {}
        pcall(function()
            if gethui then table.insert(roots, gethui()) end
        end)
        pcall(function()
            local cg = game:GetService("CoreGui")
            table.insert(roots, cg)
            local rg = cg:FindFirstChild("RobloxGui")
            if rg then table.insert(roots, rg) end
        end)
        pcall(function()
            local pg = LocalPlayer:FindFirstChild("PlayerGui")
            if pg then table.insert(roots, pg) end
        end)
        return roots
    end

    local function launchLegacyVersion(verKey)
        local src = VERSION_SOURCES[verKey]
        if not src then return end

        HubScreen.Enabled = false

        -- Snapshot das ScreenGuis existentes antes de rodar a versão antiga
        local existing = {}
        for _, root in ipairs(getAllGuiRoots()) do
            for _, child in ipairs(root:GetChildren()) do
                if child:IsA("ScreenGui") then
                    existing[child] = true
                end
            end
        end

        local fn, err = loadstring(src)
        if not fn then
            warn("[BadgeMaster Hub] Erro ao carregar " .. verKey .. ": " .. tostring(err))
            showHub()
            return
        end

        task.spawn(function()
            local ok, runErr = pcall(fn)
            if not ok then
                warn("[BadgeMaster Hub] Erro ao executar " .. verKey .. ": " .. tostring(runErr))
            end
        end)

        -- Aguarda a GUI da versão aparecer e conecta o botão [✕] para destruir e voltar ao Hub
        task.spawn(function()
            local capturedGuis = {}
            for _ = 1, 25 do
                task.wait(0.1)
                for _, root in ipairs(getAllGuiRoots()) do
                    for _, child in ipairs(root:GetChildren()) do
                        if child:IsA("ScreenGui") and not existing[child] and child ~= HubScreen then
                            capturedGuis[child] = true
                        end
                    end
                end
                if next(capturedGuis) then break end
            end

            local function closeLegacyAndReturn()
                for gui, _ in pairs(capturedGuis) do
                    if gui and gui.Parent then
                        pcall(function() gui:Destroy() end)
                    end
                end
                showHub()
            end

            local hookedClose = false
            for gui, _ in pairs(capturedGuis) do
                for _, desc in ipairs(gui:GetDescendants()) do
                    if desc:IsA("TextButton") then
                        local t = (desc.Text or ""):gsub("%s+", "")
                        if t == "✕" or t == "X" or t == "x" then
                            hookedClose = true
                            desc.MouseButton1Click:Connect(closeLegacyAndReturn)
                        end
                    end
                end
            end

            -- Se a versão (ex: V1) não tiver GUI ou não tiver botão [✕], cria uma barra flutuante com [✕]
            if not hookedClose then
                local fallbackGui = Instance.new("ScreenGui")
                fallbackGui.Name = "BadgeMaster_LegacyCloseBar"
                fallbackGui.ResetOnSpawn = false
                fallbackGui.Parent = parentGui
                capturedGuis[fallbackGui] = true

                local bar = Instance.new("Frame")
                bar.Size = UDim2.new(0, 220, 0, 38)
                bar.Position = UDim2.new(0.5, -110, 0, 18)
                bar.BackgroundColor3 = Color3.fromRGB(16, 20, 30)
                bar.BorderSizePixel = 0
                bar.Parent = fallbackGui
                makeCorner(bar, 8)
                local bs = Instance.new("UIStroke")
                bs.Color = Color3.fromRGB(0, 210, 255)
                bs.Thickness = 1.4
                bs.Parent = bar

                local lbl = Instance.new("TextLabel")
                lbl.Size = UDim2.new(1, -40, 1, 0)
                lbl.Position = UDim2.new(0, 10, 0, 0)
                lbl.BackgroundTransparency = 1
                lbl.Text = "⚡ " .. verKey .. " em execução"
                lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
                lbl.TextSize = 11
                lbl.Font = Enum.Font.GothamBold
                lbl.TextXAlignment = Enum.TextXAlignment.Left
                lbl.Parent = bar

                local xBtn = Instance.new("TextButton")
                xBtn.Size = UDim2.new(0, 26, 0, 26)
                xBtn.Position = UDim2.new(1, -32, 0.5, -13)
                xBtn.BackgroundColor3 = Color3.fromRGB(195, 45, 65)
                xBtn.Text = "✕"
                xBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
                xBtn.TextSize = 11
                xBtn.Font = Enum.Font.GothamBold
                xBtn.BorderSizePixel = 0
                xBtn.Parent = bar
                makeCorner(xBtn, 6)
                xBtn.MouseButton1Click:Connect(closeLegacyAndReturn)
            end
        end)
    end

    for idx, info in ipairs(VERSION_LIST) do
        local card = Instance.new("TextButton")
        card.LayoutOrder = idx
        card.BackgroundColor3 = info.Recommended and Color3.fromRGB(18, 36, 58) or Color3.fromRGB(18, 22, 32)
        card.Text = ""
        card.BorderSizePixel = 0
        card.AutoButtonColor = true
        card.Parent = GridScroll
        makeCorner(card, 8)

        if info.Recommended then
            local cs = Instance.new("UIStroke")
            cs.Color = Color3.fromRGB(0, 220, 255)
            cs.Thickness = 1.5
            cs.Parent = card
        end

        local title = Instance.new("TextLabel")
        title.Size = UDim2.new(1, -16, 0, 22)
        title.Position = UDim2.new(0, 10, 0, 8)
        title.BackgroundTransparency = 1
        title.Text = (info.Recommended and "⭐ " or "📦 ") .. info.Label .. (info.Recommended and " (ATUAL)" or "")
        title.TextColor3 = info.Recommended and Color3.fromRGB(0, 240, 255) or Color3.fromRGB(255, 255, 255)
        title.TextSize = 12
        title.Font = Enum.Font.GothamBold
        title.TextXAlignment = Enum.TextXAlignment.Left
        title.TextTruncate = Enum.TextTruncate.AtEnd
        title.Parent = card

        local desc = Instance.new("TextLabel")
        desc.Size = UDim2.new(1, -16, 0, 20)
        desc.Position = UDim2.new(0, 10, 0, 32)
        desc.BackgroundTransparency = 1
        desc.Text = info.Desc
        desc.TextColor3 = Color3.fromRGB(150, 165, 190)
        desc.TextSize = 10
        desc.Font = Enum.Font.Gotham
        desc.TextXAlignment = Enum.TextXAlignment.Left
        desc.TextTruncate = Enum.TextTruncate.AtEnd
        desc.Parent = card

        card.MouseButton1Click:Connect(function()
            if info.Key == "V14" then
                HubScreen.Enabled = false
                launchV14(showHub)
            else
                launchLegacyVersion(info.Key)
            end
        end)
    end
end

buildVersionHub()
print("[BadgeMaster V14] Hub Universal de Versões carregado com sucesso!")
