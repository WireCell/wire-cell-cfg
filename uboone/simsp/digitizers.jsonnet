local wc = import "wirecell.jsonnet";
local par = import "params.jsonnet";
local com = import "common.jsonnet";
local pnode = import "pnode.jsonnet";


local simple = {
    type: "Digitizer",
    data: par.adc {
        anode: wc.tn(com.anode),
    },
    uses: [com.anode],
};

{
    simple: pnode.inode(simple),
}
