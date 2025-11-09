extends Control
class_name Avion

@export var zones: int = 2

@onready var seat_scene: PackedScene = preload("res://Scenes/asiento.tscn")
@onready var seats_container: HBoxContainer = %SeatsContainer
@onready var destino_label: Label = %Destino
@onready var estado_label: Label = %Estado
@onready var bar_vip: ProgressBar = %BarVIP
@onready var bar_normal: ProgressBar = %BarNormal
@onready var mutex: Mutex = Mutex.new()

#MAX 258 = ASIENTOS_NORMALES + ASIENTOS_VIP
const ASIENTOS_NORMALES = 79 
const ASIENTOS_VIP = 50 

var aerolinea: Aerolinea = null

var id_avion: String = ""
var disponible: bool = true
var destino: Aerolinea.Destino = Aerolinea.Destino.COLOMBIA
var horario: Aerolinea.Horario = Aerolinea.Horario.MAÑANA

var asientos: Dictionary = {} # { Asiento: Pasajero } 
var asientos_por_posicion: Dictionary = {}  # { Vector2i: Asiento }
var c_normales: int = 0
var c_vip: int = 0

var letras_fila = ["A", "B", "C", "D", "E", "F"]

func _ready() -> void:
	create_seats()

func set_data(data: Dictionary) -> void:
	destino = data["destino"]
	horario = data["horario"]
	id_avion = str(data["id"])
	disponible = true
	update_ui()

func update_ui() -> void:
	destino_label.text = str(Aerolinea.Destino.keys()[destino])
	estado_label.text = "Disponible" if disponible else "No Disponible"
	bar_vip.max_value = ASIENTOS_VIP
	bar_vip.value = c_vip
	bar_normal.max_value = ASIENTOS_NORMALES
	bar_normal.value = c_normales

func get_size_plane() -> Vector2i:
	return Vector2i.ZERO
func create_seats() -> void:
	# Limpiar el contenedor principal y diccionarios
	for child in seats_container.get_children():
		child.queue_free()
	
	asientos.clear()
	asientos_por_posicion.clear()
	
	seats_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	seats_container.alignment = BoxContainer.ALIGNMENT_CENTER
	
	# Calcular columnas para cada tipo
	var columnas_normales = ceili(float(ASIENTOS_NORMALES) / 6.0)
	var columnas_vip = ceili(float(ASIENTOS_VIP) / 6.0)
	
	# Crear columnas NORMALES
	crear_columnas_zona(0, columnas_normales, ASIENTOS_NORMALES, Aerolinea.Type.NORMAL)
	
	# Crear columnas VIP
	crear_columnas_zona(columnas_normales, columnas_vip, ASIENTOS_VIP, Aerolinea.Type.VIP)

func crear_columnas_zona(columna_inicio: int, num_columnas: int, total_asientos: int, tipo: Aerolinea.Type) -> void:
	var asientos_creados = 0
	
	for columna in range(num_columnas):
		var columna_container = VBoxContainer.new()
		columna_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
		columna_container.alignment = BoxContainer.ALIGNMENT_CENTER
		seats_container.add_child(columna_container)
		
		var num_columna_real = columna_inicio + columna
		
		# PRIMER GRUPO: 3 asientos superiores
		for fila in range(3):
			var posicion = Vector2i(fila, num_columna_real)
			var seat: Asiento = seat_scene.instantiate()
			columna_container.add_child(seat)
			
			var id = "%s%d" % [letras_fila[fila], num_columna_real + 1]
			var tipo_real = tipo if asientos_creados < total_asientos else Aerolinea.Type.EMPTY
			
			seat.set_data({ "id": id, "avion": self, "tipo": tipo_real, "pos": posicion })
			
			asientos[seat] = null
			asientos_por_posicion[posicion] = seat
			
			if tipo_real != Aerolinea.Type.EMPTY:
				asientos_creados += 1
		
		# ESPACIADOR CENTRAL - ahora es un asiento EMPTY especial
		var spacer_seat: Asiento = seat_scene.instantiate()
		columna_container.add_child(spacer_seat)
		spacer_seat.set_data({
			"id": "SPACER_%d" % num_columna_real,
			"avion": self,
			"tipo": Aerolinea.Type.EMPTY,
			"pos": Vector2i(-1, num_columna_real)  # Posición especial para espaciadores
		})
		asientos[spacer_seat] = null
		
		# SEGUNDO GRUPO: 3 asientos inferiores
		for fila in range(3, 6):
			var posicion = Vector2i(fila, num_columna_real)
			var seat: Asiento = seat_scene.instantiate()
			columna_container.add_child(seat)
			
			var id = "%s%d" % [letras_fila[fila], num_columna_real + 1]
			var tipo_real = tipo if asientos_creados < total_asientos else Aerolinea.Type.EMPTY
			
			seat.set_data({ "id": id, "avion": self, "tipo": tipo_real, "pos": posicion })
			
			asientos[seat] = null
			asientos_por_posicion[posicion] = seat
			
			if tipo_real != Aerolinea.Type.EMPTY:
				asientos_creados += 1
	
func add_pasajero(asiento: Asiento, pasajero: Pasajero) -> void:
	asientos[asiento] = pasajero
	if asiento.tipo == Aerolinea.Type.NORMAL:
		c_normales += 1
	else:
		c_vip += 1
	call_deferred("update_ui")

func get_available_seats(is_vip: Aerolinea.Type, personas: int) -> Array:
	# Buscar grupos de asientos consecutivos en la misma columna y zona
	var grupos_encontrados = []
	
	# Para cada asiento disponible del tipo solicitado
	for seat in asientos:
		if asientos[seat] == null and seat.tipo == is_vip:
			# Verificar si podemos formar un grupo a partir de este asiento
			var grupo = [seat]
			var zona_superior = seat.pos.x < 3  # Si está en filas 0-2 (zona superior)
			
			# Buscar los siguientes asientos en la misma columna y zona
			for i in range(1, personas):
				var siguiente_fila = seat.pos.x + i
				# Verificar que no nos salgamos de la zona
				if (zona_superior and siguiente_fila >= 3) or siguiente_fila >= 6:
					break
				
				var siguiente_pos = Vector2i(siguiente_fila, seat.pos.y)
				var siguiente_asiento = asientos_por_posicion.get(siguiente_pos)
				
				# Verificar si el siguiente asiento es válido y disponible
				if (siguiente_asiento and 
					siguiente_asiento.tipo == is_vip and 
					asientos[siguiente_asiento] == null):
					grupo.append(siguiente_asiento)
				else:
					break
			
			# Si encontramos un grupo del tamaño requerido, agregarlo
			if grupo.size() == personas:
				grupos_encontrados.append(grupo)
	
	return grupos_encontrados
