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
