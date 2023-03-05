/*
* Temp converter from ChatGPT
*
*/
import os
import math

fn main() {
	temperature := os.input('Bitte geben Sie die Temperatur ein: ').f64()
	unit := os.input('Bitte geben Sie die Einheit ein (C, F): ')
	mut result := 0.0
	mut pretty_res := 0.0
	mut result_unit := ''

	if unit == 'C' {
		result = temperature * 9 / 5 + 32
		result_unit = 'F'
	} else if unit == 'F' {
		result = (temperature - 32) * 5 / 9
		result_unit = 'C'
	} else {
		println('Error: Unbekannte Einheit.')
		return
	}

	pretty_res = math.round_sig(result, 4)

	println('Das Ergebnis ist: ${pretty_res} ${result_unit}')

	if result_unit == 'C' {
		result += 273.15
	} else {
		result = (result + 459.67) * 5 / 9
	}

	pretty_res = math.round_sig(result, 4)

	println('In Kelvin ist das Ergebnis: ${pretty_res} K')
}
