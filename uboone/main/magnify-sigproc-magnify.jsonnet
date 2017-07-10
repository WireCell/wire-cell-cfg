// This Jsonnet file configures WCT and wire-cell command line to run
// the signal processing.  It reads and writes a "magnify" file.

// Example jsonnet command line to test the Jsonnet compilation
// $ jsonnet -J cfg -V detector=uboone -V input=foo.root cfg/uboone/main/magnify-sigproc-magnify.jsonnet

// Full wire-cell command line:
//
// $ wire-cell -V detector=uboone \
//             -V input=nsp_2D_display_3455_0_6.root \
//             -V output=output.root \
//             -c uboone/main/magnify-sigproc-magnify.jsonnet


local wc = import "wirecell.jsonnet";

local anodes = import "multi/anodes.jsonnet";
local bits = import "uboone/sigproc/bits.jsonnet";
local filters = import "uboone/sigproc/filters.jsonnet";
local omni = import "uboone/sigproc/omni.jsonnet";

local magnify = import "uboone/io/magnify.jsonnet";

[

    {                           // main CLI
        type: "wire-cell",
        data: {
            // fixme: need gen for AnodePlane, best to move that to a 3rd lib
            plugins: ["WireCellGen", "WireCellSigProc", "WireCellSio"],
            apps: ["Omnibus"],
        }
    },


    magnify.source,

    anodes.nominal,

    bits.fieldresponse,

] + filters + [

    bits.perchanresp,

    // omni.noisefilter,
    omni.sigproc,

    magnify.sink,
    
    {
        type: "Omnibus",
        data: {
            source: wc.tn(magnify.source),
            sink: wc.tn(magnify.sink),
            filters: [wc.tn(omni.sigproc)],
        }
    },


]
