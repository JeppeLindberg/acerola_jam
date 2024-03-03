extends RigidBody2D


var _player_pickup;


func _ready():
    add_to_group('player');

    _player_pickup = get_node('player_pickup');


func set_pickupable(pickup):
    _player_pickup.set_pickupable(pickup);

func unset_pickupable(pickup):
    _player_pickup.unset_pickupable(pickup);
