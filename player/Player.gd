extends Area2D

export var speed = 400  # How fast the player will move (pixels/sec).
var screen_size  # Size of the game window.
# Target will control the move to mouse/tap logic
var target = Vector2()
var MIN_DISTANCE_TO_CONSIDER_MOUSE_MOVEMENT = 10

# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_viewport_rect().size
	hide()

func _process(delta):
	var velocity = calculateVelocity()
	updateAnimation(velocity)
	updatePosition(velocity, delta)

func isUsingMouseToMove():
	return position.distance_to(target) > MIN_DISTANCE_TO_CONSIDER_MOUSE_MOVEMENT

func calculateNewVelocityFromMouse():
	return (target - position).normalized()
	
func calculateNewVelocityFromKeyboard():
	var velocity = Vector2()
	
	if Input.is_action_pressed("ui_right"):
		velocity.x += 1
	if Input.is_action_pressed("ui_left"):
		velocity.x -= 1
	if Input.is_action_pressed("ui_down"):
		velocity.y += 1
	if Input.is_action_pressed("ui_up"):
		velocity.y -= 1
	
	return velocity

func calculateVelocity ():
	var velocity
	
	if isUsingMouseToMove():
		velocity = calculateNewVelocityFromMouse()
	else:
		velocity = calculateNewVelocityFromKeyboard()
	
	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
	return velocity

func updateAnimation(velocity):
	if velocity.length() > 0:
		$AnimatedSprite.play()
	else:
		$AnimatedSprite.stop()
	if velocity.x != 0:
		$AnimatedSprite.animation = "right"
		$AnimatedSprite.flip_v = false
		# See the note below about boolean assignment
		$AnimatedSprite.flip_h = velocity.x < 0
	elif velocity.y != 0:
		$AnimatedSprite.animation = "up"
		$AnimatedSprite.flip_v = velocity.y > 0

func updatePosition(velocity, delta):
	position += velocity * delta
	position.x = clamp(position.x, 0, screen_size.x)
	position.y = clamp(position.y, 0, screen_size.y)
	if not isUsingMouseToMove():
		target = position

func start(pos):
	position = pos
	# Initialize the target as the position
	target = position
	show()
	$CollisionShape2D.disabled = false

# Change the target whenever a touch event happens
func _input(event):
	if event is InputEventScreenDrag or event is InputEventScreenTouch:
		target = event.position

# Adding a signal for when the player is hit
signal hit
func _on_Player_body_entered(body):
	hide()  # Player disappears after being hit.
	emit_signal("hit")
	$CollisionShape2D.set_deferred("disabled", true)