extends Control
class_name Avion

@export var zones: int = 2

const ASIENTOS_NORMALES = 300
const ASIENTOS_VIP = 50

var id_avion: String = ""
# { Asiento: Pasajero } 
var pasajeros: Dictionary = {}
var disponible: bool = true
var destino: Aerolinea.Destino = Aerolinea.Destino.COLOMBIA
var horario: Aerolinea.Horario = Aerolinea.Horario.MAÑANA
var row: int = 0
var columns: int = 0

func get_size_plane() -> Vector2i:
	var i: int = 0
	while true:
		i += 1
		if ASIENTOS_NORMALES % 3 == 0 and ASIENTOS_VIP % i == 0:
			return Vector2i.DOWN
	return Vector2i.ZERO

func create_seats() -> void:
	pass
	
func add_pasajero() -> void:
	pass

func get_available_seats() -> Array:
	var seats: Array = []
	for seat in pasajeros.keys():
		if seat.state == Asiento.AsientoState.NO_OCUPADO:
			seats.append(seat)
	return seats
