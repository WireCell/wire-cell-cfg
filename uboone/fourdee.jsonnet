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
            step_size : 0.1*wc.mm,
            tracks : [{
                time: 1.0*wc.ms,
                charge: -1000.0,
                ray: wc.ray(wc.point(1,0,0,wc.m), wc.point(1.1,0.1,0.1,wc.m))
            }]
        }
    },


    // anode needed by drifter and ductor, so put first
    uboone.anode,

    uboone.drifter,
        
    uboone.noise,

    uboone.ductor,

    uboone.digitizer,

    // output to simple histogram frame sink from sio.
    {
        type: "HistFrameSink",
        data: {
            filename: "uboone.root",
            anode: uboone.anode_tn,
        }
    },

    // The "app" component
    uboone.fourdee {
        data : super.data {
            FrameSink: "HistFrameSink",            
        }
    },


]

