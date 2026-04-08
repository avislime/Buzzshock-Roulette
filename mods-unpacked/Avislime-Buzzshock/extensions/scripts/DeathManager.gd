extends "res://scripts/DeathManager.gd"

var Buzzshock

func _ready():
	defibParent.visible = false
	Buzzshock = get_node("/root/ModLoader/Avislime-Buzzshock")

func MedicineDeath():
	viewblocker.visible = true
	cam.cam.rotation_degrees = Vector3(cam.cam.rotation_degrees.x, cam.cam.rotation_degrees.y, 0)
	DisableSpeakers()
	if (shotgunShooting.roundManager.health_player == 0):
		shotgunShooting.roundManager.OutOfHealth("player")
		Buzzshock.BuzzshockEvent("MedicineDeath")
		return
	else:
		Buzzshock.BuzzshockEvent("MedicineBad")
	await get_tree().create_timer(.4, false).timeout
	speaker_playerDefib.play()
	await get_tree().create_timer(.85, false).timeout
	speaker_heartbeat.play()
	animator_pp.play("revival brightness")
	defibParent.visible = true
	animator_playerDefib.play("RESET")
	viewblocker.visible = false
	filter.BeginPan(filter.lowPassMaxValue, filter.lowPassDefaultValue)
	FadeInSpeakers()
	cameraShaker.Shake()
	await get_tree().create_timer(.6, false).timeout
	animator_playerDefib.play("remove defib device")
	await get_tree().create_timer(.4, false).timeout
	#await(healthCounter.UpdateDisplayRoutine(false, !shotgunShooting.playerCanGoAgain, false))
	defibParent.visible = false
