extends Node

enum {
	IDLE = 0,
	FIGHTING = 1,
}

var music_bus = AudioServer.get_bus_index("Music")
var last_state = FIGHTING
var music_state = IDLE
var volume = 0
var combat_volume = -80
var idle_volume = -15
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if music_state != last_state:
		last_state = music_state
		match music_state:
			IDLE:
				volume = idle_volume
				AudioServer.set_bus_volume_db(music_bus,volume)
				$Idle1.play()
			FIGHTING:
				pass
	else:
		match music_state:
			IDLE:
				pass
			FIGHTING:
				pass
		#AudioServer.set_bus_volume_db(music_bus,volume)


func _on_Combat1_finished():
	$Combat1.play()


func _on_Combat2_finished():
	$Combat2.play()


func _on_Idle1_finished():
	$Idle1.play()
