extends Node2D

const color = Color.DARK_GRAY
@export var grid_size: Vector2 = Vector2(48, 48)

@onready var camera: Camera2D = $Camera2D
@onready var viewport: Viewport = get_viewport()

func _process(_delta: float) -> void:
	queue_redraw()
	
func _draw() -> void:
	var viewport_size = viewport.size
	var camera_pos = camera.position
	var vp_right = viewport_size.x * camera.zoom.x
	var vp_bottom = viewport_size.y * camera.zoom.y
	
	var leftmost = -vp_right + camera_pos.x
	var topmost = -vp_bottom + camera_pos.y
	
	var left = ceil(leftmost / grid_size.x) * grid_size.x
	var bottommost = vp_bottom + camera_pos.y
	for x in range(0, viewport_size.x / camera.zoom.x + 1):
		draw_line(Vector2(left, topmost), Vector2(left, bottommost), color)
		left += grid_size.x
	
	var top = ceil(topmost / grid_size.y)  * grid_size.y
	var rightmost = vp_right + camera_pos.x
	for y in range(0, viewport_size.y / camera.zoom.y + 1):
		draw_line(Vector2(leftmost, top), Vector2(rightmost, top), color)
		top += grid_size.y
