local params = import "params/chooser.jsonnet";
local wc = import "wirecell.jsonnet";
{
    sink : {
        type: "HistFrameSink",
        data: {
            filename: std.extVar("framefile"), 
            anode: "AnodePlane",
            units: if params.digitize then 1.0 else wc.uV,
        }
    },
}
