# Contributing To Ramaze

Everybody is welcome to contribute to Ramaze and/or the guide. This guide is
meant to be a starting point for those interested in contributing code, writing
documentation or advertising Ramaze.

## Coding Standards

* 2 spaces per indentation level for Ruby code.
* Document your code as much as you can.
* Write Bacon specifications for each change you make, especially when adding
  new features.
* Use Markdown for markup, both when documenting source code as well as when
  writing pages for the guide.
* Code should be hard wrapped at 80 characters.
* Variables and methods are ``lower_cased`` while constants such as those used
  to store version numbers use ``SCREAMING_SNAKE_CASE``. An example of this is
  ``Ramaze::VERSION``. Class names and the like are ``PascalCased``.

## Git Usage and Standards

Ramaze uses [Git][git] as it's version control system. In order to contribute to
Ramaze using Git there are a few things to keep in mind and a few standards to
follow.

### Commit Messages

Commit messages should be splitted up in two parts, a short description of the
commit in 50 characters or less. This short description should be followed by an
empty line which in turn is followed by a long description. The short
description can be seen as an Email subject while the long description would be
the actual Email body. An example of such a commit message is the following:

    Moved some chapters around.

    The chapters on helpers and logging data have been moved to their own file
    instead of being displayed in the README. Next up is writing the actual
    documentation on logging data.

    Signed-off-by: Yorick Peterse <yorickpeterse@gmail.com>

Each commit should only contain a related set of changes. If you're adding a
feature but found a bug and fixed it it's easier to keep track of changes if the
bug and the feature are divided into two separate commits (if possible). This
makes it easier to revert certain changes when needed or pick specific commits
from a branch (using ``git  cherry-pick``).

### Branching

When working on code your changes should be made in a separate branch. The name
of this branch should be related to the changes you're making and should be
short. For example, if you're working on a chapter for the guide you could name
it "documentation". Or maybe you're working on a helper, in that case you could
name it "example-helper". In the end it doesn't really matter, just keep the
length down a bit. Putting your changes in a separate branch makes it easier to
manage them and pull them into the main (master) branch.

### Pull Requests

Once you've finished working on your changes you should notify us about the
changes. The easiest way to do this is to send a pull request on Github.
Information about sending and handling pull requests can be found on the [Pull
request][pull requests] page on Github.

## Writing Documentation

The documentation (both the guides and the API documentation) use
[Markdown][markdown] as its markup engine. All the text should be written in
English. Try writing as clear as possible and remove as much spelling/grammar
errors as you can find before submitting it to Ramaze.

Linking to classes and methods can be done by wrapping the namespace/method in
``{}``:

    {Ramaze::VERSION}

If you want to link to an internal file you should use the following syntax
instead:

    {file:path/to/file Title}

Markdown files should be lower cased, spaces should be replaced with
underscores. Examples of this are ``ramaze_command.md`` and
``special_thanks.md``. Just like the Ruby code the text for the guide should be
wrapped at 80 characters.

## Spreading The Word

Maybe you're not familiar with Git or perhaps you just don't have the time to
contribute code. In both cases there are things you can do to help Ramaze grow.
The easiest way is to just tell people about it. Talk to co-workers, give
presentations or just suggest it whenever you think it could be useful for
people.

If you like to use the Ramaze logo for a presentation or something else you can
freely use the official Ramaze logo displayed below. The logo is licensed under
a [Creative Commons][cc license] license. The logo comes in two formats, a SVG
file and a PNG of which both are displayed below.

![Logo SVG][logo svg]
![Logo PNG][logo png]

[git]: http://git-scm.com/
[pull requests]: http://help.github.com/send-pull-requests/
[markdown]: http://daringfireball.net/projects/markdown/
[cc license]: http://creativecommons.org/licenses/by-sa/3.0/
[logo svg]: _static/logo.svg "The logo in SVG format"
[logo png]: _static/logo.png "The logo in PNG format"
