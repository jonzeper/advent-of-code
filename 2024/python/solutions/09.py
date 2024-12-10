from collections import defaultdict, namedtuple

class Filesystem:
    def __init__(self):
        self.i = 0
        self.checksum = 0

    def write_file(self, fid, size):
        # print(f"Writing file {fid=} {size=}")
        for _ in range(size):
            self.checksum += self.i * fid
            self.i += 1

    def write_blanks(self, size):
        # print(f"Writing {size} blanks")
        self.i += size


def part_one(lines: list[str]) -> int:
    disk_map = [int(c) for c in lines[0]]
    map_l = 0 # Pointer working from left of map
    l_fid = 0
    map_r = len(disk_map) - 1 # Pointer from right of map
    r_fid = ((len(disk_map) + 1) // 2) - 1 # n_files - 1
    filesystem = Filesystem()
    while map_r > map_l:
        filesystem.write_file(l_fid, disk_map[map_l])
        map_l += 1 # We've processed a file on the left, move the pointer up one place
        l_fid += 1

        # Fill in blank spaces with file(s) from right side
        n_blanks = disk_map[map_l]
        while n_blanks > 0:
            r_file_len = disk_map[map_r]

            if r_file_len > n_blanks:
                # File on right is longer than our blank space. Take off what we can and stick it in.
                disk_map[map_r] -= n_blanks # Leave the entry on the end, but reduce its length accordingly
                filesystem.write_file(r_fid, n_blanks)
                n_blanks = 0
            else:
                # File on right fits exactly in our blank space.
                filesystem.write_file(r_fid, r_file_len)
                n_blanks -= r_file_len
                map_r -= 2 # We processed a file on the right, so decrement the right-hand pointer. We can skip over blank space, so move two.
                r_fid -= 1
        map_l += 1 # We processed a blank space record on the left, move the left-hand pointer up one.

    # Maybe there's a little left over on the right side after we've filled in all blank space from the left
    if disk_map[map_r] > 0:
        filesystem.write_file(r_fid, disk_map[map_r])

    return filesystem.checksum

DiskMapEntry = namedtuple("DiskMapEntry", ["id", "size"]) # We'll use id == -1 to indicate a blank

def part_two(lines: list[str]) -> int:
    n_files = len(lines[0]) // 2
    fid = 0
    disk_map: list[DiskMapEntry] = []
    for i in range(0, len(lines[0]), 2):
        disk_map.append(DiskMapEntry(fid, int(lines[0][i])))
        fid += 1
        if i+1 < len(lines[0]):
            disk_map.append(DiskMapEntry(-1, int(lines[0][i+1])))

    filesystem = Filesystem()
    map_r = -1
    lowest_checked = n_files

    while abs(map_r) < len(disk_map):
        rightmost_entry = disk_map[map_r]
        if rightmost_entry.id == -1 or rightmost_entry.id > lowest_checked:
            map_r -= 1
            continue
        lowest_checked = rightmost_entry.id

        map_l = 0 # Pointer in disk_map
        while map_l < len(disk_map) + map_r:
            if disk_map[map_l].id < 0 and disk_map[map_l].size >= rightmost_entry.size:
                move_it(disk_map, map_l, map_r)
                break
            map_l += 1
        map_r -= 1

    for entry in disk_map:
        if entry.id == -1:
            filesystem.write_blanks(entry.size)
        else:
            filesystem.write_file(entry.id, entry.size)

    return filesystem.checksum

def move_it(disk_map: list[DiskMapEntry], map_l, map_r):
    fsize = disk_map[map_r].size
    disk_map[map_l] = DiskMapEntry(-1, disk_map[map_l].size - fsize)
    disk_map.insert(map_l, disk_map[map_r])
    disk_map[map_r] = DiskMapEntry(-1, fsize)

def render(disk_map):
    buf=""
    for entry in disk_map:
        for _ in range(entry.size):
            if entry.id == -1:
                buf += "."
            else:
                buf += str(entry.id)
    print(buf)

def part_two_wrong(lines: list[str]) -> int:
    # I first interpreted the problem as wanting to find the lastest file that would fit snugly in the open space, not just
    # the first one which would fit at all. Saving for posterity.
    disk_map = [int(c) for c in lines[0]]

    files_by_size = defaultdict(list)
    for fid, fsize in enumerate(disk_map[::2]):
        files_by_size[fsize].append(fid)

    filesystem = Filesystem()
    map_i = 0 # Pointer in disk map
    while len(files_by_size) > 0:
        # Handle a file from the left
        fid = map_i // 2
        fsize = disk_map[map_i]
        filesystem.write_file(fid, fsize)
        map_i += 1
        files_by_size[fsize].remove(fid)
        if len(files_by_size[fsize]) < 1:
            del files_by_size[fsize]

        # Handle blank space from the left
        n_blanks = disk_map[map_i]
        # Look for the largest (and rightmost) file which would fit in the blank
        while n_blanks > 0:
            search_size = n_blanks
            while search_size > 0:
                # We found a file with the target size
                if files_with_target_size := files_by_size.get(search_size):
                    fid = files_with_target_size.pop()
                    if len(files_with_target_size) < 1:
                        del files_by_size[search_size]
                    filesystem.write_file(fid, search_size)
                    n_blanks -= search_size
                # No match, see if there is a smaller file that would fit
                else:
                    search_size -= 1
        if n_blanks > 0:
            filesystem.write_blanks(n_blanks)
        map_i += 1


    return 1
