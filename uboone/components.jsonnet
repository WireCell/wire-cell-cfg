// This provides default component configurations for MicroBoone.
// They can be aggregated as-is or extended/customized in the
// top-level configuration file.  They make use of uboone global
// parameters.

local params = import "uboone/globals.jsonnet";
local wc = import "wirecell.jsonnet";
{
    anode: {
        type : "AnodePlane",
        name : "uboone-anode-plane", // could leave empty, just testing out explicit name
        data : {
            // WIRECELL_PATH will be searched for these files
            wires:"microboone-celltree-wires-v2.json.bz2",
            fields:"garfield-1d-3planes-21wires-6impacts-v4.json.bz2",
            ident : 0,
            gain : params.gain,
            shaping : params.shaping,
            readout_time : params.readout,
            tick : params.tick,
        }
    },
    
    // shortcut type+name for below
    anode_tn: self.anode.type + ":" + self.anode.name,

    drifter: {
        type : "Drifter",
        data : {
            anode: $.anode_tn,
            DL : params.DL,
            DT : params.DT,
            lifetime : params.electron_lifetime,
            fluctuate : params.fluctuate,
        }
    },

    ductor: {
        type : 'Ductor',
        data : {
            nsigma : params.nsigma_diffusion_truncation,
            fluctuate : params.fluctuate,
            start_time: params.start_time,
            readout_time: params.readout,
            drift_speed : params.drift_speed,
            first_frame_number: params.start_frame_number,
            anode: $.anode_tn,
        }
    },        


    noise : {
        type: "SilentNoise",
        data: {},
    },


    digitizer : {
        type: "Digitizer",
        // fixme: ditch CamelCase
        MaxSample: 4095,
        Baseline: 0*wc.volt,
        VperADC: 2.0*wc.volt/4096,
    },

    fourdee : {
        type : 'FourDee',
        data : {
            DepoSource: "TrackDepos",
            Drifter: "Drifter",
            Ductor: "Ductor",
            Dissonance: "SilentNoise",
            Digitizer: "Digitizer",
            FrameSink: "DumpFrames",            
        }
    },

}
