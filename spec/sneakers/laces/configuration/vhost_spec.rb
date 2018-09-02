# frozen_string_literal: true

describe Sneakers::Laces::Configuration, '#vhost' do
  subject { configuration.vhost }

  let(:configuration) { described_class.new }

  before { allow(Sneakers::CONFIG).to receive(:fetch).with(:vhost).and_return('awesome') }

  context 'when vhost has been configured manually' do
    before { configuration.vhost = 'custom' }

    it { is_expected.to eq 'custom' }
  end

  context 'when vhost has not been configured manually' do
    it { is_expected.to eq 'awesome' }
  end
end
