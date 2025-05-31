local Scripts = {
	{
		PlacesIds = {2753915549, 4442272183, 7449423635},
		Path = "BloxFruits.luau"
	}
}

local fetcher, urls = {}, {}

urls.Owner = "https://raw.githubusercontent.com/notredz/";
urls.Repository = `{ urls.Owner }Scripts/refs/heads/main/`;
urls.Translator = `{ urls.Repository }Translator/`;
urls.Utils = `{ urls.Repository }Utils/`;

do
	local _ENV = (getgenv or getrenv or getfenv)()
	
	if _ENV.rz_error_message then
		_ENV.rz_error_message:Destroy()
	end
	
	local identifyexecutor = identifyexecutor or (function() return "Unknown" end)
	
	local function CreateMessageError(Text)
		_ENV.loadedFarm = nil
		_ENV.OnFarm = false
		
		local Message = Instance.new("Message", workspace)
		Message.Text = string.gsub(Text, urls.Owner, "")
		_ENV.rz_error_message = Message
		
		error(Text, 2)
	end
	
	local function formatUrl(Url)
		for string, path in urls do
			if Url:find("{" .. string .. "}") then
				return Url:gsub("{" .. string .. "}", path)
			end
		end
		
		return Url
	end
	
	function fetcher.get(Url)
		local success, response = pcall(function()
			return game:HttpGet(formatUrl(Url))
		end)
		
		if success then
			return response
		else
			CreateMessageError(`[1] [{ identifyexecutor() }] failed to get http/url/raw: { Url }\n>>{ response }<<`)
		end
	end
	
	function fetcher.load(Url, concat)
		local raw = fetcher.get(Url) .. (if concat then concat else "")
		local execute, error = loadstring(raw)
		
		if type(execute) ~= "function" then
			CreateMessageError(`[2] [{ identifyexecutor() }] sintax error: { Url }\n>>{ error }<<`)
		else
			return (function(...)
				local body = { pcall(execute, ...) }
				
				if body[1] == false then
					CreateMessageError(`[3] [{ identifyexecutor() }] execute error: { Url }\n>>{ body[2] }<<`)
				else
					table.remove(body, 1)
					return unpack(body)
				end
			end)
		end
	end
end

for _, Data in Scripts do
	if table.find(Data.PlacesIds, game.PlaceId) then
		return fetcher.load("{Repository}/Games/" .. Data.Path)(fetcher, ...)
	end
  end
