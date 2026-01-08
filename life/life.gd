extends Node2D

const grid_color = Color.DARK_GRAY
const EXTENSION_FACTOR = 4
const NEIGHBOR_OFFSETS := [
	Vector2(-1, -1), Vector2(0, -1), Vector2(1, -1),
	Vector2(-1,  0),                 Vector2(1,  0),
	Vector2(-1,  1), Vector2(0,  1), Vector2(1,  1),
]
@export var grid_size: Vector2 = Vector2(48, 48)
var occupied_cells: Array[Vector2] = []
@onready var camera_body: CharacterBody2D = $CameraBody
@onready var camera_2d: Camera2D = $CameraBody/Camera2D
@onready var viewport: Viewport = get_viewport()

func _ready() -> void:
	if camera_body:
		camera_body.camera_updated.connect(update_grid)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			var grid_position = get_grid_mouse_position()
			if grid_position in occupied_cells:
				return
			else:
				occupied_cells.append(grid_position)
			update_grid()
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			var grid_position = get_grid_mouse_position()
			if grid_position not in occupied_cells:
				return
			else:
				occupied_cells.erase(grid_position)
			update_grid()
	if event.is_action_pressed("ui_accept"):
		advance_game_state()

func _draw() -> void:
	draw_grid()
	draw_squares()
	
func draw_grid():
	if not camera_2d:
		return
	
	var viewport_size = get_viewport_rect().size
	var camera_pos = camera_2d.position
	var camera_zoom = camera_2d.zoom
	
	var world_top_left = camera_pos - (viewport_size * camera_zoom / 2)
	var world_bottom_right = camera_pos + (viewport_size * camera_zoom / 2)
	
	var extended_top_left = world_top_left - viewport_size * camera_zoom * EXTENSION_FACTOR
	var extended_bottom_right = world_bottom_right + viewport_size * camera_zoom * EXTENSION_FACTOR
	
	var start_x = floor(extended_top_left.x / grid_size.x) * grid_size.x
	var end_x = ceil(extended_bottom_right.x / grid_size.x) * grid_size.x
	
	for x in range(start_x, end_x + grid_size.x, grid_size.x):
		draw_line(
			Vector2(x, extended_top_left.y),
			Vector2(x, extended_bottom_right.y),
			grid_color
		)
	
	var start_y = floor(extended_top_left.y / grid_size.y) * grid_size.y
	var end_y = ceil(extended_bottom_right.y / grid_size.y) * grid_size.y
	
	for y in range(start_y, end_y + grid_size.y, grid_size.y):
		draw_line(
			Vector2(extended_top_left.x, y),
			Vector2(extended_bottom_right.x, y),
			grid_color
		)

func draw_squares():
	for i in occupied_cells:
		draw_rect(Rect2((Vector2(i) * grid_size), grid_size), Color.WHITE)

func update_grid() -> void:
	queue_redraw()

func get_world_mouse_pos() -> Vector2:
	var mouse_pos = get_viewport().get_mouse_position()
	var cam_pos = camera_body.global_position
	return cam_pos + (mouse_pos - Vector2(viewport.size / 2)) / camera_2d.zoom

func get_grid_mouse_position() -> Vector2:
	var world_pos = get_world_mouse_pos()
	return Vector2(
		floor(world_pos.x / grid_size.x),
		floor(world_pos.y / grid_size.y)
	)

func get_occupied_neighbors(cell: Vector2) -> int:
	var count := 0
	for offset in NEIGHBOR_OFFSETS:
		if cell + offset in occupied_cells:
			count += 1
	return count

func advance_game_state():
	var new_occupied: Array[Vector2] = []
	var candidates: Dictionary = {}

	# 1. Survival / death
	for cell in occupied_cells:
		var n := get_occupied_neighbors(cell)
		if n == 2 or n == 3:
			new_occupied.append(cell)

		# Track empty neighbors as birth candidates
		for offset:Vector2 in NEIGHBOR_OFFSETS:
			var candidate := cell + offset
			if candidate not in occupied_cells:
				candidates[candidate] = true

	# 2. Births
	for cell in candidates.keys():
		if get_occupied_neighbors(cell) == 3:
			new_occupied.append(cell)

	occupied_cells = new_occupied
	update_grid()
