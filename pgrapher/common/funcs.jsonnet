// This provides some util functions.

local g = import "pgraph.jsonnet";

{
    // Build a fanout-[pipelines]-fanin graph.  pipelines is a list of
    // pnode objects, one for each spine of the fan.
    fanpipe :: function(fout, pipelines, fin, name="fanpipe", outtags=[], tag_rules=[]) {

        local fanmult = std.length(pipelines),

        local fanout = g.pnode({
            type: fout,
            name: name,
            data: {
                multiplicity: fanmult,
                tag_rules: tag_rules,
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

    // Build a fanout-[pipelines] graph where each pipe is self
    // terminated.  pipelines is a list of pnode objects, one for each
    // spine of the fan.
    fansink :: function(fout, pipelines, name="fansink", tag_rules=[]) {

        local fanmult = std.length(pipelines),

        local fanout = g.pnode({
            type: fout,
            name: name,
            data: {
                multiplicity: fanmult,
                tag_rules: tag_rules,
            },
        }, nin=1, nout=fanmult),


        ret: g.intern(innodes=[fanout],
                      outnodes=[],
                      centernodes=pipelines,
                      edges=
                      [g.edge(fanout, pipelines[n], n, 0) for n in std.range(0, fanmult-1)],
                      name=name),
    }.ret,


}
