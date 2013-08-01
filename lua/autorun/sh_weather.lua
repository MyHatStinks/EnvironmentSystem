-----------------
--Weather Sytem--
---Shared File---
-----------------

if SERVER then
	AddCSLuaFile()
	AddCSLuaFile( "sh_weather_blacklist.lua" )
	AddCSLuaFile( "cl_weather.lua" )
	
	include( "sh_weather_blacklist.lua" )
	include( "sv_weather.lua" )
	
	resource.AddSingleFile( "sound/weathereffects/wind2.wav" )
	resource.AddSingleFile( "materials/weathereffects/cloud_storm.vtf" )
	resource.AddSingleFile( "materials/weathereffects/cloud_storm2.vtf" )
elseif CLIENT then
	include( "sh_weather_blacklist.lua" )
	include( "cl_weather.lua" )
end

Weather = Weather or {}

Weather.Effects = {}
Weather.Effects["sun"] = { Clouds = nil, CSize = nil, Sound = nil, RandomEffect = nil, RandomClientEffect = nil, HUD = nil, particle = nil, StartFunc = nil, EndFunc = nil}
Weather.Effects["snow"] = { Clouds = "weathereffects/cloud_storm", CSize = 4, Sound = "coast.windmill", HUD = "Effects/splashwake1", HUDMax = 20, HUDMin = 40, particle = "weathersystem_snow", LightMod = (-2) }
Weather.Effects["rain"] = { Clouds = "weathereffects/cloud_storm2", CSize = 4, Sound = "ambient/water/water_flow_loop1.wav", HUD = "Effects/splash1", HUDCol = {200,200,255}, particle = "weathersystem_rain", LightMod = (-1) }
Weather.Effects["storm"] = { Clouds = "weathereffects/cloud_storm2", CSize = 4, Sound = "ambient/water/water_flow_loop1.wav", HUD = "Effects/splash2", HUDCol = {200,200,255}, particle = "weathersystem_storm", LightMod = (-2), RandomSounds = {"ambient/atmosphere/thunder1.wav", "ambient/atmosphere/thunder2.wav", "ambient/atmosphere/thunder3.wav", "ambient/atmosphere/thunder4.wav"},
	RandomClientEffect = function( self )
		timer.Simple( math.Rand(0, 1.5), function() surface.PlaySound( table.Random( self.RandomSounds ) ) end )
	end, RandomEffect = function()
		Weather.SkyPaint:SetKeyValue( "topcolor", "1 1 1" )
		Weather.SkyPaint:SetKeyValue( "bottomcolor", "1 1 1" )
		Weather.SkyPaint:SetKeyValue( "duskcolor", "1 1 1" )
		timer.Simple(0.1, function() Weather.PaintSky() end)
	end}
Weather.Effects["fog"] = { Clouds = nil, CSize = nil, Sound = nil, HUD = nil, particle = nil, LightMod = -1,
	StartFunc = function( self ) hook.Add("SetupWorldFog", "Weather Systems Fog", self.DoFog) hook.Add("SetupSkyboxFog", "Weather Systems Sky Fog", self.DoFog) end,
	EndFunc = function( self ) hook.Remove("SetupWorldFog", "Weather Systems Fog") hook.Remove("SetupSkyboxFog", "Weather Systems Sky Fog") end,
	DoFog = function(scale) render.FogMode( 1 ) render.FogStart( 0 ) render.FogEnd( 1000*(scale or 1) ) render.FogMaxDensity(0.7) render.FogColor(140,140,150) return true end}


local function WeatherSystemInit()
	if Weather.Blacklisted and Weather.Blacklisted.time then return end
	
	RunConsoleCommand( "sv_skyname", "painted" )
end
hook.Add( "Initialize", "Weather System Initialise", WeatherSystemInit )