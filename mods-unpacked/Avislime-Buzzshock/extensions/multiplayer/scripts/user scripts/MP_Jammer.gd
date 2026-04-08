extends "res://multiplayer/scripts/user scripts/MP_Jammer.gd"

var Buzzshock

func _ready():
	for i in bootup_text_array:
		i.visible = false
	for i in button_colliders:
		i.disabled = true
	for i in button_intbranches:
		i.interactionAllowed = false
	Buzzshock = get_node("/root/ModLoader/Avislime-Buzzshock")

func Jammer_Enable():
	properties.is_jammed = true
	properties.jammer_checked = false
	properties.health_counter.DisableDisplay()
	PlaySound_RandomError()
	if properties.is_active:
		Buzzshock.BuzzshockEvent("Jammed MP")
