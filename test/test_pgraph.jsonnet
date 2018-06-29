// test wc.graph

local g = import "pgraph.jsonnet";

{
    n1: g.pnode({type:"Node", name:"n1"}, nout=1),
    n2: g.pnode({type:"Node", name:"n2"}, nin=1, nout=1),
    n3: g.pnode({type:"Node", name:"n3"}, nin=1),
    e12: g.edge($.n1, $.n2),
    e23: g.edge($.n2, $.n3),

    pn: g.intern([$.n1],[$.n3],[$.n2],[
        g.edge($.n1, $.n2),
        g.edge($.n2, $.n3)], "pn"),

    n12: g.intern([$.n1],[$.n2],edges=[
        g.edge($.n1, $.n2)
    ], name="n12"),
    n123: g.intern([$.n12],[$.n3],edges=[
        g.edge($.n12, $.n3),
    ], name="n123"),


    n13: g.intern([$.n1],[$.n3], edges=[
        g.edge($.n1, $.n3),
    ], name="n13"),

    n123inserted: g.insert_one($.n13, 0, $.n2, $.n2, name="n123inserted"),
}
