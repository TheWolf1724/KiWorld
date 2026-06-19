class_name Combat
extends RefCounted
## Utilidades de combate puras (sin estado). Faciles de testear y de
## reutilizar tanto en cliente como, en el futuro, en un servidor autoritativo.

const CRIT_CHANCE := 0.12
const CRIT_MULT := 1.8

## Calcula el dano final dado el ataque del atacante y la defensa del objetivo.
## Devuelve [dano, es_critico].
static func resolve(attack_power: int, defense: int) -> Array:
	var base := maxi(1, attack_power - int(defense * 0.5))
	var variance := randf_range(0.9, 1.1)
	var is_crit := randf() < CRIT_CHANCE
	var dmg := int(round(base * variance * (CRIT_MULT if is_crit else 1.0)))
	return [maxi(1, dmg), is_crit]
