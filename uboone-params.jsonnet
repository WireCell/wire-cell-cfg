local wc = import "wirecell.jsonnet";
local gen = import "gen.jsonnet";
{
    drift_speed: 1.114*wc.mm/wc.us,
    gain: 14.0,
    shaping: 2*wc.us,
    readout: 5.0*wc.ms,
    tick: 0.5*wc.us,  


    anode: gen.AnodePlane {
        name : "uboone-anode-plane", // could leave empty, just testing out explicit name
        data : super.data {
            wires:"microboone-celltree-wires-v2.json.bz2",
            fields:"garfield-1d-3planes-21wires-6impacts-v4.json.bz2",
        }
    },

    anode_tn: self.anode.type + ":" + self.anode.name,

    drifter: gen.Drifter {
        data : super.data {
            anode: $.anode_tn,
        }
    },
    
    ductor: gen.Ductor {
        data : super.data {
            anode: $.anode_tn
        }
    },        

}
