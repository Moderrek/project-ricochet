extends Control

@onready var fluid_rect: Panel = $FluidRect
@onready var drain_particles: CPUParticles2D = $DrainParticles

var current_fill: float = 0.0

func set_fill_level(fill_level: float) -> void:
    fill_level = clamp(fill_level, 0.0, 1.0)
    current_fill = fill_level
    var bar_width = fluid_rect.size.x
    if drain_particles and fill_level > 0.04:
        drain_particles.emitting = true
    else:
        drain_particles.emitting = false
    drain_particles.position.x = bar_width * current_fill
    drain_particles.position.y = fluid_rect.size.y / 2.0
    fluid_rect.material.set_shader_parameter("fill_amount", fill_level)


