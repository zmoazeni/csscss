[![Build Status](https://travis-ci.org/zmoazeni/csscss.png?branch=master)](https://travis-ci.org/zmoazeni/csscss)
[![Code Climate](https://codeclimate.com/github/zmoazeni/csscss.png)](https://codeclimate.com/github/zmoazeni/csscss)

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

Note: csscss only works on ruby 1.9.x and up. It will have trouble with ruby 1.8.x.

Then you can run it in at the command line against CSS files.

    $ csscss path/to/styles.css path/to/other-styles.css

    {.contact .content .primary} and {article, #comments} share 5 rules
    {.profile-picture}, {.screenshot img} and {a.blurb img} share 4 rules
    {.work h2:first-child, .contact h2} and {body.home h2} share 4 rules
    {article.blurb:hover} and {article:hover} share 3 rules

Run it in a verbose mode to see all the duplicated styles.

    $ csscss -v path/to/styles.css

Run it against remote files by passing a valid URL.

    $ csscss -v http://example.com/css/main.css

You can also choose a minimum number of matches, which will ignore any
rulesets that have fewer matches.

    $ csscss -n 10 -v path/to/style.css # ignores rulesets with < 10 matches

If you prefer writing in [Sass](http://sass-lang.com/), you can also parse your sass/scss files.

    $ gem install sass
    $ csscss path/to/style.scss

Sass users may be interested in the `--ignore-sass-mixins`
experimental flag that won't match duplicate declarations from including mixins.

If you prefer writing in [LESS](http://lesscss.org/), you can also parse your LESS files.

    $ gem install less
    $ csscss path/to/style.less

LESS requires an additional javascript runtime.
[v8/therubyracer](https://rubygems.org/gems/therubyracer) on most
rubies, and [therubyrhino](https://rubygems.org/gems/therubyrhino) on
jruby.

## Why doesn't csscss automatically remove duplications for me? ##

I have been asked this a lot, but csscss is intentionally designed this
way. Check out [this
post](http://connectionrequired.com/blog/2013/04/why-csscss-doesnt-remove-duplication-for-you/)
for my reasoning.

## I found bugs ##

This is still a new and evolving project. I heartily welcome feedback.
If you find any issues, please report them on
[github](https://github.com/zmoazeni/csscss/issues).

Please include the smallest CSS snippet to describe the issue and the
output you expect to see.

## Who are you? ##

My name is [Zach Moazeni](https://twitter.com/zmoazeni). I work for [an
awesome company](http://www.getharvest.com/). And [we're
hiring!](http://www.getharvest.com/careers)

## I'm a dev, I can help ##

Awesome! Thanks! Here are the steps I ask:

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Make sure the tests pass (`bundle exec rake test`)
5. Push to the branch (`git push origin my-new-feature`)
6. Create new Pull Request
