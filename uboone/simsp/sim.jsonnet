// Simulation pipeline elements
local wc = import "wirecell.jsonnet";
local g = import "pgraph.jsonnet";

local par = import "params.jsonnet";
local com = import "common.jsonnet";

local dri = import "drifters.jsonnet";
local duc = import "ductors.jsonnet";
local dig = import "digitizers.jsonnet";
local noi = import "noise.jsonnet";

// Here we define a 2x2 set of possibilities
// ductor type:
// - single :: one ductor
// - multi :: multi ductor to include uv/vy grounded wires
// noise type:
// - quiet :: no noise
// - noisy :: with noise

local quiet(ductor) = g.intern([dri.simple],[dig.simple],[ductor],
                               edges=[
                                   g.edge(dri.simple, ductor),
                                   g.edge(ductor, dig.simple)
                               ],
                               name="QuietSim");
local noisy(ductor) = g.intern([dri.simple],[dig.simple],[ductor,noi.nominal],
                               edges=[
                                   g.edge(dri.simple, ductor),
                                   g.edge(ductor, noi.nominal),
                                   g.edge(noi.nominal, dig.simple)
                               ],
                               name="NoisySim");

{
    single_quiet: quiet(duc.single),
    single_noisy: noisy(duc.single),
    multi_quiet: quiet(duc.multi),
    multi_noisy: noisy(duc.multi),
}
