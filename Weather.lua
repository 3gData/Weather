local Lighting = game:GetService("Lighting")
local TS = game:GetService("TweenService")
local RepStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Info = require(script.Utility)
local VisualSettings = require(script.VisualSettings)
local RainScript = RepStorage:FindFirstChild("Rain_Effect")

local Weathers = Info.Weathers
local Compatability = Info.Compatability

local LastWeather = "Storm"
local CurrentWeather = "Sunny"

local CurrTimeMinimums
local CurrTimeMaximums

local RainTarget = Instance.new("NumberValue")
local EffectsFinished = Instance.new("BindableEvent")

local WeatherRunning = false

local angularInfo = TweenInfo.new(
	20,
	Enum.EasingStyle.Sine,
	Enum.EasingDirection.Out,
	0,
	false,
	0
)

local StartWeatherFunctions = {
	Rain = function(v)
		task.wait(5)
		local pg = v:WaitForChild("PlayerGui",3)
		if pg and not pg:FindFirstChild("Rain_Effect") then
			
			local sc = RainScript:Clone()
			sc.Disabled = false
			sc.Parent = pg
			sc.Sound:Pause()
			sc.Sound.SoundId = "rbxassetid://2027808328"
			sc.Sound.Volume = 1
			local Rate = sc.Rate.Value
			RainTarget.Value = 15

			if Rate > 10 then
				for i = Rate,RainTarget.Value,-1 do
					if sc:FindFirstChild("Rate") == nil then break end
					sc:FindFirstChild("Rate").Value = i
					task.wait(.35)
				end
			else
				Rate = 0
				for i = Rate,RainTarget.Value,1 do
					if sc:FindFirstChild("Rate") == nil then break end
					sc:FindFirstChild("Rate").Value = i
					task.wait(.1)
				end
			end
		end
		task.wait(2)
		WeatherRunning = false
	end,	
}

local EndWeatherFunctions = {
	Rain = function(v)
		local pg = v:WaitForChild("PlayerGui",3)
		local sc = pg:FindFirstChild("Rain_Effect")
		
		if pg and sc then
			TS:Create(
				sc,TweenInfo.new(3),
				{Volume = 0}
			):Play()
			
			RainTarget.Value = CurrentWeather ~= "HeavyRain" and 0 or 20
			local step = RainTarget.Value < sc.Rate.Value and -1 or 1
			
			local Rate = sc.Rate
			for i = Rate.Value,RainTarget.Value,step do
				if sc == nil then return end
				Rate.Value = i
				task.wait(step == -1 and .5 or 1)
			end
		end
		EffectsFinished:Fire()
	end,
}

function calculateAverageWeatherTime()
	
	if Info.Limits[CurrentWeather] then
		CurrTimeMinimums = Info.Limits[CurrentWeather]['Minimum']
		CurrTimeMaximums = Info.Limits[CurrentWeather]['Maximum']
	else
		local source = CurrentWeather:split(":")
		local lm = 0
		local lmi = 0

		for i,v in pairs(source) do
			local infolimitsv  = Info.Limits[v]
			if infolimitsv.Maximum > lm then
				lm = infolimitsv.Maximum
			end

			if infolimitsv.Minimum < lmi then
				lmi = infolimitsv.Minumum
			end

		end

		CurrTimeMinimums = lmi*60
		CurrTimeMaximums = lm*60
		end
	end


function switchWeather(Forced)
	LastWeather = CurrentWeather
	
	repeat
		CurrentWeather = Forced or Info.getRandomWeather(LastWeather)
		task.wait()
	until CurrentWeather ~= LastWeather
	
	local DoesFunctionExist = false
	
	for _,W in pairs(LastWeather:split(":")) do
		if EndWeatherFunctions[W] ~= nil then
			for _,Player in pairs(Players:GetPlayers()) do
				local co = coroutine.create(EndWeatherFunctions[W])
				coroutine.resume(co,Player)
				DoesFunctionExist = true
			end
		end
	end

	if DoesFunctionExist then
		EffectsFinished.Event:Wait()
	end
	
	calculateAverageWeatherTime()
	
	local cwMatch,cwSplit = CurrentWeather:match(":"),CurrentWeather:split(":")
	
	local FirstW = cwMatch and cwSplit[1] or CurrentWeather
	local SecondW = cwMatch and cwSplit[2] or CurrentWeather
	
	local Settings = SecondW and VisualSettings.Tweens[FirstW][SecondW] or VisualSettings.Tweens[FirstW]
	
	if not Settings or next(Settings) == nil then
		warn("Settings inproperly configured for weather: "..CurrentWeather.."\n Exiting Function")
		WeatherRunning = false
		return 
	end
	
	local Parent = Lighting:FindFirstChildOfClass(Settings.Type)
	
	if Parent and Parent.Name:lower():match("weather") then
		for name,Property in pairs(Settings) do
			if type(name) == "string" and name ~= "Type" then
				coroutine.wrap(function()
					TS:Create(
						Parent,
						angularInfo,
						{[name] = Property}
					):Play()
				end)()
			end
		end
	end
	
	for i,Weather in pairs(cwSplit) do
		if StartWeatherFunctions[Weather] ~= nil then
			for i,Player in pairs(Players:GetPlayers()) do
				local co = coroutine.create(StartWeatherFunctions[Weather])
				coroutine.resume(co,Player)
			end
		end
	end
	
	EffectsFinished.Event:Wait()
end


while wait(.1) do
	if WeatherRunning == false then
		switchWeather()
		WeatherRunning = true
		wait(Random.new(math.randomseed(tick()*1e9)):NextNumber(CurrTimeMinimums,CurrTimeMaximums))
		WeatherRunning = false
	end
end