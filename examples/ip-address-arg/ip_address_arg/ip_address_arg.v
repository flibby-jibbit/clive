module ip_address_arg

import clive

struct IPAddress {
	octets []string @[required]
}

pub fn get_ip_address(arg clive.IArg) ?IPAddress {
	if stored := arg.stored() {
		if ipa := IPAddress.new(stored.first()) {
			return ipa
		}
	}

	return none
}

pub fn get_ip_addresses(arg clive.IArg) ?[]IPAddress {
	if stored := arg.stored() {
		mut addrs := []IPAddress{}

		for addr in stored {
			if ipa := IPAddress.new(addr) {
				addrs << ipa
			}
		}

		return addrs
	}

	return none
}

fn IPAddress.new(input string) !IPAddress {
	pieces := input.split('.')
	if pieces.len != 4 {
		return error('Not enough octets: ${input}')
	}

	mut octets := []string{}

	for piece in pieces {
		if piece.int() < 0 || piece.int() > 255 {
			return error('Octet ${piece} invalid.')
		}

		octets << piece
	}

	return IPAddress{
		octets: octets
	}
}

pub fn (self IPAddress) to_string() string {
	return self.octets.join('.')
}

@[noinit]
struct IPAddressArg {
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
	// This can be whatever you want
	values []string
}

// vfmt off
pub fn IPAddressArg.new(attrs struct {
	name string
	alias string
	description string
	separator string = '|'
	multiple bool
	required bool
	default string
	choices []string
}) clive.IArg {
	// vfmt on
	return clive.IArg(IPAddressArg{
		kind: 'IP address'
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

fn (self IPAddressArg) validate(input string) !string {
	ipa := IPAddress.new(input)!
	return ipa.to_string()
}

pub fn (mut self IPAddressArg) parse(input string) ! {
	// Validation and storage are completely up to you.
	self.store(input)!
}

pub fn (self IPAddressArg) stored() ?[]string {
	// Store the values however you want, just return
	// an array of strings here.
	if self.values.len > 0 {
		return self.values
	}

	return none
}

pub fn (mut self IPAddressArg) store(input string) ! {
	mut addrs := []string{}

	if self.multiple {
		for addr in input.split(self.separator) {
			addrs << self.validate(addr)!
		}
	} else {
		addrs = [self.validate(input)!]
	}

	self.values = addrs
}
