local Serializer = require(script.Parent.Serializer)

local model = workspace:WaitForChild("TestModel")

local encoded = Serializer:EncodeModelNoDepth(model)
local decoded = Serializer:DecodeModelNoDepth(encoded)

print(`Encoded model: {encoded}`)
print(`Decoded model: {decoded}`)