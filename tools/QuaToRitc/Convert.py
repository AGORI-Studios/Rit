import os, sys, yaml

global quaMap, ritc, string
ritc = ""

# Example rit chart format:
"""
[Meta]
AudioFile:file.ogg
SongTitle:Name blah blah
SongDiff:Diff
[...]

[Timings]
starttime:bpm

// comment (just cuz)
[Hits]
starttime:endtime:lane // if endtime is 0, -1, or up to starttime, then theres no hold object
[...]

[Velocities] // Quaver SV's in Rit's format
starttime:multiplier
[...]
"""

if __name__ == "__main__":
    # get our file arg
    if len(sys.argv) < 2:
        print("Usage: python Convert.py <file>")
        sys.exit(1)

    # get our file
    file = sys.argv[1]
    if not os.path.isfile(file):
        print("File does not exist")
        sys.exit(1)

    # open our file
    with open(file, "r") as f:
        quaMap = yaml.safe_load(f)

    ritc += "[Meta]\n"
    ritc += "AudioFile:" + quaMap["AudioFile"] + "\n"
    ritc += "SongTitle:" + quaMap["Title"] + "\n"
    ritc += "SongDiff:" + quaMap["DifficultyName"] + "\n"
    ritc += "Background:" + quaMap["BackgroundFile"] + "\n"
    ritc += "Banner:" + quaMap["BannerFile"] + "\n"
    # Mode, but remove the "Keys" part (is formatted like Mode: Keys4), should only give "4"
    ritc += "KeyAmount:" + quaMap["Mode"].replace("Keys", "") + "\n"
    ritc += "Creator:" + quaMap["Creator"] + "\n"
    ritc += "CreatorID:" + quaMap["Creator"] + "\n"

    ritc += "\n[Timings]\n" # TimingPoints dictionary
    for tp in quaMap["TimingPoints"]:
        ritc += str(tp["StartTime"]) + ":" + str(tp["Bpm"] if "Bpm" in tp else 0) + "\n"

    ritc += "\n[Hits]\n" # HitObjects dictionary
    for hit in quaMap["HitObjects"]:
        # get our start/end times
        start = hit["StartTime"]
        end = hit["EndTime"] if "EndTime" in hit else 0
        ritc += str(start) + ":" + str(end) + ":" + str(hit["Lane"]) + "\n"

    ritc += "\n[Velocities]\n" # SliderVelocities dictionary
    for sv in quaMap["SliderVelocities"]:
        mult = sv["Multiplier"] if "Multiplier" in sv else 1
        ritc += str(sv["StartTime"]) + ":" + str(mult) + "\n"

    # save our file
    with open(file[:-4] + ".ritc", "w") as f:
        f.write(ritc)

    print("Done!")
