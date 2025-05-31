Absolutely! Here’s the polished and formatted README.md **in full**:

````markdown
# 🎯 ESP Documentation

A lightweight, customizable ESP (Extra Sensory Perception) script for Roblox.

---

## 📥 Installation

```lua
local ESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/GlockClipz/hookfunction/refs/heads/main/libary.lua"))()
````

---

## 🎮 Basic Controls

### Main Toggle

```lua
ESP:Toggle()  -- Toggles the entire ESP on/off
```

### Visual Elements

```lua
ESP:ToggleCornerBox()   -- Toggle corner box display
ESP:ToggleHealthBar()   -- Toggle health bar display
ESP:ToggleDistance()    -- Toggle distance display
ESP:ToggleName()        -- Toggle name display
ESP:ToggleTool()        -- Toggle tool display
```

---

## 🎨 Customization

### Color Settings

```lua
ESP:SetColor(Color3.fromRGB(255, 0, 0))       -- Set box color
ESP:SetTextColor(Color3.fromRGB(255, 0, 0))   -- Set text color
```

### Size Settings

```lua
ESP:SetSize(14)            -- Set text size
ESP:SetBoxThickness(2)     -- Set box line thickness
ESP:SetCornerSize(6)       -- Set corner box size
```

### Distance Settings

```lua
ESP:SetMaxDistance(1000)   -- Set maximum render distance
```

---

## ⚙️ Properties

```lua
ESP.Enabled            -- ESP state (true/false)
ESP.ShowDistance       -- Show distance (true/false)
ESP.ShowName           -- Show names (true/false)
ESP.CornerBoxEnabled   -- Show corner boxes (true/false)
ESP.BoxThickness       -- Box line thickness (number)
ESP.TextSize           -- Text size (number)
ESP.MaxDistance        -- Maximum render distance (number)
```

---

## 🎨 Color Properties

```lua
ESP.TextColor          -- Text color (Color3)
ESP.BoxColor           -- Box color (Color3)
ESP.HealthBarWidth     -- Health bar width (number)
ESP.HealthBarOffset    -- Health bar offset (number)
```

---

## 🔧 Advanced Settings

```lua
ESP.TextOutlineColor   -- Text outline color (Color3)
ESP.CornerSize         -- Corner box size (number)
```

---

**Note:** All changes take effect immediately after calling the respective functions.



