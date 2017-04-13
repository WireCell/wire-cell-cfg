local wc = import "wirecell.jsonnet";
{
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
