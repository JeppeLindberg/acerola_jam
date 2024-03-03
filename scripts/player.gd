extends RigidBody2D



var _move_left_pressed = false;
var _move_up_pressed = false;
var _move_right_pressed = false;
var _move_down_pressed = false;

@export var movement_speed = 100.0


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

func _move_and_collide(vector):
	var collision = move_and_collide(vector);
	# if collision != null:
	# 	collision

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

	
		

