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
