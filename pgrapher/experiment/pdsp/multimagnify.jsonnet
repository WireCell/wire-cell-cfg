// This provides multiple MagnifySink for e.g. protoDUNE 

local wc = import "wirecell.jsonnet";
local g = import "pgraph.jsonnet";

// multiple MagnifySink
// tagn (n = 0, 1, ... 5) for anode[n]
// FrameFanin tags configured in sim.jsonnet 
function(tag, tools, outputfile) {
    
    local nanodes = std.length(tools.anodes),

    local magnify = function (tag, index, tools) g.pnode({
        type: "MagnifySink",
        name: "mag%s%d"%[tag,index],
        data: {
            output_filename: outputfile,
            root_file_mode: if index == 0 then "RECREATE" else "UPDATE",
            frames: ["%s%d"%[tag,index]], // note that if tag set, each apa should have a tag set for FrameFanin
            anode: wc.tn(tools.anodes[index]),
        },
    }, nin=1, nout=1),
    
    local multimagnify = [magnify(tag, n, tools) for n in std.range(0, nanodes-1)],

    //return: g.pipeline([multimagnify[0], multimagnify[1], multimagnify[2], multimagnify[3], multimagnify[4], multimagnify[5]]),
    return: g.pipeline([multimagnify[n] for n in std.range(0, nanodes-1)]),
    
}.return
