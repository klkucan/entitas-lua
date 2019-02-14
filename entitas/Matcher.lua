local function string_components(components)
    if not components then
        return ""
    end
    local str = ""
    for _, v in pairs(components) do
        if #str > 0 then
            str = str .. ",\n"
        end

        if v then
            str = str .. tostring(v)
        end
    end
    return str
end

local function string_components_ex(components)
    if not components or #components == 0 then
        return ""
    end
    local str = ""
    for _, v in pairs(components) do
        if #str > 0 then
            str = str .. ","
        end

        if v then
            str = str .. tostring(v)
        end
    end
    return str
end


local M = {}

M.__index = M

M.__tostring = function(t)
    return string.format("<Matcher [all=({%s}) any=({%s}) none=({%s})]>",
        string_components(t._all),
        string_components(t._any),
        string_components(t._none)
)
end


function M:match_entity(entity)
    -- self._all是在调用Matcher(component)创建Matcher table时定义的
    -- 注意此处的self是一个Matcher
    -- has_all就是用entity的_components中的数据与self._all中所有的数据进行对比。
    -- 如果_all中出现任何一个不在_components中的数据就返回false
    local all_cond = not self._all or entity:has_all(self._all)
    -- 开始的原理都一样，只不过any的判断是只要存在一个就return true
    local any_cond = not self._any or entity:has_any(self._any)
    local none_cond = not self._none or not entity:has_any(self._none)

    --print(all_cond,any_cond,none_cond)
    return all_cond and any_cond and none_cond
end

local function components_eql( comps1, comps2 )
    for k,v in pairs(comps1) do
        if not comps2[k] or not comps2[k]._is(v) then
            return false
        end
    end
    return true
end

local function components_intersect( comps1, comps2 )
    for k,v in pairs(comps1) do
        if comps2[k] and comps2[k]._is(v) then
            return true
        end
    end
    return false
end

local function components_has( comps, comp )
    for _,v in pairs(comps) do
        if comp._is(v) then
            return true
        end
    end
    return false
end

function M:match(comps)
    local all_cond = not self._all or components_eql(self._all,comps)
    local any_cond = not self._any or components_intersect(self._any,comps)
    local none_cond = not self._none or not components_intersect(self._none,comps)

    --print(all_cond,any_cond,none_cond)
    return all_cond and any_cond and none_cond
end

function M:match_one(comp)
    local all_cond = not self._all or components_has(self._all,comp)
    local any_cond = not self._any or components_has(self._any,comp)
    local none_cond = not self._none or not components_has(self._none,comp)

    --print(all_cond,any_cond,none_cond)
    return all_cond and any_cond and none_cond
end

local matcher_cache = {}


-- 最终返回的是一个table，这个table包含_all\_any\_none，以及M中的方法
return function (all_of_tb, any_of_tb, none_of_tb)
    local key = string_components_ex(all_of_tb)..string_components_ex(any_of_tb)..string_components_ex(none_of_tb)
    local tb = matcher_cache[key]
    if not tb then
        tb = {_all = all_of_tb,_any =any_of_tb, _none = none_of_tb }
        matcher_cache[key] = setmetatable(tb, M)
    end
    return tb
end
