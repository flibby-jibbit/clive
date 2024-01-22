module clive

fn test_int_arg_new_defaults() {
	arg := IntArg.new(name: 'iarg')

	assert arg.kind == 'int' // hard-coded
	assert arg.name == 'iarg'
	assert arg.alias.is_blank()
	assert arg.description.is_blank()
	assert arg.separator == default_separator
	assert !arg.multiple
	assert !arg.required
	assert arg.default.is_blank()
	assert arg.choices.len == 0
}

fn test_int_new_arg() {
	arg := IntArg.new(
		name: 'iarg'
		alias: 'i'
		description: 'An int arg.'
		separator: '$'
		multiple: true
		required: true
		default: '1'
		choices: ['1', '2']
	)

	assert arg.kind == 'int' // hard-coded
	assert arg.name == 'iarg'
	assert arg.alias == 'i'
	assert arg.description == 'An int arg.'
	assert arg.separator == '$'
	assert arg.multiple
	assert arg.required
	assert arg.default == '1'
	assert arg.choices == ['1', '2']
}

fn test_int_arg_parse() {
	mut arg := IntArg.new(name: 'iarg')

	arg.parse('123')!
	stored := arg.stored() or { [] }
	assert stored == ['123']
}

fn test_int_arg_parse_error() {
	mut arg := IntArg.new(name: 'iarg')

	mut error := false
	arg.parse('x') or { error = true }
	assert error
}

fn test_int_arg_parse_empty() {
	mut arg := IntArg.new(name: 'iarg')

	mut error := false
	arg.parse('') or { error = true }
	assert error
}

fn test_int_arg_parse_mult() {
	mut arg := IntArg.new(
		name: 'iarg'
		multiple: true
		separator: ':'
	)

	arg.parse('123:456:789')!
	stored := arg.stored() or { [] }
	assert stored == ['123', '456', '789']
}

fn test_int_arg_parse_mult_error() {
	mut arg := IntArg.new(
		name: 'iarg'
		multiple: true
		separator: '#'
	)

	mut error := false
	arg.parse('123#x#456') or { error = true }
	assert error
}
