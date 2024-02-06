patches-own [ is-algae? regrowth ]
turtles-own [ energy ] ; parrot fish and barra
globals [
  parrotfish-population
  barracuda-population
  algae-count
]

breed [ parrotFishes parrotFish ]
breed [ barracudas barracuda ]

to setup
  clear-all
  reset-ticks
  ask patches
  [
    set pcolor blue
    set is-algae? false
    set regrowth regrowth-rate-max
  ]

  set algae-count 0
  let centroid patch 0 0
  repeat clusters [
    let tmp patch random-pxcor random-pycor

    while [is-patch-close? tmp centroid] [
      set tmp patch random-pxcor random-pycor
    ]

    populate-cluster tmp
    set centroid tmp
  ]

  create-parrotFishes initial-number-pfish
  [
    set shape  "fish"
    set color 126 ; magenta ish
    set size 2
    set label-color blue - 2
    set energy random (10)
    setxy random-xcor random-ycor
  ]

  ; barracudas look bluish silver or greenish silver imo
  create-barracudas initial-number-barracuda [
    set shape "fish"
    set color 98
    set size 5
    set label-color red - 2
    set energy random (20)
    setxy random-xcor random-ycor
  ]
end

to-report is-patch-close? [c1 c2]
  let dist-to-prev 0
  let dist-to-origin 0
  ask c1 [
    set dist-to-prev (distance c2)
  ]
  report dist-to-prev <= max-pxcor
end

to go
  regrow-algae
  ask parrotFishes
  [
    ifelse coin-flip? [right random 45] [left random 45] ; fish cant make 180 turns right???
    forward random max-forward
  ]

  ask barracudas [
    let b self
    let p nobody

    ask neighbors [
      ask parrotFishes-here [
        set p self
      ]
    ]

    ifelse p != nobody [
      face p
    ] [
      ifelse coin-flip? [right random 45] [left random 45]
    ]
    set label energy
    forward random max-forward
  ]

  set algae-count 0
  ask patches [
    if pcolor = red [
      set algae-count (algae-count + 1)
    ]
  ]
  parrot-fish-live
  parrot-fish-reproduce
  barracuda-live
  barracuda-reproduce
  tick
end

to step
  go
end

to populate-cluster [cluster]
  ask cluster [
    let this-radius (random-gamma cluster-radius 1)

    let xs (range (pxcor - this-radius) (pxcor + this-radius))
    let ys (range (pycor - this-radius) (pycor + this-radius))

    (foreach xs [
      [x] -> (
        (foreach ys [
          [y] -> ask (patch x y) [
            let radius (distance (cluster))
              if random-float 1 < (1 - (radius - 1) / this-radius) [
              set pcolor red
              set is-algae? true
              set algae-count (algae-count + 1)
            ]
          ]
        ])
      )
    ])
  ]
end

to regrow-algae
  ask patches
  [
    ifelse is-algae? and regrowth = 0 [
      set pcolor red
    ] [set regrowth regrowth - 1]
  ]
end

to parrot-fish-live
  ask parrotFishes
  [
    if pcolor = red
    [
      set pcolor blue
      set energy (energy + pfish-energy-gained)
      set regrowth regrowth-rate-max
    ]

    set energy (energy - pfish-cost-of-living)
    if energy <= 0 [die]
  ]
end

;to barracuda-live
;  ask barracudas
 ; [
  ;  let eaten (count parrotFishes-here)
   ; ask parrotFishes-here [
    ;  die
    ;]

    ;set energy (energy + eaten * barracuda-energy-gained - 1)
    ;if energy <= 0 [die]
;  ]
;end

to barracuda-live
  ask barracudas [
    if any? parrotFishes in-radius 1 [
      let huntCheck random 100 + 1 < successful-hunt-chance

      if huntCheck [
        let eaten 1 ;  one fish
        ask one-of parrotFishes in-radius 1 [ die ]

        set energy (energy + eaten * barracuda-energy-gained)
      ]
    ]
    set energy (energy - barracuda-cost-of-living)
    if energy <= 0 [die]
  ]
end




;when prey eats algae, ask patches[set regrowth 30 set pcolor blue]
to parrot-fish-reproduce
  ask parrotFishes
  [
    if energy > pfish-reproduce-energy-threshold
    [
      let potential-mate one-of other parrotFishes with [energy > pfish-reproduce-energy-threshold]

      if potential-mate != nobody and random 100 < pfish-reproduction-chance
      [
        ; Create a child fish
        hatch-parrotFishes 1
        [
          set color 126 ; magenta ish
          set size 2
          set energy (energy + [energy] of potential-mate) / 3 ; share energy between parents and child
        ]

        ; Decrease the energy of the parent fish
        set energy (energy - (energy / 3))
        ask potential-mate [set energy (energy - (energy / 3))]
      ]
    ]
  ]
end

to barracuda-reproduce
  ask barracudas
  [
    if energy > barracuda-reproduce-energy-threshold
    [
      let potential-mate one-of other barracudas with [energy > barracuda-reproduce-energy-threshold]

      if potential-mate != nobody and random 100 < barracuda-reproduction-chance
      [
        ; Create a child fish
        hatch-barracudas 1
        [
          set color 98
          set size 5
          set energy (energy + [energy] of potential-mate) / 3 ; share energy between parents and child
        ]

        ; Decrease the energy of the parent fish
        set energy (energy - (energy / 3))
        ask potential-mate [set energy (energy - (energy / 3))]
      ]
    ]
  ]
end


to-report coin-flip?
  report random 2 = 0 ;0 or 1
end
@#$#@#$#@
GRAPHICS-WINDOW
565
25
1093
554
-1
-1
8.0
1
10
1
1
1
0
1
1
1
-32
32
-32
32
0
0
1
ticks
30.0

BUTTON
34
37
100
70
setup
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
181
40
244
73
go
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
37
116
209
149
initial-number-pfish
initial-number-pfish
0
100
100.0
1
1
NIL
HORIZONTAL

SLIDER
307
24
479
57
max-forward
max-forward
0
100
3.0
1
1
NIL
HORIZONTAL

SLIDER
35
156
207
189
pfish-energy-gained
pfish-energy-gained
0
100
20.0
1
1
NIL
HORIZONTAL

SLIDER
306
64
478
97
regrowth-rate-max
regrowth-rate-max
0
500
100.0
10
1
NIL
HORIZONTAL

SLIDER
36
199
262
232
pfish-reproduce-energy-threshold
pfish-reproduce-energy-threshold
0
100
30.0
1
1
NIL
HORIZONTAL

SLIDER
35
246
221
279
pfish-reproduction-chance
pfish-reproduction-chance
0
100
10.0
1
1
NIL
HORIZONTAL

SLIDER
33
337
206
370
cluster-radius
cluster-radius
0
20
10.0
1
1
NIL
HORIZONTAL

SLIDER
59
402
232
435
clusters
clusters
1
10
5.0
1
1
NIL
HORIZONTAL

SLIDER
370
114
556
147
initial-number-barracuda
initial-number-barracuda
0
100
5.0
1
1
NIL
HORIZONTAL

SLIDER
362
156
555
189
barracuda-energy-gained
barracuda-energy-gained
0
100
30.0
1
1
NIL
HORIZONTAL

SLIDER
287
197
555
230
barracuda-reproduce-energy-threshold
barracuda-reproduce-energy-threshold
0
100
15.0
1
1
NIL
HORIZONTAL

SLIDER
330
237
556
270
barracuda-reproduction-chance
barracuda-reproduction-chance
0
100
10.0
1
1
NIL
HORIZONTAL

MONITOR
277
367
357
412
NIL
algae-count
17
1
11

PLOT
1114
25
1314
175
Algae Count
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot algae-count"

MONITOR
271
442
381
487
NIL
count barracudas
17
1
11

MONITOR
281
500
399
545
NIL
count parrotFishes
17
1
11

PLOT
1117
206
1317
356
Fish Population
NIL
NIL
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"barracudas" 1.0 0 -2139308 true "" "plot count barracudas"
"parrot fishes" 1.0 0 -14454117 true "" "plot count parrotFishes"

BUTTON
108
38
172
72
NIL
step
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
382
280
554
313
successful-hunt-chance
successful-hunt-chance
0
100
53.0
1
1
NIL
HORIZONTAL

SLIDER
384
333
558
366
barracuda-cost-of-living
barracuda-cost-of-living
0
100
100.0
1
1
NIL
HORIZONTAL

SLIDER
34
290
206
323
pfish-cost-of-living
pfish-cost-of-living
0
100
100.0
1
1
NIL
HORIZONTAL

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.4.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
