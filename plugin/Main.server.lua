local HTTPService = game:GetService("HttpService")
local Tests = require(script.Parent.Tests)
local Serializer = require(script.Parent.Serializer)

local uilib = script.Parent.uilib
local LabeledTextInput = require(uilib.LabeledTextInput)
local CollapsibleTitledSection = require(uilib.CollapsibleTitledSection)
local VerticalScrollingFrame = require(uilib.VerticalScrollingFrame)
local VerticallyScalingListFrame = require(uilib.VerticallyScalingListFrame)
local LabeledCheckbox = require(uilib.LabeledCheckbox)

local toolbar = plugin:CreateToolbar("Mason AI")
local button = toolbar:CreateButton("Open Panel", "Open the panel that allows you to collect/serialize data!", "rbxassetid://10938069104")

local widgetInfo = DockWidgetPluginGuiInfo.new(
  Enum.InitialDockState.Bottom,
  false, false,
  300, 200,
  300, 200
)

local widget = plugin:CreateDockWidgetPluginGui("MasonAI", widgetInfo)
widget.Title = "Mason AI"

local scrollFrame = VerticalScrollingFrame.new("ScrollFrame")
local listFrame = VerticallyScalingListFrame.new("ListFrame")

local dataCollapse = CollapsibleTitledSection.new("Collapse", "Data Collection", true, true, true)
local portInput = LabeledTextInput.new("PortNumber", "Port #", "3232")
local serverCheckbox = LabeledCheckbox.new("ServerCheckbox", "Connection", false, false)
local dataCheckbox = LabeledCheckbox.new("DataCheckbox", "Stream data", false, true)

portInput:SetMaxGraphemes(5)

local serializeCollapse = CollapsibleTitledSection.new("Collapse", "Serialization", true, true, true)
local serializedInput = LabeledTextInput.new("SerializedInput", "Serialized", "")
serializedInput:SetMaxGraphemes(math.huge)

portInput:GetFrame().Parent = dataCollapse:GetContentsFrame()
serverCheckbox:GetFrame().Parent = dataCollapse:GetContentsFrame()
dataCheckbox:GetFrame().Parent = dataCollapse:GetContentsFrame()
serializedInput:GetFrame().Parent = serializeCollapse:GetContentsFrame()

listFrame:AddChild(dataCollapse:GetSectionFrame())
listFrame:AddChild(serializeCollapse:GetSectionFrame())
listFrame:AddBottomPadding()

listFrame:GetFrame().Parent = scrollFrame:GetContentsFrame()
scrollFrame:GetSectionFrame().Parent = widget

local function postData(data)
  local URL = `http://localhost:{portInput:GetValue()}`

  local success, result = pcall(function()
    return HTTPService:PostAsync(`{URL}/data/`, HTTPService:JSONEncode(data), Enum.HttpContentType.ApplicationJson)
  end)

  if success then
    print(`Successfully posted data: {result}`)
  else
    warn(`Failed to upload data: {result}`)
  end
end

button.Click:Connect(function()
  widget.Enabled = not widget.Enabled
end)

serverCheckbox:SetValueChangedFunction(function(newValue)
	dataCheckbox:SetDisabled(not newValue)
  dataCheckbox:SetValue(false)

  if not newValue then return end

  local testData = {
    name = "Test",
    description = "This is a test",
    serialization = Serializer:EncodeModelNoDepth(workspace["Pine Tree"])
  }

  postData(testData)
end)