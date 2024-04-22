local Tests = require(script.Parent.Tests)
local Serializer = require(script.Parent.Serializer)
local DataCollection = require(script.Parent.DataCollection)

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

button.Click:Connect(function()
  widget.Enabled = not widget.Enabled
end)

local url

serverCheckbox:SetValueChangedFunction(function(newValue)
	dataCheckbox:SetDisabled(not newValue)
  dataCheckbox:SetValue(false)

  if not newValue then
    print("[MASON]: Disconnected from server")
  else
    local port = portInput:GetValue()

    if not port then
      warn("Invalid port number!")
      serverCheckbox:SetValue(false)
      dataCheckbox:SetValue(false)
      dataCheckbox:SetDisabled(true)
      return
    end

    url = `http://localhost:{port}`
    local success, result = DataCollection:Post(`{url}/test`, {})
    
    if success then
      print(`[MASON]: Connected on {url}!`)
    else
      warn(`[MASON]: Failed to connect to server: {result}`)
      serverCheckbox:SetValue(false)
      dataCheckbox:SetValue(false)
      dataCheckbox:SetDisabled(true)
    end
  end
end)

local previous = false

dataCheckbox:SetValueChangedFunction(function(newValue)
  if previous == newValue then return end

  if newValue then
    print("[MASON]: Starting data collection...")
    DataCollection:Scrape(url)
  else
    print("[MASON]: Stopping data collection...")
    DataCollection:StopScraping()
  end

  previous = newValue
end)

serializedInput:SetValueChangedFunction(function(newValue)
  if newValue == "" then return end
  
	Serializer:DecodeModelNoDepth(newValue)
end)