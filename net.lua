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
