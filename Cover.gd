extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var occupant = ""
var type = "Cover"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func set_occupant(new_occupant):
	if occupant == "":
		occupant = new_occupant
		return new_occupant
	else:
		return occupant

func reset_occupant():
	occupant = ""
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
