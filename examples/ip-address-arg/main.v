// Test with `v run main.v`

module main

import clive
import ip_address_arg

fn main() {
	mut app := clive.App.new(name: 'ip-address-arg')
	mut cmd := clive.Cmd.new(name: 'test-args')

	iparg := ip_address_arg.IPAddressArg.new(
		name: 'iparg'
		description: 'An IP address arg.'
		multiple: true
		default: '127.0.0.1'
	)

	cmd.args.add(iparg)
	app.cmds.add(cmd)

	mut os_args := [
		app.name,
		cmd.name,
	]

	println('Default value:')
	app.parse(os_args) or { println(err) }
	// clive won't have a get_ip_address() method, so
	// either implement your own or use get_string.
	// i := cmd.args.get_string('iparg') or { '' }
	if a := cmd.args.get('iparg') {
		if ipa := ip_address_arg.get_ip_address(a) {
			println('iparg: ${ipa.to_string()}')
		}
	}

	println('\nParsing error:')
	os_args << 'iparg=123.123.123.256'
	app.parse(os_args) or { println(err) }

	println('\nAnother parsing error:')
	os_args[2] = 'iparg=123.123.123'
	app.parse(os_args) or { println(err) }

	println('\nSingle value:')
	os_args[2] = 'iparg=192.168.1.1'
	app.parse(os_args) or { println(err) }

	if a := cmd.args.get('iparg') {
		if ipa := ip_address_arg.get_ip_address(a) {
			println('iparg: ${ipa.to_string()}')
		}
	}

	println('\nMultiple values:')
	os_args[2] = 'iparg=1.1.1.1|8.8.8.8'
	app.parse(os_args) or { println(err) }

	if a := cmd.args.get('iparg') {
		if ipas := ip_address_arg.get_ip_addresses(a) {
			println('iparg: ${ipas.map(it.to_string()).join('|')}')
		}
	}
}
