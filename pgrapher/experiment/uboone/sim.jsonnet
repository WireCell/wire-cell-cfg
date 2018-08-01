// Microboone-specific functions for simulation related things.  The
// structure of function is parameterized on params and tools.

local wc = import "wirecell.jsonnet";
local g = import "pgraph.jsonnet";
local simnodes = import "pgrapher/common/sim/nodes.jsonnet";

function(params, tools)
{
    // Extract these as they will be useful in multiple contexts
    shorted_channels : {
        uv: [ 
            [ { plane:0, min:296, max:296 } ],
            [ { plane:0, min:298, max:315 } ],
            [ { plane:0, min:317, max:317 } ],
            [ { plane:0, min:319, max:327 } ],
            [ { plane:0, min:336, max:337 } ],
            [ { plane:0, min:343, max:345 } ],
            [ { plane:0, min:348, max:351 } ],
            [ { plane:0, min:376, max:400 } ],
            [ { plane:0, min:410, max:445 } ],
            [ { plane:0, min:447, max:484 } ],
            [ { plane:0, min:501, max:503 } ],
            [ { plane:0, min:505, max:520 } ],
            [ { plane:0, min:522, max:524 } ],
            [ { plane:0, min:536, max:559 } ],
            [ { plane:0, min:561, max:592 } ],
            [ { plane:0, min:595, max:598 } ],
            [ { plane:0, min:600, max:632 } ],
            [ { plane:0, min:634, max:652 } ],
            [ { plane:0, min:654, max:654 } ],
            [ { plane:0, min:656, max:671 } ],
        ],
        vy: [
            [ { plane:2, min:2336, max:2399 } ],
            [ { plane:2, min:2401, max:2414 } ],
            [ { plane:2, min:2416, max:2463 } ],
        ],
    },


    // The guts of this chain can be generated with:
    // $ wirecell-util convert-uboone-wire-regions \
    //                 microboone-celltree-wires-v2.1.json.bz2 \
    //                 MicroBooNE_ShortedWireList_v2.csv \
    //                 foo.json
    //
    // Copy-paste the plane:0 and plane:2 in uv_ground and vy_ground, respectively
    // ductors is a trio of fundamental ductors corresponding to one anode plane
    multi_ductor_chain:: function(ductors) [
        {
            ductor: ductors[1].name,
            rule: "wirebounds",
            args: $.shorted_channels.uv,
        },

        {
            ductor: ductors[2].name,
            rule: "wirebounds",
            args: $.shorted_channels.vy,
        },
        {               // catch all if the above do not match.
            ductor: ductors[0].name,
            rule: "bool",
            args: true,
        },
    ],


    //
    // Noise:
    //
    
    // A channel status with no misconfigured channels.
    empty_csdb: {
        type: "StaticChannelStatus",
        name: "uniform",
        data: {
            nominal_gain: params.elec.gain,
            nominal_shaping: params.elec.shaping,
            deviant_status: [
                //// This is what elements of this array look like:
                //// One entry per "deviant" channel.
                // {
                //     chid: 0,               // channel number
                //     gain: 4.7*wc.mV/wc.fC, // deviant gain
                //     shaping: 1*wc.us,      // deviant shaping time
                // }
            ],
        }
    },


    // A channel status configured with nominal misconfigured channels.
    miscfg_csdb: {
        type: "StaticChannelStatus",
        name: "misconfigured",
        data: {
            nominal_gain: params.elec.gain,
            nominal_shaping: params.elec.shaping,
            deviant_status: [ { chid: ch,
                                gain: params.nf.misconfigured.gain,
                                shaping: params.nf.misconfigured.shaping,
                              } for ch in params.nf.misconfigured.channels ],
        },
    },

        
    // Make a noise model bound to an anode and a channel status
    make_noise_model: function(anode, csdb) {
        type: "EmpiricalNoiseModel",
        name: "empericalnoise%s"% csdb.name,
        data: {
            anode: wc.tn(anode),
            chanstat: wc.tn(csdb),
            spectra_file: params.files.noise,
            nsamples: params.daq.nticks,
            period: params.daq.tick,
            wire_length_scale: 1.0*wc.cm, // optimization binning
        },
        uses: [anode, csdb],
    },


    // make a noise source.  A source is for a particular anode and noise model.
    noise_source:: function(anode, model) g.pnode({
        type: "NoiseSource",
        name: "noise%s%s"%[anode.name, model.name],
        data: params.daq {
            rng: wc.tn(tools.random),
            model: wc.tn(model),
	    anode: wc.tn(anode),

            start_time: params.daq.start_time,
            stop_time: params.daq.stop_time,
            readout_time: params.daq.readout_time,
            sample_period: params.daq.tick,
            first_frame_number: params.daq.first_frame_number,
        }}, nin=0, nout=1, uses=[anode, model]),


    local noise_summer = g.pnode({
        type: "FrameSummer",
        name: "noisesummer",
        data: {
            align: true,
            offset: 0.0*wc.s,
        }
    }, nin=2, nout=1),


    // A "frame filter" that adds in noise.  Can use $.noise_summer but once.
    plus_noise:: function(noise, summer) 
    g.intern([summer],[summer],[noise],
             edges = [
                 g.edge(noise, summer, 0, 1),
             ]),



    // Return a frame filter that adds noise.  Must use "return" attribute.
    noise:: function(anode, model) {
        local nsrc = $.noise_source(anode, model),
        local nsum = g.pnode({
            type: "FrameSummer",
            name: "sum" + nsrc.name,
            data: {
                align: true,
                offset: 0.0*wc.s,
            }
        }, nin=2, nout=1),

        return : g.intern([nsum],[nsum],[nsrc],
                          edges = [
                              g.edge(nsrc, nsum, 0, 1),
                          ]),
    }
    
    


} + simnodes(params, tools)
