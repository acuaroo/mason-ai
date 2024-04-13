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
  task.spawn(function()
    while DataCollection.Active do
      task.wait(1)
      local id = math.random(1000000, 9999999)
      local success, result = self:Get(`{url}/proxy?url=https://apis.roblox.com/toolbox-service/v1/items/details?assetIds={id}`)

      if not success then
        warn(`[MASON]: Failed to scrape asset {id}: {result}`)
        return
      end

      local success, result = self:Post(`{url}/model`, {["id"] = id})

      if not success then
        warn(`[MASON]: Failed to obtain asset {id}: {result}`)
        return
      end
      
      InsertService:LoadAsset(id)
      print(`Loaded asset {id}!`)
    end
  end)
end

function DataCollection:StopScraping()
  DataCollection.Active = false
end

function DataCollection:ValidateModel(model)
  local descendants = model:GetDescendants()
  if #descendants > 1000 then return false end
  
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