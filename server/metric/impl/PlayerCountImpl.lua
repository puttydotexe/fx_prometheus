--[[
    fx_prometheus - Copyright (C) 2025 putty
    License: CC BY-NC-SA 4.0 (https://creativecommons.org/licenses/by-nc-sa/4.0/)
    https://p.utty.dev/
]]--

PlayerCount = setmetatable({}, { __index = MetricCollector })
PlayerCount.__index = PlayerCount

function PlayerCount:new(registery)
    local self = MetricCollector.new(self, "player_latency", true)

    self.playerDisconnections = Counter:new("fx_prometheus_player_disconnections", "The amount of player disconnections as of current.")
    self.playerConnections = Counter:new("fx_prometheus_player_connections", "The amount of player connections as of current.")
    self.playerCount = Gauge:new("fx_prometheus_player_count", "The amount of players connected as of current.")

    return self
end

function PlayerCount:register(registery)
    registery:register(self.playerDisconnections)
    registery:register(self.playerConnections)
    registery:register(self.playerCount)

    -- Register a new event handler to listen to player connections.
    AddEventHandler("playerConnecting", function(_, _, _)
        self.playerConnections:inc()
    end)

    -- Register a new event handler to listen to player disconnections.
    AddEventHandler("playerDropped", function(_, _)
        self.playerDisconnections:inc()
    end)
end

function PlayerCount:tick()
    self.playerCount:set(GetNumPlayerIndices())
end