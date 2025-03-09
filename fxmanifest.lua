--[[
    fx_prometheus - Copyright (C) 2025 putty
    License: CC BY-NC-SA 4.0 (https://creativecommons.org/licenses/by-nc-sa/4.0/)
    https://p.utty.dev/
]]--

fx_version "cerulean"
game "gta5"

author "putty <contact@utty.dev>"
description ""
version "1.0.0-SNAPSHOT"

lua54 "yes"
server_only "yes"

server_scripts {"server/prometheus/**.lua", "server/init.lua", "server/metric/**.lua"}