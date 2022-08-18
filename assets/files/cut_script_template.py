adm = Avidemux()
# video
adm.videoCodec("Copy")
# audio
tracks = adm.audioTracksCount()
if tracks > 0:
    adm.audioClearTracks()
    adm.setSourceTrackLanguage(0,"Unknown")
    adm.audioAddTrack(0)
    adm.audioCodec(0, "copy")
# choose output directory
outdir = "/Users/aschilken/otr" 
if outdir is None:
    print("Error-No output folder selected, bye")
    return
adm.clearSegments()
