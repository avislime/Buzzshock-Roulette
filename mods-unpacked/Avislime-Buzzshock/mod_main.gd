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
var socket_intiface = WebSocketPeer.new()
var url_multishock = ""
var authkey_multishock = ""
var url_intiface = ""
var shockers
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
	url_intiface = config_data["Connections"]["Intiface"]["Websocket"]
	if config_data["Connections"]["Multishock"]["Enabled"]:
		MultishockConnect()
	if config_data["Connections"]["Intiface"]["Enabled"]:
		IntifaceConnect()
		await get_tree().create_timer(1).timeout
		IntifaceRequestDevices()
		IntifaceScanForDevices()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	socket_multishock.poll()
	socket_intiface.poll()
	
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
	
	if is_intiface_connected:
		var state = socket_intiface.get_ready_state()
		if state == WebSocketPeer.STATE_OPEN:
			while socket_intiface.get_available_packet_count():
				var packet = socket_intiface.get_packet()
				if socket_intiface.was_string_packet():
					var packet_text = packet.get_string_from_utf8()
					IntifaceProcessResponse(packet_text)
					ModLoaderLog.debug("Got string data: %s" % packet_text,  AUTHORNAME_MODNAME_LOG_NAME)
				else:
					ModLoaderLog.debug("Got binary data: %d bytes" % packet.size(), AUTHORNAME_MODNAME_LOG_NAME)
		
		elif state == WebSocketPeer.STATE_CLOSING:
			pass
		
		elif state == WebSocketPeer.STATE_CLOSED:
			var code = socket_intiface.get_close_code()
			ModLoaderLog.debug("WebSocket closed with code: %d. Clean: %s" % [code, code != -1], AUTHORNAME_MODNAME_LOG_NAME)
			is_intiface_connected = false
		pass

func BuzzshockEvent(case):
	ModLoaderLog.debug("Buzzshock event called: %s" % case, AUTHORNAME_MODNAME_LOG_NAME)
	# Example event data
	var event = {	"Enabled": false,
					"Device": "pishock",
					"Action": "vibrate",
					"Intensity": 25,
					"Duration": 0.3}
	match(case):
		# Grab event command parameters from config
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
		if event["Device"] == "pishock":
			if is_multishock_connected:
				ModLoaderLog.debug(	"Sending Multishock command: %s at %s percent, %s seconds." % 
									[event["Action"], event["Intensity"], event["Duration"]],
									AUTHORNAME_MODNAME_LOG_NAME)
				MultishockCommand(event["Intensity"], event["Duration"],
				"random" if config_data["Connections"]["Multishock"]["Random Shocker"] else "all", event["Action"])
		else:
			if is_intiface_connected:
				ModLoaderLog.debug(	"Sending Intiface command: Vibrate at %s percent, %s seconds." % 
									[event["Intensity"], event["Duration"]],
									AUTHORNAME_MODNAME_LOG_NAME)
				IntifaceCommand(event["Device"], event["Intensity"], event["Duration"])

func MultishockConnect():
	# Initiate websocket connection to multishock.
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

func MultishockGetDevices():
	socket_multishock.send_text(JSON.stringify({
		"auth_key": authkey_multishock,
		"cmd": "get_devices"}))

func MultishockProcessDevices(response):
	ModLoaderLog.debug("Processing device list", AUTHORNAME_MODNAME_LOG_NAME)
	var json_data = JSON.parse_string(response)
	var shocker_ids = []
	for user in json_data:
		var shocker_names = []
		for shocker in user["shockers"]:
			shocker_names.append(shocker["name"])
			shocker_ids.append(shocker["identifier"])
		ModLoaderLog.debug("User: %s (%s), shockers: %s" % [user["name"], user["id"], ", ".join(shocker_names)], AUTHORNAME_MODNAME_LOG_NAME)
	ModLoaderLog.info("All shockers added to shocker list", AUTHORNAME_MODNAME_LOG_NAME)
	shockers = shocker_ids

func MultishockCommand(intensity, duration, option, action):
	socket_multishock.send_text(JSON.stringify({
		"cmd": "operate",
		"value": {
			"intensity": intensity,
			"duration": duration,
			"shocker_option": option,
			"action": action,
			"shocker_ids": shockers,
			"warning": false,
			"held": false},
		"auth_key": authkey_multishock}))

func IntifaceConnect():
	# Initiate websocket connection to multishock.
	ModLoaderLog.debug("Connecting to Intiface at '%s'" % url_intiface, AUTHORNAME_MODNAME_LOG_NAME)
	var err = socket_intiface.connect_to_url(url_intiface)
	# Wait for connection to establish.
	if err == OK:
		await get_tree().create_timer(1).timeout
		if socket_intiface.get_ready_state() == WebSocketPeer.STATE_OPEN:
			ModLoaderLog.success("Connected to Intiface.", AUTHORNAME_MODNAME_LOG_NAME)
			socket_intiface.send_text(JSON.stringify([{
				"RequestServerInfo":{
					"Id": 1,
					"ClientName": "Buzzshock Roulette",
					"ProtocolVersionMajor": 4,
					"ProtocolVersionMinor": 0}}], "", false))
			is_intiface_connected = true
		else:
			ModLoaderLog.warning("Failed to connect to Intiface, Timed out.", AUTHORNAME_MODNAME_LOG_NAME)
			is_intiface_connected = false
	else:
		ModLoaderLog.warning("Failed to connect to Intiface.", AUTHORNAME_MODNAME_LOG_NAME)
		is_intiface_connected = false

func IntifaceScanForDevices():
	ModLoaderLog.debug("Intiface: Attempting device scan.", AUTHORNAME_MODNAME_LOG_NAME)
	socket_intiface.send_text(JSON.stringify([{
		"StartScanning":{
			"Id": 1}}], "", false))

func IntifaceRequestDevices():
	ModLoaderLog.debug("Intiface: Requesting device list.", AUTHORNAME_MODNAME_LOG_NAME)
	socket_intiface.send_text(JSON.stringify([{
		"RequestDeviceList":{
			"Id": 1}}], "", false))

func IntifaceProcessResponse(response):
	var json_data = JSON.parse_string(response)
	for data in json_data:
		if "Ok" in data:
			ModLoaderLog.debug("Intiface: Received Ok", AUTHORNAME_MODNAME_LOG_NAME)
		elif "Ping" in data:
			ModLoaderLog.debug("Intiface: Received Ping", AUTHORNAME_MODNAME_LOG_NAME)
		elif "ServerInfo" in data:
			ModLoaderLog.debug("Intiface: Recieved ServerInfo", AUTHORNAME_MODNAME_LOG_NAME)
		elif "DeviceList" in data:
			ModLoaderLog.debug("Intiface: Received DeviceList", AUTHORNAME_MODNAME_LOG_NAME)
			devices = {}
			for device in data["DeviceList"]["Devices"]:
				device = data["DeviceList"]["Devices"][device]
				for feature in device["DeviceFeatures"]:
					feature = device["DeviceFeatures"][feature]
					if "Output" in feature:
						for output in feature["Output"]:
							if "Vibrate" in output:
								var device_name = IntifaceProcessDisplayName(device["DeviceName"], device["DeviceIndex"] + feature["FeatureIndex"])
								ModLoaderLog.debug("IS THAT A VIBRATOR?? Anyway logged device %s as %s" % 
								[device["DeviceName"], device_name],
								AUTHORNAME_MODNAME_LOG_NAME)
								devices[device_name] = {
									"DeviceIndex": device["DeviceIndex"],
									"FeatureIndex": feature["FeatureIndex"],
									"MaxValue": feature["Output"]["Vibrate"]["Value"][1]
								}
		elif "Error" in data:
			ModLoaderLog.debug("Intiface: Received Error", AUTHORNAME_MODNAME_LOG_NAME)
		elif "Disconnect" in data:
			ModLoaderLog.debug("Intiface: Received Disconnect", AUTHORNAME_MODNAME_LOG_NAME)

func IntifaceProcessDisplayName(text, index):
	# what the fuck do you mean there's no built in function to make a string alphanumeric
	# TODO: Replace this with something that isnt asinine
	# this will do for now but Boy Do I Fucking Hate It
	return "%s-%s" % [text.to_lower().replace(" ", "").replace("(", "").replace(")", ""), index]

func IntifaceCommand(device, intensity, duration):
	if devices.has(device):
		ModLoaderLog.debug(JSON.stringify(device, "", false), AUTHORNAME_MODNAME_LOG_NAME)
		var intensity_value = round(devices[device]["MaxValue"] * (intensity/100))
		ModLoaderLog.debug("%s found; Max Value %s" % [device, devices[device]["MaxValue"]], AUTHORNAME_MODNAME_LOG_NAME)
		ModLoaderLog.debug("Sending %s intensity for %s seconds" % [intensity_value, duration], AUTHORNAME_MODNAME_LOG_NAME)
		socket_intiface.send_text(JSON.stringify([{
			"OutputCmd":{
				"Id": 1,
				"DeviceIndex": devices[device]["DeviceIndex"],
				"FeatureIndex": devices[device]["FeatureIndex"],
				"Command":{
					"Vibrate":{
						"Value": intensity_value}}}}]))
		await get_tree().create_timer(duration).timeout
		socket_intiface.send_text(JSON.stringify([{
			"OutputCmd":{
				"Id": 1,
				"DeviceIndex": devices[device]["DeviceIndex"],
				"FeatureIndex": devices[device]["FeatureIndex"],
				"Command":{
					"Vibrate":{
						"Value": 0}}}}]))
	else:
		ModLoaderLog.debug("%s is not a connected device." % device, AUTHORNAME_MODNAME_LOG_NAME)
