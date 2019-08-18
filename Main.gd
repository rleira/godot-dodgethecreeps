extends Node

export (PackedScene) var Mob
var score

func _ready():
	randomize()
	newGame()

func gameOver():
	$ScoreTimer.stop()
	$MobTimer.stop()
	$HUD.showGameOver()
	$Music.stop()
	$DeathSound.play()

func newGame():
	score = 0
	$Player.start($StartPosition.position)
	$StartTimer.start()
	$HUD.updateScore(score)
	$HUD.showMessage("Get Ready")
	$HUD.hideStartButton()
	$Music.play()

func _on_MobTimer_timeout():
	# Choose a random location on Path2D.
	$MobPath/MobSpawnLocation.set_offset(randi())
	# Create a Mob instance and add it to the scene.
	var mob = Mob.instance()
	add_child(mob)
	# Set the mob's direction perpendicular to the path direction.
	var direction = $MobPath/MobSpawnLocation.rotation + PI / 2
	# Set the mob's position to a random location.
	mob.position = $MobPath/MobSpawnLocation.position
	# Add some randomness to the direction.
	direction += rand_range(-PI / 4, PI / 4)
	mob.rotation = direction
	# Set the velocity (speed & direction).
	mob.linear_velocity = Vector2(rand_range(mob.min_speed, mob.max_speed), 0)
	mob.linear_velocity = mob.linear_velocity.rotated(direction)
	
	# Connect delete of mobs at game end
	$HUD.connect("start_game", mob, "_on_start_game")

func _on_ScoreTimer_timeout():
	score += 1
	$HUD.updateScore(score)

func _on_StartTimer_timeout():
	$MobTimer.start()
	$ScoreTimer.start()

