extends Node

const AUTHORNAME_MODNAME_LOG_NAME := "Avislime-Buzzshock:Config"

var config_file = "user://buzzshock_config.json"
var default_config_data = {
	"Connections": {
		"Multishock":
			{"Enabled": true,
			"Websocket": "ws://localhost:8765",
			"Authkey": ""},
	},
	"Events":{
		"Shots":{
			"Player":{
				"Player shot Other; Live":
					{"Enabled": true,
					"Action": "vibrate",
					"Intensity":40,
					"Duration":1,
					"Random Shocker": false},
				"Player shot Other; Sawed":
					{"Enabled": true,
					"Action": "vibrate",
					"Intensity":75,
					"Duration":1,
					"Random Shocker": false},
				"Player shot Other; Blank":
					{"Enabled": true,
					"Action": "vibrate",
					"Intensity":20,
					"Duration":0.3,
					"Random Shocker": false},
				"Player killed Other":
					{"Enabled": true,
					"Action": "vibrate",
					"Intensity":100,
					"Duration":1,
					"Random Shocker": false},
				"Player shot Self; Live":
					{"Enabled": true,
					"Action": "vibrate",
					"Intensity":25,
					"Duration":1,
					"Random Shocker": false},
				"Player shot Self; Sawed":
					{"Enabled": true,
					"Action": "vibrate",
					"Intensity":50,
					"Duration":1,
					"Random Shocker": false},
				"Player shot Self; Blank":
					{"Enabled": true,
					"Action": "vibrate",
					"Intensity":50,
					"Duration":0.3,
					"Random Shocker": false},
				"Player killed Self":
					{"Enabled": true,
					"Action": "vibrate",
					"Intensity":100,
					"Duration":1,
					"Random Shocker": false}},
			"Other":
				{"Other shot Player; Live":
					{"Enabled": true,
					"Action": "vibrate",
					"Intensity":40,
					"Duration":1,
					"Random Shocker": false},
				"Other shot Player; Sawed":
					{"Enabled": true,
					"Action": "vibrate",
					"Intensity":75,
					"Duration":1,
					"Random Shocker": false},
				"Other shot Player; Blank":
					{"Enabled": false,
					"Action": "vibrate",
					"Intensity":20,
					"Duration":0.3,
					"Random Shocker": false},
				"Other killed Player":
					{"Enabled": true,
					"Action": "vibrate",
					"Intensity":100,
					"Duration":1,
					"Random Shocker": false},
				"Other shot Self; Live":
					{"Enabled": true,
					"Action": "vibrate",
					"Intensity":25,
					"Duration":0.3,
					"Random Shocker": false},
				"Other shot Self; Sawed":
					{"Enabled": true,
					"Action": "vibrate",
					"Intensity":50,
					"Duration":0.3,
					"Random Shocker": false},
				"Other shot Self; Blank":
					{"Enabled": false,
					"Action": "vibrate",
					"Intensity":50,
					"Duration":0.3,
					"Random Shocker": false},
				"Other killed Self":
					{"Enabled": true,
					"Action": "vibrate",
					"Intensity":50,
					"Duration":0.3,
					"Random Shocker": false}
				}
			},
		"Items":{
			"Handcuffs":{
				"Enabled": false,
				"Action": "vibrate",
				"Intensity":10,
				"Duration":0.6,
				"Random Shocker": false},
			"Beer":{
				"Enabled": false,
				"Action": "vibrate",
				"Intensity":10,
				"Duration":0.6,
				"Random Shocker": false},
			"Magnifying Glass":{
				"Enabled": false,
				"Action": "vibrate",
				"Intensity":25,
				"Duration":0.3,
				"Random Shocker": false},
			"Cigarettes":{
				"Enabled": false,
				"Action": "vibrate",
				"Intensity":25,
				"Duration":0.3,
				"Random Shocker": false},
			"Handsaw":{
				"Enabled": true,
				"Action": "vibrate",
				"Intensity":25,
				"Duration":1.25,
				"Random Shocker": false},
			"Expired Medicine":
				{"Success":
					{"Enabled": false,
					"Action": "shock",
					"Intensity":5,
					"Duration":0.3,
					"Random Shocker": false},
				"Fail":
					{"Enabled": false,
					"Action": "shock",
					"Intensity":15,
					"Duration":0.3,
					"Random Shocker": false},
				"Death":
					{"Enabled": false,
					"Action": "shock",
					"Intensity":25,
					"Duration":1,
					"Random Shocker": false}},
			"Inverter":{
				"Enabled": false,
				"Action": "vibrate",
				"Intensity":25,
				"Duration":0.3,
				"Random Shocker": false},
			"Burner Phone":{
				"Enabled": false,
				"Action": "vibrate",
				"Intensity":25,
				"Duration":0.3,
				"Random Shocker": false},
			"Adrenaline":{
				"Enabled": true,
				"Action": "vibrate",
				"Intensity":25,
				"Duration":0.3,
				"Random Shocker": false}
			}
		}
	}

func LoadConfig():
	var config_data
	if FileAccess.file_exists(config_file):
		ModLoaderLog.debug("Buzzshock configuration found.", AUTHORNAME_MODNAME_LOG_NAME)
		var file = FileAccess.open(config_file, FileAccess.READ)
		config_data = JSON.parse_string(file.get_as_text())
		# Load data
		file.close()
	else:
		# No save file found. Creating fresh.
		ModLoaderLog.debug("Buzzshock configuration not found. Creating with defaults.", AUTHORNAME_MODNAME_LOG_NAME)
		var file = FileAccess.open(config_file, FileAccess.WRITE)
		var json = JSON.stringify(default_config_data, "\t", false)
		file.store_string(json)
		file.close()
		# Load default config data
		config_data = default_config_data
	return config_data
