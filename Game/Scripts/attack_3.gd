extends Area3D

var BlastRadius
var BlastDamage
@export var BlastCollider : CollisionShape3D
@export var BlastParticles : GPUParticles3D
@export var SmokeParticles : GPUParticles3D

func _ready() -> void:
    # 1. Setup the collision shape to match the huge blast radius
    var new_shape = CylinderShape3D.new()
    new_shape.radius = BlastRadius
    new_shape.height = 5.0 # Give it some vertical height so it hits taller enemies
    if BlastCollider:
        BlastCollider.shape = new_shape
        
    # 2. Setup particles if you have them
    if BlastParticles and BlastParticles.process_material:
        BlastParticles.process_material.emission_sphere_radius = BlastRadius
        BlastParticles.amount = int(20 * BlastRadius)
    if SmokeParticles and SmokeParticles.process_material:
        SmokeParticles.process_material.emission_sphere_radius = BlastRadius
        SmokeParticles.amount = int(20 * BlastRadius)
        
    BlastParticles.restart()
    SmokeParticles.restart()
    # 3. Connect the signal via code so you don't have to do it in the editor
    body_entered.connect(_on_body_entered)
	
    
    # 4. Wait a brief moment to let the physics engine register overlapping bodies, then cleanup
    # 0.5 seconds gives the explosion enough time to apply damage
    await get_tree().create_timer(2).timeout
    queue_free()

func _on_body_entered(body: Node3D) -> void:
    # Damage all objects that have the Damage function
    if body.is_in_group("Enemy") and body.has_method("Damage"):
        body.Damage(BlastDamage)
