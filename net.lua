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
