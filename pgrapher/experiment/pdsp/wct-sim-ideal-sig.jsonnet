// This is a main entry point for configuring a wire-cell CLI job to
// simulate protoDUNE-SP.  It is simplest signal-only simulation with
// one set of nominal field response function.  It excludes noise.
// The kinematics are a mixture of Ar39 "blips" and some ideal,
// straight-line MIP tracks.
//
// Output is a Python numpy .npz file.

local wc = import "wirecell.jsonnet";
local g = import "pgraph.jsonnet";

local cli = import "pgrapher/ui/cli/nodes.jsonnet";

local io = import "pgrapher/common/fileio.jsonnet";
local params = import "pgrapher/experiment/pdsp/params.jsonnet";
local tools_maker = import "pgrapher/common/tools.jsonnet";

local tools = tools_maker(params);

local sim_maker = import "pgrapher/experiment/pdsp/sim.jsonnet";
local sim = sim_maker(params, tools);

local tracklist = [
    {
        time: 1*wc.ms,
        charge: -5000,          // negative means per step
        ray: params.det.bounds,
    },
];
local output = "wct-sim-ideal-sig.npz";

    
local depos = g.join_sources(g.pnode({type:"DepoMerger", name:"BlipTrackJoiner"}, nin=2, nout=1),
                             [sim.ar39(), sim.tracks(tracklist)]);

local deposio = io.numpy.depos(output);
local drifter = sim.drifter;

local signal = sim.signal;

local frameio = io.numpy.frames(output);
local sink = sim.frame_sink;

local graph = g.pipeline([depos, deposio, drifter, signal, frameio, sink]);

local app = {
    type: "Pgrapher",
    data: {
        edges: g.edges(graph),
    },
};

// Finally, the configuration sequence which is emitted.

[cli.cmdline] + g.uses(graph) + [app]

