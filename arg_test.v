module clive

fn test_args_get_bool_true() {
	mut cmd := Cmd.new(name: 'cmd')
	arg := BoolArg.new(name: 'barg')

	cmd.args.add(arg)

	expected := true
	cmd.args.parse(['${arg.name}=${expected}'])!

	actual := cmd.args.get_bool(arg.name) or { false }
	assert actual == expected
}

fn test_args_get_bool_true_with_alias() {
	mut cmd := Cmd.new(name: 'cmd')
	arg := BoolArg.new(
		name: 'barg'
		alias: 'b'
	)

	cmd.args.add(arg)

	expected := true
	cmd.args.parse(['${arg.alias}=${expected}'])!

	actual := cmd.args.get_bool(arg.alias) or { false }
	assert actual == expected
}

fn test_args_get_bool_true_with_default() {
	mut cmd := Cmd.new(name: 'cmd')
	arg := BoolArg.new(
		name: 'barg'
		default: 'true'
	)

	cmd.args.add(arg)

	expected := true
	cmd.args.parse([])!

	actual := cmd.args.get_bool(arg.name) or { false }
	assert actual == expected
}

fn test_args_get_bool_false() {
	mut cmd := Cmd.new(name: 'cmd')
	arg := BoolArg.new(name: 'barg')

	cmd.args.add(arg)

	expected := false
	cmd.args.parse(['${arg.name}=${expected}'])!

	actual := cmd.args.get_bool(arg.name) or { true }
	assert actual == expected
}

fn test_args_get_bool_false_with_default() {
	mut cmd := Cmd.new(name: 'cmd')
	arg := BoolArg.new(
		name: 'barg'
		default: 'false'
	)

	cmd.args.add(arg)

	expected := false
	cmd.args.parse([])!

	actual := cmd.args.get_bool(arg.name) or { true }
	assert actual == expected
}

fn test_args_get_bool_none() {
	cmd := Cmd.new(name: 'cmd')
	match cmd.args.get_bool('does-not-exist') {
		none { assert true }
		else { assert false }
	}
}

fn test_args_get_int() {
	mut cmd := Cmd.new(name: 'cmd')
	arg := IntArg.new(name: 'iarg')

	cmd.args.add(arg)

	expected := 123
	cmd.args.parse(['${arg.name}=${expected.str()}'])!

	actual := cmd.args.get_int(arg.name) or { 0 }
	assert actual == expected
}

fn test_args_get_int_with_alias() {
	mut cmd := Cmd.new(name: 'cmd')
	arg := IntArg.new(
		name: 'iarg'
		alias: 'i'
	)

	cmd.args.add(arg)

	expected := 123
	cmd.args.parse(['${arg.alias}=${expected.str()}'])!

	actual := cmd.args.get_int(arg.alias) or { 0 }
	assert actual == expected
}

fn test_args_get_int_with_default() {
	mut cmd := Cmd.new(name: 'cmd')
	arg := IntArg.new(
		name: 'iarg'
		default: '1'
	)

	cmd.args.add(arg)

	expected := 1
	cmd.args.parse([])!

	actual := cmd.args.get_int(arg.alias) or { 0 }
	assert actual == expected
}

fn test_args_get_int_with_choices() {
	mut cmd := Cmd.new(name: 'cmd')
	arg := IntArg.new(
		name: 'iarg'
		choices: ['1', '2']
	)

	cmd.args.add(arg)

	expected := 1
	cmd.args.parse(['iarg=1'])!

	actual := cmd.args.get_int(arg.alias) or { 0 }
	assert actual == expected

	mut error := false
	cmd.args.parse(['iarg=3']) or { error = true }
	assert error
}

fn test_args_get_int_none() {
	cmd := Cmd.new(name: 'cmd')
	match cmd.args.get_int('does-not-exist') {
		none { assert true }
		else { assert false }
	}
}

fn test_args_get_ints() {
	mut cmd := Cmd.new(name: 'cmd')
	arg := IntArg.new(
		name: 'iarg'
		multiple: true
	)
	cmd.args.add(arg)

	expected := [123, 456]
	input := expected.map(it.str()).join(default_separator)
	cmd.args.parse(['${arg.name}=${input}'])!

	actual := cmd.args.get_ints(arg.name) or { [] }
	assert actual == expected
}

fn test_args_get_ints_with_default() {
	mut cmd := Cmd.new(name: 'cmd')
	arg := IntArg.new(
		name: 'iarg'
		multiple: true
		default: '2'
	)
	cmd.args.add(arg)

	expected := [2]
	cmd.args.parse([])!

	actual := cmd.args.get_ints(arg.name) or { [] }
	assert actual == expected
}

fn test_args_get_ints_with_choices() {
	mut cmd := Cmd.new(name: 'cmd')
	arg := IntArg.new(
		name: 'iarg'
		multiple: true
		choices: ['1', '2']
	)

	cmd.args.add(arg)

	expected := [1, 2]
	input := expected.map(it.str()).join(default_separator)
	cmd.args.parse(['${arg.name}=${input}'])!

	actual := cmd.args.get_ints(arg.alias) or { [] }
	assert actual == expected

	mut error := false
	cmd.args.parse(['iarg=1,3,4']) or { error = true }
	assert error
}

fn test_args_get_ints_none() {
	cmd := Cmd.new(name: 'cmd')
	match cmd.args.get_ints('does-not-exist') {
		none { assert true }
		else { assert false }
	}
}

fn test_args_get_float() {
	mut cmd := Cmd.new(name: 'cmd')
	arg := FloatArg.new(name: 'farg')

	cmd.args.add(arg)

	expected := 123.456
	cmd.args.parse(['${arg.name}=${expected.str()}'])!

	actual := cmd.args.get_float(arg.name) or { 0.0 }
	assert actual == expected
}

fn test_args_get_float_with_alias() {
	mut cmd := Cmd.new(name: 'cmd')
	arg := FloatArg.new(
		name: 'farg'
		alias: 'f'
	)

	cmd.args.add(arg)

	expected := 123.456
	cmd.args.parse(['${arg.alias}=${expected.str()}'])!

	actual := cmd.args.get_float(arg.alias) or { 0.0 }
	assert actual == expected
}

fn test_args_get_float_with_default() {
	mut cmd := Cmd.new(name: 'cmd')
	arg := FloatArg.new(
		name: 'farg'
		default: '1.2'
	)

	cmd.args.add(arg)

	expected := 1.2
	cmd.args.parse([])!

	actual := cmd.args.get_float(arg.alias) or { 0.0 }
	assert actual == expected
}

fn test_args_get_float_with_choices() {
	mut cmd := Cmd.new(name: 'cmd')
	arg := FloatArg.new(
		name: 'farg'
		choices: ['1.2', '3.4']
	)

	cmd.args.add(arg)

	expected := 1.2
	cmd.args.parse(['farg=1.2'])!

	actual := cmd.args.get_float(arg.alias) or { 0.0 }
	assert actual == expected

	mut error := false
	cmd.args.parse(['farg=5.6']) or { error = true }
	assert error
}

fn test_args_get_float_none() {
	cmd := Cmd.new(name: 'cmd')
	match cmd.args.get_float('does-not-exist') {
		none { assert true }
		else { assert false }
	}
}

fn test_args_get_floats() {
	mut cmd := Cmd.new(name: 'cmd')
	arg := FloatArg.new(
		name: 'farg'
		multiple: true
	)

	cmd.args.add(arg)

	expected := [123.456, 456.789]
	input := expected.map(it.str()).join(default_separator)
	cmd.args.parse(['${arg.name}=${input}'])!

	actual := cmd.args.get_floats(arg.name) or { [] }
	assert actual == expected
}

fn test_args_get_floats_with_default() {
	mut cmd := Cmd.new(name: 'cmd')
	arg := FloatArg.new(
		name: 'farg'
		multiple: true
		default: '2.3'
	)

	cmd.args.add(arg)

	expected := [2.3]
	cmd.args.parse([])!

	actual := cmd.args.get_floats(arg.name) or { [] }
	assert actual == expected
}

fn test_args_get_floats_with_choices() {
	mut cmd := Cmd.new(name: 'cmd')
	arg := FloatArg.new(
		name: 'farg'
		multiple: true
		choices: ['1.2', '3.4']
	)

	cmd.args.add(arg)

	expected := [1.2, 3.4]
	input := expected.map(it.str()).join(default_separator)
	cmd.args.parse(['${arg.name}=${input}'])!

	actual := cmd.args.get_floats(arg.alias) or { [] }
	assert actual == expected

	mut error := false
	cmd.args.parse(['farg=1.2,5.6,7.8']) or { error = true }
	assert error
}

fn test_args_get_floats_none() {
	cmd := Cmd.new(name: 'cmd')
	match cmd.args.get_floats('does-not-exist') {
		none { assert true }
		else { assert false }
	}
}

fn test_args_get_string() {
	mut cmd := Cmd.new(name: 'cmd')
	arg := StringArg.new(name: 'sarg')

	cmd.args.add(arg)

	expected := 'str_val'
	cmd.args.parse(['${arg.name}=${expected}'])!

	actual := cmd.args.get_string(arg.name) or { '' }
	assert actual == expected
}

fn test_args_get_string_with_alias() {
	mut cmd := Cmd.new(name: 'cmd')
	arg := StringArg.new(
		name: 'sarg'
		alias: 's'
	)

	cmd.args.add(arg)

	expected := 'str_val'
	cmd.args.parse(['${arg.alias}=${expected}'])!

	actual := cmd.args.get_string(arg.alias) or { '' }
	assert actual == expected
}

fn test_args_get_string_with_default() {
	mut cmd := Cmd.new(name: 'cmd')
	arg := StringArg.new(
		name: 'sarg'
		default: 'wonky'
	)

	cmd.args.add(arg)

	expected := 'wonky'
	cmd.args.parse([])!

	actual := cmd.args.get_string(arg.name) or { '' }
	assert actual == expected
}

fn test_args_get_string_with_choices() {
	mut cmd := Cmd.new(name: 'cmd')
	arg := StringArg.new(
		name: 'sarg'
		choices: ['wonky', 'donkey']
	)

	cmd.args.add(arg)

	expected := 'wonky'
	cmd.args.parse(['sarg=${expected}'])!

	actual := cmd.args.get_string(arg.name) or { '' }
	assert actual == expected

	mut error := false
	cmd.args.parse(['sarg=topsy']) or { error = true }
	assert error
}

fn test_args_get_string_none() {
	cmd := Cmd.new(name: 'cmd')
	match cmd.args.get_string('does-not-exist') {
		none { assert true }
		else { assert false }
	}
}

fn test_args_get_strings() {
	mut cmd := Cmd.new(name: 'cmd')
	arg := StringArg.new(
		name: 'sarg'
		multiple: true
	)

	cmd.args.add(arg)

	expected := ['str_val1', 'str_val2']
	cmd.args.parse(['${arg.name}=${expected.join(default_separator)}'])!

	actual := cmd.args.get_strings(arg.name) or { [] }
	assert actual == expected
}

fn test_args_get_strings_with_default() {
	mut cmd := Cmd.new(name: 'cmd')
	arg := StringArg.new(
		name: 'sarg'
		multiple: true
		default: 'wonky'
	)

	cmd.args.add(arg)

	expected := ['wonky']
	cmd.args.parse([])!

	actual := cmd.args.get_strings(arg.name) or { [] }
	assert actual == expected
}

fn test_args_get_strings_with_choices() {
	mut cmd := Cmd.new(name: 'cmd')
	arg := StringArg.new(
		name: 'sarg'
		multiple: true
		choices: ['wonky', 'donkey']
	)

	cmd.args.add(arg)

	expected := ['wonky', 'donkey']
	cmd.args.parse(['sarg=${expected.join(default_separator)}'])!

	actual := cmd.args.get_strings(arg.name) or { [] }
	assert actual == expected

	mut error := false
	cmd.args.parse(['sarg=wonky,topsy,turvy']) or { error = true }
	assert error
}

fn test_args_get_strings_none() {
	cmd := Cmd.new(name: 'cmd')
	match cmd.args.get_strings('does-not-exist') {
		none { assert true }
		else { assert false }
	}
}

fn test_args_all() {
	mut cmd := Cmd.new(name: 'cmd')
	barg := BoolArg.new(name: 'barg')
	sarg := StringArg.new(name: 'sarg')

	cmd.args.add(barg)
	cmd.args.add(sarg)

	args := cmd.args.all()
	assert args.len == 2
	names := args.map(it.name)
	assert names.contains('barg')
	assert names.contains('sarg')
}
