# frozen_string_literal: true

describe Sneakers::Laces::QueueManager, '#declare_queue' do
  subject(:declare_queue) do
    manager.declare_queue name:         name,
                          worker_tag:   worker_tag,
                          routing_key:  routing_key,
                          params:       params
  end

  let(:manager) { described_class.new }
  let(:bindings) { Sneakers::Laces.api_client.list_queue_bindings(Sneakers::Laces.config.vhost, name) }

  before { allow(Sneakers::Laces).to receive(:reload) }

  after { manager.delete_queue name: name, worker_tag: worker_tag }

  shared_examples 'declaring queue' do
    it 'has worker tag in arguments' do
      expect(queue.arguments).to eq expected_arguments
    end

    it 'has default attributes from sneakers' do
      expect(queue.slice('exclusive', 'auto_delete', 'durable')).to eq expected_params
    end

    it 'setups binding' do
      declare_queue

      expect(bindings.any? { |b| b.fetch('routing_key') == expected_routing_key }).to eq true
    end

    it 'reloads workers' do
      declare_queue

      expect(Sneakers::Laces).to have_received(:reload).with(worker_tag: worker_tag)
    end
  end

  context 'when no params and not routing_key given' do
    let(:name)        { 'queue_with_default_params' }
    let(:worker_tag)  { 'foo_worker' }
    let(:routing_key) { nil }
    let(:params)      { {} }

    it 'creates queue' do
      expect { declare_queue }.to change { manager.list_queues.count }.from(0).to(1)
    end

    describe 'created queue' do
      subject(:queue) do
        declare_queue
        manager.queue_info name: name
      end

      let(:expected_arguments) do
        {
          'x-worker-tag' => 'foo_worker'
        }
      end

      let(:expected_routing_key) { 'queue_with_default_params' }

      let(:expected_params) do
        {
          'exclusive'   => false,
          'auto_delete' => false,
          'durable'     => true
        }
      end

      include_examples 'declaring queue'
    end
  end

  context 'when params given' do
    let(:name)        { 'queue_with_custom_params' }
    let(:worker_tag)  { 'foo_worker' }
    let(:routing_key) { nil }
    let(:params) do
      {
        'auto_delete' => true,
        'arguments' => {
          'x-max-priority' => 10
        }
      }
    end

    it 'creates queue' do
      expect { declare_queue }.to change { manager.list_queues.count }.from(0).to(1)
    end

    describe 'created queue' do
      subject(:queue) do
        declare_queue
        manager.queue_info name: name
      end

      let(:expected_arguments) do
        {
          'x-worker-tag'    => 'foo_worker',
          'x-max-priority'  => 10
        }
      end

      let(:expected_routing_key) { 'queue_with_custom_params' }

      let(:expected_params) do
        {
          'exclusive'   => false,
          'auto_delete' => true,
          'durable'     => true
        }
      end

      include_examples 'declaring queue'
    end
  end

  context 'when routing_key given' do
    let(:name)        { 'queue_with_default_params' }
    let(:worker_tag)  { 'foo_worker' }
    let(:routing_key) { 'custom_routing_key' }
    let(:params)      { {} }

    it 'creates queue' do
      expect { declare_queue }.to change { manager.list_queues.count }.from(0).to(1)
    end

    describe 'created queue' do
      subject(:queue) do
        declare_queue
        manager.queue_info name: name
      end

      let(:expected_arguments) do
        {
          'x-worker-tag' => 'foo_worker'
        }
      end

      let(:expected_routing_key) { 'custom_routing_key' }

      let(:expected_params) do
        {
          'exclusive'   => false,
          'auto_delete' => false,
          'durable'     => true
        }
      end

      include_examples 'declaring queue'
    end
  end
end
