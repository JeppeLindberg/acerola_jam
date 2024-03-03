extends Node2D

var _player

var _target_pickup: Node2D = null
var _picked_up_item: Node2D = null


func _ready():
	_player = get_parent();

func set_pickupable(pickup):
	_target_pickup = pickup;

func unset_pickupable(pickup):
	if _target_pickup == pickup:
		_target_pickup = null;

func _pickup_current_target():
	if _target_pickup == null:
		return;

	_picked_up_item = _target_pickup
	_picked_up_item.pick_up(_player)

func _drop_current_item():
	if _picked_up_item == null:
		return;

	_picked_up_item.drop()
	_picked_up_item = null;

func _unhandled_input(event):
	if event is InputEventKey:
		if event.is_action_pressed("pickup"):
			if _picked_up_item == null:
				_pickup_current_target();
			else:
				_drop_current_item();
