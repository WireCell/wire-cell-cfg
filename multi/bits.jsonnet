local params = import "params/chooser.jsonnet";
local wc = import "wirecell.jsonnet";
local anodes = import "multi/anodes.jsonnet";
{
    drifter: {
        type : "Drifter",
        data : {
            anode: wc.tn(anodes.nominal),
            DL : params.DL,
            DT : params.DT,
            lifetime : params.electron_lifetime,
            fluctuate : params.fluctuate,
        }
    },

    digitizer : {
        type: "Digitizer",
        data : {
            gain: params.digitizer.pregain,
            baselines: params.digitizer.baselines,
            resolution: params.digitizer.resolution,
            fullscale: params.digitizer.fullscale,
            anode: wc.tn(anodes.nominal),
        }
    },


}
