extends SpotLight3D

@export_range(0.0, 8.0, 0.1) var min_energy: float = 0.5  #minimum light
@export_range(0.0, 8.0, 0.1) var max_energy: float = 5.0  #maximum light 
@export_range(0.05, 1.0, 0.05) var min_flicker_interval: float = 0.1  #min flicker interval
@export_range(0.05, 1.0, 0.05) var max_flicker_interval: float = 0.3  #max flicker interval

func _ready():
	_flicker_light()

func _flicker_light() -> void:
	while true:
		light_energy = randf_range(min_energy, max_energy)
		await get_tree().create_timer(randf_range(min_flicker_interval, max_flicker_interval)).timeout
