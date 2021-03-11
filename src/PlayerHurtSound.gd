extends AudioStreamPlayer

class_name PlayerHurtSound

func _ready():
	connect("finished", self, "queue_free")
