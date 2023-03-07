import os
import time
import rand

const (
	file_name     = 'big_file.txt'
	total_lines   = 6_500_000
)

fn remove_old_file(file_name string) {
	if os.exists(file_name) {
		os.rm(file_name) or { panic(err) }
		println('Vorherige Kopie von `${file_name}` wird gelöscht...')
	}
}

fn write_random_lines_to_file(file_name string) {
	sw := time.new_stopwatch()
	mut f_out := os.create(file_name) or { panic(err) }
	println('Leere Datei `${file_name}` wurde erstellt.')
	println('Nun werden ${total_lines} Zeilen geschrieben...')
	for i in 0 .. total_lines {
		non_zero_idx := (i + 1)
		line := '#${non_zero_idx}: RANDOM uuid is - `${rand.uuid_v4()}`'
		f_out.writeln(line) or { panic(err) }
	}
	f_out.close()

	println('Note: ${@FN}() took: ${sw.elapsed().milliseconds()} ms')
}

[console]
fn main() {
	sw := time.new_stopwatch()
	remove_old_file(file_name)
	write_random_lines_to_file(file_name)

	println('Note: ${@FN}() took: ${sw.elapsed().milliseconds()} ms')
	println('FINITO!')
}
