extends Node

const AUTHORNAME_MODNAME_LOG_NAME := "Avislime-Buzzshock:Config"

var config_file = "user://buzzshock_config.json"
var default_config_data = {
	"Connections":{
		"Multishock":
			{"Enabled": true,
			"Websocket": "ws://localhost:8765",
			"Authkey": "passkey",
			"Random Shocker": false},
		"Intiface":{
			"Enabled": true,
			"Websocket": "ws://127.0.0.1:12345"
		}
	},
	"Events":{
		"Shots":{
			"Player":{
				"Player shot Other; Live":
					{"Enabled": true,
					"Device": "pishock",
					"Action": "vibrate",
					"Intensity":40,
					"Duration":0.3},
				"Player shot Other; Sawed":
					{"Enabled": true,
					"Device": "pishock",
					"Action": "vibrate",
					"Intensity":75,
					"Duration":1},
				"Player shot Other; Blank":
					{"Enabled": true,
					"Device": "pishock",
					"Action": "vibrate",
					"Intensity":15,
					"Duration":0.3},
				"Player killed Other":
					{"Enabled": true,
					"Device": "pishock",
					"Action": "vibrate",
					"Intensity":100,
					"Duration":1},
				"Player shot Self; Live":
					{"Enabled": true,
					"Device": "pishock",
					"Action": "shock",
					"Intensity":3,
					"Duration":1},
				"Player shot Self; Sawed":
					{"Enabled": true,
					"Device": "pishock",
					"Action": "shock",
					"Intensity":5,
					"Duration":1},
				"Player shot Self; Blank":
					{"Enabled": true,
					"Device": "pishock",
					"Action": "vibrate",
					"Intensity":15,
					"Duration":0.3},
				"Player killed Self":
					{"Enabled": true,
					"Device": "pishock",
					"Action": "shock",
					"Intensity":8,
					"Duration":1}},
			"Other":
				{"Other shot Player; Live":
					{"Enabled": true,
					"Device": "pishock",
					"Action": "shock",
					"Intensity":3,
					"Duration":1},
				"Other shot Player; Sawed":
					{"Enabled": true,
					"Device": "pishock",
					"Action": "shock",
					"Intensity":5,
					"Duration":1},
				"Other shot Player; Blank":
					{"Enabled": false,
					"Device": "pishock",
					"Action": "vibrate",
					"Intensity":5,
					"Duration":0.3},
				"Other killed Player":
					{"Enabled": true,
					"Device": "pishock",
					"Action": "shock",
					"Intensity":8,
					"Duration":1},
				"Other shot Self; Live":
					{"Enabled": true,
					"Device": "pishock",
					"Action": "vibrate",
					"Intensity":10,
					"Duration":0.3},
				"Other shot Self; Sawed":
					{"Enabled": true,
					"Device": "pishock",
					"Action": "vibrate",
					"Intensity":20,
					"Duration":0.3},
				"Other shot Self; Blank":
					{"Enabled": false,
					"Device": "pishock",
					"Action": "vibrate",
					"Intensity":5,
					"Duration":0.3},
				"Other killed Self":
					{"Enabled": true,
					"Device": "pishock",
					"Action": "vibrate",
					"Intensity":35,
					"Duration":0.3},
				"Other shot Other; Live":
					{"Enabled": true,
					"Device": "pishock",
					"Action": "vibrate",
					"Intensity":10,
					"Duration":0.3},
				"Other shot Other; Sawed":
					{"Enabled": true,
					"Device": "pishock",
					"Action": "vibrate",
					"Intensity":20,
					"Duration":0.3},
				"Other shot Other; Blank":
					{"Enabled": false,
					"Device": "pishock",
					"Action": "vibrate",
					"Intensity":5,
					"Duration":0.3},
				"Other killed Other":
					{"Enabled": true,
					"Device": "pishock",
					"Action": "vibrate",
					"Intensity":35,
					"Duration":0.3}
				}
			},
		"Items":{
			"Handcuffs":{
				"Enabled": false,
				"Device": "pishock",
				"Action": "vibrate",
				"Intensity":10,
				"Duration":0.6},
			"Beer":{
				"Enabled": false,
				"Device": "pishock",
				"Action": "vibrate",
				"Intensity":10,
				"Duration":0.6},
			"Magnifying Glass":{
				"Enabled": false,
				"Device": "pishock",
				"Action": "vibrate",
				"Intensity":25,
				"Duration":0.3},
			"Cigarettes":{
				"Enabled": false,
				"Device": "pishock",
				"Action": "vibrate",
				"Intensity":25,
				"Duration":0.3},
			"Handsaw":{
				"Enabled": true,
				"Device": "pishock",
				"Action": "vibrate",
				"Intensity":25,
				"Duration":1.25},
			"Expired Medicine":
				{"Success":
					{"Enabled": false,
					"Device": "pishock",
					"Action": "shock",
					"Intensity":5,
					"Duration":0.3},
				"Fail":
					{"Enabled": true,
					"Device": "pishock",
					"Action": "shock",
					"Intensity":3,
					"Duration":0.3},
				"Death":
					{"Enabled": true,
					"Device": "pishock",
					"Action": "shock",
					"Intensity":5,
					"Duration":1}},
			"Inverter":{
				"Enabled": false,
				"Device": "pishock",
				"Action": "vibrate",
				"Intensity":25,
				"Duration":0.3},
			"Burner Phone":{
				"Enabled": false,
				"Device": "pishock",
				"Action": "vibrate",
				"Intensity":25,
				"Duration":0.3},
			"Adrenaline":{
				"Enabled": true,
				"Device": "pishock",
				"Action": "shock",
				"Intensity":1,
				"Duration":0.3},
			"Jammer":{
				"Enabled": false,
				"Device": "pishock",
				"Action": "vibrate",
				"Intensity":25,
				"Duration":0.3,
				"Jammed":{
					"Enabled": true,
					"Device": "pishock",
					"Action": "shock",
					"Intensity":1,
					"Duration":0.3}},
			"Remote":{
				"Enabled": false,
				"Device": "pishock",
				"Action": "vibrate",
				"Intensity":25,
				"Duration":0.3}
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
