--[[
    fx_prometheus - Copyright (C) 2025 putty
    License: CC BY-NC-SA 4.0 (https://creativecommons.org/licenses/by-nc-sa/4.0/)
    https://p.utty.dev/
]]--

local FXPrometheus = {}

local function initialize()
    FXPrometheus["auth_hashing"] = GetConvar("fx_prometheus_auth_hashing", "false") ~= "false"
    FXPrometheus["auth_password"] = GetConvar("fx_prometheus_auth_password", "")
    FXPrometheus["prometheus_registery"] = PrometheusRegistry:new("fx_prometheus")
    FXPrometheus["prometheus_tick_rate"] = GetConvar("fx_prometheus_tick_rate", "30")

    -- Check if authentication is disabled and suggest to enable it.
    if FXPrometheus["auth_password"] == "" then
        print("^1Metric endpoint authentication is currently disabled, it is highly suggested that you enable it and set a password.^7")
    end

    -- Check if authentication is enabled however not using a bCrypt hash.
    if FXPrometheus["auth_password"] ~= "" and not FXPrometheus["auth_hashing"] then
        print("^1Metric endpoint authentication is enabled however using plain-text, it is highly suggest that you use a bCrypt hash.^7")
    end

    -- Check if the script name has been renamed.
    if GetCurrentResourceName() ~= "fx_promethus" then
        print("^1The resource name has been changed and as a result the endpoint used to fetch metrics will also be different!^7")
    end
end

local function registerMetrics()
    local playerConnectionMetric = PlayerConnection:new()
    local playerCountMetric = PlayerCount:new()

    playerConnectionMetric:register(FXPrometheus["prometheus_registery"])
    playerCountMetric:register(FXPrometheus["prometheus_registery"])

    CreateThread(function()
        while true do

            playerConnectionMetric:tick()
            playerCountMetric:tick()
            Wait(FXPrometheus["prometheus_tick_rate"] * 1000)
        end
    end)
end

local function registerHttpHandler()
    SetHttpHandler(function(request, response)
        -- Ensure the request was sent using the correct method.
        if request.method ~= "GET" then
            response.writeHead(405, {["Content-Type"] = "application/json"})
            response.send('{"error": "This endpoint only accepts GET requests."}')
            return
        end

        -- Check if authentication is enabled.
        if FXPrometheus["auth_password"] ~= "" then
            local authenticationHeader = request["headers"]["Authorization"]

            -- Ensure the request was sent with the required authentication header.
            if not authenticationHeader then
                response.writeHead(401, {["Content-Type"] = "application/json"})
                response.send('{"error": "Failed to authenticate request."}')
                return
            end

            -- Check if authentication hashing is enabled.
            if FXPrometheus["auth_hashing"] then

                -- Ensure the provided authentication header matches the configured hashed password.
                if not VerifyPasswordHash(authenticationHeader, FXPrometheus["auth_password"]) then
                    response.writeHead(401, {["Content-Type"] = "application/json"})
                    response.send('{"error": "Failed to authenticate request."}')
                    return
                end
            else
                -- Ensure the provided authentication header matches the configured authentication password.
                if authenticationHeader ~= FXPrometheus["auth_password"] then
                    response.writeHead(401, {["Content-Type"] = "application/json"})
                    response.send('{"error": "Failed to authenticate request."}')
                    return
                end
            end
        end

        response.writeHead(200, {["Content-Type"] = "text/plain"})
        response.send(FXPrometheus["prometheus_registery"]:collect())
    end)
end

CreateThread(function()
    initialize()
    registerMetrics()
    registerHttpHandler()
end)