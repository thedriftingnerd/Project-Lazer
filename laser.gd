extends RayCast3D

@onready var beam = $beam
@onready var splash = $splash

var tween: Tween
var beam_rad: float = 0.03

func _ready(): #starts laser act/deact cycle
	_call_laser_cycle()

func _process(delta):
	force_raycast_update()
	if is_colliding():#beam length and splash depth based on collision point
		var cast_point = to_local(get_collision_point())
		beam.height = cast_point.y
		beam.position.y = cast_point.y / 2
		splash.position.y = cast_point.y

#beaming scotty up
func activate(time: float) -> void:
	tween = get_tree().create_tween()
	visible = true
	splash.emitting = true
	tween.set_parallel(true)
	tween.tween_property(beam.mesh, "top_radius", beam_rad, time)
	tween.tween_property(beam.mesh, "bottom_radius", beam_rad, time)
	tween.tween_property(splash.process_material, "scale_min", 1, time)
	await tween.finished
	visible = true
	
#beaming scotty down
func deactivate(time: float) -> void:
	tween = get_tree().create_tween()
	tween.set_parallel(true)
	tween.tween_property(beam.mesh, "top_radius", 0, time)
	tween.tween_property(beam.mesh, "bottom_radius", 0, time)
	tween.tween_property(splash.process_material, "scale_min", 0, time)
	await tween.finished
	visible = false
	splash.emitting = false

func _call_laser_cycle() -> void: #continuously acts/deacts the laser
	while true:
		await get_tree().create_timer(2.0).timeout
		await deactivate(1)
		await get_tree().create_timer(2.0).timeout
		await activate(1)
