local wc = import "wirecell.jsonnet";
local anodes = import "multi/anodes.jsonnet";

// it's kind of long, so put it in its own file
local default_noisedb_cfg = import "omnicndb.jsonnet"; 

// the data objects this file makes available for use elsewhere:
{

    // fixme: add individual channel noise filter configs

    noisedb: {
        type : "OmniChannelNoiseDB",
        data: default_noisedb_cfg,
    },

    noisefilter: {
        type: "OmnibusNoiseFilter",
        data : {
            maskmap: { chirp: "bad", noisy: "bad" },
            channel_filters: "mbOneChannelNoise",
            channel_status_filters: "mbOneChannelStatus",
            grouped_filters: "mbCoherentNoiseSub",
            channel_noisedb: "OmniChannelNoiseDB",
        }
    },

    sigproc : {
        type: "OmnibusSigProc",
        data: {
            // This class has a HUGE set of parameters.  See
            // OmnibusSigProc.h for the list.  For here, for now, we
            // mostly just defer to the hard coded values.  
            anode: wc.tn(anodes.nominal),
        }
    },

}

