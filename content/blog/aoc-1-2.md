---
title: Advent of Code 2020 — Days 1–2
date: 2020-12-03
summary: Looking back over the start of AoC 2020. Comedy ensues.
tags:
    - programming
    - advent-of-code
---

It’s that time of year.
[Advent of Code](https://adventofcode.com)
is live and programmers everywhere are flexing their golfing skills on anyone bored enough to listen—and this year, I’m one of them.
I’m new to this whole thing—I
didn’t even know about AoC until 2019.

I made an attempt to get through the challenges last year in multiple languages.
I have
[working solutions](https://github.com/Starchery/advent/tree/master/2019)
for days 1 and 2 in both Python and Rust.

You’ll see something that looks like a solution for day 3 parts 1 and 2
at that link, but it’s half-baked and doesn’t work.
I got two and a half days in before I lost interest.
The puzzles themselves are great,
it was just difficult to justify spending time on them.
I intend to go back and at the *very least* finish day 3,
but the 2020 challenges have monopolized my attention.

{{< aside >}}
Also a C++ one for that I didn’t bother committing—I
just wanted to see how much C++ I could recall from memory.

Did you know there’s no `string::split` in `std`?
Like, in ~~2020~~ 2019?
I had to roll up my sleeves and write my own.
It’s a miracle C++ devs get anything done.
{{< /aside >}}

This year will be different.
I told myself
*I’m getting all 50 stars this year whether I like it or not.*
So far I’ve made it to day 4, so that’s already a marked improvement!
I’m optimistic.

## the setup

The process is the same for every day.

1. The puzzle for the day becomes available at T00:00-5:00.
2. Part 1 of the puzzle is immediately available for your reading pleasure.
3. There is sample input data that you’ll need to parse or process in some way to solve the puzzle.
4. Once you submit a working solution for part 1, part 2 is revealed. It extends part 1 in some way, adding extra requirements or throwing a wrench in the works.
5. You get a pretty star for each part you solve :)

There’s a frankly absurd amount of
[starter templates](https://github.com/Bogdanp/awesome-advent-of-code)
you can use to bootstrap a system for submitting results;
I decided to be cliche and
[write my own](https://github.com/Starchery/advent/blob/master/2020/aoc/__main__.py),
though.
I hate being beholden to the spaghetti of
others—if I have to deal with spaghetti, **it better be my own**.

Plus these “frameworks” always have some sort of problem truncating inputs.
Debugging that is the most annoying thing of all time.
Bar none.
Do not fight me on this.

The crux of my solution is `aoc/__main__.py`:

<div class="language-tag">Python</div>

```python
def main(args):
    try:
        day = "0" + args[1] if len(args[1]) == 1 else args[1]
    except IndexError:
        all_days = (day.name for day in AOC_DIR.iterdir() if "day" in day.name)
        most_recent_day = sorted(all_days, reverse=True)[0]
        day = most_recent_day[-2:]

    print_header(day)
    try:
        run(day)
    except (ImportError, NotImplementedError, AttributeError) as e:
        print(e)


if __name__ == "__main__":
    main(sys.argv)
```

I know, the error handling is incredibly robust and fault-tolerant.
This just runs the solution for the day passed in as an argument,
or the most recent day if none was given.

The `run` function is infinitely more sinister:

{{< aside >}}

You should be super suspicious of that `eval`.
It’s needed because we’re parametrizing the solver
function (`part1` or `part2`) based on the value of `part`.

This could be replaced with some funky `getattr` shenanigans,
but you know what? `eval` is simpler.
It’s okay.
It won’t hurt you.
Even `goto` is the best tool for the job sometimes.

{{< /aside >}}

<div class="language-tag">Python</div>

```python
def run(day):
    infile = AOC_DIR / f"day{day}" / "input"
    if not infile.parent.exists():
        raise NotImplementedError(f"Day {day} not yet attempted.")
    if not infile.exists():
        raise NotImplementedError(f"No input file for day {day} was found.")

    def go(part):
        solve = eval(f'__import__("day{day}").part{part}')
        solution = show(*bench(solve)(infile.open()))
        print(f"Part {part}: {solution}")

    for n in (1, 2):
        go(part=n)
```

This imports the module for the current day,
runs part 1 and part 2 for it,
benchmarks how long the solution took to calculate,
and pretty-prints the result.

That’s it.
No token juggling, frame hacks, or parsing.
Just run my code and tell me what I got!
This means when a puzzle is uploaded, I have to copy the input manually.
I survive.

## Day 1

*Spoilers ahead for days 1 and 2.*
*Shield your eyes if you want to try them out on your own.*

Day 1 was a simple filter map reduce.
Given a list of positive integers,
find two numbers that sum to 2020
and calculate their product.
You know, the kind of problem that would be a one-liner in Haskell.

<div class="language-tag">Python</div>

```python
def parse(fileobj, factory=int):
    yield from map(factory, fileobj)
```

File objects in Python are iterators over the lines in a file.
This is **super** useful for these kinds of problems.
To parse the file into a stream of integers,
just map the `int` function over the stream.
I pass in the factory as an argument,
since I imagine I’m going to be using this function a lot.

My first guess was to get the
[cartesian product](https://en.wikipedia.org/wiki/Cartesian_product)
of the numbers with themselves and pluck the first pair that sums to 2020.

<div class="language-tag">Python</div>

```python
def n_nums_that_sum_to(total, xs, n=2):
    pairs = itertools.product(xs, repeat=n)
    return next(filter(lambda ns: sum(ns) == total, pairs))
```

Translating that from English to Python turned out to be trivial.
God, I love `itertools`.
The rest is just calculating their product.
I hand-rolled my own `product` function,
only to learn later that one is already in the standard library
as `math.prod`. Oh well.

{{< aside >}}
Python really is the exact opposite of C++.
{{< /aside >}}

<div class="language-tag">Python</div>

```python
def product(xs):
    return functools.reduce(operator.mul, xs, 1)


def part1(infile, n=2):
    return product(n_nums_that_sum_to(2020, parse(infile), n))
```

This is a working implementation.

### Part 2

Part 2 is the same thing,
but now we have to find the product of **3** numbers
that sum to 2020.
Since we parametrized `part1` over the number of elements in each pair,
we can just pass in `3` instead of `2` for `n`.

<div class="language-tag">Python</div>

```python
def part2(infile):
    return part1(infile, n=3)
```

<div class="language-tag">Shell</div>

```sh
~src/advent/2020 $ python aoc 1
                Day 01
====================================
Part 1:     974304      (734.09μs)
Part 2:  236430480      (271.67ms)
```

The input is different for everybody,
but these values were accepted. Success.

### bonus

The astute (read: awake) will realize that using the cartesian product
to find two numbers that sum to 2020 is super nonsensical.
Consider the following product of two identical sets:

> A = B = {1,2}
>
> A × B = {1,2} × {1,2} = {(1,1), (1,2), (2,1), (2,2)}

Both (1,2) and (2,1) are members of the resultant set.
Addition is commutative and associative,
so checking both of these is wasteful.
What we’re really looking for is the set of unique
[combinations](https://en.wikipedia.org/wiki/Combination)
from the input data.

Because `itertools` is amazing, it includes a `combinations` function.

<div class="language-tag">Python</div>

```python
def n_nums_that_sum_to(total, xs, n=2):
    # pairs = itertools.product(xs, repeat=n)
    combos = itertools.combinations(xs, n)
    return next(filter(lambda ns: sum(ns) == total, combos))
```

This gives us a free performance boost.

<div class="language-tag">Shell</div>

```sh
~src/advent/2020 $ python aoc 1
                Day 01
====================================
Part 1:     974304      (695.47μs)
Part 2:  236430480      (99.94ms)
```

It’s still pretty damn slow for what it’s doing,[^1]
but this is what I came up with on my own, so it’s okay.[^2]
I can just blame Python if anyone asks.

---

## Day 2

Day 2 is harder to explain, but only slightly.
You get a file full of lines like this:

    1-3 a: abcde
    1-3 b: cdefg
    2-9 c: ccccccccc

You read this as:

1. The word must have `1 <= N <= 3` `a`s in it.
2. The word must have `1 <= N <= 3` `b`s in it.
3. The word must have `2 <= N <= 9` `c`s in it.

{{< aside >}}

If upon hearing this,
your mind immediately went “regex,”
congratulations, you are smarter than I.

I went the long way round. Strap in.

{{< /aside >}}

You get the picture.
Given this criteria,
find out how many passwords are considered valid.

I had a solution that was definitely right,
and I was banging my head against the wall trying to figure out why AoC wasn’t accepting it (*it was not right*).
It’s interesting to see why I made this mistake though.

### Attempt 1

My immediate thought was that each line has the same information,
just with different values.
I should make a type representing a line.

{{< aside >}}
A dataclass is the closest thing Python has to structs.

If that means nothing to you, it’s a record.

If that means nothing to you, it’s a `namedtuple` but cooler.
{{< /aside >}}

<div class="language-tag">Python</div>

```python
@dataclasses.dataclass
class Line:
    bounds: range
    letter: str
    password: str

    def is_valid(self):
        return self.password.count(self.letter) in self.bounds
```

That’s pretty much the implementation.
`s.count(c)` returns the number of occurrences of `c` in `s`.
Pretty self explanatory.

One underrated aspect of Python is how easy it is to use ranges.
I can store a range in my `dataclass` and use it for bounds checking.
Very cool.

The hard part is parsing.
Looking at the input,
I was really annoyed by all the punctuation.
The boundary is separated by a dash,
there’s a colon after the letter,
dogs and cats living together.
So I figured I should be fine just filtering out
any non-alphanumeric characters.

<div class="language-tag">Python</div>

```python
def parse(infile):
    def parse_line(line):
        # snip ...

    yield from map(
        parse_line,
        map(
            lambda line: "".join(
                c for c in line if c.isalnum()
            ),
            infile
        ),
    )
```

The double `map` is necessary since we’re mapping over
a stream of lines, and mapping over every character in every line.
This will turn

    1-3 a: abcde
    1-3 b: cdefg
    2-9 c: ccccccccc

into

    13aabcde
    13bcdefg
    29cccccccccc

So that inside `parse_line`,
I can slice the first 2 characters to get the bounds,
the next character to get the “target letter”,
and anything that remains is the password to check.

<div class="language-tag">Python</div>

```python
# snip ...
    def parse_line(line):
        # unsnip!
        min, max, letter = line[:3]
        password = line[3:]
        min, max = int(min), int(max)
        return Line(range(min, max + 1), letter, password)
# snip ...

# parse the file, take only the ones that were valid, and count em
def part1(infile):
    return len(tuple(filter(Line.is_valid, parse(infile))))
```

{{< aside >}}
The `+ 1` is needed because `range` is inclusive-exclusive.
{{< /aside >}}

This gave me an answer that *seemed* correct,
but was woefully incorrect.

The astute (read: sentient) will realize that my
“strip all non-alnum chars from each line”
idea will fail for double digit numbers.

    7-12 f: foobar

Will become

    712ffoobar

Which leads to

```python
min = 7
max = 1
letter = "2" ???
word = "ffoobar" ???
```

Cats and dogs living together. ∎

### Attempt 2

The sensible thing is to accept that this is a three-step process:

{{< aside >}}

No, the sensible thing is
`(\d+)-(\d+) (\w): (\w*)`.
But we’re well beyond that point.

{{< /aside >}}

1. Split the line on whitespace.
2. Split the first group on `'-'`
3. Remove the `':'` from the second group.

<div class="language-tag">Python</div>

```python
def parse(infile):
    def parse_line(line: str):
        bounds, letter, password = line.split()
        min, max = map(int, bounds.split("-"))
        return Line(range(min, max + 1), letter[:-1], password)

    yield from map(parse_line, infile)
```
It’s pretty cool that you can unpack
`map(int, bound.split("-"))`
into two variables at once, but I digress.

Also, the weird
`len(tuple(filter(...)))`
chain in `part1` is super unreadable.
I usually prefer to use lazy iterators for these challenges
since the data can get huge.
But a list comprehension is simply better here.

<div class="language-tag">Python</div>

```python
def part1(infile, predicate=Line.is_valid):
    return len([line for line in parsed(infile) if predicate(line)])
```

<div class="language-tag">Shell</div>

```sh
~src/advent/2020 $ python aoc 2
                Day 02
====================================
Part 1:        418      (2.14ms)
```

Cool. That works.

### Part 2

Part 2 changes the rules completely.
The new rules to determine password validity are simple.
Read this:

    1-3 a: abcde
    1-3 b: cdefg
    2-9 c: ccccccccc

as:

1. one of index 1 or index 3 in `abcde` must contain `a`: neither both nor neither.
2. one of index 1 or index 3 in `cdefg` must contain `b`: neither both nor neither.
3. one of index 2 or index 9 in `ccccccccc` must contain `c`: neither both nor neither.

The astute (read: literate) among us will realize that this corresponds to a
[logical XOR (⊕) operation](https://en.wikipedia.org/wiki/Exclusive_or).
Python has a `xor` operator built in—they pronounce it like `^`.

This is pretty simple—just add a new method to the `Line` `dataclass`.
However, **the concept of “indices” as presented in the puzzle is 1-based.**
So we need to do some math on our bounds.

{{< aside >}}

Side notes:

Yes, `^` works on `bool`s as well as `int`s.

I’ll get git diff style line highlighting working soon.

Yes, I really like nested functions.

{{< /aside >}}

<div class="language-tag">Python</div>

```python {hl_lines=["11-17", "19-22"]}
# old stuff...
@dataclasses.dataclass
class Line:
    bounds: range
    letter: str
    password: str

    def is_valid(self) -> bool:
        return self.password.count(self.letter) in self.bounds

    # SHINY NEW STUFF!
    def is_valid_new(self) -> bool:
        def is_letter_at(idx: int) -> bool:
            return self.password[idx] == self.letter

        pos1, pos2 = self.bounds.start - 1, self.bounds.stop - 2
        return is_letter_at(pos1) ^ is_letter_at(pos2)

# We parametrized part1 over the predicate function,
# so we can just pass in the new method for part2.
def part2(infile):
    return part1(infile, predicate=Line.is_valid_new)
```

<div class="language-tag">Shell</div>

```sh
~/src/advent/2020 $ python aoc 2
                Day 02
====================================
Part 1:        418      (1.35ms)
Part 2:        616      (1.48ms)
```

This is correct.
Hey, that wasn’t too bad!
Look at me, I’m a programmer!

## Reflections

The first two days weren’t bad at all.
They were challenging enough to be interesting,
while also easy enough to let me inflate my ego.

My goals for the rest of the event:

* Improve my hideous runner script

  I know I said it was no big deal having to copy-paste the inputs,
  but come on. It’s 2020. We can do better.
* Reflect every so often in a blog post like this one
* Rewrite some of the simpler puzzles in a language I’d like to learn

  Probably Rust, but maybe Typescript or Haskell. We’ll see.

And of course,

* **Get all 50 stars**.

[^1]: One interesting solution I saw was to sort the input initially.
    Work from the ends of the list inward.
    If the sum of those two numbers is > 2020,
    decrement the end pointer.
    If the sum is < 2020,
    increment the front pointer.\
    \
    This would be {O(nlogn), O(n<sup>2</sup>logn)} as opposed to my {O(n<sup>2</sup>), O(n<sup>3</sup>)} solution.

[^2]: Or, turn the input into a set.
    as you loop over the input,
    just check if `2020 - elem`
    is in the set.\
    \
    This would be {O(n), O(n<sup>2</sup>)}.
