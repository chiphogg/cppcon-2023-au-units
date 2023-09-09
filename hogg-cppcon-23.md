# (Title image placeholder)

Notes:

Welcome!  As C++ programmers, we're frankly spoiled by how easy it is to handle our time quantities,
thanks to the `std::chrono` library.  Today we'll learn how to bring that same expressiveness and
robustness to **all** physical quantities.  Our new open source library, Au, makes this... more than
possible: it makes it easy.

But the talk isn't _just_ about Au.  It's really about the whole _ecosystem_ of such libraries that
people have written to meet this need.  The ecosystem has different niches.  And the libraries _in_
that ecosystem influence each other, both through competition and collaboration.  These interactions
make every participating library stronger, and it's the _entire C++ community_ who benefits.

---

## Placeholder for transition slides

Notes:

TODO: I am struggling with what to write here.  I want to try to cover the following ideas:

- Sequel to CppCon 2021 talk (whose main points I'll briefly summarize)
    - Last talk: here's what to look for (but no existing _available_ library has it).  Now you
      _can_ have nice things!
- Who is Aurora and what does "safely, quickly, broadly" mean?
- What is a units library?
    - Value proposition: catch mistakes when you _build_, at no cost when you _run_.
    - Use diagram from blog post to illustrate

I will need to figure out a good way to make it flow.

---

# C++ Units: the goal

Notes:

What are we trying to accomplish when we write a units library?  Sounds obvious: it's to provide
robust physical units support --- to make it easy and delightful to get this stuff effortlessly
correct.  Well, that's true, but it's only _part_ of the goal.

---

## All of the people, all of the time

Notes:

The _full_ goal is to do this

- for as _much of the C++ community_ as possible,
- for as much of the _time_ as possible.

Starting _right now_, because we can't affect the past anymore.  If the vertical dimension
shows the --- _very diverse_ --- community of C++ users, and the horizontal dimension shows time, we
want to cover as much of this diagram as possible with good units support.

Accurately expressing our goal is the first step to getting a chance to meet it.

Now, we can use this model to evaluate candidate solutions.  For example: shouldn't there be
a _standard units library_?  I think there should!  And I'm actively collaborating with others who
are working to make it happen on the mp-units project.  Let's see how it fits in on the diagram.

---

## Standard units library?

Notes:

The sad news is that there's literally zero chance for a standard units library before C++29.  So it
comes into play sometime around here, after a roughly six year gap.  And then it reaches various
parts of the community only gradually: it takes time to upgrade to a new standard, and some use
cases need validated toolchains, which won't even exist until years after the new standard drops.

Again: should there _be_ a standard units library?  Absolutely!  But this just makes it clear that
it can't be the _whole_ solution.

In fact, I believe that no single library can be the whole solution until _standard units_ has been
around as long as standard _chrono_.  I think the way to cover this diagram is with an _ecosystem_
of libraries.

---

## The C++ Units Library Ecosystem

Notes:

Different users have different needs.  One project needs a validated toolchain which doesn't exist
past C++14.  Another project needs robust support for C++17's `optional`, or C++20's concepts.  One
project uses `double` for everything without a second thought.  Another project runs on embedded
hardware that can only use integers.

It's difficult for any one library to satisfy all of these use cases well, if not outright
impossible.  Therefore, the ecosystem has _niches_.  It can support multiple libraries, coexisting
for extended periods of time.  _And that's good_, because the libraries are _little laboratories_
for how to handle units in C++.  We can try things out, and find out not just what works great, but
also what ideas _sound promising_ but have hidden pitfalls.

If we embrace that ecosystem viewpoint, we see the libraries interacting through both competition
and collaboration.  They can adopt each others' strengths, and learn from each others' mistakes.
This makes the whole _ecosystem_ stronger, and it meets the _community's_ needs better.
