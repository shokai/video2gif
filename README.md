video2gif
=========

Install Dependencies
--------------------

    % brew install ffmpeg imagemagick
    % gem install args_parser

Run
---

    % video2gif --help
    % video2gif -i input.mov -o output.gif
    % video2gif -i input.mov -o output.gif -vfps 12 -gfps 18 -s 320x180
    % video2gif -i input.mov -o output.gif -vfps 2 -gfps 6 -s 240x
