extends "res://scripts/DealerIntelligence.gd"

var Buzzshock

func _ready():
	Buzzshock = get_node("/root/ModLoader/Avislime-Buzzshock")

func Shoot(who : String):
	var currentRoundInChamber = shellSpawner.sequenceArray[0]
	dealerCanGoAgain = false
	var playerDied = false
	var dealerDied = false
	ejectManager.FadeOutShell()
	#ANIMATION DEPENDING ON WHO IS SHOT
	match(who):
		"self":
			await get_tree().create_timer(.2, false).timeout
			animator_shotgun.play("enemy shoot self")
			await get_tree().create_timer(2, false).timeout
			shotgunShooting.whoshot = "dealer"
			shotgunShooting.PlayShootingSound()
			pass
		"player":
			animator_shotgun.play("enemy shoot player")
			await get_tree().create_timer(2, false).timeout
			shotgunShooting.whoshot = "player"
			shotgunShooting.PlayShootingSound()
			pass
	
	# Injected code. Send Buzzshock event based on shot
	# print("dealer shot %s; Round was %s; dealt %d damage" % [who, currentRoundInChamber, roundManager.currentShotgunDamage])
	match(who):
		"player":
			match(currentRoundInChamber):
				"live":
					if roundManager.currentShotgunDamage >= roundManager.health_player:
						Buzzshock.BuzzshockEvent("OtherKilledPlayer")
					else:
						match(roundManager.currentShotgunDamage):
							1:
								Buzzshock.BuzzshockEvent("OtherShotPlayer")
							2:
								Buzzshock.BuzzshockEvent("OtherShotPlayerSawed")
				"blank":
					Buzzshock.BuzzshockEvent("OtherShotPlayerBlank")
		"self":
			match(currentRoundInChamber):
				"live":
					if roundManager.currentShotgunDamage >= roundManager.health_player:
						Buzzshock.BuzzshockEvent("OtherKilledSelf")
					else:
						match(roundManager.currentShotgunDamage):
							1:
								Buzzshock.BuzzshockEvent("OtherShotSelf")
							2:
								Buzzshock.BuzzshockEvent("OtherShotSelfSawed")
				"blank":
					Buzzshock.BuzzshockEvent("OtherShotSelfBlank")
	
	#SUBTRACT HEALTH. ASSIGN DEALER CAN GO AGAIN. RETURN IF DEAD
	if (currentRoundInChamber == "live" && who == "self"): 
		roundManager.health_opponent -= roundManager.currentShotgunDamage
		if (roundManager.health_opponent < 0): roundManager.health_opponent = 0
		smoke.SpawnSmoke("barrel")
		cameraShaker.Shake()
		dealerCanGoAgain = false
		death.Kill("dealer", false, true)
		return
	if (currentRoundInChamber == "live" && who == "player"): 
		roundManager.health_player -= roundManager.currentShotgunDamage
		if (roundManager.health_player < 0): roundManager.health_player = 0
		cameraShaker.Shake()
		smoke.SpawnSmoke("barrel")
		await(death.Kill("player", false, false))
		playerDied = true
	if (currentRoundInChamber == "blank" && who == "self"): dealerCanGoAgain = true
	#EJECTING SHELLS
	await get_tree().create_timer(.4, false).timeout
	if (who == "player"): animator_shotgun.play("enemy eject shell_from player")
	if (who == "self"): animator_shotgun.play("enemy eject shell_from self")
	await get_tree().create_timer(1.7, false).timeout
	#shellSpawner.sequenceArray.remove_at(0)
	EndDealerTurn(dealerCanGoAgain)
