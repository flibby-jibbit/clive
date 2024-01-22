module clive

fn test_float_arg_new_defaults() {
	arg := FloatArg.new(name: 'farg')

	assert arg.kind == 'float' // hard-coded
	assert arg.name == 'farg'
	assert arg.alias.is_blank()
	assert arg.description.is_blank()
	assert arg.separator == default_separator
	assert !arg.multiple
	assert !arg.required
	assert arg.default.is_blank()
	assert arg.choices.len == 0
}

fn test_float_arg_new() {
	arg := FloatArg.new(
		name: 'farg'
		alias: 'f'
		description: 'A float arg.'
		separator: '^'
		multiple: true
		required: true
		default: '1.2'
		choices: ['1.2', '3.4']
	)

	assert arg.kind == 'float' // hard-coded
	assert arg.name == 'farg'
	assert arg.alias == 'f'
	assert arg.description == 'A float arg.'
	assert arg.separator == '^'
	assert arg.multiple
	assert arg.required
	assert arg.default == '1.2'
	assert arg.choices == ['1.2', '3.4']
}

fn test_float_arg_parse() {
	mut arg := FloatArg.new(name: 'farg')

	arg.parse('1.23')!
	stored := arg.stored() or { [] }
	assert stored == ['1.23']
}

fn test_float_arg_parse_error() {
	mut arg := FloatArg.new(name: 'farg')

	mut error := false
	arg.parse('v') or { error = true }
	assert error
}

fn test_float_arg_parse_empty() {
	mut arg := FloatArg.new(name: 'farg')

	mut error := false
	arg.parse('') or { error = true }
	assert error
}

fn test_float_arg_parse_mult() {
	mut arg := FloatArg.new(
		name: 'farg'
		multiple: true
		separator: '|'
	)

	arg.parse('1.23|4.56|7.89')!
	stored := arg.stored() or { [] }
	assert stored == ['1.23', '4.56', '7.89']
}

fn test_float_arg_parse_mult_error() {
	mut arg := FloatArg.new(
		name: 'farg'
		multiple: true
		separator: '/'
	)

	mut error := false
	arg.parse('1.23/v/4.56') or { error = true }
	assert error
}
