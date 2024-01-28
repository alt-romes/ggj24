extends Node3D

@onready var timer := Timer.new()
@export var screen: TextureRect
@export var winscreen: Control

@export var followers: Array[Follower]

# Called when the node enters the scene tree for the first time.
func _ready():
	timer.one_shot = true
	timer.wait_time = 5.0
	add_child(timer)
	timer.connect("timeout", _end_title_screen.bind(timer))
	timer.start()

func _end_title_screen(timer):
	screen.visible = false
	timer.queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var totalHappy = 0
	for f in followers:
		if f.state == 1:
			totalHappy += 1
			
	if totalHappy > 0.5*31:
		winscreen.visible = true
		
