def myfilter(s) =
  def mkfilter(graph) =
    v = ffmpeg.filter.video.input(graph, s)
    v = ffmpeg.filter.hflip(graph, v)
    v = ffmpeg.filter.curves(preset=10, graph, v)
    ffmpeg.filter.video.output(graph, v)
  end
   mux_audio(audio=drop_video(s), ffmpeg.filter.create(mkfilter))
end
