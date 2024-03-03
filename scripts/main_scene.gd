extends Node2D

var _result

# Get all children of the node that belongs to all of the given groups
func get_children_in_groups(node, groups, recursive = false):
	_result = []

	if recursive:
		_get_children_in_groups_recursive(node, groups)
		return _result

	for child in node.get_children():
		for group in groups:				
			if child.is_in_group(group):
				_result.append(child)
				break

	return _result

func _get_children_in_groups_recursive(node, groups):
	for child in node.get_children():
		var add_to_result = true;
		for group in groups:
			if not child.is_in_group(group):
				add_to_result = false;
				break
				
		if add_to_result:
			_result.append(child)

		_get_children_in_groups_recursive(child, groups)

func create_node(prefab_path, parent):
	var scene = load(prefab_path)
	var new_node = scene.instantiate()
	parent.add_child(new_node)
	return new_node
