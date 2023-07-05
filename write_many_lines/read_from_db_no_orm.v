import time
import db.sqlite
import os

const (
	rows_to_insert        = 6_500_000
	read_batch            = 1_000_000
	db_table_name         = 'random_lines'
	db_file_name          = 'million_lines'
	db_database_file_name = '${db_file_name}.db'
	db_database_file_path = os.join_path(os.cache_dir(), db_database_file_name)
)

fn db_conn(db_name string) !sqlite.DB {
	dump(db_name)
	return sqlite.connect(db_name)!
}

fn check_table(db sqlite.DB) {
	// Check if table exists!
	sql := 'SELECT COUNT(DISTINCT tbl_name) FROM sqlite_master WHERE type=\'table\' AND name=\'${db_table_name}\''
	if db.q_int(sql) < 1 {
		panic('There\'s no table \'${db_table_name}\' in DB')
	}
}

fn read_all_from_db(db sqlite.DB) {
	sw := time.new_stopwatch()

	res := db.q_int('SELECT COUNT(*) FROM ${db_table_name}')
	if res < 1 {
		eprintln("There's nothing to read from table and/or database")
		exit(1)
	}

	rows, exec_code := db.exec('SELECT * FROM ${db_table_name} ORDER BY 2 ASC')
	if sqlite.is_error(exec_code) {
		eprintln('ERROR: SQL query could not be executed!')
		dump(exec_code)
	} else {
		for idx, line in rows {
			non_zeor_idx := (idx + 1)
			if non_zeor_idx % read_batch == 0 {
				dump(line)
			}
		}
	}
	println('Note: ${@FN}() took: ${sw.elapsed().milliseconds()} ms')
}

[console]
fn main() {
	sw := time.new_stopwatch()
	//dump(os.user_os())
	mut db := db_conn(db_database_file_path) or { panic('Can not connect to a DB...') }
	db.synchronization_mode(sqlite.SyncMode.off)
	db.journal_mode(sqlite.JournalMode.memory)
	check_table(db)
	read_all_from_db(db)

	println('Note: ${@FN}() took: ${sw.elapsed().milliseconds()} ms')
	println('FINITO!')
}
