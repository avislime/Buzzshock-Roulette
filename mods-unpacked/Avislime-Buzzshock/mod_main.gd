extends Node

const AUTHORNAME_MODNAME_DIR := "Avislime-Buzzshock"
const AUTHORNAME_MODNAME_LOG_NAME := "Avislime-Buzzshock:Main"

var mod_dir_path := ""
var extensions = ["extensions/scripts/DealerIntelligence.gd",
				  "extensions/scripts/DeathManager.gd",
				  "extensions/scripts/ItemInteraction.gd",
				  "extensions/scripts/MedicineManager.gd",
				  "extensions/scripts/ShotgunShooting.gd",
				  "extensions/multiplayer/scripts/user scripts/MP_ItemInteraction.gd",
				  "extensions/multiplayer/scripts/user scripts/MP_Jammer.gd",
				  "extensions/multiplayer/scripts/user scripts/MP_ShotgunInteraction.gd"]
var ConfigManager = load("res://mods-unpacked/Avislime-Buzzshock/config_manager.gd").new()
var config_data = {}

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
	ModLoaderLog.info("Buzzshock event called: %s" % case, AUTHORNAME_MODNAME_LOG_NAME)
	if is_multishock_connected:
		var event = {"Enabled": false,
					 "Intensity": 25,
					 "Duration": 0.1,
					 "Action": "vibrate",
					 "Random Shocker": false}
		match(case):
			# Grab event command parameters from config
			"Test":
				MultishockCommand(25, 1, "all", "vibrate")
			"PlayerShotOther":
				event = config_data["Events"]["Shots"]["Player"]["Player shot Other; Live"]
			"PlayerShotOtherSawed":
				event = config_data["Events"]["Shots"]["Player"]["Player shot Other; Sawed"]
			"PlayerShotOtherBlank":
				event = config_data["Events"]["Shots"]["Player"]["Player shot Other; Blank"]
			"PlayerKilledOther":
				event = config_data["Events"]["Shots"]["Player"]["Player killed Other"]
			"PlayerShotSelf":
				event = config_data["Events"]["Shots"]["Player"]["Player shot Self; Live"]
			"PlayerShotSelfSawed":
				event = config_data["Events"]["Shots"]["Player"]["Player shot Self; Sawed"]
			"PlayerShotSelfBlank":
				event = config_data["Events"]["Shots"]["Player"]["Player shot Self; Blank"]
			"PlayerKilledSelf":
				event = config_data["Events"]["Shots"]["Player"]["Player killed Self"]
			"OtherShotPlayer":
				event = config_data["Events"]["Shots"]["Other"]["Other shot Player; Live"]
			"OtherShotPlayerSawed":
				event = config_data["Events"]["Shots"]["Other"]["Other shot Player; Sawed"]
			"OtherShotPlayerBlank":
				event = config_data["Events"]["Shots"]["Other"]["Other shot Player; Blank"]
			"OtherKilledPlayer":
				event = config_data["Events"]["Shots"]["Other"]["Other killed Player"]
			"OtherShotSelf":
				event = config_data["Events"]["Shots"]["Other"]["Other shot Self; Live"]
			"OtherShotSelfSawed":
				event = config_data["Events"]["Shots"]["Other"]["Other shot Self; Sawed"]
			"OtherShotSelfBlank":
				event = config_data["Events"]["Shots"]["Other"]["Other shot Self; Blank"]
			"OtherKilledSelf":
				event = config_data["Events"]["Shots"]["Other"]["Other killed Self"]
			"OtherShotOther":
				event = config_data["Events"]["Shots"]["Other"]["Other shot Other; Live"]
			"OtherShotOtherSawed":
				event = config_data["Events"]["Shots"]["Other"]["Other shot Other; Sawed"]
			"OtherShotOtherBlank":
				event = config_data["Events"]["Shots"]["Other"]["Other shot Other; Blank"]
			"OtherKilledOther":
				event = config_data["Events"]["Shots"]["Other"]["Other killed Other"]
			"Handcuffs":
				event = config_data["Events"]["Items"]["Handcuffs"]
			"Beer":
				event = config_data["Events"]["Items"]["Beer"]
				await get_tree().create_timer(0.5).timeout
			"Beer MP":
				event = config_data["Events"]["Items"]["Beer"]
				await get_tree().create_timer(0.5).timeout
			"Magnifying Glass":
				event = config_data["Events"]["Items"]["Magnifying Glass"]
			"Magnifying Glass MP":
				event = config_data["Events"]["Items"]["Magnifying Glass"]
			"Cigarettes":
				event = config_data["Events"]["Items"]["Cigarettes"]
				await get_tree().create_timer(1).timeout
			"Cigarettes MP":
				event = config_data["Events"]["Items"]["Cigarettes"]
				await get_tree().create_timer(1).timeout
			"Handsaw":
				event = config_data["Events"]["Items"]["Handsaw"]
				await get_tree().create_timer(0.75).timeout
			"Handsaw MP":
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
			"Inverter MP":
				event = config_data["Events"]["Items"]["Inverter"]
				await get_tree().create_timer(1.5).timeout
			"Burner Phone":
				event = config_data["Events"]["Items"]["Burner Phone"]
				await get_tree().create_timer(4).timeout
			"Burner Phone MP":
				event = config_data["Events"]["Items"]["Burner Phone"]
				await get_tree().create_timer(4).timeout
			"Adrenaline":
				event = config_data["Events"]["Items"]["Adrenaline"]
				await get_tree().create_timer(3.25).timeout
			"Adrenaline MP":
				event = config_data["Events"]["Items"]["Adrenaline"]
				await get_tree().create_timer(3.25).timeout
		if event["Enabled"]:
			ModLoaderLog.info(	"Sending command: %s at %s percent, %s seconds." % 
								[event["Action"], event["Intensity"], event["Duration"]],
								AUTHORNAME_MODNAME_LOG_NAME)
			MultishockCommand(event["Intensity"], event["Duration"],
			"random" if event["Random Shocker"] else "all", event["Action"])

func MultishockGetDevices():
	socket_multishock.send_text(JSON.stringify({
		"auth_key": authkey_multishock,
		"cmd": "get_devices"}))

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
