local module = {}

module.Weights = {
	Fog = 15,
	Rain = 40,
	Sunny = 75,
	HeavyRain = 15,
	Storm = 5
}

module.Limits = { -- How long weathers last
	Fog = {Minimum = 10,Maximum = 25},
	Rain = {Minimum = 15,Maximum = 20},
	HeavyRain = {Minimum = 15,Maximum = 20},
	Sunny = {Minimum = 20,Maximum = 40},
	Storm = {Minimum = 10,Maximum = 50}
}

module.Weathers = {
	"Fog",
	"Rain",
	"HeavyRain",
	"Sunny",
	"Storm"
}

module.Compatability = {
	Rain = "Fog",
	Fog = "Rain:HeavyRain",
	HeavyRain = "Fog:Storm",
	Storm = "HeavyRain:Rain",
}

local WeightTotal = 0

for i,v in pairs(module.Weights) do
	WeightTotal += v
end

function getTabCount(tab)
	local c = 0
	for i,v in pairs(tab) do
		c += 1
	end
	return c
end

function getIndName(tab,ind)
	local c = 0
	for i,v in pairs(tab) do
		c += 1
		if c == ind then
			return i
		end
	end
end

	
	function module.CheckCompatability(weather1,weather2)
		local compatible = false
		local found = ""
		
		if weather1:match(":") or weather2:match(":") then
			return
		end

		local checkagainst = module.Compatability[weather1]
		for i,v in pairs(checkagainst:split(":")) do
			if v == weather2 then
				compatible = true
			end
		end
		
		return compatible,weather1..":"..weather2
	end
	
	
	function module.getRandomWeather(last)
		local count = 0
		local rand = math.random(1,WeightTotal)
		
		local weather
		
			for i,v in next,module.Weights do
				count += v
				if rand <= count then
					weather = i
					break
				end
			end
		if math.random(1,100) < 7 then
			for i,v in pairs(module.Compatability) do
				if i ~= weather and i ~= last then
					local comp,found = module.CheckCompatability(i,weather)
					if comp ~= false and found ~= last then
						weather = found
						break
					end
				end
			end
		end
		return weather
	end
	


return module
