extends Control


var _labels
var _main_scene

@export var debug_label_path: String

var _labels_dict = {}


func _ready():
	_labels = get_node('labels');
	_main_scene = get_node('/root/main_scene');

func _process(_delta):
	_labels_dict = {}
	for label in _labels.get_children():
		label.queue_free()

func add_label(key, text):
	if false:
		print(key + ' ' + text)

	if key in _labels_dict.keys():
		_labels_dict[key].text = text
	else:
		var label = _main_scene.create_node(debug_label_path, _labels)
		_labels_dict[key] = label;
		label.text = text;


