extends CharacterBody2D
signal camera_updated
@export_subgroup("Movement Stats")
@export var move_speed := 600.0
@export var acceleration := 1500.0
@export var friction := 1200.0
@onready var camera_2d: Camera2D = $Camera2D

func _process(delta: float) -> void:
	var move_input = Input.get_vector("left", "right", "up", "down")
	
	var target_velocity = move_input * move_speed
	
	velocity = velocity.move_toward(target_velocity, acceleration * delta)
	
	if move_input.length() < 0.1:
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
		
	move_and_slide()
	
	if get_last_motion() > Vector2(0.0, 0.0):
		camera_updated.emit()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			if camera_2d.zoom + Vector2(.1, .1) >= Vector2(2.0, 2.0):
				return
			camera_2d.zoom += Vector2(.1, .1)
			camera_updated.emit()
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			if camera_2d.zoom - Vector2(.1, .1) <= Vector2(0.0, 0.0):
				return
			camera_2d.zoom -= Vector2(.1, .1)
			camera_updated.emit()
