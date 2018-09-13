// This is a main entry point to configure WCT via wire-cell CLI to
// run simulation, (an essentially empty) noise filtering and signal
// processing.
// 
// Simulation is signal and noise with Ar39 and some ideal line MIP
// tracks as initial kinematics.

// Output is a Python numpy .npz file.

local wc = import "wirecell.jsonnet";
local g = import "pgraph.jsonnet";

local cli = import "pgrapher/ui/cli/nodes.jsonnet";

local io = import "pgrapher/common/fileio.jsonnet";
local params = import "pgrapher/experiment/pdsp/params.jsonnet";
local tools_maker = import "pgrapher/common/tools.jsonnet";
local sim_maker = import "pgrapher/experiment/pdsp/sim.jsonnet";
local sp_maker = import "pgrapher/experiment/uboone/sp.jsonnet";

local tools = tools_maker(params);

local sim = sim_maker(params, tools);

local sp = sp_maker(params, tools);


local stubby = {
    tail: wc.point(1000.0, 0.0, 5000.0, wc.mm),
    head: wc.point(1100.0, 0.0, 5100.0, wc.mm),
};

local close = {
    tail: wc.point(10.0, 0.0, 5000.0, wc.mm),
    head: wc.point(11.0, 0.0, 5100.0, wc.mm),
};


local tracklist = [
    {
        time: 1*wc.ms,
        charge: -5000,         
        ray: stubby,
    },
    {
        time: 2*wc.ms,
        charge: -5000,         
        ray: close,
    },
//    {
//        time: 0,
//        charge: -5000,         
//        ray: params.det.bounds,
//    },


];
local output = "wct-pdsp-sim-ideal-sn-nf-sp.npz";
    
local depos = g.join_sources(g.pnode({type:"DepoMerger", name:"BlipTrackJoiner"}, nin=2, nout=1),
                             [sim.ar39(), sim.tracks(tracklist)]);

local deposio = io.numpy.depos(output);
local drifter = sim.drifter;

// signal plus noise sim sub-graph
local splusn = sim.splusn;

local frameio = io.numpy.frames(output);
local sink = sim.frame_sink;


local graph = g.pipeline([depos, deposio, drifter, splusn, sp, frameio, sink]);

local app = {
    type: "Pgrapher",
    data: {
        edges: g.edges(graph),
    },
};

// Finally, the configuration sequence which is emitted.


[cli.cmdline] + g.uses(graph) + [app]

