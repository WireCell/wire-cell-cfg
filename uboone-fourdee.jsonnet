local wc = import "wirecell.jsonnet";
local det = import "uboone-params.jsonnet";
local gen = import "gen.jsonnet";
[
    {                           // main CLI
	type: "wire-cell",
	data: {
	    plugins: ["WireCellGen"],
	    apps: ["FourDee"]
	}
    },

    gen.FourDee,

    // order matters.  AnodePlane is instantiated by Drifter and Ductor
    gen.AnodePlane {
        name : "uboone anode plane",
        data : super.data {
            wires:"wires.json.bz2",
            fields:"fields.json.bz2",
            ident: 42,
        }
    },

    gen.Drifter {
        data : super.data {
            anode: "uboone anode plane"
        }
    },
        
    gen.TrackDepos,

    gen.SilentNoise,

    gen.Ductor {
        data : super.data {
            anode: "uboone anode plane",
        }
    },        

    gen.Digitizer,

]

