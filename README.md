# cmplxsy-predator-prey
Predator-Prey Relationship between the barracuda and parrotfish

There are three buttons to take note of.
Setup - Initializes the environment of the simulation based off of the values of the variables given.
Step - Do one tick of the simulation
Go - continuously do ticks in real time

Variables 
max-forward - how far the fishes can swim per tick

initial-number-pfish - The initial amount of parrot fish spawned when setting up 
pfish-energy-gained - amount of energy gained per algae eaten by parrot fish
pfish-reproduce-energy-threshold - amount of energy a parrot fish should have before it is eligble to reproduce
pfish-reproduce-chance - chance of a successful reproduction of parrot fish when two eligible parrot fishes are in close contact
pfish-cost-of-living - energy needed to live per tick

clusters - number of algae clusters in the environment
cluster radius - how big the algae clusters can get
regrowth-rate-max - how long it takes for algae to grow back


initial-number-barracuda - The initial amount of barracuda spawned when setting up 
barracuda-energy-gained - amount of energy gained per algae eaten by parrot fish
barracuda-reproduce-energy-threshold - amount of energy a parrot fish should have before it is eligble to reproduce
barracuda-reproduce-chance - chance of a successful reproduction of barracuda when two eligible parrot fishes are in close contact
barracuda-cost-of-living - energy needed to live per tick
successful-hunt-chance - if a barracuda is near a parrot fish/s, it is the chance of a barracuda to successfully catch one parrot fish