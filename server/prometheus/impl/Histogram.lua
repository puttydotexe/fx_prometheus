--[[
    fx_prometheus - Copyright (C) 2025 putty
    License: CC BY-NC-SA 4.0 (https://creativecommons.org/licenses/by-nc-sa/4.0/)
    https://p.utty.dev/
]]

Histogram = {}
Histogram.__index = Histogram

--[[
    Creates a new Histogram instance.
    
    @param name (string): The name of the histogram.
    @param help (string): The description of the histogram.
    @param buckets (table): A table of numeric bucket values defining the histogram's bucket ranges.
    
    @return (Histogram): A new Histogram instance with the specified name, help, buckets, and initial values.
    
    @throws (error): Throws an error if the name, help, or buckets are not valid.
]]--
function Histogram:new(name, help, buckets)
    -- Ensure the histogram name is a valid non-empty string.
    if type(name) ~= "string" or name == "" then
        error(string.format("Failed to call 'new' on Prometheus histogram '%s': Histogram name must be a non-empty string.", name))
    end

    -- Ensure the histogram help is a valid non-empty string.
    if type(help) ~= "string" or help == "" then
        error(string.format("Failed to call 'new' on Prometheus histogram '%s': Histogram help must be a non-empty string.", name))
    end

    -- Ensure buckets is a table and contains valid numeric values.
    if type(buckets) ~= "table" or #buckets == 0 then
        error(string.format("Failed to call 'new' on Prometheus histogram '%s': Buckets must be a non-empty table of numbers.", name))
    end

    -- Sort the buckets in ascending order for correct histogram calculation.
    table.sort(buckets)

    table.insert(buckets, math.huge)

    local struct = {
        __type = "Histogram",
        name = name,
        help = help,
        buckets = buckets,
        count = 0,
        sum = 0,
        bucket_counts = {}
    }

    -- Set the initial bucket count for each bucket to 0.
    for _, bucket in ipairs(buckets) do
        struct.bucket_counts[bucket] = 0
    end

    setmetatable(struct, self)

    return struct
end

--[[
    Observes a value and updates the histogram.
    
    @param value (number): The observed value to add to the histogram.
    
    @return (void): No return value.
    
    @throws (error): Throws an error if the value is not a valid number.
]]--
function Histogram:observe(value)
    -- Ensure the provided value is a valid number.
    if type(value) ~= "number" then
        error(string.format("Failed to call 'observe' on Prometheus histogram '%s': Value must be a number.", self.name))
    end

    -- Increment the buckets count of values recorded.
    self.count = self.count + 1

    -- Add the value to the buckets sum.
    self.sum = self.sum + value

    -- Increment the buckets counts based on the value.
    for _, bucket in ipairs(self.buckets) do
        if value <= bucket then
            self.bucket_counts[bucket] = self.bucket_counts[bucket] + 1
        end
    end
end

--[[
    Collects the current state of the histogram in the expected Prometheus exposition format.
    
    @return (string): A string representing the histogram in the Prometheus exposition format, including its name, help text, type, count, sum, and the bucket counts.
]]--
function Histogram:collect()
    local result = string.format("# HELP %s %s\n# TYPE %s histogram\n", self.name, self.help, self.name)

    result = result .. string.format("%s_count %d\n", self.name, self.count)
    result = result .. string.format("%s_sum %f\n", self.name, self.sum)

    for _, bucket in ipairs(self.buckets) do
        result = result .. string.format("%s_bucket{le=\"%f\"} %d\n", self.name, bucket, self.bucket_counts[bucket])
    end

    return result
end