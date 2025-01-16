import os
import time
import rand

const file_name = 'big_file_18.5M_lines.txt'
const file_path = os.join_path(os.cache_dir(), file_name)
const total_lines = 18_500_000

fn remove_old_file_if_exist(path_to_file string) {
	if os.exists(path_to_file) && os.is_file(path_to_file) {
		os.rm(path_to_file) or { panic(err) }
		println('Previous copy of `${path_to_file}` was deleted...')
	}
}

fn write_random_lines_to_file(path_to_file string) {
	sw := time.new_stopwatch()
	mut f_out := os.create(path_to_file) or { panic(err) }
	println('Empty file (\'${path_to_file}\') was created')
	println('Trying to write to ${path_to_file}...')
	for i in 0 .. total_lines {
		non_zero_idx := (i + 1)
		line := '#${non_zero_idx}: RANDOM uuid is - `${rand.uuid_v4()}`'
		f_out.writeln(line) or { panic(err) }
	}
	f_out.close()

	println('Note: ${@FN}() took: ${sw.elapsed().milliseconds()} ms')
}

@[console]
fn main() {
	sw := time.new_stopwatch()
	remove_old_file_if_exist(file_path)
	write_random_lines_to_file(file_path)

	println('Note: ${@FN}() took: ${sw.elapsed().milliseconds()} ms')
	println('FINITO!')
}
