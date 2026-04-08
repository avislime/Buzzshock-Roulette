extends "res://scripts/ShotgunShooting.gd"

var Buzzshock

func _ready():
	Buzzshock = get_node("/root/ModLoader/Avislime-Buzzshock")

func Shoot(who : String):
	dealerShotTrue = false
	disablingDelayShit = false
	playerCanGoAgain = false
	var playerDied = false
	var dealerShot = false
	ejectionManager_player.FadeOutShell()
	cursorManager.SetCursor(false, false)
	#CAMERA CONTROLS & ANIMATION DEPENDING ON WHO IS SHOT
	match(who):
		"self":
			await get_tree().create_timer(.25, false).timeout
			animator_shotgun.play("player shoot self")
			await get_tree().create_timer(.5, false).timeout
			camera.BeginLerp("enemy")
		"dealer":
			await get_tree().create_timer(.25, false).timeout
			animator_shotgun.play("player shoot dealer")
			await get_tree().create_timer(.5, false).timeout
			camera.BeginLerp("enemy")
	#PLAY CORRECT SOUND. ASSIGN CURRENT ROUND IN CHAMBER
	await get_tree().create_timer(2, false).timeout
	var currentRoundInChamber = shellSpawner.sequenceArray[0]	
	MainSlowDownRoutine(who, false)
	if (who == "self"): whoshot = "player"
	else: whoshot = "dealer"
	
	# Injected code. Send Buzzshock event based on shot
	# print("player shot %s; Round was %s; dealt %d damage" % [who, currentRoundInChamber, roundManager.currentShotgunDamage])
	match(who):
		"dealer":
			match(currentRoundInChamber):
				"live":
					if roundManager.currentShotgunDamage >= roundManager.health_opponent:
						Buzzshock.BuzzshockEvent("PlayerKilledOther")
					else:
						match(roundManager.currentShotgunDamage):
							1:
								Buzzshock.BuzzshockEvent("PlayerShotOther")
							2:
								Buzzshock.BuzzshockEvent("PlayerShotOtherSawed")
				"blank":
					Buzzshock.BuzzshockEvent("PlayerShotOtherBlank")
		"self":
			match(currentRoundInChamber):
				"live":
					if roundManager.currentShotgunDamage >= roundManager.health_opponent:
						Buzzshock.BuzzshockEvent("PlayerKilledSelf")
					else:
						match(roundManager.currentShotgunDamage):
							1:
								Buzzshock.BuzzshockEvent("PlayerShotSelf")
							2:
								Buzzshock.BuzzshockEvent("PlayerShotSelfSawed")
				"blank":
					Buzzshock.BuzzshockEvent("PlayerShotSelfBlank")
	
	PlayShootingSound()
	#SHAKE CAMERA
	if (currentRoundInChamber == "live"):
		smoke.SpawnSmoke("barrel")
		cameraShaker.Shake()
	#SUBTRACT HEALTH. ASSIGN PLAYER CAN GO AGAIN. RETURN IF DEAD
	if (currentRoundInChamber == "live" && who == "dealer"): 
		roundManager.health_opponent -= roundManager.currentShotgunDamage
		if (roundManager.health_opponent < 0): roundManager.health_opponent = 0
	if (currentRoundInChamber == "live" && who == "self"): 
		CheckAchievement_why()
		CheckAchievement_style()
		roundManager.waitingForHealthCheck2 = true
		if (shellSpawner.sequenceArray.size() == 1): 
			whatTheFuck = true
		roundManager.waitingForDealerReturn = true
		healthCounter.playerShotSelf = true
		playerDied = true
		roundManager.health_player -= roundManager.currentShotgunDamage
		if (roundManager.health_player < 0): roundManager.health_player = 0
		playerCanGoAgain = false
		healthCounter.checkingPlayer = true
		await(death.Kill("player", false, true))
	if (currentRoundInChamber == "blank" && who == "self"): 
		playerCanGoAgain = true
		CheckAchievement_coinflip()
	if (currentRoundInChamber == "live" && who == "dealer"): 
		playerCanGoAgain = false
		dealerShot = true
		dealerShotTrue = true
		await(death.Kill("dealer", false, false))
	if (playerDied): return
	if (dealerShot): return
	await get_tree().create_timer(.3, false).timeout
	#EJECTING SHELLS
	if (currentRoundInChamber == "blank" && who == "self"):
		animator_shotgun.play("player eject shell")
		await get_tree().create_timer(.85, false).timeout
		camera.BeginLerp("home")
		await get_tree().create_timer(1.35, false).timeout
		FinalizeShooting(playerCanGoAgain, true, false, false)
		return
	if (currentRoundInChamber == "blank" && who == "dealer"): disablingDelayShit = true
	ShootingDealerEjection(currentRoundInChamber, who, false)
