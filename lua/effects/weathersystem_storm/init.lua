
local function Collide(particle, hitpos, normal)
	particle:SetEndAlpha(0)
	particle:SetStartSize(1)
	particle:SetEndSize(1)
	particle:SetDieTime(0)
	particle.Emitter:Finish()
	
	--if Weather.Outside then 
	local Splash = EffectData() 
		Splash:SetStart(hitpos)
		Splash:SetOrigin(hitpos)
		Splash:SetColor(255,255,255,255)
		Splash:SetScale( math.random( 1,3 ) )
		Splash:SetFlags(0)
		--Splash:SetCollide(true)
		util.Effect( "watersplash", Splash )
	--end
end

function EFFECT:Init(data)
	local emitter = ParticleEmitter(LocalPlayer():GetPos())
	local PerfMode = (data:GetFlags(PerfMode) >= 1)
	local SubtleMode = (data:GetFlags(PerfMode) == 2)
	for i=0, SubtleMode and 35 or (PerfMode and 150) or 500 do
		local a = math.random(9999)
		local b = math.random(1,180)
		local distance = PerfMode and 1024 or 2048
		local x = math.sin(b)*math.sin(a)*distance
		local y = math.sin(b)*math.cos(a)*distance
		
		if not ((x>100 or x<-100) or (y>100 or y<-100)) then
			x = x + (x>0 and 100 or (-100))
			y = y + (y>0 and 100 or (-100))
		end
		
		local z = math.cos(b)*distance
		local offset = Vector(x,y, Weather.Height or 450)
		local spawnpos = LocalPlayer():GetPos() + offset
		local particle = emitter:Add("particle/rain.vmt", spawnpos)
		if (particle) then
			particle.Emitter = emitter
			particle:SetVelocity(Vector(math.random(450,470),math.random(-10,10),math.random(-1000,-1200)))
			particle:SetRoll(math.random(-360,360))
			particle:SetLifeTime(0)
			particle:SetDieTime(10 + math.Rand(-1,1))
			particle:SetStartAlpha(150)
			particle:SetEndAlpha(150)
			particle:SetStartSize(1)
			particle:SetEndSize(1)
			particle:SetAirResistance(50)
			particle:SetGravity(Vector(0,0,math.random(-100,-50)))
			particle:SetCollide(true)
			particle:SetCollideCallback(Collide)
			particle:SetBounce(0.01)
			particle:SetColor(170,170,250,120)
		end
	end
	emitter:Finish()
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end
