extends Node

# Weather System - Sistema de clima procedural (BONUS)

signal weather_changed(new_weather: String)

enum Weather {
	CLEAR,
	RAIN,
	STORM,
	FOG,
	ECLIPSE,
	BLOODMOON
}

var current_weather: Weather = Weather.CLEAR
var weather_seed: int = 0

# Efeitos do clima na gameplay
var weather_effects = {
	Weather.CLEAR: {
		"encounter_rate": 1.0,
		"visibility": 1.0,
		"damage_mod": 1.0
	},
	Weather.RAIN: {
		"encounter_rate": 0.7,
		"visibility": 0.8,
		"damage_mod": 0.9
	},
	Weather.STORM: {
		"encounter_rate": 1.5,
		"visibility": 0.6,
		"damage_mod": 1.2
	},
	Weather.FOG: {
		"encounter_rate": 1.3,
		"visibility": 0.4,
		"damage_mod": 1.0
	},
	Weather.ECLIPSE: {
		"encounter_rate": 2.0,
		"visibility": 0.5,
		"damage_mod": 1.5,
		"rare": true
	},
	Weather.BLOODMOON: {
		"encounter_rate": 3.0,
		"visibility": 0.7,
		"damage_mod": 2.0,
		"rare": true
	}
}

func initialize(seed: int):
	weather_seed = seed
	seed(weather_seed)

	# Escolhe clima baseado na seed
	var weather_roll = randf()

	if weather_roll < 0.02:  # 2% chance
		current_weather = Weather.BLOODMOON
	elif weather_roll < 0.05:  # 3% chance
		current_weather = Weather.ECLIPSE
	elif weather_roll < 0.15:  # 10% chance
		current_weather = Weather.STORM
	elif weather_roll < 0.30:  # 15% chance
		current_weather = Weather.FOG
	elif weather_roll < 0.50:  # 20% chance
		current_weather = Weather.RAIN
	else:  # 50% chance
		current_weather = Weather.CLEAR

	weather_changed.emit(get_weather_name())
	print("Weather: ", get_weather_name())

func get_weather_name() -> String:
	match current_weather:
		Weather.CLEAR: return "Clear Sky"
		Weather.RAIN: return "Rain"
		Weather.STORM: return "Storm"
		Weather.FOG: return "Fog"
		Weather.ECLIPSE: return "Eclipse"
		Weather.BLOODMOON: return "Blood Moon"
		_: return "Unknown"

func get_encounter_modifier() -> float:
	return weather_effects[current_weather].encounter_rate

func get_damage_modifier() -> float:
	return weather_effects[current_weather].damage_mod

func get_visibility() -> float:
	return weather_effects[current_weather].visibility

func is_rare_weather() -> bool:
	return weather_effects[current_weather].get("rare", false)
