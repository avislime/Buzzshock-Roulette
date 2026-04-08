extends "res://scripts/MedicineManager.gd"

var Buzzshock

func _ready():
	Buzzshock = get_node("/root/ModLoader/Avislime-Buzzshock")

func UseMedicine():
	cam.moving = false
	var dying = GetFlip()
	if (dying):Perms(8.78)
	else: Perms(6.78)
	await get_tree().create_timer(3.05, false).timeout
	death.DisableSpeakers()
	await get_tree().create_timer(1.25 + .1, false).timeout
	if (dying):
		counter.skipping_careful = true
		rm.health_player -= 1
		speaker_medicine.stream = death_player
		speaker_medicine.play()
		await(death.MedicineDeath())
		counter.overriding_medicine = true
		counter.overriding_medicine_adding = false
		counter.UpdateDisplayRoutineCigarette_Player()
	else:
		Buzzshock.BuzzshockEvent("MedicineGood")
		death.FadeInSpeakers()
		counter.overriding_medicine = true
		counter.overriding_medicine_adding = true
		counter.UpdateDisplayRoutineCigarette_Player()
