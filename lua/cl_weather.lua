-----------------
--Weather Sytem--
---Client File---
-----------------

local ActiveWeather = "sun"

local HUDEffects = CreateClientConVar( "weather_hud_effects", 1, true, false )
local Volume = CreateClientConVar( "weather_volume", 0.3, true, false )

Weather = Weather or {}

local function IsOutside()
	local pos = LocalPlayer():EyePos()
	local trace = util.TraceLine( {start = pos, endpos = pos+Vector(0,0,16384), mask=MASK_SOLID_BRUSHONLY} )
	
	Weather.Outside = (not trace.Hit) or trace.HitSky
	
	if Weather.Outside then
		Weather.Height = math.min( (trace.Hit and (trace.HitPos.z - trace.StartPos.z) or 800) - 20, 800 )
	else
		Weather.Height = math.max( (trace.Hit and (trace.HitPos.z - trace.StartPos.z) or 800) + 100, 400 )
	end
	return Weather.Outside
end

local ActiveRain, RainMax, RainMin
local HUDRainNextGenerate, HUDRainDrops, HUDCol = 0, {}, {}
local function PaintRain()
	local s = GAMEMODE:CalcView( LocalPlayer(), LocalPlayer():EyePos(), LocalPlayer():EyeAngles(), 75 );
	
	if (HUDEffects:GetBool()) and ActiveRain and ( IsOutside() and s.angles.p < 35 ) then
		if( CurTime() > HUDRainNextGenerate ) then
			HUDRainNextGenerate = CurTime() + math.Rand( 0.1, 0.4 )
			
			local t = { }
			t.x = math.random( 0, ScrW() )
			t.y = math.random( 0, ScrH() )
			t.r = math.random( RainMin, RainMax )
			t.c = CurTime();
			t.RainMat = surface.GetTextureID( ActiveRain )
			
			table.insert( HUDRainDrops, t )
		end
		
	end
	
	for k, v in pairs( HUDRainDrops ) do
		if( CurTime() - v.c > 1 ) then
			table.remove( HUDRainDrops, k );
			continue;
		end
		
		surface.SetDrawColor( HUDCol.r or 255, HUDCol.g or 255, HUDCol.b or 255, 255 * ( 1 - ( CurTime() - v.c ) ) );
		surface.SetTexture( v.RainMat );
		surface.DrawTexturedRect( v.x, v.y, v.r, v.r );
		
	end
end
hook.Add( "HUDPaint", "Weather System HUD Rain", PaintRain )

local ActiveSound, SoundFaded
local SoundCache = {}
local ActiveParticle
local nexttick, SoundLoop = 0, 0
local function ClientThink()
	if SoundCache[ActiveSound] then
		local sound = SoundCache[ActiveSound]
		if IsOutside() then
			if SoundFaded then
				sound:ChangeVolume(  tonumber(Volume:GetString())/5, 0 )
				sound:ChangeVolume( tonumber(Volume:GetString()), 1 )
				SoundFaded = false
				SoundLoop = CurTime() + SoundDuration( ActiveSound )
			elseif CurTime()>SoundLoop then
				sound:Play()
				sound:ChangeVolume( tonumber(Volume:GetString()), 0 )
				SoundFaded = false
				SoundLoop = CurTime() + SoundDuration( ActiveSound )
			elseif (not sound:IsPlaying()) then
				sound:Play()
				SoundLoop = CurTime() + SoundDuration( ActiveSound )
			end
		else
			if (not sound:IsPlaying()) or CurTime()>SoundLoop then
				sound:Play()
				sound:ChangeVolume( tonumber(Volume:GetString())/5, 0 )
				SoundLoop = CurTime() + SoundDuration( ActiveSound )
				SoundFaded = false
			elseif not SoundFaded then
				sound:ChangeVolume( tonumber(Volume:GetString())/5, 0 )
				SoundFaded = true
			end
		end
	end
	
	if ActiveParticle and (CurTime()>nexttick) then
		local particles = EffectData()
		util.Effect(ActiveParticle, particles)
		
		nexttick = CurTime()+0.25
	end
end
hook.Add( "Think", "Weather System Client Think", ClientThink )

net.Receive( "Weather System ChangeWeather", function()
	local weather = net.ReadString() or "sun"
	
	if (weather ~= ActiveWeather) and Weather.Effects[ActiveWeather].EndFunc then
		Weather.Effects[ActiveWeather]:EndFunc()
	end
	if Weather.Effects[weather].StartFunc then Weather.Effects[weather]:StartFunc() end
	
	ActiveWeather = weather
	ActiveParticle = Weather.Effects[weather].particle
	ActiveRain = Weather.Effects[weather].HUD
	if Weather.Effects[weather].HUDCol then
		HUDCol.r, HUDCol.g, HUDCol.b = unpack(Weather.Effects[weather].HUDCol)
	else HUDCol.r, HUDCol.g, HUDCol.b = 255, 255, 255 end
	
	RainMax, RainMin = Weather.Effects[weather].HUDMax or 50, Weather.Effects[weather].HUDMin or 120
	
	local OldActive = ActiveSound
	ActiveSound = Weather.Effects[weather].Sound
	if (ActiveSound ~= OldActive) then
		if SoundCache[ OldActive ] then
			SoundCache[ OldActive ]:FadeOut(1)
		end
		if ActiveSound then
			if not SoundCache[ActiveSound] then SoundCache[ActiveSound] = CreateSound( LocalPlayer(), Weather.Effects[weather].Sound ) end
			local sound = SoundCache[ActiveSound]
			
			if sound then
				sound:Play()
				sound:ChangeVolume( 0, 0 )
				sound:ChangeVolume( tonumber(Volume:GetString()), 1 )
				SoundLoop = CurTime() + SoundDuration( ActiveSound )
			end
			SoundFaded = false
		end
	end
end)
net.Receive( "Weather System Random Event", function()
	if Weather.Effects[ActiveWeather].RandomClientEffect then Weather.Effects[ActiveWeather]:RandomClientEffect() end
end)
local LightLevel = 1
net.Receive( "Weather System Update Lights", function()
	render.RedownloadAllLightmaps()
	
	local light = net.ReadInt( 8 )
	LightLevel = math.Clamp(1- (109-light)/20 ,0.2,1)
end)

hook.Add( "InitPostEntity", "Weather System Client Init", function()
	Weather.ParticleEmitter = ParticleEmitter( LocalPlayer():GetPos() )
	RunConsoleCommand( "weather_refresh" )
end)

local ColMod = {
	[ "$pp_colour_addr" ] = 0,
	[ "$pp_colour_addg" ] = 0,
	[ "$pp_colour_addb" ] = 0,
	[ "$pp_colour_brightness" ] = 0,
	[ "$pp_colour_contrast" ] = 1,
	[ "$pp_colour_colour" ] = 1,
	[ "$pp_colour_mulr" ] = 1,
	[ "$pp_colour_mulg" ] = 1,
	[ "$pp_colour_mulb" ] = 1
}
hook.Add( "RenderScreenspaceEffects", "WeatherSystem Client ScreenSpace", function()
	ColMod[ "$pp_colour_contrast" ] = LightLevel
	ColMod[ "$pp_colour_colour" ] = LightLevel
	--print( LightLevel )
	DrawColorModify( ColMod )
end)