extends Node2D



var _player: RigidBody2D

var _move_left_pressed = false;
var _move_up_pressed = false;
var _move_right_pressed = false;
var _move_down_pressed = false;

@export var movement_speed = 100.0


func _ready():
	_player = get_parent();

func _physics_process(delta):
	var _move_dir = Vector2.ZERO;

	if _move_left_pressed:
		_move_dir += Vector2.LEFT;
	if _move_up_pressed:
		_move_dir += Vector2.UP;
	if _move_right_pressed:
		_move_dir += Vector2.RIGHT;
	if _move_down_pressed:
		_move_dir += Vector2.DOWN;
		
	_move_dir = _move_dir.normalized();
		
	_move_and_collide(_move_dir * movement_speed * delta)

func _move_and_collide(vector: Vector2):
	var attempts = 3;

	while attempts >= 0:
		var old_pos = global_position;
		var collision = _player.move_and_collide(vector);
		var new_pos = global_position;
		if collision != null:
			var completed_percentage = old_pos.distance_to(new_pos) / vector.length();
			
			if completed_percentage >= 1.0:
				break;

			var remaining_vector = vector * (1.0 - completed_percentage);
			vector = remaining_vector.project(collision.get_normal().rotated(deg_to_rad(90.0)))
			attempts -= 1;
			continue;
		
		break;

func _unhandled_input(event):
	if event is InputEventKey:

		if event.is_action_pressed("move_left"):
			_move_left_pressed = true;
			return;
		if event.is_action_released("move_left"):			
			_move_left_pressed = false;
			return;

		if event.is_action_pressed("move_up"):
			_move_up_pressed = true;
			return;
		if event.is_action_released("move_up"):			
			_move_up_pressed = false;
			return;

		if event.is_action_pressed("move_right"):
			_move_right_pressed = true;
			return;
		if event.is_action_released("move_right"):			
			_move_right_pressed = false;
			return;

		if event.is_action_pressed("move_down"):
			_move_down_pressed = true;
			return;
		if event.is_action_released("move_down"):			
			_move_down_pressed = false;
			return;

	
		

