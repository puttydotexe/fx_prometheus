--[[
    fx_prometheus - Copyright (C) 2025 putty
    License: CC BY-NC-SA 4.0 (https://creativecommons.org/licenses/by-nc-sa/4.0/)
    https://p.utty.dev/
]]--

MetricCollector = {}
MetricCollector.__index = MetricCollector

--[[
    Creates a new instance of a MetricCollector.

    @param name (string): The name of the metric collector.
    
    @return (MetricCollector): A new MetricCollector instance.
]]--
function MetricCollector:new(name, tickable)
    local struct = {
        __type = "MetricRegistery",
        name = name,
        tickable = tickable
    }

    setmetatable(struct, self)

    return struct
end

--[[
    Registers the metric collector.  
    This method must be implemented by child object.

    @throws (error): If not implemented in the child object.
]]--
function MetricCollector:register()
    error(string.format("Failed to call 'tick' on metric implementation '%s': Metric implementation does not define a register function.", name))
end

--[[
    Defines the logic that should run on every tick.  
    This method must be implemented by child object.

    @throws (error): If not implemented in the child object.
]]--
function MetricCollector:tick()
    if not self.tickable then return end

    error(string.format("Failed to call 'tick' on metric implementation '%s': Metric implementation was set to tickable however does not define a tick function.", name))
end