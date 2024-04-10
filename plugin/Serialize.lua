local Serializer = {}

--[[
  Serialization Syntax:
  M: Model
  P: Part
  >: Child down
  ^: Parent up
  ,: Sibling

  [C;P;O;S] Properties
    - C: XXXX: Color (BrickColor Index)
    - P: x,y,z: Position (Vector3)
    - O: x,y,z: Orientation (Vector3)
    - S: x,y,z: Size (Vector3)

  Example:
  M>P[...],P[...],P[...],M>P[...]^P[...]>P[...]>P[...]^^P[...]
]]

function Serializer:EncodeModel(base: Model | Part): string
  
end

function Serializer:DecodeModel(data: string): nil
  local baseModel = Instance.new("Model")
  baseModel.Parent = workspace
  baseModel.Name = "Generated Model"
end

function Serializer:_roundVector(vector: Vector3): Vector3
  return Vector3.new(
    math.floor(vector.X * 10) / 10,
    math.floor(vector.Y * 10) / 10,
    math.floor(vector.Z * 10) / 10
  )
end


return Serializer