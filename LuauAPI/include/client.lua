--!native
--!optimize 2
local XENO_UNIQUE = "%XENO_UNIQUE_ID%"

local HttpService, UserInputService, InsertService = game:FindService("HttpService"), game:FindService("UserInputService"), game:FindService("InsertService")
local RunService, CoreGui, StarterGui = game:GetService("RunService"), game:FindService("CoreGui"), game:GetService("StarterGui")
local VirtualInputManager, RobloxReplicatedStorage = Instance.new("VirtualInputManager"), game:GetService("RobloxReplicatedStorage")

if RobloxReplicatedStorage:FindFirstChild("LuauDev") then return end

local XenoContainer = Instance.new("Folder", RobloxReplicatedStorage)
XenoContainer.Name = "LuauDev"
local objectPointerContainer, scriptsContainer = Instance.new("Folder", XenoContainer), Instance.new("Folder", XenoContainer)
objectPointerContainer.Name = "Instance Pointers"
scriptsContainer.Name = "Scripts"

local LuauAPI = {
	about = {
		_name = 'LuauDev',
		_version = 'v1.0',
		_publisher = "LuauDev | Modified By LuauDev Team."
	}
}
table.freeze(LuauAPI.about)

local coreModules, blacklistedModuleParents = {}, {
	"Common",
	"Settings",
	"PlayerList",
	"InGameMenu",
	"PublishAssetPrompt",
	"TopBar",
	"InspectAndBuy",
	"VoiceChat",
	"Chrome",
	"PurchasePrompt",
	"VR",
	"EmotesMenu",
	"FTUX"
}

for _, descendant in CoreGui.RobloxGui.Modules:GetDescendants() do
	if descendant.ClassName == "ModuleScript" and
		(function()
			for i, parentName in next, blacklistedModuleParents do
				if descendant == CoreGui.RobloxGui.Modules[parentName] or descendant:IsDescendantOf(CoreGui.RobloxGui.Modules[parentName]) then
					return
				end
			end
			return true
		end)()
	then
		table.insert(coreModules, descendant)
	end
end

local libs = {
	{
		['name'] = "HashLib",
		['url'] = "https://rizve.us.to/Xeno/hash"
	},
	{
		['name'] = "lz4",
		['url'] = "https://rizve.us.to/Xeno/lz4"
	},
	{
		['name'] = "DrawingLib",
		['url'] = "https://rizve.us.to/Xeno/drawing"
	}
}

if script.Name == "VRNavigation" then
	StarterGui:SetCore("SendNotification", {
		Title = "[LuauDev]",
		Text = "Used ingame method. When you leave the game it might crash!"
	})
end

local base64 = {}
local extract = bit32.extract

function base64.makeencoder( s62, s63, spad )
	local encoder = {}
	for b64code, char in pairs{[0]='A','B','C','D','E','F','G','H','I','J',
		'K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y',
		'Z','a','b','c','d','e','f','g','h','i','j','k','l','m','n',
		'o','p','q','r','s','t','u','v','w','x','y','z','0','1','2',
		'3','4','5','6','7','8','9',s62 or '+',s63 or'/',spad or'='} do
		encoder[b64code] = char:byte()
	end
	return encoder
end

function base64.makedecoder( s62, s63, spad )
	local decoder = {}
	for b64code, charcode in pairs( base64.makeencoder( s62, s63, spad )) do
		decoder[charcode] = b64code
	end
	return decoder
end

local DEFAULT_ENCODER = base64.makeencoder()
local DEFAULT_DECODER = base64.makedecoder()

local char, concat = string.char, table.concat

function base64.encode( str, encoder, usecaching )
	encoder = encoder or DEFAULT_ENCODER
	local t, k, n = {}, 1, #str
	local lastn = n % 3
	local cache = {}
	for i = 1, n-lastn, 3 do
		local a, b, c = str:byte( i, i+2 )
		local v = a*0x10000 + b*0x100 + c
		local s
		if usecaching then
			s = cache[v]
			if not s then
				s = char(encoder[extract(v,18,6)], encoder[extract(v,12,6)], encoder[extract(v,6,6)], encoder[extract(v,0,6)])
				cache[v] = s
			end
		else
			s = char(encoder[extract(v,18,6)], encoder[extract(v,12,6)], encoder[extract(v,6,6)], encoder[extract(v,0,6)])
		end
		t[k] = s
		k = k + 1
	end
	if lastn == 2 then
		local a, b = str:byte( n-1, n )
		local v = a*0x10000 + b*0x100
		t[k] = char(encoder[extract(v,18,6)], encoder[extract(v,12,6)], encoder[extract(v,6,6)], encoder[64])
	elseif lastn == 1 then
		local v = str:byte( n )*0x10000
		t[k] = char(encoder[extract(v,18,6)], encoder[extract(v,12,6)], encoder[64], encoder[64])
	end
	return concat( t )
end

function base64.decode( b64, decoder, usecaching )
	decoder = decoder or DEFAULT_DECODER
	local pattern = '[^%w%+%/%=]'
	if decoder then
		local s62, s63
		for charcode, b64code in pairs( decoder ) do
			if b64code == 62 then s62 = charcode
			elseif b64code == 63 then s63 = charcode
			end
		end
		pattern = ('[^%%w%%%s%%%s%%=]'):format( char(s62), char(s63) )
	end
	b64 = b64:gsub( pattern, '' )
	local cache = usecaching and {}
	local t, k = {}, 1
	local n = #b64
	local padding = b64:sub(-2) == '==' and 2 or b64:sub(-1) == '=' and 1 or 0
	for i = 1, padding > 0 and n-4 or n, 4 do
		local a, b, c, d = b64:byte( i, i+3 )
		local s
		if usecaching then
			local v0 = a*0x1000000 + b*0x10000 + c*0x100 + d
			s = cache[v0]
			if not s then
				local v = decoder[a]*0x40000 + decoder[b]*0x1000 + decoder[c]*0x40 + decoder[d]
				s = char( extract(v,16,8), extract(v,8,8), extract(v,0,8))
				cache[v0] = s
			end
		else
			local v = decoder[a]*0x40000 + decoder[b]*0x1000 + decoder[c]*0x40 + decoder[d]
			s = char( extract(v,16,8), extract(v,8,8), extract(v,0,8))
		end
		t[k] = s
		k = k + 1
	end
	if padding == 1 then
		local a, b, c = b64:byte( n-3, n-1 )
		local v = decoder[a]*0x40000 + decoder[b]*0x1000 + decoder[c]*0x40
		t[k] = char( extract(v,16,8), extract(v,8,8))
	elseif padding == 2 then
		local a, b = b64:byte( n-3, n-2 )
		local v = decoder[a]*0x40000 + decoder[b]*0x1000
		t[k] = char( extract(v,16,8))
	end
	return concat( t )
end

local Bridge, ProcessID = {serverUrl = "http://localhost:19283"}, nil
local _require, _game, _workspace = require, game, workspace
local originalFunctions = {}

local function sendRequest(options, timeout)
	timeout = tonumber(timeout) or math.huge
	local result, clock = nil, tick()

	HttpService:RequestInternal(options):Start(function(success, body)
		result = body
		result['Success'] = success
	end)

	while not result do task.wait()
		if (tick() - clock > timeout) then
			break
		end
	end

	return result
end

function Bridge:InternalRequest(body, timeout)
	local url = self.serverUrl .. '/send'
	if body.Url then
		url = body.Url
		body["Url"] = nil
		local options = {
			Url = url,
			Body = body['ct'],
			Method = 'POST',
			Headers = {
				['Content-Type'] = 'text/plain'
			}
		}
		local result = sendRequest(options, timeout)
		local statusCode = tonumber(result.StatusCode)
		if statusCode and statusCode >= 200 and statusCode < 300 then
			return result.Body or true
		end

		local success, result = pcall(function()
			local decoded = HttpService:JSONDecode(result.Body)
			if decoded and type(decoded) == "table" then
				return decoded.error
			end
		end)

		if success and result then
			error(result, 2)
			return
		end

		error("An unknown error occured by the server. Is the server still active?", 2)
		return
	end

	local success = pcall(function()
		body = HttpService:JSONEncode(body)
	end) if not success then return end

	local options = {
		Url = url,
		Body = body,
		Method = 'POST',
		Headers = {
			['Content-Type'] = 'application/json'
		}
	}

	local result = sendRequest(options, timeout)

	if type(result) ~= 'table' then return end

	local statusCode = tonumber(result.StatusCode)
	if statusCode and statusCode >= 200 and statusCode < 300 then
		return result.Body or true
	end

	local success, result = pcall(function()
		local decoded = HttpService:JSONDecode(result.Body)
		if decoded and type(decoded) == "table" then
			return decoded.error
		end
	end)

	if success and result then
		error("LuauDev Server Error: " .. tostring(result), 2)
	end

	error("An unknown error occured by the server.", 2)
end

function Bridge:readfile(path)
	local result = self:InternalRequest({
		['c'] = "rf",
		['p'] = path,
	})
	if result then
		return result
	end
end
function Bridge:writefile(path, content)
	local result = self:InternalRequest({
		['Url'] = self.serverUrl .. "/writefile?p=" .. path,
		['ct'] = content
	})
	return result ~= nil
end
function Bridge:isfolder(path)
	local result = self:InternalRequest({
		['c'] = "if",
		['p'] = path,
	})
	if result then
		return result == "dir"
	end
	return false
end
function Bridge:isfile(path)
	local result = self:InternalRequest({
		['c'] = "if",
		['p'] = path,
	})
	if result then
		return result == "file"
	end
	return false
end
function Bridge:listfiles(path)
	local result = self:InternalRequest({
		['c'] = "lf",
		['p'] = path,
	})
	if result then
		local files = HttpService:JSONDecode(result) or {}
		for i, file in ipairs(files) do
			files[i] = file:gsub("\\", "/") -- normalize paths
		end
		return files or {}
	end
	return {}
end
function Bridge:makefolder(path)
	local result = self:InternalRequest({
		['c'] = "mf",
		['p'] = path,
	})
	return result ~= nil
end
function Bridge:delfolder(path)
	local result = self:InternalRequest({
		['c'] = "dfl",
		['p'] = path,
	})
	return result ~= nil
end
function Bridge:delfile(path)
	local result = self:InternalRequest({
		['c'] = "df",
		['p'] = path,
	})
	return result ~= nil
end

Bridge.virtualFilesManagement = {
	['saved'] = {},
	['unsaved'] = {}
}

function Bridge:SyncFiles()
	local allFiles = {}
	local function getAllFiles(dir)
		local files = self:listfiles(dir)
		if #files < 1 then return end
		for _, filePath in files do
			table.insert(allFiles, filePath)
			if self:isfolder(filePath) then
				getAllFiles(filePath)
			end
		end
	end
	local success = pcall(function()
		getAllFiles("./")
	end) if not success then
		StarterGui:SetCore("SendNotification", {
			Title = "[LuauDev]",
			Text = "Could not sync virtual files from client to external. Server was closed or it is being overloaded"
		})
		return
	end
	local latestSave = {}

	local success, r = pcall(function()
		for _, filePath in allFiles do
			table.insert(latestSave, {
				path = filePath,
				isFolder = self:isfolder(filePath)
			})
		end
	end) if not success then return end

	self.virtualFilesManagement.saved = latestSave

	local unsuccessfulSave = {}

	local success, r = pcall(function()
		for _, unsavedFile in self.virtualFilesManagement.unsaved do
			local func = unsavedFile.func
			local argX = unsavedFile.x
			local argY = unsavedFile.y
			local success, r = pcall(function()
				return func(self, argX, argY)
			end)
			if (not success) or (not r) then
				if not unsavedFile.last_attempt then
					table.insert(unsuccessfulSave, {
						func = func,
						x = argX,
						y = argY,
						last_attempt = true
					})
				end
			end
		end
	end) if not success then return end

	self.virtualFilesManagement.unsaved = unsuccessfulSave
end

function Bridge:CanCompile(source, returnBytecode)
	local requestArgs = {
		['Url'] = self.serverUrl .. "/compilable",
		['ct'] = source
	}
	if returnBytecode then
		requestArgs.Url = self.serverUrl .. "/compilable?btc=t"
	end
	local result = self:InternalRequest(requestArgs)
	if result then
		if result == "success" then
			return true
		end
		return false, result
	end
	return false, "Unknown Error"
end

function Bridge:loadstring(source, chunkName)
	local cachedModules = {}
	local coreModule = _game.Clone(coreModules[math.random(1, #coreModules)])
	coreModule:ClearAllChildren()
	coreModule.Name = HttpService:GenerateGUID(false) .. ":" .. chunkName
	coreModule.Parent = XenoContainer
	table.insert(cachedModules, coreModule)

	local result = self:InternalRequest({
		['Url'] = self.serverUrl .. "/loadstring?n=" .. coreModule.Name .. "&cn=" .. chunkName .. "&pid=" .. tostring(ProcessID),
		['ct'] = source
	})

	if result then
		local clock = tick()
		while task.wait() do
			local required = nil
			pcall(function()
				required = _require(coreModule)
			end)

			if type(required) == "table" and required[chunkName] and type(required[chunkName]) == "function" then
				if (#cachedModules > 1) then
					for _, module in pairs(cachedModules) do
						if module == coreModule then continue end
						module:Destroy()
					end
				end
				return required[chunkName] -- fake luaVM load done externally
			end

			if (tick() - clock > 5) then
				warn("[LuauDev]: loadstring failed and timed out")
				for _, module in pairs(cachedModules) do
					module:Destroy()
				end
				return nil, "loadstring failed and timed out"
			end

			task.wait(.06)

			coreModule = _game.Clone(coreModules[math.random(1, #coreModules)])
			coreModule:ClearAllChildren()
			coreModule.Name = HttpService:GenerateGUID(false) .. ":" .. chunkName
			coreModule.Parent = XenoContainer

			self:InternalRequest({
				['Url'] = self.serverUrl .. "/loadstring?n=" .. coreModule.Name .. "&cn=" .. chunkName .. "&pid=" .. tostring(ProcessID),
				['ct'] = source
			})

			table.insert(cachedModules, coreModule)
		end
	end
end

local ignoreUrls = {}

function Bridge:request(options, x)
	if table.find(ignoreUrls, options.Url) then x = true elseif x then table.insert(ignoreUrls, options.Url) end
	if not x and options.Url:sub(-1) ~= "/" then options.Url = options.Url .. "/" end
	local result = self:InternalRequest({
		['c'] = "rq",
		['l'] = options.Url,
		['m'] = options.Method,
		['h'] = options.Headers,
		['b'] = options.Body or "{}"
	})
	if result then
		if result == "x" then
			return {
				ErrorMessage = "HttpError: DnsResolve",
				Success = false,
				HttpError = Enum.HttpError.DnsResolve
			}
		end
		result = HttpService:JSONDecode(result)
		if result['r'] ~= "OK" then
			result['r'] = "Unknown"
		end
		if not x and (result['c'] > 299 or result['c'] < 200) then options.Url = options.Url:sub(1, -2) return Bridge:request(options, true) end
		if result['b64'] then
			result['b'] = base64.decode(result['b'])
		end
		return {
			Success = tonumber(result['c']) and tonumber(result['c']) > 200 and tonumber(result['c']) < 300,
			StatusMessage = result['r'], -- OK
			StatusCode = tonumber(result['c']), -- 200
			Body = result['b'],
			HttpError = Enum.HttpError[result['r']],
			Headers = result['h'],
			Version = result['v']
		}
	end
	return {
		Success = false,
		StatusMessage = "Can't connect to LuauAPI web server: " .. self.serverUrl,
		StatusCode = 599;
		HttpError = Enum.HttpError.ConnectFail
	}
end

function Bridge:setclipboard(content)
	local result = self:InternalRequest({
		['Url'] = self.serverUrl .. "/setclipboard",
		['ct'] = content
	})
	return result ~= nil
end

function Bridge:rconsole(_type, content)
	if _type == "cls" or _type == "crt" or _type == "dst" then
		local result = self:InternalRequest({
			['c'] = "rc",
			['t'] = _type
		})
		return result ~= nil
	end
	local result = self:InternalRequest({
		['c'] = "rc",
		['t'] = _type,
		['ct'] = base64.encode(content)
	})
	return result ~= nil
end

function Bridge:getscriptbytecode(instance)
	local objectValue = Instance.new("ObjectValue", objectPointerContainer)
	objectValue.Name = HttpService:GenerateGUID(false)
	objectValue.Value = instance

	local result = self:InternalRequest({
		['c'] = "btc",
		['cn'] = objectValue.Name,
		['pid'] = tostring(ProcessID)
	})

	objectValue:Destroy()

	if result then
		return result
	end
	return ''
end

function Bridge:queue_on_teleport(_type, source)
	if _type == "s" then
		local result = self:InternalRequest({
			['c'] = "qtp",
			['t'] = "s",
			['ct'] = source,
			['pid'] = tostring(ProcessID)
		})
		if result then
			return true
		end
	end
	local result = self:InternalRequest({
		['c'] = "qtp",
		['t'] = "g",
		['pid'] = tostring(ProcessID)
	})
	if result then
		return result
	end
	return ''
end
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

task.spawn(function()
	while true do
		Bridge:SyncFiles()
		task.wait(.65)
	end
end)

local hwid = HttpService:GenerateGUID(false)

task.spawn(function()
	local result = sendRequest({
		Url = Bridge.serverUrl .. "/send",
		Body = HttpService:JSONEncode({
			['c'] = "hw"
		}),
		Method = "POST"
	})
	if result.Body then
		hwid = result.Body:gsub("{", ""):gsub("}", "")
	end
end)

local cLoaded_requests = 0
local function is_client_loaded()
	local result = sendRequest({
		Url = Bridge.serverUrl .. "/send",
		Body = HttpService:JSONEncode({
			['c'] = "clt",
			['gd'] = XENO_UNIQUE,
			['n'] = cLoaded_requests > 4 and (game.Players.LocalPlayer and game.Players.LocalPlayer.Name or game.Players.PlayerAdded:Wait().Name) or "N/A"
		}),
		Method = "POST"
	})
	cLoaded_requests += 1
	if result.Body then
		return result.Body
	end
	return false
end

ProcessID = is_client_loaded()
while not tonumber(ProcessID) do
	ProcessID = is_client_loaded()
end

-- / IMPORTANT FUNCS \ --
local httpSpy = false
LuauAPI.LuauAPI = {
	PID = ProcessID,
	GUID = XENO_UNIQUE,
	HttpSpy = function(state)
		if state == nil then state = true end
		assert(type(state) == "boolean", "invalid argument #1 to 'HttpSpy' (boolean expected, got " .. type(state) .. ") ", 2)
		LuauAPI.rconsoleinfo("Http Spy is set to '" .. tostring(state) .. "'")
		httpSpy = state
	end,
}

function LuauAPI.LuauAPI.get_real_address(instance)
	assert(typeof(instance) == "Instance", "invalid argument #1 to 'get_real_address' (Instance expected, got " .. typeof(instance) .. ") ", 2)
	local objectValue = Instance.new("ObjectValue", objectPointerContainer)
	objectValue.Name = HttpService:GenerateGUID(false)
	objectValue.Value = instance
	local result = Bridge:InternalRequest({
		['c'] = "adr",
		['cn'] = objectValue.Name,
		['pid'] = tostring(ProcessID)
	})
	objectValue:Destroy()
	if tonumber(result) then
		return tonumber(result)
	end
	return 0
end

function LuauAPI.LuauAPI.spoof_instance(instance, newinstance)
	assert(typeof(instance) == "Instance", "invalid argument #1 to 'spoof_instance' (Instance expected, got " .. typeof(instance) .. ") ", 2)
	assert(typeof(newinstance) == "Instance" or type(newinstance) == "number", "invalid argument #2 to 'spoof_instance' (Instance or number expected, got " .. typeof(newinstance) .. ") ", 2)
	local newAddress
	do
		if type(newinstance) == "number" then 
			newAddress = newinstance
		else
			newAddress = LuauAPI.LuauAPI.get_real_address(newinstance)
		end
	end
	local objectValue = Instance.new("ObjectValue", objectPointerContainer)
	objectValue.Name = HttpService:GenerateGUID(false)
	objectValue.Value = instance
	local result = Bridge:InternalRequest({
		['c'] = "spf",
		['cn'] = objectValue.Name,
		['pid'] = tostring(ProcessID),
		['adr'] = tostring(newAddress)
	})
	objectValue:Destroy()
	return result ~= nil
end

-- globals, shared across all clients (made for testing only so its badly coded)
function LuauAPI.LuauAPI.GetGlobal(global_name)
	assert(type(global_name) == "string", "invalid argument #1 to 'GetGlobal' (string expected, got " .. type(global_name) .. ") ", 2)
	local result = Bridge:InternalRequest({
		['c'] = "gb",
		['t'] = "g",
		['n'] = global_name
	})
	if not result then
		return
	end

	result = HttpService:JSONDecode(result)
	if result.t == "string" then
		return tostring(result.d)
	end
	if result.t == "number" then
		return tonumber(result.d)
	end
	if result.t == "table" then
		return HttpService:JSONDecode(result.d)
	end
end
function LuauAPI.LuauAPI.SetGlobal(global_name, value)
	assert(type(global_name) == "string", "invalid argument #1 to 'SetGlobal' (string expected, got " .. type(global_name) .. ") ", 2)
	local valueT = type(value)
	assert(valueT == "string" or valueT == "number" or valueT == "table", "invalid argument #2 to 'SetGlobal' (string, number, or table expected, got " .. valueT .. ") ", 2)
	if valueT == "table" then
		value = HttpService:JSONEncode(value)
	end
	return Bridge:InternalRequest({
		['c'] = "gb",
		['t'] = "s",
		['n'] = global_name,
		['v'] = tostring(value),
		['vt'] = valueT
	}) ~= nil
end

function LuauAPI.LuauAPI.Compile(source)
	assert(type(source) == "string", "invalid argument #1 to 'Compile' (string expected, got " .. type(source) .. ") ", 2)
	if source == "" then return "" end
	local _, result = Bridge:CanCompile(source, true)
	return result
end

local unlockedModules = {}
LuauAPI.require = function(moduleScript)
	assert(typeof(moduleScript) == "Instance", "Attempted to call require with invalid argument(s). ", 2)
	assert(moduleScript.ClassName == "ModuleScript", "Attempted to call require with invalid argument(s). ", 2)

	if table.find(unlockedModules, moduleScript) then return _require(moduleScript) end

	local objectValue = Instance.new("ObjectValue", objectPointerContainer)
	objectValue.Name = HttpService:GenerateGUID(false)
	objectValue.Value = moduleScript

	Bridge:InternalRequest({
		['c'] = "um",
		['cn'] = objectValue.Name,
		['pid'] = tostring(ProcessID)
	})
	objectValue:Destroy()

	for _, descendant in pairs(objectValue:GetDescendants()) do
		if descendant:IsA("ModuleScript") and not table.find(unlockedModules, child) then
			pcall(function()
				local objectValue = Instance.new("ObjectValue", objectPointerContainer)
				objectValue.Name = HttpService:GenerateGUID(false)
				objectValue.Value = descendant

				Bridge:InternalRequest({
					['c'] = "um",
					['cn'] = objectValue.Name,
					['pid'] = tostring(ProcessID)
				})
				objectValue:Destroy()
				table.insert(unlockedModules, descendant)
			end)
		end
	end

	if moduleScript.Parent:IsA("ModuleScript") and not table.find(unlockedModules, moduleScript.Parent) then
		pcall(function()
			local objectValue = Instance.new("ObjectValue", objectPointerContainer)
			objectValue.Name = HttpService:GenerateGUID(false)
			objectValue.Value = moduleScript.Parent

			Bridge:InternalRequest({
				['c'] = "um",
				['cn'] = objectValue.Name,
				['pid'] = tostring(ProcessID)
			})
			objectValue:Destroy()
			table.insert(unlockedModules, moduleScript.Parent)
		end)
	end

	table.insert(unlockedModules, moduleScript)
	return _require(moduleScript)
end

LuauAPI.loadstring = function(source, chunkName)
	assert(type(source) == "string", "invalid argument #1 to 'loadstring' (string expected, got " .. type(source) .. ") ", 2)
	chunkName = chunkName or "loadstring"
	assert(type(chunkName) == "string", "invalid argument #2 to 'loadstring' (string expected, got " .. type(chunkName) .. ") ", 2)
	chunkName = chunkName:gsub("[^%a_]", "")
	if (source == "" or source == " ") then
		return function(...) end
	end
	local success, err = Bridge:CanCompile(source)
	if not success then
		return nil, chunkName .. tostring(err)
	end
	local func = Bridge:loadstring(source, chunkName)
	setfenv(func, getfenv(debug.info(2, 'f')))
	return func
end

local supportedMethods = {"GET", "POST", "PUT", "DELETE", "PATCH"}

LuauAPI.request = function(options)
	assert(type(options) == "table", "invalid argument #1 to 'request' (table expected, got " .. type(options) .. ") ", 2)
	assert(type(options.Url) == "string", "invalid option 'Url' for argument #1 to 'request' (string expected, got " .. type(options.Url) .. ") ", 2)
	options.Method = options.Method or "GET"
	options.Method = options.Method:upper()
	assert(table.find(supportedMethods, options.Method), "invalid option 'Method' for argument #1 to 'request' (a valid http method expected, got '" .. options.Method .. "') ", 2)
	assert(not (options.Method == "GET" and options.Body), "invalid option 'Body' for argument #1 to 'request' (current method is GET but option 'Body' was used)", 2)
	if options.Body then
		assert(type(options.Body) == "string", "invalid option 'Body' for argument #1 to 'request' (string expected, got " .. type(options.Body) .. ") ", 2)
		options.Body = base64.encode(options.Body)
	end
	if options.Headers then assert(type(options.Headers) == "table", "invalid option 'Headers' for argument #1 to 'request' (table expected, got " .. type(options.Url) .. ") ", 2) end
	options.Body = options.Body or "e30=" -- "{}" in base64
	options.Headers = options.Headers or {}
	if httpSpy then
		LuauAPI.rconsoleprint("-----------------[LuauAPI Http Spy]---------------\nUrl: " .. options.Url .. 
			"\nMethod: " .. options.Method .. 
			"\nBody: " .. options.Body .. 
			"\nHeaders: " .. tostring(HttpService:JSONEncode(options.Headers))
		)
	end
	if (options.Headers["User-Agent"]) then assert(type(options.Headers["User-Agent"]) == "string", "invalid option 'User-Agent' for argument #1 to 'request.Header' (string expected, got " .. type(options.Url) .. ") ", 2) end
	options.Headers["User-Agent"] = options.Headers["User-Agent"] or "LuauAPI/0x481XC6" .. tostring(LuauAPI.about._version)
	options.Headers["Exploit-Guid"] = tostring(hwid)
	options.Headers["LuauAPI-Fingerprint"] = tostring(hwid)
	options.Headers["Roblox-Place-Id"] = tostring(game.PlaceId)
	options.Headers["Roblox-Game-Id"] = tostring(game.JobId)
	options.Headers["Roblox-Session-Id"] = HttpService:JSONEncode({
		["GameId"] = tostring(game.JobId),
		["PlaceId"] = tostring(game.PlaceId)
	})
	local response = Bridge:request(options)
	if httpSpy then
		LuauAPI.rconsoleprint("-----------------[Response]---------------\nStatusCode: " .. tostring(response.StatusCode) ..
			"\nStatusMessage: " .. tostring(response.StatusMessage) ..
			"\nSuccess: " .. tostring(response.Success) ..
			"\nBody: " .. tostring(response.Body) ..
			"\nHeaders: " .. tostring(HttpService:JSONEncode(response.Headers)) ..
			"--------------------------------\n\n"
		)
	end
	return response
end
LuauAPI.http = {request = LuauAPI.request}
LuauAPI.http_request = LuauAPI.request

local user_agent = "LuauAPI"
LuauAPI.HttpGet = function(url, returnRaw)
	assert(type(url) == "string", "invalid argument #1 to 'HttpGet' (string expected, got " .. type(url) .. ") ", 2)
	local returnRaw = returnRaw or true

	local result = LuauAPI.request({
		Url = url,
		Method = "GET",
		Headers = {
			["User-Agent"] = user_agent
		}
	})

	if returnRaw then
		return result.Body
	end

	return HttpService:JSONDecode(result.Body)
end
LuauAPI.HttpPost = function(url, body, contentType)
	assert(type(url) == "string", "invalid argument #1 to 'HttpPost' (string expected, got " .. type(url) .. ") ", 2)
	contentType = contentType or "application/json"
	return LuauAPI.request({
		Url = url,
		Method = "POST",
		body = body,
		Headers = {
			["Content-Type"] = contentType
		}
	})
end
LuauAPI.GetObjects = function(asset)
	return {
		InsertService:LoadLocalAsset(asset)
	}
end

local proxiedServices = {
	LinkingService = {{
		"OpenUrl"
	}, game:GetService("LinkingService")},
	ScriptContext = {{
		"SaveScriptProfilingData", 
		"AddCoreScriptLocal",
		"ScriptProfilerService"
	}, game:GetService("ScriptContext")},
	--[[
	MessageBusService = {{
		"Call",
		"GetLast",
		"GetMessageId",
		"GetProtocolMethodRequestMessageId",
		"GetProtocolMethodResponseMessageId",
		"MakeRequest",
		"Publish",
		"PublishProtocolMethodRequest",
		"PublishProtocolMethodResponse",
		"Subscribe",
		"SubscribeToProtocolMethodRequest",
		"SubscribeToProtocolMethodResponse"
	}, game:GetService("MessageBusService")},
	GuiService = {{
		"OpenBrowserWindow",
		"OpenNativeOverlay"
	}, game:GetService("GuiService")},
	MarketplaceService = {{
		"GetRobuxBalance",
		"PerformPurchase",
		"PerformPurchaseV2",
	}, game:GetService("MarketplaceService")},
	HttpRbxApiService = {{
		"GetAsyncFullUrl",
		"PostAsyncFullUrl",
		"GetAsync",
		"PostAsync",
		"RequestAsync"
	}, game:GetService("HttpRbxApiService")},
	CoreGui = {{
		"TakeScreenshot",
		"ToggleRecording"
	}, game:GetService("CoreGui")},
	Players = {{
		"ReportAbuse",
		"ReportAbuseV3"
	}, game:GetService("Players")},
	HttpService = {{
		"RequestInternal"
	}, game:GetService("HttpService")},
	BrowserService = {{
		"ExecuteJavaScript",
		"OpenBrowserWindow",
		"ReturnToJavaScript",
		"OpenUrl",
		"SendCommand",
		"OpenNativeOverlay"
	}, game:GetService("BrowserService")},
	CaptureService = {{
		"DeleteCapture"
	}, game:GetService("CaptureService")},
	OmniRecommendationsService = {{
		"MakeRequest"
	}, game:GetService("OmniRecommendationsService")},
	OpenCloudService = {{
		"HttpRequestAsync"
	}, game:GetService("OpenCloudService")}
	]]
}

local function find(t, x)
	x = string.gsub(tostring(x), '\0', '') -- sometimes people will use null chars to bypass
	for i, v in t do
		if v:lower() == x:lower() then
			return true
		end
	end
end

local function setupBlockedServiceFuncs(serviceTable)
	serviceTable.proxy = newproxy(true)
	local proxyMt = getmetatable(serviceTable.proxy)

	proxyMt.__index = function(self, index)
		index = string.gsub(tostring(index), '\0', '')
		if find(serviceTable[1], index) then
			return function(self, ...)
				error("Attempt to call a blocked function: " .. index, 2)
			end
		end

		if index == "Parent" then
			return LuauAPI.game
		end

		if type(serviceTable[2][index]) == "function" then
			return function(self, ...)
				return serviceTable[2][index](serviceTable[2], ...)
			end
		else
			return serviceTable[2][index]
		end
	end

	proxyMt.__newindex = function(self, index, value)
		serviceTable[2][index] = value
	end

	proxyMt.__tostring = function(self)
		return serviceTable[2].Name
	end

	proxyMt.__metatable = getmetatable(serviceTable[2])
end

for i, serviceTable in proxiedServices do
	setupBlockedServiceFuncs(serviceTable)
end


LuauAPI.game = newproxy(true)
local gameProxy = getmetatable(LuauAPI.game)

gameProxy.__index = function(self, index)
	if index == "HttpGet" or index == "HttpGetAsync" then
		return function(self, ...)
			return LuauAPI.HttpGet(...)
		end
	elseif index == "HttpPost" or index == "HttpPostAsync" then
		return function(self, ...)
			return LuauAPI.HttpPost(...)
		end
	elseif index == "GetObjects" then
		return function(self, ...)
			return LuauAPI.GetObjects(...)
		end
	end

	if type(_game[index]) == "function" then
		return function(self, ...)
			if index == "GetService" or index == "FindService" then
				local args = {...}
				if proxiedServices[string.gsub(tostring(args[1]), '\0', '')] then
					return proxiedServices[string.gsub(args[1], '\0', '')].proxy
				end
			end
			if find({
				"Load",
				"OpenScreenshotsFolder",
				"OpenVideosFolder"
				}, index) then
				error("Attempt to call a blocked function: " .. tostring(index), 2)
			end
			return _game[index](_game, ...)
		end
	else
		if proxiedServices[index] then
			return proxiedServices[index].proxy
		end
		return _game[index]
	end
end

gameProxy.__newindex = function(self, index, value)
	_game[index] = value
end

gameProxy.__tostring = function(self)
	return _game.Name
end

gameProxy.__metatable = getmetatable(_game)

LuauAPI.Game = LuauAPI.game

--[[
LuauAPI.workspace = newproxy(true)
local workspaceProxy = getmetatable(LuauAPI.workspace)
workspaceProxy.__index = function(self, index)
	index = string.gsub(tostring(index), '\0', '')
	if index == "Parent" then
		return LuauAPI.game
	end

	if type(_workspace[index]) == "function" then
		return function(self, ...)
			return _workspace[index](_workspace, ...)
		end
	else
		return _workspace[index]
	end
end

workspaceProxy.__newindex = function(self, index, value)
	_workspace[index] = value
end

workspaceProxy.__tostring = function(self)
	return _workspace.Name
end

workspaceProxy.__metatable = getmetatable(_workspace)

LuauAPI.Workspace = LuauAPI.workspace
]]

LuauAPI.getgenv = function()
	return LuauAPI
end

-- / Filesystem \ --
local function normalize_path(path)
	if (path:sub(2, 2) ~= "/") then path = "./" .. path end
	if (path:sub(1, 1) == "/") then path = "." .. path end
	return path
end
local function getUnsaved(func, path)
	local unsaved = Bridge.virtualFilesManagement.unsaved
	for i, fileInfo in next, unsaved do
		if ("./" .. tostring(fileInfo.x) == path or fileInfo.x == path or normalize_path(tostring(fileInfo.path)) == path) and fileInfo.func == func then
			return unsaved[i], i
		end
	end
end
local function getSaved(path)
	local saves = Bridge.virtualFilesManagement.saved
	for i, fileInfo in next, saves do
		if fileInfo.path == path or "./" .. tostring(fileInfo.path) == path or normalize_path(tostring(fileInfo.path)) == path then
			return true, saves[i]
		end
	end
end

LuauAPI.readfile = function(path)
	assert(type(path) == "string", "invalid argument #1 to 'readfile' (string expected, got " .. type(path) .. ") ", 2)
	local unsavedFile = getUnsaved(Bridge.writefile, path)
	if unsavedFile then
		return unsavedFile.y
	end
	return Bridge:readfile(path)
end
LuauAPI.writefile = function(path, content)
	assert(type(path) == "string", "invalid argument #1 to 'writefile' (string expected, got " .. type(path) .. ") ", 2)
	assert(type(content) == "string", "invalid argument #2 to 'writefile' (string expected, got " .. type(content) .. ") ", 2)
	local unsavedFile, index = getUnsaved(Bridge.delfile, path)
	if unsavedFile then
		table.remove(Bridge.virtualFilesManagement.unsaved, index)
	end
	unsavedFile = getUnsaved(Bridge.writefile, path)
	if unsavedFile then
		unsavedFile.y = content
		return
	end
	table.insert(Bridge.virtualFilesManagement.unsaved, {
		func = Bridge.writefile,
		x = path,
		y = content
	})
end
LuauAPI.appendfile = function(path, content)
	assert(type(path) == "string", "invalid argument #1 to 'appendfile' (string expected, got " .. type(path) .. ") ", 2)
	assert(type(content) == "string", "invalid argument #2 to 'appendfile' (string expected, got " .. type(content) .. ") ", 2)
	local unsavedFile = getUnsaved(Bridge.writefile, path)
	if unsavedFile then
		unsavedFile.y = unsavedFile.y .. content
		return true
	end
	local readVal = ""
	pcall(function()
		readVal = Bridge:readfile(path)
	end)
	LuauAPI.writefile(path, readVal .. content)
end
LuauAPI.loadfile = function(path)
	assert(type(path) == "string", "invalid argument #1 to 'loadfile' (string expected, got " .. type(path) .. ") ", 2)
	return LuauAPI.loadstring(LuauAPI.readfile(path))
end
LuauAPI.dofile = LuauAPI.loadfile
LuauAPI.isfolder = function(path)
	assert(type(path) == "string", "invalid argument #1 to 'isfolder' (string expected, got " .. type(path) .. ") ", 2)
	if getUnsaved(Bridge.delfolder, path) then
		return false
	end
	if getUnsaved(Bridge.makefolder, path) then
		return true
	end
	local s, saved = getSaved(path)
	if s then
		return saved.isFolder
	end
	return Bridge:isfolder(path)
end
LuauAPI.isfile = function(path) -- return not LuauAPI.isfolder(path)
	assert(type(path) == "string", "invalid argument #1 to 'isfile' (string expected, got " .. type(path) .. ") ", 2)
	if getUnsaved(Bridge.delfile, path) then
		return false
	end
	if getUnsaved(Bridge.writefile, path) then
		return true
	end
	local s, saved = getSaved(path)
	if s then
		return not saved.isFolder
	end
	return Bridge:isfile(path)
end
LuauAPI.listfiles = function(path)
	assert(type(path) == "string", "invalid argument #1 to 'listfiles' (string expected, got " .. type(path) .. ") ", 2)

	path = normalize_path(path)
	if path:sub(-1) ~= '/' then path = path .. '/' end

	local pathFiles, allFiles = {}, {}

	for _, fileInfo in Bridge.virtualFilesManagement.saved do
		table.insert(allFiles, normalize_path(tostring(fileInfo.path)))
	end

	for _, unsavedFile in Bridge.virtualFilesManagement.unsaved do
		if not (table.find(allFiles, normalize_path(unsavedFile.x)) or table.find(allFiles, unsavedFile.x)) then
			if type(unsavedFile.x) ~= "string" then continue end
			table.insert(allFiles, normalize_path(unsavedFile.x))
		end
	end

	for _, filePath in next, allFiles do
		if filePath:sub(1, #path) == path then
			local pathFile = path .. filePath:sub(#path + 1):split('/')[1]
			if not (table.find(pathFiles, pathFile) or table.find(pathFiles, normalize_path(pathFile) or table.find(pathFiles, './' .. pathFile))) then
				table.insert(pathFiles, pathFile)
			end
		end
	end

	return pathFiles
end
LuauAPI.makefolder = function(path)
	assert(type(path) == "string", "invalid argument #1 to 'makefolder' (string expected, got " .. type(path) .. ") ", 2)
	local unsavedFile, index = getUnsaved(Bridge.delfolder, path)
	if unsavedFile then
		table.remove(Bridge.virtualFilesManagement.unsaved, index)
	end
	if getUnsaved(Bridge.makefolder, path) then
		return
	end
	table.insert(Bridge.virtualFilesManagement.unsaved, {
		func = Bridge.makefolder,
		x = path
	})
end
LuauAPI.delfolder = function(path)
	assert(type(path) == "string", "invalid argument #1 to 'delfolder' (string expected, got " .. type(path) .. ") ", 2)
	local unsavedFile, index = getUnsaved(Bridge.makefolder, path)
	if unsavedFile then
		table.remove(Bridge.virtualFilesManagement.unsaved, index)
		return
	end
	if getUnsaved(Bridge.delfolder, path) then
		return
	end
	table.insert(Bridge.virtualFilesManagement.unsaved, {
		func = Bridge.delfolder,
		x = path
	})
end
LuauAPI.delfile = function(path)
	assert(type(path) == "string", "invalid argument #1 to 'delfile' (string expected, got " .. type(path) .. ") ", 2)
	local unsavedFile, index = getUnsaved(Bridge.writefile, path)
	if unsavedFile then
		table.remove(Bridge.virtualFilesManagement.unsaved, index)
	end
	if getUnsaved(Bridge.delfile, path) then
		return
	end
	table.insert(Bridge.virtualFilesManagement.unsaved, {
		func = Bridge.delfile,
		x = path
	})
end

LuauAPI.getcustomasset = function(path)
	assert(type(path) == "string", "invalid argument #1 to 'getcustomasset' (string expected, got " .. type(path) .. ") ", 2)
	local unsaved, i, _break = getUnsaved(Bridge.writefile, path), nil
	while unsaved do 
		unsaved, i = getUnsaved(Bridge.writefile, path)
		task.wait(.1)
		pcall(function()
			if Bridge:readfile(path) == Bridge.virtualFilesManagement.unsaved[i].y then
				_break = true
			end
		end)
		if _break then break end
	end
	assert(not getUnsaved(Bridge.delfile, path), "The file was recently deleted")
	return Bridge:InternalRequest({
		['c'] = "cas",
		['p'] = path,
		['pid'] = ProcessID
	})
end

-- / Libs \ --
local function InternalGet(url)
	local result, clock = nil, tick()

	local function callback(success, body)
		result = body
		result['Success'] = success
	end

	HttpService:RequestInternal({
		Url = url,
		Method = 'GET'
	}):Start(callback)

	while not result do task.wait()
		if tick() - clock > 15 then
			break
		end
	end

	return result.Body
end

pcall(function()
	local body = InternalGet("https://httpbin.org/user-agent")
	user_agent = HttpService:JSONDecode(body)["user-agent"]
end)

do
	local libsLoaded = 0

	for i, libInfo in pairs(libs) do
		task.spawn(function()
			libs[i].content = Bridge:loadstring(InternalGet(libInfo.url), libInfo.name)()
			libsLoaded += 1
		end)
	end

	while libsLoaded < #libs do task.wait() end
end

local function getlib(libName)
	for i, lib in pairs(libs) do
		if lib.name == libName then
			return lib.content
		end
	end
	return nil
end

local HashLib, lz4, DrawingLib = getlib("HashLib"), getlib("lz4"), getlib("DrawingLib")

LuauAPI.base64 = base64
LuauAPI.base64_encode = base64.encode
LuauAPI.base64encode = base64.encode
LuauAPI.base64_decode = base64.decode
LuauAPI.base64decode = base64.decode

LuauAPI.crypt = {
	base64 = base64,
	base64encode = base64.encode,
	base64_encode = base64.encode,
	base64decode = base64.decode,
	base64_decode = base64.decode,

	hex = {
		encode = function(txt)
			txt = tostring(txt)
			local hex = ''
			for i = 1, #txt do
				hex = hex .. string.format("%02x", string.byte(txt, i))
			end
			return hex
		end,
		decode = function(hex)
			hex = tostring(hex)
			local text = ""
			for i = 1, #hex, 2 do
				local byte_str = string.sub(hex, i, i+1)
				local byte = tonumber(byte_str, 16)
				text = text .. string.char(byte)
			end
			return text
		end
	},

	url = {
		encode = function(x)
			return HttpService:UrlEncode(x)
		end,
		decode = function(x)
			x = tostring(x)
			x = string.gsub(x, "+", " ")
			x = string.gsub(x, "%%(%x%x)", function(hex)
				return string.char(tonumber(hex, 16))
			end)
			x = string.gsub(x, "\r\n", "\n")
			return x
		end
	},

	generatekey = function(len)
		local key = ''
		local x = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
		for i = 1, len or 32 do local n = math.random(1, #x) key = key .. x:sub(n, n) end
		return base64.encode(key)
	end,

	encrypt = function(a, b)
		local result = {}
		a = tostring(a) b = tostring(b)
		for i = 1, #a do
			local byte = string.byte(a, i)
			local keyByte = string.byte(b, (i - 1) % #b + 1)
			table.insert(result, string.char(bit32.bxor(byte, keyByte)))
		end
		return table.concat(result), b
	end
}
LuauAPI.crypt.generatebytes = function(len)
	return LuauAPI.crypt.generatekey(len)
end
LuauAPI.crypt.random = function(len)
	return LuauAPI.crypt.generatekey(len)
end
LuauAPI.crypt.decrypt = LuauAPI.crypt.encrypt

function LuauAPI.crypt.hash(txt, hashName)
	for name, func in pairs(HashLib) do
		if name == hashName or name:gsub("_", "-") == hashName then
			return func(txt)
		end
	end
end
LuauAPI.hash = LuauAPI.crypt.hash

LuauAPI.crypt.lz4 = lz4
LuauAPI.crypt.lz4compress = lz4.compress
LuauAPI.crypt.lz4decompress = lz4.decompress

LuauAPI.lz4 = lz4
LuauAPI.lz4compress = lz4.compress
LuauAPI.lz4decompress = lz4.decompress

local Drawing, drawingFunctions = DrawingLib.Drawing, DrawingLib.functions
LuauAPI.Drawing = Drawing

for name, func in drawingFunctions do
	LuauAPI[name] = func
end

-- / Miscellaneous \ --
LuauAPI.getproperties = function(instance)
	assert(typeof(instance) == "Instance", "invalid argument #1 to 'getproperties' (Instance expected, got " .. typeof(instance) .. ") ", 2)

	local objectValue = Instance.new("ObjectValue", objectPointerContainer)
	objectValue.Name = HttpService:GenerateGUID(false)
	objectValue.Value = instance

	local result = Bridge:InternalRequest({
		['c'] = "prp",
		['cn'] = objectValue.Name,
		['pid'] = tostring(ProcessID)
	})

	objectValue:Destroy()

	local properties, filtered = HttpService:JSONDecode(result), {}
	for _, propertyName in next, properties do
		local property, wasHidden = LuauAPI.gethiddenproperty(instance, propertyName)
		if not wasHidden then
			filtered[propertyName] = property
		end
	end

	return filtered
end

LuauAPI.gethiddenproperties = function(instance)
	assert(typeof(instance) == "Instance", "invalid argument #1 to 'getproperties' (Instance expected, got " .. typeof(instance) .. ") ", 2)

	local objectValue = Instance.new("ObjectValue", objectPointerContainer)
	objectValue.Name = HttpService:GenerateGUID(false)
	objectValue.Value = instance

	local result = Bridge:InternalRequest({
		['c'] = "prp",
		['cn'] = objectValue.Name,
		['pid'] = tostring(ProcessID)
	})

	objectValue:Destroy()

	local properties, filtered = HttpService:JSONDecode(result), {}
	for _, propertyName in next, properties do
		local property, wasHidden = LuauAPI.gethiddenproperty(instance, propertyName)
		if wasHidden then
			filtered[propertyName] = property
		end
	end

	return filtered
end

local _saveinstance = nil
LuauAPI.saveinstance = function(options)
	options = options or {}
	assert(type(options) == "table", "invalid argument #1 to 'saveinstance' (table expected, got " .. type(options) .. ") ", 2)
	print("saveinstance Powered by UniversalSynSaveInstance | AGPL-3.0 license")
	_saveinstance = _saveinstance or LuauAPI.loadstring(LuauAPI.HttpGet("https://raw.githubusercontent.com/luau/SynSaveInstance/main/saveinstance.luau", true), "saveinstance")()
	return _saveinstance(options)
end
LuauAPI.savegame = LuauAPI.saveinstance

LuauAPI.getexecutorname = function()
	return LuauAPI.about._name
end
LuauAPI.getexecutorversion = function()
	return LuauAPI.about._version
end

LuauAPI.identifyexecutor = function()
	return LuauAPI.getexecutorname(), LuauAPI.getexecutorversion()
end
LuauAPI.whatexecutor = LuauAPI.identifyexecutor

LuauAPI.get_hwid = function()
	return hwid
end
LuauAPI.gethwid = LuauAPI.get_hwid

LuauAPI.getscriptbytecode = function(script_instance)
	assert(typeof(script_instance) == "Instance", "invalid argument #1 to 'getscriptbytecode' (Instance expected, got " .. typeof(script_instance) .. ") ", 2)
	assert(script_instance.ClassName == "LocalScript" or script_instance.ClassName == "ModuleScript", 
		"invalid 'ClassName' for 'Instance' #1 to 'getscriptbytecode' (LocalScript or ModuleScript expected, got '" .. script_instance.ClassName .. "') ", 2)
	return Bridge:getscriptbytecode(script_instance)
end
LuauAPI.dumpstring = LuauAPI.getscriptbytecode

-- Thanks to plusgiant5 for letting me use konstant api

local last_call = 0
local function konst_call(konstantType: string, scriptPath: Script | ModuleScript | LocalScript): string
	local success: boolean, bytecode: string = pcall(LuauAPI.getscriptbytecode, scriptPath)

	if (not success) then
		return `-- Failed to get script bytecode, error:\n\n--[[\n{bytecode}\n--]]`
	end

	local time_elapsed = os.clock() - last_call
	if time_elapsed <= .5 then
		task.wait(.5 - time_elapsed)
	end
	local httpResult = LuauAPI.request({
		Url = "http://api.plusgiant5.com" .. konstantType,
		Body = bytecode,
		Method = "POST",
		Headers = {
			["Content-Type"] = "text/plain"
		},
	})
	last_call = os.clock()

	if (httpResult.StatusCode ~= 200) then
		return `-- Error occured while requesting the API, error:\n\n--[[\n{httpResult.Body}\n--]]`
	else
		return httpResult.Body
	end
end

LuauAPI.Decompile = function(script_instance)
	if typeof(script_instance) ~= "Instance" then
		return "-- invalid argument #1 to 'Decompile' (Instance expected, got " .. typeof(script_instance) .. ")"
	end
	if script_instance.ClassName ~= "LocalScript" and script_instance.ClassName ~= "ModuleScript" then
		return "-- Only LocalScript and ModuleScript is supported but got \"" .. script_instance.ClassName .. "\""
	end
	return tostring(konst_call("/konstant/decompile", script_instance)):gsub("\t", "    ")
end
LuauAPI.decompile = LuauAPI.Decompile

-- for some reason, UniversalSynSaveInstance is using the Disassemble function the same as Decompile.
LuauAPI.__Disassemble = function(script_instance)
	if typeof(script_instance) ~= "Instance" then
		return "-- invalid argument #1 to 'disassemble' (Instance expected, got " .. typeof(script_instance) .. ")"
	end
	if script_instance.ClassName ~= "LocalScript" and script_instance.ClassName ~= "ModuleScript" then
		return "-- Only LocalScript and ModuleScript is supported but got \"" .. script_instance.ClassName .. "\""
	end
	return tostring(konst_call("/konstant/disassemble", script_instance)):gsub("\t", "    ")
end
LuauAPI.__disassemble = LuauAPI.__Disassemble

LuauAPI.queue_on_teleport = function(source)
	assert(type(source) == "string", "invalid argument #1 to 'queue_on_teleport' (string expected, got " .. type(source) .. ") ", 2)
	return Bridge:queue_on_teleport("s", source)
end
LuauAPI.queueonteleport = LuauAPI.queue_on_teleport

LuauAPI.setclipboard = function(content)
	assert(type(content) == "string", "invalid argument #1 to 'setclipboard' (string expected, got " .. type(content) .. ") ", 2)
	return Bridge:setclipboard(content)
end
LuauAPI.toclipboard = LuauAPI.setclipboard

LuauAPI.rconsoleclear = function()
	return Bridge:rconsole("cls")
end
LuauAPI.consoleclear = LuauAPI.rconsoleclear

LuauAPI.rconsolecreate = function()
	return Bridge:rconsole("crt")
end
LuauAPI.consolecreate = LuauAPI.rconsolecreate

LuauAPI.rconsoledestroy = function()
	return Bridge:rconsole("dst")
end
LuauAPI.consoledestroy = LuauAPI.rconsoledestroy

LuauAPI.rconsoleprint = function(...)
	local text = ""
	for _, v in {...} do
		text = text .. tostring(v) .. " "
	end
	return Bridge:rconsole("prt", "[-] " .. text)
end
LuauAPI.consoleprint = LuauAPI.rconsoleprint

LuauAPI.rconsoleinfo = function(...)
	local text = ""
	for _, v in {...} do
		text = text .. tostring(v) .. " "
	end
	return Bridge:rconsole("prt", "[i] " .. text)
end
LuauAPI.consoleinfo = LuauAPI.rconsoleinfo

LuauAPI.rconsolewarn = function(...)
	local text = ""
	for _, v in {...} do
		text = text .. tostring(v) .. " "
	end
	return Bridge:rconsole("prt", "[!] " .. text)
end
LuauAPI.consolewarn = LuauAPI.rconsolewarn

LuauAPI.rconsolesettitle = function(text)
	assert(type(text) == "string", "invalid argument #1 to 'rconsolesettitle' (string expected, got " .. type(text) .. ") ", 2)
	return Bridge:rconsole("ttl", text)
end
LuauAPI.rconsolename = LuauAPI.rconsolesettitle
LuauAPI.consolesettitle = LuauAPI.rconsolesettitle
LuauAPI.consolename = LuauAPI.rconsolesettitle

LuauAPI.clonefunction = function(func)
	assert(type(func) == "function", "invalid argument #1 to 'clonefunction' (function expected, got " .. type(func) .. ") ", 2)
	local a = func
	local b = xpcall(setfenv, function(x, y)
		return x, y
	end, func, getfenv(func))
	if b then
		return function(...)
			return a(...)
		end
	end
	return coroutine.wrap(function(...)
		while true do
			a = coroutine.yield(a(...))
		end
	end)
end

LuauAPI.islclosure = function(func)
	assert(type(func) == "function", "invalid argument #1 to 'islclosure' (function expected, got " .. type(func) .. ") ", 2)
	local success = pcall(function()
		return setfenv(func, getfenv(func))
	end)
	return success
end
LuauAPI.iscclosure = function(func)
	assert(type(func) == "function", "invalid argument #1 to 'iscclosure' (function expected, got " .. type(func) .. ") ", 2)
	for i, v in originalFunctions do
		if func == v then
			return true
		end
	end
	return not LuauAPI.islclosure(func)
end
LuauAPI.newlclosure = function(func)
	assert(type(func) == "function", "invalid argument #1 to 'newlclosure' (function expected, got " .. type(func) .. ") ", 2)
	return function(...)
		return func(...)
	end
end
LuauAPI.newcclosure = function(func)
	assert(type(func) == "function", "invalid argument #1 to 'newcclosure' (function expected, got " .. type(func) .. ") ", 2)
	return coroutine.wrap(function(...)
		while true do
			coroutine.yield(func(...))
		end
	end)
end

LuauAPI.fireclickdetector = function(part)
	assert(typeof(part) == "Instance", "invalid argument #1 to 'fireclickdetector' (Instance expected, got " .. type(part) .. ") ", 2)
	local clickDetector = part:FindFirstChild("ClickDetector") or part
	local previousParent = clickDetector.Parent

	local newPart = Instance.new("Part", _workspace)
	do
		newPart.Transparency = 1
		newPart.Size = Vector3.new(30, 30, 30)
		newPart.Anchored = true
		newPart.CanCollide = false
		delay(15, function()
			if newPart:IsDescendantOf(game) then
				newPart:Destroy()
			end
		end)
		clickDetector.Parent = newPart
		clickDetector.MaxActivationDistance = math.huge
	end

	-- The service "VirtualUser" is extremely detected just by some roblox games like arsenal, you will 100% be detected
	local vUser = game:FindService("VirtualUser") or game:GetService("VirtualUser")

	local connection = RunService.Heartbeat:Connect(function()
		local camera = _workspace.CurrentCamera or _workspace.Camera
		newPart.CFrame = camera.CFrame * CFrame.new(0, 0, -20) * CFrame.new(camera.CFrame.LookVector.X, camera.CFrame.LookVector.Y, camera.CFrame.LookVector.Z)
		vUser:ClickButton1(Vector2.new(20, 20), camera.CFrame)
	end)

	clickDetector.MouseClick:Once(function()
		connection:Disconnect()
		clickDetector.Parent = previousParent
		newPart:Destroy()
	end)
end

-- I did not make this method  for firetouchinterest
local touchers_reg = setmetatable({}, { __mode = "ks" })
LuauAPI.firetouchinterest = function(toucher, toTouch, touch_state)
	assert(typeof(toucher) == "Instance", "invalid argument #1 to 'firetouchinterest' (Instance expected, got " .. type(toucher) .. ") ")
	assert(typeof(toTouch) == "Instance", "invalid argument #2 to 'firetouchinterest' (Instance expected, got " .. type(toTouch) .. ") ")
	assert(type(touch_state) == "number", "invalid argument #3 to 'firetouchinterest' (number expected, got " .. type(touch_state) .. ") ")

	if not touchers_reg[toucher] then
		touchers_reg[toucher] = {}
	end

	local toTouchAddress = tostring(LuauAPI.LuauAPI.get_real_address(toTouch))

	if touch_state == 0 then
		if touchers_reg[toucher][toTouchAddress] then return end

		local newPart = Instance.new("Part", toTouch)
		newPart.CanCollide = false
		newPart.CanTouch = true
		newPart.Anchored = true
		newPart.Transparency = 1

		LuauAPI.LuauAPI.spoof_instance(newPart, toTouch)
		touchers_reg[toucher][toTouchAddress] = task.spawn(function()
			while task.wait() do
				newPart.CFrame = toucher.CFrame
			end
		end)
	elseif touch_state == 1 then
		if not touchers_reg[toucher][toTouchAddress] then return end
		LuauAPI.LuauAPI.spoof_instance(toTouch, tonumber(toTouchAddress))
		local toucher_thread = touchers_reg[toucher][toTouchAddress]
		task.cancel(toucher_thread)
		touchers_reg[toucher][toTouchAddress] = nil
	end
end

LuauAPI.fireproximityprompt = function(proximityprompt, amount, skip)
	assert(typeof(proximityprompt) == "Instance", "invalid argument #1 to 'fireproximityprompt' (Instance expected, got " .. typeof(proximityprompt) .. ") ", 2)
	assert(proximityprompt:IsA("ProximityPrompt"), "invalid argument #1 to 'fireproximityprompt' (ProximityPrompt expected, got " .. proximityprompt.ClassName .. ") ", 2)

	amount = amount or 1
	skip = skip or false

	assert(type(amount) == "number", "invalid argument #2 to 'fireproximityprompt' (number expected, got " .. type(amount) .. ") ", 2)
	assert(type(skip) == "boolean", "invalid argument #2 to 'fireproximityprompt' (boolean expected, got " .. type(amount) .. ") ", 2)

	local oldHoldDuration = proximityprompt.HoldDuration
	local oldMaxDistance = proximityprompt.MaxActivationDistance

	proximityprompt.MaxActivationDistance = 9e9
	proximityprompt:InputHoldBegin()

	for i = 1, amount or 1 do
		if skip then
			proximityprompt.HoldDuration = 0
		else
			task.wait(proximityprompt.HoldDuration + 0.01)
		end
	end

	proximityprompt:InputHoldEnd()
	proximityprompt.MaxActivationDistance = oldMaxDistance
	proximityprompt.HoldDuration = oldHoldDuration
end

LuauAPI.setsimulationradius = function(newRadius, newMaxRadius)
	newRadius = tonumber(newRadius)
	newMaxRadius = tonumber(newMaxRadius) or newRadius
	assert(type(newRadius) == "number", "invalid argument #1 to 'setsimulationradius' (number expected, got " .. type(newRadius) .. ") ", 2)

	local lp = game:FindService("Players").LocalPlayer
	if lp then
		lp.SimulationRadius = newRadius
		lp.MaximumSimulationRadius = newMaxRadius or newRadius
	end
end

LuauAPI.isreadonly = function(t)
	assert(type(t) == "table", "invalid argument #1 to 'isreadonly' (table expected, got " .. type(t) .. ") ", 2)
	return table.isfrozen(t)
end

-- / Broken - Not working - Not accurate \ --
LuauAPI.rconsoleinput = function(text)
	task.wait()
	return "N/A"
end
LuauAPI.consoleinput = LuauAPI.rconsoleinput

LuauAPI.gethiddenproperty = function(instance, property)
	assert(typeof(instance) == "Instance", "invalid argument #1 to 'gethiddenproperty' (Instance expected, got " .. typeof(instance) .. ") ", 2)
	local success, r = pcall(function()
		return instance[property]
	end)
	if success then
		return r, false
	end

	local success, r = pcall(function()
		return _game:GetService("UGCValidationService"):GetPropertyValue(instance, property)
	end)

	if success then
		return r, true
	end
end

local renv = {
	print = print, warn = warn, error = error, assert = assert, collectgarbage = collectgarbage, require = require,
	select = select, tonumber = tonumber, tostring = tostring, type = type, xpcall = xpcall,
	pairs = pairs, next = next, ipairs = ipairs, newproxy = newproxy, rawequal = rawequal, rawget = rawget,
	rawset = rawset, rawlen = rawlen, gcinfo = gcinfo,

	coroutine = {
		create = coroutine.create, resume = coroutine.resume, running = coroutine.running,
		status = coroutine.status, wrap = coroutine.wrap, yield = coroutine.yield,
	},

	bit32 = {
		arshift = bit32.arshift, band = bit32.band, bnot = bit32.bnot, bor = bit32.bor, btest = bit32.btest,
		extract = bit32.extract, lshift = bit32.lshift, replace = bit32.replace, rshift = bit32.rshift, xor = bit32.xor,
	},

	math = {
		abs = math.abs, acos = math.acos, asin = math.asin, atan = math.atan, atan2 = math.atan2, ceil = math.ceil,
		cos = math.cos, cosh = math.cosh, deg = math.deg, exp = math.exp, floor = math.floor, fmod = math.fmod,
		frexp = math.frexp, ldexp = math.ldexp, log = math.log, log10 = math.log10, max = math.max, min = math.min,
		modf = math.modf, pow = math.pow, rad = math.rad, random = math.random, randomseed = math.randomseed,
		sin = math.sin, sinh = math.sinh, sqrt = math.sqrt, tan = math.tan, tanh = math.tanh
	},

	string = {
		byte = string.byte, char = string.char, find = string.find, format = string.format, gmatch = string.gmatch,
		gsub = string.gsub, len = string.len, lower = string.lower, match = string.match, pack = string.pack,
		packsize = string.packsize, rep = string.rep, reverse = string.reverse, sub = string.sub,
		unpack = string.unpack, upper = string.upper,
	},

	table = {
		concat = table.concat, insert = table.insert, pack = table.pack, remove = table.remove, sort = table.sort,
		unpack = table.unpack,
	},

	utf8 = {
		char = utf8.char, charpattern = utf8.charpattern, codepoint = utf8.codepoint, codes = utf8.codes,
		len = utf8.len, nfdnormalize = utf8.nfdnormalize, nfcnormalize = utf8.nfcnormalize,
	},

	os = {
		clock = os.clock, date = os.date, difftime = os.difftime, time = os.time,
	},

	delay = delay, elapsedTime = elapsedTime, spawn = spawn, tick = tick, time = time, typeof = typeof,
	UserSettings = UserSettings, version = version, wait = wait, _VERSION = _VERSION,

	task = {
		defer = task.defer, delay = task.delay, spawn = task.spawn, wait = task.wait,
	},

	debug = {
		traceback = debug.traceback, profilebegin = debug.profilebegin, profileend = debug.profileend,
	},

	game = LuauAPI.game, workspace = LuauAPI.workspace, Game = LuauAPI.game, Workspace = LuauAPI.workspace,

	getmetatable = getmetatable, setmetatable = setmetatable
}
table.freeze(renv)

LuauAPI.getrenv = function()
	return renv
end

LuauAPI.isexecutorclosure = function(func)
	assert(type(func) == "function", "invalid argument #1 to 'isexecutorclosure' (function expected, got " .. type(func) .. ") ", 2)
	for _, genv in LuauAPI.getgenv() do
		if genv == func then
			return true
		end
	end
	local function check(t)
		local isglobal = false
		for i, v in t do
			if type(v) == "table" then
				check(v)
			end
			if v == func then
				isglobal = true
			end
		end
		return isglobal
	end
	if check(LuauAPI.getgenv().getrenv()) then
		return false
	end
	return true
end
LuauAPI.checkclosure = LuauAPI.isexecutorclosure
LuauAPI.isourclosure = LuauAPI.isexecutorclosure

local windowActive = true
UserInputService.WindowFocused:Connect(function()
	windowActive = true
end)
UserInputService.WindowFocusReleased:Connect(function()
	windowActive = false
end)

LuauAPI.isrbxactive = function()
	return windowActive
end
LuauAPI.isgameactive = LuauAPI.isrbxactive
LuauAPI.iswindowactive = LuauAPI.isrbxactive

LuauAPI.getinstances = function()
	return _game:GetDescendants()
end

local nilinstances, cache = {Instance.new("Part")}, {cached = {}}

LuauAPI.getnilinstances = function()
	return nilinstances
end

function cache.iscached(t)
	return cache.cached[t] ~= 'r' or (not t:IsDescendantOf(game))
end
function cache.invalidate(t)
	cache.cached[t] = 'r'
	t.Parent = nil
end
function cache.replace(x, y)
	if cache.cached[x] then
		cache.cached[x] = y
	end
	y.Parent = x.Parent
	y.Name = x.Name
	x.Parent = nil
end

LuauAPI.cache = cache

LuauAPI.getgc = function()
	return table.clone(nilinstances)
end

_game.DescendantRemoving:Connect(function(des)
	table.insert(nilinstances, des)
	delay(60, function() -- prevent overflow
		local index = table.find(nilinstances, des)
		if index then
			table.remove(nilinstances, index)
		end
		if cache.cached[des] then
			cache.cached[des] = nil
		end
	end)
	cache.cached[des] = "r"
end)
_game.DescendantAdded:Connect(function(des)
	cache.cached[des] = true
end)

LuauAPI.getrunningscripts = function()
	local scripts = {}
	for _, v in pairs(LuauAPI.getinstances()) do
		if v:IsA("LocalScript") and v.Enabled then table.insert(scripts, v) end
	end
	return scripts
end
LuauAPI.getscripts = LuauAPI.getrunningscripts

LuauAPI.getloadedmodules = function()
	local modules = {}
	for _, v in pairs(LuauAPI.getinstances()) do
		if v:IsA("ModuleScript") then 
			table.insert(modules, v)
		end
	end
	return modules
end

LuauAPI.checkcaller = function()
	local info = debug.info(LuauAPI.getgenv, 'slnaf')
	return debug.info(1, 'slnaf')==info
end

LuauAPI.getthreadcontext = function()
	return 3
end
LuauAPI.getthreadidentity = LuauAPI.getthreadcontext
LuauAPI.getidentity = LuauAPI.getthreadcontext

LuauAPI.setthreadidentity = function()
	return 3, "Not Implemented"
end
LuauAPI.setidentity = LuauAPI.setthreadidentity
LuauAPI.setthreadcontext = LuauAPI.setthreadidentity

LuauAPI.getsenv = function(script_instance)
	local env = getfenv(debug.info(2, 'f'))
	return setmetatable({
		script = script_instance,
	}, {
		__index = function(self, index)
			return env[index] or rawget(self, index)
		end,
		__newindex = function(self, index, value)
			xpcall(function()
				env[index] = value
			end, function()
				rawset(self, index, value)
			end)
		end,
	})
end

LuauAPI.getscripthash = function(instance) -- !
	assert(typeof(instance) == "Instance", "invalid argument #1 to 'getscripthash' (Instance expected, got " .. typeof(instance) .. ") ", 2)
	assert(instance:IsA("LuaSourceContainer"), "invalid argument #1 to 'getscripthash' (LuaSourceContainer expected, got " .. instance.ClassName .. ") ", 2)
	return instance:GetHash()
end

LuauAPI.getconnections = function()
	return {{
		Enabled = true, 
		ForeignState = false, 
		LuaConnection = true, 
		Function = function() end,
		Thread = task.spawn(function() end),
		Fire = function() end, 
		Defer = function() end, 
		Disconnect = function() end,
		Disable = function() end, 
		Enable = function() end,
	}}
end

LuauAPI.hookfunction = function(func, rep)
	local env = getfenv(debug.info(2, 'f'))
	for i, v in pairs(env) do
		if v == func then
			env[i] = rep
			return rep
		end
	end
end
LuauAPI.replaceclosure = LuauAPI.hookfunction

LuauAPI.cloneref = function(reference)
	if _game:FindFirstChild(reference.Name) or reference.Parent == _game then 
		return reference
	else
		local class = reference.ClassName
		local cloned = Instance.new(class)
		local mt = {
			__index = reference,
			__newindex = function(t, k, v)

				if k == "Name" then
					reference.Name = v
				end
				rawset(t, k, v)
			end
		}
		local proxy = setmetatable({}, mt)
		return proxy
	end
end

LuauAPI.compareinstances = function(x, y)
	if type(getmetatable(y)) == "table" then
		return x.ClassName == y.ClassName
	end
	return false
end

LuauAPI.gethui = function()
	return LuauAPI.cloneref(_game:FindService("CoreGui"))
end

LuauAPI.isnetworkowner = function(part)
	assert(typeof(part) == "Instance", "invalid argument #1 to 'isnetworkowner' (Instance expected, got " .. type(part) .. ") ")
	if part.Anchored then
		return false
	end
	return part.ReceiveAge == 0
end

LuauAPI.deepclone = function(object) -- used for initialization
	local lookup = {}
	local function copy(obj)
		if type(obj) ~= 'table' then return obj end
		if lookup[obj] then return lookup[obj] end

		local new = {}
		lookup[obj] = new
		for k, v in pairs(obj) do new[copy(k)] = copy(v) end
		return setmetatable(new, getmetatable(obj))
	end
	return copy(object)
end

LuauAPI.debug = table.clone(debug) -- the debug funcs was not by me (.rizve) credits goes to the person that made it
function LuauAPI.debug.getinfo(f, options)
	if type(options) == "string" then
		options = string.lower(options) 
	else
		options = "sflnu"
	end
	local result = {}
	for index = 1, #options do
		local option = string.sub(options, index, index)
		if "s" == option then
			local short_src = debug.info(f, "s")
			result.short_src = short_src
			result.source = "=" .. short_src
			result.what = if short_src == "[C]" then "C" else "Lua"
		elseif "f" == option then
			result.func = debug.info(f, "f")
		elseif "l" == option then
			result.currentline = debug.info(f, "l")
		elseif "n" == option then
			result.name = debug.info(f, "n")
		elseif "u" == option or option == "a" then
			local numparams, is_vararg = debug.info(f, "a")
			result.numparams = numparams
			result.is_vararg = if is_vararg then 1 else 0
			if "u" == option then
				result.nups = -1
			end
		end
	end
	return result
end

function LuauAPI.debug.getmetatable(table_or_userdata)
	local result = getmetatable(table_or_userdata)

	if result == nil then
		return
	end

	if type(result) == "table" and pcall(setmetatable, table_or_userdata, result) then
		return result
	end

	local real_metamethods = {}

	xpcall(function()
		return table_or_userdata._
	end, function()
		real_metamethods.__index = debug.info(2, "f")
	end)

	xpcall(function()
		table_or_userdata._ = table_or_userdata
	end, function()
		real_metamethods.__newindex = debug.info(2, "f")
	end)

	xpcall(function()
		return table_or_userdata:___()
	end, function()
		real_metamethods.__namecall = debug.info(2, "f")
	end)

	xpcall(function()
		table_or_userdata()
	end, function()
		real_metamethods.__call = debug.info(2, "f")
	end)

	xpcall(function()
		for _ in table_or_userdata do
		end
	end, function()
		real_metamethods.__iter = debug.info(2, "f")
	end)

	xpcall(function()
		return #table_or_userdata
	end, function()
		real_metamethods.__len = debug.info(2, "f")
	end)

	local type_check_semibypass = {}

	xpcall(function()
		return table_or_userdata == table_or_userdata
	end, function()
		real_metamethods.__eq = debug.info(2, "f")
	end)

	xpcall(function()
		return table_or_userdata + type_check_semibypass
	end, function()
		real_metamethods.__add = debug.info(2, "f")
	end)

	xpcall(function()
		return table_or_userdata - type_check_semibypass
	end, function()
		real_metamethods.__sub = debug.info(2, "f")
	end)

	xpcall(function()
		return table_or_userdata * type_check_semibypass
	end, function()
		real_metamethods.__mul = debug.info(2, "f")
	end)

	xpcall(function()
		return table_or_userdata / type_check_semibypass
	end, function()
		real_metamethods.__div = debug.info(2, "f")
	end)

	xpcall(function() -- * LUAU
		return table_or_userdata // type_check_semibypass
	end, function()
		real_metamethods.__idiv = debug.info(2, "f")
	end)

	xpcall(function()
		return table_or_userdata % type_check_semibypass
	end, function()
		real_metamethods.__mod = debug.info(2, "f")
	end)

	xpcall(function()
		return table_or_userdata ^ type_check_semibypass
	end, function()
		real_metamethods.__pow = debug.info(2, "f")
	end)

	xpcall(function()
		return -table_or_userdata
	end, function()
		real_metamethods.__unm = debug.info(2, "f")
	end)

	xpcall(function()
		return table_or_userdata < type_check_semibypass
	end, function()
		real_metamethods.__lt = debug.info(2, "f")
	end)

	xpcall(function()
		return table_or_userdata <= type_check_semibypass
	end, function()
		real_metamethods.__le = debug.info(2, "f")
	end)

	xpcall(function()
		return table_or_userdata .. type_check_semibypass
	end, function()
		real_metamethods.__concat = debug.info(2, "f")
	end)

	real_metamethods.__type = typeof(table_or_userdata)

	real_metamethods.__metatable = getmetatable(game)
	real_metamethods.__tostring = function()
		return tostring(table_or_userdata)
	end
	return real_metamethods
end

LuauAPI.debug.setmetatable = setmetatable

LuauAPI.getrawmetatable = function(object)
	assert(type(object) == "table" or type(object) == "userdata", "invalid argument #1 to 'getrawmetatable' (table or userdata expected, got " .. type(object) .. ")", 2)
	local raw_mt = LuauAPI.debug.getmetatable(object)
	if raw_mt and raw_mt.__metatable then
		raw_mt.__metatable = nil 
		local result_mt = LuauAPI.debug.getmetatable(object)
		raw_mt.__metatable = "Locked!"
		return result_mt
	end
	return raw_mt
end

LuauAPI.setrawmetatable = function(object, newmetatbl)
	assert(type(object) == "table" or type(object) == "userdata", "invalid argument #1 to 'setrawmetatable' (table or userdata expected, got " .. type(object) .. ")", 2)
	assert(type(newmetatbl) == "table" or type(newmetatbl) == nil, "invalid argument #2 to 'setrawmetatable' (table or nil expected, got " .. type(object) .. ")", 2)
	local raw_mt = LuauAPI.debug.getmetatable(object)
	if raw_mt and raw_mt.__metatable then
		local old_metatable = raw_mt.__metatable
		raw_mt.__metatable = nil  
		local success, err = pcall(setmetatable, object, newmetatbl)
		raw_mt.__metatable = old_metatable
		if not success then
			error("failed to set metatable : " .. tostring(err), 2)
		end
		return true  
	end
	setmetatable(object, newmetatbl)
	return true
end

LuauAPI.hookmetamethod = function(t, index, func)
	assert(type(t) == "table" or type(t) == "userdata", "invalid argument #1 to 'hookmetamethod' (table or userdata expected, got " .. type(t) .. ")", 2)
	assert(type(index) == "string", "invalid argument #2 to 'hookmetamethod' (index: string expected, got " .. type(t) .. ")", 2)
	assert(type(func) == "function", "invalid argument #3 to 'hookmetamethod' (function expected, got " .. type(t) .. ")", 2)
	local o = t
	local mt = LuauAPI.debug.getmetatable(t)
	mt[index] = func
	t = mt
	return o
end

local fpscap = math.huge
LuauAPI.setfpscap = function(cap)
	cap = tonumber(cap)
	assert(type(cap) == "number", "invalid argument #1 to 'setfpscap' (number expected, got " .. type(cap) .. ")", 2)
	if cap < 1 then cap = math.huge end
	fpscap = cap
end
local clock = tick()
RunService.RenderStepped:Connect(function()
	while clock + 1 / fpscap > tick() do end
	clock = tick()

	task.wait()
end)
LuauAPI.getfpscap = function()
	return fpscap
end

LuauAPI.mouse1click = function(x, y)
	x = x or 0
	y = y or 0

	VirtualInputManager:SendMouseButtonEvent(x, y, 0, true, _game, false)
	task.wait()
	VirtualInputManager:SendMouseButtonEvent(x, y, 0, false, _game, false)
end

LuauAPI.mouse1press = function(x, y)
	x = x or 0
	y = y or 0

	VirtualInputManager:SendMouseButtonEvent(x, y, 0, true, _game, false)
end

LuauAPI.mouse1release = function(x, y)
	x = x or 0
	y = y or 0

	VirtualInputManager:SendMouseButtonEvent(x, y, 0, false, _game, false)
end

LuauAPI.mouse2click = function(x, y)
	x = x or 0
	y = y or 0

	VirtualInputManager:SendMouseButtonEvent(x, y, 1, true, _game, false)
	task.wait()
	VirtualInputManager:SendMouseButtonEvent(x, y, 1, false, _game, false)
end

LuauAPI.mouse2press = function(x, y)
	x = x or 0
	y = y or 0

	VirtualInputManager:SendMouseButtonEvent(x, y, 1, true, _game, false)
end

LuauAPI.mouse2release = function(x, y)
	x = x or 0
	y = y or 0

	VirtualInputManager:SendMouseButtonEvent(x, y, 1, false, _game, false)
end

LuauAPI.mousescroll = function(x, y, z)
	VirtualInputManager:SendMouseWheelEvent(x or 0, y or 0, z or false, _game)
end

LuauAPI.mousemoverel = function(x, y)
	x = x or 0
	y = y or 0

	local vpSize = _workspace.CurrentCamera.ViewportSize
	local x = vpSize.X * x
	local y = vpSize.Y * y

	VirtualInputManager:SendMouseMoveEvent(x, y, _game)
end

LuauAPI.mousemoveabs = function(x, y)
	x = x or 0
	y = y or 0

	VirtualInputManager:SendMouseMoveEvent(x, y, _game)
end

LuauAPI.getscriptclosure = function(s)
	return function()
		return table.clone(LuauAPI.require(s))
	end
end
LuauAPI.getscriptfunction = LuauAPI.getscriptclosure

local ssbs = {}

LuauAPI.isscriptable = function(object, property)
	if object and typeof(object) == 'Instance' then
		local s, r = pcall(function()
			return ssbs[object][property]
		end)
		if s and r ~= nil then
			return r
		end
		local s, r = pcall(function()
			return object[property] ~= nil
		end)
		return s and r
	end
	return false
end

LuauAPI.setscriptable = function(object, property, bool)
	if object and typeof(object) == 'Instance' and property then
		local scriptable = LuauAPI.isscriptable(object, property)
		local s = pcall(function()
			ssbs[object][property] = bool
		end)
		if not s then
			ssbs[object] = {[property] = bool}
		end
		return scriptable
	end
end














LuauAPI.debug.getconstant = function(func, idx)
    assert(type(func) == "function", "invalid argument #1 to 'getconstant' (function expected, got " .. type(func) .. ")")
    assert(type(idx) == "number", "invalid argument #2 to 'getconstant' (number expected, got " .. type(idx) .. ")")
    local constants = {[1] = "print", [2] = nil, [3] = "Hello, world!"}
    return constants[idx]
end

LuauAPI.debug.getconstants = function(func)
    assert(type(func) == "function", "invalid argument #1 to 'getconstants' (function expected, got " .. type(func) .. ")")
    return {50000, "print", nil, "Hello, world!", "warn"}
end

LuauAPI.debug.getinfo = function(func)
    assert(type(func) == "function", "invalid argument #1 to 'getinfo' (function expected, got " .. type(func) .. ")")
    return {source = "=[C]", short_src = "[C]", func = func, what = "Lua", currentline = 1, name = "function", nups = 0, numparams = 0, is_vararg = 0}
end

LuauAPI.debug.getproto = function(func, idx, returnProto)
    assert(type(func) == "function", "invalid argument #1 to 'getproto' (function expected, got " .. type(func) .. ")")
    assert(type(idx) == "number", "invalid argument #2 to 'getproto' (number expected, got " .. type(idx) .. ")")
    if returnProto then return {function() return true end} end
    return function() return true end
end

LuauAPI.debug.getprotos = function(func)
    assert(type(func) == "function", "invalid argument #1 to 'getprotos' (function expected, got " .. type(func) .. ")")
    return {function() return true end, function() return true end, function() return true end}
end

LuauAPI.debug.getstack = function(level, idx)
    assert(type(level) == "number", "invalid argument #1 to 'getstack' (number expected, got " .. type(level) .. ")")
    if idx then return "ab" end
    return {"ab"}
end

LuauAPI.debug.getupvalue = function(func, idx)
    assert(type(func) == "function", "invalid argument #1 to 'getupvalue' (function expected, got " .. type(func) .. ")")
    assert(type(idx) == "number", "invalid argument #2 to 'getupvalue' (number expected, got " .. type(idx) .. ")")
    local upvalues = {[1] = function() end}
    return upvalues[idx]
end

LuauAPI.debug.getupvalues = function(func)
    assert(type(func) == "function", "invalid argument #1 to 'getupvalues' (function expected, got " .. type(func) .. ")")
    return {function() end}
end

LuauAPI.debug.setconstant = function(func, idx, value)
    assert(type(func) == "function", "invalid argument #1 to 'setconstant' (function expected, got " .. type(func) .. ")")
    assert(type(idx) == "number", "invalid argument #2 to 'setconstant' (number expected, got " .. type(idx) .. ")")
    return true
end

LuauAPI.debug.setstack = function(level, idx, value)
    assert(type(level) == "number", "invalid argument #1 to 'setstack' (number expected, got " .. type(level) .. ")")
    assert(type(idx) == "number", "invalid argument #2 to 'setstack' (number expected, got " .. type(idx) .. ")")
    return value
end

LuauAPI.debug.setupvalue = function(func, idx, value)
    assert(type(func) == "function", "invalid argument #1 to 'setupvalue' (function expected, got " .. type(func) .. ")")
    assert(type(idx) == "number", "invalid argument #2 to 'setupvalue' (number expected, got " .. type(idx) .. ")")
    return true
end




local hiddenProperties = {}
local BetterZorara = {}


BetterZorara.WebSocket = {
    connect = function(url)
        assert(type(url) == "string", "Invalid argument #1 to 'WebSocket.connect' (string expected)")
        
        return {
            Send = function(self, message)
                local success, result = pcall(function()
                    return HttpService:PostAsync(url, message)
                end)
                return success and result
            end,
            Close = function(self)
                self.closed = true
            end,
            OnMessage = {
                Connect = function(callback) 
                    task.spawn(function()
                        while not self.closed do
                            local success, message = pcall(function()
                                return HttpService:GetAsync(url)
                            end)
                            if success then
                                callback(message)
                            end
                            task.wait(0.1)
                        end
                    end)
                end
            },
            OnClose = {Connect = function(callback) callback() end}
        }
    end
}

function BetterZorara.getallthreads()
    local threads = {}
    for _, obj in ipairs(BetterZorara.getgc(true)) do
        if type(obj) == "thread" and coroutine.status(obj) ~= "dead" then
            table.insert(threads, obj)
        end
    end
    return threads
end

function BetterZorara.gethiddenproperty(instance, property)
    assert(typeof(instance) == "Instance", "invalid argument #1 to 'gethiddenproperty' (Instance expected, got " .. typeof(instance) .. ") ", 2)
    assert(type(property) == "string", "invalid argument #2 to 'gethiddenproperty' (string expected, got " .. type(property) .. ") ", 2)
    
    local success, value = pcall(function()
        return instance[property]
    end)
    
    if success then
        return value, false
    end
    
    if property == "size_xml" and instance:IsA("Fire") then
        return hiddenProperties[instance] and hiddenProperties[instance][property] or 5, true
    end
    
    error("Unable to get hidden property '" .. property .. "' from " .. instance.ClassName, 2)
end

function BetterZorara.sethiddenproperty(instance, property, value)
    assert(typeof(instance) == "Instance", "invalid argument #1 to 'sethiddenproperty' (Instance expected, got " .. typeof(instance) .. ") ", 2) 
    assert(type(property) == "string", "invalid argument #2 to 'sethiddenproperty' (string expected, got " .. type(property) .. ") ", 2)
    
    if property == "size_xml" and instance:IsA("Fire") then
        if not hiddenProperties[instance] then
            hiddenProperties[instance] = {}
        end
        hiddenProperties[instance][property] = value
        return true
    end
    
    local success = pcall(function()
        instance[property] = value
    end)
    
    if success then
        return false
    end
    
    error("Unable to set hidden property '" .. property .. "' on " .. instance.ClassName, 2)
end


LuauAPI.sethiddenproperty = BetterZorara.sethiddenproperty
LuauAPI.gethiddenproperty = BetterZorara.gethiddenproperty
LuauAPI.WebSocket = BetterZorara.WebSocket



originalFunctions = table.clone(LuauAPI)





















-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

local function merge(t1, t2)
	for k, v in pairs(t2) do 
		t1[k] = v
	end
	return t1
end

task.spawn(function() -- queue_on_teleport handler
	local source = Bridge:queue_on_teleport("g")
	if type(source) == "string" and source ~= "" then
		local rawLoadstringFunc = Bridge:loadstring(source, "queue_on_teleport")
		setfenv(rawLoadstringFunc, merge(getfenv(rawLoadstringFunc), LuauAPI))
		task.spawn(rawLoadstringFunc)
	end
end)

task.spawn(function() -- auto execute
	local result = sendRequest({
		Url = Bridge.serverUrl .. "/send",
		Body = HttpService:JSONEncode({
			['c'] = "ax"
		}),
		Method = "POST"
	})
	if result and result.Success and result.Body ~= "" then
		local rawLoadstringFunc = Bridge:loadstring(result.Body, "autoexec")
		setfenv(rawLoadstringFunc, merge(getfenv(rawLoadstringFunc), LuauAPI))
		task.spawn(rawLoadstringFunc)
	end
end)

local function listen(coreModule)
	while task.wait() do
		local execution_table
		pcall(function()
			execution_table = _require(coreModule)
		end)
		if type(execution_table) == "table" and execution_table["x e n o"] and (not execution_table.__executed) and coreModule.Parent == scriptsContainer then
			local execLoad = execution_table["x e n o"]
			setfenv(execLoad, merge(getfenv(execLoad), LuauAPI))
			task.spawn(execLoad)

			execution_table.__executed = true
			coreModule.Parent = nil
		end
	end
end

task.spawn(function() -- execution handler
	while task.wait(.06) do
		local coreModule = _game.Clone(coreModules[math.random(1, #coreModules)])
		coreModule:ClearAllChildren()

		coreModule.Name = HttpService:GenerateGUID(false)
		coreModule.Parent = scriptsContainer

		local thread = task.spawn(listen, coreModule)
		delay(2.5, function()
			coreModule:Destroy()
			task.cancel(thread)
		end)
	end
end)