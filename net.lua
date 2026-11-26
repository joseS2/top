--[[
    =================================================================================
    👑 BADGE MASTER V13 - OMNI-TESTING LAB & ADVANCED REMOTE/ITEM SUITE
    =================================================================================
    NOVIDADES DA V13 (EVOLUÇÃO DIRETA DA V12 + MELHORIAS DA V8/V9):

    1. [🎁 COLETA TOTAL DE ITENS RESTAURADA E AMPLIADA]:
       - Escaneia Tools e colecionáveis em: Workspace, ReplicatedStorage, Lighting,
         StarterPack, ReplicatedFirst e Mochila (Backpack).
       - Restaura o fallback da V8/V9 para Tools sem Handle (equipando direto pela
         mochila e ativando).
       - Para itens do mapa (Model/BasePart), dispara TouchInterest, conexões
         .Touched, ClickDetector e ProximityPrompt internos automaticamente.
       - Botão dedicado [🎁 Pegar Itens] para coletar todos os itens de uma vez.

    2. [⚡ SISTEMA DE REMOTES V13 (BATERIA INTELIGENTE DE ATRIBUTOS)]:
       - Ao clicar em qualquer Remote/Bindable SEM digitar argumento manual, ele
         testa automaticamente uma bateria completa usada por devs:
         {}, {true}, {false}, {1}, {0}, {100}, {1000}, {999999}, {-1},
         {true, 1000}, {true, 1}, {true, true}, {false, 1000}, {1, true}, {1000, true},
         {LocalPlayer}, {LocalPlayer, true}, {LocalPlayer, 1000}, {Character}, {RootPart},
         strings comuns ("Win", "Claim", "Complete", "Collect", "Buy", "Unlock", etc.),
         tabelas ({Amount = 1000}, {Value = true}) e todos os BadgeIds do universo.
       - Suporte a múltiplos argumentos manuais separados por vírgula!
         Ex: true, 1000  |  "Award", 12345  |  true, 1  |  1000  |  false
       - Presets clicáveis rápidos + opção [⚡ Só Remotes] e [🚀 TESTAR TUDO] que
         usam a bateria completa automaticamente quando o campo está vazio.
       - Correção do bug da V12 em BindableEvent/BindableFunction.

    3. [📍 TELEPORTE INTELIGENTE & RETORNO AO LOCAL ANTERIOR]:
       - Salva automaticamente sua posição antes de qualquer teleporte.
       - Botão [📍 Salvar Local] para marcar um ponto fixo no mapa.
       - Botão [↩️ Voltar Local] para retornar imediatamente ao ponto anterior.
       - Toggle [🔄 Auto-Voltar: ON/OFF]: escolha se quer voltar sozinho após
         testar um item/pad/prompt ou ficar no local!
       - Botão [📍 TP] individual nos cards de Itens, Pads e Prompts.

    4. [⏹️ CONTROLE TOTAL]:
       - [⏹️ Parar Tudo] interrompe tanto os loops individuais quanto os testes em
         massa imediatamente.
       - Toggle de Noclip direto na barra superior e interface alinhada sem cortes.
    =================================================================================
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local Lighting = game:GetService("Lighting")
local StarterPack = game:GetService("StarterPack")
local HttpService = game:GetService("HttpService")
local VirtualInputManager = game:GetService("VirtualInputManager")

local LocalPlayer = Players.LocalPlayer
local Backpack = LocalPlayer:WaitForChild("Backpack")
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local RootPart = Character:WaitForChild("HumanoidRootPart", 10)
local Humanoid = Character:WaitForChild("Humanoid", 10)

-- Estado Global V13
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
    NoclipEnabled = true,
    AutoReturnTP = true,
    SavedPosition = nil,
    LastPositionBeforeTP = nil
}

-- Anti-AFK
LocalPlayer.Idled:Connect(function()
    pcall(function()
        local vu = game:GetService("VirtualUser")
        vu:CaptureController()
        vu:ClickButton2(Vector2.new(0, 0))
    end)
end)

local function refreshCharacterRefs()
    Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    RootPart = Character:WaitForChild("HumanoidRootPart", 5)
    Humanoid = Character:WaitForChild("Humanoid", 5)
    Backpack = LocalPlayer:WaitForChild("Backpack", 5)
end

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
-- 0. UTILITÁRIOS DE TELEPORTE E FILTRO DE PLAYERS
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

local function teleportToCFrame(targetCFrame, autoReturn, holdTime)
    if not RootPart or not RootPart.Parent then refreshCharacterRefs() end
    if not RootPart then return nil end

    local origPos = RootPart.CFrame
    State.LastPositionBeforeTP = origPos
    RootPart.CFrame = targetCFrame

    if autoReturn then
        task.wait(holdTime or 0.08)
        if RootPart and RootPart.Parent then
            RootPart.CFrame = origPos
        end
    end
    return origPos
end

local function returnToPreviousPosition()
    if not RootPart or not RootPart.Parent then refreshCharacterRefs() end
    if not RootPart then return false end

    local target = State.LastPositionBeforeTP or State.SavedPosition
    if target then
        RootPart.CFrame = target
        return true
    end
    return false
end

local function getEntryTargetPart(entry)
    local obj = entry and entry.Object
    if not obj or not obj.Parent then return nil end
    if obj:IsA("BasePart") then return obj end
    if obj:IsA("Tool") then
        return obj:FindFirstChild("Handle") or obj:FindFirstChildWhichIsA("BasePart", true)
    end
    if obj:IsA("Model") then
        return obj.PrimaryPart or obj:FindFirstChild("Handle") or obj:FindFirstChildWhichIsA("BasePart", true)
    end
    if obj:IsA("ProximityPrompt") or obj:IsA("ClickDetector") then
        local p = obj.Parent
        if p then
            return p:IsA("BasePart") and p or p:FindFirstChildWhichIsA("BasePart", true)
        end
    end
    return obj:FindFirstChildWhichIsA("BasePart", true)
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
        local ok, data = pcall(function() return HttpService:JSONDecode(res) end)
        if ok and data and data.data then
            for _, b in ipairs(data.data) do
                table.insert(State.UniverseBadgeIds, b.id)
            end
        end
    end
end)

-- ---------------------------------------------------------------------------------
-- 2. ESP DE ITENS E PADS (DESTAQUE VISUAL EM 3D ATRAVÉS DAS PAREDES)
-- ---------------------------------------------------------------------------------
local function toggleEsp(enabled)
    State.EspEnabled = enabled

    for _, h in ipairs(State.EspHighlights) do
        if h and h.Parent then h:Destroy() end
    end
    State.EspHighlights = {}

    if not enabled then return end

    for _, entry in ipairs(State.ScannedEntries) do
        pcall(function()
            local target = entry.Object
            if target and target.Parent and (entry.Category == "Itens" or entry.Category == "Pads" or entry.Category == "Prompts") then
                local adornee = target:IsA("Model") and target or (target:IsA("BasePart") and target or target.Parent)
                if adornee then
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
                    end

                    highlight.Adornee = adornee
                    highlight.Parent = adornee
                    table.insert(State.EspHighlights, highlight)
                end
            end
        end)
    end
end

-- ---------------------------------------------------------------------------------
-- 3. PARSER & BATERIA DE ARGUMENTOS PARA REMOTES V13
-- ---------------------------------------------------------------------------------
local function parseSingleToken(raw)
    local trimmed = raw:match("^%s*(.-)%s*$")
    if trimmed == "" then return nil, false end

    -- Remove aspas externas se existirem
    local quoted = trimmed:match('^"(.*)"$') or trimmed:match("^'(.*)'$")
    if quoted ~= nil then
        return quoted, true
    end

    local lower = trimmed:lower()
    if lower == "true" then return true, true end
    if lower == "false" then return false, true end
    if lower == "nil" or lower == "null" then return nil, true end
    if lower == "me" or lower == "player" or lower == "localplayer" then return LocalPlayer, true end
    if lower == "char" or lower == "character" then return Character, true end
    if lower == "hrp" or lower == "root" or lower == "rootpart" then return RootPart, true end

    local num = tonumber(trimmed)
    if num ~= nil then return num, true end

    return trimmed, true
end

local function parseCustomArgs(inputStr)
    local args = {}
    local current = ""
    local inSingle, inDouble = false, false

    for i = 1, #inputStr do
        local ch = inputStr:sub(i, i)
        if ch == "'" and not inDouble then
            inSingle = not inSingle
            current = current .. ch
        elseif ch == '"' and not inSingle then
            inDouble = not inDouble
            current = current .. ch
        elseif ch == "," and not inSingle and not inDouble then
            local val, ok = parseSingleToken(current)
            if ok then table.insert(args, val) end
            current = ""
        else
            current = current .. ch
        end
    end

    local lastVal, ok = parseSingleToken(current)
    if ok then table.insert(args, lastVal) end

    return args
end

local function buildDefaultRemoteBattery()
    local battery = {
        {},
        {true},
        {false},
        {1},
        {0},
        {100},
        {1000},
        {999999},
        {-1},
        {true, 1000},
        {true, 1},
        {true, 0},
        {true, true},
        {false, 1000},
        {false, 1},
        {1, true},
        {1000, true},
        {1000, false},
        {LocalPlayer},
        {LocalPlayer, true},
        {LocalPlayer, 1000},
        {Character},
        {RootPart},
        {"Win"},
        {"Complete"},
        {"Claim"},
        {"Collect"},
        {"Finish"},
        {"Buy"},
        {"Unlock"},
        {"Equip"},
        {"Open"},
        {"Start"},
        {"End"},
        {"Reward"},
        {"Daily"},
        {"Redeem"},
        {"Verify"},
        {"Check"},
        {"Accept"},
        {"Confirm"},
        {"Yes"},
        {"Give"},
        {"Award"},
        {"Badge"},
        {"Secret"},
        {"Found"},
        {"Touch"},
        {"Hit"},
        {"Click"},
        {"Interact"},
        {"Claim", true},
        {"Claim", 1},
        {"Claim", 1000},
        {"Win", true},
        {"Complete", true},
        {"Unlock", true},
        {"Buy", 1},
        {"Give", 1000},
        {"Add", 1000},
        {{Amount = 1000}},
        {{Value = true}}
    }

    for _, bId in ipairs(State.UniverseBadgeIds) do
        table.insert(battery, {bId})
        table.insert(battery, {"Award", bId})
        table.insert(battery, {"Badge", bId})
        table.insert(battery, {bId, true})
        table.insert(battery, {LocalPlayer, bId})
    end

    return battery
end

-- ---------------------------------------------------------------------------------
-- 4. SCANNER TOTAL DE ELEMENTOS V13
-- ---------------------------------------------------------------------------------
local function scanAllGameElementsV13()
    local entries = {}
    local seen = {}

    -- A) REMOTES & UNRELIABLE & BINDABLES
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

    -- B) ITENS (WORKSPACE, REPLICATEDSTORAGE, LIGHTING, STARTERPACK, REPLICATEDFIRST & MOCHILA)
    local itemKeywords = {
        "tool", "sword", "gun", "weapon", "key", "relic", "coin", "gem", "badge",
        "trophy", "orb", "drop", "shard", "item", "collectible", "chest", "crate",
        "gift", "present", "star", "crystal", "candy", "egg", "fruit", "flower",
        "note", "page", "book", "scroll", "artifact", "pickup", "loot", "medal",
        "crown", "ring", "amulet", "potion", "card", "ticket", "token", "flag",
        "secret", "plush", "pet", "gear", "bag", "backpack"
    }

    -- 1. Tools e Colecionáveis no Workspace
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
                local matched = false
                for _, kw in ipairs(itemKeywords) do
                    if n:find(kw) then
                        matched = true
                        break
                    end
                end
                if matched then
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
                end
            end
        end
    end

    -- 2. Tools em Serviços de Storage (ReplicatedStorage, Lighting, StarterPack, ReplicatedFirst)
    local storageContainers = {
        {Service = ReplicatedStorage, Label = "ReplicatedStorage"},
        {Service = Lighting, Label = "Lighting"},
        {Service = StarterPack, Label = "StarterPack"},
        {Service = ReplicatedFirst, Label = "ReplicatedFirst"}
    }

    for _, container in ipairs(storageContainers) do
        for _, obj in ipairs(container.Service:GetDescendants()) do
            if obj:IsA("Tool") and not seen[obj] then
                seen[obj] = true
                table.insert(entries, {
                    Id = "ToolS_" .. tostring(obj:GetDebugId() or math.random(10000, 99999)),
                    Name = obj.Name,
                    Type = "ReplicatedTool",
                    Category = "Itens",
                    Icon = "📦",
                    TypeLabel = "Item em " .. container.Label,
                    Location = obj.Parent and obj.Parent.Name or container.Label,
                    Object = obj
                })
            end
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

    -- C) TOUCHPADS / BLOCOS COM TOUCH
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
                if n:find("badge") or n:find("giver") or n:find("checkpoint") or n:find("pad") or n:find("stage") or n:find("win") or n:find("portal") or n:find("teleport") then
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
            local name = obj.Parent and obj.Parent.Name or obj.Name
            if obj:IsA("ProximityPrompt") and obj.ActionText ~= "" then
                name = obj.ActionText .. " (" .. (obj.ObjectText ~= "" and obj.ObjectText or (obj.Parent and obj.Parent.Name or "Prompt")) .. ")"
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
-- 5. EXECUTOR DE AÇÕES INDIVIDUAIS V13
-- ---------------------------------------------------------------------------------
local function fireTouchPart(part)
    if not part or not part:IsA("BasePart") then return end
    if getconnections then
        for _, conn in ipairs(getconnections(part.Touched)) do
            pcall(function() conn:Fire(RootPart) end)
        end
    end
    if firetouchinterest then
        firetouchinterest(RootPart, part, 0)
        task.wait(0.015)
        firetouchinterest(RootPart, part, 1)
    end
end

local function executeAction(entry, specificArg, overrideAutoReturn)
    if not Character or not RootPart or not Humanoid or not RootPart.Parent then
        refreshCharacterRefs()
    end

    local shouldReturn = (overrideAutoReturn ~= nil) and overrideAutoReturn or State.AutoReturnTP

    pcall(function()
        -- REMOTES & BINDABLES COM ARGUMENTO MANUAL OU BATERIA COMPLETA
        if entry.Type == "Remote" or entry.Type == "UnreliableRemote" or entry.Type == "Bindable" then
            local rem = entry.Object
            if not rem or not rem.Parent then return end

            local argList = {}
            if specificArg and specificArg:match("%S") then
                table.insert(argList, parseCustomArgs(specificArg))
            else
                argList = buildDefaultRemoteBattery()
            end

            for _, args in ipairs(argList) do
                pcall(function()
                    if rem:IsA("RemoteEvent") or rem.ClassName == "UnreliableRemoteEvent" then
                        if #args == 0 then rem:FireServer() else rem:FireServer(table.unpack(args)) end
                    elseif rem:IsA("RemoteFunction") then
                        if #args == 0 then rem:InvokeServer() else rem:InvokeServer(table.unpack(args)) end
                    elseif rem:IsA("BindableEvent") then
                        if #args == 0 then rem:Fire() else rem:Fire(table.unpack(args)) end
                    elseif rem:IsA("BindableFunction") then
                        if #args == 0 then rem:Invoke() else rem:Invoke(table.unpack(args)) end
                    end
                end)
            end

        -- ITENS DO MAPA (WORLD TOOL & COLECIONÁVEIS)
        elseif entry.Type == "WorldTool" or entry.Type == "WorldItem" then
            local item = entry.Object
            if item and item.Parent and not isFromOtherPlayer(item) then
                local handle = getEntryTargetPart(entry)
                if handle then
                    local origPos = teleportToCFrame(handle.CFrame + Vector3.new(0, 1.2, 0), false)
                    fireTouchPart(handle)

                    -- Dispara Prompts/ClickDetectors dentro do item se houver
                    for _, desc in ipairs(item:GetDescendants()) do
                        if desc:IsA("ClickDetector") and fireclickdetector then
                            pcall(function() fireclickdetector(desc) end)
                        elseif desc:IsA("ProximityPrompt") and fireproximityprompt then
                            pcall(function()
                                desc.HoldDuration = 0
                                desc.RequiresLineOfSight = false
                                fireproximityprompt(desc)
                            end)
                        end
                    end

                    if item:IsA("Tool") then
                        pcall(function() Humanoid:EquipTool(item) end)
                        pcall(function() item.Parent = Character end)
                        task.wait(0.08)
                        pcall(function() item:Activate() end)
                    end

                    task.wait(0.06)
                    if shouldReturn and origPos and RootPart and RootPart.Parent then
                        RootPart.CFrame = origPos
                    end
                elseif item:IsA("Tool") then
                    -- Fallback da V8/V9 para Tool sem Handle/BasePart
                    pcall(function()
                        item.Parent = Backpack
                        Humanoid:EquipTool(item)
                        task.wait(0.08)
                        item:Activate()
                    end)
                end
            end

        elseif entry.Type == "ReplicatedTool" then
            local tool = entry.Object
            if tool then
                local clone = tool:Clone()
                clone.Parent = Backpack
                pcall(function() Humanoid:EquipTool(clone) end)
                task.wait(0.08)
                pcall(function() clone:Activate() end)
            end

        elseif entry.Type == "BackpackTool" then
            local tool = entry.Object
            if tool and tool.Parent then
                pcall(function()
                    tool.Parent = Character
                    task.wait(0.08)
                    tool:Activate()
                    task.wait(0.04)
                    tool.Parent = Backpack
                end)
            end

        -- PROMPTS COM ALINHAMENTO DE CÂMERA
        elseif entry.Type == "Prompt" then
            local prompt = entry.Object
            if prompt and prompt.Parent then
                local promptPart = getEntryTargetPart(entry)
                if promptPart then
                    local origPos = teleportToCFrame(promptPart.CFrame + Vector3.new(0, 1.2, 0), false)
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
                    if shouldReturn and origPos and RootPart and RootPart.Parent then
                        RootPart.CFrame = origPos
                    end
                end
            end

        -- TOUCHPADS
        elseif entry.Type == "TouchPad" then
            local part = entry.Object
            if part and part:IsA("BasePart") and part.Parent then
                local origPos = teleportToCFrame(part.CFrame + Vector3.new(0, 1.5, 0), false)
                RootPart.AssemblyLinearVelocity = Vector3.new(0, -4, 0)
                pcall(function() Humanoid:ChangeState(Enum.HumanoidStateType.Landed) end)

                fireTouchPart(part)
                task.wait(0.08)
                if shouldReturn and origPos and RootPart and RootPart.Parent then
                    RootPart.CFrame = origPos
                end
            end
        end
    end)
end

-- ---------------------------------------------------------------------------------
-- 6. ESPIÃO DE REDE INTEGRADO
-- ---------------------------------------------------------------------------------
local function initRemoteSpy(onCapture)
    if not hookmetamethod then return end
    pcall(function()
        local oldNamecall
        oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
            local method = getnamecallmethod()
            local args = {...}

            if (method == "FireServer" or method == "InvokeServer")
                and (self:IsA("RemoteEvent") or self:IsA("RemoteFunction") or self.ClassName == "UnreliableRemoteEvent") then
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
-- 7. INTERFACE GRÁFICA V13 (CYBER APEX LAB)
-- ---------------------------------------------------------------------------------
local function makeCorner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius)
    c.Parent = parent
    return c
end

local function buildInterfaceV13()
    local parentGui = (gethui and gethui()) or game:GetService("CoreGui"):FindFirstChild("RobloxGui") or LocalPlayer:WaitForChild("PlayerGui")
    local old = parentGui:FindFirstChild("BadgeMaster_V13") or parentGui:FindFirstChild("BadgeMaster_V12")
    if old then old:Destroy() end

    local Screen = Instance.new("ScreenGui")
    Screen.Name = "BadgeMaster_V13"
    Screen.ResetOnSpawn = false

    -- Botão Mobile Flutuante
    local MobBtn = Instance.new("TextButton")
    MobBtn.Size = UDim2.new(0, 52, 0, 52)
    MobBtn.Position = UDim2.new(0, 16, 0.45, 0)
    MobBtn.BackgroundColor3 = Color3.fromRGB(15, 18, 28)
    MobBtn.Text = "👑"
    MobBtn.TextSize = 24
    MobBtn.BorderSizePixel = 0
    MobBtn.Parent = Screen
    makeCorner(MobBtn, 26)

    local mbStroke = Instance.new("UIStroke")
    mbStroke.Color = Color3.fromRGB(0, 240, 255)
    mbStroke.Thickness = 2
    mbStroke.Parent = MobBtn

    -- Janela Principal
    local Window = Instance.new("Frame")
    Window.Size = UDim2.new(0, 680, 0, 560)
    Window.Position = UDim2.new(0.5, -340, 0.5, -280)
    Window.BackgroundColor3 = Color3.fromRGB(10, 12, 18)
    Window.BorderSizePixel = 0
    Window.Active = true
    Window.ClipsDescendants = true
    Window.Parent = Screen
    makeCorner(Window, 12)

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
    makeCorner(TopBar, 12)

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -135, 1, 0)
    Title.Position = UDim2.new(0, 14, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = "👑 BADGE MASTER V13  |  OMNI-TESTING LAB"
    Title.TextColor3 = Color3.fromRGB(0, 240, 255)
    Title.TextSize = 12
    Title.Font = Enum.Font.GothamBold
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = TopBar

    local NoclipBtn = Instance.new("TextButton")
    NoclipBtn.Size = UDim2.new(0, 82, 0, 26)
    NoclipBtn.Position = UDim2.new(1, -122, 0.5, -13)
    NoclipBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 110)
    NoclipBtn.Text = "👻 Noclip: ON"
    NoclipBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    NoclipBtn.TextSize = 9
    NoclipBtn.Font = Enum.Font.GothamBold
    NoclipBtn.BorderSizePixel = 0
    NoclipBtn.Parent = TopBar
    makeCorner(NoclipBtn, 6)

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
    makeCorner(CloseBtn, 6)

    CloseBtn.MouseButton1Click:Connect(function() Window.Visible = false end)
    MobBtn.MouseButton1Click:Connect(function() Window.Visible = not Window.Visible end)
    NoclipBtn.MouseButton1Click:Connect(function()
        State.NoclipEnabled = not State.NoclipEnabled
        NoclipBtn.Text = State.NoclipEnabled and "👻 Noclip: ON" or "👻 Noclip: OFF"
        NoclipBtn.BackgroundColor3 = State.NoclipEnabled and Color3.fromRGB(0, 170, 110) or Color3.fromRGB(50, 56, 72)
    end)

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
    TopCmds.Size = UDim2.new(1, 0, 0, 36)
    TopCmds.BackgroundTransparency = 1
    TopCmds.Parent = Body

    local topLayout = Instance.new("UIListLayout")
    topLayout.FillDirection = Enum.FillDirection.Horizontal
    topLayout.Padding = UDim.new(0, 5)
    topLayout.Parent = TopCmds

    local function makeTopBtn(text, color, widthScale)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(widthScale, -4, 1, 0)
        btn.BackgroundColor3 = color
        btn.Text = text
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.TextSize = 10
        btn.Font = Enum.Font.GothamBold
        btn.BorderSizePixel = 0
        btn.Parent = TopCmds
        makeCorner(btn, 8)
        return btn
    end

    local MassTestBtn = makeTopBtn("🚀 TESTAR TUDO", Color3.fromRGB(220, 35, 60), 0.23)
    local AllRemotesBtn = makeTopBtn("⚡ Só Remotes", Color3.fromRGB(130, 60, 230), 0.19)
    local GrabItemsBtn = makeTopBtn("🎁 Pegar Itens", Color3.fromRGB(225, 135, 20), 0.18)
    local EspBtn = makeTopBtn("👁️ ESP: OFF", Color3.fromRGB(0, 170, 115), 0.14)
    local RescanBtn = makeTopBtn("🔄 Re-Scan", Color3.fromRGB(0, 130, 240), 0.13)
    local StopAutosBtn = makeTopBtn("⏹️ Parar", Color3.fromRGB(45, 52, 68), 0.13)

    -- 2. Barra de Teleporte & Retorno
    local TpRow = Instance.new("Frame")
    TpRow.Size = UDim2.new(1, 0, 0, 30)
    TpRow.Position = UDim2.new(0, 0, 0, 42)
    TpRow.BackgroundColor3 = Color3.fromRGB(16, 20, 30)
    TpRow.BorderSizePixel = 0
    TpRow.Parent = Body
    makeCorner(TpRow, 8)

    local tpLayout = Instance.new("UIListLayout")
    tpLayout.FillDirection = Enum.FillDirection.Horizontal
    tpLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    tpLayout.Padding = UDim.new(0, 6)
    tpLayout.Parent = TpRow

    local tpPad = Instance.new("UIPadding")
    tpPad.PaddingLeft = UDim.new(0, 8)
    tpPad.PaddingRight = UDim.new(0, 8)
    tpPad.Parent = TpRow

    local tpTitle = Instance.new("TextLabel")
    tpTitle.Size = UDim2.new(0, 110, 1, 0)
    tpTitle.BackgroundTransparency = 1
    tpTitle.Text = "📍 Teleporte:"
    tpTitle.TextColor3 = Color3.fromRGB(0, 220, 255)
    tpTitle.TextSize = 10
    tpTitle.Font = Enum.Font.GothamBold
    tpTitle.TextXAlignment = Enum.TextXAlignment.Left
    tpTitle.Parent = TpRow

    local SavePosBtn = Instance.new("TextButton")
    SavePosBtn.Size = UDim2.new(0, 120, 0, 22)
    SavePosBtn.BackgroundColor3 = Color3.fromRGB(28, 38, 56)
    SavePosBtn.Text = "📌 Salvar Local"
    SavePosBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    SavePosBtn.TextSize = 10
    SavePosBtn.Font = Enum.Font.GothamBold
    SavePosBtn.BorderSizePixel = 0
    SavePosBtn.Parent = TpRow
    makeCorner(SavePosBtn, 6)

    local ReturnPosBtn = Instance.new("TextButton")
    ReturnPosBtn.Size = UDim2.new(0, 145, 0, 22)
    ReturnPosBtn.BackgroundColor3 = Color3.fromRGB(0, 145, 220)
    ReturnPosBtn.Text = "↩️ Voltar ao Anterior"
    ReturnPosBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ReturnPosBtn.TextSize = 10
    ReturnPosBtn.Font = Enum.Font.GothamBold
    ReturnPosBtn.BorderSizePixel = 0
    ReturnPosBtn.Parent = TpRow
    makeCorner(ReturnPosBtn, 6)

    local AutoReturnBtn = Instance.new("TextButton")
    AutoReturnBtn.Size = UDim2.new(0, 155, 0, 22)
    AutoReturnBtn.BackgroundColor3 = Color3.fromRGB(0, 175, 110)
    AutoReturnBtn.Text = "🔄 Auto-Voltar: ON"
    AutoReturnBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    AutoReturnBtn.TextSize = 10
    AutoReturnBtn.Font = Enum.Font.GothamBold
    AutoReturnBtn.BorderSizePixel = 0
    AutoReturnBtn.Parent = TpRow
    makeCorner(AutoReturnBtn, 6)

    -- 3. Barra de Parâmetros Customizados do Lab
    local ParamRow = Instance.new("Frame")
    ParamRow.Size = UDim2.new(1, 0, 0, 34)
    ParamRow.Position = UDim2.new(0, 0, 0, 78)
    ParamRow.BackgroundColor3 = Color3.fromRGB(16, 20, 30)
    ParamRow.BorderSizePixel = 0
    ParamRow.Parent = Body
    makeCorner(ParamRow, 8)

    local prLabel = Instance.new("TextLabel")
    prLabel.Size = UDim2.new(0, 125, 1, 0)
    prLabel.Position = UDim2.new(0, 8, 0, 0)
    prLabel.BackgroundTransparency = 1
    prLabel.Text = "🧪 Args Remote:"
    prLabel.TextColor3 = Color3.fromRGB(255, 190, 60)
    prLabel.TextSize = 10
    prLabel.Font = Enum.Font.GothamBold
    prLabel.TextXAlignment = Enum.TextXAlignment.Left
    prLabel.Parent = ParamRow

    local CustomArgInput = Instance.new("TextBox")
    CustomArgInput.Size = UDim2.new(1, -280, 0, 24)
    CustomArgInput.Position = UDim2.new(0, 130, 0.5, -12)
    CustomArgInput.BackgroundColor3 = Color3.fromRGB(24, 30, 44)
    CustomArgInput.PlaceholderText = "Vazio = Bateria Auto | Ex: true, 1000 ou 'Win'"
    CustomArgInput.PlaceholderColor3 = Color3.fromRGB(110, 120, 140)
    CustomArgInput.Text = ""
    CustomArgInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    CustomArgInput.TextSize = 10
    CustomArgInput.Font = Enum.Font.Code
    CustomArgInput.ClearTextOnFocus = false
    CustomArgInput.BorderSizePixel = 0
    CustomArgInput.Parent = ParamRow
    makeCorner(CustomArgInput, 6)

    local ApplyToAllBtn = Instance.new("TextButton")
    ApplyToAllBtn.Size = UDim2.new(0, 138, 0, 24)
    ApplyToAllBtn.Position = UDim2.new(1, -144, 0.5, -12)
    ApplyToAllBtn.BackgroundColor3 = Color3.fromRGB(0, 155, 245)
    ApplyToAllBtn.Text = "⚡ Injetar nos Remotes"
    ApplyToAllBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ApplyToAllBtn.TextSize = 10
    ApplyToAllBtn.Font = Enum.Font.GothamBold
    ApplyToAllBtn.BorderSizePixel = 0
    ApplyToAllBtn.Parent = ParamRow
    makeCorner(ApplyToAllBtn, 6)

    CustomArgInput.FocusLost:Connect(function()
        State.CustomArg = CustomArgInput.Text
    end)
    CustomArgInput:GetPropertyChangedSignal("Text"):Connect(function()
        State.CustomArg = CustomArgInput.Text
    end)

    -- 4. Barra de Presets Rápidos de Argumentos
    local PresetRow = Instance.new("Frame")
    PresetRow.Size = UDim2.new(1, 0, 0, 24)
    PresetRow.Position = UDim2.new(0, 0, 0, 117)
    PresetRow.BackgroundTransparency = 1
    PresetRow.Parent = Body

    local presetLayout = Instance.new("UIListLayout")
    presetLayout.FillDirection = Enum.FillDirection.Horizontal
    presetLayout.Padding = UDim.new(0, 5)
    presetLayout.Parent = PresetRow

    local presets = {
        {Label = "🤖 Auto (Todos)", Value = ""},
        {Label = "true, 1000", Value = "true, 1000"},
        {Label = "1000", Value = "1000"},
        {Label = "false", Value = "false"},
        {Label = "true, 1", Value = "true, 1"},
        {Label = "true", Value = "true"},
        {Label = '"Win"', Value = '"Win"'},
        {Label = '"Claim"', Value = '"Claim"'},
        {Label = "me, 1000", Value = "me, 1000"}
    }

    for _, p in ipairs(presets) do
        local pBtn = Instance.new("TextButton")
        pBtn.Size = UDim2.new(0, p.Value == "" and 92 or 66, 1, 0)
        pBtn.BackgroundColor3 = p.Value == "" and Color3.fromRGB(90, 50, 165) or Color3.fromRGB(24, 30, 44)
        pBtn.Text = p.Label
        pBtn.TextColor3 = Color3.fromRGB(225, 235, 250)
        pBtn.TextSize = 9
        pBtn.Font = Enum.Font.GothamBold
        pBtn.BorderSizePixel = 0
        pBtn.Parent = PresetRow
        makeCorner(pBtn, 5)

        pBtn.MouseButton1Click:Connect(function()
            CustomArgInput.Text = p.Value
            State.CustomArg = p.Value
        end)
    end

    -- 5. Categorias (Pills)
    local CatRow = Instance.new("Frame")
    CatRow.Size = UDim2.new(1, 0, 0, 28)
    CatRow.Position = UDim2.new(0, 0, 0, 147)
    CatRow.BackgroundTransparency = 1
    CatRow.Parent = Body

    local catLayout = Instance.new("UIListLayout")
    catLayout.FillDirection = Enum.FillDirection.Horizontal
    catLayout.Padding = UDim.new(0, 6)
    catLayout.Parent = CatRow

    local CatBtns = {}
    local Categories = {"Todos", "Itens", "Remotes", "Prompts", "Pads", "Bindables", "🛰️ Spy"}

    -- 6. Barra de Busca e Status
    local SearchRow = Instance.new("Frame")
    SearchRow.Size = UDim2.new(1, 0, 0, 28)
    SearchRow.Position = UDim2.new(0, 0, 0, 181)
    SearchRow.BackgroundTransparency = 1
    SearchRow.Parent = Body

    local StatusText = Instance.new("TextLabel")
    StatusText.Size = UDim2.new(0.45, -6, 1, 0)
    StatusText.BackgroundTransparency = 1
    StatusText.Text = "Carregando mapa..."
    StatusText.TextColor3 = Color3.fromRGB(165, 175, 195)
    StatusText.TextSize = 11
    StatusText.Font = Enum.Font.GothamMedium
    StatusText.TextXAlignment = Enum.TextXAlignment.Left
    StatusText.TextTruncate = Enum.TextTruncate.AtEnd
    StatusText.Parent = SearchRow

    local SearchBox = Instance.new("TextBox")
    SearchBox.Size = UDim2.new(0.55, 0, 1, 0)
    SearchBox.Position = UDim2.new(0.45, 0, 0, 0)
    SearchBox.BackgroundColor3 = Color3.fromRGB(18, 22, 32)
    SearchBox.PlaceholderText = "🔍 Buscar item, remote ou prompt..."
    SearchBox.PlaceholderColor3 = Color3.fromRGB(110, 120, 140)
    SearchBox.Text = ""
    SearchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    SearchBox.TextSize = 11
    SearchBox.Font = Enum.Font.Gotham
    SearchBox.BorderSizePixel = 0
    SearchBox.Parent = SearchRow
    makeCorner(SearchBox, 6)

    -- 7. Lista Interativa
    local ScrollList = Instance.new("ScrollingFrame")
    ScrollList.Size = UDim2.new(1, 0, 1, -215)
    ScrollList.Position = UDim2.new(0, 0, 0, 215)
    ScrollList.BackgroundColor3 = Color3.fromRGB(8, 10, 15)
    ScrollList.BorderSizePixel = 0
    ScrollList.ScrollBarThickness = 4
    ScrollList.Parent = Body
    makeCorner(ScrollList, 8)

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
            for _, log in ipairs(State.SpyLogs) do
                local card = Instance.new("Frame")
                card.Size = UDim2.new(1, -8, 0, 48)
                card.BackgroundColor3 = Color3.fromRGB(16, 20, 30)
                card.BorderSizePixel = 0
                card.Parent = ScrollList
                makeCorner(card, 8)

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
                local okJson, argsStr = pcall(function() return HttpService:JSONEncode(log.Args) end)
                sub.Text = "Args: " .. (okJson and argsStr or tostring(#log.Args) .. " args")
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
                makeCorner(replayBtn, 6)

                replayBtn.MouseButton1Click:Connect(function()
                    pcall(function()
                        if log.Method == "FireServer" then
                            log.Remote:FireServer(table.unpack(log.Args))
                        else
                            log.Remote:InvokeServer(table.unpack(log.Args))
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
            local matchesSearch = (search == "") or entry.Name:lower():find(search, 1, true) or entry.TypeLabel:lower():find(search, 1, true) or entry.Location:lower():find(search, 1, true)

            if matchesCat and matchesSearch then
                count = count + 1
                local hasSpatialPart = (entry.Category == "Itens" or entry.Category == "Pads" or entry.Category == "Prompts")
                    and (entry.Type ~= "ReplicatedTool" and entry.Type ~= "BackpackTool")

                local card = Instance.new("Frame")
                card.Name = "Card_" .. entry.Id
                card.Size = UDim2.new(1, -8, 0, 48)
                card.BackgroundColor3 = Color3.fromRGB(16, 20, 28)
                card.BorderSizePixel = 0
                card.Parent = ScrollList
                makeCorner(card, 8)

                local titleWidthOffset = hasSpatialPart and -235 or -185

                local titleLabel = Instance.new("TextLabel")
                titleLabel.Size = UDim2.new(1, titleWidthOffset, 0, 20)
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
                subLabel.Size = UDim2.new(1, titleWidthOffset, 0, 16)
                subLabel.Position = UDim2.new(0, 10, 0, 25)
                subLabel.BackgroundTransparency = 1
                subLabel.Text = string.format("%s • %s", entry.TypeLabel, entry.Location)
                subLabel.TextColor3 = Color3.fromRGB(140, 150, 175)
                subLabel.TextSize = 9
                subLabel.Font = Enum.Font.Gotham
                subLabel.TextXAlignment = Enum.TextXAlignment.Left
                subLabel.TextTruncate = Enum.TextTruncate.AtEnd
                subLabel.Parent = card

                if hasSpatialPart then
                    local tpBtn = Instance.new("TextButton")
                    tpBtn.Size = UDim2.new(0, 46, 0, 30)
                    tpBtn.Position = UDim2.new(1, -222, 0.5, -15)
                    tpBtn.BackgroundColor3 = Color3.fromRGB(38, 48, 70)
                    tpBtn.Text = "📍 TP"
                    tpBtn.TextColor3 = Color3.fromRGB(0, 225, 255)
                    tpBtn.TextSize = 10
                    tpBtn.Font = Enum.Font.GothamBold
                    tpBtn.BorderSizePixel = 0
                    tpBtn.Parent = card
                    makeCorner(tpBtn, 6)

                    tpBtn.MouseButton1Click:Connect(function()
                        local part = getEntryTargetPart(entry)
                        if part then
                            teleportToCFrame(part.CFrame + Vector3.new(0, 2, 0), false)
                            StatusText.Text = "Teleportado para " .. entry.Name .. " (use Voltar ao Anterior!)"
                        else
                            StatusText.Text = "Sem posição 3D para " .. entry.Name
                        end
                    end)
                end

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
                makeCorner(runOnceBtn, 6)

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
                makeCorner(autoBtn, 6)

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
        pill.Size = UDim2.new(0, catName:find("Spy") and 85 or 74, 1, 0)
        pill.BackgroundColor3 = (State.ActiveCategory == catName) and Color3.fromRGB(0, 180, 255) or Color3.fromRGB(20, 25, 36)
        pill.Text = catName
        pill.TextColor3 = Color3.fromRGB(255, 255, 255)
        pill.TextSize = 10
        pill.Font = Enum.Font.GothamBold
        pill.BorderSizePixel = 0
        pill.Parent = CatRow
        makeCorner(pill, 6)

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

    -- Botões de Teleporte
    SavePosBtn.MouseButton1Click:Connect(function()
        if not RootPart or not RootPart.Parent then refreshCharacterRefs() end
        if RootPart then
            State.SavedPosition = RootPart.CFrame
            State.LastPositionBeforeTP = RootPart.CFrame
            StatusText.Text = "Posição atual salva!"
        end
    end)

    ReturnPosBtn.MouseButton1Click:Connect(function()
        if returnToPreviousPosition() then
            StatusText.Text = "Retornou para o local anterior!"
        else
            StatusText.Text = "Nenhuma posição anterior salva ainda."
        end
    end)

    AutoReturnBtn.MouseButton1Click:Connect(function()
        State.AutoReturnTP = not State.AutoReturnTP
        AutoReturnBtn.Text = State.AutoReturnTP and "🔄 Auto-Voltar: ON" or "🔄 Auto-Voltar: OFF"
        AutoReturnBtn.BackgroundColor3 = State.AutoReturnTP and Color3.fromRGB(0, 175, 110) or Color3.fromRGB(65, 72, 92)
    end)

    -- Toggle ESP
    EspBtn.MouseButton1Click:Connect(function()
        local nextState = not State.EspEnabled
        toggleEsp(nextState)
        EspBtn.Text = nextState and "👁️ ESP: ON" or "👁️ ESP: OFF"
        EspBtn.BackgroundColor3 = nextState and Color3.fromRGB(0, 230, 135) or Color3.fromRGB(0, 170, 115)
    end)

    -- Injetar Argumento Manual (ou Bateria Completa se vazio) em Todos os Remotes
    local function runAllRemotes(triggerBtn, defaultText, defaultColor)
        if State.IsBatchRunning then return end
        State.IsBatchRunning = true
        triggerBtn.Text = "Testando..."
        local usingAutoBattery = not (State.CustomArg and State.CustomArg:match("%S"))
        StatusText.Text = usingAutoBattery
            and "Testando bateria completa de atributos em todos os remotes..."
            or ("Injetando '" .. State.CustomArg .. "' em todos os remotes...")

        task.spawn(function()
            local count = 0
            for _, entry in ipairs(State.ScannedEntries) do
                if not State.IsBatchRunning then break end
                if entry.Category == "Remotes" or entry.Category == "Bindables" then
                    count = count + 1
                    StatusText.Text = string.format("Remote %d: %s", count, entry.Name)
                    executeAction(entry, State.CustomArg)
                    task.wait(State.RemoteDelay)
                end
            end
            StatusText.Text = State.IsBatchRunning
                and string.format("Concluído! %d remotes testados.", count)
                or "Teste de remotes interrompido."
            triggerBtn.Text = defaultText
            triggerBtn.BackgroundColor3 = defaultColor
            State.IsBatchRunning = false
        end)
    end

    ApplyToAllBtn.MouseButton1Click:Connect(function()
        runAllRemotes(ApplyToAllBtn, "⚡ Injetar nos Remotes", Color3.fromRGB(0, 155, 245))
    end)

    AllRemotesBtn.MouseButton1Click:Connect(function()
        runAllRemotes(AllRemotesBtn, "⚡ Só Remotes", Color3.fromRGB(130, 60, 230))
    end)

    -- Pegar Todos os Itens
    GrabItemsBtn.MouseButton1Click:Connect(function()
        if State.IsBatchRunning then return end
        State.IsBatchRunning = true
        GrabItemsBtn.Text = "Pegando..."

        task.spawn(function()
            local entries = scanAllGameElementsV13()
            renderCards()

            local itemCount = 0
            for _, entry in ipairs(entries) do
                if not State.IsBatchRunning then break end
                if entry.Category == "Itens" then
                    itemCount = itemCount + 1
                    StatusText.Text = string.format("Pegando item %d: %s", itemCount, entry.Name)
                    executeAction(entry, State.CustomArg)
                    task.wait(0.04)
                end
            end

            StatusText.Text = string.format("Coleta finalizada! %d itens processados.", itemCount)
            GrabItemsBtn.Text = "🎁 Pegar Itens"
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

local UI = buildInterfaceV13()

initRemoteSpy(function()
    if State.ActiveCategory == "🛰️ Spy" then
        UI.Render()
    end
end)

-- ---------------------------------------------------------------------------------
-- 8. VINCULAÇÃO DOS BOTÕES PRINCIPAIS
-- ---------------------------------------------------------------------------------
UI.MassTestBtn.MouseButton1Click:Connect(function()
    if State.IsBatchRunning then return end
    State.IsBatchRunning = true
    UI.MassTestBtn.Text = "TESTANDO..."
    UI.MassTestBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 120)
    UI.Status.Text = "Iniciando teste massivo de remotes, itens, pads e prompts..."

    task.spawn(function()
        local entries = scanAllGameElementsV13()
        UI.Render()

        local total = #entries
        for i = 1, total do
            if not State.IsBatchRunning then break end
            local e = entries[i]
            UI.Status.Text = string.format("Testando (%d/%d): %s", i, total, e.Name)
            executeAction(e, State.CustomArg)
            task.wait(State.RemoteDelay)
        end

        UI.Status.Text = State.IsBatchRunning
            and "Finalizado! Todos os elementos foram testados."
            or "Teste massivo interrompido pelo usuário."
        UI.MassTestBtn.Text = "🚀 TESTAR TUDO"
        UI.MassTestBtn.BackgroundColor3 = Color3.fromRGB(220, 35, 60)
        State.IsBatchRunning = false
    end)
end)

UI.RescanBtn.MouseButton1Click:Connect(function()
    UI.Status.Text = "Atualizando mapa, itens e eventos..."
    task.spawn(function()
        scanAllGameElementsV13()
        UI.Render()
        if State.EspEnabled then toggleEsp(true) end
        UI.Status.Text = "Escaneamento V13 atualizado!"
    end)
end)

UI.StopAutosBtn.MouseButton1Click:Connect(function()
    State.ActiveLoops = {}
    State.IsBatchRunning = false
    UI.Render()
    UI.Status.Text = "Todos os loops e testes em massa foram parados."
end)

task.delay(0.5, function()
    scanAllGameElementsV13()
    UI.Render()
end)

print("[BadgeMaster V13] Omni-Testing Lab carregado com sucesso!")
