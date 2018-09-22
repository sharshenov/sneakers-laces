# frozen_string_literal: true

describe Sneakers::Laces::QueueManager, '#delete_queue' do
  subject(:delete_queue) { manager.delete_queue name: name, worker_tag: 'whatever' }

  let(:manager) { described_class.new }
  let(:name)    { 'queue_to_delete' }

  context 'when queue exists' do
    before { manager.declare_queue name: name, worker_tag: 'whatever' }

    it 'deletes queue' do
      expect { delete_queue }.to change { manager.list_queues.count }.from(1).to(0)
    end

    it 'reloads workers' do
      allow(Sneakers::Laces).to receive(:reload)
      delete_queue
      expect(Sneakers::Laces).to have_received(:reload).with(worker_tag: 'whatever')
    end
  end

  context "when queue doesn't exist" do
    it "doesn't raise an exception" do
      expect { delete_queue }.not_to raise_error
    end

    it 'does not reload workers' do
      allow(Sneakers::Laces).to receive(:reload)
      delete_queue
      expect(Sneakers::Laces).not_to have_received(:reload)
    end
  end
end
