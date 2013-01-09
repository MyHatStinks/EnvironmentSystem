Weather = Weather or {}
Weather.Blacklist = {}

local b = Weather.Blacklist

--Insert Blacklist lines here
--b["map_name (without .bsp)"] = { time = [DisableTime, true/false], weather = [DisableWeather, true/false] }
b["example_map"] = {time = true, weather = true}

local map = game.GetMap()
Weather.Blacklisted = b[map]