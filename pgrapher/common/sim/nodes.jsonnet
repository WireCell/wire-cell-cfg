// This file provides variety of simulation related Pnodes
// parameterized on tools and params.


local wc = import "wirecell.jsonnet";
local g = import "pgraph.jsonnet";
local depos = import "pgrapher/common/sim/depos.jsonnet";

function(params, tools)
{
    // Create a drifter Pnode.
    drifter: g.pnode({
        local xregions = wc.unique_list(std.flattenArrays([v.faces for v in params.det.volumes])),

        type: "Drifter",
        data: params.lar {
            rng: wc.tn(tools.random),
            xregions: xregions,
            time_offset: params.sim.trigger_offset,
        },
    }, nin=1, nout=1, uses=[tools.random]),

    
    // The set of all ductors are formed as the "cross product" of all
    // anodes and all PIR trios.  For one element of that product this
    // function is called.  The name should be unique across all
    // anodes X PIR trios.
    make_ductor:: function(name, anode, pir_trio) g.pnode({
        type: 'Ductor',
        name: name,
        data: {
            rng: wc.tn(tools.random),
            anode: wc.tn(anode),
            pirs: std.map(function(pir) wc.tn(pir), pir_trio),
        },
    }, nin=1,nout=1,uses=[tools.random, anode] + pir_trio),
    

    // make all ductors for given anode and for all PIR trios.
    make_anode_ductors:: function(anode)
    std.mapWithIndex(function(n, pir_trio)
                     $.make_ductor('ductor%d%s'%[n, anode.name], anode, pir_trio), tools.pirs),


    // Multi APA's are harder
    
    // make all ductors for a given PIR trio.  Basename should include
    // an identifier unique to the PIR trio.
    make_detector_ductors:: function(pirname, anodes, pir_trio)
    std.mapWithIndex(function (n, anode)
                     $.make_ductor('%s%s' % [pirname, anode.name],
                                   anode, pir_trio), tools.anodes),
        

    // Map above function across all trio of PIRs.  Result is a 2D
    // array of ductor Pnodes indexed like: [ipir][ianode]
    ductors: std.mapWithIndex(function (n, pir_trio)
                              $.make_detector_ductors("ductor%d"%[n], tools.anodes, pir_trio), tools.pirs),


    // Make aone multiductor for a single anode from the primitive
    // ductors which are also featured in the given chain.  The chain
    // is left as an exercise to the caller.
    multi_ductor:: function(anode, ductors, chains, name="") g.pnode({
        type: "MultiDuctor",
        data : {
            anode: wc.tn(anode),
            continuous: params.sim.continuous,
            chains : chains,
            start_time : params.daq.start_time,
            readout_time: params.daq.readout_time, 
            first_frame_number: params.daq.first_frame_number,
        }
    }, nin=1, nout=1, uses = [anode] + ductors),


    // This operates on all channels so needs a channel selector bypass.
    // Maybe fixme: there are tag-aware nodes inside.
    misconfigure:: function(params) {

        local split = g.pnode({
            type: "FrameSplitter",
            name: "misconsplit"
        }, nin=1, nout=2),

        local chsel = g.pnode({
            type: "ChannelSelector",
            name: "misconsel",
            data: {
                channels: params.nf.misconfigured.channels,
            }
        }, nin=1, nout=1),

        local miscon = g.pnode({
            type: "Misconfigure",
            name: "sigmisconfig",
            data: {
                // Must match what was actually used to start with
                from: {
                    gain: params.elec.gain,
                    shaping: params.elec.shaping,
                },
                to: {
                    gain: params.nf.misconfigured.gain,
                    shaping: params.nf.misconfigured.shaping,
                },
                nsamples: 50,   // number of samples of the response
                tick: params.daq.tick, // sample period of the response
                truncate:true // result is extended by nsamples, tuncate clips that off
            }
        }, nin=1, nout=1),

        local merge = g.pnode({
            type: "FrameMerger",
            name: "misconmerge",
            data: {
                rule: "replace",
                // note: the first two need to match the order of what data is
                // fed to ports 0 and 1 of this component in the pgraph below!
                mergemap: [
                ],
            }
        }, nin=2, nout=1),

        return : g.intern([split], [merge], [chsel, miscon],
                          edges=[
                              g.edge(split, chsel),
                              g.edge(chsel, miscon),
                              g.edge(miscon, merge, 0, 0),
                              g.edge(split, merge, 1, 1),
                          ],
                          name="misconfigure"),
    }.return,

    // Make a digitizer bound to an anode.
    digitizer:: function(anode, name="", tag="") g.pnode({
        type: "Digitizer",
        name: name,
        data : params.adc {
            anode: wc.tn(anode),
            frame_tag: tag
        }
    }, nin=1, nout=1, uses=[anode]),

    // cap off the end of the graph
    frame_sink: g.pnode({ type: "DumpFrames" }, nin=1, nout=0),


    // drifter + ductor + digitizer = signal
    // signal: g.intern([self.drifter],[self.multi_ductor],
    //                  edges=[
    //                      g.edge(self.drifter, self.multi_ductor),
    //                  ]),

    
} + depos(params,tools)
    
