local wc = import "wirecell.jsonnet";
local par = import "params.jsonnet";
local com = import "common.jsonnet";
local pnode = import "pnode.jsonnet";


local simple = {
    type: "Drifter",
    data: par.lar + par.sim {
        anode: wc.tn(com.anode),
        rng: wc.tn(com.random),
    },
    uses: [com.anode, com.random],
};

//local vagbond = {};

{
    simple: pnode.inode(simple),
}
