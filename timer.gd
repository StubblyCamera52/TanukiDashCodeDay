extends Label


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	text = str(fmod(Time.get_ticks_msec()/60000,60),":",fmod((Time.get_ticks_msec()/1000),60),".",fmod(Time.get_ticks_msec(), 1000))
