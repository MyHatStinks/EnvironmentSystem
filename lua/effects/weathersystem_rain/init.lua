
local function Collide(particle, hitpos, normal)
	for i2=1,2 do
		Splash = Weather.ParticleEmitter:Add("particle/snow", hitpos)
		Splash:SetLifeTime(0)
		Splash:SetDieTime(math.Rand(0.10, 0.50))
		Splash:SetStartSize(1)
		Splash:SetStartAlpha(255)
		Splash:SetEndAlpha(0)
		Splash:SetStartLength(5)
		Splash:SetEndLength(0)
		Splash:SetVelocity(Vector(0,0,10) + (VectorRand() * 5))
		Splash:SetGravity(Vector(0,0,-100))
		Splash:SetColor(200,200,250,200)
	end
	
	if(math.random(0,100) == 0) then
		sound.Play("ambient/water/rain_drip".. math.random(1,4) ..".wav", hitpos, 75, 100)
	end
	particle:SetDieTime(0)
end

function EFFECT:Init(data)
	local emitter = Weather and Weather.ParticleEmitter
	if not emitter then return end
	
	for i=0, 150 do
		local a = math.random(9999)
		local b = math.random(1,180)
		local distance = 2048
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
			particle:SetVelocity(Vector(math.random(-5,5),math.random(-5,5),-math.random(1500,2500)))
			particle:SetRoll(math.random(-360,360))
			particle:SetLifeTime(0)
			particle:SetDieTime(10 + math.Rand(-1,1))
			particle:SetStartAlpha(150)
			particle:SetEndAlpha(150)
			particle:SetStartSize(1)
			particle:SetEndSize(1)
			particle:SetStartLength( 10 )
			particle:SetEndLength( 10 )
			particle:SetAirResistance(50)
			particle:SetGravity(Vector(0,0,math.random(-100,-50)))
			particle:SetCollide(true)
			particle:SetCollideCallback(Collide)
			particle:SetBounce(0.01)
			particle:SetColor(220,220,250,200)
		end
	end
	emitter:Finish()
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end
