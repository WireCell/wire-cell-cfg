// This file is part of wire-cell-cfg.
//
// This file provides a base data structure to define parameters that
// span all currently supported WCT functionality.  Not every
// parameter will be used and not all value here is valid.  The
// parameters are named and factored into sub-objects in order to be
// sympathetic to how the C++ components are structured and name their
// configuration paramters.  As such it's often possible to build a
// component configuration object by inheriting from one or more
// sub-objects in the parameter structure.  For most jobs, this
// structure should be derived and overriden before being passed to
// functions that produce other configuration structures.

local wc = import "wirecell.jsonnet";

{
    // Parameters relevant to the bulk liquid argon volume.
    lar : {
        // Longitudinal diffusion constant
        DL :  7.2 * wc.cm2/wc.s,
        // Transverse diffusion constant
        DT : 12.0 * wc.cm2/wc.s,
        // Electron lifetime
        lifetime : 8*wc.ms,
        // Electron drift speed, assumes a certain applied E-field
        drift_speed : 1.6*wc.mm/wc.us, // at 500 V/cm
        // LAr density
        density: 1.389*wc.g/wc.centimeter3,
        // Decay rate per mass for natural Ar39.
        ar39activity: 1*wc.Bq/wc.kg,
    },

    det: {
        // The detector volumes are defined as a set of planes
        // organized into a "front" and "back" face of an AnodePlane
        // and also used by the Drifter.  Each volume defined will map
        // to an AnodePlane which is given the same name.  The volumes
        // given here are several unrelated volumes and given just as
        // examples to show the structure.
        volumes : [
            {
                wires: 0,
                name: "onesided",
                faces: [ {anode: 0, response: 10*wc.cm, cathode: 2*wc.m},
                         null ],
            },
            {
                wires: 0,
                name: "twosided",
                faces: [ {anode: 0, response: +10*wc.cm, cathode: 2*wc.m},
                         {anode: 0, response: -10*wc.cm, cathode: -2*wc.m} ],
            },
            {
                wires: 0,
                name: "anothertwosided",
                faces: [ {anode: 4*wc.m, response: +10*wc.cm + 4*wc.m, cathode:  2*wc.m + 4*wc.m },
                         {anode: 4*wc.m, response: -10*wc.cm + 4*wc.m, cathode: -2*wc.m + 4*wc.m} ],
            },
        ],
    },
    
    // Parameters related to the DAQ
    daq : {
        // One digitization sampling period
        tick: 0.5*wc.us,

        // Number of ticks in one readout period.  Note, some
        // components take an "nsamples".  This can be not need not be
        // the same as "nticks".  For example, NF will typicall
        // differ.
        nticks: 10000,

        // Readout period in units of time
        readout_time: self.tick*self.nticks,

        // In cases where a node limits its running based on number of
        // readouts (aka frames), this is how many are to be
        // processed.
        nreadouts: 1,

        // Where a node sets a readout (frame) time, this is the
        // starting time.
        start_time: 0.0*wc.s,

        // In case where a node limits running based on time, this is
        // when it will stop.
        stop_time: self.start_time + self.nreadouts*self.readout_time,

        // In a case where a node counts readouts (frames), this is
        // the first number.
        first_frame_number: 100,
    },

    // Parameters having to do with digitization.
    adc : {
        // A relative gain applied just prior to digitization.  This
        // is not FE gain, see elec for that.
        gain: 1.0,

        // Voltage baselines added to any input voltage signal listed
        // in a per plan (U,V,W) array.
        baselines: [900*wc.millivolt,900*wc.millivolt,200*wc.millivolt],

        // The resolution (bits) of the ADC
        resolution: 12,

        // The voltage range as [min,max] of the ADC, eg min voltage
        // counts 0 ADC, max counts 2^resolution-1.
        fullscale: [0*wc.volt, 2.0*wc.volt],
    },

    // Parameters having to do with the front end electronics
    elec : {
        // The FE amplifier gain in units of Voltage/Charge.
        gain : 14.0*wc.mV/wc.fC,

        // The shaping (aka peaking) time of the amplifier shaper.
        shaping : 2.0*wc.us,

        // An realtive gain applied after shaping.
        postgain: 1.0,
    },

    // Parameters related to simulation, not given elsewhere.
    sim : {

        // The number of impact bins per wire region gives the
        // granularity of the simulation convolution in the transverse
        // dimension.  Typically should match what the granularity at
        // which the field response functions are defined.
        nimpacts: 10,

        // if statistical fluctations should be applied
        fluctuate: true,
        // if continuous or discontinuous mode is is used.  See, eg
        // https://wirecell.github.io/news/posts/simulation-updates/
        continuous: false,

        // A fixed time offset added to all drifted depo times which
        // can be useful if the origin depo source fails to provide
        // correct times.  So called "trigger" as it can be used to
        // align the resulting activitity in the final simulated frame
        // to some point in time corresponding to an external trigger
        // which is somehow coincident with the production of the
        // original depositions.
        trigger_offset: 0.0,
    },

    // Parameters related to noise filtering.  
    nf : {                    

        // Number of frequency bins over which NF filters are applied.
        // Note, this likely differs from nticks so should be
        // overriden in the experiment specific parameters.  Where
        // they differ then truncation or extension of waveforms may
        // occur.
        nssamples: $.daq.nticks, 

        
    },    

    // Some configuration is too bulky to include directly and so are
    // expelicitly loaded by WCT from other files (typically as
    // compressed JSON).  The user is free to provide this files
    // themselves and there are wirecell-* Python programs that can
    // help generate them or convert from foreign formats.  However,
    // most common cases are provided for by files in the
    // wire-cell-data package.  Here, the attributes are given and a
    // more specfic parameter file should override and provide their
    // names.
    files : {
        
        // The "wire schema" file giving wire locations.
        // wirecell-util has generation and conersion commands to make
        // these.
        wires: null,

        // An array of field response files.  This array may span
        // alternative "universes" (such as "shorted wire regsion")
        // such as implemented in the ~MultiDuctor~ simulation
        // component.  The first field file is considered "nominal".
        // The info in these files are typically produced by Garfield
        // initially and then converted to WCT format using the
        // "wirecell-sigproc convert-garfield" command.
        fields: [],

        // A noise file provides a spectral lookup table.  This info
        // is usually provided by some analysis and converted.  One
        // such converter is "wirecell-sigproc convert-noise-spectra".
        noise: null,

        // This file gives per-channel calibrated responses.  See
        // "wirecell-sigproc channel-response" for one converter.
        chresp: null, 
    },
}


