local params = import "params/chooser.jsonnet";
local bits = import "multi/bits.jsonnet";
local depos = import "multi/depos.jsonnet";
local frames = import "multi/frames.jsonnet";
local wc = import "wirecell.jsonnet";
[
    bits.anode {
        name: "nominal",
    },
    bits.anode {
        name: "uvground",
        data : super.data {
            fields:params.fields.uvground,
        }
    },
    bits.anode {
        name: "vyground",
        data : super.data {
            fields:params.fields.vyground,
        }
    },
    bits.anode {
        name: "truth",
        data : super.data {
            // fixme: this should really be some special "field"
            // response file which leads to some kind of "true signal
            // waveforms" For now, just use the nominal one as a stand
            // in to let the configuration and machinery be developed.
            fields:params.fields.truth,
        }
    },


    depos.depos,
    bits.drifter {
        data : super.data {
            anode: "AnodePlane:nominal",
        },
    },

    bits.ductor {
        name:"nominal",
        data : super.data {
            anode: "AnodePlane:nominal",
        }
    },
    bits.ductor {
        name:"uvground",
        data : super.data {
            anode: "AnodePlane:uvground",
        }
    },
    bits.ductor {
        name:"vyground",
        data : super.data {
            anode: "AnodePlane:vyground",
        }
    },
    bits.ductor {
        name:"truth",
        data : super.data {
            anode: "AnodePlane:truth",
        }
    },



    {
        type: "MultiDuctor",
        data: {
            anode : "AnodePlane:nominal",
            chains : [
                [
                    {           // select based on transverse location
                        ductor: "Ductor:uvground", // type/name of ductor
                        rule: "wirebounds",    // select based on wire bounds.
                        args: [ // If depo is in one of the regions then this ductor is applied.
                            // Each region is specified as a range in u, v and w wire index ranges.
                            // Remember wire index starts counting with 0 at edge/corners at negative-most Z.
                            // Endpoints are considered part of the index range.
                            // Total region is the logical AND of all specified wire index ranges.
                            [
                                { plane: 0, min:100, max:200 },
                                { plane: 1, min:300, max:400 },
                            ],
                            [ // All regions in the list or logically ORed together.
                                { plane: 0, min:500, max:600 }, // just in U
                            ],
                        ],
                    },

                    {           // select based on transverse location
                        ductor: "Ductor:vyground", // type/name of ductor
                        rule: "wirebounds",    // select based on wire bounds.
                        args: [             // If depo is in one of the regions then this ductor is applied.
                            // Each region is specified as a range in u, v and w wire index ranges.
                            // Remember wire index starts counting with 0 at edge/corners at negative-most Z.
                            // Endpoints are considered part of the index range.
                            [ // Total region is the logical AND of all specified wire index ranges.
                                { plane: 1, min:800, max:800 },
                                { plane: 2, min:600, max:700 },
                            ],
                        ],
                    },

                    {   // if nothing above matches, then use this one
                        ductor: "Ductor:nominal",
                        rule: "bool",
                        args: true,
                    }
                ],
                [
                    {   // Always run this one
                        ductor: "Ductor:truth",
                        rule: "bool",
                        args: true,
                    },
                    // fixme: this needs to be extended to allow rules
                    // which will split up depositions by some
                    // identifier so that, for example, one may save
                    // separately signal from protons, electrons,
                    // muons.  Some more info in trello.
                ],
            ]
        }
    },

    bits.noisemodel {
        data : super.data {
            anode: "AnodePlane:nominal",
        },
    },
    bits.noisesource {
        data : super.data {
            anode: "AnodePlane:nominal",
        },
    },

    bits.digitizer {
        data : super.data {
            anode: "AnodePlane:nominal",
        },
    },

    frames.sink {
        data : super.data {
            anode: "AnodePlane:nominal",
        },
    },        

    {
        type: "FourDee",
        data : {
            DepoSource: depos.depos_tn,
            Drifter: "Drifter",
            Ductor: "MultiDuctor",
            Dissonance: "NoiseSource",

            /// Turning off digitizer saves frame as voltage.  Must
            // configure HistFrameSink's units to match!
            Digitizer: if params.digitize then "Digitizer" else "",
            
            FrameSink: "HistFrameSink",            
        }
    },
    

]
