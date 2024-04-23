local HTTPService = game:GetService("HttpService")
local InsertService = game:GetService("InsertService")
local Serializer = require(script.Parent.Serializer)

local DataCollection = {}
DataCollection.Active = true

function DataCollection:Post(url, data)
  local success, result = pcall(function()
    return HTTPService:PostAsync(url, HTTPService:JSONEncode(data), Enum.HttpContentType.ApplicationJson)
  end)

  return success, result
end

function DataCollection:Get(url)
  local success, result = pcall(function()
    return HTTPService:GetAsync(url)
  end)

  return success, result
end

function DataCollection:Scrape(url)
  DataCollection.Active = true
  
  task.spawn(function()
    while DataCollection.Active do
      print("[MASON]: Scanning for models...")
      task.wait(0.5)

      local asset_id = math.random(100000, 9000000)
      local success, result = self:Post(`{url}/productid`, {["asset_id"] = asset_id})
      if not success then continue end

      local decoded = nil

      pcall(function()
        decoded = HTTPService:JSONDecode(result)
      end)

      if not decoded or not decoded["data"] then continue end

      local asset = decoded["data"][1]
      if not asset then continue end

      local product_id = asset["product"]["productId"]
      local name = asset["asset"]["name"]
      local description = asset["asset"]["description"]

      local success, result = self:Post(`{url}/model`, {["asset_id"] = asset_id, ["product_id"] = product_id})
      if not success then continue end
      
      task.wait(1)

      local success, result = pcall(function()
        InsertService:LoadAsset(asset_id).Parent = workspace
      end)

      if not success then continue end

      print(`[MASON]: Model found! {name}, {description}, {asset_id}`)
      
      local model = workspace:WaitForChild("Model")
      local isValid = DataCollection:ValidateModel(model)

      if not isValid then 
        print("[MASON]: Model was invalid!")
        model:Destroy()
        continue 
      end

      model:PivotTo(CFrame.new(0, 0, 0))
      local serialized = Serializer:EncodeModelNoDepth(model)
      self:Post(`{url}/data`, {["name"] = name, ["description"] = description, ["serialized"] = serialized})

      model:Destroy()
    end
  end)
end

function DataCollection:StopScraping()
  DataCollection.Active = false
end

function DataCollection:ValidateModel(model)
  local descendants = model:GetDescendants()
  if #descendants > 1000 then return false end
  if #descendants < 2 then return false end
  
  local population = {}

  for _, obj in descendants do
    population[obj.ClassName] = (population[obj.ClassName] or 0) + 1
  end

  if ((population["MeshPart"] or 0) / #descendants) > 0.35 then
    return false
  end

  return true
end

return DataCollection