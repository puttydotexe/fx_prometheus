--[[
    fx_prometheus - Copyright (C) 2025 putty
    License: CC BY-NC-SA 4.0 (https://creativecommons.org/licenses/by-nc-sa/4.0/)
    https://p.utty.dev/
]]--

Gauge = {}
Gauge.__index = Gauge

--[[
    Creates a new Gauge instance.
    
    @param name (string): The name of the gauge.
    @param help (string): The description of the gauge.
    
    @return (Gauge): A new Gauge instance with the specified name, help, and an initial value of 0.
    
    @throws (error): Throws an error if the name or help is either not provided or is an empty string.
]]--
function Gauge:new(name, help)
    -- Ensure the gauge name is a valid non-empty string.
    if type(name) ~= "string" or name == "" then
        error(string.format("Failed to call 'new' on Prometheus gauge '%s': Gauge name must be a non-empty string.", name))
    end

    -- Ensure the gauge help is a valid non-empty string.
    if type(help) ~= "string" or help == "" then
        error(string.format("Failed to call 'new' on Prometheus gauge '%s': Gauge help must be a non-empty string.", name))
    end

    local struct = {
        __type = "Gauge",
        name = name,
        help = help,
        value = 0
    }

    setmetatable(struct, self)

    return struct
end

--[[
    Sets the value of the gauge.
    
    @param value (number): The value to set the gauge to.
    
    @return (void): No return value.
    
    @throws (error): Throws an error if the provided value is not a number.
]]--
function Gauge:set(value)
    -- Ensure the provided value is a valid number.
    if type(value) ~= "number" then
        error(string.format("Failed to call 'set' on Prometheus gauge '%s': Gauge value must be a number.", self.name))
    end

    self.value = value
end

--[[
    Increments the value of the gauge by a specified amount.
    
    @param amount (number): The amount to increment the gauge value by or if not provided, defaults to 1.
    
    @return (void): No return value.
    
    @throws (error): Throws an error if the provided amount is not a number.
]]--
function Gauge:inc(amount)
    -- Ensure the provided increment is a valid number.
    if type(amount) ~= "number" then
        error(string.format("Failed to call 'inc' on Prometheus gauge '%s': Increment value must be a number.", self.name))
    end

    self.value = self.value + (amount or 1)
end

--[[
    Decrements the value of the gauge by a specified amount.
    
    @param amount (number): The amount to decrement the gauge value by or if not provided, defaults to 1.
    
    @return (void): No return value.
    
    @throws (error): Throws an error if the provided amount is not a number.
]]--
function Gauge:dec(amount)
    -- Ensure the provided decrement is a valid number.
    if type(amount) ~= "number" then
        error(string.format("Failed to call 'dec' on Prometheus gauge '%s': Decrement value must be a number.", self.name))
    end

    self.value = self.value - (amount or 1)
end

--[[
    Collects the current value of the gauge in the expected Prometheus exposition format.
    
    @return (string): A string representing the gauge in the Prometheus exposition format, including its name, help text, type, and current value.
]]--
function Gauge:collect()
    return string.format("# HELP %s %s\n# TYPE %s gauge\n%s %f\n", self.name, self.help, self.name, self.name, self.value)
end