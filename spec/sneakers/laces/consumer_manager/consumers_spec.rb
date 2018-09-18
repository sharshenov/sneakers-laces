# frozen_string_literal: true

describe Sneakers::Laces::ConsumerManager, '#consumers' do
  subject(:consumers) { manager.consumers }

  let(:queue_manager) { Sneakers::Laces::QueueManager.new }

  before do
    queue_manager.declare_queue name: 'queue1', worker_tag: 'consumer_one'
    queue_manager.declare_queue name: 'queue2', worker_tag: 'consumer_one'
    queue_manager.declare_queue name: 'queue3', worker_tag: 'consumer_two'
  end

  after do
    queue_manager.delete_queue name: 'queue1'
    queue_manager.delete_queue name: 'queue2'
    queue_manager.delete_queue name: 'queue3'
  end

  context 'when no worker classes provided' do
    let(:manager) { described_class.new }

    it { is_expected.to be_a Array }

    it 'defines sneakers consumers' do
      expect(consumers.map(&:queue_name)).to eq %w[queue1 queue2 queue3]
    end

    it 'defines consumers with proper ancestors' do
      expect(consumers.map { |c| c.new.work('args') }).to eq %w[args_one args_one args_two]
    end
  end

  context 'when custom worker classes list provided' do
    let(:manager) { described_class.new([TestConsumerOne]) }

    it { is_expected.to be_a Array }

    it 'defines sneakers consumers' do
      expect(consumers.map(&:queue_name)).to eq %w[queue1 queue2]
    end

    it 'defines consumers with proper ancestors' do
      expect(consumers.map { |c| c.new.work('args') }).to eq %w[args_one args_one]
    end
  end
end
