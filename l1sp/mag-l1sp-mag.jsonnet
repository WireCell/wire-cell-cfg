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

local chsel = {
    type: "ChannelSelector",
    data: {
        // channels that will get L1SP applied
        channels: [10,20,30,2410,2420,2430,4810,4820,4830],

        // can pass on only the tags of traces that are actually needed.
        tags: ["raw","gauss"]
    }
};

local l1sp = {
    type: "L1SPFilter",
    data: {
        filter: [0.0,0.0,0.0,0.5,1.0,0.5,0.0,0.0], // bogus place holder
        adctag: "raw",                             // trace tag of raw data
        sigtag: "gauss",                           // trace tag of input signal
        outtag: "l1sp",                            // trace tag for output signal
    }
};

local fmerge = {
    type: "FrameMerger",
    data: {
        rule: "replace",

        // note: the first two need to match the order of what data is
        // fed to ports 0 and 1 of this component in the pgraph below!
        mergemap: [
            ["raw","raw","raw"],
            ["l1sp","gauss","gauss"],
            ["l1sp","wiener","wiener"],
        ],
    }
};
local flow = [chsel, l1sp, fmerge];


local app = {
    type: "Pgrapher",
    data: {
        edges: [
            {
                tail: { node: wc.tn(magsource) },
                head: { node: wc.tn(fsplit) },
            },
            {
                tail: { node: wc.tn(fsplit), port:1 },
                head: { node: wc.tn(fmerge), port:1 },
            },
            {
                tail: { node: wc.tn(fsplit), port:0 },
                head: { node: wc.tn(chsel) },
            },
            {
                tail: { node: wc.tn(chsel) },
                head: { node: wc.tn(l1sp) },
            },
            {
                tail: { node: wc.tn(l1sp) },
                head: { node: wc.tn(fmerge), port:0 },
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
