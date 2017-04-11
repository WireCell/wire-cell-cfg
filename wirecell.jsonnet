{
    // units
    nanosecond: 1.0,
    ns:         self.nanosecond,
    second:     1.0e9*self.nanosecond,
    s:          self.second,
    millisecond:1.0e6*self.nanosecond,
    ms:         self.millisecond,
    microsecond:1.0e3*self.nanosecond,
    us:         self.microsecond,
    picosecond: 1.0e-3*self.nanosecond,

    millimeter: 1.0,
    mm:         self.millimeter,
    centimeter: 10.0*self.millimeter,
    cm:         self.centimeter,
    meter:      1000.0*self.millimeter,
    cm2:        self.cm*self.cm,


    pi: 2*std.acos(0),

    radian: 1.0,
    rad:    self.radian,
    degree: self.pi/180.0,
    deg:    self.degree,

    // fixme: make this match WCT system of units
    volt: 1.0,

    // values
    nominal_drift_velocity: 1.6*self.mm/self.us,

    // vectors
    point(x,y,z,u) :: {x:x*u, y:y*u, z:z*u},
    ray(p1,p2) :: {tail:p1, head:p2},

    Point :: {x:0,y:0,z:0},
    Ray :: {tail:self.Point,head:self.Point},
    Track :: { time:0.0, charge:-1, ray:self.Ray },


    // fixme: need to revisit what is below

    // Configurables
    Component :: {
	type:"",
	name:"",
	data:{}
    },
    TrackDepos :: self.Component + { type: "TrackDepos" },

    // DFP
    Node :: {type:"",name:"",port:0},
    uvw:: ["U","V","W"],
    conn_uvw_uvw(a,b,p)::
    {
	tail: {type:a, name:a + $.uvw[p], port:p},
	head: {type:b, name:b + $.uvw[p], port:p},
    },
    conn_one_uvw(a,b,p)::
    {
	tail: {type:a, name:a},
	head: {type:b, name:b + $.uvw[p]},
    },
    conn_uvw_one(a,b,p)::
    {
	tail: {type:a, name:a + $.uvw[p]},
	head: {type:b, name:b,            port:p},
    },
    
}

