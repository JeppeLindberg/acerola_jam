extends Node2D


@export var connected_relays: Array[Node2D]

var is_emitter = false;
var is_reciever = false;
var is_transmitter = false



func _ready():
	add_to_group('relay');

func make_emitter():
	is_emitter = true;

func make_reciever():
	is_reciever = true;

func make_transmitter():
	is_transmitter = true;

