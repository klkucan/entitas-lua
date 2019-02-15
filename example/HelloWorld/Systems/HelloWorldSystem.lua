local Components = require('example.HelloWorld.Components')

local HelloWorldSystem = class("HelloWorldSystem")

function HelloWorldSystem:ctor(context)
    self.context = context
end

function HelloWorldSystem:initialize()
    --create an entity and give it a DebugMessageComponent with
    --the text "Hello World!" as its data
    local entity = self.context:create_entity()
    -- 这里相当于创建一个DebugMessage class，message的值为"HelloWorld"
    -- 但是如果多次调用这个add呢？似乎会频繁创建DebugMessage class
    entity:add(Components.DebugMessage,"HelloWorld")
end


return HelloWorldSystem