// This provides default component configurations for MicroBoone.
// They can be aggregated as-is or extended/customized in the
// top-level configuration file.  They make use of dune global
// parameters.

local params = import "dune/globals.jsonnet";
local wc = import "wirecell.jsonnet";
{
    anode: {
        type : "AnodePlane",
        name : "dune-anode-plane", // could leave empty, just testing out explicit name
        data : {
            // WIRECELL_PATH will be searched for these files
            wires:"dune35t-tpc1-celltree-wires-v5.json.bz2",
            fields:"garfield-1d-3planes-21wires-6impacts-dune-v1.json.bz2",
            ident : 0,
            gain : params.gain,
            shaping : params.shaping,
            postgain: params.postgain,
            readout_time : params.readout,
            tick : params.tick,
        }
    },
    
    // shortcut type+name for below
    anode_tn: self.anode.type + ":" + self.anode.name,

    // Several different depoosition sources based on a dumped set of g4hits
    onehitdep : {
        type: 'JsonDepoSource',
        name: "onehitdep",
        data : {
            filename: "onehit.jsonnet",
            model: "scaled",    // take "q" as dQ directly.
        }
    },
    energydeps: {
        type: 'JsonDepoSource',
        name: 'energydeps',
        data: {
            // the g4tuple.json file "q" is in units of MeV.  Multiply by
            // ioniztion "W-value" and a mean 0.7 recombination from
            // http://lar.bnl.gov/properties/#particle-pass
            filename: "g4tuple.json.bz2",
            scale: wc.MeV*0.7/(23.6*wc.eV),
            model: "scaled",    // take "q" as dE, no dX given
        }
    },
    electrondeps: {
        type: 'JsonDepoSource',
        name: "electrondeps",
        data : {
            filename: "g4tuple-qsn.json.bz2",
            model: "electrons",  // take "n" from depo as already in number of electrons
        }
    },
    birksdeps: {
        type: 'JsonDepoSource',
        name: 'birksdeps',
        data : {
            filename: "g4tuple-qsn.json.bz2",
            model: "birks",     // q is dE, s is dX, apply Birks model.
        }
    },
    boxdeps: {
        type: 'JsonDepoSource',
        name: 'boxdeps',
        data : {
            filename: "g4tuple-qsn.json.bz2",
            model: "box",      // q is dE, s is dX, apply Modified Box model.
        }
    },
    depos: self.electrondeps,
    depos_tn: self.depos.type + ":" + self.depos.name,

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
        data : {
            gain: -1.0,
            baselines: [900*wc.millivolt,900*wc.millivolt,200*wc.millivolt],
            resolution: 12,
            fullscale: [0*wc.volt, 2.0*wc.volt],
            anode: $.anode_tn,
        }
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
