# Ruby terminal chess
Ruby terminal chess for Odin Project.
Live Version : https://replit.com/@Saubauer/chess
## Installation
- clone repo
- run "bundle install"

## Playing

- run "bundle exec ruby main.rb", or just "ruby main.rb"
- Most of the program uses prompts which work my pressing arrow keys and enter
- In the options you can choose to change the colors to fit your terminal and
- Change the language to German if you want to.

## Notes

### Gems used
I figured, for the last ruby project I would use some gems to spice things up.
- [TTY-Toolkit](https://ttytoolkit.org)
  - Awesome toolkit for all kinds of terminal stuff, especially:
- [tty-prompt](https://github.com/piotrmurach/tty-prompt)
  - All menues are made with prompt.
- [tty-box](https://github.com/piotrmurach/tty-box)
  - Makes it easy to print different stuff all at once
- [paint](https://github.com/janlelis/paint)
  - Found this one recommended somewhere. Easy to use.
- [oj](https://github.com/ohler55/oj)
  - Also found this recommended when looking up JSON stuff.

### Thoughts
Initially, I wasn't sure about my approach. I never really played chess before, so I had a hard time wrapping my head around
the chess notations, so I just stuck with a simple grid system.
Thus, the "AI" is just a simple random move bot. I assume to make a decent AI you would have to use some kind of grandmaster-move minmax
algorithm with the algebraic notation system. Everything else "should" work.

Design wise, I think it turned out pretty well, thanks to the TTY gems.

I hope this project turned out to be somewhat competent.
