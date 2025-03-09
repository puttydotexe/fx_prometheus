--[[
    fx_prometheus - Copyright (C) 2025 putty
    License: CC BY-NC-SA 4.0 (https://creativecommons.org/licenses/by-nc-sa/4.0/)
    https://p.utty.dev/
]]--

PrometheusRegistry = {}
PrometheusRegistry.__index = PrometheusRegistry

--[[
    Creates a new PrometheusRegistry instance with an optional name.
    
    @param name (string, optional): The name for the registry or if not provided, defaults to randomly generated name.
    
    @return (PrometheusRegistry): A new instance of PrometheusRegistry.
]]--
function PrometheusRegistry:new(name)
    local struct = {
        __type = "PrometheusRegistry",
        name = name or string.format("prometheus_registry_%d", math.random(100000, 999999)),
        metrics = {}
    }

    setmetatable(struct, self)

    return struct
end

--[[
    Registers a metric to the registry.
    
    @param metric (any): The metric to be registered (Gauge, Counter, Histogram).
    
    @return (void): No return value.
]]--
function PrometheusRegistry:register(metric)
    -- Define a list of valid metric types.
    local validMetricTypes = {
        Gauge = true,
        Counter = true,
        Histogram = true
    }

    -- Ensure there was a defined valid metric type for the to be registered metric.
    if not validMetricTypes[metric["__type"]] then
        error(string.format("Failed to call 'register' on PrometheusRegistry '%s': Incorrect metric type.", self.name))
    end

    table.insert(self.metrics, metric)
end

--[[
    Collects data from all registered metrics in the registry and returns it in the Prometheus exposition format.
    
    @return (string): A string representing the collected metrics in Prometheus exposition format, including the registry name and all metrics' data.
]]
function PrometheusRegistry:collect()
    local output = string.format("# Prometheus Registry: %s\n", self.name)

    -- Iterate through each metric and collect its data.
    for _, metric in ipairs(self.metrics) do
        output = output .. "\n" .. metric:collect()
    end

    return output
end