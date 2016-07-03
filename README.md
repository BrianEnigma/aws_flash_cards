#AWS Flash Cards

##Overview

Hi there. I'm Brian. I work for a company that got acquired by Amazon Web Services. While I've used a few of the more popular services (EC2, S3) in the past, I quickly came to realize that there were _*WAY*_ more services than I thought — many with similar or obtuse names. To help me learn, I thought I'd make some flash cards. It turns out there were more than 52 services, so I figured I'd grab enough to make a deck of playing cards. This is that deck! (Plus the scripts to generate the image assets as well as those images themselves.) I hope you enjoy!

##License

The script to generate the images for the card deck was written in 2016 by me, Brian Enigma <brian@netninja.com>. It is released under the Creative Commons Attribution-ShareAlike 4.0 International License. To view a copy of this license, visit <http://creativecommons.org/licenses/by-sa/4.0/>.

I am less sure about how the output images and deck itself can be licensed. Each card has an [AWS Simple Icon](https://aws.amazon.com/architecture/icons/) that Amazon has released without an explicit license (though they likely hold copyright on the images). Additionally, each card also has a sentence or two taken from the description of each service. So while the generator script is CC licensed, the output may or may not qualify as Fair Use, based on how transformative you'd consider the generated cards. It's probably fine for personal use, but maybe don't sell them!

##Using The Pre-Rendered Card Images

The images are pre-generated and can be found here:

- Main Cards:
    - `output/clubs-*.png`
    - `output/diamonds-*.png`
    - `output/hearts-*.png`
    - `output/spades-*.png`
- Jokers:
    - `./joker1.png`
    - `./joker2.png`
- Card Back:
    - `./reverse.png`

##Generating Card Images

**Prerequisites**

- Ruby
- The [RMagick](https://rubygems.org/gems/rmagick/) Ruby gem

**Workflow**

The data on the cards flows through several stages:

1. `cards.numbers` — This is an OS X Numbers spreadsheet. It contains the card value, suit, AWS name, AWS category, description, link to the service icon image, and various other fields. This is where the source data lives.
2. `cards.csv` — This is an export of the Numbers content to a CSV file.
3. `generate.rb` — This script reads the contents of `cards.csv`, grabs the service images from `AWS_Simple_Icons` folder, and composites everything into individual card images.
4. `./output/*.png` — The files prefixed with suit names are all of the composited images.
5. `blank.rb` — This script generates templates for the meta cards, specifically:
    - `output/blank1.png` — template for one joker
    - `output/blank2.png` — template for the other joker
    - `output/reverse.png` — template for the card backs
6. `joker1.psd`, `joker2.psd`, `reverse.ai` — Adobe files that composite text and images atop the joker and reverse templates. Export to `*.png`

##Printing    

I used [The Gamecrafter](https://www.thegamecrafter.com) for printing. The generated images are sized for their standard poker deck (825px × 1125px) and include the proper bleed and safe cut zones.
