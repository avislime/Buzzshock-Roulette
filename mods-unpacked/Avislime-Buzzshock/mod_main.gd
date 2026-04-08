extends Node

const AUTHORNAME_MODNAME_DIR := "Avislime-Buzzshock"
const AUTHORNAME_MODNAME_LOG_NAME := "Avislime-Buzzshock:Main"

var mod_dir_path := ""
var extensions = ["extensions/DealerIntelligence.gd",
				  "extensions/DeathManager.gd",
				  "extensions/ItemInteraction.gd",
				  "extensions/MedicineManager.gd",
				  "extensions/ShotgunShooting.gd"]
var config_data = {}
var ConfigManager = load("res://mods-unpacked/Avislime-Buzzshock/config_manager.gd").new()

var socket_multishock = WebSocketPeer.new()
var url_multishock = ""
var authkey_multishock = ""
var devices

var is_multishock_connected = false
var is_intiface_connected = false

func _init() -> void:
	ModLoaderLog.debug("Buzzshock Init.", AUTHORNAME_MODNAME_LOG_NAME)
	mod_dir_path = ModLoaderMod.get_unpacked_dir()+(AUTHORNAME_MODNAME_DIR)+"/"
	# Load Extensions
	for extension in extensions:
		ModLoaderMod.install_script_extension(mod_dir_path + extension)

# Called when the node enters the scene tree for the first time.
func _ready():
	ModLoaderLog.debug("Hello world!", AUTHORNAME_MODNAME_LOG_NAME)
	config_data = ConfigManager.LoadConfig()
	authkey_multishock = config_data["Connections"]["Multishock"]["Authkey"]
	url_multishock = config_data["Connections"]["Multishock"]["Websocket"]
	# Initiate websocket connection to multishock.
	if config_data["Connections"]["Multishock"]["Enabled"]:
		ModLoaderLog.debug("Connecting to '%s' with authkey '%s'" % [url_multishock, authkey_multishock], AUTHORNAME_MODNAME_LOG_NAME)
		var err = socket_multishock.connect_to_url(url_multishock)
		# Wait for connection to establish.
		if err == OK:
			await get_tree().create_timer(2).timeout
			if socket_multishock.get_ready_state() == WebSocketPeer.STATE_OPEN:
				ModLoaderLog.success("Connected to Multishock.", AUTHORNAME_MODNAME_LOG_NAME)
				is_multishock_connected = true
				MultishockGetDevices()
			else:
				ModLoaderLog.warning("Failed to connect to Multishock, Timed out.", AUTHORNAME_MODNAME_LOG_NAME)
				is_multishock_connected = false
		else:
			ModLoaderLog.warning("Failed to connect to Multishock.", AUTHORNAME_MODNAME_LOG_NAME)
			is_multishock_connected = false
	else:
		ModLoaderLog.info("Multishock is disabled in config.", AUTHORNAME_MODNAME_LOG_NAME)		

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	socket_multishock.poll()
	if is_multishock_connected:
		var state = socket_multishock.get_ready_state()
		if state == WebSocketPeer.STATE_OPEN:
			while socket_multishock.get_available_packet_count():
				var packet = socket_multishock.get_packet()
				if socket_multishock.was_string_packet():
					var packet_text = packet.get_string_from_utf8()
					ModLoaderLog.debug("Got string data: %s" % packet_text,  AUTHORNAME_MODNAME_LOG_NAME)
					MultishockProcessDevices(packet_text)
				else:
					ModLoaderLog.debug("Got binary data: %d bytes" % packet.size(), AUTHORNAME_MODNAME_LOG_NAME)
		
		elif state == WebSocketPeer.STATE_CLOSING:
			pass
		
		elif state == WebSocketPeer.STATE_CLOSED:
			var code = socket_multishock.get_close_code()
			ModLoaderLog.debug("WebSocket closed with code: %d. Clean: %s" % [code, code != -1], AUTHORNAME_MODNAME_LOG_NAME)
			is_multishock_connected = false
		pass

func BuzzshockEvent(case):
	ModLoaderLog.debug("Buzzshock event called: %s" % case, AUTHORNAME_MODNAME_LOG_NAME)
	var event = {"Enabled": false,
				 "Intensity": 50,
				 "Duration": 1,
				 "Action": "vibrate",
				 "Random Shocker": false}
	match(case):
		# Grab event command parameters from config
		"Test":
			MultishockCommand(25, 1, "all", "vibrate")
		"PlayerShotDealer":
			event = config_data["Events"]["Shots"]["Singleplayer"]["Player"]["Player shot Dealer; Live"]
		"PlayerShotDealerSawed":
			event = config_data["Events"]["Shots"]["Singleplayer"]["Player"]["Player shot Dealer; Sawed"]
		"PlayerShotDealerBlank":
			event = config_data["Events"]["Shots"]["Singleplayer"]["Player"]["Player shot Dealer; Blank"]
		"PlayerKilledDealer":
			event = config_data["Events"]["Shots"]["Singleplayer"]["Player"]["Player killed Dealer"]
		"PlayerShotSelf":
			event = config_data["Events"]["Shots"]["Singleplayer"]["Player"]["Player shot Self; Live"]
		"PlayerShotSelfSawed":
			event = config_data["Events"]["Shots"]["Singleplayer"]["Player"]["Player shot Self; Sawed"]
		"PlayerShotSelfBlank":
			event = config_data["Events"]["Shots"]["Singleplayer"]["Player"]["Player shot Self; Blank"]
		"PlayerKilledSelf":
			event = config_data["Events"]["Shots"]["Singleplayer"]["Player"]["Player killed Self"]
		"DealerShotPlayer":
			event = config_data["Events"]["Shots"]["Singleplayer"]["Dealer"]["Dealer shot Player; Live"]
		"DealerShotPlayerSawed":
			event = config_data["Events"]["Shots"]["Singleplayer"]["Dealer"]["Dealer shot Player; Sawed"]
		"DealerShotPlayerBlank":
			event = config_data["Events"]["Shots"]["Singleplayer"]["Dealer"]["Dealer shot Player; Blank"]
		"DealerKilledPlayer":
			event = config_data["Events"]["Shots"]["Singleplayer"]["Dealer"]["Dealer killed Player"]
		"DealerShotSelf":
			event = config_data["Events"]["Shots"]["Singleplayer"]["Dealer"]["Dealer shot Self; Live"]
		"DealerShotSelfSawed":
			event = config_data["Events"]["Shots"]["Singleplayer"]["Dealer"]["Dealer shot Self; Sawed"]
		"DealerShotSelfBlank":
			event = config_data["Events"]["Shots"]["Singleplayer"]["Dealer"]["Dealer shot Self; Blank"]
		"DealerKilledSelf":
			event = config_data["Events"]["Shots"]["Singleplayer"]["Dealer"]["Dealer killed Self"]
		"Handcuffs":
			event = config_data["Events"]["Items"]["Handcuffs"]
		"Beer":
			event = config_data["Events"]["Items"]["Beer"]
			await get_tree().create_timer(0.5).timeout
		"Magnifying Glass":
			event = config_data["Events"]["Items"]["Magnifying Glass"]
		"Cigarettes":
			event = config_data["Events"]["Items"]["Cigarettes"]
			await get_tree().create_timer(1).timeout
		"Handsaw":
			event = config_data["Events"]["Items"]["Handsaw"]
			await get_tree().create_timer(0.75).timeout
		"MedicineSucceed":
			event = config_data["Events"]["Items"]["Expired Medicine"]["Succeed"]
		"MedicineFail":
			event = config_data["Events"]["Items"]["Expired Medicine"]["Fail"]
		"MedicineDeath":
			event = config_data["Events"]["Items"]["Expired Medicine"]["Death"]
		"Inverter":
			event = config_data["Events"]["Items"]["Inverter"]
			await get_tree().create_timer(1.5).timeout
		"Burner Phone":
			event = config_data["Events"]["Items"]["Burner Phone"]
			await get_tree().create_timer(4).timeout
		"Adrenaline":
			event = config_data["Events"]["Items"]["Adrenaline"]
			await get_tree().create_timer(3.25).timeout
	if event["Enabled"]:
		ModLoaderLog.debug("Sending command: %s at %s percent, %s seconds." % 
						   [case, event["Action"], event["Intensity"], event["Duration"]],
						   AUTHORNAME_MODNAME_LOG_NAME)
		MultishockCommand(event["Intensity"], event["Duration"],
		"random" if event["Random Shocker"] else "all", event["Action"])

func MultishockGetDevices():
	socket_multishock.send_text(JSON.stringify({"auth_key": authkey_multishock, "cmd": "get_devices"}))

func MultishockProcessDevices(response):
	ModLoaderLog.debug("Processing device list", AUTHORNAME_MODNAME_LOG_NAME)
	var json_data = JSON.parse_string(response)
	var shockerids = []
	for user in json_data:
		var shockernames = []
		for shocker in user["shockers"]:
			shockernames.append(shocker["name"])
			shockerids.append(shocker["identifier"])
		ModLoaderLog.debug("User: %s (%s), shockers: %s" % [user["name"], user["id"], ", ".join(shockernames)], AUTHORNAME_MODNAME_LOG_NAME)
	ModLoaderLog.info("All shockers added to Device List", AUTHORNAME_MODNAME_LOG_NAME)
	devices = shockerids

func MultishockCommand(intensity, duration, option, action):
	socket_multishock.send_text(JSON.stringify({
		"cmd": "operate",
		"value": {
			"intensity": intensity,
			"duration": duration,
			"shocker_option": option,
			"action": action,
			"shocker_ids": devices,
			"warning": false,
			"held": false},
		"auth_key": authkey_multishock}))
