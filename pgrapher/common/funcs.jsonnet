// This provides some util functions.

local g = import "pgraph.jsonnet";

{
    // Build a fanout-[pipelines]-fanin graph.  pipelines is a list of
    // pnode objects, one for each spine of the fan.
    fanpipe :: function(fout, pipelines, fin, name="fanpipe", outtags=[]) {

        local fanmult = std.length(pipelines),

        local fanout = g.pnode({
            type: fout,
            name: name,
            data: {
                multiplicity: fanmult,
            },
        }, nin=1, nout=fanmult),


        local fanin = g.pnode({
            type: fin,
            name: name,
            data: {
                multiplicity: fanmult,
                tags: outtags,
            },
        }, nin=fanmult, nout=1),

        ret: g.intern(innodes=[fanout],
                      outnodes=[fanin],
                      centernodes=pipelines,
                      edges=
                      [g.edge(fanout, pipelines[n], n, 0) for n in std.range(0, fanmult-1)] +
                      [g.edge(pipelines[n], fanin, 0, n) for n in std.range(0, fanmult-1)],
                      name=name),
    }.ret,


}
