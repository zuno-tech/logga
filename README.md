# Logga

Provides attribute logging functionality to ActiveRecord objects.

## Requirements

Requires Ruby 2.7.2 or above
## Installation

Add this line to your application's Gemfile:

```ruby
gem 'logga'
```

And then execute:

```sh
bundle
```

Or install it yourself as:

```sh
gem install logga
```

## Usage

Add this to your model:

```ruby
class Order < ApplicationRecord
  add_log_entries_for :create, :update
end
```

So that new LogEntry records attached to a given Order instance will be created whenever a new one is created or
modified.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.

## Versioning

The version of the gem should be set in the `VERSION` file found in the root of the project. This is then read by the `lib/boxt_aasm_ext/version.rb` file to set in the gem.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/boxt/logga.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

## TODOs

- Write some tests
- Improve the documentation
