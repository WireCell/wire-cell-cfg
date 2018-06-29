local wc = import "wirecell.jsonnet";
local g = import "pgraph.jsonnet";

local par = import "params.jsonnet";
local com = import "common.jsonnet";


{
    simple: g.pnode({
        type: "Drifter",
        data: par.lar + par.sim {
            anode: wc.tn(com.anode),
            rng: wc.tn(com.random),
        },
        uses: [com.anode, com.random],
    },nin=1,nout=1),

    // vagabond: ....
}
