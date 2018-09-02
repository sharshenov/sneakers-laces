# frozen_string_literal: true

describe Sneakers::Laces::Configuration, '#rabbitmq_api_endpoint' do
  subject { configuration.rabbitmq_api_endpoint }

  let(:configuration) { described_class.new }

  let!(:rabbitmq_api_endpoint) { ENV['RABBITMQ_API_ENDPOINT'] }

  after { ENV['RABBITMQ_API_ENDPOINT'] = rabbitmq_api_endpoint }

  context 'when environment variable RABBITMQ_API_ENDPOINT is set' do
    before { ENV['RABBITMQ_API_ENDPOINT'] = 'https://foo:bar@rmq.example.com/' }

    it { is_expected.to eq 'https://foo:bar@rmq.example.com/' }
  end

  context 'when environment variable RABBITMQ_API_ENDPOINT is not set' do
    before { ENV.delete('RABBITMQ_API_ENDPOINT') }

    it { is_expected.to eq 'http://guest:guest@localhost:15672/' }
  end
end
