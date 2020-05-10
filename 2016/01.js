var vectors = [
  { x: 0, y: -1 }, // N
  { x: 1, y: 0 }, // E
  { x: 0, y: 1 }, // S
  { x: -1, y: 0 } // W
]
var dir = 0;
var loc = { x: 0, y: 0 };
var visitedLocs = [{ x: 0, y: 0 }];

var wasVisited = function(loc) {
  for (var i=0; i < visitedLocs.length; i++) {
    if (visitedLocs[i].x == loc.x && visitedLocs[i].y == loc.y) {
      return true;
    }
  }
  return false;
}

for (var i = 0; i < a.length; i++) {
  var turn = a[i][0];
  var steps = a[i].slice(1);

  if (turn === 'L') {
    dir--;
    if (dir < 0) dir = 3;
  } else {
    dir++;
    if (dir > 3) dir = 0;
  }

  for (var j=0; j < steps; j++) {
    loc.x += vectors[dir].x;
    loc.y += vectors[dir].y;
    if (wasVisited(loc)) {
      console.log('Already visited', loc);
    }
    visitedLocs = visitedLocs.concat({ x: loc.x, y: loc.y });
  }
}
