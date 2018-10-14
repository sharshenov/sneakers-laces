# Laces for [sneakers](https://github.com/jondot/sneakers) [![Build Status](https://travis-ci.org/sharshenov/sneakers-laces.svg?branch=master)](https://travis-ci.org/sharshenov/sneakers-laces) [![Gem Version](https://badge.fury.io/rb/sneakers-laces.svg)](https://badge.fury.io/rb/sneakers-laces)

The project allows you to manage Sneakers queue processing dynamically. It uses RabbitMQ HTTP API to manage queues and utilizes [live restart](https://github.com/treasure-data/serverengine#live-restart) to reload workers.

It can be helpful for processing IO-jobs grouped by some criteria without waiting for jobs with other criterias to be executed. Imagine requesting some remote API on user basis. Requests of particular user can be executed in parallel and should not be postponed by requests of other users.

With help of the Sneakers::Laces you can declare worker classes with multiple queues per worker class. When you declare or delete a queue the worker is gracefully reloads itself without main process restart(Side effect: It is a docker-friendly solution).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'sneakers-laces'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install sneakers-laces

## Usage on consumer-side

Declare your workers and run instance
```ruby
require 'sneakers/laces'

# Be sure to configure Sneakers same way as on producer side
Sneakers.configure

class RequestAPIWorker
  include Sneakers::Laces::Worker

  from_tag :api_requester

  def work(message)
    logger.info("Doing some API request for #{message}")
    ack!
  end
end

require 'sneakers/laces/runner'

Sneakers::Laces::Runner.new.run
```

## Usage on producer-side

```ruby
require 'sneakers/laces'

# Be sure to configure Sneakers same way as on consumer side
Sneakers.configure

queue_manager = Sneakers::Laces::QueueManager.new

# This will declare queue, bindings, and send message to reload workers
queue_manager.declare_queue name: 'user_1', worker_tag: 'api_requester'
queue_manager.declare_queue name: 'user_2', worker_tag: 'api_requester'

Sneakers.publish('user 1', to_queue: 'user_1')
Sneakers.publish('user 2', to_queue: 'user_2')

# This will delete queue and send message to reload workers
queue_manager.delete_queue name: 'user_2', worker_tag: 'api_requester'

# This will pause queue by creating a extra binding and send message to reload workers
queue_manager.pause_queue name: 'user_1', worker_tag: 'api_requester'

# You still can publish to a "paused" queues
Sneakers.publish('user 1', to_queue: 'user_1')

# Make queue "processable" again
queue_manager.unpause_queue name: 'user_1', worker_tag: 'api_requester'
```

## Contributing

Bug reports and pull requests are welcome on [GitHub](https://github.com/sharshenov/sneakers-laces).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
