# frozen_string_literal: true

describe Sneakers::Laces, '.api_client' do
  subject(:api_client) { described_class.api_client }

  let!(:current_endpoint) { described_class.config.rabbitmq_api_endpoint }

  before  { described_class.configure { |c| c.rabbitmq_api_endpoint = 'https://foo:bar@rmq.example.com/' } }

  after   { described_class.configure { |c| c.rabbitmq_api_endpoint = current_endpoint } }

  it { is_expected.to be_a RabbitMQ::HTTP::Client }

  it 'has proper endpoint' do
    expect(api_client.endpoint).to eq 'https://foo:bar@rmq.example.com/'
  end
end
