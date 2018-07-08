{
    // Is this really the right thing anymore?

    // Parameters that describe just enough of the detector.  Note,
    // wire locations are specfied in a file given below.
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
}
