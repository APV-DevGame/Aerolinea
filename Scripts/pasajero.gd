extends Control
class_name Pasajero

#{ "destino": Aerolinea.Destino, "personas": int, "is_vip": bool, "avion": Avion, "asientos": [Asiento] }

var id_pasajero: String = ""
var aerolinea: Aerolinea = null
var boletos: Dictionary = {}

var thread: Thread = null

func _ready():
	if aerolinea.is_playing:
		thread = Thread.new()
		thread.start(buy_boleto)

func buy_boleto() -> void:
	OS.delay_msec((randi_range(0,3) * 500))
	boletos["id"] = str(id_pasajero)
	boletos["destino"] = randi() % Aerolinea.Destino.size()
	boletos["is_vip"] = Aerolinea.Type.VIP if (randf() < 0.25) else Aerolinea.Type.NORMAL
	boletos["personas"] = randi_range(1, 3)
	boletos["avion"] = aerolinea.get_plane(boletos["destino"])
	var arr: Array = []
	
	var avion = boletos["avion"]
	var tipo = boletos["is_vip"]
	var num_personas = boletos["personas"]
	
	# Intentar asignar asientos
	if not try_assign_group_seats(avion, tipo, num_personas):
		if not try_assign_individual_seats(avion, tipo, num_personas):
			return

func try_assign_group_seats(avion, tipo, num_personas) -> bool:
	var grupo_asientos = avion.get_available_seats(tipo, num_personas)
	
	if not grupo_asientos.is_empty():
		var asientos = grupo_asientos.pick_random()
		boletos["asientos"] = asientos
		for asiento in boletos["asientos"]:
			aerolinea.request_seat(self, asiento)
		return true
	return false

func try_assign_individual_seats(avion, tipo, num_personas) -> bool:
	var asientos_individuales = []
	var asientos_disponibles = avion.get_available_seats(tipo, 1)
	
	if asientos_disponibles.size() < num_personas:
		return false
	
	# Tomar los primeros 'num_personas' asientos disponibles
	for i in range(num_personas):
		if i < asientos_disponibles.size():
			var grupo_individual = asientos_disponibles[i]
			var asiento_individual = grupo_individual[0]
			asientos_individuales.append(asiento_individual)
	
	boletos["asientos"] = asientos_individuales
	for asiento in boletos["asientos"]:
		aerolinea.request_seat(self, asiento)
	
	return true
	
func _exit_tree() -> void:
	if thread and thread.is_alive():
		thread.wait_to_finish()
