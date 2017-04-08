// make a default params file
local wc = import "wirecell.jsonnet";
local det = import "uboone-params.jsonnet";

{
    AnodePlane :{
        name: "",
        type: "AnodePlane",
        data: {
            gain:det.gain,
            shaping:det.shaping,
            readout:det.readout,
            tick:det.tick,
            wires:"",
            fields:"",
            ident:0
        }
    },
    FourDee : {
        name:"",
        type: "FourDee",
        data: {
            DepoSource: "TrackDepos",
            Drifter: "Drifter",
            Ductor: "Ductor",
            Dissonance: "SilentNoise",
            Digitizer: "Digitizer",
            FrameSink: "DumpFrames",            
        }
    },
    Drifter : {
        name : "",
        type: "Drifter",
        data: {
            anode : "AnodePlane",
            DL: 7.2 * wc.cm2/wc.s,
            DT: 12.0 * wc.cm2/wc.s,
            lifetime: 8.0*wc.ms,
            fluctuate: true,
        }
    },
        
    TrackDepos : {
        name : "",
        type: "TrackDepos",
        data: {
            step_size: 0.1*wc.mm,
            clight: 1.0,
            tracks: [
                {
                    time: 10.0*wc.ns,
                    charge: -1000,
                    ray : wc.ray(wc.point(100,0,0,wc.cm), wc.point(200,100,100,wc.cm))
                },
            ]
        }
    },

    SilentNoise : {
        name : "",
        type : "SilentNoise",
        data : { }              // nada
    },

    Ductor : {
        name : "",
        type : "Ductor",
        data : {
            nsigma : 3.0,
            fluctuate : true,
            start_time: 0*wc.s,
            readout_time: 5*wc.ms, // fixme, should get from IAnodePlane's FieldResponse
            drift_speed: 1.6*wc.mm/wc.us, // fixme, ibid
            first_frame_number: 0,
            anode: "AnodePlane",
        }
    },

    Digitizer : {
        name : "",
        type : "Digitizer",
        data : {
            // fixme: regularize capitalization of parameter names
            MaxSample : 4095,
            Baseline : 0.0*wc.volt,
            VperADC : 2.0*wc.volt/4096, 
        }
    },

}

