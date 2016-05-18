# BarkingIguana::CacheBucket

Provides a naive but easy to set up cache with time based expiry.

Time based expiry in implemented as a maximum age that the cached objects _may_
reach. It's not a guarantee that the objects _will_ live that long.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'barking_iguana-cache_bucket'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install barking_iguana-cache_bucket

## Usage

Most likely you'll want to use the DSL in your class:

```ruby
require 'barking_iguana/cache_bucket'

class Thing
  include BarkingIguana::CacheBucket::DSL

  def expensive_operation
    cache_bucket.get 'expensive_operation' do
      object_id
    end
  end
end
```

**BEWARE!** The cache will persist across instances of the class:

```ruby
# Create two new instances of the class
t1 = Thing.new
t2 = Thing.new

# These have different object ids:
t1.object_id #=> 70248246472260
t2.object_id #=> 70248259056820

# But the same value is returned from both:
t1.expensive_operation #=> 70248246472260
t2.expensive_operation #=> 70248246472260
```

If you need `CacheBucket`s that are scoped to instances you should use a
`prefix`:

```ruby
class ScopedThing
  include BarkingIguana::CacheBucket::DSL

  def expensive_operation
    cache_bucket.get 'expensive_operation', prefix: "instance_#{id}" do
      object_id
    end
  end
end

# Create two new instances of the class
s1 = ScopedThing.new
s2 = ScopedThing.new

# These have different object ids:
s1.object_id #=> 70248246472260
s2.object_id #=> 70248259056820

# Now a different value is returned from both:
s1.expensive_operation #=> 70248246472260
s2.expensive_operation #=> 70248259056820
```

### Configuration

You may configure a few things about the behaviour of the `CacheBucket`s.

#### Logging

```ruby
BarkingIguana::CacheBucket.logger = Logger.new($stdout)
```

It logs at `Logger::DEBUG`, so you won't see very much unless you crank the log
level of your logger _way_ up.

#### Cache Horizon

The default is 3600 seconds - one hour. You can set it to any number of seconds
though. Please note that I only support integer numbers of seconds.

```ruby
BarkingIguana::CacheBucket.maximum_age = 7200
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/barking_iguana/cache_bucket.

