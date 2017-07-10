local wc = import "wirecell.jsonnet";
local common = import "params/common.jsonnet";
common {
    fields: {
        nominal: "ub-10-half.json.bz2",
        uvground: "ub-10-uv-ground-half.json.bz2",
        vyground: "ub-10-vy-ground-half.json.bz2",        
        truth: "ub-10-half.json.bz2",
    },
    wires: "microboone-celltree-wires-v2.json.bz2",
    noise: "microboone-noise-spectra-v2.json.bz2",
    drift_speed: 1.114*wc.mm/wc.us,

}
