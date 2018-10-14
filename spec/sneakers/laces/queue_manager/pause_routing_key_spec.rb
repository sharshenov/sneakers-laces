# frozen_string_literal: true

describe Sneakers::Laces::QueueManager, '#pause_routing_key' do
  subject { manager.pause_routing_key 'awesome.routing.key' }

  let(:manager) { described_class.new }

  it { is_expected.to eq 'pause.YXdlc29tZS5yb3V0aW5nLmtleQ==' }
end
