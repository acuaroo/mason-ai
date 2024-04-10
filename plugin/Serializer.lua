local Serializer = {}

--[[
  Serialization Depth Syntax:
  M: Model
  P: Part
  >: Child down
  ^: Parent up
  -: Sibling

  [C;P;O;S] Properties
    - C: XXXX: Color (BrickColor Index)
    - P: x,y,z: Position (Vector3)
    - O: x,y,z: Orientation (Vector3)
    - S: x,y,z: Size (Vector3)

  Example:
  M>P[...]-P[...]-P[...]-M>P[...]^P[...]>P[...]>P[...]^^P[...]
]]

function Serializer:EncodeModelNoDepth(model: Model): string
  local encoded = ""

  for obj in model:GetDescendants() do
    if not obj:IsA("BasePart") then continue end

    local properties = {
      tostring(obj.BrickColor.Number),
      self:_tostringV3(obj.Position),
      self:_tostringV3(obj.Orientation),
      self:_tostringV3(obj.Size)
    }

    encoded += `{table.concat(properties, ";")}-"`
  end

  return encoded
end

function Serializer:DecodeModelNoDepth(data: string): Model
  local baseModel = Instance.new("Model")
  baseModel.Parent = workspace
  baseModel.Name = "Generated Model"

  local parts = string.split(data, "-")

  for part in parts do
    local properties = string.split(part, ";")
    local part = Instance.new("Part")
    part.Parent = baseModel

    part.BrickColor = BrickColor.new(properties[1])
    part.Position = Serializer:_toV3string(properties[2])
    part.Orientation = Serializer:_toV3string(properties[3])
    part.Size = Serializer:_toV3string(properties[4])
  end

  return baseModel
end

function Serializer:_tostringV3(vector: Vector3): string
  vector = Serializer:_roundVector(vector)

  return `{vector.X},{vector.Y},{vector.Z}`
end

function Serializer:_toV3string(str: string): Vector3
  local values = string.split(str, ",")

  return Vector3.new(values[1], values[2], values[3])
end

function Serializer:_roundVector(vector: Vector3): Vector3
  return Vector3.new(
    math.floor(vector.X * 10) / 10,
    math.floor(vector.Y * 10) / 10,
    math.floor(vector.Z * 10) / 10
  )
end


return Serializer