
# ascii-art

Turns a PNG into ASCII art and prints it to your terminal.


## Requirements

- Ruby
- The `chunky_png` gem:

```bash
gem install chunky_png
```

- chunky_png only supports PNG input. Got a JPEG? Convert it first

## Usage

```bash
ruby art.rb <filename.png> [chunk_w] [chunk_h]
```

- `chunk_w` — chunk width in pixels (default: 5)
- `chunk_h` — chunk height in pixels (default: 12)

Bigger chunk values run faster but produce lower resolution.

The ratio of `chunk_w` to `chunk_h` sets the output's aspect ratio. If it differs
from the terminal font's native aspect ratio, the result will be stretched.

Run with no arguments (or `-h`) for usage, or provide "play" as an argument to see a demo.

### Examples

```bash
ruby art.rb ball.png              # default chunk size
ruby art.rb cat.png 3 8           # higher resolution
ruby art.rb -h                    # usage
```

## Tips

- Looks best in a monospace font. Bitmap terminal fonts work especially well.
- If the image comes out as a photo-negative, reverse the character palette at line 5.
- High-resolution source images look better — each character averages a whole
  block of pixels, so more pixels per block means a more accurate average.
- Preprocess for more contrast if it looks flat. 

## Making it a command

Add a shebang as the first line of `art.rb`:

```ruby
#!/usr/bin/env ruby
```

Then make it executable and drop it on your PATH:

```bash
chmod +x art.rb
ln -s "$(pwd)/art.rb" ~/.local/bin/asciiart   # if ~/.local/bin is on your PATH
```

Now run it from anywhere:

```bash
asciiart ball.png
```


## How it works

1. Load the PNG.
2. Divide it into a grid of `chunk_w` x `chunk_h` pixel blocks.
3. For each block, average the brightness of its pixels using the standard luma
   formula: `0.299*R + 0.587*G + 0.114*B`.
4. Map that average (0–255) onto a character palette by density (' .:-+*#%@').
5. Print row by row.
