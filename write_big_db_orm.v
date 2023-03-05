import time
import rand
// import arrays
import db.sqlite

const (
	total_lines          = 100_000
	db_table_name        = 'random_lines'
	db_file_name         = 'million_lines_orm.db'
	db_insert_chunk_size = 10000
)

// sets a custom table name. Default is struct name (case-sensitive)
[table: 'random_lines']
struct RandomLine {
	id         int    [primary; sql: serial] // a field named `id` of integer type must be the first field
	rand_str   string [nonull; required]
	created_at string [default: 'CURRENT_TIMESTAMP'; sql_type: 'DATETIME']
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
		db.exec_none('DELETE FROM "${db_table_name}"')
	}
	println('Note: ${@FN}() took: ${sw.elapsed().milliseconds()} ms')
}

fn fill_table_with_rand_data(db sqlite.DB) {
	sw := time.new_stopwatch()
	mut rows := []RandomLine{cap: total_lines}
	for i := 0; i < total_lines; i++ {
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
		db.close() or { panic('Konnte DB nicht mehr schließen!') }
	}
	check_table(db)
	prune_table(db)
	fill_table_with_rand_data(db)

	println('Note: ${@FN}() took: ${sw.elapsed().milliseconds()} ms')
}
