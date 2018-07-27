// This file provides various helper functions that assist in
// configuring jobs which take a graph of nodes, eg Pgrapher.  The
// nomenclature here is that an "inode" is a configuration object
// corresponding to an WCT INode component and a "pnode" is a wrapper
// around an inode or a number of pnodes which assist in constructing
// the graph in a piecewise manner.  It is best to only make pnodes
// via function calls, otherwise some functionality may not work.

local wc = import "wirecell.jsonnet";

{
    // Construct a port structure as used to form 1/2 of an edge.
    port(inode, num=0) :: { node: wc.tn(inode), port: num },


    // Make an edge between two pnodes
    edge(tail, head, tp=0, hp=0):: {
        tail: tail.oports[tp],
        head: head.iports[hp],
    },


    // Break an existing edge, terminating the tail end with a new
    // head and starting the head end with a new tail.  Graphically:
    // edge --> [edge[tail]->nh, nt->edge[head]]
    break_edge(edge, nh, nt):: [
        {
            tail: edge.tail,
            head: nh
        },
        {
            tail: nt,
            head: edge.head,
        },
    ],


    // Break and existing edge at the index in the edges array, return
    // new array of edges with the inserted new head and tail ports.
    break_insert_edge(index, edges, nh, nt)::
    std.join($.break_edge(edges[index], nh, nt), [edges[0:index], edges[index+1:std.length(edges)]]),


    // Strip any pnodes    
    strip_pnodes(arr):: std.filter(function(x) x.type != "Pnode", arr),

    // Helper recursively find all objects in "uses" array, removing
    // the array asit goes.  Return catenation of list "l" and all "uses" found.
    popuses(l, obj):: if std.objectHas(obj, "uses")
    then l + std.foldl($.popuses, obj.uses, []) + [std.prune(std.mapWithKey(function (k,v) if k == "uses" then null else v, obj))]
    else l + [obj],

    // Return all "uses" objects.
    resolve_uses(seq):: $.strip_pnodes(wc.unique_list(std.foldl($.popuses, seq, []))),
    
    // Make a pnode from an inode, giving its input and output port
    // multiplicity.  Use this instead of creating a pnode by hand.
    // Any other WCT component objects which are referenced by this
    // one should be passed in "uses" (or, as a special inode.uses).
    pnode(inode, nin=0, nout=0, uses=[]):: {
        type: "Pnode",
        name: wc.tn(inode),
        edges: [],
        uses: $.resolve_uses(uses + [inode]),
        iports: [$.port(inode, n) for n in std.range(0,nin)][:nin],
        oports: [$.port(inode, n) for n in std.range(0,nout)][:nout],
    },


    // Produce a new pnode from collections of input and output pnodes
    // and any internal nodes and edges.  The resulting "uses" and
    // "edges" are then resolved, aggregated, flattened.  Unless
    // explicitly given, all iports of innodes become iports of the
    // new pnode, etc for output.
    intern(innodes=[], outnodes=[], centernodes=[], edges=[], iports=[], oports=[], name=""):: {
        local nodes = wc.unique_list(innodes+outnodes+centernodes),
        type: "Pnode",
        name: name,
        uses: $.resolve_uses(innodes+outnodes+centernodes),
        edges: wc.unique_list(std.prune(edges + std.flattenArrays([n.edges for n in nodes]))),
        iports: if std.length(iports) == 0 then std.flattenArrays([n.iports for n in innodes]) else iports,
        oports: if std.length(oports) == 0 then std.flattenArrays([n.oports for n in outnodes]) else oports,
    },


    // Intern an ordered list of elements to form a linear pipeline by
    // subsequently connecting one element's output port 0 to the next
    // element's input port 0.  The first/last elements iport/oport
    // will be used for the pipeline's iport/oport if existing.
    pipeline(elements, name=""):: {
        local nele = std.length(elements),
        local pedges = [$.edge(elements[i], elements[i+1]) for i in std.range(0,nele-2)],
        type: "Pnode",
        name: name,
        uses: $.resolve_uses(elements),
        edges: wc.unique_list(std.prune(pedges + std.flattenArrays([n.edges for n in elements]))),
        iports: if std.length(elements[0].iports) == 0 then [] else [elements[0].iports[0]],
        oports: if std.length(elements[nele-1].oports) == 0 then [] else [elements[nele-1].oports[0]],
    },


    // Return a new pnode built by breaking an existing edge at given
    // index and patching the break with the given head and tail nodes
    // and their ports.  If a name is given it is set else the name of
    // the original pnode is kept.
    insert_one(pnode, index, newhead, newtail, iport=0, oport=0, name=null):: {
        type: "Pnode",
        name: std.prune([name, pnode.name])[0],
        uses: $.resolve_uses([pnode,newhead,newtail]),
        edges: wc.unique_list($.break_insert_edge(index, pnode.edges, newhead.iports[iport], newtail.oports[oport]) + newhead.edges + newtail.edges),
        iports: pnode.iports,
        oports: pnode.oports,
    },

    // Joint N sources using joiner, return pnode that looks like a
    // single source.  The joiner must be capable of handling and
    // N-join.  Each source is connected to joiner's input ports in
    // order.
    join_sources(joiner, sources, n=2) :: $.intern(outnodes=[joiner],
                                                   centernodes=sources,
                                                   iports=[],
                                                   edges=std.mapWithIndex(function(ind,s) $.edge(s,joiner,0,ind),
                                                                          sources),
                                                  ),

}
