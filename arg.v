module clive

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

@[noinit]
pub struct Args {
mut:
	args []IArg
}

fn (self Args) all() []IArg {
	return self.args
}

fn (self Args) check_required() ! {
	for arg in self.args.filter(it.required) {
		arg.stored() or {
			error_message := err_msg('arg_required', arg: arg.name)
			return error(error_message)
		}
	}
}

fn (mut self Args) store_defaults() ! {
	for mut arg in self.args {
		// Does a default need to be set?
		if !arg.default.is_blank() {
			stored := arg.stored() or { [] }
			if stored.len == 0 {
				arg.store(arg.default)!
			}
		}
	}
}

fn (self Args) ensure_choices() ! {
	for arg in self.args {
		if arg.choices.len > 0 {
			stored := arg.stored() or { [] }
			for s in stored {
				if !arg.choices.contains(s) {
					error_message := err_msg('arg_value_not_allowed', arg: arg.name, val: s)
					return error(error_message)
				}
			}
		}
	}
}

pub fn (self Args) get(identifier string) ?IArg {
	// Originally tried using
	//   self.args.filter([it.name, it.alias].contains(identifier))
	// but V complained about name/alias not implementing the IArg
	// interface in the contains call. WTF?
	for arg in self.args {
		if [arg.name, arg.alias].contains(identifier) {
			return arg
		}
	}

	return none
}

pub fn (mut self Args) add(arg IArg) {
	name_exists := self.args.any(it.name == arg.name)
	alias_exists := !arg.alias.is_blank() && self.args.any(it.alias == arg.alias)

	if !(name_exists || alias_exists) {
		self.args << arg
	}
}

fn (self Args) ensure_value(value string, separator string) bool {
	vals := value.split(separator).map(it.trim_space())
	return !vals.join('').is_blank()
}

pub fn (mut self Args) parse(input []string) ! {
	if input.len > self.args.len {
		error_message := err_msg('arg_unexpected', arg: input.last())
		return error(error_message)
	}

	// for each identifier=value pair
	for pair in input {
		mut identifier := pair
		mut value := ''

		if pair.contains('=') {
			tokens := pair.split('=')
			identifier = tokens.first()
			value = tokens.last()
		}

		// self.get returns a completely different "object,"
		// so parsing won't store the parsed value in the
		// "object" in the array, so we have to parse
		// the "instance" in self.args. Note that the
		// use of "object" and "instance" is done only for
		// convenience and should not be interpreted as V
		// is an object-oriented language. It is not.
		for mut arg in self.args {
			if [arg.name, arg.alias].contains(identifier) {
				if !self.ensure_value(value, arg.separator) {
					error_message := err_msg('arg_no_value', arg: arg.name)
					return error(error_message)
				}

				arg.parse(value)!
			}
		}
	}

	// Make sure defaults are stored. We have to look at this after
	// processing input because they very likely were not part of that
	// input. ;)
	self.store_defaults()!

	// Now let's ensure stored values are acceptable. This comes after
	// storing defaults because we want to ensure defaults are allowed,
	// too. Tedious, I know. :(
	self.ensure_choices()!

	// Now that all the input has been parsed, defaults have been
	// stored, and choices validated, let's check to see if any
	// required args are without values.
	self.check_required()!
}

fn (self Args) stored(identifier string) ?[]string {
	if arg := self.get(identifier) {
		if stored := arg.stored() {
			return stored
		}
	}

	return none
}

pub fn (self Args) get_bool(identifier string) ?bool {
	if stored := self.stored(identifier) {
		return truthy.contains(stored.first().to_lower())
	}

	return none
}

pub fn (self Args) get_string(identifier string) ?string {
	if stored := self.stored(identifier) {
		return stored.first()
	}

	return none
}

pub fn (self Args) get_strings(identifier string) ?[]string {
	if stored := self.stored(identifier) {
		return stored
	}

	return none
}

pub fn (self Args) get_int(identifier string) ?int {
	if stored := self.stored(identifier) {
		return stored.first().int()
	}

	return none
}

pub fn (self Args) get_ints(identifier string) ?[]int {
	if stored := self.stored(identifier) {
		return stored.map(it.int())
	}

	return none
}

pub fn (self Args) get_float(identifier string) ?f64 {
	if stored := self.stored(identifier) {
		return stored.first().f64()
	}

	return none
}

pub fn (self Args) get_floats(identifier string) ?[]f64 {
	if stored := self.stored(identifier) {
		return stored.map(it.f64())
	}

	return none
}
