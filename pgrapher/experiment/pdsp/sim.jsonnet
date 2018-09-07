local wc = import "wirecell.jsonnet";
local g = import "pgraph.jsonnet";

local sim_maker = import "pgrapher/common/sim/nodes.jsonnet";


// return some nodes, includes base sim nodes.
function(params, tools)
{
    local sim = sim_maker(params, tools),

    local nanodes = std.length(tools.anodes),

    local fanout = g.pnode({
        type: 'DepoFanout',
        name: 'depofanout',
        data: {
            multiplicity: nanodes,
        },
    }, nin=1, nout=nanodes),

    // I rue the day that we must have an (anode) X (field) cross product!
    local ductors = sim.make_detector_ductors("nominal", tools.anodes, tools.pirs[0]),

    local digitizers = [
        sim.digitizer(tools.anodes[n], name="digitizer%d"%n)
        for n in std.range(0,nanodes-1)],

    local reframers = [
        g.pnode({
            type: 'Reframer',
            name: 'reframer%d'%n,
            data: {
                anode: wc.tn(tools.anodes[n]),
                tags: [],           // ?? what do?
                fill: 0.0,
                tbin: params.sim.reframer.tbin,
                toffset: 0,
                nticks: params.sim.reframer.nticks,
            },
        }, nin=1, nout=1) for n in std.range(0, nanodes-1)],

    local signal_pipelines = [g.pipeline([ductors[n], digitizers[n], reframers[n]],
                                         name="simsigpipe%d"%n) for n in std.range(0, nanodes-1)],

    local fanin = g.pnode({
        type: 'FrameFanin',
        name: 'framefanin',
        data: {
            multiplicity: nanodes,
            tags: [],
        },
    }, nin=nanodes, nout=1),


    local make_noise_model = function(anode, csdb=null) {
        type: "EmpiricalNoiseModel",
        name: "empericalnoise%s"% anode.name,
        data: {
            anode: wc.tn(anode),
            chanstat: if std.type(csdb) == "null" then "" else wc.tn(csdb),
            spectra_file: params.files.noise,
            nsamples: params.daq.nticks,
            period: params.daq.tick,
            wire_length_scale: 1.0*wc.cm, // optimization binning
        },
        uses: [anode] + if std.type(csdb) == "null" then [] else [csdb],
    },
    local noise_models = [make_noise_model(anode) for anode in tools.anodes],

    local add_noise = function(model) g.pnode({
        type: "AddNoise",
        name: "addnoise%s"%[model.name],
        data: {
            rng: wc.tn(tools.random),
            model: wc.tn(model),
            replacement_percentage: 0.02, // random optimization
        }}, nin=1, nout=1, uses=[model]),

    local noises = [add_noise(model) for model in noise_models],
    local splusn_pipelines = [g.pipeline([ductors[n], digitizers[n], reframers[n], noises[n]],
                                         name="simsignoipipe%d"%n) for n in std.range(0, nanodes-1)],
    
    local simgraph = function(pipelines, name="simgraph")
    g.intern(innodes=[fanout],
             outnodes=[fanin],
             centernodes=pipelines,
             edges=
             [g.edge(fanout, pipelines[n], n, 0) for n in std.range(0, nanodes-1)] +
             [g.edge(pipelines[n], fanin, 0, n) for n in std.range(0, nanodes-1)],
             name=name),

    signal: simgraph(signal_pipelines, "simsignalgraph"),
    splusn: simgraph(splusn_pipelines, "simsplusngraph"),

} + sim_maker(params, tools)    // we do this twice, but it's not cause of slow down
