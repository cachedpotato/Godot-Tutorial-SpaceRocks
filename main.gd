extends Node
@export var rock_scene: PackedScene;
var screensize: Vector2 = Vector2.ZERO;

var level: int = 1
var life: int = 2


# Called when the node enters the scene tree for the first time.
func _ready():
  pass # Replace with function body.
  screensize = get_viewport().get_visible_rect().size;
  for i in 3:
    spawn_rock(3);


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
  if get_tree().get_nodes_in_group("rocks").size() == 0:
    for i in level + 3:
      spawn_rock(3)
    level += 1

func spawn_rock(size, pos = null, vel = null):
  if pos == null:
    $RockPath/RockSpawn.progress = randi();
    pos = $RockPath/RockSpawn.position;
  
  if vel == null:
    vel = Vector2.RIGHT.rotated(randf_range(0, TAU)) * randi_range(50, 125);
  
  var r = rock_scene.instantiate();
  r.screensize = screensize;
  r.start(pos, vel, size);
  call_deferred("add_child", r)


