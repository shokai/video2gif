#!/usr/bin/env ruby
require 'rubygems'
require 'ArgsParser'
require 'fileutils'

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
  puts 'e.g.   ruby video2gif.rb -i input.mov -o output.gif -vfps 2 -gfps 6 -s 200x150'
  exit
end

tmpdir = params[:tmp_dir].gsub(/\/$/,'')+"/#{Time.now.to_i}_#{Time.now.usec}"
FileUtils.mkdir_p tmpdir unless File.exists? tmpdir

puts cmd = "ffmpeg -i #{params[:input]} -r #{params[:video_fps]} -s #{params[:size]} -sameq #{tmpdir}/%d.gif"
puts `#{cmd}`

max_len = Dir.glob("#{tmpdir}/*").map{|i|
  i.split('/').last.to_i
}.max.to_s.size

Dir.glob("#{tmpdir}/*").each{|img|
  dst = File.dirname(img)+'/'+img.split('/').last.to_i.to_s.rjust(max_len,'0')+'.'+img.scan(/\.(.+)$/).first.first
  begin
    File.rename(img, dst)
  rescue => e
    STDERR.puts e
    exit 1
  end
}

if params[:max_frames].to_i > 0
  files = Dir.glob("#{tmpdir}/*").sort{|a,b|
    a.split('/').last.to_i <=> b.split('/').last.to_i
  }
  while files.size > params[:max_frames].to_i
    File.delete files.shift
  end
end

puts cmd = "convert -colors 32 -resize #{params[:size]} -loop 0 -delay #{100/params[:gif_fps].to_i} #{tmpdir}/*.gif #{params[:output]}"
puts `#{cmd}`

FileUtils.rm_r(tmpdir)
