{
	local file is "1:/runmode.ks".
	export({
		parameter d.
		local runmode is 0.
		if exists(file) set runmode to import("runmode.ks").
		local sequence is list().
		local event is lex().
		local next is {
			parameter m is runmode + 1.
			if not exists(file) create(file).
			local h is open(file).
			h:clear().
			h:write("export("+m+").").
			set runmode to m.
		}.
		d(sequence, event, next).
		return {
			until runmode >= sequence:length {
				sequence[runmode]().
				for v in event:values v().
				wait 0.
			}
		}.
	}).
}