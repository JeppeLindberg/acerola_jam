extends Area2D

var _main_scene
var _collider: CollisionShape2D


func _ready():
	_main_scene = get_node('/root/main_scene')
	_collider = get_node('./collider');

func _unhandled_input(event):
	if event is InputEventMouseButton:
		if (event.button_index == MOUSE_BUTTON_LEFT) and (event.pressed):
			if _main_scene.is_pos_overlapping_collider(_collider, event.position):
				print('clicked')
