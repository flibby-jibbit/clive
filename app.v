module clive

@[noinit]
pub struct App {
pub:
	name        string @[required]
	description string
	version     string
pub mut:
	cmds Cmds
}

// vfmt off
pub fn App.new(attrs struct {
	name string
	description string
	version string
}) App {
	// vfmt on
	mut app := App{
		name: attrs.name
		description: attrs.description
		version: attrs.version
	}

	app.cmds.add(Cmd.new(name: 'help'))
	app.cmds.add(Cmd.new(name: 'version'))

	return app
}

pub fn (self App) parse(os_args []string) !Cmd {
	mut input := os_args.clone()

	// Remove the app name.
	input.drop(1)

	// parse the cli input and return the Cmd
	// that needs to be executed.

	for input.len > 0 {
		identifier := input.first()
		input.drop(1)

		if mut cmd := self.cmds.get(identifier) {
			if cmd.name == 'help' {
				self.help()!
				return self.cmds.get('help') or {}
			}

			if cmd.name == 'version' {
				self.version()
				return self.cmds.get('version') or {}
			}
			return cmd.parse(mut input)!
		} else {
			error_message := err_msg('cmd_unexpected', cmd: identifier)
			return error(error_message)
		}
	}

	// If we get here, there were no tokens to parse.
	self.help()!
	return self.cmds.get('help') or {}
}

fn (self App) version() {
	mut ver := 'undefined'
	if !self.version.is_blank() {
		ver = self.version
	}
	println('${self.name} version ${ver}')
}
