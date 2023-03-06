import os
import time
import rand

const (
	file_name     = 'big_file.txt'
	total_lines   = 6_500_000
	read_file_lap = 1_000_000
)

//[if debug]
fn remove_old_file(file_name string) {
	if os.exists(file_name) {
		os.rm(file_name) or { panic(err) }
		println('Vorherige Kopie von `${file_name}` wird gelöscht...')
	}
}

//[if debug]
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

[if debug]
fn read_lines_from_file(file_name string) {
	sw := time.new_stopwatch()
	mut lines_read := 0
	if rows := os.read_lines(file_name) {
		for idx, line in rows {
			lines_read++
			line_num := (idx + 1)
			if line_num % read_file_lap == 0 {
				dump(line)
			}
		}
	} else {
		eprintln('File [${file_name}] NOT FOUND!')
	}
	println('Lines read: ${lines_read}')
	println('Note: ${@FN}() took: ${sw.elapsed().milliseconds()} ms')
}

[console]
fn main() {
	sw := time.new_stopwatch()
	remove_old_file(file_name)
	write_random_lines_to_file(file_name)
	read_lines_from_file(file_name)

	println('Note: ${@FN}() took: ${sw.elapsed().milliseconds()} ms')
	println('FINITO!')
}
