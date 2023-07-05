import time
import rand
import db.sqlite
import arrays
import os

const (
	rows_to_insert        = 6_500_000
	db_table_name         = 'random_lines'
	db_file_name          = 'million_lines'
	db_database_file_name = '${db_file_name}.db'
	db_database_file_path = os.join_path(os.cache_dir(), db_database_file_name)
	db_create_table_stmt  = 'CREATE TABLE IF NOT EXISTS ${db_table_name} (line_num integer primary key, line text default \'\', created_at datetime DEFAULT CURRENT_TIMESTAMP)'
	db_insert_chunk_size  = 10000
)

fn db_conn(db_file string) !sqlite.DB {
	return sqlite.connect(db_file)!
}

fn check_table(db sqlite.DB) {
	db.exec(db_create_table_stmt)
}

//[if debug]
fn populate_db_with_lines_batch(db sqlite.DB, chunk_size int) {
	sw := time.new_stopwatch()
	println('Try to insert ${rows_to_insert} rows into DB in batches of ${chunk_size}...')
	mut new_rows := []string{cap: rows_to_insert}

	for i in 0 .. rows_to_insert {
		non_zero_idx := (i + 1)
		new_rows << '#${non_zero_idx} Random UUID is - `${rand.uuid_v4()}`'
	}

	chunked_rows := arrays.chunk(new_rows, chunk_size)
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

fn purge_table(db sqlite.DB) {
	sw := time.new_stopwatch()
	num_rows := db.q_int('SELECT COUNT(*) FROM ${db_table_name}')
	if num_rows > 0 {
		println('${num_rows} rows found! truncating table...')
		db.exec('DELETE FROM `${db_table_name}`')
	}
	println('Note: ${@FN}() took: ${sw.elapsed().milliseconds()} ms')
}

[console]
fn main() {
	sw := time.new_stopwatch()
	mut db := db_conn(db_database_file_path) or { panic('Can not connect to a DB...') }
	db.synchronization_mode(sqlite.SyncMode.off)
	db.journal_mode(sqlite.JournalMode.memory)
	check_table(db)
	purge_table(db)
	populate_db_with_lines_batch(db, db_insert_chunk_size)
	println('Note: ${@FN}() took: ${sw.elapsed().milliseconds()} ms')
	println('FINITO!')
}
