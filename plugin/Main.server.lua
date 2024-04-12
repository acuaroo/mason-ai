local Tests = require(script.Parent.Tests)

local uilib = script.Parent.uilib
local LabeledTextInput = require(uilib.LabeledTextInput)
local CollapsibleTitledSection = require(uilib.CollapsibleTitledSection)
local VerticalScrollingFrame = require(uilib.VerticalScrollingFrame)
local VerticallyScalingListFrame = require(uilib.VerticallyScalingListFrame)

local toolbar = plugin:CreateToolbar("Mason AI")
local button = toolbar:CreateButton("Open Panel", "Open the panel that allows you to collect/deserialize data!", "rbxassetid://10938069104")

button.Click:Connect(function()
  widget.Enabled = not widget.Enabled
end)

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
portInput:SetMaxGraphemes(4)

portInput:GetFrame().Parent = dataCollapse:GetContentsFrame()
listFrame:AddChild(dataCollapse:GetSectionFrame())

local serializeCollapse = CollapsibleTitledSection.new("Collapse", "Serialization", true, true, true)
local serializedInput = LabeledTextInput.new("SerializedInput", "Serialized", "")
serializedInput:SetMaxGraphemes(math.huge)

serializedInput:GetFrame().Parent = serializeCollapse:GetContentsFrame()
listFrame:AddChild(serializeCollapse:GetSectionFrame())

listFrame:AddBottomPadding()

listFrame:GetFrame().Parent = scrollFrame:GetContentsFrame()
scrollFrame:GetSectionFrame().Parent = widget