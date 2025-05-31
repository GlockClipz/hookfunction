-- Name ESP ScriptMore actions
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
    ShowDistance = true,
    ShowName = true,
    ShowBox = true,
    MaxDistance = 1000,
    CornerBoxEnabled = true,
    CornerSize = 5,
    Objects = {},
    Players = game:GetService("Players"),
    RunService = game:GetService("RunService"),
    Started = false,
    ShowHealthBar = true,
    ShowTool = true
}

local HEALTH_COLORS = {
    [1] = Color3.fromRGB(0, 255, 0),    
    [0.75] = Color3.fromRGB(255, 255, 0), 
    [0.5] = Color3.fromRGB(255, 128, 0),  
    [0.25] = Color3.fromRGB(255, 0, 0),   
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

function ESP:GetEquippedTool(character)
    for _, child in pairs(character:GetChildren()) do
        if child:IsA("Tool") then
            return child.Name
        end
    end
    return "None"
end

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

                local corners = {
                    Vector3.new(min.X, max.Y, min.Z), 
                    Vector3.new(max.X, max.Y, min.Z),
                    Vector3.new(min.X, min.Y, min.Z), 
                    Vector3.new(max.X, min.Y, min.Z), 
                    Vector3.new(min.X, max.Y, max.Z),
                    Vector3.new(max.X, max.Y, max.Z), 
                    Vector3.new(min.X, min.Y, max.Z),
                    Vector3.new(max.X, min.Y, max.Z)  
                }

                local minX, minY = math.huge, math.huge
                local maxX, maxY = -math.huge, -math.huge
                local allCornersBehind = true

                -- Project corners to screen
                for _, corner in pairs(corners) do
                    local screenPos, onScreen = camera:WorldToViewportPoint(corner)
                    if screenPos.Z > 0 then 
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
                    local boxWidth = maxX - minX
                    local boxHeight = maxY - minY

                    esp.Box.Size = Vector2.new(boxWidth, boxHeight)
                    esp.Box.Position = Vector2.new(minX, minY)
                    esp.Box.Visible = not ESP.CornerBoxEnabled

                    if ESP.CornerBoxEnabled then
                        esp.TopLeftV.From = Vector2.new(minX, minY)
                        esp.TopLeftV.To = Vector2.new(minX, minY + ESP.CornerSize)
                        esp.TopLeftH.From = Vector2.new(minX, minY)
                        esp.TopLeftH.To = Vector2.new(minX + ESP.CornerSize, minY)

                        esp.TopRightV.From = Vector2.new(maxX, minY)
                        esp.TopRightV.To = Vector2.new(maxX, minY + ESP.CornerSize)
                        esp.TopRightH.From = Vector2.new(maxX, minY)
                        esp.TopRightH.To = Vector2.new(maxX - ESP.CornerSize, minY)

                        esp.BottomLeftV.From = Vector2.new(minX, maxY)
                        esp.BottomLeftV.To = Vector2.new(minX, maxY - ESP.CornerSize)
                        esp.BottomLeftH.From = Vector2.new(minX, maxY)
                        esp.BottomLeftH.To = Vector2.new(minX + ESP.CornerSize, maxY)

                        esp.BottomRightV.From = Vector2.new(maxX, maxY)
                        esp.BottomRightV.To = Vector2.new(maxX, maxY - ESP.CornerSize)
                        esp.BottomRightH.From = Vector2.new(maxX, maxY)
                        esp.BottomRightH.To = Vector2.new(maxX - ESP.CornerSize, maxY)

                        for _, line in pairs({
                            esp.TopLeftV, esp.TopLeftH,
                            esp.TopRightV, esp.TopRightH,
                            esp.BottomLeftV, esp.BottomLeftH,
                            esp.BottomRightV, esp.BottomRightH
                        }) do
                            line.Visible = true
                        end
                    else
                        for _, line in pairs({
                            esp.TopLeftV, esp.TopLeftH,
                            esp.TopRightV, esp.TopRightH,
                            esp.BottomLeftV, esp.BottomLeftH,
                            esp.BottomRightV, esp.BottomRightH
                        }) do
                            line.Visible = false
                        end
                    end

                    local healthPercent = humanoid.Health / humanoid.MaxHealth
                    local healthBarHeight = boxHeight
                    local healthBarPos = Vector2.new(minX - ESP.HealthBarWidth - ESP.HealthBarOffset, minY)

                    esp.HealthBarOutline.Size = Vector2.new(ESP.HealthBarWidth, healthBarHeight)
                    esp.HealthBarOutline.Position = healthBarPos
                    esp.HealthBarOutline.Visible = true
                    esp.HealthBarOutline.Visible = ESP.ShowHealthBar

                    esp.HealthBarFill.Size = Vector2.new(ESP.HealthBarWidth, healthBarHeight * healthPercent)
                    esp.HealthBarFill.Position = Vector2.new(healthBarPos.X, healthBarPos.Y + healthBarHeight * (1 - healthPercent))
                    esp.HealthBarFill.Color = ESP:GetHealthColor(healthPercent)
                    esp.HealthBarFill.Visible = true
                    esp.HealthBarFill.Visible = ESP.ShowHealthBar

                    local healthText = string.format("%d", math.floor(humanoid.Health + 0.5))
                    esp.HealthText.Text = healthText
                    esp.HealthText.Position = Vector2.new(healthBarPos.X - esp.HealthText.TextBounds.X - 2, 
                        healthBarPos.Y + healthBarHeight - esp.HealthText.TextBounds.Y)
                    esp.HealthText.Visible = true
                    esp.HealthText.Visible = ESP.ShowHealthBar

                    local toolName = ESP:GetEquippedTool(character)
                    esp.ToolText.Text = toolName
                    esp.ToolText.Position = Vector2.new((minX + maxX) / 2, maxY + 2)
                    esp.ToolText.Visible = true
                    esp.ToolText.Visible = ESP.ShowTool

                    esp.Name.Position = Vector2.new((minX + maxX) / 2, minY - esp.Name.TextBounds.Y - 2)
                    esp.Name.Size = ESP.TextSize
                    esp.Name.Text = player.Name
                    if ESP.ShowDistance then
                        esp.Name.Text = string.format("%s\n[%d studs]", player.Name, math.floor(distance))
                    end
                    esp.Name.Visible = true
                    esp.Name.Visible = ESP.ShowName and ESP.Enabled and esp.Enabled

                    -- Update box visibility
                    if ESP.ShowBox and ESP.Enabled and esp.Enabled then
                        if ESP.CornerBoxEnabled then
                            for _, line in pairs({
                                esp.TopLeftV, esp.TopLeftH,
                                esp.TopRightV, esp.TopRightH,
                                esp.BottomLeftV, esp.BottomLeftH,
                                esp.BottomRightV, esp.BottomRightH
                            }) do
                                line.Visible = true
                            end
                            esp.Box.Visible = false
                        else
                            for _, line in pairs({
                                esp.TopLeftV, esp.TopLeftH,
                                esp.TopRightV, esp.TopRightH,
                                esp.BottomLeftV, esp.BottomLeftH,
                                esp.BottomRightV, esp.BottomRightH
                            }) do
                                line.Visible = false
                            end
                            esp.Box.Visible = true
                        end
                    else
                        esp.Box.Visible = false
                        for _, line in pairs({
                            esp.TopLeftV, esp.TopLeftH,
                            esp.TopRightV, esp.TopRightH,
                            esp.BottomLeftV, esp.BottomLeftH,
                            esp.BottomRightV, esp.BottomRightH
                        }) do
                            line.Visible = false
                        end
                    end
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

    print("ESP Initialized Successfully!")
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
end

function ESP:ToggleBox()
    self.ShowBox = not self.ShowBox
    for _, esp in pairs(self.Objects) do
        if self.ShowBox then
            if self.CornerBoxEnabled then
                for _, line in pairs({
                    esp.TopLeftV, esp.TopLeftH,
                    esp.TopRightV, esp.TopRightH,
                    esp.BottomLeftV, esp.BottomLeftH,
                    esp.BottomRightV, esp.BottomRightH
                }) do
                    line.Visible = self.Enabled and esp.Enabled
                end
                esp.Box.Visible = false
            else
                for _, line in pairs({
                    esp.TopLeftV, esp.TopLeftH,
                    esp.TopRightV, esp.TopRightH,
                    esp.BottomLeftV, esp.BottomLeftH,
                    esp.BottomRightV, esp.BottomRightH
                }) do
                    line.Visible = false
                end
                esp.Box.Visible = self.Enabled and esp.Enabled
            end
        else
            esp.Box.Visible = false
            for _, line in pairs({
                esp.TopLeftV, esp.TopLeftH,
                esp.TopRightV, esp.TopRightH,
                esp.BottomLeftV, esp.BottomLeftH,
                esp.BottomRightV, esp.BottomRightH
            }) do
                line.Visible = false
            end
        end
    end
end


function ESP:ToggleCornerBox()
    if not self.ShowBox then -- If box is disabled, enable it first
        self.ShowBox = true
    end
    self.CornerBoxEnabled = not self.CornerBoxEnabled
end

function ESP:ToggleHealthBar()
    self.ShowHealthBar = not self.ShowHealthBar
end

function ESP:ToggleTool()
    self.ShowTool = not self.ShowTool
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

    print("ESP initialized successfully!")
else
    warn("ESP failed to initialize!")
end

return ESP 
