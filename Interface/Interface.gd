extends CanvasLayer

func _process(_delta):
	$HUX/VBoxContainer/TextureRect/energy.text = str(PlayerSheet.energy)
	$HUX/VBoxContainer/TextureRect/max_energy.text = str(PlayerSheet.max_energy)
