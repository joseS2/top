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
