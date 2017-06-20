local common = import "params/common.jsonnet";
common {
    fields: {
        nominal: "ub-10.json.bz2",
//        uvground: "ub-10-uv-ground.json.bz2",
        uvground: "ub-10.json.bz2",
//        vyground: "ub-10-vy-ground.json.bz2",        
        vyground: "ub-10.json.bz2",
        truth: "ub-10.json.bz2",
    },
    wires: "microboone-celltree-wires-v2.json.bz2",
    noise: "microboone-noise-spectra-v2.json.bz2",
}
