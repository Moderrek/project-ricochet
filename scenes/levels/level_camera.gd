extends Camera2D

@export var trauma_reduction_rate: float = 1.0
@export var max_offset: Vector2 = Vector2(80.0, 80.0)
@export var max_roll: float = 0.05
@export var trauma_scale := 30.0
@export var noise_time_speed := 60.0

var trauma: float = 0.0
var time_y: float = 0.0

@onready var noise: FastNoiseLite = FastNoiseLite.new()

func _ready() -> void:
	set_process(false)
	GameManager.camera_shake_request.connect(add_trauma)
	
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	noise.seed = randi()
	noise.frequency = 0.5

func _exit_tree() -> void:
	if GameManager.camera_shake_request.is_connected(add_trauma):
		GameManager.camera_shake_request.disconnect(add_trauma)

func add_trauma(amount: float) -> void:
	var normalized_amount = amount / trauma_scale 
	trauma = clamp(trauma + normalized_amount, 0.0, 1.0)
	set_process(true)

func _process(delta: float) -> void:
	if trauma > 0.0:
		trauma = clamp(trauma - trauma_reduction_rate * delta, 0.0, 1.0)
		var shake = trauma * trauma 
		
		time_y += delta * noise_time_speed 
		
		offset.x = max_offset.x * shake * noise.get_noise_2d(0.0, time_y)
		offset.y = max_offset.y * shake * noise.get_noise_2d(100.0, time_y)
		
		rotation = max_roll * shake * noise.get_noise_2d(200.0, time_y)
		
	elif offset != Vector2.ZERO:
		offset = Vector2.ZERO
		rotation = 0.0
		set_process(false)
