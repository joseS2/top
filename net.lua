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
