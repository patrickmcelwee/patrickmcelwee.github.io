---
layout: post
title:  "Code Reuse in Functional Programming"
date: 2015-01-26 22:45:00
tags: clojure functional-programming craftsmanship algorithms
---

I have been dabbling in functional programming, including a production
ClojureScript app, and I love it. I also love object orientation, but I find
that coding in a functional style keeps things simpler and allows for elegant
code reuse in a way that is more difficult with objects.

Here is an example of what I mean. I was recently working on a [Project Euler
problem](https://projecteuler.net/problem=7), to find the 10,001st prime
number.

Easy enough, with a naive implementation:

{% highlight clojure %}

(require '[clojure.math.numeric-tower :as math])

(defn not-divisible? [dividend divisor]
  (not (= (mod dividend divisor) 0)))

(defn is-prime? [candidate]
  (if (< candidate 2)
    false
    (if (= candidate 2)
      true
      (every? #(not-divisible? candidate %) (range 2 (+ 1 (math/sqrt candidate)))))))

(defn primes [] (filter is-prime? (range)))

(defn nth-prime [n]
  (nth (into [] (take n (primes))) (- n 1)))

{% endhighlight %}

That took about a half-second the first time, getting under 400 msecs once
Clojure was warmed up[<sup>1</sup>](#fn-bragging):

{% highlight clojure %}
user=> (time (nth-prime 10001))
"Elapsed time: 525.353 msecs"
104743
{% endhighlight %}

One cool thing to note is that the `primes` function generates an _infinite_
number of primes, `filter`ing over the positive integers output by `(range)`.
This is possible because `filter` and `range` are both lazy. So, in the final
`nth-prime` function, we can `take n (primes)` and no calculations will be made
except those needed to get to the `n`-th prime. This kind of laziness is one
way that Clojure encourages you to create more generic functions. I could have
coded strictly to the requirement of finding 10,000 or so primes, but it was
just as easy and efficient to create a function that will find as many primes
as you like.

Once you think about this problem of finding prime numbers, you quickly realize
that, in order to determine if a given `candidate` is prime, you only need to
check whether it is divisible by other prime numbers. All those other checks
are waste.

So, I wanted to maintain a running list of already-discovered primes. In
object-oriented mode, I might have maintained some state, but here, there is a
fairly elegant solution that just passes the values around:

{% highlight clojure %}

(defn is-prime? [candidate known-primes]
 (if (< candidate 2)
   false
   (if (= candidate 2)
     true
     (let [root (math/sqrt candidate)]
       (every? #(not-divisible? candidate %) (take-while
                                         #(< % (+ 1 root))
                                         known-primes))))))

(defn primes
  ([] (primes 2 []))
  ([n known-primes] 
   (if (is-prime? n known-primes)
     (cons n (lazy-seq (primes (inc n) (conj known-primes n))))
     (lazy-seq (primes (inc n) known-primes)))))

{% endhighlight %}

The `is-prime?` boolean function now knows about the `known-primes` and just
checks that the `candidate` is `not-divisible?` by them (up to the
square root of the `candidate`).

And our optimization pays off:

{% highlight clojure %}
user=> (time (nth-prime 10001))
"Elapsed time: 199.918 msecs"
104743
{% endhighlight %}

But the `primes` function got a whole lot more complicated! The `primes`
function cannot just use `filter` anymore, because now we have to keep track of
the `known-primes`. So I basically had to embed an explicit filtering operation
in the `primes` function - one that builds up the `known-primes` vector and
passes it into `is-prime?` each time. I also had to use `lazy-seq` to keep
that lovely laziness `filter` provided.

I noticed though, that there is a more abstract concept hiding in that messy
`primes` function - the notion of *filtering-using-past-results*. It would be
great to be able to recover the simplicity of the original `primes` by swapping
out `filter` with a function that encapsulates this new concept. I would love to just write this:

{% highlight clojure %}

(defn primes [] (filter-using-past-results is-prime? (range)))

{% endhighlight %}

Well, since functions are first-class, we can do that. Here is what
`filter-using-past-results` looks like:

{% highlight clojure %}

(defn filter-using-past-results 
  ([predicate-fn candidates] (filter-using-past-results predicate-fn candidates []))
  ([predicate-fn candidates past-results]
   (if (empty? candidates)
     []
     (let [n (first candidates) remaining (rest candidates)]
       (if (predicate-fn n past-results)
         (cons n (lazy-seq (filter-using-past-results predicate-fn
                                                      remaining
                                                      (conj past-results n))))
         (lazy-seq (filter-using-past-results predicate-fn remaining past-results)))))))

{% endhighlight %}

The performance with the extracted `filter-using-past-results` is the same as
when it was embedded in `primes`.

To write this new, rather abstract function, I used my previous `primes`
implementation as a template, but now instead of hard-coding `is-prime?`, we
have the more general case of _any predicate function that can accept a
sequence of `past-results`_. Also, rather than hard-coding the positive
integers as the collection to be filtered, we allow any `candidates` to be
passed in.[<sup>2</sup>](#fn-cheated) 

The Code ReUse Finale (Tada!)
----------

I was working in a very mathematical domain when I wrote
`filter-using-past-results`. But it was rather straightforward to create a
highly abstract function that could be useful elsewhere. For example, when
picking a middle-school 3-on-3 basketball team.

Imagine I have a bunch of players and I want to pick up to three for my team. I
don't want any two of them to play the same position, though.

So, we might have:

{% highlight clojure %}

(def player-pool [{:name "Sadie"   :position "center"}
                  {:name "Finn"    :position "forward"}
                  {:name "Sally"   :position "forward"}
                  {:name "Buster"  :position "center"}
                  {:name "Lachlan" :position "point-guard"}])

(defn should-pick? [player existing-team]
  (if (>= (count existing-team) 3)
    false
    (if (some #{(:position player)} (map :position existing-team))
      false
      true)))

(defn pick-team [pool] (filter-using-past-results should-pick? pool))

{% endhighlight %}

And it picks the team like we want:

{% highlight clojure %}
user=> (pick-team player-pool)
({:position "center", :name "Sadie"}
 {:position "forward", :name "Finn"}
 {:position "point-guard", :name "Lachlan"}) )
{% endhighlight %}

Did you see how I used `filter-using-past-results` there?? Yep, the very same
function.

Now, of course, we can extract methods when writing objects, and we could even
pull those methods out into parent classes or modules (I plan to write a
follow-up showing how to apply this pattern in a lazy, quasi-functional way in
Ruby 2.0.) But in Ruby, this kind of global re-use involves monkey-patching and
more rigid object systems (looking at you Java) may not even allow it.

In fact, most of the time, when we are writing methods within objects, we are
so constrained by the context of our object (or interface or duck type), that I
argue it is difficult to visualize the kind of widespread re-usability that is
so natural with functions.

In functional programming, particularly in Clojure, extracted functions are
immediately available for use elsewhere (so long as you include them in the
current namespace). They have broken free of the shackles of the class where
they live, and more importantly from the mental boxes we build when working
with objects. Freewheeling functions plus a small set of common data
types[<sup>3</sup>](#fn-seq) means easy and natural (ecological?) coding for
reuse.

-------

<a name="fn-bragging"><sup>1</sup></a> To give Clojure its fair share of
bragging rights, I should note that I was comparing notes with a friend coding
this up in XQuery, and his naive implementation took 59 seconds. With a bunch
of optimizations, he got that down to 8 seconds. But compiling down to Java
bytecode certainly has its benefits.

<a name="fn-cheated"><sup>2</sup></a> I also cheated and allowed for finite
collections of `candidates` - by checking to see if we have `emptied` that
collection. I realized that was a good idea only after I tried to reuse this
function on the finite collection of possible b-ball players. Again, it makes
this more generic without imposing a large cost.

<a name="fn-seq"><sup>3</sup></a> These data types in Clojure are further
united by the sequence abstraction, a wonderful thing that you can read about
in the amazingly delightful [Clojure for the Brave and
True](http://www.braveclojure.com/core-functions-in-depth/#2__The_Sequence_Abstraction).
