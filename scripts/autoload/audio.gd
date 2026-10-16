extends Node
## Zvuky a hudba. Soubory vyrábí tools/make_sounds.py.

const SOUNDS := ["click", "pickup", "discover", "treasure", "quest", "eat", "water", "splash", "plop", "brush", "rustle", "neigh", "boing"]

var enabled := true:
	set(value):
		enabled = value
		AudioServer.set_bus_mute(0, not value)

var _streams := {}
var _players: Array[AudioStreamPlayer] = []
var _music: AudioStreamPlayer
var _music_name := ""


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	for sound in SOUNDS:
		_streams[sound] = load("res://assets/audio/%s.wav" % sound)
	for i in 6:
		var player := AudioStreamPlayer.new()
		add_child(player)
		_players.append(player)
	_music = AudioStreamPlayer.new()
	_music.volume_db = -9.0
	add_child(_music)


## Přehraje zvuk; mírně mění výšku, aby se opakování neohrála.
func play(sound: String, pitch_spread := 0.08) -> void:
	if not _streams.has(sound):
		return
	for player in _players:
		if not player.playing:
			player.stream = _streams[sound]
			player.pitch_scale = 1.0 + randf_range(-pitch_spread, pitch_spread)
			player.play()
			return


func music(track: String) -> void:
	if track == _music_name:
		return
	_music_name = track
	var stream: AudioStreamWAV = load("res://assets/audio/music_%s.wav" % track)
	stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	stream.loop_begin = 0
	stream.loop_end = stream.data.size() / 2
	_music.stream = stream
	_music.play()
