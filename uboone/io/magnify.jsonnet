// note: do not change this file for your particular job.  Rather
// inherit from these data structures and change them in your own
// file.
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
            // What factor to rebin.
            rebin: 1,
            // fixme: giving an input file here is evil.
            input_filename: std.extVar("input"),
            output_filename: std.extVar("output"),

            // the category to use for the output histogram
            histtype: "decon",

            // The evilness includes shunting data directly from input
            // file to output file.  This allows the shunt to be
            // limited to the listed histogram categories.  The
            // possible categories include: orig, raw, decon,
            // threshold, baseline and possibly others.  If the value
            // is left unset or null then all categories known to the
            // code will be shunted.
            shunt: [],
        },
    }

}
