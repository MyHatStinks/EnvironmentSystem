-----------------
--Weather Sytem--
---Server File---
-----------------

local paint //Sky Paint Entity
local Time = {h=0, m=0} //Time of Day 0000 - 2359
local NextTick = 0 //Next update
local TransitionRate = {top={0,0,0}, bot={0,0,0}, dusk={0,0,0}} //Rate of transition between each level
local TimeLighting = {}
local Clouds = {FadeValue = 1, Current = "skybox/starfield", Target = "skybox/starfield", Inactive = "skybox/starfield"}

TimeLighting[0] = { top={0,0,0}, bot={0,0,0}, dusk={0,0,0}, light = 99, cloud = "skybox/starfield", cscale = 1 }
TimeLighting[1] = { top={0,0,0}, bot={0,0,0}, dusk={0,0,0}, light = 99, cloud = "skybox/starfield", cscale = 1 }
TimeLighting[2] = { top={0,0,0}, bot={0,0,0}, dusk={0,0,0}, light = 99, cloud = "skybox/starfield", cscale = 1 }
TimeLighting[3] = { top={0,0,0}, bot={0,0,0}, dusk={0,0,0}, light = 99, cloud = "skybox/starfield", cscale = 1 }
TimeLighting[4] = { top={0,0,0}, bot={0,0,0}, dusk={0,0,0}, light = 99, cloud = "skybox/starfield", cscale = 1 }

TimeLighting[5] = { top={0, 0, 0}, bot={0, 0, 0}, dusk={0,0,0}, light = 100, cloud = "skybox/starfield", cscale = 1 }
TimeLighting[6] = { top={0, 0, 0}, bot={0.1, 0, 0}, dusk={0.2,0,0}, light = 102, cloud = "skybox/starfield", cscale = 1 }
TimeLighting[7] = { top={0.1, 0.1, 0.3}, bot={0.2, 0.1, 0}, dusk={0.2,0,0}, light = 104, cloud = "skybox/starfield", cscale = 1 }
TimeLighting[8] = { top={0.2, 0.35, 0.65}, bot={0.3, 0.15, 0.1}, dusk={0.1,0,0}, light = 106, cloud = "skybox/clouds", cscale = 3 }
TimeLighting[9] = { top={0.2, 0.45, 0.85}, bot={0.35, 0.25, 0.2}, dusk={0.1,0,0}, light = 107, cloud = "skybox/clouds", cscale = 3 }
TimeLighting[10] = { top={0.3, 0.5, 0.9}, bot={0.4, 0.55, 0.9}, dusk={0.05,0,0}, light = 108, cloud = "skybox/clouds", cscale = 3 }

TimeLighting[11] = { top={0.3, 0.5, 0.9}, bot={0.4, 0.5, 0.9}, dusk={0,0,0}, light = 109, cloud = "skybox/clouds", cscale = 3 }
TimeLighting[12] = { top={0.3, 0.5, 0.9}, bot={0.4, 0.5, 0.9}, dusk={0,0,0}, light = 109, cloud = "skybox/clouds", cscale = 3 }
TimeLighting[13] = { top={0.3, 0.5, 0.9}, bot={0.4, 0.5, 0.9}, dusk={0,0,0}, light = 109, cloud = "skybox/clouds", cscale = 3 }
TimeLighting[14] = { top={0.3, 0.5, 0.9}, bot={0.4, 0.5, 0.9}, dusk={0,0,0}, light = 109, cloud = "skybox/clouds", cscale = 3 }
TimeLighting[15] = { top={0.3, 0.5, 0.9}, bot={0.4, 0.5, 0.9}, dusk={0,0,0}, light = 109, cloud = "skybox/clouds", cscale = 3 }
TimeLighting[16] = { top={0.3, 0.5, 0.9}, bot={0.4, 0.5, 0.9}, dusk={0,0,0}, light = 108, cloud = "skybox/clouds", cscale = 3 }

TimeLighting[17] = { top={0.3, 0.5, 0.9}, bot={0.4, 0.55, 0.9}, dusk={0.05,0,0}, light = 107, cloud = "skybox/clouds", cscale = 3 }
TimeLighting[18] = { top={0.2, 0.45, 0.85}, bot={0.35, 0.25, 0.2}, dusk={0.1,0,0}, light = 105, cloud = "skybox/clouds", cscale = 3 }
TimeLighting[19] = { top={0.2, 0.35, 0.65}, bot={0.3, 0.15, 0.1}, dusk={0.1,0,0}, light = 103, cloud = "skybox/clouds", cscale = 3 }
TimeLighting[20] = { top={0.1, 0.1, 0.3}, bot={0.2, 0.1, 0}, dusk={0.2,0,0}, light = 101, cloud = "skybox/starfield", cscale = 1 }
TimeLighting[21] = { top={0, 0, 0}, bot={0, 0, 0}, dusk={0.1,0,0}, light = 99, cloud = "skybox/starfield", cscale = 1 }
TimeLighting[22] = { top={0, 0, 0}, bot={0, 0, 0}, dusk={0,0,0}, light = 99, cloud = "skybox/starfield", cscale = 1 }

TimeLighting[23] = { top={0,0,0}, bot={0,0,0}, dusk={0,0,0}, light = 99, cloud = "skybox/starfield" }

local flags = bit.bor( FCVAR_ARCHIVE, FCVAR_GAMEDLL, FCVAR_DEMO, FCVAR_CLIENTCMD_CAN_EXECUTE )
local UseSystemTime = CreateConVar( "weather_systemtime", 1, flags, "Whether the weather system should use the operating system clock. Default 1." ) //Use the system time
local DayLength = CreateConVar( "weather_daylength", 60, flags, "Length of a day in minutes. Only used if weather_systemtime is 0. Default 60." ) //Length of a day (minutes)
local UseRandom = CreateConVar( "weather_random", 1, flags, "Whether the weather system should use random weather. Default 1.") //Use the random weather system
local UseWeather = CreateConVar( "weather_default", "sun", flags, "Default weather. Only used if weather_random is 0. Default \"sun\".") //Default weather (For non-random)

Weather = Weather or {}

function Weather.PaintSky()
	if Weather.Blacklisted and Weather.Blacklisted.time then return end
	
	local ActiveColors = {}
	if TransitionRate and table.Count(TransitionRate)>0 then
		for _,n in pairs( {"top", "bot", "dusk"} ) do
			ActiveColors[n] = tostring(TimeLighting[Time.h][n][1]+(TransitionRate[n][1]* Time.m)).." "
			ActiveColors[n] = ActiveColors[n]..tostring(TimeLighting[Time.h][n][2]+(TransitionRate[n][2]*Time.m)).." "
			ActiveColors[n] = ActiveColors[n]..tostring(TimeLighting[Time.h][n][3]+(TransitionRate[n][3]*Time.m))
		end
	else
		for _,n in pairs( {"top", "bot", "dusk"} ) do
			ActiveColors[n] = tostring(TimeLighting[Time.h][n][1]).." "
			ActiveColors[n] = ActiveColors[n]..tostring(TimeLighting[Time.h][n][2]).." "
			ActiveColors[n] = ActiveColors[n]..tostring(TimeLighting[Time.h][n][3])
		end
	end
	if not paint then paint = Weather.SkyPaint end
	paint:SetKeyValue( "topcolor", ActiveColors["top"] )
	paint:SetKeyValue( "bottomcolor", ActiveColors["bot"] )
	paint:SetKeyValue( "duskcolor", ActiveColors["dusk"] )
	
	local y = UseSystemTime:GetBool() and 60 or ((DayLength:GetInt()/1440)*60) //Length of a tick
	local Seconds = 1-((NextTick-CurTime()) / y) //This isn't really seconds, but whatever
	
	local STime = Time.h*60 + Time.m + Seconds
	local normal = "0 0 0"
	if STime>300 and STime<1320 then
		local n = ((STime-380)/860)*2
		local x = (n<=1) and n or (2-n)
		normal = (n-1).." 0 "..x
		
		paint:SetKeyValue( "sunsize", 0.25 )
		paint:SetKeyValue( "suncolor", "1 1 0" )
	else
		if STime >=1320 then
			STime = STime-1440
		end
		local n = ((STime+100)/380)*2
		local x = (n<=1) and n or (2-n)
		normal = (n-1).." 0 "..x
		
		paint:SetKeyValue( "sunsize", 0.01 )
		paint:SetKeyValue( "suncolor", "1 1 1" )
	end
	paint:SetKeyValue( "sunposmethod", 0 )
	paint:SetKeyValue( "sunnormal", normal )
end

cvars.AddChangeCallback( "weather_systemtime", function( cvar, old, new )
	if new==1 then
		Time.h = tonumber( os.date( "%H" ) )
		Time.m = tonumber( os.date( "%M" ) )
	end
	
	NextTick = 0
end)
cvars.AddChangeCallback( "weather_daylength", function( cvar, old, new )
	NextTick = CurTime()+ ((tonumber(new)/1440)*60)
end)

util.AddNetworkString( "Weather System Update Lights" )
local function UpdateWeatherLighting()
	local weather = (Weather.Effects[Weather.Active or "sun"].LightMod or 0)
	local level = math.max( 98, TimeLighting[Time.h].light + weather )
	
	engine.LightStyle( 0, string.char(level) )
	timer.Simple(0.1, function()
		net.Start( "Weather System Update Lights" )
			net.WriteInt(TimeLighting[Time.h].light + weather, 8)
		net.Broadcast()
	end)
end

util.AddNetworkString( "Weather System Random Event" )
local function WeatherSystemRandomEffect()
	if Weather.Blacklisted and Weather.Blacklisted.weather then return false end
	
	if (not Weather.Active) or (not (Weather.Effects[Weather.Active].RandomEffect or Weather.Effects[Weather.Active].RandomClientEffect)) then 
		timer.Destroy( "Weather Systems Weather Effects" )
		return false
	end
	
	if Weather.Effects[Weather.Active].RandomEffect then Weather.Effects[Weather.Active]:RandomEffect() end
	if Weather.Effects[Weather.Active].RandomClientEffect then net.Start("Weather System Random Event") net.Broadcast() end
	
	local nextmin = Weather.Effects[Weather.Active].RandMin or 2
	local nextmax = Weather.Effects[Weather.Active].RandMax or nextmin+40
	
	timer.Create( "Weather Systems Weather Effects", math.random(nextmin, nextmax), 0, WeatherSystemRandomEffect )
	
	return true
end

util.AddNetworkString( "Weather System ChangeWeather" )
local function SetWeather( weather )
	if Weather.Blacklisted and Weather.Blacklisted.weather and weather~="sun" then return SetWeather("sun") end
	
	if not (weather and Weather.Effects[weather]) then return false end
	if (weather==Weather.Active) or ((not Weather.Active) and weather=="sun") then return false end
	
	if Weather.Active and Weather.Effects[Weather.Active].EndFunc then Weather.Effects[Weather.Active]:EndFunc() end
	
	Weather.Active = weather
	if weather=="sun" then
		Weather.Active = nil
		Clouds.Target = TimeLighting[Time.h].cloud
	else
		Clouds.Target = Weather.Effects[weather].Clouds or TimeLighting[Time.h].cloud
	end
	
	net.Start( "Weather System ChangeWeather" )
		net.WriteString( weather )
	net.Broadcast()
	
	if Weather.Active and Weather.Effects[Weather.Active].StartFunc then Weather.Effects[Weather.Active]:StartFunc() end
	if Weather.Active and (Weather.Effects[Weather.Active].RandomEffect or Weather.Effects[Weather.Active].RandomClientEffect) then
		timer.Create( "Weather Systems Weather Effects", math.random(2, 5), 0, WeatherSystemRandomEffect )
	end
	
	UpdateWeatherLighting()
	
	timer.Start( "Weather System Weather Selector"  ) --Restart the randomisation timer
	
	return true
end
Weather.SetWeather = SetWeather

function Weather.SetTime( h, m )
	m = m or 0
	
	if UseSystemTime:GetBool() then ServerLog( "Weather SetTime failed: System time is enabled!\n" ) return end
	
	local oh, om = Time.h, Time.m
	
	Time.h = h
	Time.m = m
	
	NextTick = CurTime()+ ((DayLength:GetInt()/1440)*60) //Next tick
	if oh~=h then
		UpdateWeatherLighting( TimeLighting[Time.h].light )
		if not Weather.Active then Clouds.Target = TimeLighting[Time.h].cloud end
		if Time.h>=23 then
			TransitionRate = table.Copy( TimeLighting[23] )
		else
			for _,n in pairs( {"top", "bot", "dusk"} ) do
				for k,v in pairs( TransitionRate[n] ) do
					TransitionRate[n][k] = ( TimeLighting[Time.h+1][n][k] - TimeLighting[Time.h][n][k])/60
				end
			end
		end
		
		hook.Call( "TimeOfDayHour", nil, Time.h )
		hook.Call( "TimeOfDayMinute", nil, Time.h, Time.m )
	elseif om~=m then
		hook.Call( "TimeOfDayMinute", nil, Time.h, Time.m )
	end
end

local function RandomKey(t) //Slightly modified table.Random function
  local rk = math.random( 1, table.Count( t ) )
  local i = 1
  for k, v in pairs(t) do 
	if ( i == rk ) then return k end
	i = i + 1 
  end
end
local function SelectWeather()
	if Weather.Blacklisted and Weather.Blacklisted.weather then return end
	
	if not UseRandom:GetBool() then
		--SetWeather( UseWeather:GetString() )
		return false
	end
	local rand = math.random(1,100)
	
	if rand<=5 then
		SetWeather( "sun" )
		return true
	elseif rand<=30 then
		return SetWeather( RandomKey( Weather.Effects ) )
	else
		return false
	end
end

local function WeatherSystemInitPostEntity()
	if not (Weather.Blacklisted and Weather.Blacklisted.time) then
		//Erase interfering entities
		for _,v in pairs( ents.FindByClass( "env_skypaint" ) ) do v:Remove() end
		for _,v in pairs( ents.FindByClass( "env_sun" ) ) do v:Remove() end
		
		//Create our skypaint
		paint = ents.Create( "env_skypaint" )
		paint:Spawn()
		Weather.SkyPaint = paint
		
		//Get the current time
		Time.h = tonumber( os.date( "%H" ) )
		Time.m = tonumber( os.date( "%M" ) )
		
		if Time.h>=23 then
			TransitionRate = table.Copy( TimeLighting[23] )
		else
			for _,n in pairs( {"top", "bot", "dusk"} ) do
				for k,v in pairs( TransitionRate[n] ) do
					TransitionRate[n][k] = ( TimeLighting[Time.h+1][n][k] - TimeLighting[Time.h][n][k])/60
				end
			end
		end
	end
	
	if not (Weather.Blacklisted and Weather.Blacklisted.weather) then
		UpdateWeatherLighting() //Set the lighting
		
		if not UseRandom:GetBool() then
			SetWeather( UseWeather:GetString() )
		end
		SelectWeather()
		timer.Create( "Weather System Weather Selector", 120, 0, SelectWeather )
	end
	
	//Set the next tick to Now
	NextTick = 0
end
hook.Add( "InitPostEntity", "Weather System PostEntity", WeatherSystemInitPostEntity )

local function TimeOfDay()
	if Weather.Blacklisted and Weather.Blacklisted.time then return end
	//Clouds //{
		if Clouds.Target ~= Clouds.Current then
			if Clouds.FadeValue > 0 then
				Clouds.FadeValue = math.Approach( Clouds.FadeValue, 0, 0.05 )
			else
				Clouds.Current = Clouds.Target
			end
		elseif Clouds.FadeValue < 1 then
			Clouds.FadeValue = math.Approach( Clouds.FadeValue, 1, 0.05)
		end
		local cscale = Weather.Active and (Weather.Effects[Weather.Active].CSize or 1) or TimeLighting[Time.h].cscale or 1
		
		if not paint then paint = Weather.SkyPaint end
		paint:SetKeyValue( "starfade", Clouds.FadeValue )
		paint:SetKeyValue( "startexture", Clouds.Current )
		paint:SetKeyValue( "starscale", cscale or 1 )
		paint:SetKeyValue( "starspeed", Weather.Active and Weather.Effects[Weather.Active].CScroll or 0.01 )
	//}
	
	Weather.PaintSky()
	
	if CurTime()<NextTick then return end //Should we work?
	if UseSystemTime:GetBool() then
		NextTick = CurTime()+60
		local oh, om = Time.h, Time.m
		
		Time.h = tonumber( os.date( "%H" ) )
		Time.m = tonumber( os.date( "%M" ) )
		
		if oh ~= Time.h then
			hook.Call( "TimeOfDayHour", nil, Time.h )
			hook.Call( "TimeOfDayMinute", nil, Time.h, Time.m )
			
			UpdateWeatherLighting( TimeLighting[Time.h].light )
			if not Weather.Active then Clouds.Target = TimeLighting[Time.h].cloud end
			if Time.h>=23 then
				TransitionRate = table.Copy( TimeLighting[23] )
			else
				for _,n in pairs( {"top", "bot", "dusk"} ) do
					for k,v in pairs( TransitionRate[n] ) do
						TransitionRate[n][k] = ( TimeLighting[Time.h+1][n][k] - TimeLighting[Time.h][n][k])/60
					end
				end
			end
		elseif om ~= Time.m then
			hook.Call( "TimeOfDayMinute", nil, Time.h, Time.m )
		end
	else
		NextTick = CurTime()+ ((DayLength:GetInt()/1440)*60) //Next tick
		
		Time.m = Time.m+1 //Add a minute
		
		if Time.m >= 60 then //We're over the top
			Time.h = Time.h+1 //Add an hour
			Time.m = 0 //Reset minutes
			
			if Time.h>=24 then
				Time.h = 0 //We're over the top, reset hours
			end
			
			UpdateWeatherLighting( TimeLighting[Time.h].light )
			if not Weather.Active then Clouds.Target = TimeLighting[Time.h].cloud end
			
			if Time.h>=23 then
				TransitionRate = table.Copy( TimeLighting[23] )
			else
				for _,n in pairs( {"top", "bot", "dusk"} ) do
					for k,v in pairs( TransitionRate[n] ) do
						TransitionRate[n][k] = ( TimeLighting[Time.h+1][n][k] - TimeLighting[Time.h][n][k])/60
					end
				end
			end
			
			hook.Call( "TimeOfDayHour", nil, Time.h )
		end
		hook.Call( "TimeOfDayMinute", nil, Time.h, Time.m )
	end
end
hook.Add( "Think", "Weather System TimeOfDay Think", TimeOfDay )

concommand.Add( "weather_refresh", function( ply, c, a )
	if ply and IsValid( ply ) then
		net.Start( "Weather System ChangeWeather" )
			net.WriteString( Weather.Active or "sun" )
		net.Send( ply )
		
		local weather = (Weather.Effects[Weather.Active or "sun"].LightMod or 0)
		net.Start( "Weather System Update Lights" )
			net.WriteInt(TimeLighting[Time.h].light + weather, 8)
		net.Send( ply )
	end
end)
concommand.Add( "weather_force", function( ply, c, a )
	if IsValid(ply) and not ply:IsSuperAdmin() then return end
	
	if a[1] then
		SetWeather( a[1] )
	end
end)
concommand.Add( "weather_rand", function( ply, c, a )
	if IsValid(ply) and not ply:IsSuperAdmin() then return end
	
	if SetWeather( RandomKey( Weather.Effects ) ) then
		if IsValid( ply ) then ply:ChatPrint( "Randomise successful" ) else print( "Randomise successful" ) end
	else
		if IsValid( ply ) then ply:ChatPrint( "Randomise failed" ) else print( "Randomise failed" ) end
	end
end)

local PhraseToHour = {
	["midnight"] = 1,
	["dawn"] = 6,
	["day"] = 8,
	["noon"] = 12,
	["dusk"] = 19,
	["night"] = 21,
}
concommand.Add( "weather_time", function( ply, c, a )
	if IsValid(ply) and not ply:IsSuperAdmin() then return end
	if not a then return end
	
	local h,m = tonumber(a[1]), tonumber(a[2])
	if (not h) or (h<0) or (h>23) then
		h = PhraseToHour[ string.lower(tostring(a[1])) ]
		if h then
			Weather.SetTime( h, m )
		else
			if IsValid( ply ) then ply:ChatPrint( "Set Time failed, invalid time" ) else print( "Set Time failed, invalid time" ) end
			return
		end
	end
	
	Weather.SetTime( h, m )
end)