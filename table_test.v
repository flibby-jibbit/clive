module clive

fn test_table_new() {
	t := Table.new(cols: 3, pad: 3)

	assert t.cols == 3
	assert t.pad == 3
	assert t.lens == [0, 0, 0]
}

fn test_table_add() {
	mut t := Table.new(cols: 3, pad: 3)
	t.add(['one', 'two', 'three'])!
	assert t.rows.len == 1
}

fn test_table_add_error() {
	mut t := Table.new(cols: 3, pad: 3)

	mut failed := false
	t.add(['one', 'two']) or { failed = true }
	assert failed

	failed = false
	t.add(['one', 'two', 'three', 'four']) or { failed = true }
	assert failed
}

fn test_table_to_string() {
	mut t := Table.new(cols: 3, pad: 3)

	line1 := ['one ', 'two ', 'three']
	line2 := ['four', 'five', 'six  ']
	t.add(line1)!
	t.add(line2)!

	padding := '   '
	expected := [
		line1.join(padding),
		line2.join(padding),
	].join('\n')

	assert t.to_string() == expected
}
