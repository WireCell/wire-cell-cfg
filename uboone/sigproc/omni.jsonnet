local wc = import "wirecell.jsonnet";
local anodes = import "multi/anodes.jsonnet";
{

    //noisefilter: { },

    sigproc : {
        type: "OmnibusSigProc",
        data: {
            // This class has a HUGE set of parameters.  See
            // OmnibusSigProc.h for the list.  For here, for now, we
            // mostly just defer to the hard coded values.  
            anode: wc.tn(anodes.nominal),
        }
    },

}

