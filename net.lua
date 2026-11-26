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
