module clive

fn test_bool_arg_new_defaults() {
	arg := BoolArg.new(name: 'barg')

	assert arg.kind == 'bool' // hard-coded
	assert arg.separator.is_blank() // hard-coded
	assert !arg.multiple // hard-coded
	assert arg.choices.len == 0 // hard-coded
	assert arg.name == 'barg'
	assert arg.alias.is_blank()
	assert arg.description.is_blank()
	assert !arg.required
	assert arg.default.is_blank()
}

fn test_bool_arg_new() {
	arg := BoolArg.new(
		name: 'barg'
		alias: 'b'
		description: 'A bool arg.'
		required: true
		default: 'true'
	)

	assert arg.kind == 'bool' // hard-coded
	assert arg.separator.is_blank() // hard-coded
	assert !arg.multiple // hard-coded
	assert arg.name == 'barg'
	assert arg.alias == 'b'
	assert arg.description == 'A bool arg.'
	assert arg.required
	assert arg.default == 'true'
}

fn test_bool_arg_parse() {
	mut arg := BoolArg.new(name: 'barg')

	arg.parse('v')!

	stored := arg.stored() or { [] }
	assert stored == ['v']
}

fn test_bool_arg_parse_empty() {
	mut arg := BoolArg.new(name: 'barg')

	mut error := false
	arg.parse('') or { error = true }
	assert error
}
