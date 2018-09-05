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

    local pipelines = [g.pipeline([ductors[n], digitizers[n], reframers[n]],
                                  name="simsigpipe%d"%n) for n in std.range(0, nanodes-1)],

    local fanin = g.pnode({
        type: 'FrameFanin',
        name: 'framefanin',
        data: {
            multiplicity: nanodes,
            tags: [],
        },
    }, nin=nanodes, nout=1),

    
    signal: g.intern(innodes=[fanout],
                      outnodes=[fanin],
                      centernodes=pipelines,
                      edges=
                      [g.edge(fanout, pipelines[n], n, 0) for n in std.range(0, nanodes-1)] +
                      [g.edge(pipelines[n], fanin, 0, n) for n in std.range(0, nanodes-1)],
                      name='simsignalgraph'),

} + sim_maker(params, tools)    // we do this twice, but it's not cause of slow down
