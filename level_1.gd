extends NavigationRegion3D

@onready var enemy = $level1/enemy
@onready var player = $level1/player
@onready var nav_region = $level1/NavigationRegion3D

func _ready() -> void:
	enemy.set_nav(nav_region)
	enemy.set_target(player)
