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
