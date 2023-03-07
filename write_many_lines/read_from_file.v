import os
import time

const (
	file_name     = 'big_file.txt'
	read_file_lap = 1_000_000
)

fn file_is_ok() !bool {
	if !os.exists(file_name) {
		return error('${file_name} was not found!')
	}
	if !os.is_file(file_name) {
		return error('${file_name} is not a file!')
	}
	if !os.is_readable(file_name) {
		return error('${file_name} is not readable!')
	}

	return true
}

fn read_lines_from_file() {
	sw := time.new_stopwatch()
	mut lines_read := 0
	rows := os.read_lines(file_name) or { panic(err) }

	for idx, line in rows {
			lines_read++
			line_num := (idx + 1)
			if line_num % read_file_lap == 0 {
				println(line)
			}
		}

	println('Lines read: ${lines_read}')
	println('Note: ${@FN}() took: ${sw.elapsed().milliseconds()} ms')
}

[console]
fn main() {
	sw := time.new_stopwatch()

	file_is_ok() or { eprintln(err) exit(1) }
	read_lines_from_file()

	println('Note: ${@FN}() took: ${sw.elapsed().milliseconds()} ms')
	println('FINITO!')
}
