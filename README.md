# Berkshelf Bzr

[![Gem Version](https://badge.fury.io/rb/berkshelf-bzr.svg)](http://badge.fury.io/rb/berkshelf-bzr) [![Build Status](https://travis-ci.org/berkshelf/berkshelf-bzr.svg?branch=master)](https://travis-ci.org/berkshelf/berkshelf-bzr) [![Code Climate](https://codeclimate.com/github/berkshelf/berkshelf-bzr.svg)](https://codeclimate.com/github/berkshelf/berkshelf-bzr)

Berkshelf Bzr is a Berkshelf extension that adds support for downloading cookbooks from Bazaar locations.

### Status

This software project is no longer under active development as it has no active maintainers. The software may continue to work for some or all use cases, but issues filed in GitHub will most likely not be triaged. If a new maintainer is interested in working on this project please come chat with us in #chef-dev on Chef Community Slack.

## Installation

Add this line to your application's Gemfile:

```
gem 'berkshelf-bzr'
```

And then execute:

```
$ bundle
```

Or install it yourself as:

```
$ gem install berkshelf-bzr
```

## Usage

Activate the extension in your `Berksfile`:

```ruby
source 'https://supermarket.chef.io'
extension 'bzr'
```

Use the exposed `:bzr` key to define your sources:

```ruby
cookbook 'mycookbook', bzr: 'lp:mycookbook'
```

You may also specify a `ref` (see output of bzr help revisionspec):

```ruby
cookbook 'mycookbook', bzr: 'lp:mycookbook', ref: 'revno:7'
```

## License & Authors

The code is an adaptation of Mercurial berkshelf's extension (<https://github.com/berkshelf/berkshelf-hg>)

- Author: David Chauviere (d_chauviere@yahoo.fr)

```text
Copyright 2014 David Chauviere

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```
