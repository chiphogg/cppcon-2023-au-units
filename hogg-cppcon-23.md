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

# A taste of Au

Notes:

Let's start by getting a small taste of the library.  We're going to speed through a couple of
examples, and mention some concepts and resources that will make the library _so_ easy to learn.

We won't linger here because even though this talk is about Au, the _main_ goal of the talk is to
empower you to choose the units library that best meets _your_ needs.  So we'll save more time to
that decision framework.

---

## Example: time to goal

Notes:

Let's begin with a very simple example.  We're driving at a constant speed, and we have a goal which
is some known distance away.  How much time will it take to get there?

If you don't have a units library, you'll probably do it something like this.  You've got your
variables for distance, speed, and time.  And of course you're very careful to _specify the units_:
you use these suffixes, like "m" for meters, and "mph" for miles per hour.  You also need to do your
unit conversions manually, which is tedious but straightforward.  You've probably got constants like
these in some common header file with its own unit tests.

**(click)**

Now here's what this looks like with Au.  We see some changes right off the bat.  First off, the
prefixes are _gone_, because the _library_ is doing the work.  This line here, `meters(30.0)`, takes
the value `30` and **encapsulates** it inside of a quantity.  Once it's there, it's _safe_: you can
do any _meaningful_ thing you like, but it will _prevent_ you from making mistakes with your units.

The other thing is that we can get rid of all of these conversion factors, and instead we just
directly say what we want.  The time to goal is this ratio, _as seconds_.  When we write this line,
the compiler computes the final conversion factor, a single number, _at compile time_, and correctly
multiplies it.

So there's work that we _were_ doing, manually checking units and conversion factors, and now the
compiler's doing it for us.  We can _redeploy that effort_ to more exciting problems!

---

## Example: CPU ticks time units

```cpp
// Defined in a header somewhere:
constexpr uint64_t CPU_CLOCK_HZ = 400'000'000;

std::chrono::nanoseconds elapsed_time(uint64_t num_cpu_ticks) {
    using NS_PER_TICK = std::ratio<1'000'000'000, CPU_CLOCK_HZ>;
    return std::chrono::nanoseconds{
        num_cpu_ticks * NS_PER_TICK::num / NS_PER_TICK::den
    };
}
```

```cpp
// Defined in a header somewhere:
constexpr uint64_t CPU_CLOCK_HZ = 400'000'000;

std::chrono::nanoseconds elapsed_time(uint64_t num_cpu_ticks) {
    constexpr auto cpu_ticks = inverse(hertz * mag<CPU_CLOCK_HZ>());
    return cpu_ticks(num_cpu_ticks).as(nano(seconds));
}
```

```cpp
// Defined in a header somewhere:
constexpr uint64_t CPU_CLOCK_HZ = 400'000'000;

std::chrono::nanoseconds elapsed_time(uint64_t num_cpu_ticks) {
    constexpr auto cpu_ticks = inverse(hertz * mag<CPU_CLOCK_HZ>());
    return cpu_ticks(num_cpu_ticks).coerce_as(nano(seconds));
}
```

Godbolt: https://godbolt.org/z/48vEoYjaj

Notes:

Here's another example.  This one's from the embedded domain.  Let's say we have hardware which
measures timestamps as the integer number of CPU cycles that have elapsed since startup.  Now, we
want to work with that in more familiar time units such as nanoseconds.  So we can create
a `std::ratio` to get our conversion fraction in lowest terms, and then we do the integer math of
multiplying and dividing.  This might even be right!  There's a 50% chance, but in the worst case
we'll just flip the fraction.

Now here's how we can do this with Au.  We can simply define an ad hoc time unit that corresponds to
one CPU tick.  It's the inverse of the CPU frequency, which is one hertz times this _magnitude_, mag
of CPU clock hertz.  And then we write `cpu_ticks` of `num_cpu_ticks`, which is clearly correct, and
finally, `.as` nano seconds.

This doesn't compile.  Well, of course it doesn't!  This is a truncating conversion: times 5, and
then integer-divide by 2.  If we know what we're doing, we can coerce the compiler to disregard this
safety check.

**(click)**

So, instead of dot-as, we say dot-coerce-as, and now this is correct.  And yes, Au's integer
quantity of nanoseconds will automatically convert to the `std::chrono::nanoseconds` return type.

**(click)**

If we look at the assembly in godbolt, we can see that the functions do the same thing.  It's just
that it's easier to see that the second one is correct.

And this is just a no-op change.  We could reap even more benefits by moving this unit definition
upstream in our project, and passing timestamps around our program _natively in this custom unit_!
But this is a good start.

---

## Au: Interfaces and Idioms

Notes:

We're getting a picture of the core idioms of the library.  It's built around our workhorse type
template, which is `Quantity`.  It basically "tags" a value of any numeric type with the _units_
that give that value its meaning.

`Quantity` is a _safe container_ for your value, because it guards the entry and exit.  To put your
value inside, you call a function with the name of your unit.  To get the value back out, you call
dot-in your units, which is short for "value in".  Notice the symmetry: it's as if the unit name is
a _password_ which we set when we store our value, and which we must speak to retrieve it.

For unit conversions, we use the same API, but just pass a different unit: dot-in other-units.  Of
course, this exits the safety of the library, and makes _us_ responsible for keeping track of the
units... ugh.  To stay _within the library_ when we do the conversion, we say dot-as instead of
dot-in.

"In" and "as" are vocabulary words with consistent meanings: "as" makes a quantity, and "in" makes
a raw number.  So for `std::round` we also have "round_as" and "round_in", and similar for
`std::floor` and `std::ceil`.  Note that we _definitely don't_ have `round` without a unit slot,
because this makes no sense.  Can you round your height to the nearest integer?  No --- but you can
round it to the nearest integer number of _feet_, or _centimeters_.  This principle is _unit
safety_: a core principle of Au's design, which we'll mention again later.

Finally, we have other vocabulary words that we can compose with these.  The newest one is "coerce",
which tells the compiler to ignore safety checks for truncation or overflow for when you know it's
OK to do that.  So when you see `length.coerce_as(feet)`, you'll know what it means if you learn to
speak Au.

---

## Au: learning more

Notes:

If you want to learn _by doing_, our docs are pretty good, and I especially want to emphasize two
resources.

First, we have tutorials that you can work through, including interactive exercises.  We do expect
that everyone will be able to just clone the repo and be up and running building and testing
immediately, without installing anything.

Second, we have a troubleshooting guide.  This contains examples of common Au compiler errors,
explains what they mean in plain English, and shows how to fix them.  It also includes compiler
error text from clang, gcc, and MSVC, so you can literally `Ctrl-F` on the page and start typing in
parts of your compiler error to jump to the right section.

So there we have an appetizer of sorts for the Au library.  There's much, _much_ more we could say.
But first, I want to zoom way out and get clear on the bigger picture.

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

This question considers both the C++ standard version which the library uses, and the mechanism for
delivering the library to your project.

2. Second: what does it _cost_, in terms of developer experience?

This question covers the main reasons that teams who _could_ use a units library choose _not to use
one at all_.  These are:
    a) how much does it slow down compilation?  And,
    b) how hard are the compiler errors to _understand_, and to _fix_?

3. Third question: how do its "units-specific" features compare to other libraries?

Here, there are many, _many_ considerations.  We'll only have time to touch on a few in this talk.

---

## Full comparison

Notes:

However, if you want a fuller comparison, you can check out the "alternatives" page on our
documentation website.

You can see here we have screenshots of the comparison table for each of the three questions in the
framework.  The rows represent the points of comparison, and the columns represent the units
libraries we're comparing.

So here you can see visually: the units library features in question 3 are far, _far_ more numerous
than the others.  Of course, not all rows are created equal, and the ones higher up tend to be more
important than the ones lower down, sometimes much more.

---

# Au and alternatives

Notes:

But before we get into those rows, let's introduce the columns: which units libraries we're
comparing.  Here, too, there are too many to cover, and they range from obscure hobby projects to
those that aspire to rigor and production quality.  To narrow it down to a reasonable number, we
included two categories of library.  First, there's any library with _at least as many GitHub stars_
as Au.  And second...

---

## Libraries considered

Notes:

...there's _boost units_.  We're waiving the GitHub stars requirement because this library has been
around since before work started on _creating GitHub_.  It's notable for the rigor and clarity of
its documentation, and for being ahead of its time in many ways: they were _so close_ to inventing
vector space magnitudes, for example.

Next up, the nholthaus library made a splash in 2016, kickstarting the modern C++ units library
revolution.  Until last month, it had the most GitHub stars of any units library in _any_ language.
This library's hallmark is being _extremely_ accessible and low friction --- seriously, it's just so
easy to get started and to use.

Next we have the SI library, whose amazingly inviting logo promotes a solid and user-friendly set of
APIs.  Despite being relatively newer, it has skyrocketed up the GitHub stars chart, with no sign of
slowing down.

Finally, we have mp-units, which takes full advantage of bleeding edge post-C++20 features to see
just how far we can take our interfaces.  Besides being a top-notch units library you can use
_today_, it also serves as a vehicle for designing a possible future standard units library.  And
just this year, the library underwent a _major_ overhaul with its V2 interfaces.  It's a stunning
leap forward in composability, simplicity, and power: very exciting!

Again: there are _many_ other options out there, but these leading libraries give a good flavor for
the comparison.  Now let's see our decision framework in action.

---

## 1. Can you get it?  a) C++ standard compatibility

2023 ISO survey: https://isocpp.org/files/papers/CppDevSurvey-2023-summary.pdf

Make a plot for C++11,14,17,20

Align with list of new features for each version

Notes:

For the first question --- "can you get it?" --- we start by checking C++ standard compatibility.
Each new C++ standard brings the benefits of new features, but also the cost of excluding more and
more users.

Let's start by looking at the latter.  These are the results of the 2023 ISO C++ Developer Survey
question: what C++ version can you use on your current project?  We see C++11 covers nearly 91% of
users, with C++14 close behind at 85%.  C++17 is significantly lower, at 73%, and C++20 drops off
a cliff at 29%.  So to move up a rung on this ladder and justify leaving people behind, you really
need to get some major benefit from that new version.

So where do the libraries show up on this chart?

No surprise here, boost is the compatibility champ, supporting all versions of C++.

I think in today's world, C++14 is a strong local optimum.  The marginal exclusion compared to C++11
is very small, but the features you gain are extremely useful for units libraries.  Both Au and
nholthaus units live here.

I think C++17 makes less sense _right this minute_.  On the one hand, you lose a much bigger chunk
of users.  On the other, the features you do gain mostly help with implementation details, not end
user interfaces.  That said, C++17 adoption is _rapidly_ expanding, so I expect this to matter much
less very soon.

C++20, where mp-units lives, does exclude the majority of users, but this steep cost buys amazingly
useful features, especially concepts.  And think about it: if the library's goal is to help design
a standard units library, then of course it should liberally use features from all _previous_
standards without fear.

Also, keep in mind how this criterion works in practice.  When we measure exclusion, we're looking
at _all C++ projects simultaneously_.  What matters for _you_ is _your project_ only.  So for
example: if you're in the 29% that can use C++20, it doesn't matter that others are excluded; this
is a complete non-factor for _you_.

## 1. Can you get it?  b) Delivery mechanism

Show same figure as before, with logos under which category

- First click: Au logo in 2 places
- Second click: screenshot (or text box?) of manifest showing up on top

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

**(click)**

Here's how the libraries shake out.  boost, SI, and mp-units are delivered as full libraries,
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
quickly.  You'll obtain probably 95% of the benefits.  Then you can bother setting up the full
install _only when you need it_, if ever.

Full disclosure: the full installation is bazel-only for now.  We're going to need to lean on the
community for CMake support.  Pull requests welcome!

---

## 2. DevEx cost?  a) Compile times

Notes:

Now for the _cost you pay_ in your developer experience.  We'll start with the first cost: compile
times.  We know they will increase, because the compiler is doing _more work_ to produce the _same
program_ you would have had without the units library.  That extra work, of course, goes into
catching mistakes that would otherwise produce incorrect programs.

For this, we only have data for Au and nholthaus, simply because our measurement setup uses bazel to
build.  I'd really love to see a more comprehensive comparison, but this is what we have.

We took a couple files heavy on kinematics, and rewrote them natively and idiomatically with Au,
nholthaus, and a baseline of no units library using raw `double`.  Here are the results.

**(click)**

First, the default configuration.  We can see the slowdown for both, but it's much larger for
nholthaus: always multiple seconds, and more than tripling the time for the smaller file.  This is
widely known and acknowledged.  I've seen teams at multiple companies choose _no units library_ over
nholthaus for this reason.

**(click)**

When we trim I/O support from both libraries, we do see some improvement, particularly for the
nholthaus library.

**(click)**

Finally, what makes the _biggest difference_ for both files is **trimming unused units**.  In Au's
case, this means switching from single-file to full delivery, and only including the units used in
these functions.  For nholthaus, this massively improves their performance.  The library has
literally hundreds of units in that single file.  Each unit is very fast to compile, but they really
do add up!

But the takeaway here is that even Au's worst case is competitive with any configuration of
nholthaus: Au simply never has a severe compile time penalty.

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
