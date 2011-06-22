#!/usr/bin/env ruby
## install ffmpeg imagemagick
## gem install ArgsParser

require 'rubygems'
require 'ArgsParser'

parser = ArgsParser.parser
parser.bind(:input, :i, 'input video file')
parser.bind(:output, :o, 'output gif file', 'out.gif')
parser.bind(:size, :s, 'size', '400x300')
parser.comment(:tmp_dir, 'tmp dir', '/var/tmp/video2gif')
parser.bind(:video_fps, :vfps, 'video fps', 30)
parser.bind(:gif_fps, :gfps, 'gif fps', 30)
parser.comment(:max_frames, 'max frames', -1)
parser.bind(:help, :h, 'show help')
first, params = parser.parse(ARGV)

if !parser.has_param(:input) or parser.has_option(:help)
  puts parser.help
  exit
end

Dir.mkdir params[:tmp_dir] unless File.exists? params[:tmp_dir]
Dir.glob(params[:tmp_dir]+'/*').each{|f|
  File.delete f
}

puts cmd = "ffmpeg -i #{params[:input]} -r #{params[:video_fps]} -s #{params[:size]} -sameq #{params[:tmp_dir]}/%d.gif"
puts `#{cmd}`

max_len = Dir.glob(params[:tmp_dir]+'/*').map{|i|
  i.split('/').last.to_i
}.max.to_s.size

Dir.glob(params[:tmp_dir]+'/*').each{|img|
  dst = File.dirname(img)+'/'+img.split('/').last.to_i.to_s.rjust(max_len,'0')+'.'+img.scan(/\.(.+)$/).first.first
  begin
    File.rename(img, dst)
  rescue => e
    STDERR.puts e
    exit 1
  end
}


if params[:max_frames].to_i > 0
  files = Dir.glob(params[:tmp_dir]+'/*').sort{|a,b|
    a.split('/').last.to_i <=> b.split('/').last.to_i
  }
  while files.size > params[:max_frames].to_i
    File.delete files.shift
  end
end

puts cmd = "convert -colors 32 -resize #{params[:size]} -loop 0 -delay #{100/params[:gif_fps].to_i} #{params[:tmp_dir]}/*.gif #{params[:output]}"
puts `#{cmd}`
