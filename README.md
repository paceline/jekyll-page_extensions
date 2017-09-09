# Jekyll Page Extensions

Adds various functionalities to pages in Jekyll:
* Automatically generates print versions of pages
* Provides table of contents tag (containing links to child pages): {% toc %}
* Provides breadcrumbs tag: {% breadcrumbs %}
* Provides Rails-style link to helper: {% link_to "My Page Title" %}

## Installation

Add this line to your application's Gemfile:

    gem 'jekyll-page_extensions'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install jekyll-page_extensions

## TODO

* Avoid file not found warnings when generating print pages

## Contributing

1. Fork it ( https://github.com/paceline/jekyll-page_extensions/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
