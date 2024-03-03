extends Area2D

var _item: Node2D
var _world: Node2D


func _ready():
    _item = get_parent();
    _world = get_node('/root/main_scene/world')

func pick_up(player):
    _item.reparent(player);
    _item.position = Vector2.ZERO;
    monitoring = false;

func drop():
    _item.reparent(_world)    
    monitoring = true;

func _on_body_entered(body:Node2D):
    if body.is_in_group('player'):
        body.set_pickupable(self)

func _on_body_exited(body:Node2D):
    if body.is_in_group('player'):
        body.unset_pickupable(self)

