# -*- coding: utf-8 -*-
print("Loading class...")
from evdiff import indi

print("Creating obj:")
best = indi(10,ev=False)
print("Asigning amplitudes...")
best.amplitudes = [16.24929854, 15.47351981, 19.79463823, 11.85881823, 1., 1., 1., 1., 1., 1.]
print(best.amplitudes)
print("Asigning distances...")
best.distances = [0.97339126, 0.75831553, 0.89410924, 0.62698482, 0.5, 0.5, 0.5, 0.5, 0.5, 0.5]
print(best.distances)
print("Computing positions...")
best.getPositions()
print(best.antPos)

print("computing mesh...")
best.globo()
print("Computing mean...")
best.mean(True)
