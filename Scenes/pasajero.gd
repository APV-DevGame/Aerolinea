extends Control
class_name Pasajero

#{
	#"asiento": Vector2i.ZERO,
	#"avion": "",
	#"horario": Aerolinea.Horario.MAÑANA,
	#"destino": Aerolinea.Destino.COLOMBIA
#}

var aerolinea: Aerolinea = null
var boletos: Array[Dictionary] = []

var thread: Thread = null

func _ready():
	thread = Thread.new()
	thread.start(buy_boleto)

func pick_destino() -> Aerolinea.Destino:
	return (randi() % 3) as Aerolinea.Destino

func buy_boleto() -> void:
	OS.delay_msec(randi_range(0,3))
	var destino: Aerolinea.Destino = pick_destino()
	var people: int = randi_range(0,3)
