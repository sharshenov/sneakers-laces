# frozen_string_literal: true

describe Sneakers::Laces::QueueManager, '#declare_queue' do
  subject(:declare_queue) { manager.declare_queue name: name, worker_tag: worker_tag, params: params }

  let(:manager) { described_class.new }

  after { manager.delete_queue name: name }

  context 'when no params given' do
    let(:name)        { 'queue_with_default_params' }
    let(:worker_tag)  { 'foo_worker' }
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

      let(:expected_params) do
        {
          'exclusive'   => false,
          'auto_delete' => false,
          'durable'     => true
        }
      end

      it 'has worker tag in arguments' do
        expect(queue.arguments).to eq expected_arguments
      end

      it 'has default attributes from sneakers' do
        expect(queue.slice('exclusive', 'auto_delete', 'durable')).to eq expected_params
      end

      it 'should setup binding'
    end
  end

  context 'when params given' do
    let(:name)        { 'queue_with_custom_params' }
    let(:worker_tag)  { 'foo_worker' }
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

      let(:expected_params) do
        {
          'exclusive'   => false,
          'auto_delete' => true,
          'durable'     => true
        }
      end

      it 'has worker tag in arguments' do
        expect(queue.arguments).to eq expected_arguments
      end

      it 'has default attributes from sneakers' do
        expect(queue.slice('exclusive', 'auto_delete', 'durable')).to eq expected_params
      end

      it 'should setup binding'
    end
  end
end
