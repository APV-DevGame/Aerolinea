extends Control
class_name Pasajero

#{ "destino": Aerolinea.Destino, "personas": int, "is_vip": bool, "avion": Avion, "asientos": [Asiento] }

var id_pasajero: String = ""
var aerolinea: Aerolinea = null
var boletos: Dictionary = {}

var thread: Thread = null

func _ready():
	thread = Thread.new()
	thread.start(buy_boleto)

func buy_boleto() -> void:
	OS.delay_msec((randi_range(0,4) * 500))
	boletos["id"] = str(id_pasajero)
	boletos["destino"] = randi() % Aerolinea.Destino.size()
	boletos["is_vip"] = Aerolinea.Type.VIP if (randf() < 0.25) else Aerolinea.Type.NORMAL
	boletos["personas"] = randi_range(1, 3)
	boletos["avion"] = aerolinea.get_plane(boletos["destino"])
	
	var grupo_asientos = boletos["avion"].get_available_seats(boletos["is_vip"], boletos["personas"])
	if grupo_asientos.is_empty():
		return
	
	var asientos = grupo_asientos.pick_random()
	boletos["asientos"] = asientos
	for asiento in boletos["asientos"]:
		aerolinea.request_seat(self, asiento)
	
func _exit_tree() -> void:
	if thread and thread.is_alive():
		thread.wait_to_finish()
	
