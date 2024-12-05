#dummy asset - ignore
extends CharacterBody3D

const SPEED: float = 2.0 
@export var detection_radius: float = 10.0
@onready var player: Node3D = null
var vel: Vector3 = Vector3.ZERO 

func _ready() -> void:
	player = get_tree().root.get_node("MainScene/Player")

func _physics_process(delta: float) -> void:
	if player:
		var distance_to_player = global_transform.origin.distance_to(player.global_transform.origin)
		if distance_to_player <= detection_radius:
			var direction = (player.global_transform.origin - global_transform.origin).normalized()
			vel = direction * SPEED
		else:
			vel = Vector3.ZERO
		move_and_slide()

func _on_Enemy_body_entered(body: Node3D) -> void:
	if body == player:
		print("Game Over! The enemy caught you.")
		get_tree().reload_current_scene() 
