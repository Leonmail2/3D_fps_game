extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export var ammo_bonus = 20

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	rotate_y(0.7*PI*delta)
	transform = transform.orthonormalized()


func _on_Area_area_entered(area):
	if area.get_parent().has_method("get_ammo"):
		area.get_parent().get_ammo("Pistol",ammo_bonus)
		queue_free()
