// Perfect channel noise DB object configuration for microboone.


local wc = import "wirecell.jsonnet";
local deadchannel = import "sim_deadchannel.jsonnet";

function(params, anode, field)
{
    anode: wc.tn(anode),
    field_response: wc.tn(field),

    tick: params.daq.tick,

    // This sets the number of frequency-domain bins used in the noise
    // filtering.  It is expected that time-domain waveforms have the
    // same number of samples.
    nsamples: params.nf.nsamples,

    // For MicroBooNE, channel groups is a 2D list.  Each element is
    // one group of channels which should be considered together for
    // coherent noise filtering.
    groups: [std.range(g*48, (g+1)*48-1) for g in std.range(0,171)],

    // Externally determined "bad" channels.
    bad: deadchannel,

    // Overide defaults for specific channels.  If an info is
    // mentioned for a particular channel in multiple objects in this
    // list then last mention wins.
    channel_info: [             

        // First entry provides default channel info across ALL
        // channels.  Subsequent entries override a subset of channels
        // with a subset of these entries.  There's no reason to
        // repeat values found here in subsequent entries unless you
        // wish to change them.
        {
            channels: std.range(0, 2400 + 2400 + 3456 - 1),
            nominal_baseline: 2048.0,  // adc count
            gain_correction: 1.0,     // unitless
            response_offset: 0.0,      // ticks?
            pad_window_front: 10,     // ticks?
            pad_window_back: 10,      // ticks?
	    decon_limit: 0.02,
	    decon_limit1: 0.09,
	    adc_limit: 15,
            min_rms_cut: 1.0,
            max_rms_cut: 5.0,

            // parameter used to make "rcrc" spectrum
            rcrc: 1.0*wc.millisecond,

            // parameters used to make "config" spectrum
            reconfig : {},

            // list to make "noise" spectrum mask
            freqmasks: [],

            // field response waveform to make "response" spectrum.  
            response: {},

        },

        {
            channels: {wpid: wc.WirePlaneId(wc.Ulayer)},
            pad_window_front: 20,
	    decon_limit: 0.02,
	    decon_limit1: 0.09,
        },

        {
            channels: {wpid: wc.WirePlaneId(wc.Vlayer)},
	    decon_limit: 0.01,
	    decon_limit1: 0.08,
	    },

        {
            channels: {wpid: wc.WirePlaneId(wc.Wlayer)},
            nominal_baseline: 400.0,
	    decon_limit: 0.05,
	    decon_limit1: 0.08,
        },

        {                       // these are before hardware fix 
            channels: null, //params.nf.misconfigured.channels,
            reconfig: {
                from: {gain:  params.nf.misconfigured.gain,
                       shaping: params.nf.misconfigured.shaping},
                to:   {gain: params.elec.gain,
                       shaping: params.elec.shaping},
            }
        },
    ],
}
    
