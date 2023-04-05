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
adm.clearSegments()
