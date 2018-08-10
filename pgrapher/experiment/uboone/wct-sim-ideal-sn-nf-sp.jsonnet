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
    head: wc.point(1100.0, 0.0, 5100.0, wc.mm),
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
local magout = "wct-sim-ideal-sn-nf-sp.root";
    
local anode = tools.anodes[0];

local sim = sim_maker(params, tools);

//local depos = g.join_sources(g.pnode({type:"DepoMerger", name:"BlipTrackJoiner"}, nin=2, nout=1),
//                             [sim.ar39(), sim.tracks(tracklist)]);
local depos = sim.tracks(tracklist);


local deposio = io.numpy.depos(output);

local drifter = sim.drifter;

local ductors = sim.make_anode_ductors(anode);
local md_chain = sim.multi_ductor_chain(ductors);
local ductor = sim.multi_ductor(anode, ductors, [md_chain]);
//local ductor = sim.make_ductor("nominal", anode, tools.pirs[0]);

local miscon = sim.misconfigure(params);

local noise_model = sim.make_noise_model(anode, sim.miscfg_csdb);
local noise = sim.noise(anode, noise_model).return;

local digitizer = sim.digitizer(anode, tag="orig");
local sim_frameio = io.numpy.frames(output, "simframeio", tags="orig");
local magnifio = g.pnode({
    type: "MagnifySink",
    data: {
        output_filename: magout,
        frames: ["orig","raw"],
        anode: wc.tn(anode),
    },
}, nin=1, nout=1);


//local noise_epoch = "perfect";
local noise_epoch = "after";
local chndb = chndb_maker(params, tools).wct(noise_epoch);
local nf = nf_maker(params, tools, chndb);
local nf_frameio = io.numpy.frames(output, "nfframeio", tags="raw");

local sp = sp_maker(params, tools);
local sp_frameio = io.numpy.frames(output, "spframeio", tags="gauss");

local sink = sim.frame_sink;

local graph = g.pipeline([depos, deposio, drifter, ductor, miscon, noise, digitizer,
                          sim_frameio, magnifio,
                          nf, nf_frameio, sp, sp_frameio, sink]);

local app = {
    type: "Pgrapher",
    data: {
        edges: graph.edges,
    },
};

// Finally, the configuration sequence which is emitted.

[cli.cmdline] + graph.uses + [app]
