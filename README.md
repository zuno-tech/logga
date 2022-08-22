# Logga

Provides attribute logging functionality to ActiveRecord objects.

[![Gem Version](https://badge.fury.io/rb/logga.svg)](https://badge.fury.io/rb/logga)
[![CI](https://github.com/boxt/logga/actions/workflows/ci.yml/badge.svg)](https://github.com/boxt/logga/actions/workflows/ci.yml)

## Requirements

* Ruby 2.7 or above

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

Add the following to your model:

```ruby
class Thing < ApplicationRecord
  # Optional author accessor. See #author
  attr_accessor :author 

  # Association to :log_entries, which the loggable object must response to for logging.
  has_many :log_entries, as: :loggable, dependent: :destroy 

  add_log_entries_for(
    :create, # Log on object create
    :delete, # Log on object delete
    :update, # Log on object update
    allowed_fields: [], # set an array of fields allowed to be logged
    exclude_fields: [], # set an array of fields excluded from logging. Ignored if allowed_fields is set
    fields: {}, # Custom messages for fields. See #fields
    to: nil
  )
end
```

So that new `LogEntry` records attached to a given `Thing` instance will be created whenever a new one is created or
modified.

## Author

If you want to log the author of the changes you can do so by setting:

```ruby
thing.author = { id: "1", name: "Barry", type: "User" }
```

## Fields

You can override the default messages per field by using:

```ruby
add_log_entries_for(
  :update,
  fields: {
    name: lambda { |record, field, old_value, new_value|
      "Name changed from #{old_value} to #{new_value}"
    }
  }
)
```

This is with the exeception on `:created_at` which only takes the created record.

```ruby
add_log_entries_for(
  :create,
  fields: {
    created_at: lambda { |record|
      "Created object with id: #{record.id}"
    }
  }
)
```

## Configuration

Add an initializer to your project:

```ruby
Logga.configure do |config|
  enabled: true,
  excluded_fields: [], # Default array of excluded fields i.e. [:id] to ignore all :id fields for every object
  excluded_suffixes: [] # Array of excluded suffixes i.e. [:_id] to ignore all fields that end in :_id for every object
end
```

For example:

```ruby
Logga.configure do |config|
  excluded_fields: [:id], # Don't log any id changes
  excluded_suffixes: [_id] # Don't log any column that ends in _id
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/boxt/logga.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

## TODOs

- Improve the documentation
- Add migration generator for `:log_entries`
