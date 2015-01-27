---
layout: post
title:  "Functions Among Objects: Functional Code Reuse in Ruby"
tags: clojure functional-programming craftsmanship algorithms
---

In a [recent post](#), I claimed that functional programming makes it easier to
extract generic, highly reusable code. In that example, I extracted a
`filter-using-past-results` function from the domain of mathematics and applied
it to the domain of picking junior high basketball teams.

similar to EXTRACT METHOD in Ruby - extending Enumerable and Enumerator::Lazy?
But even in Ruby, involves monkey-patching classes, and probably two different implementations - one for a lazy sequence like primes and one for a non-lazy sequence like the map/hash of players - in clojure, the seq abstraction covers both

