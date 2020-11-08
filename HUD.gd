extends CanvasLayer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var blood_opacity = 0
export var blood_modulation_frequency = 2
var blood_modulate = true
var blood_flash = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func update_charge_bar(charge):
	$Data/ChargeBar.value = charge

func update_health(health):
	$Data/Health.text = str(health)
	if health > 40:
		_modulate_blood(false,3,0.4)
		$Data/Health.set("custom_colors/font_color",Color(1, 1, 1))
	if health <= 40 and health > 15:
		_modulate_blood(true,3,0.4)
		$Data/Health.set("custom_colors/font_color",Color(1, 0, 0))
	if health < 15 and health > 1:
		_modulate_blood(true,12,0.65)
		$Data/Health.set("custom_colors/font_color",Color(1, 0, 0))
	if health == 0:
		_modulate_blood(true,1,0.65)
		$Data/Health.set("custom_colors/font_color",Color(1, 0, 0))


func update_ammo(new_ammo,new_clip,new_low):
	$Data/Ammo.text = str(str(new_clip)+"/"+str(new_ammo))
	if new_clip > new_low:
		$Data/Ammo.set("custom_colors/font_color",Color(1, 1, 1))
	else:
		$Data/Ammo.set("custom_colors/font_color",Color(1, 0, 0))

func _modulate_blood(setting,frequency,func_offset):
#	if setting == true:
#		$Data/Blood.material.set_shader_param("flashing",1)
#		$Data/Blood.material.set_shader_param("frequency",float(frequency))
#		$Data/Blood.material.set_shader_param("offset",float(func_offset))
#	else:
#		$Data/Blood.material.set_shader_param("flashing",0)
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	

func _on_GunManager_ammo_change(ammo,clip,new_low):
	update_ammo(ammo,clip,new_low)

