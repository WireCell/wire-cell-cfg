// Simulation pipeline elements
local wc = import "wirecell.jsonnet";
local pnode = import "pnode.jsonnet";
local par = import "params.jsonnet";
local com = import "common.jsonnet";

local dri = import "drifters.jsonnet";
local duc = import "ductors.jsonnet";
local dig = import "digitizers.jsonnet";
local noi = import "noise.jsonnet";

// Here we define a 2x2 set of possibilities
// - single :: one ductor
// - multi :: multi ductor to include uv/vy grounded wires
// - quiet :: no noise
// - noise :: with noise


// chotto exhausting

local quiet(ductor) = {
    type: "Pnode",
    name: "QuietSim",
    iports: dri.simple.iports,
    oports: dig.simple.oports,
    edges: [
        pnode.edge(dri.simple, ductor),
        pnode.edge(ductor, dig.simple),
    ],
    uses: [dri.simple, ductor, dig.simple],

};
local noisy(ductor) = {
    type: "Pnode",
    name: "NoisySim",
    iports: dri.simple.iports,
    oports: dig.simple.oports,
    edges: [
        pnode.edge(dri.simple, ductor),
        pnode.edge(ductor, noi.nominal),
        pnode.edge(noi.nominal, dig.simple),
    ],
    uses: [dri.simple, ductor, dig.simple, noi.nominal],
};


{
    single_quiet: quiet(duc.single),
    single_noisy: noisy(duc.single),
    multi_quiet: quiet(duc.multi),
    multi_noisy: noisy(duc.multi),
}
