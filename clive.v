module clive

pub const default_separator = ','

const truthy = ['t', 'true', 'y', 'yes', '1']
const errors = {
	'arg_invalid':           'Argument `<arg>` is invalid.'
	'arg_required':          'Argument `<arg>` is required.'
	'arg_no_value':          'Argument `<arg>` has no value.'
	'arg_not_found':         'Argument `<arg>` not found.'
	'arg_unexpected':        'Argument `<arg>` unexpected.'
	'arg_value_not_allowed': 'Argument `<arg>` does not accept `<val>`.'
	'cmd_unexpected':        'Command `<cmd>` unexpected.'
}

// vfmt off
pub fn err_msg(key string, data struct {
	cmd string = ''
	arg string = ''
	val string = ''
}) string {
	// vfmt on
	mut msg := clive.errors[key].clone()

	if !data.cmd.is_blank() {
		msg = msg.replace('<cmd>', data.cmd)
	}

	if !data.arg.is_blank() {
		msg = msg.replace('<arg>', data.arg)
	}

	if !data.val.is_blank() {
		msg = msg.replace('<val>', data.val)
	}

	return msg
}
