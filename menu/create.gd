extends Button
# Yes, this script exists only for this

func _process(_delta):
	if $"../level_select".selected != -1:
		disabled = false
	else:
		disabled = true
