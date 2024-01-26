module txtar

// Copyright (c) 2018 The Go Authors. All rights reserved.
// https://cs.opensource.google/go/x/tools/+/master:txtar/archive_test.go

struct TestParse {
	name   string
	text   string
	parsed &Archive
}

fn test_parse() {
	tests := [
		TestParse{
			name: 'basic'
			text: 'comment1
comment2
-- file1 --
File 1 text.
-- foo ---
More file 1 text.
-- file 2 --
File 2 text.
-- empty --
-- noNL --
hello world
-- empty filename line --
some content
-- --'
			parsed: &Archive{
				comment: 'comment1\ncomment2\n'
				files: [
					File{
						name: 'file1'
						data: 'File 1 text.\n-- foo ---\nMore file 1 text.\n'
					},
					File{
						name: 'file 2'
						data: 'File 2 text.\n'
					},
					File{
						name: 'empty'
						data: ''
					},
					File{
						name: 'noNL'
						data: 'hello world\n'
					},
					File{
						name: 'empty filename line'
						data: 'some content\n-- --\n'
					},
				]
			}
		},
	]
	for _, tt in tests {
		a := parse(tt.text)
		assert a == tt.parsed

		text := format(a)
		b := parse(text)
		assert b == tt.parsed
	}
}

struct TestFormat {
	name   string
	input  &Archive
	wanted string
}

fn test_format() {
	tests := [
		TestFormat{
			name: 'basic'
			input: &Archive{
				comment: 'comment1\ncomment2\n'
				files: [
					File{
						name: 'file1'
						data: 'File 1 text.\n-- foo ---\nMore file 1 text.\n'
					},
					File{
						name: 'file 2'
						data: 'File 2 text.\n'
					},
					File{
						name: 'empty'
						data: ''
					},
					File{
						name: 'noNL'
						data: 'hello world'
					},
				]
			}
			wanted: 'comment1
comment2
-- file1 --
File 1 text.
-- foo ---
More file 1 text.
-- file 2 --
File 2 text.
-- empty --
-- noNL --
hello world
'
		},
	]
	for _, tt in tests {
		result := format(tt.input)
		assert result == tt.wanted
	}
}
