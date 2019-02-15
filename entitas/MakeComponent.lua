local table_insert  = table.insert
local table_remove  = table.remove

local function com_tostring(obj)
    local lua = ""
    local t = type(obj)
    if t == "number" then
        lua = lua .. obj
    elseif t == "boolean" then
        lua = lua .. tostring(obj)
    elseif t == "string" then
        lua = lua .. string.format("%q", obj)
    elseif t == "table" then
        lua = lua .. "{"

        local first = true
        for k, v in pairs(obj) do
            if not first  then
                lua = lua .. ","
            end
            lua = lua .. com_tostring(k) .. "=" .. com_tostring(v)
            first = false
        end
        lua = lua .. "}"
    elseif t == "nil" then
        return nil
    else
        error("can not tostring" .. t .. " type.")
    end
    return lua
end

--[[
    @desc: 这个函数的功能是在new component时给其中的全局变量赋值
    author:Tsai
    time:2019-02-14 21:21:50
    --@t:
	--@args: 
    @return:
]]
local function _replace(t, ... )
    for k, v in pairs(t._keys) do -- {"message"}
        local n = select(k,...)  -- k=1 v="message" n="HelloWorld"
        if not n then
            return
        end
        rawset(t,v,n)   -- rawset(真正的component, "message", "HelloWorld")
    end
end

local function _to_string( t )
    return "\t" .. t._name .. com_tostring(t)
end

local mt = {}
mt.__index = mt
mt.__tostring = function(t) return t._name end

local function make_component(name, ...)
    local tmp = {}
    tmp.__index = tmp
    tmp.__tostring = _to_string
    -- 这里的keys相当于一个component中包含的数据。
    -- 已DebugMessage为例，_keys = {"message"}，也就是说DebugMessage中有一个全局变量为message
    tmp._keys = {...} 
    tmp._name = name
    tmp._is = function(t) return t._name == name end
    tmp._replace = _replace
    tmp._cache = {}
    tmp.new = function(...)  -- 参数是"HelloWorld"
        -- 这里的操作是为了复用component对象。
        -- 下面有个release函数，一个component release后会加入到cache中。
        local tb = table_remove(tmp._cache) -- The default value for pos is #list, so that a call table.remove(l) removes the last element of list l.
        if not tb then
            tb = {}
            --print("create component",name)
            setmetatable(tb, tmp)
        end
        _replace(tb,...) --造成的结果就是{"message"="HelloWorld"}
        return tb
    end

    tmp.release = function(comp_value)
        assert(comp_value._name == name)
        table_insert(tmp._cache,comp_value)
    end

    setmetatable(tmp,mt)
    return tmp
end

-- 使用这个lua时最后返回的是一个function

return make_component
