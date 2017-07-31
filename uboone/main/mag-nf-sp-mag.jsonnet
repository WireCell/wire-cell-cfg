// This main WCT configuration file configures a job to read in data
// from a Magnify file, run noise filtering, run signal processing and
// save the result to a new Magnify file.
//
// Run like:
//
// $ wire-cell -V detector=uboone \
//             -V input=orig-bl.root \
//             -V output=orig-bl-nf-sp.root \
//             -c uboone/main/mag-nf-sp-mag.jsonnet
//

local wc = import "wirecell.jsonnet";
local anodes = import "multi/anodes.jsonnet"; 
local magnify = import "uboone/io/magnify.jsonnet";
local omni = import "uboone/sigproc/omni.jsonnet";
local bits = import "uboone/sigproc/bits.jsonnet";
local filters = import "uboone/sigproc/filters.jsonnet";

// make local vars for these as we need to reference them a couple times.
local source = magnify.source {
    data: super.data {
        frames: ["orig"],
        cmmtree: [],            // none
    }
};
local sink = magnify.sink {
    data: super.data {
        frames: ["wiener", "gauss"],
        shunt:["Trun", "hu_orig", "hv_orig", "hw_orig",
               "hv_baseline","hu_baseline","hw_baseline"],
        cmmtree: [["bad","T_bad"], ["lf_noisy", "T_lf"]],
        summaries: ["threshold"],

    }
};

// now the main configuration sequence.
[
    {                           // main CLI
        type: "wire-cell",
        data: {
            // fixme: need gen for AnodePlane, best to move that to a 3rd lib
            plugins: ["WireCellGen", "WireCellSigProc", "WireCellSio"],
            apps: ["Omnibus"],
        }
    },

    source,

    anodes.nominal,
    
    // The channel noise database
    omni.noisedb,

    // individual noise filters used by the main filter.
    omni.channel_filters.bitshift,
    omni.channel_filters.single,
    omni.channel_filters.grouped,
    omni.channel_filters.status,

    // The main noise filter
    omni.noisefilter,
    // The PMT noise filter
    omni.pmtfilter,

    bits.fieldresponse,

    // low/hi frequency signal processing filters
] + filters + [

    // per channel response
    bits.perchanresp,

    // the main signal processing 
    omni.sigproc,

    sink,

    {
        type: "Omnibus",
        data: {
            source: wc.tn(source),
            sink: wc.tn(sink),
            filters: [		// linear chaing of frame filters
                wc.tn(omni.noisefilter),
                wc.tn(omni.pmtfilter),
		wc.tn(omni.sigproc),
            ],
        }
    },
    
]
