# frozen_string_literal: true

describe Sneakers::Laces::QueueManager, '#list_queues' do
  subject(:list_queues) { manager.list_queues }

  let(:manager) { described_class.new }

  context 'when vhost has queues' do
    before  { manager.declare_queue name: 'foo', worker_tag: 'bar' }

    after   { manager.delete_queue name: 'foo' }

    it { is_expected.to be_a Array }

    it 'contains queues' do
      expect(list_queues.first.name).to eq 'foo'
    end
  end

  context 'when vhost has no queues' do
    it { is_expected.to eq [] }
  end

  context 'when vhost does not exist' do
    before do
      allow(manager).to receive(:vhost).and_return('invalid')
      allow(Sneakers.logger).to receive(:error)
    end

    it 'logs error' do
      list_queues
      expect(Sneakers.logger).to have_received(:error).with("Vhost 'invalid' does not exist.")
    end

    it { is_expected.to eq [] }
  end
end
