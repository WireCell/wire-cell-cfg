local params = import "params/chooser.jsonnet";
local wc = import "wirecell.jsonnet";
{
    nominal: {
        type : "AnodePlane",
        data : {
            // WIRECELL_PATH will be searched for these files
            wires: params.wires,
            fields: params.fields.nominal,
            ident : 0,
            gain : params.gain,
            shaping : params.shaping,
            postgain: params.postgain,
            readout_time : params.readout_time,
            tick : params.tick,
        }
    },


    uvground : $.nominal {
        name: "uvground",
        data : super.data {
            fields:params.fields.uvground,
        }
    },


    vyground : $.nominal {
        name: "vyground",
        data : super.data {
            fields:params.fields.vyground,
        }
    },
    

    truth : $.nominal {
        name: "truth",
        data : super.data {
            // fixme: this should really be some special "field"
            // response file which leads to some kind of "true signal
            // waveforms" For now, just use the nominal one as a stand
            // in to let the configuration and machinery be developed.
            fields:params.fields.truth,
        }
    },
    

    objects: [$.nominal, $.uvground, $.vyground, $.truth],
}
