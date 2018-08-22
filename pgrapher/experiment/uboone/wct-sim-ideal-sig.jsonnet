// This configures a job for the simplest signal-only simulation where
// all channels use their nominal field responses and there are no
// misconfigured electronics.  It also excludes noise which as a side
// effect means the output frame does not span a rectangular, dense
// area in the space of channel vs tick.  The kinematics here are a
// mixture of Ar39 "blips" and some ideal, straight-line MIP tracks.
//
// Output is to a .npz file of the same name as this file.  Plots can
// be made to do some basic checks with "wirecell-gen plot-sim".

local wc = import "wirecell.jsonnet";
local g = import "pgraph.jsonnet";

local cli = import "pgrapher/ui/cli/nodes.jsonnet";

local io = import "pgrapher/common/fileio.jsonnet";
local params = import "pgrapher/experiment/uboone/simparams.jsonnet";
local tools_maker = import "pgrapher/common/tools.jsonnet";

local tools = tools_maker(params);

local sim_maker = import "pgrapher/experiment/uboone/sim.jsonnet";
local sim = sim_maker(params, tools);

local tracklist = [
    {
        time: 1*wc.ms,
        charge: -5000,          // negative means per step
        ray: params.det.bounds,
    },
];
local output = "wct-sim-ideal-sig.npz";

    
local anode = tools.anodes[0];
local depos = g.join_sources(g.pnode({type:"DepoMerger", name:"BlipTrackJoiner"}, nin=2, nout=1),
                             [sim.ar39(), sim.tracks(tracklist)]);

local deposio = io.numpy.depos(output);
local drifter = sim.drifter;
local ductor = sim.make_ductor("nominal", anode, tools.pirs[0]);
local digitizer = sim.digitizer(anode);
local frameio = io.numpy.frames(output);
local sink = sim.frame_sink;

local graph = g.pipeline([depos, deposio, drifter, ductor, digitizer, frameio, sink]);

local app = {
    type: "Pgrapher",
    data: {
        edges: graph.edges,
    },
};

// Finally, the configuration sequence which is emitted.

[cli.cmdline] + graph.uses + [app]
