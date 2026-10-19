extends Node2D
## Vrstva, která se kreslí zavoláním `paint(self)`. Znovu se kreslí jen na požádání (queue_redraw),
## takže nehybné věci (tráva, stromy, voda) stojí výkon jen jednou, ne v každém snímku.

var paint: Callable


func _draw() -> void:
	paint.call(self)
