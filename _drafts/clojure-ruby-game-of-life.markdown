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
it suggested possibly strong benefits to a functional point-of-view.

## Simplicity: Data structures, not objects

After a few iterations with the Game of Life, I realized that all you really
need to do is to keep track of which cells are alive and what their coordinates
are. Then you have to be able to compute their neighbors (the only other cells
that could 'come to life'), and finally to check the neighbors of all candidate
cells to see if they would live in the next generation.


A
