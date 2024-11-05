local LuauAPI = {
    debug = {}
}

local env = {}
local readonly = {}
local connections = {}
local hooks = {}
local threadIdentities = {}

function LuauAPI.getgenv()
    return env
end

function LuauAPI.setgenv(key, value)
    env[key] = value
    return env
end

function LuauAPI.getreg()
    return debug.getregistry()
end

function LuauAPI.getrenv()
    return getfenv(0)
end

function LuauAPI.getgc()
    return {}
end

function LuauAPI.getfenv(level)
    return debug.getfenv(level)
end

function LuauAPI.setfenv(level, env)
    return debug.setfenv(level, env)
end

function LuauAPI.clonefunction(f)
    return function(...) return f(...) end
end

function LuauAPI.newcclosure(f)
    return f
end

function LuauAPI.islclosure(f)
    return type(f) == "function" and not pcall(debug.getupvalue, f, 1)
end

function LuauAPI.getrawmetatable(obj)
    return getmetatable(obj)
end

function LuauAPI.setrawmetatable(obj, mt)
    local success = pcall(function()
        -- Get the raw metatable handling function from debug library
        local rawset = debug.setmetatable or setmetatable
        rawset(obj, mt)
    end)
    return obj
end

function LuauAPI.getnamecallmethod()
    return debug.getinfo(2, "n").name
end

function LuauAPI.setnamecallmethod(name)
    return name
end

LuauAPI.debug.getinfo = debug.getinfo
LuauAPI.debug.getupvalue = debug.getupvalue
LuauAPI.debug.setupvalue = debug.setupvalue

function LuauAPI.debug.getconstant(f, idx)
    return debug.getconstant(f, idx)
end

function LuauAPI.debug.setconstant(f, idx, value)
    return debug.setconstant(f, idx, value)
end

LuauAPI.debug.getmetatable = debug.getmetatable
LuauAPI.debug.setmetatable = debug.setmetatable
LuauAPI.debug.getregistry = debug.getregistry

function LuauAPI.sethiddenproperty(instance, property, value)
    pcall(function() instance[property] = value end)
end

function LuauAPI.gethiddenproperty(instance, property)
    local success, result = pcall(function() return instance[property] end)
    return success and result or nil
end

function LuauAPI.setreadonly(t, readonly_value)
    readonly[t] = readonly_value
end

function LuauAPI.isreadonly(t)
    return readonly[t] or false
end

function LuauAPI.makewriteable(t)
    readonly[t] = false
end

function LuauAPI.getconnections(signal)
    return connections[signal] or {}
end

function LuauAPI.firesignal(signal, ...)
    local signalConnections = connections[signal] or {}
    for _, connection in ipairs(signalConnections) do
        connection.Function(...)
    end
end

function LuauAPI.fireclickdetector(detector, distance)
    detector.MaxActivationDistance = distance or 0
    detector:Click()
end

function LuauAPI.firetouchinterest(part1, part2, toggle)
    if toggle == 0 then
        part1.CFrame = part2.CFrame
    end
end

function LuauAPI.fireproximityprompt(prompt)
    prompt:InputHoldBegin()
    prompt:InputHoldEnd()
end

function LuauAPI.hookfunction(target, hook)
    local original = hooks[target]
    hooks[target] = hook
    return original or target
end

function LuauAPI.set_thread_identity(identity)
    threadIdentities[coroutine.running()] = identity
end

function LuauAPI.get_thread_identity()
    return threadIdentities[coroutine.running()] or 2
end

function LuauAPI.rconsoleprint(text)
    print(text)
end

function LuauAPI.rconsoleclear()
    print("\n\n\n\n\n")
end

function LuauAPI.rconsolewarn(text)
    warn(text)
end

function LuauAPI.rconsoleinfo(text)
    print("[INFO]", text)
end

function LuauAPI.rconsoleerr(text)
    warn("[ERROR]", text)
end

function LuauAPI.writefile(filename, data)
    -- Stub implementation
end

function LuauAPI.readfile(filename)
    -- Stub implementation
    return ""
end

function LuauAPI.isfile(path)
    return false
end

function LuauAPI.isfolder(path)
    return false
end

function LuauAPI.makefolder(path)
    -- Stub implementation
end

function LuauAPI.delfile(path)
    -- Stub implementation
end

function LuauAPI.delfolder(path)
    -- Stub implementation
end

function LuauAPI.listfiles(path)
    return {}
end

function LuauAPI.saveinstance(options)
    -- Stub implementation
end


local function runTests()
    local testsPassed = 0
    local totalTests = 0
    
    local function test(name, func)
        totalTests = totalTests + 1
        local success, result = pcall(func)
        if success then
            testsPassed = testsPassed + 1
            print("✓", name)
        else
            warn("×", name, "Error:", result)
        end
    end

    print("Starting LuauAPI Tests\n")
    
    test("Basic Environment", function()
        local env = LuauAPI.getgenv()
        assert(type(env) == "table")
        LuauAPI.setgenv("test", 123)
        assert(env.test == 123)
    end)
    
    test("Function Clone", function()
        local function testFunc(x) return x * 2 end
        local cloned = LuauAPI.clonefunction(testFunc)
        assert(cloned(2) == 4)
    end)
    
    test("Metatable", function()
        local t = {}
        local mt = {__index = function() return true end}
        LuauAPI.setrawmetatable(t, mt)
        assert(LuauAPI.getrawmetatable(t) == mt)
    end)
    
    test("Read-only State", function()
        local t = {}
        LuauAPI.setreadonly(t, true)
        assert(LuauAPI.isreadonly(t))
        LuauAPI.makewriteable(t)
        assert(not LuauAPI.isreadonly(t))
    end)
    
    test("Thread Identity", function()
        LuauAPI.set_thread_identity(7)
        assert(LuauAPI.get_thread_identity() == 7)
    end)

    test("Protected Metatable Override", function()
        local object = setmetatable({}, { __index = function() return false end, __metatable = "Locked!" })
        local objectReturned = LuauAPI.setrawmetatable(object, { __index = function() return true end })
        assert(object, "Did not return the original object")
        assert(object.test == true, "Failed to change the metatable")
        assert(objectReturned == object, "Did not return the original object")
    end)

    print(string.format("\nTests Complete: %d/%d passed", testsPassed, totalTests))
end

-- Run tests immediately when the module loads
runTests()

return {
    LuauAPI = LuauAPI,
}
