# frozen_string_literal: true

require 'sneakers/laces'
require 'pry-byebug'

Dir['./spec/support/**/*.rb'].each { |file| require file }

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups

  config.before(:suite) do
    Sneakers.configure exchange: 'sneakers_laces'
    Sneakers::Laces.api_client.create_vhost(Sneakers::Laces.config.vhost)
    Sneakers::Laces.api_client.update_permissions_of  Sneakers::Laces.config.vhost,
                                                      'guest',
                                                      write: '.*',
                                                      read: '.*',
                                                      configure: '.*'
    Sneakers::Laces.api_client.declare_exchange(Sneakers::Laces.config.vhost, 'sneakers_laces')
  end

  config.before do
    allow(Sneakers).to receive(:publish)
  end

  config.after(:suite) do
    Sneakers::Laces.api_client.delete_vhost(Sneakers::Laces.config.vhost) unless Sneakers::Laces.config.vhost == '/'
  end
end
