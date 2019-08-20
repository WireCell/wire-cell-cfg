#!/usr/bin/env python

# Created by Wenqiang Gu, 8/20/2019

import sys, math
argc = len(sys.argv)
if argc!=2:
  print "Usage example: python test_gen_rays_pdsp.py 45 # unit in degree" 
  exit()

deg = math.radians(1)
meter = 1.0

theta = float(sys.argv[1]) *deg
tanth = math.tan(theta)

Ltpc = 3.6*meter
Htpc = 6.0*meter
Wtpc = 2.3*meter

p1 = [-Ltpc, 0.5*Htpc, 0]
p2 = [ 0, 0.5*Htpc, Ltpc/tanth]
Nreplica = int(3.*Wtpc / (Ltpc/tanth)) + 1
print '''local wc = import 'wirecell.jsonnet';
{
  rays: [
'''

for i in range(Nreplica):
  print '''  {
    tail: wc.point(%.3f, %.3f, %.3f, wc.m),  
    head: wc.point(%.3f, %.3f, %.3f, wc.m),
  },
  {
    tail: wc.point(%.3f, %.3f, %.3f, wc.m),  
    head: wc.point(%.3f, %.3f, %.3f, wc.m),
  },
  ''' %(p1[0], p1[1], p1[2], p2[0], p2[1], p2[2], p1[0]+Ltpc, p1[1], p1[2], p2[0]+Ltpc, p2[1], p2[2]) 
  p1[2] += Ltpc/tanth
  p2[2] += Ltpc/tanth

  p1[2] += 0.05*meter
  p2[2] += 0.05*meter

print '''  ],
}
'''
