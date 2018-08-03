// MicroBooNE-specific parameters.  This file produces a parameters
// object, inheriting from common.params.  

local wc = import "wirecell.jsonnet";
local base = import "pgrapher/common/params.jsonnet";

base {
    lar: super.lar {
        drift_speed : 1.1*wc.mm/wc.us,
    },

    daq: super.daq {
        // The real detector DAQ produces an odd number of ticks.
        // Note, this is different from nsamples defined below!
        nticks: 9595,
    },        
    adc: super.adc {
        // There are post-FE amplifiers
        gain: 1.2,

        // fixme: need double checking
        baselines: [900*wc.millivolt,900*wc.millivolt,200*wc.millivolt],

        // fixme: need double checking
        fullscale: [0*wc.volt, 2.0*wc.volt],
    },

    elec : super.elec {   
        gain : 14.0*wc.mV/wc.fC,
        shaping : 2.2*wc.us,
        postgain: 1.0,
    },

    det : {
        volumes: [
            // only 1 response plane for uboone, this location is in the
            // wires coordinate system and specifies where Garfield starts
            // its the drift paths.
            //
            // Note:
            // $ wirecell-util wires-info /opt/bviren/wct-dev/share/wirecell/data/microboone-celltree-wires-v2.1.json.bz2
            // anode:0 face:0 X=[-6.00,0.00]mm Y=[-1155.30,1174.70]mm Z=[0.35,10369.60]mm
            //      0: x=-0.00mm dx=6.0000mm
            //      1: x=-3.00mm dx=3.0000mm
            //      2: x=-6.00mm dx=0.0000mm
            // $ wirecell-sigproc response-info /opt/bviren/wct-dev/share/wirecell/data/ub-10-half.json.bz2 
            // origin:10.00 cm, period:0.10 us, tstart:0.00 us, speed:1.11 mm/us, axis:(1.00,0.00,0.00)
            //      plane:0, location:6.0000mm, pitch:3.0000mm
            //      plane:1, location:3.0000mm, pitch:3.0000mm
            //      plane:2, location:0.0000mm, pitch:3.0000mm

            {
                wires: 0,
                name: "uboone",
                faces: [
                    {
                        anode: 1.0*wc.cm, // drop any depos w/in 1 cm of U-wires
                        response: 10*wc.cm-6*wc.mm,
                        cathode: 2.5480*wc.m,// based dump of ubcore/v06_83_00/gdml/microboonev11.gdml by Matt Toups
                    },
                    
                    null
                ],
            },
        ],

        // The active volume bounding box defined as the location of
        // two extreme corners.  See above note for where these magic
        // numbers come from.
        bounds : {
            tail: wc.point(  -6.0, -1155.30,    0.35, wc.mm),
            head: wc.point(2560.4,  1174.7, 10369.65, wc.mm),
        },
    },
    nf: super.nf {

        // The MicroBooNE noise filtering spectra runs with a
        // different number of bins in frequency space than the
        // nominal number of ticks in time.
        nsamples: 9592,
        
        // Add some extra parameters that only make sense for other
        // structures built in uboone/.

        // also add this wart which separates "before" and "after"
        // hardware noise fix epochs.  This is used when WCT is run
        // from WCLS.
        run12boundary: 7000,  

        // These are used in chndb and also static channel status db for simulation.
        misconfigured: {
            channels: std.range(2016,2095) + std.range(2192,2303) + std.range(2352,2399),
            gain: 4.7*wc.mV/wc.fC,
            shaping: 1.1*wc.us,
        },

    },

    sim: super.sim {
        //        trigger_offset: 1.6*wc.ms, // according to Tracy
        trigger_offset: 0,
    },


    files : {
        wires:"microboone-celltree-wires-v2.1.json.bz2",
        fields:["ub-10-half.json.bz2",
                "ub-10-uv-ground-half.json.bz2",
                "ub-10-vy-ground-half.json.bz2"],
        noise: "microboone-noise-spectra-v2.json.bz2",
        chresp: "microboone-channel-responses-v1.json.bz2",
    },

}


