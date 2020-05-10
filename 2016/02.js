var pad = [
  [null, null, '1', null, null],
  [null, '2', '3', '4', null],
  ['5', '6', '7', '8', '9'],
  [null, 'A', 'B', 'C', null],
  [null, null, 'D', null, null]
];

var code = [];
var startingLoc = { x: 0, y: 2 };

input.forEach(function(path) {
  var loc = { x: startingLoc.x, y: startingLoc.y };

  path.split('').forEach(function(dir) {
    var newLoc = { x: loc.x, y: loc.y }
    switch(dir) {
      case 'U':
        newLoc.y--; break;
      case 'D':
        newLoc.y++; break;
      case 'L':
        newLoc.x--; break;
      case 'R':
        newLoc.x++; break;
    }
    if (newLoc.x < 0) newLoc.x = 0;
    if (newLoc.x > 4) newLoc.x = 4;
    if (newLoc.y < 0) newLoc.y = 0;
    if (newLoc.y > 4) newLoc.y = 4;
    if (pad[newLoc.y][newLoc.x] !== null) {
      loc.x = newLoc.x;
      loc.y = newLoc.y;
    }
  });

  code = code.concat(pad[loc.y][loc.x]);
});

console.log(code);
