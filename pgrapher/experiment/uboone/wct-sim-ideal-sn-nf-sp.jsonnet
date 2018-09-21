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
local params = import "pgrapher/experiment/uboone/simparams.jsonnet";
local tools_maker = import "pgrapher/common/tools.jsonnet";

local tools = tools_maker(params);

local sim_maker = import "pgrapher/experiment/uboone/sim.jsonnet";

local nf_maker = import "pgrapher/experiment/uboone/nf.jsonnet";
local chndb_maker = import "pgrapher/experiment/uboone/chndb.jsonnet";

local sp_maker = import "pgrapher/experiment/uboone/sp.jsonnet";

local stubby = {
    tail: wc.point(1000.0, 0.0, 100.0, wc.mm),
    head: wc.point(1100.0, 0.0, 200.0, wc.mm),
};

local tracklist = [
    {
        time: 1*wc.ms,
        charge: -5000,          // negative means per step
        //ray: stubby,
        ray: params.det.bounds,
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

local signal = sim.signal;

local miscon = sim.misconfigure(params);

local noise_model = sim.make_noise_model(anode, sim.miscfg_csdb);
local noise = sim.add_noise(noise_model);

local digitizer = sim.digitizer(anode, tag="orig");
local sim_frameio = io.numpy.frames(output, "simframeio", tags="orig");
local magnifio = g.pnode({
    type: "MagnifySink",
    data: {
        output_filename: magout,
        frames: ["orig","raw"],
        anode: wc.tn(anode),
    },
}, nin=1, nout=1, uses=[anode]);


local noise_epoch = "perfect";
//local noise_epoch = "after";
local chndb = chndb_maker(params, tools).wct(noise_epoch);
local nf = nf_maker(params, tools, chndb);
local nf_frameio = io.numpy.frames(output, "nfframeio", tags="raw");

local sp = sp_maker(params, tools);
local sp_frameio = io.numpy.frames(output, "spframeio", tags="gauss");

local sink = sim.frame_sink;

local graph = g.pipeline([depos, deposio, drifter, signal,
                          miscon,
                          noise, digitizer,
                          sim_frameio, magnifio,
                          nf, nf_frameio,
                          sp, sp_frameio, sink]);

local app = {
    type: "Pgrapher",
    data: {
        edges: g.edges(graph),
    },
};

// Finally, the configuration sequence which is emitted.

[cli.cmdline] + g.uses(graph) + [app]
