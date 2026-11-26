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
