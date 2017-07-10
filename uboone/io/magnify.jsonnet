{
    source : {
        type: "MagnifySource",
        data: {
            filename: std.extVar("input"),
            histtype: "raw",
        }
    },
    sink: {
        type: "MagnifySink",
        data: {
            rebin: 6,
            // fixme: giving an input file here is evil.
            input_filename: std.extVar("input"),
            output_filename: std.extVar("output"),
        },
    }

}
