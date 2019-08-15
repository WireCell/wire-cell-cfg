// Base channel noise DB object configuration for microboone
// This does not include any run dependent RMS cuts.
// See chndb.jsonnet

local handmade = import 'chndb-resp.jsonnet';
local wc = import 'wirecell.jsonnet';

function(params, anode, field, n, rms_cuts=[])
  {
    anode: wc.tn(anode),
    field_response: wc.tn(field),

    tick: params.daq.tick,

    // This sets the number of frequency-domain bins used in the noise
    // filtering.  It is not necessarily true that the time-domain
    // waveforms have the same number of ticks.  This must be non-zero.
    nsamples: params.nf.nsamples,

    // For MicroBooNE, channel groups is a 2D list.  Each element is
    // one group of channels which should be considered together for
    // coherent noise filtering.
    // groups: [std.range(g*48, (g+1)*48-1) for g in std.range(0,171)],
    groups: [std.range(n * 2560 + u * 40, n * 2560 + (u + 1) * 40 - 1) for u in std.range(0, 19)]
            + [std.range(n * 2560 + 800 + v * 40, n * 2560 + 800 + (v + 1) * 40 - 1) for v in std.range(0, 19)]
            + [std.range(n * 2560 + 1600 + w * 48, n * 2560 + 1600 + (w + 1) * 48 - 1) for w in std.range(0, 19)],


    // Externally determined "bad" channels.
    bad: [1, 2, 4, 200, 202, 204, 206, 208, 400, 401, 800, 801, 876, 991, 993, 995, 997, 999, 1200, 1632, 1719, 1829, 1831, 1833, 1835, 1837, 1839, 2169, 2961, 3541, 3543, 3661, 3663, 4061, 4063, 4141, 4143, 4377, 4379, 4381, 4383, 4385, 4387, 4410, 4411, 4412, 4521, 4523, 4525, 4527, 4529, 4531, 4652, 4654, 4656, 4658, 4658, 4660, 4748, 4750, 4752, 4754, 4756, 4758, 5125, 5321, 5361, 5363, 6132, 7058, 7190, 7194, 7295, 7551, 7680, 7681, 7918, 8080, 8328, 8480, 8501, 8503, 8821, 8823, 9261, 9263, 9282, 9283, 9305, 9307, 9309, 9311, 9313, 9315, 9689, 9691, 9693, 9695, 9697, 9699, 9736, 9772, 9774, 9776, 9778, 9780, 9782, 9854, 9990, 10102, 10189, 10697, 10800, 10907, 11024, 11203, 11270, 11457, 11459, 11463, 11469, 11517, 11669, 11679, 11842, 11902, 12324, 12333, 12744, 12756, 12801, 13001, 13081, 13363],

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
        channels: std.range(n * 2560, (n + 1) * 2560 - 1),
        nominal_baseline: 2048.0,  // adc count
        gain_correction: 1.0,  // unitless
        response_offset: 0.0,  // ticks?
        pad_window_front: 10,  // ticks?
        pad_window_back: 10,  // ticks?
        decon_limit: 0.02,
        decon_limit1: 0.09,
        adc_limit: 15,
        roi_min_max_ratio: 0.8, // default 0.8
        min_rms_cut: 1.0,  // units???
        max_rms_cut: 30.0,  // units???

        // parameter used to make "rcrc" spectrum
        rcrc: 1.1 * wc.millisecond, // 1.1 for collection, 3.3 for induction
        rc_layers: 1, // default 2

        // parameters used to make "config" spectrum
        reconfig: {},

        // list to make "noise" spectrum mask
        freqmasks: [],

        // field response waveform to make "response" spectrum.
        response: {},

      },

      {
        //channels: { wpid: wc.WirePlaneId(wc.Ulayer) },
	channels: std.range(n * 2560, n * 2560 + 800- 1),
	freqmasks: [
          { value: 1.0, lobin: 0, hibin: $.nsamples - 1 },
          { value: 0.0, lobin: 169, hibin: 173 },
          { value: 0.0, lobin: 513, hibin: 516 },
        ],
        /// this will use an average calculated from the anode
        // response: { wpid: wc.WirePlaneId(wc.Ulayer) },
        /// this uses hard-coded waveform.
        response: { waveform: handmade.u_resp, waveformid: wc.Ulayer },
        response_offset: 120, // offset of the negative peak
        pad_window_front: 20,
        decon_limit: 0.02,
        decon_limit1: 0.07,
        roi_min_max_ratio: 3.0,
      },

      {
        //channels: { wpid: wc.WirePlaneId(wc.Vlayer) },
	channels: std.range(n * 2560 + 800, n * 2560 + 1600- 1),
        freqmasks: [
          { value: 1.0, lobin: 0, hibin: $.nsamples - 1 },
          { value: 0.0, lobin: 169, hibin: 173 },
          { value: 0.0, lobin: 513, hibin: 516 },
        ],
        /// this will use an average calculated from the anode
        // response: { wpid: wc.WirePlaneId(wc.Vlayer) },
        /// this uses hard-coded waveform.
        response: { waveform: handmade.v_resp, waveformid: wc.Vlayer },
        response_offset: 124,
        decon_limit: 0.01,
        decon_limit1: 0.08,
        roi_min_max_ratio: 1.5,
      },

      local freqbinner = wc.freqbinner(params.daq.tick, params.nf.nsamples);
      local harmonic_freqs = [f*wc.kilohertz for f in
        // [51.5, 102.8, 154.2, 205.5, 256.8, 308.2, 359.2, 410.5, 461.8, 513.2, 564.5, 615.8]
        [51.5, 77.2, 102.8, 128.5, 154.2, 180.0, 205.5, 231.5, 256.8, 282.8, 308.2, 334.0, 359.2, 385.5, 410.5, 461.8, 513.2, 564.5, 615.8, 625.0]
      ];
      
      {
        //channels: { wpid: wc.WirePlaneId(wc.Wlayer) },
	channels: std.range(n * 2560 + 1600, n * 2560 + 2560- 1),
        nominal_baseline: 400.0,
        decon_limit: 0.05,
        decon_limit1: 0.08,
        freqmasks: freqbinner.freqmasks(harmonic_freqs, 5.0*wc.kilohertz),
      },

    ] + rms_cuts,
  }
