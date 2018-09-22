# frozen_string_literal: true

describe Sneakers::Laces::ReloadWorker, '.configure' do
  subject(:configure) { described_class.configure(worker_tags: %w[foo bar]) }

  it 'provisions ReloadWorker as Sneakers worker' do
    configure

    expect(Sneakers::Worker::Classes).to include(described_class)
  end
end
