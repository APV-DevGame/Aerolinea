extends Control
class_name Data

# Referencias a los elementos de UI
@onready var horario_actual: Label = %HorarioActual
@onready var pasajeros_actual: Label = %PasajerosActual
@onready var vip: Label = %VIP
@onready var normal: Label = %Normal
@onready var total: Label = %Total
@onready var no_vendidos: Label = %NoVendidos
@onready var bar_horario: ProgressBar = %BarHorario

# TextureButtons en lugar de Buttons
@onready var play_stop: TextureButton = %PlayStop
@onready var reset: TextureButton = %Reset
@onready var next: TextureButton = %Next

# Texturas para los estados de play/stop (puedes configurarlas en el editor)
@export var play_texture: Texture2D
@export var stop_texture: Texture2D

var aerolinea: Aerolinea

func set_aerolinea(aerolinea_ref: Aerolinea) -> void:
	aerolinea = aerolinea_ref

func _process(delta: float) -> void:
	if aerolinea and aerolinea.horario_timer:
		# Calcular el progreso basado en el tiempo restante del timer
		var tiempo_restante = aerolinea.horario_timer.time_left
		var tiempo_total = aerolinea.horario_timer.wait_time
		var progreso = 100.0 - (tiempo_restante / tiempo_total) * 100.0
		
		# Actualizar la barra
		bar_horario.value = progreso

func update_ui() -> void:
	if not aerolinea:
		return
	
	# Actualizar información del horario
	horario_actual.text = Aerolinea.Horario.keys()[aerolinea.horario]
	
	# Calcular estadísticas
	var total_pasajeros = aerolinea.pasajeros_num.get(aerolinea.horario, 0)
	var total_boletos = aerolinea.total_requests
	var vip_count = 0
	var normal_count = 0
	var total_seats = 0
	
	for avion in aerolinea.aviones:
		vip_count += avion.ASIENTOS_VIP
		normal_count += avion.ASIENTOS_NORMALES
		total_seats += avion.ASIENTOS_NORMALES + avion.ASIENTOS_VIP
	
	# Actualizar labels
	pasajeros_actual.text = str(total_pasajeros)
	vip.text = str(vip_count)
	normal.text = str(normal_count)
	total.text = str(total_seats)
	no_vendidos.text = str(total_seats - total_boletos)
	
	# Actualizar textura del botón play/stop
	update_play_stop_button()

func update_play_stop_button() -> void:
	if not aerolinea:
		return
	
	if play_texture and stop_texture:
		# Cambiar la textura según el estado
		if aerolinea.is_playing:
			play_stop.texture_normal = stop_texture
		else:
			play_stop.texture_normal = play_texture
	else:
		# Fallback: cambiar tooltip si no hay texturas
		play_stop.tooltip_text = "Stop" if aerolinea.is_playing else "Play"

func set_bar_horario(value: float) -> void:
	bar_horario.value = value

func _on_reset_pressed() -> void:
	if aerolinea:
		aerolinea._on_reset_pressed()

func _on_play_stop_pressed() -> void:
	if aerolinea:
		aerolinea._on_play_stop_pressed()
		# Actualizar inmediatamente el botón después de presionar
		update_play_stop_button()

func _on_next_pressed() -> void:
	if aerolinea:
		aerolinea._on_next_pressed()
