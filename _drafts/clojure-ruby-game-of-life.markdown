---
layout: post
title:  "Gaming Life with Objects and Functions"
tags: ruby clojure craftsmanship
---

I recently participated in the (Global Day of Code
Retreat)[http://coderetreat.org/] here in Durham, North Carolina. It was
inspiring to get together with other programmers interested in honing their
craft. In order to sort of take the business domain off the table, programming
pairs repeatedly code [Conway's Game of
Life](http://en.wikipedia.org/wiki/Conway%27s\_Game\_of\_Life). You change
pairs every 45 minutes, get new restrictions (like 'no conditionals'), throw
away the code you wrote, and start again. Design exploration, rather than a
working game, is the goal. This code retreat has traditionally focused on the
fundamentals of good object-oriented (OO) design.

Since the retreat was hosted by [Cognitect]() (formerly [Relevance]()), the
home of ClojureCore, and since I have recently been playing around with
Clojure, I was hoping to get a chance to explore some functional design - and I
did. In fact, my pairing session with [Clinton Driesbach](http://dreisbach.us/)
was the only one in which we effectively solved the game (minus a display, but
who needs that?!). That wasn't necessarily the goal, but given that, despite
all my experience in Ruby, I had not even come very close in my other sessions,
it suggested strong benefits to a functional approach.

## The Simplicity of Data

After a few iterations with the Game of Life, I realized that a few small
requirements would allow each new generation to be created from the previous
one (ignoring display and the initialization of a new board):

1. keep track of the coordinates of cells that are alive;
2. compute their neighbors (the only other cells that could 'come to life');
3. count their live neighbors;
4. check all candidate cells (living cells and their neighbors) for alive/dead
   status in the new generation; and
5. create a new generation containing only the living cells.

In Ruby, this usually began with creating a Board or World class, plus a Cell
class. The Board could `#generate` itself, and possibly, each Cell could do, if
it knew something about its Neighborhood (which might be another class).
Alternatively, the Board would do the computation for each candidate cell - or,
better, delegate that off to a Generator.

There are many good OO designs that would allow a reasonably changeable system.
They also might rather easily allow extension, such as adding the user
interface to initialize and display a board.

The trade-off is the complexity of that proliferation of classes, which even in
Ruby involves a fair amount of boilerplate, particularly if we are test-driving
the system.

[Different ways to solve in Ruby: The Clojure-way would be for cells and the
world to be value object (Structs) and have a Generator to do the math. An
initial OO way would be for world and cells to generate themselves (probably
with world passing self and new world to the cells, or maybe just the
live\_cells plus the new world)]

## Finally, the complexity of the simple

I loved this video. It shows what awesome and apparently complex systems can be
assembled using the extremely simple rules of the Game of Life. If Clojure
helps us to find simpler rules to create our increasingly huge software
monstrosities, awesome!
<iframe width="560" height="315" src="//www.youtube.com/embed/C2vgICfQawE"
frameborder="0" allowfullscreen></iframe>
