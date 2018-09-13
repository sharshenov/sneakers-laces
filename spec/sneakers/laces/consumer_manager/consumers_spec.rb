# frozen_string_literal: true

module TestModuleOne
  def work(_message)
    :module_one
  end
end

module TestModuleTwo
  def work(_message)
    :module_two
  end
end

describe Sneakers::Laces::ConsumerManager, '#consumers' do
  subject(:consumers) { manager.consumers }

  let(:manager) { described_class.new }

  let(:queue_manager) { Sneakers::Laces::QueueManager.new }

  let(:consumers_mapping) do
    {
      module_one: TestModuleOne,
      module_two: TestModuleTwo
    }
  end

  before do
    queue_manager.declare_queue name: 'queue1', worker_tag: 'module_one'
    queue_manager.declare_queue name: 'queue2', worker_tag: 'module_one'
    queue_manager.declare_queue name: 'queue3', worker_tag: 'module_two'

    allow(manager).to receive(:consumers_mapping).and_return(consumers_mapping)
  end

  after do
    queue_manager.delete_queue name: 'queue1'
    queue_manager.delete_queue name: 'queue2'
    queue_manager.delete_queue name: 'queue3'
  end

  it { is_expected.to be_a Array }

  it 'defines sneakers consumers' do
    expect(consumers.map(&:queue_name)).to eq %w[queue1 queue2 queue3]
  end

  it 'defines consumers with proper modules' do
    expect(consumers.map { |c| c.new.work('foo') }).to eq %i[module_one module_one module_two]
  end
end
