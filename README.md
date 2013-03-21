[![Build Status](https://travis-ci.org/zmoazeni/csscss.png?branch=master)](https://travis-ci.org/zmoazeni/csscss)

## What is it? ##

csscss will parse any CSS files you give it and let you know which
rulesets have duplicated declarations.

## What is it for? ##

One of the best strategies for me to maintain CSS is to reduce
duplication as much as possible. It's not a silver bullet, but it sure
helps.

To do that, you need to have all the rulesets in your head at all times.
That's hard, csscss is easy. Let it tell you what is redundant.

## How do I use it? ##

First you need to install it. It is currently packaged as a ruby gem:

    $ gem install csscss

Then you can run it in at the command line against CSS files.

    $ csscss path/to/styles.css path/to/other-styles.css

Run it in a verbose mode to see all the duplicated styles.

    $ csscss -v path/to/styles.css

You can also choose a minimum number of matches, which will ignore any
rulesets that have fewer matches.

    $ csscss -n 10 -v path/to/style.css # ignores rulesets with < 10 matches

## I found bugs ##

This is still a new and evolving project. I heartily welcome feedback.
If you find any issues, please report them on
[github](https://github.com/zmoazeni/csscss/issues).

Please include the smallest CSS snippet to describe the issue and the
output you expect to see.

## Who are you? ##

My name is [Zach Moazeni](https://twitter.com/zmoazeni). I work for [an
awesome company](http://www.getharvest.com/), which [is
hiring!](http://www.getharvest.com/careers).

## I'm a dev, I can help ##

Awesome! Thanks! Here are the steps I ask:

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Make sure the tests pass (`bundle exec rake test`)
5. Push to the branch (`git push origin my-new-feature`)
6. Create new Pull Request
