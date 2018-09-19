// This provides signal processing related pnodes, 

local wc = import "wirecell.jsonnet";
local g = import "pgraph.jsonnet";

// BIG FAT FIXME: we are taking from uboone.  If PDSP needs tuning do
// four things: 0) read this comment, 1) cp this file into pdsp/, 2)
// fix the import and 3) delete this comment.
local spfilt = import "pgrapher/experiment/uboone/sp-filters.jsonnet";

function(params, tools) {

    local pc = tools.perchanresp_nameuses,

    // pDSP needs a per-anode sigproc
    make_sigproc(anode, name=null) :: g.pnode({
        type: "OmnibusSigProc",
        name:
        if std.type(name) == 'null'
        then anode.name + "sigproc"
        else name,

        data: {
            // Many parameters omitted here.
            anode: wc.tn(anode),
            field_response: wc.tn(tools.field),
            per_chan_resp: pc.name,
        },
    }, nin=1, nout=1, uses=[anode, tools.field] + pc.uses + spfilt),

}
