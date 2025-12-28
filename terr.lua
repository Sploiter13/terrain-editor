--!native
--!optimize 2

loadstring(game:HttpGet("https://raw.githubusercontent.com/Sploiter13/severefuncs/refs/heads/main/merge2.lua"))();
task.wait(2)

---- environment ----
local game = game
local workspace = game:GetService("Workspace")
local task = task

---- get terrain ----
local Terrain = workspace:FindFirstChildOfClass("Terrain")

if not Terrain then
	warn("❌ Terrain not found!")
	return
end

---- variables ----
local selectedMaterial = "Grass"
local currentMaterialColor = {0, 255, 0}

local MATERIAL_NAMES = {
	"Grass", "Sand", "Rock", "Snow", "Ice", "LeafyGrass", "Ground",
	"CrackedLava", "Basalt", "Asphalt", "Concrete", "Brick",
	"Cobblestone", "Pavement", "Glacier", "Limestone", "Mud",
	"Salt", "Sandstone", "Slate", "WoodPlanks"
}

---- store original values ----
local originalValues = {
	materials = {},
	water = {},
	grass = {}
}

-- Store original material colors
for _, materialName in ipairs(MATERIAL_NAMES) do
	pcall(function()
		local color = Terrain:GetMaterialColor(materialName)
		originalValues.materials[materialName] = color
	end)
end

-- Store original water properties
pcall(function()
	originalValues.water.Color = Terrain.WaterColor
	originalValues.water.Transparency = Terrain.WaterTransparency
	originalValues.water.Reflectance = Terrain.WaterReflectance
	originalValues.water.WaveSize = Terrain.WaterWaveSize
	originalValues.water.WaveSpeed = Terrain.WaterWaveSpeed
end)

-- Store original grass properties
pcall(function()
	originalValues.grass.Length = Terrain.GrassLength
end)

---- load ui library ----
local bytecode = game:HttpGet("https://github.com/misterzeee/SevereUiLib/raw/refs/heads/main/MainByteCode.lua")
local func = luau.load(bytecode)
func()
local UI = zeeUi

---- set theme ----
UI.setTheme("Midnight")

---- create window ----
local win = UI.createWindow({ title = "Terrain Editor" })

---- create tabs ----
local materialsTab = win:addTab("Materials")
local waterTab = win:addTab("Water")
local presetsTab = win:addTab("Presets")

---- materials tab ----
materialsTab:addText({ text = "Select Material to Edit:" })

local materialDropdown = materialsTab:addDropdown({
	text = "Material",
	items = MATERIAL_NAMES,
	defaultIndex = 1
})

materialDropdown.OnChanged:Connect(function(value, index)
	selectedMaterial = value
	
	-- Get current color of selected material
	local success, color = pcall(function()
		return Terrain:GetMaterialColor(value)
	end)
	
	if success then
		currentMaterialColor = {
			math.floor(color.R * 255),
			math.floor(color.G * 255),
			math.floor(color.B * 255)
		}
	end
end)

materialsTab:addText({ text = "Color Picker:" })

local materialColorPicker = materialsTab:addColorPicker({
	text = "Material Color",
	default = {0, 255, 0}
})

materialColorPicker.OnChanged:Connect(function(color)
	if selectedMaterial then
		local color3 = Color3.fromRGB(color[1], color[2], color[3])
		pcall(function()
			Terrain:SetMaterialColor(selectedMaterial, color3)
		end)
	end
end)

local applyColorBtn = materialsTab:addButton({ text = "Apply Color" })
applyColorBtn.OnClick:Connect(function()
	if selectedMaterial then
		local color = materialColorPicker:getColor()
		local color3 = Color3.fromRGB(color[1], color[2], color[3])
		pcall(function()
			Terrain:SetMaterialColor(selectedMaterial, color3)
		end)
	end
end)

local resetMaterialBtn = materialsTab:addButton({ text = "Reset Selected Material" })
resetMaterialBtn.OnClick:Connect(function()
	if selectedMaterial and originalValues.materials[selectedMaterial] then
		pcall(function()
			Terrain:SetMaterialColor(selectedMaterial, originalValues.materials[selectedMaterial])
		end)
	end
end)

local resetAllBtn = materialsTab:addButton({ text = "Reset All Materials" })
resetAllBtn.OnClick:Connect(function()
	for materialName, originalColor in pairs(originalValues.materials) do
		pcall(function()
			Terrain:SetMaterialColor(materialName, originalColor)
		end)
	end
end)

---- water tab ----
waterTab:addText({ text = "Water Color:" })

local waterColorPicker = waterTab:addColorPicker({
	text = "Water Color",
	default = {
		math.floor(originalValues.water.Color.R * 255),
		math.floor(originalValues.water.Color.G * 255),
		math.floor(originalValues.water.Color.B * 255)
	}
})

waterColorPicker.OnChanged:Connect(function(color)
	local color3 = Color3.fromRGB(color[1], color[2], color[3])
	pcall(function()
		Terrain.WaterColor = color3
	end)
end)

waterTab:addText({ text = "Water Properties:" })

local waterTransparency = waterTab:addSlider({
	text = "Transparency",
	min = 0,
	max = 100,
	mode = "percent",
	default = math.floor(originalValues.water.Transparency * 100)
})

waterTransparency.OnChanged:Connect(function(v)
	pcall(function()
		Terrain.WaterTransparency = v / 100
	end)
end)

local waterReflectance = waterTab:addSlider({
	text = "Reflectance",
	min = 0,
	max = 100,
	mode = "percent",
	default = math.floor(originalValues.water.Reflectance * 100)
})

waterReflectance.OnChanged:Connect(function(v)
	pcall(function()
		Terrain.WaterReflectance = v / 100
	end)
end)

local waterWaveSize = waterTab:addSlider({
	text = "Wave Size",
	min = 0,
	max = 100,
	mode = "percent",
	default = math.floor(originalValues.water.WaveSize * 100)
})

waterWaveSize.OnChanged:Connect(function(v)
	pcall(function()
		Terrain.WaterWaveSize = v / 100
	end)
end)

local waterWaveSpeed = waterTab:addSlider({
	text = "Wave Speed",
	min = 0,
	max = 100,
	mode = "number",
	default = math.floor(originalValues.water.WaveSpeed)
})

waterWaveSpeed.OnChanged:Connect(function(v)
	pcall(function()
		Terrain.WaterWaveSpeed = v
	end)
end)

waterTab:addText({ text = "Grass:" })

local grassLength = waterTab:addSlider({
	text = "Grass Length",
	min = 0,
	max = 100,
	mode = "percent",
	default = math.floor(originalValues.grass.Length * 100)
})

grassLength.OnChanged:Connect(function(v)
	pcall(function()
		Terrain.GrassLength = v / 100
	end)
end)

waterTab:addText({ text = "Reset Water:" })

local resetWaterBtn = waterTab:addButton({ text = "Reset Water Properties" })
resetWaterBtn.OnClick:Connect(function()
	pcall(function()
		Terrain.WaterColor = originalValues.water.Color
		Terrain.WaterTransparency = originalValues.water.Transparency
		Terrain.WaterReflectance = originalValues.water.Reflectance
		Terrain.WaterWaveSize = originalValues.water.WaveSize
		Terrain.WaterWaveSpeed = originalValues.water.WaveSpeed
	end)
end)

local resetGrassBtn = waterTab:addButton({ text = "Reset Grass Length" })
resetGrassBtn.OnClick:Connect(function()
	pcall(function()
		Terrain.GrassLength = originalValues.grass.Length
	end)
end)

---- presets tab ----
presetsTab:addText({ text = "Material Presets:" })

local vibrantGrassBtn = presetsTab:addButton({ text = "Vibrant Grass" })
vibrantGrassBtn.OnClick:Connect(function()
	pcall(function()
		Terrain:SetMaterialColor("Grass", Color3.fromRGB(0, 255, 0))
		Terrain:SetMaterialColor("LeafyGrass", Color3.fromRGB(50, 200, 50))
		Terrain:SetMaterialColor("Ground", Color3.fromRGB(100, 80, 50))
		Terrain.GrassLength = 0.5
	end)
end)

local desertBtn = presetsTab:addButton({ text = "Desert Theme" })
desertBtn.OnClick:Connect(function()
	pcall(function()
		Terrain:SetMaterialColor("Sand", Color3.fromRGB(255, 220, 150))
		Terrain:SetMaterialColor("Sandstone", Color3.fromRGB(200, 180, 120))
		Terrain:SetMaterialColor("Rock", Color3.fromRGB(150, 140, 130))
		Terrain:SetMaterialColor("Ground", Color3.fromRGB(200, 160, 100))
		Terrain.GrassLength = 0.01
	end)
end)

local snowBtn = presetsTab:addButton({ text = "Snow World" })
snowBtn.OnClick:Connect(function()
	pcall(function()
		Terrain:SetMaterialColor("Snow", Color3.fromRGB(255, 255, 255))
		Terrain:SetMaterialColor("Ice", Color3.fromRGB(200, 230, 255))
		Terrain:SetMaterialColor("Glacier", Color3.fromRGB(180, 220, 250))
		Terrain.WaterColor = Color3.fromRGB(200, 230, 255)
		Terrain.WaterTransparency = 0.5
	end)
end)

local volcanicBtn = presetsTab:addButton({ text = "Volcanic World" })
volcanicBtn.OnClick:Connect(function()
	pcall(function()
		Terrain:SetMaterialColor("CrackedLava", Color3.fromRGB(255, 50, 0))
		Terrain:SetMaterialColor("Basalt", Color3.fromRGB(80, 30, 30))
		Terrain:SetMaterialColor("Rock", Color3.fromRGB(100, 40, 40))
		Terrain:SetMaterialColor("Ground", Color3.fromRGB(60, 20, 20))
		Terrain.WaterColor = Color3.fromRGB(255, 100, 0)
		Terrain.WaterTransparency = 0
	end)
end)

local alienBtn = presetsTab:addButton({ text = "Alien Planet" })
alienBtn.OnClick:Connect(function()
	pcall(function()
		Terrain:SetMaterialColor("Grass", Color3.fromRGB(200, 0, 200))
		Terrain:SetMaterialColor("Ground", Color3.fromRGB(100, 0, 150))
		Terrain:SetMaterialColor("Rock", Color3.fromRGB(150, 50, 200))
		Terrain:SetMaterialColor("Sand", Color3.fromRGB(255, 100, 255))
	end)
end)

presetsTab:addText({ text = "Water Presets:" })

local clearWaterBtn = presetsTab:addButton({ text = "Clear Water" })
clearWaterBtn.OnClick:Connect(function()
	pcall(function()
		Terrain.WaterColor = Color3.fromRGB(100, 150, 255)
		Terrain.WaterTransparency = 0.8
		Terrain.WaterWaveSize = 0.05
		Terrain.WaterWaveSpeed = 5
	end)
end)

local oceanBtn = presetsTab:addButton({ text = "Ocean Water" })
oceanBtn.OnClick:Connect(function()
	pcall(function()
		Terrain.WaterColor = Color3.fromRGB(12, 84, 91)
		Terrain.WaterTransparency = 0.3
		Terrain.WaterWaveSize = 0.25
		Terrain.WaterWaveSpeed = 15
	end)
end)

local toxicBtn = presetsTab:addButton({ text = "Toxic Water" })
toxicBtn.OnClick:Connect(function()
	pcall(function()
		Terrain.WaterColor = Color3.fromRGB(100, 255, 0)
		Terrain.WaterTransparency = 0.1
		Terrain.WaterWaveSize = 0.4
		Terrain.WaterWaveSpeed = 50
	end)
end)

local lavaBtn = presetsTab:addButton({ text = "Lava" })
lavaBtn.OnClick:Connect(function()
	pcall(function()
		Terrain.WaterColor = Color3.fromRGB(255, 100, 0)
		Terrain.WaterTransparency = 0
		Terrain.WaterWaveSize = 0.3
		Terrain.WaterWaveSpeed = 8
	end)
end)

presetsTab:addText({ text = "Reset Everything:" })

local resetEverythingBtn = presetsTab:addButton({ text = "Reset All to Original" })
resetEverythingBtn.OnClick:Connect(function()
	-- Reset all materials
	for materialName, originalColor in pairs(originalValues.materials) do
		pcall(function()
			Terrain:SetMaterialColor(materialName, originalColor)
		end)
	end
	
	-- Reset water
	pcall(function()
		Terrain.WaterColor = originalValues.water.Color
		Terrain.WaterTransparency = originalValues.water.Transparency
		Terrain.WaterReflectance = originalValues.water.Reflectance
		Terrain.WaterWaveSize = originalValues.water.WaveSize
		Terrain.WaterWaveSpeed = originalValues.water.WaveSpeed
	end)
	
	-- Reset grass
	pcall(function()
		Terrain.GrassLength = originalValues.grass.Length
	end)
end)

return zeeUi
