module clive

const cmd_name = 'my_cmd'
const cmd_alias = 'mc'
const cmd_desc = 'My Command'

fn test_cmd_new() {
	cmd := Cmd.new(
		name: clive.cmd_name
		alias: clive.cmd_alias
		description: clive.cmd_desc
		exec: cmd_exec
	)

	assert cmd.name == clive.cmd_name
	assert cmd.alias == clive.cmd_alias
	assert cmd.description == cmd.description
	assert cmd.exec == cmd_exec
}

fn test_cmd_new_defaults() {
	cmd := Cmd.new(name: clive.cmd_name)

	assert cmd.name == clive.cmd_name
	assert cmd.alias.is_blank()
	assert cmd.description.is_blank()
	assert isnil(cmd.exec)
}

fn test_cmds_add() {
	mut cmd1 := Cmd.new(name: 'cmd1')
	cmd2 := Cmd.new(name: 'cmd2', alias: 'c2')
	cmd1.cmds.add(cmd2)

	mut name_exists := true
	cmd1.cmds.get(cmd2.name) or { name_exists = false }
	assert name_exists

	mut alias_exists := true
	cmd1.cmds.get(cmd2.alias) or { alias_exists = false }
	assert alias_exists
}

fn test_cmds_get() {
	mut cmd1 := Cmd.new(name: 'cmd1')
	cmd2 := Cmd.new(name: 'cmd2', alias: 'c2')
	cmd1.cmds.add(cmd2)

	match cmd1.cmds.get(cmd2.name) {
		none { assert false }
		else { assert true }
	}

	match cmd1.cmds.get(cmd2.alias) {
		none { assert false }
		else { assert true }
	}
}

fn test_cmds_get_none() {
	cmd := Cmd.new(name: clive.cmd_name)
	match cmd.cmds.get('does-not-exist') {
		none { assert true }
		else { assert false }
	}
}

fn test_cmds_new_adds_help() {
	cmd := Cmd.new(name: clive.cmd_name)
	mut exists := true
	cmd.cmds.get('help') or { exists = false }
	assert exists

	exists = true
	cmd.cmds.get('h') or { exists = false }
	assert !exists
}

fn cmd_exec(args Args) {
}
