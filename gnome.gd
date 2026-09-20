extends CharacterBody3D
class_name Gnome
enum Type {BLUE, MAGE, GOLD}

var type: Type
var speechbus: int

var yapping: bool = false
var recruited: bool = false
var nome: String

func create():
	rolltype()
	animate()
	learntoyap()

func rolltype():
	type = Type.BLUE
	if Util.coinflip():
		type = Type.MAGE
		if Util.coinflip():
			type = Type.GOLD

func animate():
	$AnimatedSprite3D.animation = StringName("idling-" + Util.antidict(Type)[type].to_lower())
	$AnimatedSprite3D.set_frame_and_progress(randi(), randf())
	$AnimatedSprite3D.play()

func learntoyap():
	var effect = AudioEffectPitchShift.new()
	effect.pitch_scale = 2 ** randf_range(0.75, 1.25)
	AudioServer.add_bus()
	speechbus = AudioServer.bus_count - 1
	$AudioStreamPlayer3D.bus = AudioServer.get_bus_name(speechbus)
	AudioServer.add_bus_effect(speechbus, effect)

func _physics_process(delta: float):
	var distance = Util.coord(Global.player.position - global_position)
	if distance.length() > World.chunksize * World.maxradius or not is_inside_tree():
		get_parent().remove_child(self)
		Global.world.gnomes.erase(self)
		return
	if is_on_floor():
		if randf() < 0.3 * delta:
			velocity.y = 6
	else:
		velocity.y -= 16 * delta
	velocity = Util.posheight(distance.normalized() * (4 if recruited else 2), velocity.y)
	#for gnome in Global.world.gnomes:
		#if gnome != self:
			#var gnomedist = Util.coord(gnome.global_position - global_position)
			#if gnomedist.length() <= 8:
				#velocity += Util.posheight(gnomedist.normalized() / gnomedist.length() * -4)
	if distance.length() < 4 and randf() < 0.6 * delta:
		yap()
	move_and_slide()

func yap():
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

func recruit():
	recruited = true
	$AnimatedSprite3D.speed_scale *= 1.25
