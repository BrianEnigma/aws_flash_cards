#!/usr/bin/env ruby
require "csv"
require "RMagick"

VERSION = "1.0"

IMAGE_BASE = './AWS_Simple_Icons_EPS-SVG_v16.2.22'
WIDTH = 825
HEIGHT = 1125
SAFE_WIDTH = 669
SAFE_HEIGHT = 970
SAFE_OFFSET_X = ((WIDTH - SAFE_WIDTH) / 2).to_i
SAFE_OFFSET_Y = ((HEIGHT - SAFE_HEIGHT) / 2).to_i
COLOR_BORDER_WIDTH = 36
SUIT_MAP = {
    "spades" => "\u2660",
    "hearts" => "\u2665",
    "clubs" => "\u2663",
    "diamonds" => "\u2666",
}
COLOR_MAP = {
    "spades" => "black",
    "hearts" => "red",
    "clubs" => "black",
    "diamonds" => "red",
}

SHADOW_COLOR_MAP = {
    "red" => "gray40",
    "black" => "gray70",
}

if ARGV.length != 1
    #print("No filename given, using cards.csv\n")
    ARGV << 'cards.csv'
end

class CardFields
    attr_reader :value, :suit, :category, :category_color, :name, :full_name, :image, :description, :long_description, :similar, :full_image
    def initialize(arr)
        # Parsed Values:
        i = 0
        @value = arr[i]; i += 1
        @suit = arr[i]; i += 1
        @category = arr[i]; i += 1
        @category_color = '#' + arr[i]; i += 1
        @name = arr[i]; i += 1
        @full_name = arr[i]; i += 1
        @image = arr[i]; i += 1
        @description = arr[i]; i += 1
        @long_description = arr[i]; i += 1
        @similar = arr[i]; i += 1

        # Cleanup
        @full_name = '' if nil == @full_name
        @similar = '' if nil == @similar
        
        # Calculated Values:
        @full_image = "#{IMAGE_BASE}/#{@category}/#{image}"
        throw "Unable to find icon file #{@full_image}" if !File.exists?(@full_image)
    end
end

def text_fit?(text, width)
  tmp_image = Magick::Image.new(width, 500)
  drawing = Magick::Draw.new
  drawing.annotate(tmp_image, 0, 0, 0, 0, text) { |txt|
    txt.gravity = Magick::NorthWestGravity
    txt.font = 'Helvetica-Narrow'
    txt.pointsize = 18
    
  }
  metrics = drawing.get_multiline_type_metrics(tmp_image, text)
  (metrics.width < width)
end

def fit_text(text, width)
  separator = ' '
  line = ''

  if not text_fit?(text, width) and text.include? separator
    i = 0
    text.split(separator).each do |word|
      if i == 0
        tmp_line = line + word
      else
        tmp_line = line + separator + word
      end

      if text_fit?(tmp_line, width)
        unless i == 0
          line += separator
        end
        line += word
      else
        unless i == 0
          line +=  '\n'
        end
        line += word
      end
      i += 1
    end
    text = line
  end
  text
end

def generate(card, filename)
    card_value = "#{card.value.upcase}#{SUIT_MAP[card.suit]}"
    p card_value
    suit_color = COLOR_MAP[card.suit]
    shadow_color = SHADOW_COLOR_MAP[suit_color]
    i = Magick::Image.new(WIDTH, HEIGHT) {self.background_color = "white"}
    
    # Draw border
    border = Magick::Draw.new
    border.fill = card.category_color
    border.rectangle(0, 0, WIDTH, HEIGHT)
    border.draw(i)
    border = Magick::Draw.new
    border.fill = 'white'
    border.roundrectangle(SAFE_OFFSET_X + COLOR_BORDER_WIDTH, SAFE_OFFSET_Y + COLOR_BORDER_WIDTH, SAFE_OFFSET_X + SAFE_WIDTH - COLOR_BORDER_WIDTH, SAFE_OFFSET_Y + SAFE_HEIGHT - COLOR_BORDER_WIDTH, 10, 10)
    border.draw(i)
    
    # Draw card number and suit
    text = Magick::Draw.new
    #text.font = File.expand_path('~/Library/Fonts/impact.ttf')
    text.font = File.expand_path('~/Library/Fonts/DejaVuSerifCondensed-Bold.ttf')
    text.pointsize = 100
    text.gravity = Magick::NorthWestGravity
    #text.rotate(180)
    text_offset_x = 10
    text_offset_y = -12
    shadow_offset = 3
    [0, 180].each { |rotation|
        i.rotate!(rotation)
        text.annotate(i, SAFE_WIDTH, SAFE_HEIGHT, SAFE_OFFSET_X + COLOR_BORDER_WIDTH + text_offset_x + shadow_offset, SAFE_OFFSET_Y + COLOR_BORDER_WIDTH + text_offset_y + shadow_offset, card_value) {
            self.fill = shadow_color 
        }
        text.annotate(i, SAFE_WIDTH, SAFE_HEIGHT, SAFE_OFFSET_X + COLOR_BORDER_WIDTH + text_offset_x, SAFE_OFFSET_Y + COLOR_BORDER_WIDTH + text_offset_y, card_value) { 
            self.fill = suit_color 
        }
    }
    
    # Draw the icon
    icon = Magick::Image.read(card.full_image) { #"#{IMAGE_BASE}/#{card.category}/#{card.image}") {
        self.density = 250
    }
    icon = icon.first
    # Apparently the following line is required to rasterize the EPS with 
    # the correct colors? Without it, I'd get weirdly inverted colors in the
    # composite function.
    icon.write("output/test.png")
    i = i.composite(icon, (WIDTH - icon.columns) / 2, 380, Magick::OverCompositeOp) {
        #self.geometry = '500x500+10+10'
    }
    
    # Draw the name
    text = Magick::Draw.new
    text.font = 'Helvetica-Narrow-Bold'
    text.pointsize = 64
    text.gravity = Magick::NorthGravity
    name = card.name
    if !card.full_name.empty?
        name << "\n#{card.full_name}"
        offset = 130
    else
        offset = 65
    end
    y = SAFE_OFFSET_Y + 130
    text.annotate(i, SAFE_WIDTH, SAFE_HEIGHT, SAFE_OFFSET_X, y, "#{name}") {
        self.fill = 'black' 
    }
    text.pointsize = 32
    text.annotate(i, SAFE_WIDTH, SAFE_HEIGHT, SAFE_OFFSET_X, y + offset, "#{card.category}") {
        self.fill = card.category_color
    }
    
    # Draw the description text
    text = Magick::Draw.new
    text.font = 'Helvetica-Narrow'
    text.pointsize = 28
    text.gravity = Magick::NorthWestGravity
    description = "#{card.long_description}"
    magic_number = 350
    description = fit_text(description, magic_number)
    description += "\nSimilar to: #{card.similar}" if !card.similar.empty?
    offset = 725
    text.annotate(i, SAFE_WIDTH - 60, SAFE_HEIGHT, SAFE_OFFSET_X + COLOR_BORDER_WIDTH + 15, offset, description) {
        self.fill = 'black'
    }
    
    #AWS Flash Cards footer
    text = Magick::Draw.new
    text.font = 'Helvetica-Narrow'
    text.pointsize = 18
    text.gravity = Magick::NorthWestGravity
    aws_flash_cards = "AWS Flash Cards\nv#{VERSION}, #{Time.new.strftime('%Y-%m-%d')}, http://nja.me/awscards\nProduced under the Creative Commons\nAttribution-ShareAlike 4.0 International License"
    text.annotate(i, SAFE_WIDTH, SAFE_HEIGHT, SAFE_OFFSET_X + COLOR_BORDER_WIDTH + 15, SAFE_OFFSET_Y + SAFE_HEIGHT - COLOR_BORDER_WIDTH - 75, aws_flash_cards) {
        self.fill = 'gray70' 
    }
    
    i.write("output/#{filename}")
end

def is_valid_card_value(value)
    valid_values = ['a','1','2','3','4','5','6','7','8','9','10','j','q','k'] #'joker']
    return (valid_values & [value.downcase]).length != 0
end

File.open(ARGV[0], 'r').each_line { |line|
    parsed = CSV::parse(line)
    next if nil == parsed || nil == parsed[0] || nil == parsed[0][0] # No usable data
    parsed = parsed[0] # Shed the outer wrapper array
    next if !is_valid_card_value(parsed[0]) # Skip the header (and any other bad values)
    values = CardFields.new(parsed)
    #p values
    generate(values, "#{values.suit}-#{values.value}.png")
}

