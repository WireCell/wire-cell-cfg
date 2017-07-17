// This Jsonnet file configures WCT and wire-cell command line to run
// the noise filtering and signal processing.  It reads and writes a
// "magnify" file.

// Example jsonnet command line to test the Jsonnet compilation
// $ jsonnet -J cfg \
//           -V detector=uboone \
//           -V input=inmag.root \
//           -V outmag.root \
//    cfg/uboone/main/magnify-noisefilter-sigproc-magnify.jsonnet
// 
// Full wire-cell command line:
//
// $ wire-cell -V detector=uboone \
//             -V input=inmag.root \
//             -V output=outmag.root \
//             -c uboone/main/magnify-noisefilter-sigproc-magnify.jsonnet

local wc = import "wirecell.jsonnet";
local anodes = import "multi/anodes.jsonnet"; 
local magnify = import "uboone/io/magnify.jsonnet";
local omni = import "uboone/sigproc/omni.jsonnet";


local bits = import "uboone/sigproc/bits.jsonnet";
local filters = import "uboone/sigproc/filters.jsonnet";

local magnify = import "uboone/io/magnify.jsonnet";

// make local vars for these as we need to reference them a couple times.
local source = magnify.source { data: super.data { histtype: "orig" } };
local sink = magnify.sink { data: super.data { rebin: 1, histtype: "decon", shunt:["orig","baseline"] }};

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

] + filters + [
    
    bits.fieldresponse,
    bits.perchanresp,

    omni.noisedb,

    // the payload
    omni.noisefilter,
    omni.sigproc,

    sink,

    {
        type: "Omnibus",
        data: {
            source: wc.tn(source),
            sink: wc.tn(sink),
            filters: [wc.tn(omni.noisefilter), wc.tn(omni.sigproc)],
        }
    },
    
]
