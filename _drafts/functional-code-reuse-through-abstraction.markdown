---
layout: post
title:  "Code Reuse Through Abstraction in Functional Programming"
tags: clojure functional-programming craftsmanship algorithms
---

I have been dabbling in functional programming, including putting a small
ClojureScript app into production, and I love it. I also love object
orientation, but I find that coding in a functional style, particularly in
Clojure, keeps things simpler and allows for elegant code reuse in a way that
is difficult in practice with objects.

Here is an example of what I mean. (If you don't already know Clojure, the
details might be confusing. Fear not brave code-smith! You should be able to
just read my descriptions, though, to get my point about code reuse through
abstraction.) I was recently working on a Project Euler problem [link], to find
the 10,001st prime number.

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
way that Clojure encourages you to create functions that could be reused easily
in other contexts - but that's a bit of an aside.

Once you think about this problem of finding prime numbers, you quickly realize
that, in order to determine if a given `candidate` is prime, you only need to
check whether it is divisible by other prime numbers. All those other checks
are waste.

So, I wanted to maintain a running list of already-discovered primes. In object
orientation, I might have maintained some inner state, but here, there is a
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

The `primes` function cannot just use `filter` anymore, because now we have to
keep track of the `known-primes`. So we basically embed an explicit filtering
operation in the `primes` function - one that builds up the `known-primes`
vector and passes it into `is-prime?` each time. We also have to use `lazy-seq`
to keep that lovely laziness `filter` provided.

And our optimization pays off:

{% highlight clojure %}
user=> (time (nth-prime 10001))
"Elapsed time: 199.918 msecs"
104743
{% endhighlight %}

Great! I noticed though, that there is a more abstract concept hiding in that
messy `primes` function - the notion of *filtering-using-past-results*. It
would be great to be able to recover the simplicity of the original `primes` by
swapping out `filter` with a function that encapsulates this new concept. What
I mean is that I would love to just write this:

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

The performance with `filter-using-past-results` is the same.

I used the previous `primes` implementation as a template, but now instead of
hard-coding `is-prime?`, we have the more general case of _any predicate
function that can accept a sequence of `past-results`_. Also, rather than
hard-coding the positive integers as the collection to be filtered, we allow
any `collection` to be passed in.

The Code ReUse Finale (Tada!)
----------

I was working in a very mathematical domain. But it was rather straightforward
to create a highly abstract function that could be useful elsewhere. For
example, when picking a middle-school 3-on-3 basketball team.

Imagine I have a bunch of players and I want to pick three for my team. I don't
want any two of them to play the same position, though. In fact, I would prefer to have less than 3 players, rather than two centers or two forwards or whatever.

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

-------

<a name="fn-bragging"><sup>1</sup></a> To give Clojure its fair share of
bragging rights, I should note that I was comparing notes with a friend coding
this up in XQuery, and his naive implementation took 59 seconds! With a bunch
of optimizations, he got that down to 8 seconds. But compiling down to Java
bytecode certainly has its benefits.
