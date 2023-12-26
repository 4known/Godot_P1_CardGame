extends Area2D
class_name Projectile

var speed : int = 2
var direction : Vector2

var shooter : Card
var target : Card = null
var penetrating : bool = false
var damage : int = 0

var start : bool = false

func _physics_process(_delta):
	if !start: return
	global_position += speed * direction * _delta

func setProjectile(s : Card, t : Card, d : int):
	shooter = s
	target = t
	damage = d
	direction = target.getSpritePos() - shooter.global_position
	global_rotation = direction.angle()
	start = true

func _on_area_entered(area):
	if area == target:
		queue_free()
		target.getStatus().updateHealth(damage)
		shooter.getSkill().attackTarget(target)
		Signals.emit_signal("projectileHitTarget")

func _on_timer_timeout():
	queue_free()
