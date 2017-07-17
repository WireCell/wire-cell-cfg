local wc = import "wirecell.jsonnet";
local anodes = import "multi/anodes.jsonnet"; 
local magnify = import "uboone/io/magnify.jsonnet";
local omni = import "uboone/sigproc/omni.jsonnet";

// make local vars for these as we need to reference them a couple times.
local source = magnify.source { data: super.data { histtype: "orig" } };
local sink = magnify.sink { data: super.data { rebin: 1, histtype: "raw", shunt:["orig","baseline"] } };

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
    
    omni.noisedb,

    omni.noisefilter,

    sink,

    {
        type: "Omnibus",
        data: {
            source: wc.tn(source),
            sink: wc.tn(sink),
            filters: [wc.tn(omni.noisefilter)],
        }
    },
    
]
