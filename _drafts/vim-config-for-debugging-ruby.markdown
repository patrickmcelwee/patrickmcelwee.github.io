---
layout: post
title:  "Reduce Redundant Coding: Quick Vim Config for Debugging Ruby"
tags: ruby vim tools testing debugging
---

When debugging a problem in my Ruby code, I *often* follow the same pattern:
running and re-running (using a handy
[Vimux](https://github.com/benmills/vimux) shortcut) a test that exercises the
code in question, while sprinkling the code with statements like this:

    puts "troublesome_variable: #{troublesome_variable}"

There are more sophisticated debugging tools, like Pry, but for quick
visibility into the behavior of my code, this little technique packs a punch.

But it is annoying and error-prone to have to correctly enter the name of the
variable in question twice. Eliminating this kind of boilerplate is a natural
job for a good editor. I am about to walk through my process for building up a
Vim shortcut to handle this, but if a slow reveal doesn't interest you, here is
my [end result](#end-result).

First, A Vim Macro
------------------

Macros are a convenient way to explore and record keystrokes to accomplish a
task generically enough that it can be repeated on different sections of code. (They can even be [resurrected each time you start Vim](http://vim.wikia.com/wiki/Macros#Saving_a_macro), giving them a quasi-permanent status.)

After I decided to automate this simple debugging, I decided to create a macro when creating the next `puts` statement.

HERE!!

Vim shortcut to puts out a variable on next line nnoremap <Leader>pt
viw"xyoputs ": #{}"<esc>F:"xPf{"xp 
- could also illustrate putting together something simple - started with a
  macro, then had to change '^[' to <esc> and account for no autoclose
- original recorded macro: viw"xyoputs ": #{^[F:"xPf{"xp}"]}
- then I realized that I wanted to put out more than just words - so wanted to
  be able to make a custom selection. For this, I can use vmap, cutting out the
visual selection:

### <a name='end-result'></a>
    " Puts out value of a variable below current line
    "pt = put - a handy mnemonic
    nnoremap <Leader>pt viw"xyoputs ": #{}"<esc>F:"xPf{"xp
    vmap     <Leader>pt "xyoputs ": #{}"   <esc>F:"xPf{"xp

