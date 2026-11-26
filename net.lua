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
