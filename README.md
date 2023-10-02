# CppCon 2023: Talk Slides

This repo is the source code for the slides for Chip Hogg's 2023 CppCon presentation, "The Au
library: handling physical units safely, quickly, and broadly".  See the [abstract].

## How to view

You can [view the slides online](https://chogg.name/cppcon-2023-au-units/).  Use the typical
controls for a `reveal.js` presentation.  In particular:

- `s` brings up the absurdly detailed speaker notes
- `f` makes the presentation fullscreen
- `Esc` gives easy navigation
- `j`/`k` or arrow keys navigate the slides

### Local checkout option

This isn't necessary if you just want to view --- the above link should be enough for that.  But if
it's not working, or if you want to play around with the slides, you can follow these steps.

```sh
git clone https://github.com/chiphogg/cppcon-2023-au-units.git
cd cppcon-2023-au-units
git submodule init
git submodule update
python -m http.server
```

(For that last step, any local HTTP server will do.)

Then, just open up the listed URL in your browser!

[abstract]: https://cppcon2023.sched.com/event/1Qtfk/the-au-library-handling-physical-units-safely-quickly-and-broadly
