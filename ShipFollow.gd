extends PathFollow


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export var starting_offset = 872
export var speed = 30
var moving = 1
# Called when the node enters the scene tree for the first time.
func _ready():
	offset = starting_offset


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if moving == 1:
		if offset < 60:
			offset = lerp(offset,0,0.3*delta)
			$"../../../Player".global_transform.origin = $Ship2/playerpos.global_transform.origin
		else:
			offset = clamp(offset- speed * delta, 0 , 9999)
			$"../../../Player".global_transform.origin = $Ship2/playerpos.global_transform.origin
		if offset < 10:
			$"../../../Player".movement_enabled = true
			$StartTimer.start()
			moving = 2
	if moving == 3:
		offset = clamp(offset + speed * delta, 0 , 800)


func _on_StartTimer_timeout():
	moving = 3
