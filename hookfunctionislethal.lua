-- Name ESP Script
local ESP = {
    Enabled = false, -- Start disabled by default
    TextSize = 14,
    TextColor = Color3.fromRGB(255, 255, 255),
    TextOutlineColor = Color3.fromRGB(0, 0, 0),
    BoxColor = Color3.fromRGB(255, 255, 255),
    BoxThickness = 1.5,
    HealthBarWidth = 2.5,
    HealthBarOffset = 4,
    ShowDistance = true,
    MaxDistance = 1000,
    CornerBoxEnabled = true,
    CornerSize = 5,
    Objects = {}, -- Renamed from ESPObjects for clarity
    Players = game:GetService("Players"),
    RunService = game:GetService("RunService"),
    Started = false
}

-- Health Bar Colors
local HEALTH_COLORS = {
    [1] = Color3.fromRGB(0, 255, 0),    -- 100% health (Green)
    [0.75] = Color3.fromRGB(255, 255, 0), -- 75% health (Yellow)
    [0.5] = Color3.fromRGB(255, 128, 0),  -- 50% health (Orange)
    [0.25] = Color3.fromRGB(255, 0, 0),   -- 25% health (Red)
}

-- Function to get health color based on percentage
function ESP:GetHealthColor(percentage)
    local lastColor = HEALTH_COLORS[0.25]
    for threshold, color in pairs(HEALTH_COLORS) do
        if percentage >= threshold then
            return color
        end
    end
    return lastColor
end

-- Function to hide ESP elements
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

-- Function to create ESP for a player
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
    
    -- Configure corner lines
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
    
    -- Configure ESP text properties
    esp.Name.Text = player.Name
    esp.Name.Size = ESP.TextSize
    esp.Name.Center = true
    esp.Name.Outline = true
    esp.Name.OutlineColor = ESP.TextOutlineColor
    esp.Name.Color = ESP.TextColor
    esp.Name.Font = 2 -- Plex font
    
    -- Configure ESP box properties
    esp.Box.Thickness = ESP.BoxThickness
    esp.Box.Color = ESP.BoxColor
    esp.Box.Filled = false
    esp.Box.Transparency = 1
    
    -- Configure health bar properties
    esp.HealthBarOutline.Thickness = 1
    esp.HealthBarOutline.Filled = false
    esp.HealthBarOutline.Color = Color3.new(0, 0, 0)
    esp.HealthBarOutline.Transparency = 1
    
    esp.HealthBarFill.Thickness = 1
    esp.HealthBarFill.Filled = true
    esp.HealthBarFill.Transparency = 1
    
    -- Configure health text properties
    esp.HealthText.Size = ESP.TextSize - 2
    esp.HealthText.Center = false
    esp.HealthText.Outline = true
    esp.HealthText.OutlineColor = ESP.TextOutlineColor
    esp.HealthText.Color = ESP.TextColor
    esp.HealthText.Font = 2
    
    -- Configure tool text properties
    esp.ToolText.Size = ESP.TextSize - 2
    esp.ToolText.Center = true
    esp.ToolText.Outline = true
    esp.ToolText.OutlineColor = ESP.TextOutlineColor
    esp.ToolText.Color = ESP.TextColor
    esp.ToolText.Font = 2
    
    -- Connect death handling
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
    
    -- Connect to existing character
    if player.Character then
        onCharacterAdded(player.Character)
    end
    
    -- Connect to future characters
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

-- Function to get bounding box
function ESP:GetBoundingBox(character)
    local minX, minY, minZ = math.huge, math.huge, math.huge
    local maxX, maxY, maxZ = -math.huge, -math.huge, -math.huge
    
    -- Get all parts including those in models
    local function scanParts(parent)
        for _, part in pairs(parent:GetChildren()) do
            if part:IsA("BasePart") then
                local cf, size = part.CFrame, part.Size
                local corners = {
                    cf * CFrame.new(-size.X/2, -size.Y/2, -size.Z/2),
                    cf * CFrame.new(-size.X/2, -size.Y/2, size.Z/2),
                    cf * CFrame.new(-size.X/2, size.Y/2, -size.Z/2),
                    cf * CFrame.new(-size.X/2, size.Y/2, size.Z/2),
                    cf * CFrame.new(size.X/2, -size.Y/2, -size.Z/2),
                    cf * CFrame.new(size.X/2, -size.Y/2, size.Z/2),
                    cf * CFrame.new(size.X/2, size.Y/2, -size.Z/2),
                    cf * CFrame.new(size.X/2, size.Y/2, size.Z/2)
                }
                
                for _, corner in pairs(corners) do
                    local pos = corner.Position
                    minX = math.min(minX, pos.X)
                    minY = math.min(minY, pos.Y)
                    minZ = math.min(minZ, pos.Z)
                    maxX = math.max(maxX, pos.X)
                    maxY = math.max(maxY, pos.Y)
                    maxZ = math.max(maxZ, pos.Z)
                end
            end
            scanParts(part)
        end
    end
    
    scanParts(character)
    return Vector3.new(minX, minY, minZ), Vector3.new(maxX, maxY, maxZ)
end

-- Function to get character's equipped tool
function ESP:GetEquippedTool(character)
    for _, child in pairs(character:GetChildren()) do
        if child:IsA("Tool") then
            return child.Name
        end
    end
    return "None"
end

-- Update ESP positions and visibility
function ESP:Update()
    if not ESP.Enabled then return end
    
    local camera = workspace.CurrentCamera
    
    for player, esp in pairs(ESP.Objects) do
        if esp and esp.Enabled and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local character = player.Character
            local hrp = character:FindFirstChild("HumanoidRootPart")
            local humanoid = character:FindFirstChild("Humanoid")
            
            if hrp and humanoid and humanoid.Health > 0 then
                local min, max = ESP:GetBoundingBox(character)
                local rootPos = hrp.Position
                
                -- Get corners in world space
                local corners = {
                    Vector3.new(min.X, max.Y, min.Z), -- Top Front Left
                    Vector3.new(max.X, max.Y, min.Z), -- Top Front Right
                    Vector3.new(min.X, min.Y, min.Z), -- Bottom Front Left
                    Vector3.new(max.X, min.Y, min.Z), -- Bottom Front Right
                    Vector3.new(min.X, max.Y, max.Z), -- Top Back Left
                    Vector3.new(max.X, max.Y, max.Z), -- Top Back Right
                    Vector3.new(min.X, min.Y, max.Z), -- Bottom Back Left
                    Vector3.new(max.X, min.Y, max.Z)  -- Bottom Back Right
                }
                
                local minX, minY = math.huge, math.huge
                local maxX, maxY = -math.huge, -math.huge
                local allCornersBehind = true
                
                -- Project corners to screen
                for _, corner in pairs(corners) do
                    local screenPos, onScreen = camera:WorldToViewportPoint(corner)
                    if screenPos.Z > 0 then -- Corner is in front of camera
                        allCornersBehind = false
                        minX = math.min(minX, screenPos.X)
                        minY = math.min(minY, screenPos.Y)
                        maxX = math.max(maxX, screenPos.X)
                        maxY = math.max(maxY, screenPos.Y)
                    end
                end
                
                local distance = (rootPos - camera.CFrame.Position).Magnitude
                local screenPos, onScreen = camera:WorldToViewportPoint(Vector3.new(
                    (min.X + max.X) / 2,
                    max.Y + 0.5,
                    (min.Z + max.Z) / 2
                ))
                
                if onScreen and not allCornersBehind and ESP.Enabled and distance <= ESP.MaxDistance then
                    -- Calculate box dimensions
                    local boxWidth = maxX - minX
                    local boxHeight = maxY - minY
                    
                    -- Update box visibility based on style
                    esp.Box.Size = Vector2.new(boxWidth, boxHeight)
                    esp.Box.Position = Vector2.new(minX, minY)
                    esp.Box.Visible = not ESP.CornerBoxEnabled
                    
                    if ESP.CornerBoxEnabled then
                        -- Top Left Corner
                        esp.TopLeftV.From = Vector2.new(minX, minY)
                        esp.TopLeftV.To = Vector2.new(minX, minY + ESP.CornerSize)
                        esp.TopLeftH.From = Vector2.new(minX, minY)
                        esp.TopLeftH.To = Vector2.new(minX + ESP.CornerSize, minY)
                        
                        -- Top Right Corner
                        esp.TopRightV.From = Vector2.new(maxX, minY)
                        esp.TopRightV.To = Vector2.new(maxX, minY + ESP.CornerSize)
                        esp.TopRightH.From = Vector2.new(maxX, minY)
                        esp.TopRightH.To = Vector2.new(maxX - ESP.CornerSize, minY)
                        
                        -- Bottom Left Corner
                        esp.BottomLeftV.From = Vector2.new(minX, maxY)
                        esp.BottomLeftV.To = Vector2.new(minX, maxY - ESP.CornerSize)
                        esp.BottomLeftH.From = Vector2.new(minX, maxY)
                        esp.BottomLeftH.To = Vector2.new(minX + ESP.CornerSize, maxY)
                        
                        -- Bottom Right Corner
                        esp.BottomRightV.From = Vector2.new(maxX, maxY)
                        esp.BottomRightV.To = Vector2.new(maxX, maxY - ESP.CornerSize)
                        esp.BottomRightH.From = Vector2.new(maxX, maxY)
                        esp.BottomRightH.To = Vector2.new(maxX - ESP.CornerSize, maxY)
                        
                        -- Show corner lines
                        for _, line in pairs({
                            esp.TopLeftV, esp.TopLeftH,
                            esp.TopRightV, esp.TopRightH,
                            esp.BottomLeftV, esp.BottomLeftH,
                            esp.BottomRightV, esp.BottomRightH
                        }) do
                            line.Visible = true
                        end
                    else
                        -- Hide corner lines when not using corner box style
                        for _, line in pairs({
                            esp.TopLeftV, esp.TopLeftH,
                            esp.TopRightV, esp.TopRightH,
                            esp.BottomLeftV, esp.BottomLeftH,
                            esp.BottomRightV, esp.BottomRightH
                        }) do
                            line.Visible = false
                        end
                    end
                    
                    -- Update health bar
                    local healthPercent = humanoid.Health / humanoid.MaxHealth
                    local healthBarHeight = boxHeight
                    local healthBarPos = Vector2.new(minX - ESP.HealthBarWidth - ESP.HealthBarOffset, minY)
                    
                    esp.HealthBarOutline.Size = Vector2.new(ESP.HealthBarWidth, healthBarHeight)
                    esp.HealthBarOutline.Position = healthBarPos
                    esp.HealthBarOutline.Visible = true
                    
                    esp.HealthBarFill.Size = Vector2.new(ESP.HealthBarWidth, healthBarHeight * healthPercent)
                    esp.HealthBarFill.Position = Vector2.new(healthBarPos.X, healthBarPos.Y + healthBarHeight * (1 - healthPercent))
                    esp.HealthBarFill.Color = ESP:GetHealthColor(healthPercent)
                    esp.HealthBarFill.Visible = true
                    
                    -- Update health text
                    local healthText = string.format("%d", math.floor(humanoid.Health + 0.5))
                    esp.HealthText.Text = healthText
                    esp.HealthText.Position = Vector2.new(healthBarPos.X - esp.HealthText.TextBounds.X - 2, 
                        healthBarPos.Y + healthBarHeight - esp.HealthText.TextBounds.Y)
                    esp.HealthText.Visible = true
                    
                    -- Update tool text
                    local toolName = ESP:GetEquippedTool(character)
                    esp.ToolText.Text = toolName
                    esp.ToolText.Position = Vector2.new((minX + maxX) / 2, maxY + 2)
                    esp.ToolText.Visible = true
                    
                    -- Update name text
                    esp.Name.Position = Vector2.new((minX + maxX) / 2, minY - esp.Name.TextBounds.Y - 2)
                    esp.Name.Size = ESP.TextSize
                    esp.Name.Text = player.Name
                    if ESP.ShowDistance then
                        esp.Name.Text = string.format("%s\n[%d studs]", player.Name, math.floor(distance))
                    end
                    esp.Name.Visible = true
                else
                    ESP:HideESP(esp)
                end
            else
                ESP:HideESP(esp)
            end
        else
            ESP:HideESP(esp)
        end
    end
end

-- Initialize ESP (call this after loadstring)
function ESP:Init()
    if self.Started then return end
    
    -- Start ESP
    self.Started = true
    self.Enabled = true
    
    -- Connect player events
    self.Players.PlayerAdded:Connect(function(player)
        self:CreateESP(player)
    end)
    
    self.Players.PlayerRemoving:Connect(function(player)
        self:RemoveESP(player)
    end)
    
    -- Create ESP for existing players
    for _, player in ipairs(self.Players:GetPlayers()) do
        self:CreateESP(player)
    end
    
    -- Start update loop
    self.RunService.RenderStepped:Connect(function()
        self:Update()
    end)
    
    -- Debug print to confirm initialization
    print("ESP Initialized")
end

-- Stop ESP
function ESP:Stop()
    self.Enabled = false
    self.Started = false
    
    -- Remove all ESP objects
    for player in pairs(self.Objects) do
        self:RemoveESP(player)
    end
end

-- Toggle ESP
function ESP:Toggle()
    self.Enabled = not self.Enabled
end

-- Toggle corner box style
function ESP:ToggleCornerBox()
    self.CornerBoxEnabled = not self.CornerBoxEnabled
end

-- Set ESP color
function ESP:SetColor(color)
    self.BoxColor = color
    self.TextColor = color
end

-- Set ESP size
function ESP:SetSize(size)
    self.TextSize = size
end

return ESP 
