local wc = import "wirecell.jsonnet";
{
    port(obj, num=0) :: {
        node: wc.tn(obj),
        port: num
    },


    // connect two inodes
    iedge(tail, head, tp=0, hp=0):: {
        tail: $.port(tail, tp),
        head: $.port(head, hp),
        
    },

    // Connect two pnodes
    edge(tail, head, tp=0, hp=0):: {
        tail: tail.oports[tp],
        head: head.iports[hp],
    },

    // Make a pnode from a single inode
    inode(obj, iports=[0], oports=[0]):: {
        type: "Pnode",
        name: wc.tn(obj),
        edges: [],
        uses: [obj],
        iports: [$.port(obj, n) for n in iports],
        oports: [$.port(obj, n) for n in oports],
    },

    strip_pnodes(arr):: std.filter(function(x) x.type != "Pnode", arr),
}
