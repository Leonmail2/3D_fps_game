extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export var damage = 999
export var speed = 40
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	translation += -global_transform.basis.x * speed * delta


func _on_Area_area_entered(area):
	if area.get_parent().has_method("hit"):
		area.get_parent().hit(damage)
		queue_free()


func _on_Timer_timeout():
	queue_free()
