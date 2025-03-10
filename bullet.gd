extends Area2D

@export var speed: int = 1000;
var velocity: Vector2 = Vector2.ZERO;

# Called when the node enters the scene tree for the first time.
func _ready():
  pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
  position += velocity*delta;

# called every frame
func start(_transform):
  #transform here is the transform we see in the inspector
  transform = _transform;
  velocity = transform.x * speed;


func _on_visible_on_screen_notifier_2d_screen_exited():
  queue_free();


func _on_body_entered(body):
  if body.is_in_group("rocks"):
    body.explode();
    queue_free();
