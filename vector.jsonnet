// A collection of Jsonnet functions for dealing with vectors
{
    // element by element vector arithmatic
    vadd(v1,v2) :: std.map(function(i) v1[i]+v2[i],std.range(0,std.length(v1)-1)),
    vmul(v1,v2) :: std.map(function(i) v1[i]*v2[i],std.range(0,std.length(v1)-1)),
    vsub(v1,v2) :: std.map(function(i) v1[i]-v2[i],std.range(0,std.length(v1)-1)),

    // return the direction of v
    vdir(v) :: $.scale(v, 1.0 / $.mag(v)),

    // Return a vector displaced along direction of d by length l from v.
    vshift(v,d,l) :: $.vadd(v, $.scale($.vdir(d), l)),

    // Sum elements of a vector
    sum(v) :: std.foldl(function(n,x) n+x, v, 0),

    // Magnitude/length of a vector 
    mag(v) :: std.sqrt(self.sum(std.map(function(x) x*x, v))),

    // Multiply a scalar to a vector, element by element
    scale(v,s) :: std.map(function(e) e*s, v),

    // Add a scalar to a vector, element by element
    increase(v,s) :: std.map(function(e) e+s, v),

    // Return 3-vector in "3D point" format
    topoint(v) :: { x:v[0], y:v[1], z:v[2] },

    // return 3-vector given a "3D point" 
    frompoint(p) :: [ p.x, p.y, p.z ],

}
