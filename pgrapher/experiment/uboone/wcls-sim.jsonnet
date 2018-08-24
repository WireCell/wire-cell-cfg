// This is a WCT configuration file for use in a WC/LS job.  It is
// expected to be named inside a FHiCL configuration.  That
// configuration must supply the names of converter components as
// "depo_source" and "frame_sink" external variables.
//

local wc = import "wirecell.jsonnet";
local g = import "pgraph.jsonnet";


local params = import "pgrapher/experiment/uboone/simparams.jsonnet";
local tools_maker = import "pgrapher/common/tools.jsonnet";
local tools = tools_maker(params);
local sim_maker = import "pgrapher/experiment/uboone/sim.jsonnet";
local sim = sim_maker(params, tools);

local wcls_maker = import "pgrapher/ui/wcls/nodes.jsonnet";
local wcls = wcls_maker(params, tools);
    
// This gets used as an art::Event tag and the final output frame
// needs to be tagged likewise.  Note, art does not allow some
// characters, in particular: [_-]
local digit_tag = "wctsimdigits";

// make sure name matches calling FHiCL
local depos = wcls.input.depos(name="");
local frames = wcls.output.digits(name="", tags=[digit_tag]);

local anode = tools.anodes[0];
local drifter = sim.drifter;

local ductors = sim.make_anode_ductors(anode);
local md_pipes = sim.multi_ductor_pipes(ductors);
local ductor = sim.multi_ductor_graph(anode, md_pipes, "mdg");
local digitizer = sim.digitizer(anode, name="uboonedigi", tag=digit_tag);


local sink = sim.frame_sink;

local graph = g.pipeline([depos, drifter, ductor, digitizer, frames, sink]);


local app = {
    type: "Pgrapher",
    data: {
        edges: graph.edges,
    },
};

// Finally, the configuration sequence which is emitted.

graph.uses + [app]
