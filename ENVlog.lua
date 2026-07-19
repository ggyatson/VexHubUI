local Net = game:GetService("HttpService")
local Users = game:GetService("Players")
local Engine = game:GetService("RunService")
local Gateway = game:GetService("TeleportService")
local Inputs = game:GetService("UserInputService")
local Diagnostics = game:GetService("Stats")

local Options = {
    OutputFile = "Revamp_Leaks_" .. tostring(os.time()) .. ".json",
    BufferLimit = 40,
    BypassList = {
        ["RunService"] = true,
        ["UserInputService"] = true,
        ["ContextActionService"] = true,
        ["TweenService"] = true
    },
    DeepScan = true,
    PullValues = true
}

local History = {}
local Backups = {}
local Visited = {}
local SafetyValve = false

local function SafeThread()
    local trace = debug.traceback():lower():gsub('%s+', '')
    local frameworks = {"windui", "rayfield", "obsidian", "interface", "luna", "fluent", "drday", "kavo", "orion", "vape", "solara"}
    for i = 1, #frameworks do
        if trace:find(frameworks[i]) then
            return true
        end
    end
    return false
end

local function ParseValue(item, level)
    level = level or 0
    if level > 10 then return '"[Depth Maxed]"' end
    
    local kind = typeof(item)
    
    if kind == "string" then
        return '"' .. item:gsub('"', '\\"'):gsub('\n', '\\n') .. '"'
    elseif kind == "number" or kind == "boolean" then
        return tostring(item)
    elseif kind == "Instance" then
        local ok, path = pcall(function() return item:GetFullName() end)
        return '"[Instance: ' .. item.ClassName .. ' | ' .. (ok and path or "Unknown") .. ']"'
    elseif kind == "function" then
        local details = debug.getinfo(item)
        return '"[Function: ' .. tostring(item) .. ' | Line: ' .. (details.short_src or "Native") .. ':' .. (details.currentline or -1) .. ']"'
    elseif kind == "table" then
        if Visited[item] then return '"[Cyclic Reference]"' end
        Visited[item] = true
        
        local build = "{"
        local initial = true
        for k, v in pairs(item) do
            if not initial then build = build .. ", " end
            initial = false
            
            local index = type(k) == "string" and '["' .. k .. '"]' or "[" .. tostring(k) .. "]"
            build = build .. index .. " = " .. ParseValue(v, level + 1)
        end
        build = build .. "}"
        Visited[item] = nil
        return build
    else
        return '"[' .. kind .. ']"'
    end
end

local function BuildRecord(tag, source, inputs, outputs)
    local item = {
        Clock = os.date("%H:%M:%S"),
        Unix = os.time(),
        Action = tag,
        Origin = tostring(source),
        Params = ParseValue(inputs),
        Returned = ParseValue(outputs)
    }
    
    if Options.DeepScan then
        item.StackTrace = debug.traceback()
    end
    
    if Options.PullValues and type(source) == "function" then
        local pool = {}
        for i = 1, 100 do
            local ok, val = pcall(debug.getconstant, source, i)
            if ok and val ~= nil then
                table.insert(pool, tostring(val))
            else
                break
            end
        end
        if #pool > 0 then
            item.InternalConstants = pool
        end
    end
    
    return item
end

local function CommitLogs()
    if SafetyValve or #History == 0 then return end
    SafetyValve = true
    
    task.spawn(function()
        local stream = ""
        local ok, legacy = pcall(function() return readfile(Options.OutputFile) end)
        
        if ok and legacy and legacy ~= "" then
            stream = legacy:sub(1, -2) .. ",\n"
        else
            stream = "[\n"
        end
        
        local snapshot = {}
        for i = 1, #History do
            table.insert(snapshot, History[i])
        end
        History = {}
        
        for i, entry in ipairs(snapshot) do
            stream = stream .. Net:JSONEncode(entry)
            if i < #snapshot then
                stream = stream .. ",\n"
            end
        end
        
        stream = stream .. "\n]"
        writefile(Options.OutputFile, stream)
        SafetyValve = false
    end)
end

local function PushToQueue(entry)
    table.insert(History, entry)
    if #History >= Options.BufferLimit then
        CommitLogs()
    end
end

local function TrackRemoteArguments(remote, args)
    if remote.ClassName == "RemoteEvent" then
        PushToQueue(BuildRecord("REMOTE_EVENT_FIRE", remote:GetFullName(), {Arguments = args}, nil))
    elseif remote.ClassName == "RemoteFunction" then
        PushToQueue(BuildRecord("REMOTE_FUNCTION_INVOKE", remote:GetFullName(), {Arguments = args}, nil))
    end
end

local function TrackVariableMutations(func)
    if type(func) ~= "function" then return end
    local upvalues = {}
    for i = 1, 100 do
        local ok, name, val = pcall(debug.getupvalue, func, i)
        if ok and name then
            upvalues[name] = ParseValue(val)
        else
            break
        end
    end
    if next(upvalues) then
        PushToQueue(BuildRecord("UPVALUE_SNAPSHOT", func, {Upvalues = upvalues}, nil))
    end
end

if request or http_request or HttpPost then
    local target = request or http_request or HttpPost
    Backups.HttpChannel = target
    
    hookfunction(target, function(payload)
        if SafeThread() then return Backups.HttpChannel(payload) end
        local response = Backups.HttpChannel(payload)
        PushToQueue(BuildRecord("WEB_REQUEST", payload.Url or "Unknown", {payload}, response))
        return response
    end)
end

if loadstring then
    Backups.ScriptLoader = loadstring
    hookfunction(loadstring, function(sourceCode, chunkName)
        if type(sourceCode) == "string" and not SafeThread() then
            local hashId = tostring(math.hash and math.hash(sourceCode):sub(1,8) or math.random(1000, 9999))
            local path = "Revamp_Dump_" .. hashId .. ".lua"
            writefile(path, sourceCode)
            PushToQueue(BuildRecord("DYNAMIC_LOAD", chunkName or "DynamicExecution", {Size = #sourceCode, DumpPath = path}, nil))
        end
        return Backups.ScriptLoader(sourceCode, chunkName)
    end)
end

local RootMeta = getrawmetatable(game)
setreadonly(RootMeta, false)

local NativeIndex = RootMeta.__index
local NativeNamecall = RootMeta.__namecall
local NativeNewIndex = RootMeta.__newindex

RootMeta.__index = newcclosure(function(self, property)
    if checkcaller() and not SafeThread() then
        local value = NativeIndex(self, property)
        if typeof(self) == "Instance" and not Options.BypassList[self.ClassName] then
            PushToQueue(BuildRecord("PROPERTY_FETCH", self:GetFullName(), {Property = property}, value))
        end
        return value
    end
    return NativeIndex(self, property)
end)

RootMeta.__namecall = newcclosure(function(self, ...)
    local action = getnamecallmethod()
    local variables = {...}
    
    if checkcaller() and not SafeThread() then
        local result = NativeNamecall(self, ...)
        if typeof(self) == "Instance" and not Options.BypassList[self.ClassName] then
            if action ~= "IsA" and action ~= "FindFirstChild" and action ~= "WaitForChild" and action ~= "GetChildren" then
                PushToQueue(BuildRecord("ENGINE_CALL", self:GetFullName(), {Method = action, Args = variables}, result))
                
                if action == "FireServer" or action == "InvokeServer" then
                    TrackRemoteArguments(self, variables)
                end
                
                local callingFunc = debug.info(2, "f")
                if callingFunc then
                    TrackVariableMutations(callingFunc)
                end
            end
        end
        return result
    end
    
    return NativeNamecall(self, ...)
end)

RootMeta.__newindex = newcclosure(function(self, property, value)
    if checkcaller() and not SafeThread() then
        if typeof(self) == "Instance" and not Options.BypassList[self.ClassName] then
            PushToQueue(BuildRecord("PROPERTY_SET", self:GetFullName(), {Property = property, Value = value}, nil))
        end
    end
    return NativeNewIndex(self, property, value)
end)

setreadonly(RootMeta, true)

game:BindToClose(function()
    if #History > 0 then
        CommitLogs()
        task.wait(0.5)
    end
end)

Engine.Heartbeat:Connect(function()
    if #History >= (Options.BufferLimit / 2) then
        CommitLogs()
    end
end)

print("[Revamp Leaks] Engine active.")
