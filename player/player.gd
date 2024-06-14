extends RigidBody2D

@export var engine_power: float = 500;
@export var spin_power: float = 8000; 
@export var bullet_scene : PackedScene;

var fire_rate: float = 0.25;
var can_shoot: bool = true;

var thrust: Vector2 = Vector2.ZERO;
var rotation_dir: float = 0;

var screensize: Vector2 = Vector2.ZERO;
var radius: int = int(124/2);


enum {INIT, ALIVE, INVULNERABLE, DEAD}
var state = INIT;

# Called when the node enters the scene tree for the first time.
func _ready():
  change_state(ALIVE);
  screensize = get_viewport_rect().size
  $GunCooldown.wait_time = fire_rate;

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
  get_input()

func _on_gun_cooldown_timeout():
  can_shoot = true;

func change_state(new_state):
  match new_state:
    INIT:
      $CollisionShape2D.set_deferred("disabled", true);
    ALIVE:
      $CollisionShape2D.set_deferred("disabled", false);
    INVULNERABLE:
      $CollisionShape2D.set_deferred("disabled", true);
    DEAD:
      $CollisionShape2D.set_deferred("disabled", true);
  state = new_state

func get_input():
  thrust = Vector2.ZERO;
  if state in [DEAD, INIT]:
    return
  if Input.is_action_pressed("thrust"):
    #transform.x > forward momentum
    thrust = transform.x * engine_power;
  rotation_dir = Input.get_axis("rotate_left", "rotate_right")
  if Input.is_action_pressed("shoot") and can_shoot:
    shoot();

func _physics_process(delta):
  constant_force = thrust;
  constant_torque = rotation_dir * spin_power;

#safely access PhysicsDirectBodyState2D
#Which contains a bunch of useful state information (phyics state not our custom one)
func _integrate_forces(physics_state):
  var xform = physics_state.transform;
  #for smoother wrapping
  xform.origin.x = wrapf(xform.origin.x, 0 - radius, screensize.x + radius);
  xform.origin.y = wrapf(xform.origin.y, 0 - radius, screensize.y + radius);
  physics_state.transform = xform;

func shoot():
  if state == INVULNERABLE: return
  can_shoot = false;
  $GunCooldown.start();
  var bullet = bullet_scene.instantiate();
  get_tree().root.add_child(bullet);
  bullet.start($Muzzle.global_transform);
  $LaserSound.play();
  pass

func explode():
  $CollisionShape2D.set_deferred("disabled", true)
  $Sprite2D.hide()
  $Explosion/AnimationPlayer.play("explosion")
  $Explosion.show()
  linear_velocity = Vector2.ZERO
  angular_velocity = 0
  await $Explosion/AnimationPlayer.animation_finished
  set_process(false)
  change_state(DEAD)

