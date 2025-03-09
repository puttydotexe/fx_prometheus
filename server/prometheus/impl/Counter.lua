--[[
    fx_prometheus - Copyright (C) 2025 putty
    License: CC BY-NC-SA 4.0 (https://creativecommons.org/licenses/by-nc-sa/4.0/)
    https://p.utty.dev/
]]

Counter = {}
Counter.__index = Counter

--[[
    Creates a new Counter instance.
    
    @param name (string): The name of the counter.
    @param help (string): The description of the counter.
    
    @return (Counter): A new Counter instance with the specified name, help, and an initial value of 0.
    
    @throws (error): Throws an error if the name or help is either not provided or is an empty string.
]]--
function Counter:new(name, help)
    -- Ensure the counter name is a valid non-empty string.
    if type(name) ~= "string" or name == "" then
        error(string.format("Failed to call 'new' on Prometheus counter '%s': Counter name must be a non-empty string.", name))
    end

    -- Ensure the counter help is a valid non-empty string.
    if type(help) ~= "string" or help == "" then
        error(string.format("Failed to call 'new' on Prometheus counter '%s': Counter help must be a non-empty string.", name))
    end

    local struct = {
        __type = "Counter",
        name = name,
        help = help,
        value = 0
    }

    setmetatable(struct, self)

    return struct
end

--[[
    Increments the value of the counter by a specified amount.
    
    @param amount (number): The amount to increment the counter value by or if not provided, defaults to 1.
    
    @return (void): No return value.
    
    @throws (error): Throws an error if the provided amount is not a number.
]]--
function Counter:inc(amount)
    -- Ensure the provided increment is a valid number.
    if type(amount) ~= "number" and not type(amount) == nil then
        error(string.format("Failed to call 'inc' on Prometheus counter '%s': Increment value must be a number.", self.name))
    end

    self.value = self.value + (amount or 1)
end

--[[
    Collects the current value of the counter in the expected Prometheus exposition format.
    
    @return (string): A string representing the counter in the Prometheus exposition format, including its name, help text, type, and current value.
    This string is typically used in HTTP responses or metric collection.
]]--
function Counter:collect()
    return string.format("# HELP %s %s\n# TYPE %s counter\n%s %f\n", self.name, self.help, self.name, self.name, self.value)
end