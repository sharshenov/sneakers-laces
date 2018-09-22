# frozen_string_literal: true

describe Sneakers::Laces::ReloadWorker, '.routing_key' do
  subject { described_class.routing_key worker_tag: 'foo' }

  it { is_expected.to eq 'reload:foo' }
end
