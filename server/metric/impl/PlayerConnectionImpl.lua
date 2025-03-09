--[[
    fx_prometheus - Copyright (C) 2025 putty
    License: CC BY-NC-SA 4.0 (https://creativecommons.org/licenses/by-nc-sa/4.0/)
    https://p.utty.dev/
]]--

PlayerConnection = setmetatable({}, { __index = MetricCollector })
PlayerConnection.__index = PlayerConnection

function PlayerConnection:new(registery)
    local self = MetricCollector.new(self, "player_latency", true)

    self.latencyHistogram = Histogram:new("fx_prometheus_player_latency", "Player latency.", {10, 20, 50, 70, 100, 120, 150, 160, 200})
    self.averagePlayerLatency = Gauge:new("fx_prometheus_average_player_latency", "The average player latency as of current.")
    self.minPlayerLatency = Gauge:new("fx_prometheus_min_player_latency", "The highest player latency as of current.")
    self.maxPlayerLatency = Gauge:new("fx_prometheus_max_player_latency", "The lowest player latency as of current.")

    return self
end

function PlayerConnection:register(registery)
    registery:register(self.averagePlayerLatency)
    registery:register(self.latencyHistogram)
    registery:register(self.minPlayerLatency)
    registery:register(self.maxPlayerLatency)
end

function PlayerConnection:tick()
    local playerIndices = GetNumPlayerIndices()
    local cumulativeLatency = 0
    local minLatency = nil
    local maxLatency = nil
    
    -- Iterate through each player index.
    for playerIndex = 0, playerIndices - 1 do
        local player = GetPlayerFromIndex(playerIndex)
        local playerLatency = GetPlayerPing(player)
    
        -- Add the currently iterated players latency to the cumulative total.
        cumulativeLatency = cumulativeLatency + playerLatency
    
        -- Check if the currently iterated players latency is greater than the currently stored minimum.
        if minLatency == nil or minLatency > playerLatency then

            -- Update the currently stored minimum latency.
            minLatency = playerLatency
        end
    
        -- Check if the currently iterated players latency is greater than the currently stored maximum.
        if maxLatency == nil or maxLatency < playerLatency then

            -- Update the currently stored maximum latency.
            maxLatency = playerLatency
        end
    
        -- Add the currently iterated players latency to the latency histogram.
        self.latencyHistogram:observe(playerLatency)
    end

    if playerIndices > 0 then
        self.averagePlayerLatency:set(cumulativeLatency / playerIndices);
        self.minPlayerLatency:set(minLatency);
        self.maxPlayerLatency:set(maxLatency);
    else
        self.averagePlayerLatency:set(0);
        self.minPlayerLatency:set(0);
        self.maxPlayerLatency:set(0);
    end
end