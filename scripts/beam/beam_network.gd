extends Node2D


var _main_scene
var _world
var _debug

var _relay_to_id = {}
var _id_to_relay = {}
var _next_id = 0;

@export_flags_2d_physics var negation_collision_layer
@export_flags_2d_physics var occusion_collision_layer

@export var beam_path: String


func _ready():
	_main_scene = get_node('/root/main_scene')
	_world = get_node('/root/main_scene/world')
	_debug = get_node('/root/main_scene/debug')

func _process(_delta):
	_update_beam_network()

func _update_beam_network():
	_relay_to_id = {}
	_id_to_relay = {}
	_next_id = 0;

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
			directional_network[id] = {'type': 'emitter', 'color': 'none', 'depth': 0, 'point': _id_to_relay[id].global_position, 'parents': []}

	directional_network = _create_parent_network(directional_network)
	directional_network = _create_negated_network(directional_network)
	directional_network = _create_occluded_network(directional_network)
	directional_network = _colorize_network(directional_network)
	_create_beams(directional_network)
	
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
	# _debug.add_label('beam_network', 'beam_network _create_negated_network')
	var from_to_ids = {}

	for id_to in directional_network:
		for id_from in directional_network[id_to]['parents']:
			from_to_ids[id_from] = id_to;

	for id_from in from_to_ids.keys():
		var id_to = from_to_ids[id_from];
		var negation_point = _get_beam_collision(directional_network[id_from]['point'], directional_network[id_to]['point'], negation_collision_layer)
		if negation_point is Vector2:
			directional_network = _inject_negation_point(directional_network, id_from, id_to, negation_point)
	
	return(directional_network);

func _get_beam_collision(from_point, to_point, layer):
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(from_point, to_point);
	query.collide_with_areas = true;
	query.hit_from_inside = true;
	query.collision_mask = layer;
	var collision = space_state.intersect_ray(query);		
	var col_pos = collision.get('position', false);

	if !col_pos:
		return(false)
	
	return(col_pos);

func _inject_negation_point(directional_network, id_from, id_to, point):
	directional_network[_next_id] = {'type': 'negation', 'color': 'none', 'depth': directional_network[id_from]['depth'], 'point': point, 'parents': [id_from]}
	directional_network[id_to]['parents'].erase(id_from);
	directional_network[id_to]['parents'].append(_next_id);
	_next_id += 1;

	return(directional_network);

func _create_occluded_network(directional_network):
	var from_to_ids = {}

	for id_to in directional_network:
		for id_from in directional_network[id_to]['parents']:
			from_to_ids[id_from] = id_to;

	for id_from in from_to_ids.keys():
		var id_to = from_to_ids[id_from];
		var occluded_point = _get_beam_collision(directional_network[id_from]['point'], directional_network[id_to]['point'], occusion_collision_layer)
		if occluded_point is Vector2:
			directional_network = _inject_occluded_point(directional_network, id_from, id_to, occluded_point)
	
	return(directional_network);

func _inject_occluded_point(directional_network, id_from, id_to, point):
	directional_network[_next_id] = {'type': 'occlusion', 'color': 'none', 'depth': directional_network[id_from]['depth'], 'point': point, 'parents': [id_from]}
	directional_network[id_to]['parents'].erase(id_from);
	directional_network[id_to]['parents'].append(_next_id);
	_next_id += 1;

	return(directional_network);

func _colorize_network(directional_network):
	var handled_ids = []

	while len(handled_ids) < len(directional_network.keys()):		
		for id in directional_network:
			if _all_parents_handled(directional_network[id]['parents'], handled_ids):				
				handled_ids.append(id);

				if directional_network[id]['type'] == 'emitter':
					directional_network[id]['color'] = 'blue';
					continue;

				if directional_network[id]['type'] == 'occlusion':
					directional_network[id]['color'] = 'none';
					continue;

				if len(directional_network[id]['parents']) == 0:
					continue;
					
				var parent_id = directional_network[id]['parents'][0];
					
				if directional_network[id]['type'] == 'relay':
					directional_network[id]['color'] = directional_network[parent_id]['color']
					continue;

				if directional_network[id]['type'] == 'negation':
					directional_network[id]['color'] = _calculate_negated_color(directional_network[parent_id]['color'], 1);
					continue;
	
	return(directional_network);

func _all_parents_handled(parents, handled):
	for id in parents:
		if not id in handled:
			return(false)
	
	return(true);

func _create_beams(directional_network):
	for child in get_children():
		child.queue_free();

	for to_id in directional_network.keys():
		for from_id in directional_network[to_id]['parents']:
			var beam = _main_scene.create_node(beam_path, self);
			beam.set_beam(directional_network[from_id]['point'], directional_network[to_id]['point'], directional_network[from_id]['color']);

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
			_update_beam_network()
