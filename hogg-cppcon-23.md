# (Title image placeholder)

Notes:

Welcome!  As C++ programmers, we're frankly spoiled by how easy it is to handle our time quantities,
thanks to the `std::chrono` library.  Today we'll learn how to bring that same expressiveness and
robustness to **all** physical quantities.  Our new open source library, Au, makes this... well,
more than just possible; it makes it easy.

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

# Framework for choosing a units library

Notes:

Of course, this diversity can be overwhelming for end users, each of whom can only use _one_
library.  How do you choose which library is best _for you_?

As a framework for making this decision, I suggest asking the following three questions, in order.

1. First: _can you get it_ in your project?

2. Second: what does it _cost_, in terms of developer experience?

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

### C++ version compatibility

2023 ISO survey: https://isocpp.org/files/papers/CppDevSurvey-2023-summary.pdf

Make a plot for C++11,14,17,20

Align with list of new features for each version

Notes:

Each new C++ standard brings the benefits of new features, but also the cost of excluding more and
more users.

Let's start by looking at the latter.  These are the results of the 2023 ISO C++ Developer Survey
question: what C++ version can you use on your current project?  We see C++11 covers nearly 91% of
users, with C++14 close behind at 85%.  C++17 is significantly lower, at 73%, and C++20 drops off
a cliff at 29%.  So to move up a rung on this ladder and justify leaving people behind, you really
need to get some major benefit from that new version.

Now, what new features does each version bring?
- C++14 gives us more sophisticated `constexpr` functions, and `auto` return type deduction.
- C++17 brings `constexpr` if, fold expressions, and inline variables.
- C++20 has concepts, which are huge, and non-type template parameters.

By the way, already we can see why there are different niches in the C++ units library ecosystem.
C++20 concepts have a massive effect on end user interfaces: they really change the way we write
code.  If we want to design a future standard units library, we want to take full advantage of these
features!  But of course, this also excludes the wide majority of the C++ community _today_.  Thus,
there's also a separate role for a high-quality library which targets these older standards.  Again:
the ecosystem should serve as many users as possible for as much of the time as possible.

---

### Delivery mechanism

Figure ideas:

- dependency graph of small files
    - below this, figures for bazel, cmake, conan
- one long file

Notes:

The next part of "can you get it": how is the project delivered?

There are two main paradigms here.  There's "full library" delivery, where you have a DAG of
files, and users can include whichever headers they need.  Then there's the "single header"
approach, where one gigantic file contains the whole library.

The full library approach gives you more flexibility.  For example, you can have a separate header
for unit test utilities, one for I/O helpers, maybe one for each unit of measure, and so on.  The
downside is that it's more complicated to get it into your project: you need to have build target
rules expressed in _your project's_ build system, whether CMake, bazel, or something else.

The single header approach is less flexible: you get everything in the header, and nothing outside
of it.  But it makes up for that by its stunningly easy delivery: it's just one file that you put in
your project.

---

## 2. Developer experience cost

Two parts:

- Compile time penalty
- Compiler error readability

Notes:

So now we've narrowed it down to the libraries we _can_ get.  Next question: _what cost will we pay_
in terms of basic developer experience?  This is critically important to consider up front, because
these costs are reasons that people have historically chosen _not to use a units library at all_.

For units libraries, this comes in two major categories.

First, we know it will increase compile times, because the compiler is doing _more work_ to produce
the _same program_ you would have had without the units library.  That extra work, of course, goes
into catching mistakes that would otherwise produce incorrect programs.

Second, if it finds a mistake, it produces a compiler error, so: how easy are those errors to
understand and to correct?

So that's what we're looking for in a units library: it needs to take as little time as possible to
check our code, and when it finds a problem, it should explain what's wrong as clearly and concisely
as possible.

---

## 3. Units library features

Notes:

The third and final question has to do with the units library features.  And there are a **lot** to
consider!  Seriously, if you've never investigated units libraries in depth, you'll probably be
stunned by just how much differentiation there is.

This is a screenshot from our documentation page which compares several leading libraries:
basically, every library with at least as many GitHub stars as Au, plus boost units because it's
literally been around longer than GitHub.  Each column represents one of these libraries, and _each
row represents a feature_ by which they can be compared.

Good news!  We are not going to go through the entire table in this talk.  These rows are not
equally important, not by a long shot.  What we will do is pick a few, explain how Au approaches
each, and discuss how it compares to other libraries.  We'll include both strengths and weaknesses
of Au.

But remember that this is question 3 in our framework, so before we do _any_ of this, we'll
introduce the libraries we're considering, and revisit the first two questions in the context of
_these specific libraries_ .

---

# Au and alternatives

---

## Libraries considered

Notes:

We'll start with _boost units_.  This project aimed to provide a rigorous and complete solution for
units in C++.  It was written in 2007 before C++11 even existed, so it's compatible with basically
everything!  It's notable for the rigor and clarity of its documentation, and for being ahead of its
time in many ways: they were _so close_ to inventing vector space magnitudes, for example.

Next up, the nholthaus library made a splash in 2016, kickstarting the modern C++ units library
revolution.  It had the most stars of any units library in _any_ language until just last month.
This library stands out for being _extremely_ accessible and low friction --- seriously, it's just
so easy to get started and to use.

Next we have the SI library, whose amazingly inviting logo promotes a solid and user-friendly set of
APIs.  Despite being relatively newer, it has skyrocketed up the GitHub stars chart, with no sign of
slowing down.

Finally, we have mp-units, which takes full advantage of bleeding edge post-C++20 features to see
just how far we can take our interfaces.  Besides being a top-notch units library you can use
_today_, it also serves as a vehicle for designing a possible future standard units library.  And
just this year, the library underwent a _major_ overhaul with its V2 interfaces.  It's a stunning
leap forward in composability, simplicity, and power: very exciting!

There are many other options out there, but these leading libraries give a good flavor for the
comparison.

---

## 1. Can you get it?  a) C++ standard compatibility

Notes:

So, in the "can you get it" stage, question 1 of our framework, we start with the C++ standard
compatibility.  Where is each library?

No surprise here, boost is the compatibility champ, supporting all versions of C++.

I think in today's world, C++14 is a strong local optimum.  The marginal exclusion compared to C++11
is very small, but the features you gain are extremely useful for units libraries.  Both Au and
nholthaus units live here.

I think C++17 makes less sense _right this minute_.  You lose a much bigger chunk of users, but the
features you gain mostly help with implementation details, not end user interfaces.  That said,
C++17 adoption is _rapidly_ expanding, so I expect this to matter much less very soon.

C++20, where mp-units lives, excludes the majority of users, but this steep cost buys amazingly
useful features, especially concepts.

Also, keep in mind how this criterion works in practice.  When we measure exclusion, we're looking
at _all C++ projects simultaneously_.  What matters for _you_ is _your project_ only.  So for
example: if you're in the 29% that can use C++20, it doesn't matter that others are excluded; this
is a complete non-factor for _you_.

## 1. Can you get it?  b) Delivery mechanism

Show same figure as before, with logos under which category

- First click: Au logo in 2 places
- Second click: screenshot (or text box?) of manifest showing up on top

Notes:

Now for how the libraries are delivered.  boost, SI, and mp-units are delivered as full libraries,
which gives great flexibility, at the cost of more challenging setup.  nholthaus on the other hand
takes this single file approach, which makes it amazingly easy to set up, but can reduce
flexibility.  So what about Au?

**(click)**

We have the best of both worlds!  The library is composed of separate, single-purpose targets, for
those who want flexibility.  But we provide a script to package the library into a single header
file.  You can customize the precise choice of units, and toggle the infamously heavy `<iostream>`
dependency.

**(click)**

In fact, Au provides the _best_ single file solution, because it generates a manifest comment which
lists the precise release number and git commit used, the presence or absence of I/O, and the units
which were selected, bringing clarity and traceability to your repo.

We provide pre-generated single-file versions on our documentation site which include just the SI
base units.  That's why the abstract claims you can be up and running in less time than it takes to
read the abstract.  Of course, you're better off taking 10 minutes to make the custom version that
meets your needs best.

But the beauty of this hybrid approach is that you can use the single file version to get started
quickly and obtain 95% of the benefits, and then bother setting up a full install _only when you
need it_, if ever.

Full disclosure: the full installation is bazel-only for now.  We're going to need to lean on the
community for CMake support.  Pull requests welcome!

---

## 2. DevEx cost?  a) Compile times

Notes:

For compile times, we only have data for Au and nholthaus, simply because our measurement setup uses
bazel to build.  I'd really love to see a more comprehensive comparison, but this is what we have.

We took a couple files heavy on kinematics, and rewrote them idiomatically with Au, nholthaus, and
a baseline of no units library using raw `double`.  Here are the results.

**(click)**

First, the default configuration.  We can see the slowdown for both, but it's much larger for
nholthaus: always multiple seconds, and more than tripling the time for the smaller file.  This is
widely known and acknowledged.  I've seen teams at multiple companies choose _no units library_ over
nholthaus for this reason.

**(click)**

When we trim I/O support from both libraries, we do see some improvement, particularly for the
nholthaus library.

**(click)**

Finally, what makes the _biggest difference_ is **trimming unused units**.  In Au's case, this means
switching from single-file to full delivery, and only including the units used in the kinematics.
For nholthaus, this massively improves their performance.  The library has literally hundreds of
units in that single file.  Each unit is very fast to compile, but they really do add up!

But the takeaway here is that Au simply never has a severe compile time penalty.

---

## 2. DevEx cost?  b) Compiler errors

Notes:

The other reason people stop using units libraries is inscrutable compiler errors.

TODO:

- Show:
    - boost, extremely challenging
    - nholthaus, positional arguments, need to know library details to understand what unit it is
    - mp-units: concise and clear!
    - Au: similar to mp-units
- Strong types for units, pioneered by mp-units, is one of the two most significant advancements in
  C++ units libraries in the last decade (the other being vector space magnitudes)

---

# Au: core features

Notes:

Now for the third question in our framework, we can finally start evaluating units library features.
We'll emphasize those we consider the most important.  Naturally, these tend to be particular
strengths of Au.  The next section will look at some other features where we fall short.

We won't have time to compare every library on every criterion --- you can see our doc website for
that --- but we will mention other libraries where appropriate.

---

## Same program, only safer

Notes:

The first feature is to be _agnostic_ as to the _underlying numeric types_ in the program.  Some
projects just use `double` everywhere, which is fine.  But others may store their quantities in
`float`, or various integral types, which is very common in embedded applications.

The best value proposition which a units library can provide is: _same program, only safer_.  If
somebody without a units library is storing a value in some type, then we should let them use that
_same type_ under the hood.  Otherwise, we complicate their decision: to get the safety they want,
we force them to evaluate this superfluous change to their program at the same time.

With Au, it's very easy to turn an arbitrary type into a quantity.  The _name of the unit_ is
a function: you can pass it any numeric value, and get a quantity of that _same type_.  So, `6` is
an `int`; `feet(6)` is a `Quantity<Feet, int>`.

All of the libraries listed here support customizing the numeric type.  However, with nholthaus,
this isn't present in the user-facing interfaces: there's a single global type which defaults to
`double` and gets used for all quantity types.

---

## Conversion safety

chrono code goes here

```cpp
QuantityU32<Nano<Seconds>> dt = seconds(5);
```

```
error: conversion from 'Quantity<au::Seconds,int>' to non-scalar type 'Quantity<au::Nano<au::Seconds>,unsigned int>' requested
```

Notes:

Of course, being able to store integers is one thing.  What happens to them in calculations is quite
another --- especially when those calculations involve unit conversions.

We have some intuition from the chrono library here, which uses integers heavily and has a proven
track record doing so.  Let's take a duration of integer seconds.

- We can assign it to an integer _millisecond_ duration, because we know that's exact.
- We _can't_ assign it to an integer _minutes_ duration, because that could truncate!
- We _can_ assign it to a _floating point_ minutes duration, because that will be more accurate.

Any units library that is designed to support integers should follow this policy as a baseline.  The
nholthaus and SI libraries primarily have floating point applications in mind, so they silently
permit the truncation in the middle case.  Boost, mp-units, and Au all prevent it.

That said, this is only a baseline.  Consider this case in the chrono library, where we store
nanoseconds in a 32-bit integer.  We initialize it with a small number, 5 seconds.  Instead of
storing 5 billion, we find just 705 million, which is only 0.7 seconds!  Well of course we do,
because 5 billion can't fit in a 32-bit integer.  But the point is that there's another kind of risk
with integers: besides _truncation_, there's _overflow_.

The chrono library strategy for overflow is to provide user-facing types where overflow is unlikely.
Storing nanoseconds in uint32 is _not_ idiomatic chrono usage; you would use
`std::chrono::nanoseconds`, which is at least 64 bits.  But this kind of strategy doesn't scale to
a whole system of quantities, where new dimensions can get created on the fly.

**(click)**

Here's the corresponding Au code.

**(click)**

And here's the result: a compiler error.  Au knows this conversion multiplies by 1 billion, and it's
using a type whose max value is less than 5 billion.  Au considers the overflow risk too high, and
it prevents it from compiling.

---

## More conversion safety: the "safety surface"

Safety surface from blog post

Notes:

Since this is a function of both the conversion factor, and the size of the integer being used, we
can visualize this in a plot.

For each integer size, and each conversion factor, there is some smallest value that would overflow.
We prevent the conversion when that value is small enough to be "scary".  What's "scary"?  Well, we
definitely want people to feel confident using values less than 1000, because for those values they
can't jump to the next SI prefix up.  Our threshold gives some breathing room at over 2000, which
lets us support conversion factors of a million in a 32-bit signed integer.

If we trace the boundary between permitted and forbidden conversions, we get this _overflow safety
surface_.  The practical effect is that users feel empowered to choose the integer types that best
suit their program, because they know that Au is watching out for the dangerous conversions.

**(click)**

In terms of libraries, the nholthaus and SI libraries don't protect against truncation; boost and
mp-units follow the chrono library policy; and only Au has the overflow safety surface.  I would
like to see other libraries try it out in practice.

---

## Unit safety

Notes:

Here's an important principle which I love to emphasize: unit safety.

We say that a program is "unit safe" when the correct handling of physical units can be verified in
_each individual line_, by inspection, in isolation.

This is all about minimizing cognitive load.  Once you read a unit-safe line, you're done!  You know
that _if_ your program contains a unit error, then it lives somewhere else.

The way you get this is to _name_ the unit, at the _callsite_, every time you enter or exit the
units library.  So, with a height of 1.87 meters, when we say `height = meters(1.87)`, we have
_named the unit_ as we enter the library.  Our value is stored safely inside of the _quantity_,
`height`.  We know that every operation we can perform on `height` will _safeguard_ that unit
information.  And the only way to get that value out is to _name the unit_ once again.  So, let's
say we're serializing this in a protobuf.  We would call `proto.set_height_m(height.in(meters))`.
This is a "unit-safe handoff".  We don't need to see a _single other line_ of our program to know
that _this line_ handles units correctly.

Now, in fairness, I have received some pushback about this interface, and the lack of a function to
just get the underlying value without naming the unit at the callsite.  _However_, one hundred
percent of that pushback came in the _design phase_.  In the two-plus years we've been using it in
production, I haven't received a single complaint.  Not only is unit safety just not a burden, but
you come to love it!  It's hard to go back to calling `.count()` on a duration.

---

## Embedded friendliness

Notes:

I'm not an embedded programmer.  So why do I claim that our library is embedded friendly?  Because
Aurora's embedded developers have been treated as first class citizens with a seat at the table
since the beginning of the design phase.

Let's get concrete.  What makes a units library "embedded friendly"?  A few things.

- First: robust support for integer types.  Again, the library shouldn't force users to change the
  numeric types in their program just to be safer with units: don't complicate the decision!  When
  we used the nholthaus library in embedded code, it did have this effect.  Au doesn't even have
  a "default" storage type: they're all on equal footing.

- Related to integer handling: we really need that conversion safety we talked about before.  This
  should be a chrono duration-like policy at a minimum, but of course Au's overflow safety surface
  is even better.

- Finally: string handling.  `<iostream>` is an incredibly heavyweight dependency, so it needs to be
  easy to exclude it.  We provide all of our unit labels as `const char` **arrays**, not `const
  char` **pointers**, which gives us the ability to call `sizeof()` on them.  This even applies to
  compound labels that we generate automatically on the fly, such as `(m * kg) / s^2`: even these
  are stored in simple arrays.

When we talk about meeting the needs of _the entire_ C++ community, embedded developers are
a critical and often-overlooked part of that community.

---

## Composability

Notes:

Composability: this is one of my favorites.  Units almost always come from other units.  So what we
want is for the units library to let us compose units in these same ways.

We've seen that `meters` is a quantity maker: you can call it on any numeric type, and it makes
a quantity of meters.

Well, so is `meters / second`.

And `kilo(meters) / hour`.

And `meters / squared(second)`.

You can call any of these quantity makers to make a quantity.  The fluidity of combining units and
prefixes to make new units makes the library a delight to use.

Au was the only library I knew with this kind of composability for about a year, although most of
that time predates our open source release.  Happily, this is no longer the case: the V2 interfaces
of mp-units are every bit as fluently composable as Au.  I don't know of any other libraries that
come close, though.

---

## Unit-aware inverses

Notes:

Here's a fun one.  Say we have a process running at 400 Hz.  What's the period, as an integer?

Well, period is one over frequency.  But one over 400... as an _integer_... that simply truncates to
zero, right?

In seconds, yes, it does.  But we could represent this period as 2500 _microseconds_!

The key here is that if you specify the units for your result, then this _implies_ the units we
should use for 1.  We can represent 1 in different units, different _dimensionless_ units.

Solve this equation for 1: we can see that its units should be the **product** of the units for
period and frequency.  Hertz times milliseconds... that equals millionths.  One is one million
millionths.  Therefore, the program we generate under the hood will divide 400 into one million.

Here's the software API we use to express this.  `inverse_as(micro(seconds), hertz(400));`.  This
gives `micro(seconds)(2'500)`.  I haven't seen this in any other units library.  I'd like to see it
explored more.  In fact, I'd like to see it taken further --- maybe with more general _quotients_
instead of only exact inverses.  I think there's fertile ground here.

---

# Au: missing features

---

## Decibels

---

## Quantity "kind"

---

## Explicit systems

---

## Unit symbol APIs (e.g., literals)

---

# Inter-library interactions

---

## Feature inspirations

Notes:

Positive influences:
- single file (nholthaus -> Au)
- strong type units (mp-units -> Au)
- vector space magnitudes (Au -> mp-units)
- unit-safe interfaces (Au -> mp-units)
- composable units (Au before mp-units, but probably not influenced)

Negative influences:
- dimensionless convertibility to raw number (nholthaus -> Au)

Round trip conversion between percent and raw number picks up factors of 100.  Look at each
individual interface, and they are all individually reasonable!  They just interact badly.

---

## Corresponding quantity mechanism

Notes:

- Show what it is
- Mention we give this out of the box for `std::chrono::duration`

---

## nholthaus compatibility layer

---

hey don't forget to say that bazel will work out of the box

also later on, do a screenshot of the alternatives page.  Say we'll show these principles in action.

mention tutorials?  And how to develop?
