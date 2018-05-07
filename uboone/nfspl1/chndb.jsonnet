/* There are five possible channel noise DB objects.  There is a 2x2
matrix of (before,after) X (wcls,wct).  The "wcls" uses an
implementation which requires a connection to larsoft service DBs and
the wct one is stand-alone and statically configured.  The 5th type is
"multi" which uses the two wcls DB objects. */

local wc = import "wirecell.jsonnet";

local par = import "params.jsonnet";

local rms_cuts = import "chndb-rms-cuts.jsonnet";
local base_data = import "chndb-base.jsonnet";

local before_data = base_data {
    channel_info: super.channel_info + rms_cuts.before,
};
local after_data = base_data {
    channel_info: super.channel_info + rms_cuts.after,
};




local wct_before = {
    type: "OmniChannelNoiseDB",
    name: "chndbprehwfix",
    data: before_data,
};
local wct_after = {
    type: "OmniChannelNoiseDB",
    name: "chndbposthwfix",
    data: after_data,
};

local wcls_before = {
    type: "wclsChannelNoiseDB",
    name: "chndbprehwfix",
    data: before_data {
        // Replace any misconfigured channels using larsoft service
        misconfig_channel: {
            policy: "replace",
            from: {gain:  4.7*wc.mV/wc.fC, shaping: 1.1*wc.us},
            to:   {gain: 14.0*wc.mV/wc.fC, shaping: 2.2*wc.us},
        }
    }        
};
local wcls_after = {
    type: "wclsChannelNoiseDB",
    name: "chndbposthwfix",
    data: after_data {
        // Replace any misconfigured channels using larsoft service
        misconfig_channel: {
            policy: "replace",
            from: {gain:  4.7*wc.mV/wc.fC, shaping: 1.1*wc.us},
            to:   {gain: 14.0*wc.mV/wc.fC, shaping: 2.2*wc.us},
        }
    }        
};

// maybe used below
local before = if par.noisedb.flavor == "wcls" then wcls_before
          else if par.noisedb.flavor == "wct"  then wct_before;
local after = if par.noisedb.flavor == "wcls" then wcls_after
         else if par.noisedb.flavor == "wct"  then wct_after;

local multi = {
    type: "wclsMultiChannelNoiseDB",
    name: "chndb",
    data: {
        rules: [
            {
                rule: "runbefore",
                chndb: wc.tn(wcls_before),
                args: par.noisedb.run12boundary
            },
            {
                rule: "runstarting",
                chndb: wc.tn(wcls_after),
                args: par.noisedb.run12boundary,
            },
            // note, there might be a need to add a catchall if the
            // above rules are changed to not cover all run numbers.
        ],
    }
};


// finally return what is wanted.
if par.noisedb.flavor == "multi" then
{
    configs : [wcls_before, wcls_after, multi],
    typename : wc.tn(multi)
}    
else if par.noisedb.epoch == "before" then
{
    configs : [before],
    typename : wc.tn(before),
}
else if par.noisedb.epoch == "after" then
{
    configs : [after],
    typename : wc.tn(after),
}
