--!strict

--eval 9.24.22

local colors = require(game.ReplicatedStorage.util.colors)
local guiUtil = require(game.ReplicatedStorage.gui.guiUtil)
local tt = require(game.ReplicatedStorage.types.gametypes)
local gt = require(game.ReplicatedStorage.gui.guiTypes)
local rf = require(game.ReplicatedStorage.util.remotes)
local settingEnums = require(game.ReplicatedStorage.UserSettings.settingEnums)

local PlayersService = game:GetService("Players")

local module = {}
local userSettingsChangedFunction = rf.getRemoteFunction("UserSettingsChangedFunction") :: RemoteFunction

local function makeSurveyRowFrame(setting: tt.userSettingValue, player: Player, n: number): Frame
	local fr = Instance.new("Frame")
	fr.Name = string.format("33-settingRow-%04d", n) .. "setting." .. setting.name
	fr.Size = UDim2.new(1, 0, 0, 30)
	local vv = Instance.new("UIListLayout")
	vv.FillDirection = Enum.FillDirection.Horizontal
	vv.SortOrder = Enum.SortOrder.Name
	vv.Parent = fr
	local label = guiUtil.getTl("00-Domain", UDim2.new(0.2, 0, 1, 0), 4, fr, colors.defaultGrey, 1)
	label.TextScaled = false
	label.Text = setting.domain
	label.FontSize = Enum.FontSize.Size18
	label.TextXAlignment = Enum.TextXAlignment.Center
	label.TextYAlignment = Enum.TextYAlignment.Center

	local tl = guiUtil.getTl("01-SettingName", UDim2.new(0.5, 0, 1, 0), 4, fr, colors.defaultGrey, 1)
	tl.Text = setting.name
	tl.TextXAlignment = Enum.TextXAlignment.Left
	local noButton = guiUtil.getTb("02-No." .. setting.name, UDim2.new(0.1, -3, 1, 0), 2, fr, colors.defaultGrey, 1)
	noButton.Text = "No"
	local unsetButton =
		guiUtil.getTb("03-Unset-" .. setting.name, UDim2.new(0.1, -4, 1, 0), 2, fr, colors.defaultGrey, 1)
	unsetButton.Text = "-"
	local yesButton = guiUtil.getTb("04-Yes-" .. setting.name, UDim2.new(0.1, -3, 1, 0), 2, fr, colors.defaultGrey, 1)
	yesButton.Text = "Yes"
	local nowValue = nil

	if setting.value == false then
		noButton.BackgroundColor3 = colors.redStop
		nowValue = false
	elseif setting.value == true then
		yesButton.BackgroundColor3 = colors.greenGo
		nowValue = true
	else
		nowValue = nil
	end

	local localFunctions = require(game.ReplicatedStorage.localFunctions)
	noButton.Activated:Connect(function()
		if nowValue == false then
			nowValue = nil
			noButton.BackgroundColor3 = colors.defaultGrey
		elseif nowValue == nil or nowValue == true then
			nowValue = false
			noButton.BackgroundColor3 = colors.redStop
			yesButton.BackgroundColor3 = colors.defaultGrey
		end
		setting.value = nowValue
		localFunctions.notifySettingChange(player, setting)
		userSettingsChangedFunction:InvokeServer(setting)
	end)

	unsetButton.Activated:Connect(function()
		if nowValue == false or nowValue == true then
			nowValue = nil
			noButton.BackgroundColor3 = colors.defaultGrey
			yesButton.BackgroundColor3 = colors.defaultGrey
			setting.value = nowValue
			localFunctions.notifySettingChange(player, setting)
			userSettingsChangedFunction:InvokeServer(setting)
		end
	end)

	yesButton.Activated:Connect(function()
		if nowValue == false or nowValue == nil then
			nowValue = true
			noButton.BackgroundColor3 = colors.defaultGrey
			yesButton.BackgroundColor3 = colors.greenGo
		elseif nowValue == true then
			nowValue = nil
			noButton.BackgroundColor3 = colors.defaultGrey
			yesButton.BackgroundColor3 = colors.defaultGrey
		end
		setting.value = nowValue
		localFunctions.notifySettingChange(player, setting)
		userSettingsChangedFunction:InvokeServer(setting)
	end)

	return fr
end

--we already have clientside stuff whic hgets initial settings value.
local getSurveyModal = function(localPlayer: Player): ScreenGui
	local userId = localPlayer.UserId
	local sg = Instance.new("ScreenGui")
	sg.Name = "SettingsSgui"

	local userSettingsFunction: RemoteFunction = rf.getRemoteFunction("GetUserSettingsFunction")
	local userSettings: { tt.userSettingValue } = userSettingsFunction:InvokeServer("Survey")

	local outerFrame = Instance.new("Frame")
	outerFrame.Parent = sg
	outerFrame.Size = UDim2.new(0.4, 0, 0.5, 0)
	outerFrame.Position = UDim2.new(0.3, 0, 0.3, 0)
	local vv2 = Instance.new("UIListLayout")
	vv2.FillDirection = Enum.FillDirection.Vertical
	vv2.Parent = outerFrame

	local headerFrame = Instance.new("Frame")
	headerFrame.Parent = outerFrame
	headerFrame.Name = "01SurveySettingsHeader"
	headerFrame.Size = UDim2.new(1, 0, 0, 20)
	local vv = Instance.new("UIListLayout")
	vv.FillDirection = Enum.FillDirection.Horizontal
	vv.Parent = headerFrame
	local tl = guiUtil.getTl("01Type", UDim2.new(0.2, 0, 0, 20), 4, headerFrame, colors.blueDone, 1)
	tl.Text = "Type"

	local tl = guiUtil.getTl("02Name", UDim2.new(0.5, 0, 0, 20), 4, headerFrame, colors.blueDone, 1)
	tl.Text = "Name"

	local tl = guiUtil.getTl("03Value", UDim2.new(0.3, 0, 0, 20), 4, headerFrame, colors.blueDone, 1)
	tl.Text = "Value"

	--scrolling setting frame
	local frameName = "02SettingsModal"
	local scrollingFrame = Instance.new("ScrollingFrame")
	scrollingFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
	scrollingFrame.ScrollBarThickness = 10
	scrollingFrame.Name = frameName
	scrollingFrame.ScrollingDirection = Enum.ScrollingDirection.Y
	scrollingFrame.Parent = outerFrame
	scrollingFrame.Size = UDim2.new(1, 0, 1, -60)
	scrollingFrame.VerticalScrollBarInset = Enum.ScrollBarInset.Always
	scrollingFrame.CanvasSize = UDim2.new(1, 0, 1, 0)
	local vv = Instance.new("UIListLayout")
	vv.FillDirection = Enum.FillDirection.Vertical
	vv.Parent = scrollingFrame

	local player: Player = PlayersService:GetPlayerByUserId(userId)
	for ii, setting in ipairs(userSettings) do
		if setting.domain ~= settingEnums.settingDomains.Surveys then
			continue
		end
		local rowFrame = makeSurveyRowFrame(setting, player, ii)
		rowFrame.Parent = scrollingFrame
	end

	local tb = guiUtil.getTbSimple()
	tb.Text = "Close"
	tb.Name = "03ZZZMarathonSettingsCloseButton"
	tb.Size = UDim2.new(1, 0, 0, 40)
	tb.BackgroundColor3 = colors.redStop
	tb.Parent = outerFrame
	tb.Activated:Connect(function()
		sg:Destroy()
	end)
	return sg
end

local surveySettingsButton: gt.button = {
	name = "Surveys",
	contentsGetter = getSurveyModal,
}

module.surveySettingsButton = surveySettingsButton

return module
