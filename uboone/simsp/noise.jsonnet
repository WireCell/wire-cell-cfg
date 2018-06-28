// Noise simulation pipeline elements
local wc = import "wirecell.jsonnet";
local pnode = import "pnode.jsonnet";
local par = import "params.jsonnet";
local com = import "common.jsonnet";

local static_csdb = {
    type: "StaticChannelStatus",
    name: "urasai",
};

local noise_model = {
    type: "EmpiricalNoiseModel",
    data: {
        anode: wc.tn(com.anode),
        spectra_file: par.files.noise,
        chanstat: wc.tn(static_csdb),
        nsamples: par.daq.ticks_per_readout,
    },
    uses: [com.anode, static_csdb],
};
local noise_source = {
    type: "NoiseSource",
    data: par.daq {
        model: wc.tn(noise_model),
        anode: wc.tn(com.anode),
        rng: wc.tn(com.random),
        start_time: par.daq.start_time,
        stop_time: par.daq.stop_time,
        readout_time: par.daq.readout_time,
    },
    uses: [noise_model, com.anode, com.random],
};
local frame_summer = {
    type: "FrameSummer",
    data: {
        align: true,
        offset: 0.0*wc.s,
    }
};

{
    nominal: {
        type: "Pnode",
        name: "NominalNoise",
        iports: [pnode.port(frame_summer)],
        oports: [pnode.port(frame_summer)],
        edges: [
            pnode.iedge(noise_source, frame_summer),
        ],
        uses: [noise_source, frame_summer],
    },
}
