local params = import "params/chooser.jsonnet";
local wc = import "wirecell.jsonnet";
{
    anode: {
        type : "AnodePlane",
        data : {
            // WIRECELL_PATH will be searched for these files
            wires: params.wires,
            fields: params.fields.nominal,
            ident : 0,
            gain : params.gain,
            shaping : params.shaping,
            postgain: params.postgain,
            readout_time : params.readout,
            tick : params.tick,
        }
    },
    
    drifter: {
        type : "Drifter",
        data : {
            anode: "AnodePlane",
            DL : params.DL,
            DT : params.DT,
            lifetime : params.electron_lifetime,
            fluctuate : params.fluctuate,
        }
    },

    noisemodel :  {
        type: "EmpiricalNoiseModel",
        data: {
            anode: "AnodePlane",
            spectra_file: params.noise,
        }
    },
    noisesource : {
        type: "NoiseSource",
        data: {
            model: "EmpiricalNoiseModel",
            anode: "AnodePlane",
        },
    },

    digitizer : {
        type: "Digitizer",
        data : {
            gain: params.digitizer.pregain,
            baselines: params.digitizer.baselines,
            resolution: params.digitizer.resolution,
            fullscale: params.digitizer.fullscale,
            anode: "AnodePlane",
        }
    },
    ductor: {
        type : 'Ductor',
        data : {
            nsigma : params.nsigma_diffusion_truncation,
            fluctuate : params.fluctuate,
            start_time: params.start_time,
            readout_time: params.readout,
            drift_speed : params.drift_speed,
            first_frame_number: params.start_frame_number,
            anode: "AnodePlane",
        }
    },        


}
