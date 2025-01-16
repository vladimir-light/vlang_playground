import time
import rand
import db.sqlite
import arrays
import os
import flag

const db_table_name = 'random_lines'
const db_file_name = 'billion_lines'
const db_database_file_name = '${db_file_name}.db'
// const db_database_file_path = os.join_path(os.cache_dir(), db_database_file_name)
const db_database_file_path = os.join_path(os.cache_dir(), db_database_file_name)
const db_create_table_stmt = 'CREATE TABLE IF NOT EXISTS ${db_table_name} (line_num integer primary key, line text default \'\', created_at datetime DEFAULT CURRENT_TIMESTAMP)'

fn db_conn(db_file string) !sqlite.DB {
	return sqlite.connect(db_file)!
}

fn check_table(db sqlite.DB) {
	db.exec(db_create_table_stmt) or { panic(err) }
}

//[if debug]
fn populate_db_with_lines_batch(db sqlite.DB, rows_to_insert int, chunk_size int) {
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
	num_rows := db.q_int('SELECT COUNT(*) FROM ${db_table_name}') or { 0 }
	if num_rows > 0 {
		println('${num_rows} rows found! truncating table...')
		db.exec_none('DELETE FROM `${db_table_name}`')
		db.exec_none('UPDATE SQLITE_SEQEUNCE SET seq = 0 WHERE name = `${db_table_name}`')
		db.exec_none('VACUUM')
		/*
UPDATE SQLITE_SEQUENCE SET seq = 0 WHERE name = '<table>';
VACUUM;
		*/
		db.exec('DELETE ') or { panic(err) }
	}
	println('Note: ${@FN}() took: ${sw.elapsed().milliseconds()} ms')
}

@[console]
fn main() {
	mut fp := flag.new_flag_parser(os.args)
	fp.application('write_to_db_no_orm')
	fp.version('v0.0.1')
	fp.skip_executable()

	db_insert_chunk_size := fp.int('chunk', 0, 1000, '--chunk=<NUMBER>. Default: 1000')
	do_not_purge_db := fp.bool('no-purge', 0, false, 'Skip DB purging. New rows will be appended.')
	fp.limit_free_args_to_exactly(1)!
	lines_to_write := fp.remaining_parameters()[0].int()

	sw := time.new_stopwatch()
	mut db := db_conn(db_database_file_path) or { panic('Can not connect to a DB...') }
	db.synchronization_mode(sqlite.SyncMode.off)!
	db.journal_mode(sqlite.JournalMode.memory)!
	check_table(db)
	if !do_not_purge_db {
		purge_table(db)
	} else {
		println('No DB Purging...')
	}
	populate_db_with_lines_batch(db, lines_to_write, db_insert_chunk_size)
	println('Note: ${@FN}() took: ${sw.elapsed().milliseconds()} ms')
	println('FINITO!')
}
