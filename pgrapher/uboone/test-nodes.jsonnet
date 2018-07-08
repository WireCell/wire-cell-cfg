
local params = import "params.jsonnet";
local tools_maker = import "../common/tools.jsonnet";
local sim_maker = import "../sim/nodes.jsonnet";
local ub_sim = import "sim.jsonnet";

local tools = tools_maker(params);

local sim = sim_maker(params, tools);

local anode = tools.anodes[0];
local ductors = sim.make_anode_ductors(anode);

local md_chain = ub_sim(params, tools).multi_ductor_chain(ductors);
local md = sim.multi_ductor(params, anode, ductors, md_chain);

{
    uses: md.uses,
    edges: md.edges
}
