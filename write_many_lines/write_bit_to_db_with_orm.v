import db.sqlite
import rand
import time

const (
	rows_to_insert = 100_000
	db_table_name  = 'random_lines'
	db_file_name   = 'million_lines_orm.db'
)

// sets a custom table name. Default is struct name (case-sensitive)
[table: 'random_lines']
struct RandomLine {
	id         int       [primary; sql: serial]
	rand_str   string    [nonull; required]
	created_at time.Time [default: 'CURRENT_TIMESTAMP'; sql_type: 'DATETIME']
	updated_at string    [sql_type: 'DATETIME']
}

fn check_table(db sqlite.DB) {
	sql db {
		create table RandomLine
	}
}

fn prune_table(db sqlite.DB) {
	sw := time.new_stopwatch()
	found := db.q_int('SELECT COUNT(*) FROM ${db_table_name}')
	if found > 0 {
		println('${found} rows found! truncating table...')
		db.exec_none('DELETE FROM "${db_table_name}"')
	}
	println('Note: ${@FN}() took: ${sw.elapsed().milliseconds()} ms')
}

fn fill_table_with_rand_data(db sqlite.DB) {
	sw := time.new_stopwatch()
	mut rows := []RandomLine{cap: rows_to_insert}
	for i := 0; i < rows_to_insert; i++ {
		rows << RandomLine{
			rand_str: 'Random Line with ${rand.ulid()}'
		}
	}

	for new_row in rows {
		// so fkn slow! 427580 ms for only 100_000 rows...
		sql db {
			insert new_row into RandomLine
		}
	}
	println('Note: ${@FN}() took: ${sw.elapsed().milliseconds()} ms')
}

[console]
fn main() {
	sw := time.new_stopwatch()
	mut db := sqlite.connect(db_file_name)!
	defer {
		// I think it's unnecessary... It's not a MySQL/PostgeSQL DB
		db.close() or { panic('Could not close DB!') }
	}
	check_table(db)
	prune_table(db)
	fill_table_with_rand_data(db)

	println('Note: ${@FN}() took: ${sw.elapsed().milliseconds()} ms')
}
