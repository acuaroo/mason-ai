local Tests = {}

function Tests:SerializerTest()
  local Serializer = require(script.Parent.Serializer)
  Serializer:Initialize()

  local model = workspace:FindFirstChildOfClass("Model")

  local encoded = Serializer:EncodeModelNoDepth(model)
  local decoded = Serializer:DecodeModelNoDepth(encoded)

  print(`Encoded model: {string.len(encoded)}`)
  print(`Decoded model: {decoded}`)
end

return Tests