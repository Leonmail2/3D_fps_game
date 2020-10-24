extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export var enemy_type = "Dummy"
export var health = 100
#var hitcolor = 1.0

func die():
	queue_free()

func hit(damage):
	health = clamp(health - damage,0,100)
	print(health)
	#hitcolor = 0.0
	if health == 0:
		die()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func shoot():
	var bullet = preload("res://Bullet.tscn").instance()
	get_node('/root/3DShooter').add_child(bullet)
	bullet.global_transform = $Gun/BulletSpawner.get_global_transform()
	bullet.damage = 15
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#$MeshInstance.mesh.material.set_shader_param("hitcolor",hitcolor)
	#hitcolor = clamp(hitcolor + 0.5 * delta, 0.0, 1.0)
	pass
	


func _on_GunTimer_timeout():
	shoot()
