# frozen_string_literal: true

describe Sneakers::Laces::WorkerManager, '#workers' do
  subject(:workers) { manager.workers }

  let(:queue_manager) { Sneakers::Laces::QueueManager.new }

  let(:workers_without_reload_worker) { workers - [Sneakers::Laces::ReloadWorker] }
  let(:reload_worker_routing_key)     { Sneakers::Laces::ReloadWorker.queue_opts[:routing_key] }

  before do
    queue_manager.declare_queue name: 'queue1', worker_tag: 'consumer_one'
    queue_manager.declare_queue name: 'queue2', worker_tag: 'consumer_one'
    queue_manager.declare_queue name: 'queue3', worker_tag: 'consumer_two'
  end

  after do
    queue_manager.delete_queue name: 'queue1', worker_tag: 'consumer_one'
    queue_manager.delete_queue name: 'queue2', worker_tag: 'consumer_one'
    queue_manager.delete_queue name: 'queue3', worker_tag: 'consumer_two'
  end

  context 'when no worker classes provided' do
    let(:manager) { described_class.new }

    it { is_expected.to be_a Array }

    it 'defines sneakers consumers' do
      expect(workers_without_reload_worker.map(&:queue_name)).to eq %w[queue1 queue2 queue3]
    end

    it 'defines consumers with proper ancestors' do
      expect(workers_without_reload_worker.map { |c| c.new.work('args') }).to eq %w[args_one args_one args_two]
    end

    it 'contains reload worker' do
      expect(workers).to include(Sneakers::Laces::ReloadWorker)
    end

    it 'configures reload worker' do
      workers
      expect(reload_worker_routing_key).to eq(['reload:consumer_one', 'reload:consumer_two'])
    end
  end

  context 'when custom worker classes list provided' do
    let(:manager) { described_class.new([TestConsumerOne]) }

    it { is_expected.to be_a Array }

    it 'defines sneakers consumers' do
      expect(workers_without_reload_worker.map(&:queue_name)).to eq %w[queue1 queue2]
    end

    it 'defines consumers with proper ancestors' do
      expect(workers_without_reload_worker.map { |c| c.new.work('args') }).to eq %w[args_one args_one]
    end

    it 'contains reload worker' do
      expect(workers).to include(Sneakers::Laces::ReloadWorker)
    end

    it 'configures reload worker' do
      workers
      expect(reload_worker_routing_key).to eq(['reload:consumer_one'])
    end
  end
end
