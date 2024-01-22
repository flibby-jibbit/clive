module clive

const app_name = 'my_app'
const app_desc = 'My App'
const app_version = '0.1.0'

fn test_app_new() {
	app := App.new(
		name: clive.app_name
		description: clive.app_desc
		version: clive.app_version
	)

	assert app.name == clive.app_name
	assert app.description == clive.app_desc
	assert app.version == clive.app_version
}

fn test_app_new_defaults() {
	app := App.new(name: clive.app_name)

	assert app.name == clive.app_name
	assert app.description.is_blank()
	assert app.version.is_blank()
}

fn test_app_new_adds_help() {
	app := App.new(name: clive.app_name)
	mut exists := true
	app.cmds.get('help') or { exists = false }
	assert exists

	exists = true
	app.cmds.get('h') or { exists = false }
	assert !exists
}

fn test_app_new_adds_version() {
	app := App.new(name: clive.app_name)
	mut exists := true
	app.cmds.get('version') or { exists = false }
	assert exists

	exists = true
	app.cmds.get('v') or { exists = false }
	assert !exists
}

fn test_app_parse_no_args() {
	app := App.new(name: clive.app_name)
	cmd := app.parse([app.name])!
	assert cmd.name == 'help'
	assert isnil(cmd.exec)
}

fn test_app_parse_help() {
	app := App.new(name: clive.app_name)
	cmd := app.parse([app.name, 'help'])!
	assert cmd.name == 'help'
	assert isnil(cmd.exec)
}

fn test_app_parse_version() {
	app := App.new(name: clive.app_name)
	cmd := app.parse([app.name, 'version'])!
	assert cmd.name == 'version'
	assert isnil(cmd.exec)
}

fn test_app_parse_cmd() {
	mut app := App.new(name: clive.app_name)
	cmd := Cmd.new(
		name: 'cmd'
		exec: cmd_exec
	)

	app.cmds.add(cmd)

	c := app.parse([app.name, cmd.name])!
	assert c.name == cmd.name
	assert c.exec == cmd_exec
}

fn test_app_parse_cmd_alias() {
	mut app := App.new(name: clive.app_name)
	cmd := Cmd.new(
		name: 'cmd'
		alias: 'c'
		exec: cmd_exec
	)

	app.cmds.add(cmd)

	c := app.parse([app.name, cmd.alias])!
	assert c.name == cmd.name
	assert c.exec == cmd_exec
}

fn test_app_parse_cmd_with_args() {
	mut app := App.new(name: clive.app_name)
	mut cmd := Cmd.new(
		name: 'cmd'
		exec: cmd_exec
	)

	sarg := StringArg.new(name: 'sarg')
	iarg := IntArg.new(
		name: 'iarg'
		multiple: true
	)

	cmd.args.add(sarg)
	cmd.args.add(iarg)
	app.cmds.add(cmd)

	os_args := [
		app.name,
		cmd.name,
		'iarg=123,456,789',
		'sarg=somestring',
	]

	c := app.parse(os_args)!

	assert c.name == cmd.name
	assert c.exec == cmd_exec

	ints := c.args.get_ints('iarg') or { [] }
	assert ints == [123, 456, 789]

	str := c.args.get_string('sarg') or { '' }
	assert str == 'somestring'
}

fn test_app_parse_sub_cmd() {
	mut app := App.new(name: clive.app_name)
	mut cmd1 := Cmd.new(name: 'cmd1')
	cmd2 := Cmd.new(
		name: 'cmd2'
		exec: cmd_exec
	)

	cmd1.cmds.add(cmd2)
	app.cmds.add(cmd1)

	os_args := [
		app.name,
		cmd1.name,
		cmd2.name,
	]

	c := app.parse(os_args)!

	assert c.name == cmd2.name
	assert c.exec == cmd_exec
}

fn test_app_parse_sub_cmd_with_aliases() {
	mut app := App.new(name: clive.app_name)
	mut cmd1 := Cmd.new(
		name: 'cmd1'
		alias: 'c1'
	)
	cmd2 := Cmd.new(
		name: 'cmd2'
		alias: 'c2'
		exec: cmd_exec
	)

	cmd1.cmds.add(cmd2)
	app.cmds.add(cmd1)

	os_args := [
		app.name,
		cmd1.alias,
		cmd2.alias,
	]

	c := app.parse(os_args)!

	assert c.name == cmd2.name
	assert c.exec == cmd_exec
}

fn test_app_parse_sub_cmd_with_args() {
	mut app := App.new(name: clive.app_name)
	mut cmd1 := Cmd.new(name: 'cmd1')
	mut cmd2 := Cmd.new(
		name: 'cmd2'
		exec: cmd_exec
	)

	sarg := StringArg.new(name: 'sarg')
	iarg := IntArg.new(
		name: 'iarg'
		multiple: true
	)

	cmd2.args.add(sarg)
	cmd2.args.add(iarg)
	cmd1.cmds.add(cmd2)
	app.cmds.add(cmd1)

	os_args := [
		app.name,
		cmd1.name,
		cmd2.name,
		'iarg=123,456,789',
		'sarg=somestring',
	]

	c := app.parse(os_args)!

	assert c.name == cmd2.name
	assert c.exec == cmd_exec

	ints := c.args.get_ints('iarg') or { [] }
	assert ints == [123, 456, 789]

	str := c.args.get_string('sarg') or { '' }
	assert str == 'somestring'
}

fn cmd_exec(cmd Cmd) {
}
