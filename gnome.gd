extends CharacterBody3D
class_name Gnome
enum Type {BLUE, MAGE, GOLD}

var type: Type
var speechbus: int

var yapping := false
var initted := false  ###
var nome: String

func create() -> void:
	rolltype()
	animate()
	learntoyap()
	initted = true

func rolltype() -> void:
	type = Type.BLUE
	if Util.coinflip():
		type = Type.MAGE
		if Util.coinflip():
			type = Type.GOLD

func animate() -> void:
	$AnimatedSprite3D.animation = StringName("idling-" + Util.antienum(Type)[type].to_lower())
	$AnimatedSprite3D.set_frame_and_progress(randi(), randf())
	$AnimatedSprite3D.play()

func learntoyap() -> void:
	var effect := AudioEffectPitchShift.new()
	effect.pitch_scale = 2 ** randf_range(0.75, 1.25)
	AudioServer.add_bus()
	speechbus = AudioServer.bus_count - 1
	$AudioStreamPlayer3D.bus = AudioServer.get_bus_name(speechbus)
	AudioServer.add_bus_effect(speechbus, effect)

func _physics_process(delta: float) -> void:
	var displacement: Vector3 = Global.player.position - global_position  # why doesn't godot realize that Global.player is a Player when it's explicitly a Player skolaifuyhakiojrfh
	var dispcoord := Util.coord(displacement)
	var coordlen := dispcoord.length()
	if displacement.length() > World.chunksize * World.maxradius or not is_inside_tree() or not initted:
		get_parent().remove_child(self)
		Global.world.gnomes.erase(self)
		return
	if displacement.length() < 4 and randf() < 0.6 * delta:
		yap()
	if is_on_floor():
		var onyerhead: bool = abs(displacement.y + 2.75) < 0.5 and coordlen < 1
		if onyerhead or randf() < 0.3 * delta:
			jump()
	else:
		velocity.y -= 16 * delta
	var distancing := 1 if coordlen > 1.5 else (-1 if coordlen <= 1 else 0)
	velocity = Util.posheight(dispcoord.normalized() * 2 * distancing, velocity.y)
	move_and_slide()

func jump() -> void:
	velocity.y = 6

func yap() -> void:
	if yapping:
		return
	yapping = true
	$AnimatedSprite3D.speed_scale *= 4
	for word in randi_range(3, 6):
		AudioServer.get_bus_effect(speechbus, 0).pitch_scale = 2 ** randf_range(-0.25, 0.25)
		$AudioStreamPlayer3D.play()
		while $AudioStreamPlayer3D.playing:
			await get_tree().process_frame
	yapping = false
	$AnimatedSprite3D.speed_scale /= 4
