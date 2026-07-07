require 'chunky_png'

class AsciiArt
  def initialize(filename, chunk_w = 5, chunk_h = 12)
    @palette = ' .:-+*#%@'.chars
    @img = ChunkyPNG::Image.from_file(filename)
    @chunk_w = chunk_w
    @chunk_h = chunk_h
    @rows = @img.height / @chunk_h
    @cols = @img.width  / @chunk_w
  end

  def brightness(x, y)
    px = @img[x, y]
    r  = ChunkyPNG::Color.r(px)
    g  = ChunkyPNG::Color.g(px)
    b  = ChunkyPNG::Color.b(px)

    (0.299 * r + 0.587 * g + 0.114 * b) # brightness, Rec. 601 luma formula, 0.0 - 255.0
  end

  def chunk(x_coordinate, y_coordinate)
    chunk_brightness = []

    x = @chunk_w * x_coordinate
    y = @chunk_h * y_coordinate

    @chunk_w.times do
      @chunk_h.times do
        chunk_brightness << brightness(x, y)
        y += 1
      end
      y = @chunk_h * y_coordinate
      x += 1
    end
    chunk_brightness.sum.to_f / chunk_brightness.length
  end

  def chunk_char(chunk_x, chunk_y)
    avg   = chunk(chunk_x, chunk_y) # 0.0–255.0
    index = (avg / 255.0 * (@palette.length - 1)).round
    @palette[index]
  end

  def draw
    chunk_x = 0
    chunk_y = 0
    row_chars = []
    @rows.times do
      @cols.times do
        row_chars << chunk_char(chunk_x, chunk_y)
        chunk_x += 1
      end
      chunk_x = 0
      chunk_y += 1

      puts row_chars.join
      row_chars = []
    end
  end
end

def play
  puts "Play ball with the cat and dog: "
  ['cat.png','dog.png','ball.png'].each { |item| AsciiArt.new(item).draw }
end


if __FILE__ == $0
  begin
    if ARGV.empty? || ARGV[0] == "-h"
      puts <<~USAGE
        usage: ruby art.rb <filename.png> [chunk_w=5] [chunk_h=12]
        higher values run faster but lower resolution.
        the ratio of chunk_w:chunk_h sets the aspect ratio —
        if it differs from the font's native ratio, output will be stretched.
        most terminal fonts' w:h ratio is ~1:2 - ish

        also try experimenting with increasing/decreasing terminal font size, some terminals, like alacritty, have line spacing that scales disproportionately 
        to font size, leading to stretching with some font sizes
        
        if you want to see what the output looks like, run ruby art.rb play
      USAGE
    elsif ARGV[0] == "play"
      play
    else
      w = (ARGV[1] || 5).to_i
      h = (ARGV[2] || 12).to_i
      AsciiArt.new(ARGV[0], w, h).draw
    end
  rescue ChunkyPNG::Exception, Errno::ENOENT => e
    warn "couldn't read that image (#{e.message}) — use -h for usage"
    exit 1
  end
end
