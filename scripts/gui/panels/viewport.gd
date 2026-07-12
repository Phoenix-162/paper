extends PanelContainer


var mouse_sensitify = 0.005
var clicked = false

var move_speed = 10.0
func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed:
			clicked = true
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		elif not event.pressed :
			clicked = false
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if event is InputEventMouseMotion and clicked:
		%camera.rotation.x -= event.relative.y * mouse_sensitify
		%camera.rotation.y -= event.relative.x * mouse_sensitify
		%camera.rotation.x = clamp(%camera.rotation.x,deg_to_rad(-90),deg_to_rad(45))
func _process(delta: float) -> void:
	if clicked:
		var input_dir:Vector3 = Vector3.ZERO
		if Input.is_key_pressed(KEY_W):
			input_dir.z -= 1
		elif  Input.is_key_pressed(KEY_S):
			input_dir.z += 1
		elif  Input.is_key_pressed(KEY_A):
			input_dir.x -= 1
		elif  Input.is_key_pressed(KEY_D):
			input_dir.x += 1
		elif  Input.is_key_pressed(KEY_Q):
			%camera.position.y += 0.3
		elif  Input.is_key_pressed(KEY_E):
			%camera.position.y -= 0.3
		var global:Vector3 = (%camera.transform.basis * input_dir).normalized()
		%camera.position += global * move_speed * delta
