extends "res://multiplayer/scripts/user scripts/MP_ShotgunInteraction.gd"

var Buzzshock

func _ready():
	cam.BeginLerp("home")
	intermediary = get_node("/root/mp_main/standalone managers/interactions/interaction intermediary")
	intbranch_shotgun = intermediary.intbranch_shotgun
	globalparent_shotgun = intermediary.globalparent_shotgun
	globalparent_shotgun_cut_segment = intermediary.globalparent_shotgun_cut_segment
	globalanimator_cut_segment = intermediary.globalanimator_cut_segment
	globalparent_shotgun_main = intermediary.globalparent_shotgun_main
	globalparent_shotgun_forestock = intermediary.globalparent_shotgun_forestock
	globalparent_shotgun_window = intermediary.globalparent_shotgun_window
	globalparent_shotgun_cut_segment_mesh = intermediary.globalparent_shotgun_cut_segment_mesh
	Buzzshock = get_node("/root/ModLoader/Avislime-Buzzshock")

func ShootingOutcome():
	await get_tree().create_timer(.1, false).timeout
	var current_shell = intermediary.game_state.MAIN_shooter_shell
	if intermediary.game_state.MAIN_sequence_length_on_outcome == 1: for property in intermediary.instance_handler.instance_property_array: property.running_fast_revival = true
	
	# Injected code. Send Buzzshock event based on shot
	# Check if target died
	var targetKilled = false
	var our_socket
	for property in properties.intermediary.instance_handler.instance_property_array:
		if property.is_active:
			our_socket = property.socket_number
	for instance in intermediary.instance_handler.instance_property_array:
		if instance.socket_number == active_shooter_socket_target:
			if active_shooter_shotgun_damage >= instance.health_current:
				if current_shell == "live":
					targetKilled = true
	print("%s %s Local socket? Shooter: %s Target: %s" % [properties.socket_number, "True" if properties.is_active else "False", active_shooter_socket_self, active_shooter_socket_target])
	if properties.is_active:
		# We are the one taking action I think
		if targetKilled:
			if active_shooter_socket_self == active_shooter_socket_target:
				# We fuckin killed ourselves dawg
				Buzzshock.BuzzshockEvent("PlayerKilledSelf")
			else:
				# Killed someone else
				Buzzshock.BuzzshockEvent("PlayerKilledOther")
		else:
			if active_shooter_socket_self == active_shooter_socket_target:
				# Shooting ourselves?
				print("I think we're shooting ourselves.")
				match(current_shell):
					"live":
						if active_shooter_shotgun_damage == 2:
							# Sawed
							Buzzshock.BuzzshockEvent("PlayerShotSelfSawed")
						else:
							# Normal shot
							Buzzshock.BuzzshockEvent("PlayerShotSelf")
					"blank":
						Buzzshock.BuzzshockEvent("PlayerShotSelfBlank")
			else:
				# Shooting someone else
				print("I think we're shooting someone else.")
				match(current_shell):
					"live":
						if active_shooter_shotgun_damage == 2:
							Buzzshock.BuzzshockEvent("PlayerShotOtherSawed")
						else:
							Buzzshock.BuzzshockEvent("PlayerShotOther")
					"blank":
						Buzzshock.BuzzshockEvent("PlayerShotOtherBlank")
	else:
		# Someone else is taking action. this might be rougher.
		if targetKilled:
			if active_shooter_socket_target == active_shooter_socket_self:
				# Shooter killed themselves
				print("I think someone killed themselves.")
				Buzzshock.BuzzshockEvent("OtherKilledSelf")
			elif active_shooter_socket_target == our_socket:
				# I think we're being shot?
				print("I think someone is killing us.")
				Buzzshock.BuzzshockEvent("OtherKilledPlayer")
			else:
				# They're killing eachother, dawg
				print("They're killing someone else I think.")
				Buzzshock.BuzzshockEvent("OtherKilledOther")
		else:
			if active_shooter_socket_target == active_shooter_socket_self:
				# Shooter shot themselves
				print("I think someone is shooting themselves.")
				match(current_shell):
					"live":
						if active_shooter_shotgun_damage == 2:
							Buzzshock.BuzzshockEvent("OtherShotSelfSawed")
						else:
							Buzzshock.BuzzshockEvent("OtherShotSelf")
					"blank":
						Buzzshock.BuzzshockEvent("OtherShotSelfBlank")
			elif active_shooter_socket_target == our_socket:
				# I think we're being shot?
				print("I think someone is shooting us.")
				match(current_shell):
					"live":
						if active_shooter_shotgun_damage == 2:
							Buzzshock.BuzzshockEvent("OtherShotPlayerSawed")
						else:
							Buzzshock.BuzzshockEvent("OtherShotPlayer")
					"blank":
						Buzzshock.BuzzshockEvent("OtherShotPlayerBlank")
			else:
				# They're shooting eachother, dawg
				print("Other player shot other player I think.")
				match(current_shell):
					"live":
						if active_shooter_shotgun_damage == 2:
							Buzzshock.BuzzshockEvent("OtherShotOtherSawed")
						else:
							Buzzshock.BuzzshockEvent("OtherShotOther")
					"blank":
						Buzzshock.BuzzshockEvent("OtherShotOtherBlank")
	
	if current_shell == "live":
		PlaySound_LiveFire()
		anim_light_muzzle.play("flash")
		MuzzleFlashPlane()
		intermediary.anim_pp_muzzle_flash.play("pp muzzle flash")
		if !properties.is_active: anim_recoil_thirdperson.play("recoil third person")
		else: anim_recoil_firstperson.play("recoil first person")
		if properties.is_active: cam_shaker.Shake()
		for property in properties.intermediary.instance_handler.instance_property_array:
			if property.socket_number == active_shooter_socket_target:
				property.cam_shaker.Shake()
				break
		anim_muzzle_cone.play("flash cone")
		SmokeParticles()
		BloodParticles()
	else: PlaySound_BlankFire()
	
	if current_shell == "live":
		properties.stat_damage_dealt += active_shooter_shotgun_damage
	if current_shell == "live" && active_shooter_socket_target == active_shooter_socket_self:
		properties.stat_number_of_times_shot_self_with_live += 1
	
	if current_shell == "live" && active_shooter_socket_target == active_shooter_socket_self:
		if properties.is_active:
			animator_shotgun.play("RESET")
			properties.oscillator_manager.LerpToOriginal("shotgun")
			ShotgunBarrel_Grow()
		else: 
			animator_shotgun_thirdperson.play("user shoot self transition_live thirdperson")
			FailsafeAfterSelfShot()
	if current_shell == "blank" && active_shooter_socket_target == active_shooter_socket_self:
		if properties.is_active: 
			PlaySound_ShotgunFoley(true, "transition")
			animator_shotgun.play("user shoot self transition_blank")
		else:
			PlaySound_ShotgunFoley(false, "transition")
			animator_shotgun_thirdperson.play("user shoot self transition_blank thirdperson")
	
	if current_shell == "live":
		for instance in intermediary.instance_handler.instance_property_array:
			if instance.socket_number == active_shooter_socket_target:
				print("death request on instance: ", instance.user_name)
				instance.health_current -= active_shooter_shotgun_damage
				if instance.health_current < 0: 
					instance.health_current = 0
				var dir = GetDirection(instance.socket_number, active_shooter_socket_self)
				instance.death.DeathRequest(dir)
	
	RemoveFirstShellFromSequence()
	
	CheckIfFinalShot()
