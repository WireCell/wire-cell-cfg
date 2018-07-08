// This file provides variety of simulation related Pnodes
// parameterized on tools and params.


local wc = import "wirecell.jsonnet";
local g = import "pgraph.jsonnet";

function(params, tools)
{
    // Create a drifter Pnode.
    drifter: g.pnode({
        local xregions = wc.unique_list(std.flattenArrays([v.faces for v in params.det.volumes])),

        type: "Drifter",
        data: params.lar {
            rng: wc.tn(tools.random),
            xregions: xregions,
        },
    }, nin=1, nout=1, uses=[tools.random]),

    
    // The set of all ductors are formed as the "cross product" of all
    // anodes and all PIR trios.  For one element of that product this
    // function is called.  The name should be unique across all
    // anodes X PIR trios.
    make_ductor: function(name, anode, pir_trio) g.pnode({
        type: 'Ductor',
        name: name,
        data: {
            rng: wc.tn(tools.random),
            anode: wc.tn(anode),
            pirs: std.map(function(pir) wc.tn(pir), pir_trio),
        },
    }, nin=1,nout=1,uses=[tools.random, anode] + pir_trio),
    

    // make all ductors for given anode and for all PIR trios.
    make_anode_ductors: function(anode)
    std.mapWithIndex(function(n, pir_trio)
                     $.make_ductor('ductor%d%s'%[n, anode.name], anode, pir_trio), tools.pirs),


    // Multi APA's are harder
    
    // make all ductors for a given PIR trio.  Basename should include
    // an identifier unique to the PIR trio.
    make_detector_ductors: function(pirname, anodes, pir_trio)
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
    multi_ductor: function(params, anode, ductors, chains, name="") g.pnode({
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


    // Make a digitizer bound to an anode.
    digitizer: function(params, anode, name="") g.pnode({
        type: "Digitizer",
        name: name,
        data : params.adc {
            anode: wc.tn(anode),
            frame_tag: ""
        }
    }, nin=1, nout=1, uses=[anode]),

    // cap off the end of the graph
    frame_sink: g.pnode({ type: "DumpFrames" }, nin=1, nout=0),


    // drifter + ductor + digitizer = signal
    // signal: g.intern([self.drifter],[self.multi_ductor],
    //                  edges=[
    //                      g.edge(self.drifter, self.multi_ductor),
    //                  ]),

    
}
    
