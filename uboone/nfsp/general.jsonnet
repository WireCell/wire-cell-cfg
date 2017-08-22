// -*- js -*-

// This file holds some components used by others.

local wc = import "wirecell.jsonnet";
local params = import "params.jsonnet";

{
    // This holds various info about one anode plane aka APA.  Note:
    // in general multiple anode planes may be in use and
    // diferentiated by their "name".  The nameless "AnodePlane" the
    // hard-coded default and uboone only has the one so we need not
    // set the "anode" configuration parameter everywhere.
    anode: {
	type: "AnodePlane",
	data: {
	    // can have multiple anodes, just one in uboone
            ident: 0,
	    // Nominal FE amplifier gain. 
	    gain: 14.0*wc.mV/wc.fC,
	    // Gain after the FE amplifier
            postgain: 1.2,
	    // Nominal frame length
            readout_time: params.frequency_bins * params.sample_period,
	    // FE amplifier shaping time
	    shaping: 2.0*wc.us,
	    // sample period
	    tick: params.sample_period,
	    // data file holding field response functions.
            fields: params.fields_file,
	    // data file holding wire definitions
            wires: params.wires_file,
	},
    },

    sequence : [ $.anode, ],

}
