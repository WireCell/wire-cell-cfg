// Some parameters used elsewhere

local wc = import "wirecell.jsonnet";
{
    lar : {
        DL :  7.2 * wc.cm2/wc.s,
        DT : 12.0 * wc.cm2/wc.s,
        lifetime : 8*wc.ms,
        drift_speed : 1.114*wc.mm/wc.us, // at microboone voltage
        density: 1.389*wc.g/wc.centimeter3,
        ar39activity: 1*wc.Bq/wc.kg,
    },
    detector : {
        // Relative extent for active region of LAr box.  
        // (x,y,z) = (drift distance, active height, active width)
        extent: [2.5604*wc.m,2.325*wc.m,10.368*wc.m],
        // Wires have a detector edge at X=0, Z=0, centered in Y.
        center: [0.5*self.extent[0], 0.0, 0.5*self.extent[2]],
        drift_time: self.extent[0]/self.lar.drift_speed,
        drift_volume: self.extent[0]*self.extent[1]*self.extent[2],
        drift_mass: $.lar.density * self.drift_volume,
    },
    daq : {
        readout_time: 5*wc.ms,
        nreadouts: 1,
        start_time: 0.0*wc.s,
        stop_time: self.start_time + self.nreadouts*self.readout_time,
        tick: 0.5*wc.us,        // digitization time period
        sample_period: 0.5*wc.us, // sample time for any spectral data - usually same as tick
        first_frame_number: 100,
        ticks_per_readout: self.readout_time/self.tick,
    },
    adc : {
        gain: 1.0,              // note, relative and not amplifier gain.
        baselines: [900*wc.millivolt,900*wc.millivolt,200*wc.millivolt],
        resolution: 12,
        fullscale: [0*wc.volt, 2.0*wc.volt],
    },
    elec : {
        gain : 14.0*wc.mV/wc.fC,
        shaping : 2.0*wc.us,
        postgain: 1.2,          // relative
    },
    sim : {
        fluctuate: true,        // if statistical fluctations should be applied
        continuous: false,      // if continuous or discontinuous mode is is used.
    },
    nf : {                    // noise filtering specific parameters.  
        frequency_bins: 9592, // number of frequency bins in which NF operates
        run12boundary: 7000,  // separation between "before" and "after" hw noise fix.
    },                        // bunch of stuff also in chndb-*.jsonnet
    files : {
        wires:"microboone-celltree-wires-v2.1.json.bz2",
        fields:["ub-10-half.json.bz2",
                "ub-10-uv-ground-half.json.bz2",
                "ub-10-vy-ground-half.json.bz2"],
        noise: "microboone-noise-spectra-v2.json.bz2",
    }
}

