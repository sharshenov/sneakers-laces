# frozen_string_literal: true

Sneakers.configure amqp: 'amqp://localhost/sneakers_laces'

class TestConsumerOne
  include Sneakers::Laces::Worker

  from_tag :consumer_one

  def work(message)
    [message, :one].join('_')
  end
end

class TestConsumerTwo
  include Sneakers::Laces::Worker

  from_tag :consumer_two

  def work(message)
    [message, :two].join('_')
  end
end
