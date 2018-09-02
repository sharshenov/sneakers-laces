# frozen_string_literal: true

describe Sneakers::Laces, '.configure' do
  subject(:configure) do
    described_class.configure do |c|
      c.rabbitmq_api_endpoint = expected_endpoint
    end
  end

  let!(:current_endpoint) { config.rabbitmq_api_endpoint }
  let(:expected_endpoint) { 'https://foo:bar@rmq.example.com/' }
  let(:config)            { described_class.config }

  after do
    described_class.configure do |c|
      c.rabbitmq_api_endpoint = current_endpoint
    end
  end

  it 'configures Sneakers::Laces' do
    expect { configure }.to change(config, :rabbitmq_api_endpoint).from(current_endpoint).to(expected_endpoint)
  end

  it 'resets Sneakers::Laces.api_client' do
    expect { configure }.to change { described_class.api_client.endpoint }.from(current_endpoint).to(expected_endpoint)
  end
end
