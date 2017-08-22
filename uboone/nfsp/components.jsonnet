// -*- js-mode -*-

// This file holds definitions for the pure WCT components used.  They
// may be derived from in, for example, a WCLS job.


// Some general parameters used here.
local params = import "params.jsonnet";

// This data is kind of long so keep it out of this file.
local chndb_data = import "chndb_data.jsonnet"; 

{

    // This holds various info about one anode plane aka APA
    anode: {
	type: "AnodePlane",
	data: {
	    // can have multiple anodes, just one in uboone
            ident: 0,

	    // Nominal FE amplifier gain. 
	    gain: 14.0*wc.mV/wc.fC,

	    // Gain after the FE amplifier
            postgain: 1.2,

	    // Probably not used for sigproc.
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

    // Provides access to just one field response file.
    fieldresponse : {
        type: "FieldResponse",
        data: {
            filename: params.fields_file,
        }
    },

    // Provides access to the per-channel response functions.
    perchanresp : {
        type : "PerChannelResponse",
        data : {
            filename: params.chresp_file,
        },
    },

    // This should likely be overriden when this configuration is used
    // for a WCLS job.
    chndb : {
	type: "OmniChannelNoiseDB",
	data: cndb_data
    }
    
}
