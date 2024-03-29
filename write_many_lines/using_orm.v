import db.sqlite
import rand
import time
import os

const (
	db_database_file_name = 'user_orm.db'
	db_database_file_path = os.join_path(os.cache_dir(), db_database_file_name)
)

[table: 'movies']
struct Movie {
	// id           string [default: 'gen_random_uuid()'; primary; sql_type: 'uuid']
	id           string    [primary; sql: string]
	title        string    [nonull; required]
	release_year u32       [nonull; required]
	rating       f32       [nonull; required; sql: f32; sql_type: 'VARCHAR(50)']
	created_at   time.Time [default: 'CURRENT_TIMESTAMP'; sql_type: 'DATETIME']
	updated_at   time.Time [default: 'CURRENT_TIMESTAMP'; sql_type: 'DATETIME']
}

fn main() {
	// mut db := sqlite.connect(':memory:') or { panic(err) }
	mut db := sqlite.connect(db_database_file_path) or { panic(err) }

	sql db {
		create table Movie
	}!

	// since ID ist not `serial` (aka auto-generated by DB) you have to provide uniq IDs by yourself
	rows_movies := [
		Movie{
			id: rand.ulid()
			title: 'Monty Python Live at the Hollywood Bowl'
			release_year: rand.u32_in_range(1980, 2005)!
			rating: rand.f32_in_range(2.0, 9.7)!
			// created_at: time.now()
		},
		Movie{
			id: rand.ulid()
			title: "Monty Python's The Meaning of Life"
			release_year: rand.u32_in_range(1980, 2005)!
			rating: rand.f32_in_range(2.0, 9.7)!
			// created_at: time.now()
		},
		Movie{
			id: rand.ulid()
			title: "Monty Python's Life of Brian"
			release_year: rand.u32_in_range(1980, 2005)!
			rating: rand.f32_in_range(2.0, 9.7)!
			// created_at: time.now()
		},
	]

	for _, movie_row in rows_movies {
		sql db {
			insert movie_row into Movie
		}!
	}

	all_saved_movies := sql db {
		select from Movie
	}!

	// Movies from a DB table
	dump(all_saved_movies)

	// Total movies in table
	total_movies := sql db {
		select count from Movie
	}!

	dump(total_movies)
}
