local uboone = import "uboone/components.jsonnet";
local params = import "uboone/globals.jsonnet";
local wc = import "wirecell.jsonnet";
[
    {                           // main CLI
	type: "wire-cell",
	data: {
	    plugins: ["WireCellGen", "WireCellSio"],
	    apps: ["FourDee"]
	}
    },

    // "input" is to generate deposition along some track
    {
        type: 'TrackDepos',
        data : {
            step_size : 1*wc.mm,
            tracks : [{
                time: 0.0*wc.ms,
                // if negative, then charge per depo
                // o.w. it's total charge made by track.
                charge: -10000.0*wc.eplus,
                ray: wc.ray(wc.point(101,0,1,wc.mm), wc.point(102,0,1,wc.mm))
            }]
        }
    },

    {
        type: 'JsonDepoSource',
        data : {
            //filename: "onehit.jsonnet",

            filename: "g4tuple.json",
            // the g4tuple.json file is in qunits of MeV.  Multiply by
            // ioniztion "W-value" and a mean 0.7 recombination from
            // http://lar.bnl.gov/properties/#particle-pass
            qunit: wc.MeV*0.7/(23.6*wc.eV)
        }
    },

    // anode needed by drifter, ductor and digitzer, so put first
    uboone.anode,

    uboone.drifter,
        
    uboone.noise,

    uboone.ductor,

    if params.digitize then uboone.digitizer,

    // output to simple histogram frame sink from sio.
    {
        type: "HistFrameSink",
        data: {
            filename: "uboone.root",
            anode: uboone.anode_tn,
            units: if params.digitize then 1.0 else wc.uV,
        }
    },

    // The "app" component
    uboone.fourdee {
        data : super.data {

            //DepoSource: "TrackDepos",
            DepoSource: "JsonDepoSource",

            Dissonance: "",

            /// Turning off digitizer saves frame as voltage.  Must
            // configure HistFrameSink's units to match!
            Digitizer: if params.digitize then "Digitizer" else "",
            
            FrameSink: "HistFrameSink",            
        }
    },


]

