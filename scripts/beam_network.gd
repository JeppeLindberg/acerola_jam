extends Node2D


var _main_scene
var _world

var _relay_to_id = {}
var _id_to_relay = {}
var _next_id = 0;

@export_flags_2d_physics var negation_collision_layer


func _ready():
	_main_scene = get_node('/root/main_scene')
	_world = get_node('/root/main_scene/world')

func update_beam_network():
	var relays = _main_scene.get_children_in_groups(_world, ['relay'], true)
	_next_id = 0;
	for relay in relays:
		_relay_to_id[relay] = _next_id;
		_id_to_relay[_next_id] = relay;
		_next_id += 1

	var directional_network = {}

	for id in _id_to_relay.keys():
		directional_network[id] = {'type': 'relay', 'color': 'none', 'depth': 9999, 'point': _id_to_relay[id].global_position, 'parents': []}
		if _id_to_relay[id].is_emitter:
			directional_network[id] = {'type': 'emitter', 'color': 'blue', 'depth': 0, 'point': _id_to_relay[id].global_position, 'parents': []}

	directional_network = _create_parent_network(directional_network)
	directional_network = _create_negated_network(directional_network)
	directional_network = _colorize_network(directional_network)

	print(directional_network);

func _create_parent_network(directional_network):
	var handled = []

	while true:
		var frontier = []
		for id in directional_network.keys():
			if (directional_network[id]['depth'] != 9999) and !(handled.has(id)):
				frontier.append(id)
		
		if len(frontier) == 0:
			break;
		
		for id in frontier:
			for target_relay in _id_to_relay[id].connected_relays:
				if directional_network[id]['depth'] + 1 <= directional_network[_relay_to_id[target_relay]]['depth']:
					directional_network[_relay_to_id[target_relay]]['parents'].append(id);				
					directional_network[_relay_to_id[target_relay]]['depth'] = directional_network[id]['depth'] + 1;
			
			handled.append(id);
	
	return(directional_network);

func _create_negated_network(directional_network):
	var from_to_ids = {}

	for id_to in directional_network:
		for id_from in directional_network[id_to]['parents']:
			from_to_ids[id_from] = id_to;

	for id_from in from_to_ids.keys():
		var id_to = from_to_ids[id_from];
		var negation_points = _get_beam_negation_points(_id_to_relay[id_from], _id_to_relay[id_to])
		if len(negation_points) > 0:
			directional_network = _inject_negation_point(directional_network, id_from, id_to, negation_points[0])
	
	return(directional_network);

func _get_beam_negation_points(relay_from, relay_to):
	var result = []

	var ray_from = relay_from.global_position;

	while true:
		var space_state = get_world_2d().direct_space_state
		var query = PhysicsRayQueryParameters2D.create(ray_from, relay_to.global_position);
		query.collide_with_areas = true;
		query.collision_mask = negation_collision_layer;
		var collision = space_state.intersect_ray(query);		
		var col_pos = collision.get('position', false);

		if !col_pos:
			break;

		ray_from = col_pos

		var add_pos = true;
		for pos in result:
			if pos.distance_to(col_pos) < 1.0:
				add_pos = false
		
		if add_pos:
			result.append(col_pos)
	
	return(result);

func _inject_negation_point(directional_network, id_from, id_to, point):
	directional_network[_next_id] = {'type': 'negation', 'color': 'none', 'depth': directional_network[id_from]['depth'], 'point': point, 'parents': [id_from]}
	directional_network[id_to]['parents'].erase(id_from);
	directional_network[id_to]['parents'].append(_next_id);
	_next_id += 1;

	return(directional_network);

func _colorize_network(directional_network):
	var dirty = false

	while true:
		dirty = false
		
		for id in directional_network:
			if directional_network[id]['color'] == 'none':
				if len(directional_network[id]['parents']) > 0:
					var parent_id = directional_network[id]['parents'][0];

					if directional_network[id]['type'] == 'negation':
						directional_network[id]['color'] = _calculate_negated_color(directional_network[parent_id]['color'], 1);
					else:
						directional_network[id]['color'] = directional_network[parent_id]['color']

					dirty = true;

		if dirty == false:
			break;
	
	return(directional_network);

func _calculate_negated_color(base_color, negations):
	var negate = negations % 2 == 1;

	if negate:
		if base_color == 'blue':
			return('red');
		if base_color == 'red':
			return('blue');
	
	return(base_color);

func _unhandled_input(event):
	if event is InputEventKey:
		if event.is_action_pressed("test_button"):
			update_beam_network()
