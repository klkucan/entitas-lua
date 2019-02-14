local array = require("base.array")
local Collector = require("entitas.Collector")

local M = class("ReactiveSystem")

local function get_collector(self, context)
    local trigger = self:get_trigger()
    local groups = {}

    for _,one in pairs(trigger) do
        local matcher = one[1]
        local group_event = one[2]
        -- 从这可以看出每个group对应一个matcher
            -- 1.Context:get_group->group = Group.new(matcher)
            -- 2.tb._matcher = matcher; && tb.entities = set.new(true)。在Group的new函数中定一个table，也就是group。
        -- 这个group中包含一个_matcher，entities则是满足这个match的所有的entity。
        -- 添加entity的动作实在Group:handle_entity_silently函数中做的。它里面的核心是_matcher:match_entity。
        -- _matcher:match_entity内容详见Matcher.lua中的注释
        local group = context:get_group(matcher)
        -- 此处可见groups中只有一个kv的数据，k是刚才创建的group，v是事件。这这里是一个Added事件。
        groups[group] = group_event
        
        -- 总结来说group中包含了一个matcher，一个entities。前者用于过滤符合条件entity,后者保存这些entity。
    end
    -- Collector可以说是group的再次封装。
    return Collector.new(groups)
end

function M:ctor(context)
    self._collector = get_collector(self, context)
    self._entities = array.new(true)
end

function M:get_trigger()
    error(self.__cname.." 'get_trigger' not implemented")
end

function M:filter()
    error(self.__cname.." 'filter' not implemented")
end

function M:execute()
    error(self.__cname.." 'execute' not implemented")
end

function M:activate()
    self._collector:activate()
end

function M:deactivate()
    self._collector:deactivate()
end

function M:clear()
    self._collector:clear_entities()
end

function M:_execute()
    local entities = self._entities
    if self._collector.entities:size()>0 then
        self._collector.entities:foreach(function(entity)
            if self:filter(entity) then
                entities:push(entity)
            end
        end)

        self._collector:clear_entities()

        if entities:size() > 0 then
            self:execute(entities)
            entities:clear()
        end
    end
end

return M
