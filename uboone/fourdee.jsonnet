local wc = import "wirecell.jsonnet";
local det = import "uboone-params.jsonnet";
local gen = import "gen.jsonnet";
[
    {                           // main CLI
	type: "wire-cell",
	data: {
	    plugins: ["WireCellGen"],
//	    apps: ["FourDee"]
	}
    },

    gen.FourDee,

    // anode needed by drifter and ductor, so put first
    det.anode,

    det.drifter,
        
    gen.TrackDepos,

    gen.SilentNoise,

    det.ductor,

    gen.Digitizer,

]

