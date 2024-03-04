extends Node2D


var _line: Line2D

@export var blue_color: Color
@export var red_color: Color
@export var none_color: Color


func _ready():
	_line = get_node('line');

func set_beam(pos_from, pos_to, color):
	global_position = pos_from;
	_line.points[1] = pos_to - pos_from;

	if color == 'blue':
		_line.default_color = blue_color;
	if color == 'red':
		_line.default_color = red_color;
	if color == 'none':
		_line.default_color = none_color;




