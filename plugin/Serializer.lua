local Serializer = {}

--[[
  Serialization Depth Syntax:
  M: Model
  P: Part
  >: Child down
  ^: Parent up
  -: Sibling

  [C;S;P;O;S] Properties
    - C: XXXX: Color (BrickColor Index)
    - S: X: Shape (Enum.PartType)
    - P: x,y,z: Position (Vector3)
    - O: x,y,z: Orientation (Vector3)
    - S: x,y,z: Size (Vector3)

  Example:
  M>P[...]-P[...]-P[...]-M>P[...]^P[...]>P[...]>P[...]^^P[...]
]]

function Serializer:EncodeModelNoDepth(model: Model): string
  local encoded = ""

  for _, obj in model:GetDescendants() do
    if not obj:IsA("Part") then continue end
    local properties = {
      `C{tostring(obj.BrickColor.Number)}`,
      `S{tostring(obj.Shape.Value)}`,
      -- `M{tostring(obj.Material.Value)}`,
      `P{self:_tostringV3(obj.Position)}`,
      `O{self:_tostringV3(obj.Orientation)}`,
      `I{self:_tostringV3(obj.Size)}`
    }

    encoded = `{encoded}{table.concat(properties, ";")}&"`
  end

  return string.gsub(encoded, "\"", "")
end

function Serializer:DecodeModelNoDepth(data: string): Model
  local baseModel = Instance.new("Model")
  baseModel.Parent = workspace
  baseModel.Name = "Generated Model"

  data = string.gsub(data, "%a", "")
  local parts = string.split(data, "&")

  for _, part in parts do
    local properties = string.split(part, ";")
    if #properties < 5 then continue end

    local part = Instance.new("Part")
    part.Anchored = true
    part.Parent = baseModel

    part.BrickColor = BrickColor.new(tonumber(properties[1]))
    part.Shape = Serializer:_getEnum(tonumber(properties[2]), Enum.PartType)
    -- part.Material = Serializer:_getEnum(tonumber(properties[3]), Enum.Material)
    part.Position = Serializer:_toV3string(properties[3])
    part.Orientation = Serializer:_toV3string(properties[4])
    part.Size = Serializer:_toV3string(properties[5])
  end

  return baseModel
end

function Serializer:_tostringV3(vector: Vector3): string
  if vector.Magnitude == 0 then
    return "_"
  end

  return `{string.format("%.2f", vector.X)},{string.format("%.2f", vector.Y)},{string.format("%.2f", vector.Z)}`
end

function Serializer:_toV3string(str: string): Vector3
  local values = string.split(str, ",")

  return Vector3.new(values[1] or 0, values[2] or 0, values[3] or 0)
end

function Serializer:_getEnum(value: number, enum: Enum): Enum
  print(enum:GetEnumItems(), value)

  return enum:GetEnumItems()[value + 1]
end


return Serializer