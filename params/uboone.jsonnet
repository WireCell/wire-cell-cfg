// This overrides select common parameters with ones that are specific
// to MicroBooNE.

local wc = import "wirecell.jsonnet";
local common = import "params/common.jsonnet";
common {

    detector: super.detector {
	// Match what MicroBooNE actually reads out
	nticks: 9595,

	// wire geometry and numbers
	wires: "microboone-celltree-wires-v2.json.bz2",


	field: "ub-10-half.json.bz2",

	// Microboone simulation config may use multiple fields.
	fields: {
            nominal: "ub-10-half.json.bz2",
            uvground: "ub-10-uv-ground-half.json.bz2",
            vyground: "ub-10-vy-ground-half.json.bz2",        
            truth: "ub-10-half.json.bz2",
	},

    },


    simulation : super.simulation {

	noise: "microboone-noise-spectra-v2.json.bz2",

	// Drift volatage is lower than nominal.
	drift_speed: 1.114*wc.mm/wc.us,

	fluctuate: false,
    },
    
    sigproc: super.sigproc {

	frequency_bins: 9595,


    },
}
