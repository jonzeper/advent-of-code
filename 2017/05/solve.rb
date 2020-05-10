f = File.open('input').map(&:strip).map(&:to_i)

pos = 0
n_jumps = 0
while pos >= 0 && pos < f.size
  m = f[pos] > 2 ? -1 : 1
  new_pos = pos + f[pos]
  f[pos] += m
  n_jumps += 1
  pos = new_pos
  puts "#{n_jumps}: #{pos}"
end
