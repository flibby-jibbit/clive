module clive

type FnCmdExec = fn (Args)

@[noinit]
pub struct Cmd {
pub:
	name        string    @[required]
	alias       string
	description string
	exec        FnCmdExec = unsafe { nil }
pub mut:
	cmds Cmds
	args Args
}

@[noinit]
pub struct Cmds {
mut:
	cmds []Cmd
}

// vfmt off
pub fn Cmd.new(attrs struct {
	name string
	alias string
	description string
	exec FnCmdExec = unsafe { nil }
}) Cmd {
	// vfmt on
	mut cmd := Cmd{
		name: attrs.name
		alias: attrs.alias
		description: attrs.description
		exec: attrs.exec
	}

	// We don't want to add 'help' or 'version'
	// to the 'help' and 'version' commands we
	// add automatically
	if !['help', 'version'].contains(attrs.name) {
		cmd.cmds.add(Cmd.new(name: 'help'))
	}

	return cmd
}

fn (mut self Cmd) parse(mut input []string) !Cmd {
	if input.len > 0 {
		token := input.first()

		if mut cmd := self.cmds.get(token) {
			input.drop(1)

			if cmd.name == 'help' {
				self.help(input)!
				return cmd
			}

			return cmd.parse(mut input)!
		}
	}

	if isnil(self.exec) {
		// If there is nothing to execute, let's just
		// display help.
		self.help(input)!
	} else {
		// Even though no input, we need to let args.parse
		// check for required args.
		self.args.parse(input)!
	}

	return self
}

pub fn (mut self Cmds) add(cmd Cmd) {
	name_exists := self.cmds.any(it.name == cmd.name)
	alias_exists := !cmd.alias.is_blank() && self.cmds.any(it.alias == cmd.alias)

	if !(name_exists || alias_exists) {
		self.cmds << cmd
	}
}

fn (self Cmds) get(identifier string) ?Cmd {
	for cmd in self.cmds {
		if [cmd.name, cmd.alias].contains(identifier) {
			return cmd
		}
	}

	return none
}

fn (self Cmds) all() []Cmd {
	return self.cmds
}
