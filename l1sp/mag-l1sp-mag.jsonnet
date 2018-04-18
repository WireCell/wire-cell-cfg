local wc = import "wirecell.jsonnet";

local params = import "params.jsonnet";

local cmdline = {
    type: "wire-cell",
    data: {
        plugins: ["WireCellGen", "WireCellPgraph", "WireCellSio", "WireCellSigProc"],
        apps: ["Pgrapher"]
    }
};

local random = {
    type: "Random",
    data: {
        generator: "default",
        seeds: [0,1,2,3,4],
    }
};
local utils = [cmdline, random];

local anode = {
    type : "AnodePlane",
    data : params.elec + params.daq + params.files {
        ident : 0,
    }
};

local magsource = {
    type: "MagnifySource",
    data: {
        filename: std.extVar("input"),
        frames: ["raw","wiener","gauss"],
        // Map between a channel mask map key name and its TTree for reading.
        cmmtree: [         
        ],
    }
};

local magsink = {
    type: "MagnifySink",
    data: {
//        input_filename: std.extVar("input"),
        output_filename: std.extVar("output"),

	// this best be made consistent
	anode: wc.tn(anode),

        // The list of tags on traces to select groups of traces
        // to form into frames.
        frames: ["raw","wiener","gauss"],

        // The list of summary tags to save as 1D hisograms.
        summaries: [],

        // The evilness includes shunting data directly from input
        // file to output file.  This allows the shunt to be
        // limited to the listed histogram categories.  The
        // possible categories include: orig, raw, decon,
        // threshold, baseline and possibly others.  If the value
        // is left unset or null then all categories known to the
        // code will be shunted.
        shunt: [],

        // Map between a channel mask map key name and its TTree for writing.
        cmmtree: [         
            //["bad", "T_bad"],
            //["lf_noisy", "T_lf"],
        ],

    },
};

local frame_sink = {            // no config
    type: "DumpFrames",
};

local mag = [magsource, magsink, anode];

local fsplit = {                // no config
    type: "FrameSplitter",
};

local fmerge = {
    type: "FrameMerger",
    data: {
        rule: "replace",
        mergemap: [
            ["raw","raw","raw"],
            ["l1sp","gauss","gauss"],
            ["l1sp","wiener","wiener"],
        ],
    }
};
local flow = [fmerge];


local app = {
    type: "Pgrapher",
    data: {
        edges: [
            {
                tail: { node: wc.tn(magsource) },
                head: { node: wc.tn(fsplit) },
            },
            {
                tail: { node: wc.tn(fsplit), port:0 },
                head: { node: wc.tn(fmerge), port:0 },
            },
            {
                tail: { node: wc.tn(fsplit), port:1 },
                head: { node: wc.tn(fmerge), port:1 },
            },
            {
                tail: { node: wc.tn(fmerge) },
                head: { node: wc.tn(magsink) },
            },
            {
                tail: { node: wc.tn(magsink) },
                head: { node: wc.tn(frame_sink) },
            },
        ],
    }        
};

utils + mag + flow + [app]
