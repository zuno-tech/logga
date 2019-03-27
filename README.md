# Logga

Provides attribute logging functionality to ActiveRecord objects.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'logga'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install logga

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

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.

To release a new version, update the version number in `version.rb`.

## Publishing to Gemfury

After setting the new version as explained above you will now need to push the new version to Gemfury. To do this carry out the following steps:

Add the Gemfury remote (you only need to do this once):

```sh
git remote add fury https://git.fury.io/boxt/logga.git
```

And then push the new code to Gemfury:

```sh
git push fury master
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ltello/logga.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

## TODOs

* Write some tests
* Improve the documentation
