module txtar

// Copyright (c) 2018 The Go Authors. All rights reserved.
// https://cs.opensource.google/go/x/tools/+/master:txtar/archive.go
import strings

// An `Archive` is a collection of files.
pub struct Archive {
pub mut:
	comment string
	files   []File
}

// A `File` is a single file in an archive.
pub struct File {
pub:
	name string // name of file ("foo/bar.txt")
	data string // text content of file
}

// format returns the serialized form of an `Archive`.
// It is assumed that the `Archive` data structure is well-formed:
// a.Comment and all a.File[i].Data contain no file marker lines,
// and all a.File[i].Name is non-empty.
pub fn format(a &Archive) string {
	mut buf := strings.new_builder(2 << 10)
	buf.write_string(fix_nl(a.comment))
	for _, f in a.files {
		buf.write_string('-- ${f.name} --\n')
		buf.write_string(fix_nl(f.data))
	}
	return buf.str()
}

// parse the serialized form of an `Archive`.
pub fn parse(d string) &Archive {
	mut a := &Archive{}
	mut before, mut name, mut data := find_file_marker(d)
	a.comment = before
	for name != '' {
		prev := name
		before, name, data = find_file_marker(data)
		a.files << File{prev, before}
	}
	return a
}

const newline_marker = '\n-- '
const marker = '-- '
const marker_end = ' --'

// find_file_marker finds the next file marker in data,
// extracts the file name, and returns the data before the marker,
// the file name, and the data after the marker.
// If there is no next marker, findFileMarker returns before = fixNL(data), name = "", after = nil.
fn find_file_marker(data string) (string, string, string) {
	mut i := 0
	for {
		name, after := is_marker(data[i..])
		if name != '' {
			return data[..i], name, after
		}
		if j := data[i..].index(txtar.newline_marker) {
			i += j + 1 // positioned at start of new possible marker
		} else {
			return fix_nl(data), '', ''
		}
	}
	return '', '', ''
}

// is_marker checks whether `data` begins with a file marker line.
// If so, it returns the name from the line and the data after the line.
// Otherwise it returns name == "" with an unspecified after.
fn is_marker(data string) (string, string) {
	if !data.starts_with(txtar.marker) {
		return '', ''
	}
	mut d := data
	mut after := ''
	i := data.index_u8(`\n`)
	if i >= 0 {
		d, after = data[..i], data[i + 1..]
	}
	if !(d.ends_with(txtar.marker_end) && d.len >= txtar.marker.len + txtar.marker_end.len) {
		return '', ''
	}
	return d[txtar.marker.len..d.len - txtar.marker_end.len].trim_space(), after
}

// If data is empty or ends in \n, fix_nl returns `data`.
// Otherwise fix_nl returns a new slice consisting of `data` with a final \n added.
fn fix_nl(data string) string {
	if data == '' || data[data.len - 1] == `\n` {
		return data
	}
	return data + '\n'
}
