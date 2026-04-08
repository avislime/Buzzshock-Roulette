extends "res://multiplayer/scripts/user scripts/MP_ItemInteraction.gd"

var Buzzshock

func _ready():
	Buzzshock = get_node("/root/ModLoader/Avislime-Buzzshock")

func InteractWithItem_FirstPerson(packet : Dictionary):
	properties.permissions.SetMainPermission(false)
	if packet.stealing_item:
		properties.SetAdrenalineControllerPrompts(false)
		properties.permissions.SetItemPermissions(false, true)
		properties.is_stealing_item = false
		properties.is_on_secondary_interaction = false
	var local_grid_index = packet.local_grid_index
	var item_object : Node3D
	#for user_property in properties.intermediary.instance_handler.instance_property_array:
	#	if user_property.socket_number == packet.item_socket_number:
	#		item_object = user_property.user_inventory_instance_array[local_grid_index]
	#		break
	item_object = properties.intermediary.game_state.MAIN_inventory_by_socket[packet.item_socket_number][local_grid_index].item_instance
	RemoveItemFromInventory(local_grid_index, packet.item_socket_number)
	GetItemVariables(item_object)
	ChangeGameStateWithItem(active_id, packet)
	if !packet.stealing_item:
		animator_items_firstperson.play("RESET")
	else:
		properties.intermediary.filter.PanLowPass_In()
		PanCameraBack()
	await(PickupItem(active_item_parent))
	match active_id:
		1:	#hand saw
			shotgun.SetShotgunVisible_Global(false)
			shotgun.SetShotgunVisible_Local(true)
			Buzzshock.BuzzshockEvent("Handsaw MP")
		2:	#magnifying glass
			shotgun.SetShotgunVisible_Global(false)
			shotgun.SetShotgunVisible_Local(true)
			Buzzshock.BuzzshockEvent("Magnifying Glass MP")
		3:	#jammer
			properties.cam.moving = false
			Buzzshock.BuzzshockEvent("Jammer MP")
		4:	#cigarettes
			Buzzshock.BuzzshockEvent("Cigarettes MP")
			pass
		5:	#beer	
			Buzzshock.BuzzshockEvent("Beer MP")
			shotgun.SetShotgunVisible_Global(false)
			shotgun.SetShotgunVisible_Local(true)
		6:	#burner phone
			Buzzshock.BuzzshockEvent("Burner Phone MP")
			pass
		8: #adrenaline
			Buzzshock.BuzzshockEvent("Adrenaline MP")
			pass
		9:	#inverter
			Buzzshock.BuzzshockEvent("Inverter MP")
			pass
		10:	#remote
			Buzzshock.BuzzshockEvent("Remote MP")
			pass
	
	var active_stream : AudioStream
	for res in properties.intermediary.game_state.MAIN_item_resource_array:
		if res.id == active_id:
			active_stream = res.sound_initial_interaction_fp
	properties.item_manager.speaker_fp_initial_interaction.stream = active_stream
	properties.item_manager.speaker_fp_initial_interaction.play()
	
	var animation_name = "use item id " + str(active_id) + " first person"
	animator_items_firstperson.play(animation_name)
	if active_item_has_secondary_interaction: return
	await get_tree().create_timer(animator_items_firstperson.get_animation(animation_name).length, false).timeout
	match active_id:
		1:	#hand saw
			shotgun.SetShotgunVisible_Global(true)
			shotgun.SetShotgunVisible_Local(false)
		2:	#magnifying glass
			shotgun.SetShotgunVisible_Global(true)
			shotgun.SetShotgunVisible_Local(false)
		5:	#beer
			shotgun.SetShotgunVisible_Global(true)
			shotgun.SetShotgunVisible_Local(false)
	await get_tree().create_timer(.2, false).timeout
	EndItemInteraction(packet)
