extends KinematicBody


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export var enemy_type = "Dummy"
export var health = 100
export var speed = 10

var path = []
var path_node = 0

onready var nav = get_parent()
onready var player = $"../../../Player"
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


func _physics_process(delta):
	if path_node < path.size():
		var direction = (path[path_node]-global_transform.origin)
		if direction.length() < 1:
			path_node += 1
		else:
			$Gun.look_at(player.global_transform.origin,Vector3.UP)
			var playerxz = Vector3(player.global_transform.origin.x,global_transform.origin.y,player.global_transform.origin.z)
			look_at(playerxz,Vector3.UP)
			var velocity = direction.normalized() * speed
			velocity.y += -40 * delta
			move_and_slide(velocity,Vector3.UP)

func move_to(target_pos):
	path = nav.get_simple_path(global_transform.origin, target_pos)
	path_node = 0

func _on_GunTimer_timeout():
	shoot()


func _on_MoveTimer_timeout():
	move_to(player.global_transform.origin)
