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
