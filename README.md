# rails-dtrace

The rails-dtrace gem hooks into the ActiveSupport::Notifications
instruments in Rails, turning them into DTrace probes.

## Requirements

Rails > 3.0

An OS that supports DTrace. For example:
* MacOS X
* Illumos
* SmartOS
* Solaris

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'ruby-usdt', :git => 'https://github.com/chrisa/ruby-usdt.git',
        :submodules => true, :branch => 'disable_provider'
gem 'rails-dtrace'
```

And then execute:

```bash
$ bundle
```

If you are using edge Rails (master/4.0), the notification syntax has
changed in an awesome way. In this case, you'll want the `rails_4`
branch.

```ruby
gem 'ruby-usdt', :git => 'git://github.com/chrisa/ruby-usdt.git',
        :submodules => true, :branch => 'disable_provider'
gem 'rails-dtrace', :git => 'git://github.com/sax/rails-dtrace.git',
        :branch => 'rails_4'
```

## Warning

This gem in an experiment in progress. The code does not have automated
tests, and the performance impact of ActiveSupport::Notifications
combined with ruby-usdt and libusdt are unknown. **DO NOT USE THIS IN
PRODUCTION** unless you love risk.

Also, this gem requires experimental behavior in libusdt/ruby-usdt.
Core behavior may drastically change between releases/commits of this
gem. When this is no longer the case (and I figure out how to write
tests around this gem) these warnings will disappear.

## Usage

Once you add the gem to your Rails application, it will automatically
subscribe to all notifications, turning them into DTrace probes. 

Note that notifications are lazy-loaded, so even though rails-dtrace subscribes to all available instruments, they will only be converted to probes as they fire in Rails code. For this reason, in order to get a full picture of what is happening in a Rails process, enough load should be generated to ensure that all important probes are registered before tracing.

### Rails 3

Arguments to probes are:

* `arg0` - Start time of notification - Integer
* `arg1` - End time of notification - Integer
* `arg2` - Unique identifier of notification - String
* `arg3` - Stringified hash of notification payload - String

The notification name is split to create the probe function and the probe name. For instance, `sql.active_record` becomes `ruby*:rails:sql:active_record`. This is probably far too simplistic.

The following dtrace command can be used, as an example:

```bash
sudo dtrace -n 'ruby*:rails:sql:active_record { printf("%d %d %s %s", arg0, arg1,
     copyinstr(arg2), copyinstr(arg3)) }'
```

Example output:

```
1  15407  sql:active_record 1344495838 1344495838 4595e4d30b17bdb96fe9 {:sql=>"SELECT \"things\".* FROM \"things\" ", :name=>"Thing Load", :connection_id=>70184895988280, :binds=>[]}
```


### Rails 4 / Edge Rails

Note that you need to use the `rails_4` branch in order for this to work. In newer Rails, notifications become more dtrace-like. Rather than a notification sending a message to one `call` method (that wraps start time and end time), they send two messages, `start` and `finish`. This way, you can do your own math on the notifications.

In rails-dtrace, the notification name becomes the probe function, and we map `start -> entry` and `finish -> exit`.

Arguments to probes are:

* `arg0` - Unique identifier of notification - String
* `arg1` - Stringified hash of notification payload - String

The following dtrace command can be used, as an example:

```bash
sudo dtrace -n 'ruby*:rails:sql.active_record: { printf("%s %s", copyinstr(arg0),
     copyinstr(arg1)) }'
```

Example output:

```
3  52609  sql.active_record:entry a392841cfd75a132432e
	{:sql=>"SELECT \"things\".* FROM \"things\" ", :name=>"Thing Load", :connection_id=>70362294355260, :binds=>[]}
3  52610  sql.active_record:exit a392841cfd75a132432e
	{:sql=>"SELECT \"things\".* FROM \"things\" ", :name=>"Thing Load", :connection_id=>70362294355260, :binds=>[]}
```


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Suggestions for Contributions

* How the F do you test this thing?
* Can Rails instruments be detected at initialization time to register all probes at once?
* The Responder turns the Notification payload (a hash) into a string.
  This can surely be better.

## License

Copyright (c) 2012 Eric Saxby

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

   http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
