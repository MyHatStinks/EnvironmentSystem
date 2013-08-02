
local function Collide(particle, hitpos, normal)
	particle:SetEndAlpha(200)
	particle:SetStartSize(1)
	particle:SetEndSize(1)
	particle:SetDieTime(5)
end

function EFFECT:Init(data)
	local emitter = Weather and Weather.ParticleEmitter
	if not emitter then return end
	
	for i=0, 100 do
		local a = math.random(9999)
		local b = math.random(1,180)
		local distance = 1024--2048
		local x = math.sin(b)*math.sin(a)*distance
		local y = math.sin(b)*math.cos(a)*distance
		
		if not ((x>200 or x<-200) or (y>200 or y<-200)) then
			x = x + (x>0 and 200 or (-200))
			y = y + (y>0 and 200 or (-200))
		end
		
		local z = math.cos(b)*distance
		local offset = Vector(x,y, Weather.Height or 450)
		local spawnpos = LocalPlayer():GetPos() + offset
		local particle = emitter:Add("particle/snow.vmt", spawnpos)
		if (particle) then
			particle.Emitter = emitter
			particle:SetVelocity(Vector(math.random(-200,200),math.random(-200,200),-math.random(300,400)))
			particle:SetRoll(math.random(-360,360))
			particle:SetLifeTime(0)
			particle:SetDieTime(10 + math.Rand(-1,1))
			particle:SetStartAlpha(100)
			particle:SetEndAlpha(100)
			particle:SetStartSize(1)
			particle:SetEndSize(1)
			particle:SetAirResistance(50)
			particle:SetGravity(Vector(0,0,math.random(-100,-50)))
			particle:SetCollide(true)
			particle:SetCollideCallback(Collide)
			particle:SetBounce(0.01)
			particle:SetColor(255,255,255,150)
		end
	end
	emitter:Finish()
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end
