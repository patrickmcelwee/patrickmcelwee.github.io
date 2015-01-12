---
layout: post
title:  "Quick Vim Config for Debugging Ruby"
date: 2014-01-12 07:29:00
tags: ruby vim tools testing debugging
---

When we write code, we are automating. Most obviously, we are automating
something for our customers. But there are so many levels for automation, like
layers of an onion. Business rules on the outside, moving down through
automated deployments, server provisioning, networking, application routing,
and so on, right down to everyday programmer tasks, even the keystrokes we
enter into an editor or terminal. Since we interact with our computers so
often, good optimization habits here can magnify our efficiency everywhere.

When debugging a problem in Ruby, I *often* follow the same pattern:
running and re-running[<sup>1</sup>](#fn-vimux)  a test that exercises the
code in question, while sprinkling the code with statements like this:

{% highlight ruby %}
puts "troublesome_variable: #{troublesome_variable}"
{% endhighlight %}

There are more sophisticated debugging tools, like [Pry](http://pryrepl.org/), but for quick
visibility into the behavior of my code, this little technique packs a punch.

But it is annoying and error-prone to enter the name of the
troublesome_variable twice. Eliminating this kind of boilerplate is a natural
job for a good editor. In this post, I walk through my process for building up
a Vim shortcut to handle this, but if a slow reveal doesn't interest you, you
can skip to the [end result](#end-result).

First, A Vim Macro
------------------

Macros are a convenient way to explore and record keystrokes that accomplish a
task generically enough so it can be repeated on different sections of code.
(Macros can even be [resurrected each time you start
Vim](http://vim.wikia.com/wiki/Macros#Saving_a_macro), giving them a
quasi-permanent status.)

After I decided to automate this simple debugging, I recorded a macro when
typing out the next `puts` statement. First, I positioned my cursor on the name of
the variable I wished to inspect.

To start a macro while in Vim's normal mode, type `q` followed by a second
letter that names the register into which Vim will store your keystrokes. For
example, I used the `p` registry: `qp`. Vim should now let you know at the
bottom of the editor that it is 'recording'.

Then you just do your thing, but try to use smart commands that would work, for
example, no matter how long the word is. [Vim's motion
commands](http://vimdoc.sourceforge.net/htmldoc/motion.html), combined with
[text-objects](http://blog.carbonfive.com/2011/10/17/vim-text-objects-the-definitive-guide/),
are good candidates. The relational `h`, `j`, `k`, and `l` keys are usually
poor choices.

First I copied the current word into a register (`x`) I named using the `"`
command: `"xyiw`. `yiw` 'yanks' the 'inner word' on which my cursor is
positioned into that register.[<sup>2</sup>](#fn-yanking)

Next, make a new line below the current one (`o`), and type the skeleton of the
`puts` expression that we want (`puts ": #{}"`), followed by `<esc>` to go back
to normal mode.

Now, let's jump back to the colon with `F:` and paste the variable name from
the `x` register *before* the colon with big-P (`"xP`). We have one more place to
enter it: inside the string interpolation block. So jump to the beginning of
the block with `f{` and paste the variable name again, this time after the
cursor with little-p (`"xp`). And that's it! You should see:

{% highlight ruby %}
puts "troublesome_variable: #{troublesome_variable}"
{% endhighlight %}

Hit `q` again to stop recording.

Now you can view your recorded macro, using Vim's `<Ctrl-r>`, which outputs the
content of a register. In your `.vimrc`, in insert mode, type `<Ctrl-r><Ctrl-r>p` (assuming you recorded into the `p` buffer like me.)

This should show you something like this:

    "xyiwoputs ": #{^[F:"xPf{"xp

Some cleanup is usually needed at this point, as it is here. For example, when
recording macros, Vim writes `<esc>` as `^[`. So, that has to be replaced.
Also, I use an autoclose extension, which meant that I didn't have to close the
string interpolation curly brace while typing. But in the interest of a more
generic implementation, not relying on autoclose always being there, I added
the close curly brace to the sequence of keystrokes.

So, my cleaned-up version looks like:

    "xyiwoputs ": #{}<esc>F:"xPf{"xp

Now, I just add a `nnoremap` together with my desired shortcut in normal mode:

{% highlight vim %}
nnoremap <Leader>pt "xyiwoputs ": #{}"<esc>F:"xPf{"xp 
{% endhighlight %}

So now, if I position myself over that `troublesome_variable` and enter `<Leader>pt`, I get this:

![puts a troublesome_variable]({{ site.url }}/assets/images/putsTroublesomeVariable.gif)

Variations
---------

So, that works fine when I only want to output a single variable, but often I
want to see the result of something like
`troublesome_variable.confusing_method`. For that, I need to be able to select
all the text I want to inspect first, like so:
 
![puts a method call]({{ site.url }}/assets/images/putsRandomTimesTwo.gif)

So, I can just tweak this to create a
visual mode shortcut:

{% highlight vim %}
vmap <Leader>pt "xyoputs ": #{}"<esc>F:"xPf{"xp
{% endhighlight %}

That is basically the same, except that it uses a simple yank `y` instead of
yank-a-word `yiw`.

Also, sometimes I want to `inspect` the value, so I can add `.inspect` to the skeleton:

{% highlight vim %}
nnoremap <Leader>pit "xyiwoputs ": #{.inspect}"<esc>F:"xPf{"xp 
vmap     <Leader>pit "xyoputs ": #{.inspect}"<esc>F:"xPf{"xp
{% endhighlight %}

Which allows this:

![inspect an object]({{ site.url }}/assets/images/inspectTroublesomeObject.gif)

And so on. Now you have something to build on in case you find other use cases later.

THE END RESULT
-------------

### <a name='end-result'></a>

{% highlight vim %}
" Paste into .vimrc
" Puts out value of a variable below current line
" pt = put - a handy mnemonic
nnoremap <Leader>pt  viw"xyoputs ": #{}"<esc>F:"xPf{"xp
nnoremap <Leader>pit "xyiwoputs ": #{.inspect}"<esc>F:"xPf{"xp 
vmap     <Leader>pt  "xyoputs ": #{}"<esc>F:"xPf{"xp
vmap     <Leader>pit "xyoputs ": #{.inspect}"<esc>F:"xPf{"xp
{% endhighlight %}

A Good Habit
------

I find that tackling small optimizations like this, aside from the benefit to
my productivity and increased knowledge about my editor, helps to keep me sharp
and looking for beneficial automations elsewhere. And when I get too eager
about automation, it provides a low-cost learning environment in which to start
recognizing when the cost of automation exceeds the benefits.

-------

<a name="fn-vimux"><sup>1</sup></a> using a handy [Vimux](https://github.com/benmills/vimux) shortcut

<a name="fn-yanking"><sup>2</sup></a> Actually I did something slightly less
efficient originally, entering visual mode before yanking. It was only after
looking at my recorded macro that I realized I could do the entire thing
without going into visual mode. This ability to see and analyze the recorded
macro can be a big plus.
