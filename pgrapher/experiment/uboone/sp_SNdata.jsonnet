// This provides signal processing related pnodes, 

local wc = import "wirecell.jsonnet";
local g = import "pgraph.jsonnet";

function(params, tools) {

    local sigproc_perchan = g.pnode({
        type: "OmnibusSigProc",
        data: {
            // This class has a HUGE set of parameters.  See
            // OmnibusSigProc.h for the list.  For here, for now, we
            // mostly just defer to the hard coded configuration values.
            // They can be selectively overriddent.  This class also hard
            // codes a slew of SP filter component names which MUST
            // correctly match what is provided in sp-filters.jsonnet.
            anode: wc.tn(tools.anode),
            field_response: wc.tn(tools.field),
            per_chan_resp: wc.tn(tools.perchanresp),
	    fft_flag: 0,   // 1 is faster but higher memory, 0 is slightly slower but lower memory
        }
    }, nin=1,nout=1, uses=[tools.anode, tools.field, tools.perchanresp] + import "sp-filters.jsonnet"),
local sigproc_uniform = g.pnode({
        type: "OmnibusSigProc",
        data: {
            anode: wc.tn(tools.anode),
            field_response: wc.tn(tools.field),
            per_chan_resp: "",
            shaping: params.elec.shaping,
	    fft_flag: 0,    // 1 is faster but higher memory, 0 is slightly slower but lower memory	
        }
    }, nin=1,nout=1,uses=[tools.anode, tools.field] + import "sp-filters.jsonnet"),

    // ch-by-ch response correction in SP turn off by setting null input
    local sigproc = if std.type(params.files.chresp)=='null'
                    then sigproc_uniform
                    else sigproc_perchan,

    return: sigproc,

}.return
