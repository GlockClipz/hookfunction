# Complete ESP Setup Guide

## Step 1: Initial Setup
First, create a new script file called `esp_setup.lua` with this basic loader:

```lua
-- Basic ESP Loader
local ESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/GlockClipz/hookfunction/refs/heads/main/hookfunctionislethal.lua"))()
task.wait(0.5)  -- Wait for ESP to load

-- Force initialization
ESP.Started = false
ESP:Init()
```

## Step 2: Configure Visual Settings

### Box Settings
```lua
-- Box Configuration
ESP.BoxColor = Color3.fromRGB(255, 0, 0)  -- Red box
ESP.BoxThickness = 2  -- Line thickness
ESP.CornerBoxEnabled = true  -- Use corner style boxes
ESP.CornerSize = 6  -- Size of corner pieces
```

### Text Settings
```lua
-- Text Configuration
ESP.TextSize = 14  -- Size of all text
ESP.TextColor = Color3.fromRGB(255, 255, 255)  -- White text
ESP.TextOutlineColor = Color3.fromRGB(0, 0, 0)  -- Black outline
```

### Health Bar Settings
```lua
-- Health Bar Configuration
ESP.HealthBarWidth = 2.5  -- Width of health bar
ESP.HealthBarOffset = 4  -- Distance from box
```

## Step 3: Feature Configuration

### Basic Features
```lua
-- Enable/Disable Features
ESP.ShowName = true      -- Show player names
ESP.ShowDistance = true  -- Show distance
ESP.MaxDistance = 1000   -- Maximum render distance
ESP.Enabled = true      -- Master toggle
```

## Step 4: Add Controls
```lua
-- Keybind Controls
local UserInputService = game:GetService("UserInputService")

-- Create a settings table
local settings = {
    espEnabled = true,
    namesEnabled = true,
    distanceEnabled = true,
    cornerBoxEnabled = true
}

-- Add keyboard controls
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.RightAlt then
        -- Master Toggle (Right Alt)
        settings.espEnabled = not settings.espEnabled
        ESP:Toggle()
        print("ESP:", settings.espEnabled and "ON" or "OFF")
        
    elseif input.KeyCode == Enum.KeyCode.N then
        -- Toggle Names (N key)
        settings.namesEnabled = not settings.namesEnabled
        ESP:ToggleName()
        print("Names:", settings.namesEnabled and "ON" or "OFF")
        
    elseif input.KeyCode == Enum.KeyCode.B then
        -- Toggle Box Style (B key)
        settings.cornerBoxEnabled = not settings.cornerBoxEnabled
        ESP:ToggleCornerBox()
        print("Corner Box:", settings.cornerBoxEnabled and "ON" or "OFF")
        
    elseif input.KeyCode == Enum.KeyCode.H then
        -- Toggle Distance (H key)
        settings.distanceEnabled = not settings.distanceEnabled
        ESP:ToggleDistance()
        print("Distance:", settings.distanceEnabled and "ON" or "OFF")
    end
end)
```

## Step 5: Complete Setup Script
Here's the complete script combining all features:

```lua
-- Full ESP Setup
print("Loading ESP...")

-- Load ESP
local ESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/GlockClipz/hookfunction/refs/heads/main/hookfunctionislethal.lua"))()
task.wait(0.5)

-- Visual Configuration
ESP.BoxColor = Color3.fromRGB(255, 0, 0)      -- Red box
ESP.TextColor = Color3.fromRGB(255, 255, 255)  -- White text
ESP.TextOutlineColor = Color3.fromRGB(0, 0, 0) -- Black outline
ESP.BoxThickness = 2
ESP.TextSize = 14
ESP.CornerSize = 6
ESP.HealthBarWidth = 2.5
ESP.HealthBarOffset = 4

-- Feature Configuration
ESP.ShowName = true
ESP.ShowDistance = true
ESP.CornerBoxEnabled = true
ESP.MaxDistance = 1000
ESP.Enabled = true

-- Force initialization
ESP.Started = false
local success = ESP:Init()

if success then
    print("ESP initialized successfully!")
else
    warn("ESP failed to initialize!")
    return
end

-- Keybind Controls
local UserInputService = game:GetService("UserInputService")

-- Settings tracker
local settings = {
    espEnabled = true,
    namesEnabled = true,
    distanceEnabled = true,
    cornerBoxEnabled = true
}

-- Control Guide
print([[
ESP Controls:
- Right Alt: Toggle ESP
- N: Toggle Names
- B: Toggle Box Style
- H: Toggle Distance
]])

-- Add keyboard controls
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.RightAlt then
        settings.espEnabled = not settings.espEnabled
        ESP:Toggle()
        print("ESP:", settings.espEnabled and "ON" or "OFF")
    elseif input.KeyCode == Enum.KeyCode.N then
        settings.namesEnabled = not settings.namesEnabled
        ESP:ToggleName()
        print("Names:", settings.namesEnabled and "ON" or "OFF")
    elseif input.KeyCode == Enum.KeyCode.B then
        settings.cornerBoxEnabled = not settings.cornerBoxEnabled
        ESP:ToggleCornerBox()
        print("Corner Box:", settings.cornerBoxEnabled and "ON" or "OFF")
    elseif input.KeyCode == Enum.KeyCode.H then
        settings.distanceEnabled = not settings.distanceEnabled
        ESP:ToggleDistance()
        print("Distance:", settings.distanceEnabled and "ON" or "OFF")
    end
end)

print("ESP setup complete!")
```

## Controls Guide
- **Right Alt**: Toggle entire ESP on/off
- **N key**: Toggle player names
- **B key**: Switch between corner and full boxes
- **H key**: Toggle distance display

## Customization Tips
1. **Change Colors**:
   ```lua
   ESP.BoxColor = Color3.fromRGB(255, 0, 0)  -- Red
   ESP.BoxColor = Color3.fromRGB(0, 255, 0)  -- Green
   ESP.BoxColor = Color3.fromRGB(0, 0, 255)  -- Blue
   ```

2. **Adjust Box Style**:
   ```lua
   ESP.CornerSize = 8  -- Larger corners
   ESP.BoxThickness = 3  -- Thicker lines
   ```

3. **Text Adjustments**:
   ```lua
   ESP.TextSize = 16  -- Larger text
   ESP.TextColor = Color3.fromRGB(255, 255, 0)  -- Yellow text
   ```

Let me know if you need any clarification or have questions about specific settings!
