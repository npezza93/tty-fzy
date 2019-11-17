# TTY::Fzy

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'tty-fzy'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install tty-fzy

## Usage

`TTY::Fzy` can have its `tty`, `prompt`, and `lines` configured by doing the following. The current values listed are the defaults.

```ruby
TTY::Fzy.configure do |config|
  config.tty = "/dev/tty"
  config.promt = '❯ '
  config.lines = 10
end
```

To create a prompt:
```ruby
TTY::Fzy.new(choices: ['choice1', 'choice2'])
```
![Imgur](https://i.imgur.com/KNZB8Xd.gif)

Alternatively, you can pass an array of hashes to modify the choice list.
```ruby
# Same as above
TTY::Fzy.new(choices: [{ text: 'choice1' }, { text: 'choice2' }])

# The alt text will show up dimmer next to the text and wont be filterable.
TTY::Fzy.new(choices: [
  { text: 'choice1', alt: 'path' },
  { text: 'choice2', alt: 'path2' }
])

# The return text is what is returned once an option is selected. It won't be shown in the filter and cannot be searched.
TTY::Fzy.new(choices: [
  { text: 'choice1', returns: 'choice:1:1' },
  { text: 'choice2', returns: 'path2:1:1' }
])
```

![Imgur](https://i.imgur.com/w40Ac4r.gif)

Then call `call` on a `TTY::Fzy` instance to trigger the prompt and output it to the configured `output`.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/npezza93/tty-fzy. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the tty-fzy project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/npezza93/tty-fzy/blob/master/CODE_OF_CONDUCT.md).
