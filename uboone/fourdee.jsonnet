local uboone = import "uboone/components.jsonnet";
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


    // anode needed by drifter and ductor, so put first
    uboone.anode,

    uboone.drifter,
        
    uboone.noise,

    uboone.ductor,

    //uboone.digitizer,

    // output to simple histogram frame sink from sio.
    {
        type: "HistFrameSink",
        data: {
            filename: "uboone.root",
            anode: uboone.anode_tn,
            units: wc.mV,       // mV if no digitizer, 1.0 otherwise
        }
    },

    // The "app" component
    uboone.fourdee {
        data : super.data {

            // write out just voltage
            Dissonance: "",
            Digitizer: "",
            
            FrameSink: "HistFrameSink",            
        }
    },


]

