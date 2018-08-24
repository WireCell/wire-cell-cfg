// Here we override params.jsonnet to provide simulation-specific params.

local wc = import "wirecell.jsonnet";
local base = import "pgrapher/experiment/uboone/params.jsonnet";

base {

    daq: super.daq {

        // In MB LArSoft simulation, they expect a different number of
        // ticks than acutal data.
        nticks: 9600,
    },        

    // These parameters only make sense for running WCT simulation on
    // microboone in larsoft.  The "trigger" section is not
    // "standard".  This section is just a set up for use below in
    // "sim".  There is no trigger, per se, in the simulation but
    // rather a contract between the generators of energy depositions
    // (ie, LarG4) and the drift and induction simulation (WCT).  For
    // details of this contract see:
    // https://microboone-docdb.fnal.gov/cgi-bin/private/ShowDocument?docid=12290
    trigger : {

        // A hardware trigger occurs at some "absolute" time but near
        // 0.0 for every "event".  It is measured in "simulation" time
        // which is the same clock used for expressing energy
        // deposition times.  The following values are from table 3 of
        // DocDB 12290.
        hardware: {
            times: {

                none: 0.0,

                // BNB hardware trigger time.  Note interactions
                // associated with BNB neutrinos should all be produced
                // starting in the beam gate which begins at 3125ns and is
                // 1600ns in duration.
                bnb : -31.25*wc.ns,


                // Like above but for NUMI.  It's gate is 9600ns long starting
                // at 4687.5ns.
                numi : -54.8675*wc.ns,

                ext : -414.0625*wc.ns,
                
                mucs: -405.25*wc.ns,
            },

            // Select on of the trigger types
            type: "bnb",

            time: self.times[self.type],
        },

        // Measured relative to the hardware trigger time above is a
        // time offset to the time that the first tick of the readout
        // should sample.  This is apparently fixed for all hardware
        // trigger types (?).
        time_offset: -1.6*wc.ms,

        time: self.hardware.time + self.time_offset,
    },

    sim: super.sim {

        
        // The Ductor start_time is measured at the response plane
        // and the readout time (for MB/LArSoft running) is
        // measured at the collection plane (I Gess????).  The
        // response time offset is then the readout time at which
        // a deposition passes the response plane.  It is
        // estimated assuming the depo travels along the nominal
        // drift velocity (which in fact it doesn't).  It's around
        // 85.5us before the final readout time
        local response_time_offset = $.det.response_plane / $.lar.drift_speed,

        // But, then to get the first tick to be at the trigger
        // time offset we must both enlarge the Ductor's number of
        // ticks and then truncate the resulting frame by this
        // same amount.
        local response_nticks = wc.roundToInt(response_time_offset / $.daq.tick),


        // For running in LArSoft, the simulation must be in fixed time mode. 
        fixed: true,

        // The ductor needs to have its time acceptance enlarged to
        // account for the fact that its clock runs at the response
        // plane and final readout clock assumed to run at the
        // colleciton plane.
        ductor : {
            nticks: $.daq.nticks + response_nticks,

            // The readout duration.
            readout_time: self.nticks * $.daq.tick,

            // The start time for the Ductor must take into account the
            // "trigger" time plus the fact that induction start time is
            // measured at the response plane while the readout time is
            // measured at the collection plane (I guess????).
            start_time: $.trigger.time - response_time_offset,
        },

        // To counter the enlarged duration of the ductor, a Reframer
        // chops off the little early, extra time.  Note, tags depend on how 
        reframer: {
            tbin: response_nticks,
            nticks: $.daq.nticks,
        }

    },
    // This is a non-standard, MB-specific variable.  Each object
    // attribute holds an array of regions corresponding to a
    // particular set of field response functions.  A region is
    // defined as an array of trios: plane, min and max wire index.
    // Each trio defines a swath in the transverse plane bounded by
    // the min/max wires.  A region is finally the intersection or
    // overlap of all its trios in the transverse plane.
    shorted_regions : {
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

}
