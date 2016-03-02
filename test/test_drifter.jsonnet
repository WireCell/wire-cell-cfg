local Drifter = {type: "Drifter", name: "", data:{drift_velocity:4}};
local wc = import "wirecell.jsonnet";
[
    Drifter { name: "drifterU", data: {location: 15*wc.mm} },
    Drifter { name: "drifterV", data: {location: 10*wc.mm} },
    Drifter { name: "drifterW", data: {location:  5*wc.mm} },
    
]

