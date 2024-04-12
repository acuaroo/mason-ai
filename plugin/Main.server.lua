local HTTPService = game:GetService("HttpService")
local InsertService = game:GetService("InsertService")
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
local serverCheckbox = LabeledCheckbox.new("ServerCheckbox", "Server connection", false, false)
local dataCheckbox = LabeledCheckbox.new("DataCheckbox", "Stream data", false, true)

-- dataCheckbox:DisableWithOverrideValue(false)
portInput:SetMaxGraphemes(4)

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
  local URL = `http://localhost:{portInput:GetText()}/`

  local success, result = pcall(function()
    return HTTPService:PostAsync(`{URL}/data/`, HTTPService:JSONEncode(data))
  end)

  if success then
    print(`Successfully posted data: {result}`)
  else
    warn(`Failed to upload data: {result}`)
  end
end

local function validateModel(model)
  local descendants = model:GetDescendants()
  if #desc > 1000 then return false end
  
  local population = {}

  for _, obj in descendants do
    population[obj.ClassName] = (population[obj.ClassName] or 0) + 1
  end

  if (population["MeshPart"] or 0) / #descendants > 0.35 then
    return false
  end

  return true
end

local function scrapeToolbox()
  local assetId = math.random(1000, 100000)
  local success, model = pcall(InsertService.LoadAsset, InsertService, assetId)

  if success and model then
    model.Parent = workspace

    local isValid = validateModel(model)

    if not isValid then
      model:Destroy()
      return
    end

    local serialized = Serializer:EncodeModelNoDepth(model)
    postData({name = "test", description = "test", serialization = serialized})

    return true
  else
    print("Model failed to load! Skipping ...")
    return false
  end
end

button.Click:Connect(function()
  widget.Enabled = not widget.Enabled
end)

serverCheckbox:SetValueChangedFunction(function(newValue)
	dataCheckbox:SetDisabled(newValue)
  dataCheckbox:SetValue(false)
end)