module clive

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

// vfmt off
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
	// vfmt on
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

fn (self StringArg) validate(input string) ![]string {
	error_message := err_msg('arg_invalid', arg: self.name)

	vals := if self.multiple {
		input.split(self.separator)
	} else {
		[input]
	}

	for v in vals {
		if v.trim_space().is_blank() {
			return error(error_message)
		}
	}

	return vals
}

pub fn (self StringArg) stored() ?[]string {
	if self.values.len > 0 {
		return self.values
	}

	return none
}

pub fn (mut self StringArg) store(input string) ! {
	self.values = self.validate(input)!
}

pub fn (mut self StringArg) parse(input string) ! {
	self.store(input)!
}
