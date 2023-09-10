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

# Choosing a units library

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
APIs.  Despite being newer, it has skyrocketed up the GitHub stars chart, with no sign of slowing
down.

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

No surprise here, boost is the compatibility champ, supporting all versions.

I think in today's world, C++14 is a strong local optimum.  The marginal exclusion compared to C++11
is very small, but the features you gain are extremely useful for units libraries.  Both Au and
nholthaus units live here.

I think C++17 makes less sense.  You lose a much bigger chunk of users, but the features you gain
mostly don't impact end user interfaces.  That said, I think C++17 adoption is _rapidly_ expanding,
so I expect this to matter much less very soon.

C++20, where mp-units lives, excludes the majority of users, but this steep cost buys amazingly
useful features.  But think about what this criterion actually means.  This exclusion refers to _all
projects_, but what matters for you is _your project_.  So this is either a complete dealbreaker for
projects that can't use C++20, or a complete non-factor for projects which can.

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
We'll start with what we view as the most important.  Naturally, these tend to be particular
strengths of Au.  The next section will look at some other features where we fall short.

We won't have time to compare every library on every criterion, but we'll mention other libraries
where appropriate.

---

## Conversion safety

---

## Unit safety

---

## Embedded friendliness

Notes:

Be sure to cover:
- Don't force users to change their underlying types!  This complicates their decision.  Instead,
  make the library a pure win!
- Real-world-tested conversion safety matters here.
- Embedded were first class consumers from the beginning.  Need to be good with integers; need to
  provide unit labels as const char _array_, not just pointers!

---

## Composability

---

## Unit-aware inverses

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
