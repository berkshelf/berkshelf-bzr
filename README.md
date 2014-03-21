Berkshelf Bzr
============
[![Gem Version](https://badge.fury.io/rb/berkshelf-bzr.png)](http://badge.fury.io/rb/berkshelf-bzr)

Berkshelf Bzr is a Berkshelf extension that adds support for downloading cookbooks from Bazaar locations.

Installation
------------
Add this line to your application's Gemfile:

    gem 'berkshelf-bzr'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install berkshelf-bzr

Usage
-----
Activate the extension in your `Berksfile`:

```ruby
source 'https://api.berkshelf.com'
extension 'bzr'
```

Use the exposed `:bzr` key to define your sources:

```ruby
cookbook 'bacon', bzr: 'https://bitbucket.org/meats/bacon'
```

You may also specify a `ref` (see output of bzr help revisionspec):

```ruby
cookbook 'bacon', bzr: 'https://bitbucket.org/meats/bacon', ref: 'revno:7'
```

License & Authors
-----------------
- Author: David Chauviere (d_chauviere@yahoo.fr)
- Author: Seth Vargo (sethvargo@gmail.com)
- Author: Manuel Ryan (ryan@shamu.ch)

```text
Copyright 2014 David Chauviere
Copyright 2014 Seth Vargo
Copyright 2013-2014 Manual Ryan

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
