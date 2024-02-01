# Description

`clive` is a CLI parsing library for [Vlang](https://vlang.io). It was
originally based on the V standard library `cli`, but has since been
rewritten a few times and should only possess a passing resemblance. ;)

`clive` tries to strike a balance between generalizing behavior and
giving you control. For example, if you create a custom arg type,
parsing is completely up to you. Clive, on the other hand, will
ensure defaults are stored, ensure stored values match available
choices (where appropriate), and check for required arguments.

# `clive.App`

```
@[noinit]
pub struct App {
pub:
	name        string @[required]
	description string
	version     string
pub mut:
	cmds Cmds
}

pub fn App.new(attrs struct {
	name string
	description string
	version string
}) App {
	mut app := App{
		name: attrs.name
		description: attrs.description
		version: attrs.version
	}

	app.cmds.add(Cmd.new(name: 'help'))
	app.cmds.add(Cmd.new(name: 'version'))

	return app
}
```

An `app` is the entry point of an application, and it must have
commands. The idea behind this decision is if you are building a
CLI _application_, it's most likely a complex collection of
related functionality. If this is not the case, maybe a shell
script will work out better?

`help` and `version` commands are added automatically to an `app`, but
they have no aliases in order to not conflict with commands you will
add to the `app`.

When adding commands to the `app`, if a command already exists with
the same name or alias, it will be silently ignored. The first one
wins, not the last.

# `clive.Cmd`

```
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

pub fn Cmd.new(attrs struct {
	name string
	alias string
	description string
	exec FnCmdExec = unsafe { nil }
}) Cmd {
	mut cmd := Cmd{
		name: attrs.name
		alias: attrs.alias
		description: attrs.description
		exec: attrs.exec
	}

	if !['help', 'version'].contains(attrs.name) {
		cmd.cmds.add(Cmd.new(name: 'help'))
	}

	return cmd
}

```

Commands are the bits that _do_ something in the application. They can
have an alias of your choosing. They can have sub-commands, which can
also have sub-commands. They can have arguments (see below).

`help` is added to all commands automatically, but there is no alias
(for the same reason mentioned above). If you add a command that does
not have an `exec` callback, `help` will be called automatically if you
do not pass anything to the command.

As with adding commands to an `app`, the first one with name/alias wins.

# `clive.IArg`

```
pub interface IArg {
	kind        string
	name        string
	alias       string
	description string
	separator   string
	multiple    bool
	required    bool
	default     string
	choices     []string
	stored() ?[]string
mut:
	parse(string) !
	store(string) !
}
```

Arguments are the bits that change how commands behave. They are all named,
not positional, and can therefore be supplied in any order. Like commands,
arguments can have an alias of your choosing. They can have single or
multiple values, can be required or not, have a default value, and be
restricted to a given list of choices. When you allow multiple values, you
can define whatever separator you like. `clive` defaults to a comma.

You may have noticed that `IArg` is an interface and not a struct. This is
because `clive` allows you to define your own custom arguments. As long as
you satisfy the interface, you can do whatever you need to in order to
implement an argument of arbitrary complexity. See the `IPAddressArg` example
in `examples/ip-address-arg`.

When supplying arguments and values on the command line, the argument name
must be followed by `=` (equal sign), which is followed by the value(s). No
spaces. For example

```
$ app cmd arg=val
```

Between all arguments being named and allowing only a single way
to populate arguments, the implementation in `clive` is significantly
simplified.

`clive` provides basic argument types `BoolArg`, `FloatArg`, `IntArg`, and
`StringArg`.

## `clive.BoolArg`

```
@[noinit]
pub struct BoolArg {
pub:
	kind        string   @[required]
	name        string   @[required]
	alias       string
	description string
	separator   string
	multiple    bool
	required    bool
	default     string
	choices     []string
mut:
	value string
}

pub fn BoolArg.new(attrs struct {
	name string
	alias string
	description string
	required bool
	default string
}) IArg {
	return IArg(BoolArg{
		kind: 'bool'
		name: attrs.name
		alias: attrs.alias
		description: attrs.description
		multiple: false
		required: attrs.required
		default: attrs.default
		choices: []string{}
	})
}
```

Notice that `BoolArg` does not allow multiple values as I could not think of a
of a reasonable use case. If you have one, let me know and I'll reconsider.

By default, `BoolArg` accepts the following as truthy, in any combination of case:

```
const truthy = ['t', 'true', 'y', 'yes', '1']
```

Everything else is considered falsey.

When defining custom argument types, `kind` can be whatever you want it to be
and is used only when generating `help` output.

Note that with all of the supplied types, `default` and `choices` are `string`s
to allow for the absence of values. If the "constructors" were changed to accept
actual types, they would be initialized with values corresponding to their types
and could incorrectly imply the presence of a default value.

## `clive.FloatArg`

```
@[noinit]
pub struct FloatArg {
pub:
	kind        string   @[required]
	name        string   @[required]
	alias       string
	description string
	separator   string
	multiple    bool
	required    bool
	default     string
	choices     []string
mut:
	values []string
}

pub fn FloatArg.new(attrs struct {
	name string
	alias string
	description string
	separator string = default_separator
	multiple bool
	required bool
	default string
	choices []string
}) IArg {
	return IArg(FloatArg{
		kind: 'float'
		name: attrs.name
		alias: attrs.alias
		description: attrs.description
		separator: attrs.separator
		multiple: attrs.multiple
		required: attrs.required
		default: attrs.default
		choices: attrs.choices
	})
}
```

## `clive.IntArg`

```
@[noinit]
pub struct IntArg {
pub:
	kind        string   @[required]
	name        string   @[required]
	alias       string
	description string
	separator   string
	multiple    bool
	required    bool
	default     string
	choices     []string
mut:
	values []string
}

pub fn IntArg.new(attrs struct {
	name string
	alias string
	description string
	separator string = default_separator
	multiple bool
	required bool
	default string
	choices []string
}) IArg {
	return IArg(IntArg{
		kind: 'int'
		name: attrs.name
		alias: attrs.alias
		description: attrs.description
		separator: attrs.separator
		multiple: attrs.multiple
		required: attrs.required
		default: attrs.default
		choices: attrs.choices
	})
}
```

## `clive.StringArg`

```
@[noinit]
pub struct StringArg {
pub:
	kind        string   @[required]
	name        string   @[required]
	alias       string
	description string
	separator   string
	multiple    bool
	required    bool
	default     string
	choices     []string
mut:
	values []string
}

pub fn StringArg.new(attrs struct {
	name string
	alias string
	description string
	separator string = default_separator
	multiple bool
	required bool
	default string
	choices []string
}) IArg {
	return IArg(StringArg{
		kind: 'string'
		name: attrs.name
		alias: attrs.alias
		description: attrs.description
		separator: attrs.separator
		multiple: attrs.multiple
		required: attrs.required
		default: attrs.default
		choices: attrs.choices
	})
}
```

# Example

```
module main

import os
import clive

fn main() {
	mut app := clive.App.new(
		name: 'dep'
		description: 'Deployment utility.'
		version: '0.1.0'
	)

	mut deploy_cmd := clive.Cmd.new(
		name: 'deploy'
		description: 'Deploy an application to an environment.'
		exec: deploy
	)

	env_arg := clive.StringArg.new(
		name: 'environment'
		alias: 'env'
		description: 'The environment to deploy to.'
		required: true
		default: 'dev'
		choices: ['dev', 'qa', 'prod']
	)

	deploy_cmd.args.add(env_arg)

	app_arg := clive.StringArg.new(
		name: 'application'
		alias: 'app'
		description: 'The application to deploy.'
		required: true
		multiple: true
		choices: ['app-one', 'app-two', 'app-three', 'app-four']
	)

	deploy_cmd.args.add(app_arg)

	retries_arg := clive.IntArg.new(
		name: 'retries'
		alias: 'r'
		description: 'The number of times to retry a deployment.'
		default: '3'
	)

	deploy_cmd.args.add(retries_arg)
	app.cmds.add(deploy_cmd)

	mut check_cmd := clive.Cmd.new(
		name: 'check'
		description: 'Check the version of an application in an environment.'
		exec: check
	)

	// Notice args can be "reused" for multiple commands. This has not been
	// fully tested.
	check_cmd.args.add(env_arg)
	check_cmd.args.add(app_arg)
	app.cmds.add(check_cmd)

	cmd := app.parse(os.args) or {
		println(err)
		exit(1)
	}

	if !isnil(cmd.exec) {
		cmd.exec(cmd.args)
	}
}

fn deploy(args clive.Args) {
	// You can get stored values using convenience methods.
	// Note these methods return `none` if either the arg
	// does not exist or it has no stored value(s).
	env := args.get_string('environment') or { '' }
	apps := args.get_strings('application') or { [] }
	retries := args.get_int('retries') or { 0 }
	println('Deploying ${apps.join(',')} to ${env} with ${retries} retries.')
}

fn check(args clive.Args) {
	// You can get stored values using convenience methods.
	// Note these methods return `none` if either the arg
	// does not exist or it has no stored value(s).
	env := args.get_string('environment') or { '' }
	apps := args.get_strings('application') or { [] }
	println('Checking the version of ${apps.join(',')} in ${env}.')
}

```

From the command line, invocation would look something like:

```
$ dep deploy env=qa app=app-one,app-two
$ dep check app=app-two env=prod
```

# To Do

* Add more documentation.
* Ensure adequate test coverage.
