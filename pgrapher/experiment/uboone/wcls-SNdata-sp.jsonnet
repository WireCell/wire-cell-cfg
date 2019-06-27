local reality = std.extVar("reality");

local wc = import "wirecell.jsonnet";
local g = import "pgraph.jsonnet";

local raw_input_label = std.extVar("raw_input_label"); // eg "daq"

local data_params = import "params.jsonnet";
local simu_params = import "simparams.jsonnet";
local params_base = if reality == "data" then data_params else simu_params;
local params = params_base {
	daq: super.daq {
		nticks: 6400 // truncation
	}
};

local tools_maker = import "pgrapher/common/tools.jsonnet";
local tools = tools_maker(params);

local wcls_maker = import "pgrapher/ui/wcls/nodes.jsonnet";
local wcls = wcls_maker(params, tools);

local nf_maker = import "pgrapher/experiment/uboone/nf.jsonnet";

local sp_maker = import "pgrapher/experiment/uboone/sp_SNdata.jsonnet";

// Collect the WC/LS input converters for use below.  Make sure the
// "name" argument matches what is used in the FHiCL that loads this
// file.  In particular if there is no ":" in the inputer then name
// must be the emtpy string.
local wcls_input = {
    SNdata_filtered: g.pnode({
        type: 'wclsCookedFrameSource',
        name: "",
        data: {
            art_tag: raw_input_label,
            frame_tags: ["raw"], // this is a WCT designator
            nticks: 6400, 
        },
    }, nin=0, nout=1),

};

// Collect all the wc/ls output converters for use below.  Note the
// "name" MUST match what is used in theh "outputers" parameter in the
// FHiCL that loads this file.
local wcls_output = {
    // The output of signal processing.  Note, there are two signal
    // sets each created with its own filter.  The "gauss" one is best
    // for charge reconstruction, the "wiener" is best for S/N
    // separation.  Both are used in downstream WC code.
    sp_signals: g.pnode({
        type: "wclsFrameSaver",
        name: "spsaver", 
        data: {
            anode: wc.tn(tools.anode),
            digitize: false,         // true means save as RawDigit, else recob::Wire
            frame_tags: ["gauss", "wiener"],
            nticks: 6400,
            chanmaskmaps: [],
        },
    },nin=1, nout=1, uses=[tools.anode]),

    // save "threshold" from normal decon for each channel noise
    // used in imaging
    sp_thresholds: wcls.output.thresholds(name="spthresholds", tags=["threshold"]),
};

local sp = sp_maker(params, tools);

local sink = g.pnode({ type: "DumpFrames" }, nin=1, nout=0);

local graph = g.pipeline([wcls_input.SNdata_filtered,
                          sp,
			  wcls_output.sp_thresholds,
                          wcls_output.sp_signals,
                          sink]);

local app = {
    type: "Pgrapher",
    data: {
        edges: g.edges(graph),
    },
};

// Finally, the configuration sequence 
g.uses(graph) + [app]
