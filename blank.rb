#!/usr/bin/env ruby
require "csv"
require "RMagick"

VERSION = "1.1"

WIDTH = 825
HEIGHT = 1125
SAFE_WIDTH = 669
SAFE_HEIGHT = 970
SAFE_OFFSET_X = ((WIDTH - SAFE_WIDTH) / 2).to_i
SAFE_OFFSET_Y = ((HEIGHT - SAFE_HEIGHT) / 2).to_i
COLOR_BORDER_WIDTH = 36

SHADOW_COLOR_MAP = {
    "red" => "gray40",
    "black" => "gray70",
}

def generate(bordercolor, textcolor, fieldcolor, text_string, filename)
    suit_color = textcolor
    shadow_color = SHADOW_COLOR_MAP[textcolor]
    i = Magick::Image.new(WIDTH, HEIGHT) {self.background_color = fieldcolor}
    
    # Draw border
    border = Magick::Draw.new
    border.fill = bordercolor
    border.rectangle(0, 0, WIDTH, HEIGHT)
    border.draw(i)
    border = Magick::Draw.new
    border.fill = fieldcolor
    border.roundrectangle(SAFE_OFFSET_X + COLOR_BORDER_WIDTH, SAFE_OFFSET_Y + COLOR_BORDER_WIDTH, SAFE_OFFSET_X + SAFE_WIDTH - COLOR_BORDER_WIDTH, SAFE_OFFSET_Y + SAFE_HEIGHT - COLOR_BORDER_WIDTH, 10, 10)
    border.draw(i)
    
    # Draw card number and suit
    text = Magick::Draw.new
    text.font = File.expand_path('~/Library/Fonts/DejaVuSerifCondensed-Bold.ttf')
    text.pointsize = 100
    text.gravity = Magick::NorthWestGravity
    #text.rotate(180)
    text_offset_x = 26
    text_offset_y = -10
    shadow_offset = 3
    [0, 180].each { |rotation|
        i.rotate!(rotation)
        text.annotate(i, SAFE_WIDTH, SAFE_HEIGHT, SAFE_OFFSET_X + COLOR_BORDER_WIDTH + text_offset_x + shadow_offset, SAFE_OFFSET_Y + COLOR_BORDER_WIDTH + text_offset_y + shadow_offset, text_string) {
            self.fill = shadow_color 
        }
        text.annotate(i, SAFE_WIDTH, SAFE_HEIGHT, SAFE_OFFSET_X + COLOR_BORDER_WIDTH + text_offset_x, SAFE_OFFSET_Y + COLOR_BORDER_WIDTH + text_offset_y, text_string) { 
            self.fill = suit_color 
        }
    }
    
    if (!text_string.empty?)
        #AWS Flash Cards footer
        text = Magick::Draw.new
        text.font = 'Helvetica-Narrow'
        text.pointsize = 28
        text.gravity = Magick::NorthWestGravity
        aws_flash_cards = "AWS Flash Cards\nv#{VERSION}, #{Time.new.strftime('%Y-%m-%d')}\nhttp://nja.me/awscards"
        text.annotate(i, SAFE_WIDTH, SAFE_HEIGHT, SAFE_OFFSET_X + COLOR_BORDER_WIDTH + 15, SAFE_OFFSET_Y + SAFE_HEIGHT - COLOR_BORDER_WIDTH - 84, aws_flash_cards) {
            self.fill = 'gray70' 
        }
    end
    
    i.write("output/#{filename}")
end

generate("#f8ae43", "black", "white", "Joker", "blank1.png")
generate("#444444", "red", "white", "Joker", "blank2.png")
generate("white", "red", "#444444", "", "reverse.png")

