extends Node2D


var _main_scene
var _world

@export_flags_2d_physics var negation_collision_layer


func _ready():
	_main_scene = get_node('/root/main_scene')
	_world = get_node('/root/main_scene/world')


func update_beam_network():
	var relays = _main_scene.get_children_in_groups(_world, ['relay'], true)
	var relay_to_id = {}
	var id_to_relay = {}
	var next_id = 0;
	for relay in relays:
		relay_to_id[relay] = next_id;
		id_to_relay[next_id] = relay;
		next_id += 1

	var directional_network = {}

	for id in id_to_relay.keys():
		directional_network[id] = {'color': 'none', 'depth': 9999, 'point': id_to_relay[id].global_position, 'outgoing_edges': [], 'handled': false}
		if id_to_relay[id].is_emitter:
			directional_network[id] = {'color': 'blue', 'depth': 0, 'point': id_to_relay[id].global_position, 'outgoing_edges': [], 'handled': false}

	var modified_directional_network = directional_network
	var dirty = false;

	while(true):
		for id in directional_network.keys():
			if modified_directional_network[id]['handled']:
				continue;

			var relay = id_to_relay.get(id, false)

			if relay:
				var color = directional_network[id]['color'];
				if color == 'none':
					continue;

				for target_relay in id_to_relay[id].connected_relays:
					if directional_network[relay_to_id[target_relay]]['depth'] <= directional_network[id]['depth']:
						continue;

					var negation_points = _get_beam_negation_points(id_to_relay[id], target_relay);
					
					dirty = true;

					if len(negation_points) == 0:
						modified_directional_network[id]['outgoing_edges'].append(relay_to_id[target_relay])
						modified_directional_network[id]['handled'] = true;
						modified_directional_network[relay_to_id[target_relay]]['color'] = color;
						modified_directional_network[relay_to_id[target_relay]]['depth'] = modified_directional_network[id]['depth'] + 1;

					var negations = 0;
					var prev_id = 0;
					for point in negation_points:
						if negations == 0:
							modified_directional_network[id]['outgoing_edges'].append(next_id);
							modified_directional_network[id]['handled'] = true;
							
						if negations >= 1:
							modified_directional_network[prev_id]['outgoing_edges'].append(next_id);

						negations += 1;
						modified_directional_network[next_id] = {'color': _calculate_negated_color(color, negations), 'depth': directional_network[id]['depth'], 'point': point, 'outgoing_edges': [], 'handled': true}
						prev_id = next_id;
						next_id += 1

					modified_directional_network[relay_to_id[target_relay]]['color'] = _calculate_negated_color(color, negations);
					modified_directional_network[relay_to_id[target_relay]]['depth'] = modified_directional_network[id]['depth'] + 1;
		
		if dirty:
			directional_network = modified_directional_network;
		else:
			break;
	
	print(directional_network);

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
