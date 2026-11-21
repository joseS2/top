-- ========================================================
-- VERSÃO 9 (FINAL): Auto Farm + Auto Attack / Kill Aura Integrado
-- Descrição: Inclui tudo da V8 (Ponto Seguro [H], Alcance Máximo, GUI no Topo)
--            + Sistema de Ataque Automático (Kill Aura) que equipa a arma
--            e ataca continuamente o mob selecionado enquanto estiver em cima dele.
-- ========================================================

local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- VirtualUser para clique virtual automático (Kill Aura)
local VirtualUser = nil
pcall(function()
    VirtualUser = game:GetService("VirtualUser")
end)

-- ==================== CONFIGURAÇÕES INICIAIS ====================
local ATIVADO = false                              -- Ligar/Desligar Farm
local AUTO_ATTACK = true                           -- Ligar/Desligar Auto Attack (Kill Aura)
local ALTURA_CABECA = 4.5                          -- Altura acima da cabeça do mob (boa para alcance de ataque)
local VELOCIDADE_VOO = 75                          -- Velocidade do voo seguro
local DISTANCIA_MAXIMA = 500                       -- Distância máxima de busca (em studs)
local DELAY_ATAQUE = 0.15                          -- Intervalo entre cada golpe (em segundos)
local DISTANCIA_GOLPE = 12                         -- Distância máxima do mob para começar a bater

local COR_ROSA = Color3.fromRGB(255, 20, 147)
local COR_FUNDO = Color3.fromRGB(20, 20, 25)

-- Ponto seguro salvo com a tecla H
local safeSpotCFrame = nil

-- Blacklist para ignorar NPCs pacíficos de missão/lojas
local BLACKLIST_PALAVRAS = {
    "quest", "misao", "missao", "shop", "loja", "dealer", "seller", 
    "vendedor", "trainer", "treinador", "spawn", "boat", "barco", 
    "doctor", "medico", "blacksmith", "ferreiro", "safe", "civilian",
    "citizen", "dialog", "talk", "npc", "giver"
}

-- Blacklist temporária de cadáveres
local deadBlacklist = {}

local function isBlacklisted(model)
    if deadBlacklist[model] then
        if tick() < deadBlacklist[model] then
            return true
        else
            deadBlacklist[model] = nil
        end
    end
    return false
end

local function markAsDead(model)
    if model then
        deadBlacklist[model] = tick() + 12
    end
end

-- ==================== FILTRO DE INIMIGOS ====================
local function isEnemyAlive(model)
    if not model or not model:IsA("Model") then return false end
    if not model:IsDescendantOf(Workspace) then return false end
    if model == LocalPlayer.Character then return false end

    -- Aceita somente modelos que pertencem a outros jogadores
    local player = Players:GetPlayerFromCharacter(model)
    if not player then return false end

    local hum = model:FindFirstChildOfClass("Humanoid")
    local rootPart = model:FindFirstChild("HumanoidRootPart")
    local head = model:FindFirstChild("Head") or rootPart

    if not hum or not rootPart or not head then return false end
    if hum.Health <= 0 or hum:GetState() == Enum.HumanoidStateType.Dead then return false end

    return true
end

-- Busca o inimigo vivo mais próximo dentro do limite de distância
local function findNearestEnemy()
    local char = LocalPlayer.Character
    if not char then return nil end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end

    local originPos = safeSpotCFrame and safeSpotCFrame.Position or hrp.Position
    local closestEnemy = nil
    local shortestDist = DISTANCIA_MAXIMA

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local model = player.Character
            if isEnemyAlive(model) then
                local head = model:FindFirstChild("Head") or model:FindFirstChild("HumanoidRootPart")
                if head then
                    local dist = (originPos - head.Position).Magnitude
                    if dist <= shortestDist then
                        shortestDist = dist
                        closestEnemy = model
                    end
                end
            end
        end
    end

    return closestEnemy
end

-- ==================== SISTEMA DE ATAQUE (KILL AURA) ====================
local lastAttackTick = 0

-- Equipa automaticamente a primeira arma/ferramenta se a mão estiver vazia
local function ensureWeaponEquipped()
    local char = LocalPlayer.Character
    if not char then return end

    local currentTool = char:FindFirstChildOfClass("Tool")
    if not currentTool then
        local backpack = LocalPlayer:FindFirstChildOfClass("Backpack")
        if backpack then
            local tool = backpack:FindFirstChildOfClass("Tool")
            if tool then
                tool.Parent = char
            end
        end
    end
end

-- Desfere o golpe no mob
local function performAttackOnTarget(target)
    if not AUTO_ATTACK then return end
    if tick() - lastAttackTick < DELAY_ATAQUE then return end
    lastAttackTick = tick()

    ensureWeaponEquipped()

    local char = LocalPlayer.Character
    if not char then return end

    -- 1. Ativação direta da Tool
    local tool = char:FindFirstChildOfClass("Tool")
    if tool then
        tool:Activate()
    end

    -- 2. Clique virtual para englobar sistemas de combate baseados em clique
    if VirtualUser then
        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:Button1Down(Vector2.new(0, 0))
            task.wait(0.01)
            VirtualUser:Button1Up(Vector2.new(0, 0))
        end)
    end
end

-- ==================== INTERFACE (GUI NO TOPO) ====================
local function getGuiParent()
    local success, coreGui = pcall(function() return game:GetService("CoreGui") end)
    if success and coreGui then
        local p = pcall(function()
            local f = Instance.new("Folder", coreGui)
            f:Destroy()
        end)
        if p then return coreGui end
    end
    return LocalPlayer:WaitForChild("PlayerGui")
end

local guiParent = getGuiParent()
if guiParent:FindFirstChild("Enemy_AutoAttack_GUI") then
    guiParent["Enemy_AutoAttack_GUI"]:Destroy()
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "Enemy_AutoAttack_GUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = guiParent

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 240, 0, 290)
mainFrame.Position = UDim2.new(0.5, -120, 0, 20)
mainFrame.BackgroundColor3 = COR_FUNDO
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = mainFrame

local stroke = Instance.new("UIStroke")
stroke.Color = COR_ROSA
stroke.Thickness = 1.5
stroke.Parent = mainFrame

-- Barra de Título (Arrastável)
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 28)
title.BackgroundTransparency = 1
title.Text = "★ Auto Farm + Kill Aura"
title.TextColor3 = COR_ROSA
title.Font = Enum.Font.GothamBold
title.TextSize = 13
title.Parent = mainFrame

-- Status e Vida
local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -20, 0, 32)
statusLabel.Position = UDim2.new(0, 10, 0, 28)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Status: Desativado\nAlvo: Nenhum"
statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
statusLabel.Font = Enum.Font.GothamMedium
statusLabel.TextSize = 11
statusLabel.TextWrapped = true
statusLabel.Parent = mainFrame

-- Indicador do Ponto Seguro [H]
local safeSpotLabel = Instance.new("TextLabel")
safeSpotLabel.Size = UDim2.new(1, -20, 0, 18)
safeSpotLabel.Position = UDim2.new(0, 10, 0, 60)
safeSpotLabel.BackgroundTransparency = 1
safeSpotLabel.Text = "📍 Ponto [H]: Não definido"
safeSpotLabel.TextColor3 = Color3.fromRGB(255, 180, 50)
safeSpotLabel.Font = Enum.Font.Gotham
safeSpotLabel.TextSize = 10
safeSpotLabel.Parent = mainFrame

-- Controle de Distância Máxima
local distFrame = Instance.new("Frame")
distFrame.Size = UDim2.new(1, -20, 0, 24)
distFrame.Position = UDim2.new(0, 10, 0, 80)
distFrame.BackgroundTransparency = 1
distFrame.Parent = mainFrame

local distTitle = Instance.new("TextLabel")
distTitle.Size = UDim2.new(0, 80, 1, 0)
distTitle.BackgroundTransparency = 1
distTitle.Text = "Dist. Máx:"
distTitle.TextColor3 = Color3.fromRGB(180, 180, 180)
distTitle.Font = Enum.Font.GothamMedium
distTitle.TextSize = 11
distTitle.TextXAlignment = Enum.TextXAlignment.Left
distTitle.Parent = distFrame

local minusBtn = Instance.new("TextButton")
minusBtn.Size = UDim2.new(0, 24, 1, 0)
minusBtn.Position = UDim2.new(0, 75, 0, 0)
minusBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
minusBtn.Text = "-"
minusBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
minusBtn.Font = Enum.Font.GothamBold
minusBtn.TextSize = 12
minusBtn.Parent = distFrame
Instance.new("UICorner", minusBtn).CornerRadius = UDim.new(0, 4)

local distBox = Instance.new("TextBox")
distBox.Size = UDim2.new(0, 65, 1, 0)
distBox.Position = UDim2.new(0, 104, 0, 0)
distBox.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
distBox.Text = tostring(DISTANCIA_MAXIMA)
distBox.TextColor3 = COR_ROSA
distBox.Font = Enum.Font.GothamBold
distBox.TextSize = 11
distBox.Parent = distFrame
Instance.new("UICorner", distBox).CornerRadius = UDim.new(0, 4)

local plusBtn = Instance.new("TextButton")
plusBtn.Size = UDim2.new(0, 24, 1, 0)
plusBtn.Position = UDim2.new(0, 174, 0, 0)
plusBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
plusBtn.Text = "+"
plusBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
plusBtn.Font = Enum.Font.GothamBold
plusBtn.TextSize = 12
plusBtn.Parent = distFrame
Instance.new("UICorner", plusBtn).CornerRadius = UDim.new(0, 4)

local function setDistance(val)
    DISTANCIA_MAXIMA = math.clamp(val, 50, 10000)
    distBox.Text = tostring(DISTANCIA_MAXIMA)
end

minusBtn.MouseButton1Click:Connect(function()
    setDistance(DISTANCIA_MAXIMA - 100)
end)

plusBtn.MouseButton1Click:Connect(function()
    setDistance(DISTANCIA_MAXIMA + 100)
end)

distBox.FocusLost:Connect(function()
    local n = tonumber(distBox.Text)
    if n then setDistance(n) else distBox.Text = tostring(DISTANCIA_MAXIMA) end
end)

-- Controle de Velocidade de Voo/Ida
local speedFrame = Instance.new("Frame")
speedFrame.Size = UDim2.new(1, -20, 0, 24)
speedFrame.Position = UDim2.new(0, 10, 0, 108)
speedFrame.BackgroundTransparency = 1
speedFrame.Parent = mainFrame

local speedTitle = Instance.new("TextLabel")
speedTitle.Size = UDim2.new(0, 80, 1, 0)
speedTitle.BackgroundTransparency = 1
speedTitle.Text = "Velocidade:"
speedTitle.TextColor3 = Color3.fromRGB(180, 180, 180)
speedTitle.Font = Enum.Font.GothamMedium
speedTitle.TextSize = 11
speedTitle.TextXAlignment = Enum.TextXAlignment.Left
speedTitle.Parent = speedFrame

local speedMinusBtn = Instance.new("TextButton")
speedMinusBtn.Size = UDim2.new(0, 24, 1, 0)
speedMinusBtn.Position = UDim2.new(0, 75, 0, 0)
speedMinusBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
speedMinusBtn.Text = "-"
speedMinusBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
speedMinusBtn.Font = Enum.Font.GothamBold
speedMinusBtn.TextSize = 12
speedMinusBtn.Parent = speedFrame
Instance.new("UICorner", speedMinusBtn).CornerRadius = UDim.new(0, 4)

local speedBox = Instance.new("TextBox")
speedBox.Size = UDim2.new(0, 65, 1, 0)
speedBox.Position = UDim2.new(0, 104, 0, 0)
speedBox.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
speedBox.Text = tostring(VELOCIDADE_VOO)
speedBox.TextColor3 = COR_ROSA
speedBox.Font = Enum.Font.GothamBold
speedBox.TextSize = 11
speedBox.Parent = speedFrame
Instance.new("UICorner", speedBox).CornerRadius = UDim.new(0, 4)

local speedPlusBtn = Instance.new("TextButton")
speedPlusBtn.Size = UDim2.new(0, 24, 1, 0)
speedPlusBtn.Position = UDim2.new(0, 174, 0, 0)
speedPlusBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
speedPlusBtn.Text = "+"
speedPlusBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
speedPlusBtn.Font = Enum.Font.GothamBold
speedPlusBtn.TextSize = 12
speedPlusBtn.Parent = speedFrame
Instance.new("UICorner", speedPlusBtn).CornerRadius = UDim.new(0, 4)

local function setSpeed(val)
    VELOCIDADE_VOO = math.clamp(val, 10, 500)
    speedBox.Text = tostring(VELOCIDADE_VOO)
end

speedMinusBtn.MouseButton1Click:Connect(function()
    setSpeed(VELOCIDADE_VOO - 10)
end)

speedPlusBtn.MouseButton1Click:Connect(function()
    setSpeed(VELOCIDADE_VOO + 10)
end)

speedBox.FocusLost:Connect(function()
    local n = tonumber(speedBox.Text)
    if n then setSpeed(n) else speedBox.Text = tostring(VELOCIDADE_VOO) end
end)

-- Controle de Altura sobre o Alvo
local heightFrame = Instance.new("Frame")
heightFrame.Size = UDim2.new(1, -20, 0, 24)
heightFrame.Position = UDim2.new(0, 10, 0, 136)
heightFrame.BackgroundTransparency = 1
heightFrame.Parent = mainFrame

local heightTitle = Instance.new("TextLabel")
heightTitle.Size = UDim2.new(0, 80, 1, 0)
heightTitle.BackgroundTransparency = 1
heightTitle.Text = "Altura:"
heightTitle.TextColor3 = Color3.fromRGB(180, 180, 180)
heightTitle.Font = Enum.Font.GothamMedium
heightTitle.TextSize = 11
heightTitle.TextXAlignment = Enum.TextXAlignment.Left
heightTitle.Parent = heightFrame

local heightMinusBtn = Instance.new("TextButton")
heightMinusBtn.Size = UDim2.new(0, 24, 1, 0)
heightMinusBtn.Position = UDim2.new(0, 75, 0, 0)
heightMinusBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
heightMinusBtn.Text = "-"
heightMinusBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
heightMinusBtn.Font = Enum.Font.GothamBold
heightMinusBtn.TextSize = 12
heightMinusBtn.Parent = heightFrame
Instance.new("UICorner", heightMinusBtn).CornerRadius = UDim.new(0, 4)

local heightBox = Instance.new("TextBox")
heightBox.Size = UDim2.new(0, 65, 1, 0)
heightBox.Position = UDim2.new(0, 104, 0, 0)
heightBox.BackgroundColor3 = Color3.fromRGB(28, 28, 36)
heightBox.Text = tostring(ALTURA_CABECA)
heightBox.TextColor3 = COR_ROSA
heightBox.Font = Enum.Font.GothamBold
heightBox.TextSize = 11
heightBox.Parent = heightFrame
Instance.new("UICorner", heightBox).CornerRadius = UDim.new(0, 4)

local heightPlusBtn = Instance.new("TextButton")
heightPlusBtn.Size = UDim2.new(0, 24, 1, 0)
heightPlusBtn.Position = UDim2.new(0, 174, 0, 0)
heightPlusBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
heightPlusBtn.Text = "+"
heightPlusBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
heightPlusBtn.Font = Enum.Font.GothamBold
heightPlusBtn.TextSize = 12
heightPlusBtn.Parent = heightFrame
Instance.new("UICorner", heightPlusBtn).CornerRadius = UDim.new(0, 4)

local function setHeight(val)
    ALTURA_CABECA = math.clamp(math.round(val * 10) / 10, -10, 50)
    heightBox.Text = tostring(ALTURA_CABECA)
end

heightMinusBtn.MouseButton1Click:Connect(function()
    setHeight(ALTURA_CABECA - 0.5)
end)

heightPlusBtn.MouseButton1Click:Connect(function()
    setHeight(ALTURA_CABECA + 0.5)
end)

heightBox.FocusLost:Connect(function()
    local n = tonumber(heightBox.Text)
    if n then setHeight(n) else heightBox.Text = tostring(ALTURA_CABECA) end
end)

-- Botão Liga/Desliga Voo Farm
local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(1, -20, 0, 28)
toggleBtn.Position = UDim2.new(0, 10, 0, 166)
toggleBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
toggleBtn.BorderSizePixel = 0
toggleBtn.Text = "LIGAR FARM"
toggleBtn.TextColor3 = Color3.fromRGB(0, 255, 150)
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 12
toggleBtn.Parent = mainFrame
Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 6)

-- Botão Liga/Desliga Kill Aura (Auto Attack)
local attackToggleBtn = Instance.new("TextButton")
attackToggleBtn.Size = UDim2.new(1, -20, 0, 26)
attackToggleBtn.Position = UDim2.new(0, 10, 0, 198)
attackToggleBtn.BackgroundColor3 = Color3.fromRGB(35, 30, 45)
attackToggleBtn.BorderSizePixel = 0
attackToggleBtn.Text = "⚔️ Auto Attack: [LIGADO]"
attackToggleBtn.TextColor3 = Color3.fromRGB(255, 180, 255)
attackToggleBtn.Font = Enum.Font.GothamBold
attackToggleBtn.TextSize = 11
attackToggleBtn.Parent = mainFrame
Instance.new("UICorner", attackToggleBtn).CornerRadius = UDim.new(0, 6)

attackToggleBtn.MouseButton1Click:Connect(function()
    AUTO_ATTACK = not AUTO_ATTACK
    if AUTO_ATTACK then
        attackToggleBtn.Text = "⚔️ Auto Attack: [LIGADO]"
        attackToggleBtn.TextColor3 = Color3.fromRGB(255, 180, 255)
    else
        attackToggleBtn.Text = "⚔️ Auto Attack: [DESLIGADO]"
        attackToggleBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
    end
end)

-- Botão Pular Alvo
local skipBtn = Instance.new("TextButton")
skipBtn.Size = UDim2.new(1, -20, 0, 24)
skipBtn.Position = UDim2.new(0, 10, 0, 228)
skipBtn.BackgroundColor3 = Color3.fromRGB(45, 30, 35)
skipBtn.BorderSizePixel = 0
skipBtn.Text = "⏭ Pular Alvo"
skipBtn.TextColor3 = Color3.fromRGB(255, 150, 180)
skipBtn.Font = Enum.Font.GothamMedium
skipBtn.TextSize = 11
skipBtn.Parent = mainFrame
Instance.new("UICorner", skipBtn).CornerRadius = UDim.new(0, 6)

-- Botão Salvar Ponto Seguro
local setSafeBtn = Instance.new("TextButton")
setSafeBtn.Size = UDim2.new(1, -20, 0, 22)
setSafeBtn.Position = UDim2.new(0, 10, 0, 256)
setSafeBtn.BackgroundColor3 = Color3.fromRGB(30, 35, 45)
setSafeBtn.BorderSizePixel = 0
setSafeBtn.Text = "📍 Salvar Ponto Aqui (Tecla H)"
setSafeBtn.TextColor3 = Color3.fromRGB(150, 200, 255)
setSafeBtn.Font = Enum.Font.GothamMedium
setSafeBtn.TextSize = 10
setSafeBtn.Parent = mainFrame
Instance.new("UICorner", setSafeBtn).CornerRadius = UDim.new(0, 6)

-- Arrastar com o mouse
local dragging, dragStart, startPos
mainFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

local function saveCurrentLocationAsSafe()
    local char = LocalPlayer.Character
    if char and char:FindFirstChild("HumanoidRootPart") then
        safeSpotCFrame = char.HumanoidRootPart.CFrame
        safeSpotLabel.Text = "📍 Ponto [H]: Salvo com sucesso!"
        safeSpotLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
    end
end

setSafeBtn.MouseButton1Click:Connect(saveCurrentLocationAsSafe)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.H and not UserInputService:GetFocusedTextBox() then
        saveCurrentLocationAsSafe()
    end
end)

local currentTarget = nil
local targetHead = nil
local diedConn = nil

local function clearCurrentTarget()
    if diedConn then
        diedConn:Disconnect()
        diedConn = nil
    end
    if currentTarget then
        markAsDead(currentTarget)
    end
    currentTarget = nil
    targetHead = nil
end

toggleBtn.MouseButton1Click:Connect(function()
    ATIVADO = not ATIVADO
    if ATIVADO then
        toggleBtn.Text = "DESLIGAR FARM"
        toggleBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
    else
        toggleBtn.Text = "LIGAR FARM"
        toggleBtn.TextColor3 = Color3.fromRGB(0, 255, 150)
        clearCurrentTarget()
        statusLabel.Text = "Status: Desativado\nAlvo: Nenhum"

        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then hum.PlatformStand = false end
        end
    end
end)

skipBtn.MouseButton1Click:Connect(function()
    if ATIVADO and currentTarget then
        clearCurrentTarget()
        statusLabel.Text = "Pulando para o próximo..."
    end
end)

-- ==================== THREAD GERENCIADORA DE ALVOS ====================
task.spawn(function()
    while true do
        task.wait(0.15)
        if ATIVADO then
            if currentTarget then
                if not isEnemyAlive(currentTarget) then
                    clearCurrentTarget()
                end
            end

            if not currentTarget then
                local nextEnemy = findNearestEnemy()
                if nextEnemy then
                    currentTarget = nextEnemy
                    targetHead = nextEnemy:FindFirstChild("Head") or nextEnemy:FindFirstChild("HumanoidRootPart")
                    
                    local hum = nextEnemy:FindFirstChildOfClass("Humanoid")
                    if hum then
                        if diedConn then diedConn:Disconnect() end
                        diedConn = hum.Died:Connect(function()
                            clearCurrentTarget()
                        end)
                    end
                else
                    if safeSpotCFrame then
                        statusLabel.Text = "Sem inimigos no alcance.\nRetornando ao Ponto [H]..."
                    else
                        statusLabel.Text = "Sem inimigos no alcance.\n(Aperte H para salvar base)"
                    end
                end
            end

            if currentTarget then
                local hum = currentTarget:FindFirstChildOfClass("Humanoid")
                local hp = hum and math.floor(hum.Health) or 0
                local maxHp = hum and math.floor(hum.MaxHealth) or 100
                statusLabel.Text = string.format("Alvo: %s\nVida: %d/%d", currentTarget.Name, hp, maxHp)
            end
        end
    end
end)

-- ==================== LOOP DE VOO, NOCLIP E KILL AURA ====================

RunService.Stepped:Connect(function()
    if not ATIVADO then return end
    local char = LocalPlayer.Character
    if char then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    end
end)

RunService.Heartbeat:Connect(function(dt)
    if not ATIVADO then return end

    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end

    -- Caso 1: Tem alvo selecionado
    if currentTarget and targetHead and targetHead.Parent then
        hum.PlatformStand = true
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero

        local targetPos = targetHead.Position + Vector3.new(0, ALTURA_CABECA, 0)
        local currentPos = hrp.Position
        local dist = (targetPos - currentPos).Magnitude

        if dist > 2 then
            local direction = (targetPos - currentPos).Unit
            local step = math.min(dist, VELOCIDADE_VOO * dt)
            hrp.CFrame = CFrame.new(currentPos + direction * step, targetHead.Position)
        else
            -- Fixado na cabeça olhando para baixo/para o inimigo
            hrp.CFrame = CFrame.new(targetPos, targetHead.Position)
        end

        -- KILL AURA: Ataca enquanto estiver próximo/em cima da cabeça do mob
        if dist <= DISTANCIA_GOLPE then
            performAttackOnTarget(currentTarget)
        end

    -- Caso 2: Sem alvo no alcance -> Espera no ponto seguro [H]
    elseif safeSpotCFrame then
        hum.PlatformStand = true
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero

        local targetPos = safeSpotCFrame.Position
        local currentPos = hrp.Position
        local dist = (targetPos - currentPos).Magnitude

        if dist > 2 then
            local direction = (targetPos - currentPos).Unit
            local step = math.min(dist, VELOCIDADE_VOO * dt)
            hrp.CFrame = CFrame.new(currentPos + direction * step, targetPos + safeSpotCFrame.LookVector)
        else
            hrp.CFrame = safeSpotCFrame
        end
    end
end)

print("[V9 FINAL] Auto Farm + Kill Aura ativado com sucesso!")
