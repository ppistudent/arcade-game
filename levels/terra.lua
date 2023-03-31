local level = require("level")
local terra = level:extend()

terra.spawn_variation = 25 
terra.spawn_rate = 20
terra.spawn_count = 15
terra.spawn_count_max = 58
terra.spawn_growth_factor = 0.11
terra.max_monsters_count = 80
terra.map = "middle" 
terra.require_score = 30000
terra.monsters_available = {
	"gob",
	"bat",
	"oneye",
	"woise",
	"fred",
	"mole",
	"meatboy"
}
terra.monsters_probability = {
	10,
	45,
	50,
	70,
	65,
	72,
	77
}

return terra
