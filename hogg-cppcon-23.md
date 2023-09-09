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

Different users have different needs.  One project needs a specific validated toolchain which
doesn't yet exist past C++14.  Another project needs robust support for C++17's `optional`, or
C++20's concepts.  One project uses `double` for everything without a second thought.  Another
project runs on embedded hardware that can only use integers.

It's difficult for any one library to satisfy all of these use cases well, if not outright
impossible.  Therefore, the ecosystem has _niches_.  It can support multiple libraries, coexisting
for extended periods of time.  _And that's good_, because the libraries are _little laboratories_
for how to handle units in C++.  We can try things out, and find out not just what works great, but
also what ideas _sound promising_ but have hidden pitfalls.

If we embrace that ecosystem viewpoint, we see the libraries interacting through both competition
and collaboration.  They can adopt each others' strengths, and learn from each others' mistakes.
This makes the whole _ecosystem_ stronger, and it meets the _community's_ needs better.

---

# Choosing a units library

Notes:

Of course, this diversity can be overwhelming for end users.  How do you choose which library is
best _for you_?

As a framework for making this decision, I suggest asking the following three questions, in order.

1. First: _can you get it_ in your project?

2. Second: what does it do to your _basic developer experience_?

3. Third: only then do we ask, how do its "units-specific" features compare to other libraries?

---

## 1. Can you get it?

Two parts:

- C++ version compatibility
- Delivery mechanism

Notes:

We start with: "can you get it?"  By this we mean two things.  First, there's the "hard dealbreaker"
of C++ version compatibility.  Then, there's the "soft dealbreaker" of delivery mechanism, or how
you integrate the library into your project.

---

## C++ version compatibility

2023 ISO survey: https://isocpp.org/files/papers/CppDevSurvey-2023-summary.pdf

Make a plot for C++11,14,17,20

When I click, show the Au logo by C++14.

Notes:

As we go to newer C++ standards, we get nicer features, but we exclude more and more users.

We'll start with the exclusion side, which this figure illustrates.  These are the results of the
2023 ISO C++ Developer Survey question: what C++ version can you use on your current project?  We
see C++11 covers nearly 91% of users, with C++14 close behind at 85%.  C++17 is significantly lower,
at 73%, and C++20 drops off a cliff at 29%.  So to move up a rung on this ladder and justify leaving
people behind, you really need to get some major benefit from that new version.

For C++14, we got more sophisticated `constexpr` functions.  This is _huge_ for units libraries,
which want to compute all those conversion factors at compile time.  We also benefit from `auto`
return type deduction, making implementations far simpler and less error prone.  So, C++14: small
cost, big benefit.

For C++17, we benefit from `constexpr` if, fold expressions, and inline variables.  But those mostly
make life slightly easier for the **implementers**.  They don't benefit end users.  So, with tiny
benefits, but a big cost in exclusion, I don't think there _is_ a niche for a C++17 units library.

For C++20, we get a huge leap forward for _end user interfaces_, thanks to features like concepts
and non-type template parameters.  Especially concepts: you can write a function template that takes
_any length_, and _any time_.  Even though the exclusion cost of C++20 is huge, these user-facing
features mean there _is_ a niche here.  For example, if you were designing a candidate standard
units library, you would want to make full use of C++20 features, because you will obviously have
them if you succeed.  That's what mp-units is doing, and they very effectively demonstrate how these
bleeding edge features can improve end user interfaces.

**(click)**

Au lives here, at C++14.  This really is the sweet spot if you want a high quality fast, modern
library, that can reach the vast majority of users.

---

## Delivery mechanism

Figure ideas:

- dependency graph of small files
    - below this, figures for bazel, cmake, conan
- one long file

Notes:

Next: is the project delivered in a way that your project can use?

There are two main paradigms here.  There's the "full library" approach, where you have a DAG of
files, and users can include whichever headers they need.  Then there's the "single header"
approach, where one gigantic file contains the whole library.

The full library approach gives you more flexibility.  For example, you can have a separate header
for unit test utilities, one for I/O helpers, maybe several for different units, and so on.  The
downside is that it's more complicated to get it into your project: you need to have build target
rules expressed in _your project's_ build system, whether CMake, bazel, or something else.

The single header approach is less flexible: you get everything in the header, and nothing outside
of it.  But it makes up for that by its stunningly easy delivery: it's just one file that you put in
your project.  The nholthaus units library is a good example: for years, it had the most GitHub
stars of any units library _in any language_.

So what does Au choose here?

**(click)**

The best of both worlds!  We built the library out of well-defined individual targets, and you can
do a full install for maximum flexibility.  But we also provide a script to package the whole
library in one file.  You can choose which units to include, and whether or not to depend on the
infamously bulky `<iostream>` library.  **Best of all:** every single-file package includes
a _manifest comment_ at the top, which tells you which units and features were included, and _which
version of the library_ was used.  No guessing, full reproducibility!

So here's an idea for a migration path in _your_ project.  Start with the single file version, which
gives you 95% of the benefits for at most 10 minutes of setup.  Use it this way indefinitely if you
like... but if you ever want more flexibility, you can take the extra effort for a full install.

One caveat: the full install is currently bazel-only, no CMake.  We'll need to lean on the community
to add support for CMake.  Pull requests welcome!

---

hey don't forget to say that bazel will work out of the box

also later on, do a screenshot of the alternatives page.  Say we'll show these principles in action.
