module clive

import strconv

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

// vfmt off
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
	// vfmt on
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

fn (self FloatArg) validate(input string) ![]string {
	error_message := err_msg('arg_invalid', arg: self.name)

	vals := if self.multiple {
		input.split(self.separator)
	} else {
		[input]
	}

	for v in vals {
		strconv.atof64(v) or { return error(error_message) }
	}

	return vals
}

pub fn (self FloatArg) stored() ?[]string {
	if self.values.len > 0 {
		return self.values
	}

	return none
}

pub fn (mut self FloatArg) store(input string) ! {
	self.values = self.validate(input)!
}

pub fn (mut self FloatArg) parse(input string) ! {
	self.store(input)!
}
