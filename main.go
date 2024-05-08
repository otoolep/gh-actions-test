package main

import (
	"database/sql"
	"fmt"
	"log"
	"os"

	_ "github.com/mattn/go-sqlite3"
)

// These variables are populated via the Go linker.
// Make sure the build process (linker flags) are updated, as well as go.mod.
var (
	// Version of rqlite.
	Version = "1"

	// Commit this code was built at.
	Commit = "unknown"

	// Branch the code was built from.
	Branch = "unknown"

	// Buildtime is the timestamp when the build took place.
	Buildtime = "unknown"
)

func main() {
	fmt.Println("Version:", Version, "Commit:", Commit, "Branch:", Branch, "Buildtime:", Buildtime)

	os.Remove("./foo.db")
	db, err := sql.Open("sqlite3", "./foo.db")
	if err != nil {
		log.Fatal(err)
	}
	defer db.Close()

	sqlStmt := `
	create table foo (id integer not null primary key, name text);
	delete from foo;
	`
	_, err = db.Exec(sqlStmt)
	if err != nil {
		log.Printf("%q: %s\n", err, sqlStmt)
		return
	}
}
