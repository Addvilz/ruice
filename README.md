# Ruice

> Where my dependencies at, fam?
>
> \- *Me, a minor Ruby hater*

Ruice is a DIC container implemented in less than 150 lines of Ruby code.

It allows for:

- Automatic injection in instance props
- Configuration properties
- Autowiring by class name

## Development status

I literally wrote this in 12 minutes. Are you mad?

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'ruice'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install ruice

## Usage

```ruby

class DependencyA
end

class InjectionPoint
  def initialize
    @dependency_a = Ruice::Dependency.new DependencyA
    @property = Ruice::Property 'my.config.property'
    @env = Ruice::Property 'env'
  end
  
  def dic_ready
    # Method always invoked when @injected props have been replaced
  end
  
  def something
    @dependency # Instance of DependencyA
    @property # 'FooBar'
    @env # 'production'
  end
end

container = Ruice::Container.new(
  {
    my: {
      config: {
        property: 'FooBar'
      }
    }
  },
  'production'
)

# Register dependency by class
container.with(Logger, proc {
  Logger.new('/dev/null')
})

# Register dependency by name

container.with('my_logger', proc {
  Logger.new('/dev/null')
})

# Automatically created instance
injection_point = container.request InjectionPoint

# Instance of by class Logger
logger = container.request Logger

# Instance of by name Logger
logger = container.request 'my_logger' 

```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/Addvilz/ruice.

## License

The gem is available as open source under the terms of the [Apache 2.0 License](https://www.apache.org/licenses/LICENSE-2.0).
