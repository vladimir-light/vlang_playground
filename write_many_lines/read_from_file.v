import os
import time

const (
	file_name     = 'big_file.txt'
	file_path     = os.join_path(os.cache_dir(), file_name)
	read_file_lap = 1_000_000
)

fn file_is_ok() !bool {
	if !os.exists(file_path) {
		return error('${file_path} does not exist!')
	}
	if !os.is_file(file_path) {
		return error('${file_name} (${file_path}) is not a file!')
	}
	if !os.is_readable(file_path) {
		return error('${file_name} (${file_path}) is not readable!')
	}

	return true
}

fn read_lines_from_file(path_to_file string) {
	sw := time.new_stopwatch()
	println('Trying to read from ${path_to_file}...')
	mut lines_read := 0
	rows := os.read_lines(path_to_file) or { panic(err) }

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

	file_is_ok() or {
		eprintln(err)
		exit(1)
	}
	read_lines_from_file(file_path)

	println('Note: ${@FN}() took: ${sw.elapsed().milliseconds()} ms')
	println('FINITO!')
}
