extends Camera2D

@export var trauma_reduction_rate: float = 1.0
@export var max_offset: Vector2 = Vector2(80.0, 80.0)
@export var max_roll: float = 0.05

var trauma: float = 0.0
var time_y: float = 0.0

@onready var noise: FastNoiseLite = FastNoiseLite.new()

func _ready() -> void:
	GameManager.camera_shake_request.connect(add_trauma)
	
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	noise.seed = randi()
	noise.frequency = 0.5

func add_trauma(amount: float) -> void:
	var normalized_amount = amount / 30.0 
	trauma = clamp(trauma + normalized_amount, 0.0, 1.0)

func _process(delta: float) -> void:
	if trauma > 0.0:
		trauma = clamp(trauma - trauma_reduction_rate * delta, 0.0, 1.0)
		var shake = trauma * trauma 
		
		time_y += delta * 60.0
		
		offset.x = max_offset.x * shake * noise.get_noise_2d(0.0, time_y)
		offset.y = max_offset.y * shake * noise.get_noise_2d(100.0, time_y)
		
		rotation = max_roll * shake * noise.get_noise_2d(200.0, time_y)
		
	elif offset != Vector2.ZERO:
		offset = Vector2.ZERO
		rotation = 0.0
