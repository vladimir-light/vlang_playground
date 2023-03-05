import time
import rand
import db.sqlite
import arrays
import os

const (
	file_name             = 'dummy_file.txt'
	total_lines           = 6_500_000
	read_file_lap         = 1_000_000
	db_table_name         = 'random_lines'
	db_create_table_stmt  = 'create table if not exists ${db_table_name} (line_num integer primary key, line text default \'\');'
	db_database_file_name = 'million_lines.db'
	db_database_in_memory = ':in_memory:'
	db_insert_chunk_size  = 10000
)

struct NewFullLine {
	id   i16    [required]
	line string [required]
}

fn db_conn(db_name string) !sqlite.DB {
	if db_name == db_database_in_memory && !os.is_file(db_name) {
		eprintln('Es wird mit einer :in_memory: DB gearbeitet...')
		mut db := sqlite.connect(db_name)!
		return db
	}
	mut db := sqlite.connect(db_name)!

	return db
}

//[if debug]
fn check_table(db sqlite.DB) {
	db.exec(db_create_table_stmt)
}

//[if debug]
fn populate_db_with_lines_batch(db sqlite.DB, chunk_size int) {
	sw := time.new_stopwatch()
	println('Try to insert ${total_lines} rows into DB in batches of ${chunk_size}...')
	mut new_rows := []string{cap: total_lines}

	for i in 0 .. total_lines {
		non_zero_idx := (i + 1)
		new_rows << '#${non_zero_idx} Random UUID is - `${rand.ulid()}`'
	}

	chunked_rows := arrays.chunk(new_rows, chunk_size)
	// dump(chunked_rows[0])
	mut insert_stmts_list := []string{}

	for _, chunk in chunked_rows {
		inser_stmt_values := "('" + chunk.join("'),('") + "')"
		insert_stmts_list << 'INSERT INTO ${db_table_name} (line) VALUES ${inser_stmt_values};'
	}

	total_statements := insert_stmts_list.len
	for insert_stmts_list.len > 0 {
		db.exec_none(insert_stmts_list.pop())
	}
	println('FLUSH_DB: ${total_statements} INSERT statements executed...')
	println('Note: ${@FN}() took: ${sw.elapsed().milliseconds()} ms')
}

//[if debug]
fn purge_table(db sqlite.DB) {
	sw := time.new_stopwatch()
	num_rows := db.q_int('SELECT COUNT(*) FROM ${db_table_name}')
	if num_rows > 0 {
		println('${num_rows} rows found! truncating table...')
		db.exec('DELETE FROM `${db_table_name}`')
	}
	println('Note: ${@FN}() took: ${sw.elapsed().milliseconds()} ms')
}

[if debug]
fn read_all_from_db(db sqlite.DB) {
	sw := time.new_stopwatch()

	rows, exec_dode := db.exec('SELECT * FROM ${db_table_name} ORDER BY 2 ASC')
	if sqlite.is_error(exec_dode) {
		eprintln('ERROR: SQL Query konnte nicht ausgeführt werden!')
		dump(exec_dode)
	} else {
		for idx, line in rows {
			non_zeor_idx := (idx + 1)
			if non_zeor_idx % read_file_lap == 0 {
				dump(line)
			}
		}
	}
	println('Note: ${@FN}() took: ${sw.elapsed().milliseconds()} ms')
}

[console]
fn main() {
	sw := time.new_stopwatch()
	db := db_conn(db_database_file_name) or { panic('Can not connect to a DB...') }
	check_table(db)
	purge_table(db)
	populate_db_with_lines_batch(db, db_insert_chunk_size)
	read_all_from_db(db)

	// read all lines
	println('Note: ${@FN}() took: ${sw.elapsed().milliseconds()} ms')
	println('FINITO!')
}
