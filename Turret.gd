extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var player = $"../../Player"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func shoot():
	var bullet = preload("res://Bullet.tscn").instance()
	get_node('/root/3DShooter').add_child(bullet)
	bullet.global_transform = $Arm2/Cylinder2/Sphere2/Sphere2/BulletSpawn.get_global_transform()
	bullet.damage = 15

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#$Arm2/Cylinder2/Sphere2.look_at(player.global_transform.origin,Vector3.UP)
	pass

func _on_ShootTimer_timeout():
	#shoot()
