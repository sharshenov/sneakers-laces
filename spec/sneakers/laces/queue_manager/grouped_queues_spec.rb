# frozen_string_literal: true

describe Sneakers::Laces::QueueManager, '#grouped_queues' do
  subject(:grouped_queues) { manager.grouped_queues }

  let(:manager) { described_class.new }

  before do
    manager.declare_queue name:       'queue_1',
                          worker_tag: 'foo'

    manager.declare_queue name:       'queue_2',
                          worker_tag: 'bar'

    manager.declare_queue name:       'queue_3',
                          worker_tag: 'bar'

    manager.declare_queue name:       'queue_4',
                          worker_tag: 'baz'

    Sneakers::Laces.api_client.declare_queue Sneakers::Laces.config.vhost, 'queue_5', {}
  end

  after do
    manager.delete_queue name: 'queue_1'
    manager.delete_queue name: 'queue_2'
    manager.delete_queue name: 'queue_3'
    manager.delete_queue name: 'queue_4'
    manager.delete_queue name: 'queue_5'
  end

  it 'returns queues with worker tag only' do
    expect(grouped_queues.values.flatten.map(&:name).to_set).to eq %w[queue_1 queue_2 queue_3 queue_4].to_set
  end

  it 'groups queues by worker tag' do
    expect(grouped_queues.keys.to_set).to eq %w[foo bar baz].to_set
  end
end
