extends Camera2D

var mouse_start_pos
var screen_start_position

var dragging = false

func _input(event):
	if event is InputEventMouseButton:
		if event.is_pressed():
			mouse_start_pos = event.position
			screen_start_position = position
			dragging = true
		else:
			dragging = false
	elif event is InputEventMouseMotion and dragging:
		var speed = Vector2(1/zoom.x,1/zoom.y)
		global_position = speed * (mouse_start_pos - event.position) + screen_start_position

func _process(_delta):
	if Input.is_action_just_released("zoom+"):
		zoom.x += 0.1
		zoom.y += 0.1
	if Input.is_action_just_released("zoom-"):
		if zoom.x - 0.1 > 0.1:
			zoom.x -= 0.1
			zoom.y -= 0.1
