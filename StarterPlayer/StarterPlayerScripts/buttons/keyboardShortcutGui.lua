--!strict

-- keyboardShortcutGui
-- client keyboard shortcuts

local annotater = require(game.ReplicatedStorage.util.annotater)
local _annotate = annotater.getAnnotater(script)

local module = {}

local PlayersService = game:GetService("Players")
local localPlayer = PlayersService.LocalPlayer

module.CreateShortcutGui = function()
	local playerGui = localPlayer:WaitForChild("PlayerGui")
	local existingGui = playerGui:FindFirstChild("KeyboardShortcutsGui")

	if existingGui then
		existingGui.Enabled = true
		return existingGui
	end

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "KeyboardShortcutsGui"
	screenGui.ResetOnSpawn = false
	screenGui.Parent = playerGui

	local mainFrame = Instance.new("Frame")
	mainFrame.Size = UDim2.new(0.4, 0, 0.4, 0)
	mainFrame.Position = UDim2.new(0.3, 0, 0.3, 0)
	mainFrame.BackgroundColor3 = Color3.fromRGB(197, 204, 211) -- Soft gray
	mainFrame.BorderSizePixel = 0
	mainFrame.Parent = screenGui

	local UserInputService = game:GetService("UserInputService")
	local dragging
	local dragStart
	local startPos

	local function updateDrag(input)
		local delta = input.Position - dragStart
		mainFrame.Position =
			UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end

	mainFrame.InputBegan:Connect(function(input)
		if
			input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch
		then
			dragging = true
			dragStart = input.Position
			startPos = mainFrame.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if
			input.UserInputType == Enum.UserInputType.MouseMovement
			or input.UserInputType == Enum.UserInputType.Touch
		then
			if dragging then
				updateDrag(input)
			end
		end
	end)

	local UserInputService = game:GetService("UserInputService")
	local dragging
	local dragStart
	local startPos

	local cornerRadius = Instance.new("UICorner")
	cornerRadius.CornerRadius = UDim.new(0.05, 0) -- Gentler corners
	cornerRadius.Parent = mainFrame

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, 0, 0.15, 0)
	title.Position = UDim2.new(0, 0, 0, 0)
	title.BackgroundColor3 = Color3.fromRGB(168, 208, 230) -- Pale blue
	title.Font = Enum.Font.GothamSemibold
	title.TextColor3 = Color3.fromRGB(70, 70, 70) -- Dark gray text
	title.TextScaled = true
	title.Text = "Keyboard Shortcuts"
	title.Parent = mainFrame

	local titleCorner = Instance.new("UICorner")
	titleCorner.CornerRadius = UDim.new(0.2, 0)
	titleCorner.Parent = title

	local shortcutsList = Instance.new("ScrollingFrame")
	shortcutsList.Size = UDim2.new(0.9, 0, 0.75, 0)
	shortcutsList.Position = UDim2.new(0.05, 0, 0.2, 0)
	shortcutsList.BackgroundTransparency = 1
	shortcutsList.BorderSizePixel = 0
	shortcutsList.ScrollBarThickness = 4
	shortcutsList.AutomaticCanvasSize = Enum.AutomaticSize.Y
	shortcutsList.CanvasSize = UDim2.new(0, 0, 0, 0)
	shortcutsList.Parent = mainFrame

	local listLayout = Instance.new("UIListLayout")
	listLayout.Padding = UDim.new(0, 8)
	listLayout.Parent = shortcutsList

	local shortcuts = {
		{ key = "1", desc = "Warp to last completed run", icon = "🏃" },
		{ key = "h", desc = "Remove sign highlights", icon = "🚫" },
		{ key = "z", desc = "Cancel current race", icon = "🚫" },
		{ key = "x", desc = "Remove popped up UIs and notifications", icon = "🗑️" },
		{ key = "Tab", desc = "Toggle leaderboard", icon = "📊" },
	}

	for _, shortcut in ipairs(shortcuts) do
		local shortcutFrame = Instance.new("Frame")
		shortcutFrame.Size = UDim2.new(1, 0, 0, 40)
		shortcutFrame.BackgroundColor3 = Color3.fromRGB(184, 216, 186) -- Soft green
		shortcutFrame.BorderSizePixel = 0
		shortcutFrame.Parent = shortcutsList

		local shortcutCorner = Instance.new("UICorner")
		shortcutCorner.CornerRadius = UDim.new(0.2, 0)
		shortcutCorner.Parent = shortcutFrame

		local keyLabel = Instance.new("TextLabel")
		keyLabel.Size = UDim2.new(0.15, 0, 0.8, 0)
		keyLabel.Position = UDim2.new(0.02, 0, 0.1, 0)
		keyLabel.BackgroundColor3 = Color3.fromRGB(241, 167, 167) -- Soft red
		keyLabel.Font = Enum.Font.GothamBold
		keyLabel.TextColor3 = Color3.fromRGB(70, 70, 70)
		keyLabel.TextScaled = true
		keyLabel.Text = shortcut.key
		keyLabel.Parent = shortcutFrame

		local keyCorner = Instance.new("UICorner")
		keyCorner.CornerRadius = UDim.new(0.3, 0)
		keyCorner.Parent = keyLabel

		local descLabel = Instance.new("TextLabel")
		descLabel.Size = UDim2.new(0.68, 0, 0.8, 0)
		descLabel.Position = UDim2.new(0.2, 0, 0.1, 0)
		descLabel.BackgroundTransparency = 1
		descLabel.Font = Enum.Font.Gotham
		descLabel.TextColor3 = Color3.fromRGB(70, 70, 70)
		descLabel.TextScaled = true
		descLabel.Text = shortcut.desc
		descLabel.TextXAlignment = Enum.TextXAlignment.Left
		descLabel.Parent = shortcutFrame

		local iconLabel = Instance.new("TextLabel")
		iconLabel.Size = UDim2.new(0.1, 0, 0.8, 0)
		iconLabel.Position = UDim2.new(0.88, 0, 0.1, 0)
		iconLabel.BackgroundTransparency = 1
		iconLabel.Font = Enum.Font.Gotham
		iconLabel.TextColor3 = Color3.fromRGB(70, 70, 70)
		iconLabel.TextScaled = true
		iconLabel.Text = shortcut.icon
		iconLabel.Parent = shortcutFrame
	end

	-- Adjust the ScrollingFrame's size
	local function updateScrollingFrameSize()
		local contentSize = listLayout.AbsoluteContentSize
		shortcutsList.CanvasSize = UDim2.new(0, 0, 0, contentSize.Y)
		shortcutsList.Size = UDim2.new(0.9, 0, math.min(0.75, contentSize.Y / mainFrame.AbsoluteSize.Y), 0)
	end

	listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateScrollingFrameSize)
	updateScrollingFrameSize()

	local closeButton = Instance.new("TextButton")
	closeButton.Size = UDim2.new(0.3, 0, 0.08, 0)
	closeButton.Position = UDim2.new(0.35, 0, 0.9, 0)
	closeButton.BackgroundColor3 = Color3.fromRGB(241, 167, 167) -- Soft red
	closeButton.Text = "Close"
	closeButton.TextColor3 = Color3.fromRGB(70, 70, 70)
	closeButton.Font = Enum.Font.GothamSemibold
	closeButton.TextSize = 14
	closeButton.Parent = mainFrame

	local closeCorner = Instance.new("UICorner")
	closeCorner.CornerRadius = UDim.new(0.3, 0)
	closeCorner.Parent = closeButton

	closeButton.MouseButton1Click:Connect(function()
		screenGui.Enabled = false
	end)

	return screenGui
end

_annotate("end")
return module
