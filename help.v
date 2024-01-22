module clive

fn help_header(name string, description string) ! {
	mut t := Table.new(cols: 2)

	t.add(['Name:', name])!
	if !description.is_blank() {
		t.add(['Description:', description])!
	}

	println(t.to_string())
	println('')
}

fn help_cmds(cmds Cmds) ! {
	mut output := ['Commands:', '']

	mut t := Table.new(cols: 3)

	t.add(['Name', 'Alias', 'Description'])!
	t.add(['----', '-----', '-----------'])!

	for cmd in cmds.all() {
		t.add([cmd.name, cmd.alias, cmd.description])!
	}

	output << t.to_string()
	println(output.join('\n'))
}

fn help_usage(cmd string, args []IArg) {
	mut output := ['Usage:', '']
	mut cmd_line := [cmd]

	for arg in args {
		mut fragment := ''

		if !arg.required {
			fragment = '['
		}

		fragment += '${arg.name}=${arg.kind}'

		if !arg.required {
			fragment += ']'
		}

		cmd_line << fragment
	}

	output << cmd_line.join(' ')
	output << ''
	println(output.join('\n'))
}

fn help_arg(arg IArg) ! {
	mut t := Table.new(cols: 2, pad: 5)
	t.add(['Name:', arg.name])!
	t.add(['Alias:', arg.alias])!
	t.add(['Description:', arg.description])!
	t.add(['Kind:', arg.kind])!
	t.add(['Multiple:', arg.multiple.str()])!
	t.add(['Required:', arg.required.str()])!
	t.add(['Default:', arg.default])!
	t.add(['Choices:', arg.choices.join(arg.separator)])!
	println(t.to_string())
	println('')
}

fn help_args(cmd string, args []IArg) ! {
	mut output := [
		'Arguments:',
		'',
		'`${cmd} help arg` for more information.',
		'',
	]

	mut t := Table.new(cols: 2, pad: 5)

	t.add(['Name', 'Description'])!
	t.add(['----', '-----------'])!

	for arg in args {
		t.add([arg.name, arg.description])!
	}

	output << t.to_string()
	output << ''
	println(output.join('\n'))
}

fn (self App) help() ! {
	help_header(self.name, self.description)!
	help_cmds(self.cmds)!
}

fn (self Cmd) help(input []string) ! {
	help_header(self.name, self.description)!

	if input.len > 0 {
		token := input.first()
		if arg := self.args.get(token) {
			help_usage(self.name, [arg])
			help_arg(arg)!
		} else {
			error_message := err_msg('arg_not_found', arg: token)
			return error(error_message)
		}
	} else {
		args := self.args.all()
		if args.len > 0 {
			help_usage(self.name, args)
			help_args(self.name, args)!
		}
	}

	help_cmds(self.cmds)!
}
