extends Spatial

var enemyReasource = load("res://Enemy.tscn")
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_SpawnTimer_timeout():
	var newenemy = enemyReasource.instance()
	newenemy.global_transform = global_transform
	get_parent().add_child(newenemy)
