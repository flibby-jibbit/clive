module clive

fn test_string_arg_new_defaults() {
	arg := StringArg.new(name: 'sarg')

	assert arg.kind == 'string' // hard-coded
	assert arg.name == 'sarg'
	assert arg.alias.is_blank()
	assert arg.description.is_blank()
	assert arg.separator == default_separator
	assert !arg.multiple
	assert !arg.required
	assert arg.default.is_blank()
	assert arg.choices.len == 0
}

fn test_string_new_arg() {
	arg := StringArg.new(
		name: 'sarg'
		alias: 's'
		description: 'A string arg.'
		separator: '|'
		multiple: true
		required: true
		default: 'str1'
		choices: ['str1', 'str2']
	)

	assert arg.kind == 'string' // hard-coded
	assert arg.name == 'sarg'
	assert arg.alias == 's'
	assert arg.description == 'A string arg.'
	assert arg.separator == '|'
	assert arg.multiple
	assert arg.required
	assert arg.default == 'str1'
	assert arg.choices == ['str1', 'str2']
}

fn test_string_arg_parse() {
	mut arg := StringArg.new(name: 'iarg')

	arg.parse('something')!
	stored := arg.stored() or { [] }
	assert stored == ['something']
}

fn test_string_arg_parse_empty() {
	mut arg := StringArg.new(name: 'sarg')

	mut error := false
	arg.parse('') or { error = true }
	assert error
}

fn test_string_arg_parse_mult() {
	mut arg := StringArg.new(
		name: 'sarg'
		multiple: true
		separator: '@'
	)

	arg.parse('one@two@three')!
	stored := arg.stored() or { [] }
	assert stored == ['one', 'two', 'three']
}
