--This script was originally by PreciousBeam (I think) But i have altered it to be big cool
local Settings = {
	
	Distortion		= true;
	
	Rate			= script:WaitForChild("Rate");
	
	Size			= 0.1;
	
	SizeRandomness	= true;
	SizeRandomNoise = 0.1;
		
	Tint			= false;
	TintColor				= Color3.fromRGB(111, 193, 255);
		
	FadeSpeed		= 1;
	
	Sound			= true;
	
	Theme			= "Preset";
		Themes					= {
					Preset = {1197357237, 1197356853, 1197357004, 1197356610, 1197356458, 1197357445, 1197357656, 1197358187, 1197358487, 1197357888};
					Custom = {}
		};
		
	PhysicalRain	= true;
		PhysicalRainWind		= Vector2.new(2,2);
		PhysicalRainRadius		= 75;
		Gusts					= false;
			GustsPerMin				= 15;
			GustsStrength			= 10;


}

local ContentProvider	= game:GetService("ContentProvider")
local TweenService		= game:GetService("TweenService")
local UserInputService	= game:GetService("UserInputService")
local RunService		= game:GetService("RunService")
local instance										= Instance.new
local brickcolor, color3, colorsequence				= BrickColor.new, Color3.fromRGB, ColorSequence.new
local numbersequence, numberrange					= NumberSequence.new, NumberRange.new
local cf, v3, v2, udim2, newray						= CFrame.new, Vector3.new, Vector2.new, UDim2.new, Ray.new
local pow, sin, cos, pi, sqrt, abs, asin, random	= math.pow, math.sin, math.cos, math.pi, math.sqrt, math.abs, math.asin, math.random
	
local Camera			= workspace.CurrentCamera 
local player			= game.Players.LocalPlayer	
local Distortion		= Settings.Distortion	
local Rate				= Settings.Rate
local Size				= Settings.Size
local SizeRandomness	= Settings.SizeRandomness
local SizeRandomNoise	= Settings.SizeRandomNoise
local Tint				= Settings.Tint
local TintColor			= Settings.TintColor
local FadeSpeed			= Settings.FadeSpeed
local Sound				= Settings.Sound
local ChosenTheme		= Settings.Theme
local Theme				= Settings.Themes[ChosenTheme]
local PhysicalRain		= Settings.PhysicalRain
local PhysicalRainWind	= Settings.PhysicalRainWind
local PhysicalRainRadius= Settings.PhysicalRainRadius
local Gusts				= Settings.Gusts
local GustsPerMin		= Settings.GustsPerMin
local GustsStrength		= Settings.GustsStrength

local Gusting			= false
local LastGust			= tick()

local mainGUI
local RainSound			= script.Sound
	RainSound.Looped	= true

local PartNum = 1
	
math.randomseed(tick())
	
if not Distortion then
	local Assets = {true}
	for i=1, #Theme do
		Assets[i] = ("rbxassetid://" .. Theme[i])
	end
	ContentProvider:PreloadAsync(Assets)
	wait()
	while ContentProvider.RequestQueueSize > 0 do
		print("Waiting for images to load...")
		wait()
	end
end

	delay(3,function()
		RainSound:Play()
	end)


if not Distortion then
	mainGUI = instance('ScreenGui')
		mainGUI.Name = 'RainGUI'
		mainGUI.Parent = player.PlayerGui
end

local function weldBetween(a, b)
	local weld	= Instance.new("Weld")
		weld.C0 = a.CFrame:inverse() * b.CFrame
		
		weld.Part0 = a
		weld.Part1 = b
	weld.Parent = a
	
	return weld
end

local function BoxPos(Origin, Radius)
	return cf(Origin +v3(random(-Radius, Radius), 50, random(-Radius, Radius)))
end

local function inSine(t, b, c, d)
	return -c * cos(t / d * (pi / 2)) + c + b
end

local function CreateSplash(Position)
	local Part = instance("Part")
		Part.Anchored		= true
		Part.CanCollide		= false
		Part.Transparency	= 1
		Part.Position		= Position - v3(0,0.5,0)
		Part.Name 			= 'SplashPart'
		Part.Size			= v3(1,1,1)
		
	local splashParticles = instance('ParticleEmitter')
		if Tint then
			splashParticles.Color 			= TintColor
		else
			splashParticles.Color 			= colorsequence(color3(187,234,255))
		end
		splashParticles.Size			= numbersequence(0,1.3)
		splashParticles.Texture 		= 'rbxassetid://241576804'
		splashParticles.Acceleration 	= v3(0,-30,0)
		splashParticles.Rotation		= numberrange(0,360)
		splashParticles.Lifetime 		= numberrange(0.4)
		splashParticles.Rate 			= 2
		splashParticles.Speed 			= numberrange(3)
	splashParticles.Parent			= Part
		
	Part.Parent = Camera
	game.Debris:AddItem(Part,2)
end

local function CreatePhysicalRain(OriginPoint)
	local Part	= instance("Part")
		Part.Name 			= 'RainPart'
		Part.TopSurface		= Enum.SurfaceType.Smooth
		Part.BottomSurface	= Enum.SurfaceType.Smooth
		Part.CanCollide		= false
		Part.Size			= Vector3.new(0.05, 1.5, 0.05)
		Part.Material		= Enum.Material.SmoothPlastic
		if Tint then
			Part.Color = TintColor
		else
			Part.Color = color3(111, 193, 255)
		end
	
		Part.CFrame			= BoxPos(OriginPoint, PhysicalRainRadius)
		Part.Orientation	= Vector3.new(PhysicalRainWind.X + random(-3,3), 0, PhysicalRainWind.Y + random(-3,3))
	
	local V		= instance('BodyVelocity')
		V.Velocity			= Part.CFrame.upVector * -150
		V.MaxForce			= v3(5000,5000,5000)
	V.Parent = Part
	
	delay(3,function()
		Part:Destroy()
	end)
	
	Part.Touched:Connect(function(hit)
		if not hit:IsDescendantOf(player.Character) and not hit:IsDescendantOf(Camera) then
			CreateSplash(Part.Position);
		end
		Part:Destroy()
	end)
	
	Part.Parent = workspace.CurrentCamera
	
	
end

local function createDistortionDroplet()
	local glass			= instance('Part')
		glass.CanCollide	= false
		glass.Material 		= 'Glass'
		glass.Name 			= 'Droplet_Main'
		glass.Transparency 	= 0.6
		glass.Shape 		= 'Ball'
	
	if Tint then
		glass.Color = TintColor
	else
		glass.Color = color3(200,200,220)
	end
	
	if SizeRandomness then
		local x 	= random(-SizeRandomNoise*10, SizeRandomNoise*10)/10
		glass.Size 	= v3(Size+x, Size+x, Size+x)
	else
		glass.Size 	= v3(Size, Size, Size)
	end
	
	local objectSpace = cf(random(-450,450)/100, random(-300,300)/100, -4)
	local function MoveDroplet()
		local screenSpace = Camera.CFrame:toWorldSpace(objectSpace)
		glass.CFrame = screenSpace
	end
	
	RunService:BindToRenderStep("DropletUpdate", Enum.RenderPriority.Camera.Value + 1, MoveDroplet)
	
	local tweens = {}
	local goal = {}
		goal.Transparency = 1
		local tweenInfo = TweenInfo.new(FadeSpeed+0.2, Enum.EasingStyle.Sine,  Enum.EasingDirection.In) 
		local tween = TweenService:Create(glass, tweenInfo, goal)
	
	glass.Parent = Camera
	
	tweens[#tweens+1] = tween
	for i=1, random(1,4) do
		local p2 = instance('Part')
		p2.CanCollide = false
		p2.Material = 'Glass'
		p2.Transparency = 0.6
		p2.Shape = 'Ball'
		p2.Name = 'Inner_Part'
		if Tint then
			p2.Color = TintColor
		else
			p2.Color = color3(200,200,220)
		end
		local v = random(-SizeRandomNoise*100, SizeRandomNoise*100)/100
		p2.Size = glass.Size+v3(v,v,v)
		p2.Parent = glass
		p2.CFrame = glass.CFrame+v3(random(-12,12)/100,random(-12,12)/100,0)
		weldBetween(p2, glass)
		local tween = TweenService:Create(p2, tweenInfo, goal)
		tweens[#tweens+1] = tween
		delay(FadeSpeed+0.2, function() p2:Destroy() end)
	end
	for i, t in pairs(tweens) do
		t:Play()
	end
	delay(FadeSpeed+0.2, function() glass:Destroy() end)
end

local function createDroplet()
local n = random(1, #Theme)
local Gui = instance("ImageLabel")
	Gui.AnchorPoint = v2(0.5,0.5)
	Gui.BackgroundTransparency = 1
	Gui.Position = udim2( (random(0,100)/100), 0, (random(0,100)/100), 0 )
	Gui.Rotation = random(0,360)
	Gui.Image = ("rbxassetid://"..Theme[n])
	if SizeRandomness then
		local x = random(-SizeRandomNoise, SizeRandomNoise)
		Gui.Size = udim2(
			0,
			Size+x,
			0,
			Size+x)
	else
		Gui.Size = udim2(0, Size, 0, Size)
	end
	if Tint then
		Gui.ImageColor3 = TintColor
	end
	Gui.Parent = mainGUI
	local goal = {}
		goal.ImageTransparency = 1
	local tweenInfo = TweenInfo.new(FadeSpeed+0.2, Enum.EasingStyle.Sine,  Enum.EasingDirection.In) 
	local tween = TweenService:Create(Gui, tweenInfo, goal)
	tween:Play()
	delay(FadeSpeed+0.2, function() Gui:Destroy() end)
end

while wait(1/Rate.Value) do
	if PhysicalRain then
		local dropRain		= coroutine.wrap(function()
			for i=1, Rate.Value*4 do
				CreatePhysicalRain(Camera.CFrame.p)
			end
		end)
		dropRain()
	end
	
	if Gusts and not Gusting and tick()-LastGust > (60/GustsPerMin) and random()>0.5 then
		Gusting				= true
		LastGust			= tick()
		local strength		= random(2,GustsStrength)
		local gustLength	= random(4,10)
		local begin			= v2(Settings.PhysicalRainWind.X, Settings.PhysicalRainWind.Y)
		local ending		= v2(Settings.PhysicalRainWind.X+strength, Settings.PhysicalRainWind.Y+strength)
		local Schange		= ending-begin
		local Echange		= begin-ending
		
		local blowGust		= coroutine.wrap(function()
			for i=1, 20 do
				wait(gustLength/20)
				PhysicalRainWind = v2(
					inSine(gustLength, begin.X, Schange.X, i/20),
					inSine(gustLength, begin.Y, Schange.Y, i/20)
					)
			end
			wait(0.1)
			for i=1, 20 do
				wait(gustLength/20)
				PhysicalRainWind = v2(
					inSine(gustLength, ending.X, (Echange.X), i/20),
					inSine(gustLength, ending.Y, (Echange.Y), i/20)
					)
			end
			Gusting			= false
		end)
		
		blowGust()
	end

	local ray					= newray(Camera.CFrame.p, Camera.CFrame.p+v3(0,3,0) * 70) 
 	local hit, position, normal = workspace:FindPartOnRay(ray, player.Character)

	if hit and hit.Transparency ~=1 and not hit:IsDescendantOf(Camera) then
		if Sound and RainSound.Volume ~= 0.7 then
			RainSound.Volume = 0.7
		end
		
	elseif not hit then
		if Sound and RainSound.Volume ~= 2 then
			RainSound.Volume = 2
		end

		if Camera.CFrame.lookVector.Y>.5 then
			if Distortion then
				createDistortionDroplet()
			else
				createDroplet()
			end
		end
	end
end
