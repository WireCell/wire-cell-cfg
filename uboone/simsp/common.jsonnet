// Configuration for common, shared components.  These are things not
// directly part of a pipeline element and they may not be all used.
// This file's data structure is a free form object.

local wc = import "wirecell.jsonnet";
local params = import "params.jsonnet";


{
    cmdline: {
        type: "wire-cell",
        data: {
            plugins: ["WireCellGen", "WireCellPgraph", "WireCellSio", "WireCellSigProc"],
            apps: ["Pgrapher"]
        }
    },
    random : {
        type: "Random",
        data: {
            generator: "default",
            seeds: [0,1,2,3,4],
        }
    },
    fields : std.mapWithIndex(function (n, fname) {
        type: "FieldResponse",
        name: "field%d"%n,
        data: { filename: fname }
    }, params.files.fields),

    wires : {
        type: "WireSchemaFile",
        data: { filename: params.files.wires }
    },

    // 0:nominal, 1:uv-grounded, 2:vy-grounded
    anodes : std.mapWithIndex(function (n, fr) {
        type : "AnodePlane",
        name : "anode%d" % n,
        data : params.elec + params.daq {
            ident : 0,              // must match what's in wires
            field_response: wc.tn(fr),
            wire_schema: wc.tn($.wires),
            cathode: [{x:params.detector.extent[0], y:0.0, z:0.0}],
        },
        uses: [fr, $.wires],
    }, $.fields),

    anode: $.anodes[0],         // one special/nominal anode

}
