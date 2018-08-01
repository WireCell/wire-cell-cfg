// This configures a WCT job for a pipeline that includes full MB
// signal and noise effects in the simulation. and the NF/SP
// components to correct them.  The kinematics here are a mixture of
// Ar39 "blips" and ideal, straight-line MIP tracks.
//
// In particular, there are three "PlaneImpactResponse" objects.
// Which one used depends on the given channel or wire being "shorted"
// or not.
//
// Output is to a .npz file of the same name as this file.  Plots can
// be made to do some basic checks with "wirecell-gen plot-sim".

local wc = import "wirecell.jsonnet";
local g = import "pgraph.jsonnet";

local cli = import "pgrapher/ui/cli/nodes.jsonnet";

local io = import "pgrapher/common/fileio.jsonnet";
local params = import "pgrapher/experiment/uboone/params.jsonnet";
local tools_maker = import "pgrapher/common/tools.jsonnet";

local tools = tools_maker(params);

local sim_maker = import "pgrapher/experiment/uboone/sim.jsonnet";

local nf_maker = import "pgrapher/experiment/uboone/nf.jsonnet";
local chndb_maker = import "pgrapher/experiment/uboone/chndb.jsonnet";

local sp_maker = import "pgrapher/experiment/uboone/sp.jsonnet";

local stubby = {
    tail: wc.point(1000.0, 0.0, 5000.0, wc.mm),
    head: wc.point(1010.0, 0.0, 5010.0, wc.mm),
};

local tracklist = [
    {
        time: 1*wc.ms,
        charge: -5000,          // negative means per step
        ray: stubby,
        //ray: params.det.bounds,
    },
];
local output = "wct-sim-ideal-sn-nf-sp.npz";
    
local anode = tools.anodes[0];

local sim = sim_maker(params, tools);

local depos = g.join_sources(g.pnode({type:"DepoMerger", name:"BlipTrackJoiner"}, nin=2, nout=1),
                             [sim.ar39(), sim.tracks(tracklist)]);

local deposio = io.numpy.depos(output);

local drifter = sim.drifter;

local ductors = sim.make_anode_ductors(anode);
local md_chain = sim.multi_ductor_chain(ductors);
local ductor = sim.multi_ductor(anode, ductors, [md_chain]);

// fixme: insert misconfigureer


local noise_model = sim.make_noise_model(anode, sim.miscfg_csdb);
local noise = sim.noise(anode, noise_model).return;

local digitizer = sim.digitizer(anode, tag="orig");

local chndb = chndb_maker(params, tools).wct("after");
local nf = nf_maker(params, tools, chndb);
local sp = sp_maker(params, tools);

local frameio = io.numpy.frames(output);
local sink = sim.frame_sink;

local graph = g.pipeline([depos, deposio, drifter, ductor, noise, digitizer, nf, sp, frameio, sink]);

local app = {
    type: "Pgrapher",
    data: {
        edges: graph.edges,
    },
};

// Finally, the configuration sequence which is emitted.

[cli.cmdline] + graph.uses + [app]
