// This WCT configuration file defines configuration nodes which may
// be used in a WC/LS job.  They configure components defined not in
// WCT proper but in the larwirecell package of larsoft.

local wc = import "wirecell.jsonnet";
local g = import "pgraph.jsonnet";


function(params, tools)
{
    // converters from data which is input to WCT
    input : {
        depos : function(name="deposource", model="", scale=1.0) g.pnode({
            type: 'wclsSimDepoSource',
            name: name,
            data: {
                model: model,
                scale: scale,
            },
        }, nin=0, nout=1),
    },

    // converters for data which is output from WCT
    output : {
        // Save a frame to raw::RawDigits
        digits : function(name="digitsaver", tags=["wct"], cmm=[]) g.pnode({
            type: "wclsFrameSaver",
            name: name, 
            data: {
                anode: wc.tn(tools.anode),
                digitize: true,         // true means save as RawDigit, else recob::Wire
                frame_tags: tags,
                nticks: params.daq.nticks,
                chanmaskmaps: cmm,
            },
        }, nin=1, nout=1, uses=[tools.anode]),

        // Save a frame to recob::Wires
        signals : function(tags=["wct"], name="signalsaver", cmm=[]) g.pnode({
            type: "wclsFrameSaver",
            name: name, 
            data: {
                anode: wc.tn(tools.anode),
                digitize: false,         // true means save as RawDigit, else recob::Wire
                frame_tags: tags,
                nticks: params.daq.nticks,
                chanmaskmaps: cmm,
            },
        },nin=1, nout=1, uses=[tools.anode])
    },

}

