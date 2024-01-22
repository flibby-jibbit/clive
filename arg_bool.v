module clive

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

// vfmt off
pub fn BoolArg.new(attrs struct {
	name string
	alias string
	description string
	required bool
	default string
}) IArg {
	// vfmt on
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

fn (self BoolArg) validate(input string) !string {
	if input.trim_space().is_blank() {
		error_message := err_msg('arg_invalid', arg: self.name)
		return error(error_message)
	}

	return input
}

pub fn (self BoolArg) stored() ?[]string {
	if !self.value.is_blank() {
		return [self.value]
	}

	return none
}

pub fn (mut self BoolArg) store(input string) ! {
	self.value = self.validate(input)!
}

pub fn (mut self BoolArg) parse(input string) ! {
	self.store(input)!
}
