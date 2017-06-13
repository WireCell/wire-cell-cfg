local params = import "uboone/globals.jsonnet";
local uboone = import "uboone/components.jsonnet";
local wc = import "wirecell.jsonnet";
[
    uboone.anode {
        name: "nominal",
        data : super.data {
            fields:"garfield-1d-3planes-21wires-6impacts-v6.json.bz2",
        }
    },
    uboone.anode {
        name: "uvground",
        data : super.data {
            fields:"garfield-1d-3planes-21wires-6impacts-uboone-uv-ground.json.bz2",
        }
    },
    uboone.anode {
        name: "vyground",
        data : super.data {
            fields:"garfield-1d-3planes-21wires-6impacts-uboone-vy-ground.json.bz2",
        }
    },


    uboone.ductor {
        name:"nominal",
        data : super.data {
            anode: "AnodePlane:nominal",
        }
    },
    uboone.ductor {
        name:"uvground",
        data : super.data {
            anode: "AnodePlane:uvground",
        }
    },
    uboone.ductor {
        name:"vyground",
        data : super.data {
            anode: "AnodePlane:vyground",
        }
    },

    {
        type: "MultiDuctor",
        data: {
            anode : "AnodePlane:nominal",
            chain : [
                {                   // select based on transverse location
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

                {                   // select based on transverse location
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

                {                   // if nothing above matches, then use this one
                    ductor: "Ductor:nominal",
                    rule: "bool",
                    args: true,
                }
            ]
        }
    },
]
