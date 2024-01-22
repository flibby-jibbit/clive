module clive

import strings

const default_pad = 5

struct Table {
pub:
	cols int @[required]
	pad  int @[required]
mut:
	lens []int
	rows [][]string
}

// vfmt off
fn Table.new(attrs struct {
	cols int
	pad int = default_pad
}) Table {
	// vfmt on
	mut t := Table{
		cols: attrs.cols
		pad: attrs.pad
	}

	t.lens = []int{len: attrs.cols, init: 0}
	return t
}

fn (mut self Table) add(row []string) ! {
	if row.len != self.cols {
		return error('Row must contain ${self.cols} columns.')
	}

	for i, val in row {
		if val.len > self.lens[i] {
			self.lens[i] = val.len
		}
	}

	self.rows << row
}

fn (mut self Table) normalize() {
	for mut row in self.rows {
		for i, cell in row {
			padlen := self.lens[i] - cell.len
			if padlen > 0 {
				padding := strings.repeat(32, padlen)
				row[i] = cell + padding
			}
		}
	}
}

fn (mut self Table) to_string() string {
	self.normalize()

	padding := strings.repeat(32, self.pad)

	mut output := []string{}

	for row in self.rows {
		output << row.join(padding)
	}

	return output.join('\n')
}
