-- Name ESP Script
if not Drawing then
    warn("Drawing library not found! ESP will not work!")
    return {}
end

local ESP = {
    Enabled = false,
    TextSize = 14,
    TextColor = Color3.fromRGB(255, 255, 255),
    TextOutlineColor = Color3.fromRGB(0, 0, 0),
    BoxColor = Color3.fromRGB(255, 255, 255),
    BoxThickness = 1.5,
    HealthBarWidth = 2.5,
    HealthBarOffset = 4,
    ShowDistance = false,
    ShowName = false,
    ShowBox = false,
    MaxDistance = 1000,
    CornerBoxEnabled = false,
    CornerSize = 5,
    Objects = {},
    Players = game:GetService("Players"),
    RunService = game:GetService("RunService"),
    Camera = workspace.CurrentCamera,
    Started = false,
    ShowHealthBar = false,
    ShowTool = false,
    UpdateRate = 1/30, -- Update 30 times per second
    LastUpdate = 0
}

local HEALTH_COLORS = {
    [1] = Color3.fromRGB(0, 255, 0),    
    [0.75] = Color3.fromRGB(255, 255, 0), 
    [0.5] = Color3.fromRGB(255, 128, 0),  
    [0.25] = Color3.fromRGB(255, 0, 0),   
}

-- Cache frequently used values
local huge = math.huge
local floor = math.floor
local pairs = pairs
local Vector2 = Vector2.new
local Vector3 = Vector3.new
local CFrame = CFrame.new
local Color3 = Color3.fromRGB

-- Optimization: Cache corner offsets
local CORNER_OFFSETS = {
    Vector3.new(-1, -1, -1),
    Vector3.new(-1, -1, 1),
    Vector3.new(-1, 1, -1),
    Vector3.new(-1, 1, 1),
    Vector3.new(1, -1, -1),
    Vector3.new(1, -1, 1),
    Vector3.new(1, 1, -1),
    Vector3.new(1, 1, 1)
}

function ESP:GetHealthColor(percentage)
    local lastColor = HEALTH_COLORS[0.25]
    for threshold, color in pairs(HEALTH_COLORS) do
        if percentage >= threshold then
            return color
        end
    end
    return lastColor
end

function ESP:HideESP(esp)
    if not esp then return end
    esp.Name.Visible = false
    esp.Box.Visible = false
    esp.TopLeftV.Visible = false
    esp.TopLeftH.Visible = false
    esp.TopRightV.Visible = false
    esp.TopRightH.Visible = false
    esp.BottomLeftV.Visible = false
    esp.BottomLeftH.Visible = false
    esp.BottomRightV.Visible = false
    esp.BottomRightH.Visible = false
    esp.HealthBarOutline.Visible = false
    esp.HealthBarFill.Visible = false
    esp.HealthText.Visible = false
    esp.ToolText.Visible = false
end

function ESP:CreateESP(player)
    if player == ESP.Players.LocalPlayer then return end
    
    local esp = {
        Name = Drawing.new("Text"),
        Box = Drawing.new("Square"),
        -- Corner lines
        TopLeftV = Drawing.new("Line"),
        TopLeftH = Drawing.new("Line"),
        TopRightV = Drawing.new("Line"),
        TopRightH = Drawing.new("Line"),
        BottomLeftV = Drawing.new("Line"),
        BottomLeftH = Drawing.new("Line"),
        BottomRightV = Drawing.new("Line"),
        BottomRightH = Drawing.new("Line"),
        HealthBarOutline = Drawing.new("Square"),
        HealthBarFill = Drawing.new("Square"),
        HealthText = Drawing.new("Text"),
        ToolText = Drawing.new("Text"),
        Player = player,
        Enabled = true
    }
    
    local cornerProps = {
        Thickness = ESP.BoxThickness,
        Color = ESP.BoxColor,
        Transparency = 1,
    }
    
    for _, line in pairs({
        esp.TopLeftV, esp.TopLeftH,
        esp.TopRightV, esp.TopRightH,
        esp.BottomLeftV, esp.BottomLeftH,
        esp.BottomRightV, esp.BottomRightH
    }) do
        for prop, value in pairs(cornerProps) do
            line[prop] = value
        end
    end
    
    esp.Name.Text = player.Name
    esp.Name.Size = ESP.TextSize
    esp.Name.Center = true
    esp.Name.Outline = true
    esp.Name.OutlineColor = ESP.TextOutlineColor
    esp.Name.Color = ESP.TextColor
    esp.Name.Font = 2 
    
    esp.Box.Thickness = ESP.BoxThickness
    esp.Box.Color = ESP.BoxColor
    esp.Box.Filled = false
    esp.Box.Transparency = 1
    
    esp.HealthBarOutline.Thickness = 1
    esp.HealthBarOutline.Filled = false
    esp.HealthBarOutline.Color = Color3.new(0, 0, 0)
    esp.HealthBarOutline.Transparency = 1
    
    esp.HealthBarFill.Thickness = 1
    esp.HealthBarFill.Filled = true
    esp.HealthBarFill.Transparency = 1
    
    esp.HealthText.Size = ESP.TextSize - 2
    esp.HealthText.Center = false
    esp.HealthText.Outline = true
    esp.HealthText.OutlineColor = ESP.TextOutlineColor
    esp.HealthText.Color = ESP.TextColor
    esp.HealthText.Font = 2
    
    esp.ToolText.Size = ESP.TextSize - 2
    esp.ToolText.Center = true
    esp.ToolText.Outline = true
    esp.ToolText.OutlineColor = ESP.TextOutlineColor
    esp.ToolText.Color = ESP.TextColor
    esp.ToolText.Font = 2
    
    local function onCharacterAdded(character)
        esp.Enabled = true
        local humanoid = character:WaitForChild("Humanoid", 5)
        if humanoid then
            humanoid.Died:Connect(function()
                esp.Enabled = false
                ESP:HideESP(esp)
            end)
        end
    end
    
    if player.Character then
        onCharacterAdded(player.Character)
    end
    
    player.CharacterAdded:Connect(onCharacterAdded)
    
    ESP.Objects[player] = esp
end

-- Function to remove ESP
function ESP:RemoveESP(player)
    local esp = ESP.Objects[player]
    if esp then
        esp.Name:Remove()
        esp.Box:Remove()
        esp.TopLeftV:Remove()
        esp.TopLeftH:Remove()
        esp.TopRightV:Remove()
        esp.TopRightH:Remove()
        esp.BottomLeftV:Remove()
        esp.BottomLeftH:Remove()
        esp.BottomRightV:Remove()
        esp.BottomRightH:Remove()
        esp.HealthBarOutline:Remove()
        esp.HealthBarFill:Remove()
        esp.HealthText:Remove()
        esp.ToolText:Remove()
        ESP.Objects[player] = nil
    end
end

function ESP:GetBoundingBox(character)
    local minX, minY, minZ = huge, huge, huge
    local maxX, maxY, maxZ = -huge, -huge, -huge
    
    -- Optimization: Only check HumanoidRootPart and Head for rough bounding box
    local hrp = character:FindFirstChild("HumanoidRootPart")
    local head = character:FindFirstChild("Head")
    
    if not (hrp and head) then return end
    
    local cframe = hrp.CFrame
    local size = hrp.Size
    
    -- Calculate corners using cached offsets
    for _, offset in pairs(CORNER_OFFSETS) do
        local pos = (cframe * CFrame.new(
            offset.X * size.X/2,
            offset.Y * size.Y/2,
            offset.Z * size.Z/2
        )).Position
        
        minX = math.min(minX, pos.X)
        minY = math.min(minY, pos.Y)
        minZ = math.min(minZ, pos.Z)
        maxX = math.max(maxX, pos.X)
        maxY = math.max(maxY, pos.Y)
        maxZ = math.max(maxZ, pos.Z)
    end
    
    -- Adjust Y max using head position
    maxY = math.max(maxY, head.Position.Y + head.Size.Y/2)
    
    return Vector3.new(minX, minY, minZ), Vector3.new(maxX, maxY, maxZ)
end

function ESP:GetEquippedTool(character)
    for _, child in pairs(character:GetChildren()) do
        if child:IsA("Tool") then
            return child.Name
        end
    end
    return "None"
end

function ESP:Update()
    if not self.Enabled then return end
    
    -- Throttle updates
    local now = tick()
    if now - self.LastUpdate < self.UpdateRate then return end
    self.LastUpdate = now
    
    local camera = self.Camera
    if not camera then return end
    local cameraPosition = camera.CFrame.Position
    
    for player, esp in pairs(self.Objects) do
        if not (esp and esp.Enabled and player.Character) then 
            self:HideESP(esp)
            continue 
        end
        
        local character = player.Character
        local humanoid = character:FindFirstChild("Humanoid")
        local hrp = character:FindFirstChild("HumanoidRootPart")
        
        if not (humanoid and hrp and humanoid.Health > 0) then
            self:HideESP(esp)
            continue
        end
        
        -- Early distance check
        local distance = (hrp.Position - cameraPosition).Magnitude
        if distance > self.MaxDistance then
            self:HideESP(esp)
            continue
        end
        
        local min, max = self:GetBoundingBox(character)
        if not min then
            self:HideESP(esp)
            continue
        end
        
        -- Optimization: Check if any corner is visible before proceeding
        local cornerVisible = false
        local corners = {
            Vector3.new(min.X, max.Y, min.Z),
            Vector3.new(max.X, max.Y, min.Z)
        }
        
        for _, corner in pairs(corners) do
            local screenPos, onScreen = camera:WorldToViewportPoint(corner)
            if onScreen and screenPos.Z > 0 then
                cornerVisible = true
                break
            end
        end
        
        if not cornerVisible then
            self:HideESP(esp)
            continue
        end
        
        -- Calculate screen positions
        local screenMin, onScreenMin = camera:WorldToViewportPoint(min)
        local screenMax, onScreenMax = camera:WorldToViewportPoint(max)
        
        if not (onScreenMin or onScreenMax) then
            self:HideESP(esp)
            continue
        end
        
        local boxWidth = screenMax.X - screenMin.X
        local boxHeight = screenMax.Y - screenMin.Y
        
        -- Update ESP elements
        if self.ShowBox and esp.Box then
            esp.Box.Size = Vector2(boxWidth, boxHeight)
            esp.Box.Position = Vector2(screenMin.X, screenMin.Y)
            esp.Box.Visible = not self.CornerBoxEnabled
        end
        
        if self.ShowName and esp.Name then
            esp.Name.Position = Vector2((screenMin.X + screenMax.X)/2, screenMin.Y - esp.Name.TextBounds.Y - 2)
            esp.Name.Text = self.ShowDistance and string.format("%s\n[%d]", player.Name, floor(distance)) or player.Name
            esp.Name.Visible = true
        end
        
        if self.ShowHealthBar and humanoid then
            local healthPercent = humanoid.Health / humanoid.MaxHealth
            local barHeight = boxHeight * healthPercent
            local barPosition = Vector2(screenMin.X - self.HealthBarWidth - self.HealthBarOffset, screenMin.Y)
            
            esp.HealthBarOutline.Size = Vector2(self.HealthBarWidth, boxHeight)
            esp.HealthBarOutline.Position = barPosition
            esp.HealthBarOutline.Visible = true
            
            esp.HealthBarFill.Size = Vector2(self.HealthBarWidth, barHeight)
            esp.HealthBarFill.Position = Vector2(barPosition.X, barPosition.Y + boxHeight - barHeight)
            esp.HealthBarFill.Color = self:GetHealthColor(healthPercent)
            esp.HealthBarFill.Visible = true
            
            if esp.HealthText then
                esp.HealthText.Text = floor(humanoid.Health + 0.5)
                esp.HealthText.Position = Vector2(barPosition.X - esp.HealthText.TextBounds.X - 2, 
                    barPosition.Y + boxHeight - esp.HealthText.TextBounds.Y)
                esp.HealthText.Visible = true
            end
        end
        
        if self.ShowTool and esp.ToolText then
            esp.ToolText.Text = self:GetEquippedTool(character)
            esp.ToolText.Position = Vector2((screenMin.X + screenMax.X)/2, screenMax.Y + 2)
            esp.ToolText.Visible = true
        end
    end
end

function ESP:Init()
    if self.Started then return end
    
    local testDraw = Drawing.new("Line")
    if not testDraw then
        warn("Failed to create test drawing! ESP will not work!")
        return false
    end
    testDraw:Remove()
    
    self.Started = true
    self.Enabled = true
    
    local success = pcall(function()
        self.Players.PlayerAdded:Connect(function(player)
            self:CreateESP(player)
        end)
        
        self.Players.PlayerRemoving:Connect(function(player)
            self:RemoveESP(player)
        end)
        
        for _, player in ipairs(self.Players:GetPlayers()) do
            self:CreateESP(player)
        end
    end)
    
    if not success then
        warn("Failed to connect player events!")
        return false
    end
    
    success = pcall(function()
        self.UpdateConnection = self.RunService.RenderStepped:Connect(function()
            self:Update()
        end)
    end)
    
    if not success then
        warn("Failed to start update loop!")
        return false
    end
    
    return true
end

-- Stop ESP
function ESP:Stop()
    self.Enabled = false
    self.Started = false
    
    if self.UpdateConnection then
        self.UpdateConnection:Disconnect()
        self.UpdateConnection = nil
    end
    
    for player in pairs(self.Objects) do
        self:RemoveESP(player)
    end
end

function ESP:Toggle()
    self.Enabled = not self.Enabled
    for _, esp in pairs(self.Objects) do
        if not self.Enabled then
            self:HideESP(esp)
        end
    end
end

function ESP:ToggleName()
    self.ShowName = not self.ShowName
end

function ESP:ToggleDistance()
    self.ShowDistance = not self.ShowDistance
    -- Distance is handled in the Update function
end

function ESP:ToggleBox()
    self.ShowBox = not self.ShowBox
    -- Immediately update all existing ESP objects
    for _, esp in pairs(self.Objects) do
        if not self.ShowBox then
            esp.Box.Visible = false
            esp.TopLeftV.Visible = false
            esp.TopLeftH.Visible = false
            esp.TopRightV.Visible = false
            esp.TopRightH.Visible = false
            esp.BottomLeftV.Visible = false
            esp.BottomLeftH.Visible = false
            esp.BottomRightV.Visible = false
            esp.BottomRightH.Visible = false
        end
    end
end

function ESP:ToggleCornerBox()
    if not self.ShowBox then -- If box is disabled, enable it first
        self.ShowBox = true
    end
    self.CornerBoxEnabled = not self.CornerBoxEnabled
    -- Immediately update all existing ESP objects
    for _, esp in pairs(self.Objects) do
        if self.ShowBox and ESP.Enabled and esp.Enabled then
            if self.CornerBoxEnabled then
                esp.Box.Visible = false
                esp.TopLeftV.Visible = true
                esp.TopLeftH.Visible = true
                esp.TopRightV.Visible = true
                esp.TopRightH.Visible = true
                esp.BottomLeftV.Visible = true
                esp.BottomLeftH.Visible = true
                esp.BottomRightV.Visible = true
                esp.BottomRightH.Visible = true
            else
                esp.Box.Visible = true
                esp.TopLeftV.Visible = false
                esp.TopLeftH.Visible = false
                esp.TopRightV.Visible = false
                esp.TopRightH.Visible = false
                esp.BottomLeftV.Visible = false
                esp.BottomLeftH.Visible = false
                esp.BottomRightV.Visible = false
                esp.BottomRightH.Visible = false
            end
        end
    end
end

-- Add new functions to toggle health bar and tool text
function ESP:ToggleHealthBar()
    self.ShowHealthBar = not self.ShowHealthBar
    for _, esp in pairs(self.Objects) do
        if esp.Enabled and self.Enabled then
            esp.HealthBarOutline.Visible = self.ShowHealthBar
            esp.HealthBarFill.Visible = self.ShowHealthBar
            esp.HealthText.Visible = self.ShowHealthBar
        end
    end
end

function ESP:ToggleTool()
    self.ShowTool = not self.ShowTool
    for _, esp in pairs(self.Objects) do
        if esp.Enabled and self.Enabled then
            esp.ToolText.Visible = self.ShowTool
        end
    end
end

function ESP:SetColor(color)
    self.BoxColor = color
    self.TextColor = color
end

function ESP:SetSize(size)
    self.TextSize = size
end

ESP.Started = false
local success = ESP:Init()

if success then
    -- Set default configuration
    ESP.BoxColor = Color3.fromRGB(255, 0, 0)  
    ESP.TextColor = Color3.fromRGB(255, 255, 255)  -- White text
    ESP.BoxThickness = 2
    ESP.TextSize = 14
    ESP.Enabled = false
    ESP.ShowHealthBar = false
    ESP.ShowTool = false
    ESP.ShowName = false
    ESP.ShowDistance = false
    ESP.ShowBox = false
    ESP.CornerBoxEnabled = false  -- Start with regular box

    
else
    warn("ESP failed to initialize!")
end

return ESP 
