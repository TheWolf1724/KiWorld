class_name EnemyData
extends Resource
## Definicion de un tipo de enemigo (estilo ScriptableObject).
## Crea variantes nuevas guardando .tres o instanciando en GameData.
## Cuando tengas pixel-art, anade aqui el campo de la spritesheet/animaciones.

@export var id: StringName = &"dummy"
@export var display_name: String = "Enemigo"
@export var color: Color = Color(0.85, 0.3, 0.3)
@export var size: float = 8.0            ## radio de colision (px)
@export var sprite_row: int = 0          ## fila en assets/enemies.png
@export var max_health: int = 18
@export var attack_power: int = 4
@export var defense: int = 1
@export var move_speed: float = 45.0
@export var aggro_radius: float = 90.0
@export var attack_range: float = 16.0
@export var attack_cooldown: float = 1.1
@export var xp_reward: int = 8
