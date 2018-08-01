// see README.org

local wc = import "wirecell.jsonnet";

local base = import "chndb-base.jsonnet";
local rms_cuts = import "chndb-rms-cuts.jsonnet";

function(params, tools)
{
    wct: function(epoch="before") {
        type: "OmniChannelNoiseDB",
        name: "ocndb%s"%epoch,
        data : base(params, tools.anode, tools.field, rms_cuts[epoch]),
    },

    wcls: function(epoch="before") {
        type: "wclsChannelNoiseDB",
        name: "wclscndb%s"%epoch,
        data : base(params, tools.anode, tools.field, rms_cuts[epoch]) {
            misconfig_channel: {
                policy: "replace",
                from: {gain:  params.nf.misconfigured.gain,
                       shaping: params.nf.misconfigured.shaping},
                to:   {gain: params.elec.gain,
                       shaping: params.elec.shaping},
            },
        },
    },

    wcls_multi: {
        local bef = $.wcls("before"),
        local aft = $.wcls("after"),
        type: "wclsMultiChannelNoiseDB",
        // note, if a name is given here, it must match what is used in the .fcl for inputers.
        data: {
            rules: [
                {
                    rule: "runbefore",
                    chndb: wc.tn(bef),
                    args: params.nf.run12boundary
                },
                {
                    rule: "runstarting",
                    chndb: wc.tn(aft),
                    args: params.nf.run12boundary,
                },
                // note, there might be a need to add a catchall if the
                // above rules are changed to not cover all run numbers.
            ],
        },
        uses: [bef, aft],           // pnode extension
    },

}

