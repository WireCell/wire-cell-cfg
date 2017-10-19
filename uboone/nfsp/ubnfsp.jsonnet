// This is a main Wire Cell Toolkit configuration file for use with
// art/LArSoft.
//
// It configures WCT to run inside LArSoft in order to run MicroBooNE
// noise filtering (NF) and signal processing (SP).

// Most of the configuration is provided as part of WCT as located by
// directories in a WIRECELL_PATH environment variable.


// These are provided by the wire-cell-cfg package.
local wc = import "wirecell.jsonnet";
local gen = import "general.jsonnet";
local nf = import "nf.jsonnet";
local sp = import "sp.jsonnet";
local params = import "params.jsonnet";
local chndb_data = import "chndb_data.jsonnet"; 


// Override parts of the NF config in order to use LArSoft-specific
// channel noise database class.
local wcls_nf = (if std.extVar("noisedb") == "static" then nf else nf {
    chndb : {
	type: "wclsChannelNoiseDB",
	data: chndb_data {
	    // don't set bad_channel policy.  NF determines bad channels internally
	    // bad_channel: { policy: "replace" },
	    misconfig_channel: {
                policy: "replace",
                from: {gain:  4.7*wc.mV/wc.fC, shaping: 1.1*wc.us},
                to:   {gain: 14.0*wc.mV/wc.fC, shaping: 2.2*wc.us},
	    }
	}
    }
});

// This source converts between LArSoft raw::RawDigit and WCT IFrame
// for input to WCT.  
local source = {
    type: "wclsRawFrameSource",
    data: {
	// used to locate the input raw::RawDigit in the art::Event
        source_label: "daq",
	// names the output frame tags and likely must match the next
	// IFrameFilter (eg, that for the NF)
        frame_tags: ["orig"],
	nticks: params.frequency_bins,
    },
};

// This sink converts between WCT IFrame and LArSoft recob::Wire for
// output from WCT.
local sink = {
    type: "wclsCookedFrameSink",
    data: {
	// Output frame tags to look for.  These must be what are
	// provided by the last IFrameFilter (ie, those from SP).
        frame_tags: ["gauss", "wiener"],
	nticks: params.output_nticks,
    },
};


// Finally, the main config sequence puts it all together.

[
    source,
    sink,

] + gen.sequence + wcls_nf.sequence + sp.sequence + [

    {
        type: "Omnibus",
        data: {
            source: wc.tn(source),
            sink: wc.tn(sink),
            filters: std.map(wc.tn, wcls_nf.frame_filters + sp.frame_filters)
        }
    },
    
]    
