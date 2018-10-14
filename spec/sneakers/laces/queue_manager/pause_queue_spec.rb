# frozen_string_literal: true

describe Sneakers::Laces::QueueManager, '#pause_queue' do
  subject(:pause_queue) do
    manager.pause_queue name:         name,
                        worker_tag:   worker_tag
  end

  let(:manager)     { described_class.new }
  let(:name)        { 'pause-test' }
  let(:worker_tag)  { 'whatever' }

  before do
    allow(manager).to receive(:pause_routing_key).with('pause-test').and_return('pause.Base64EncodedName')

    manager.declare_queue name:         name,
                          worker_tag:   worker_tag

    allow(Sneakers::Laces).to receive(:reload)
  end

  after { manager.delete_queue name: name, worker_tag: worker_tag }

  it 'setups pause binding' do
    expect { pause_queue }.to change { pause_binding_exist? }.from(false).to(true)
  end

  it 'reloads workers' do
    pause_queue

    expect(Sneakers::Laces).to have_received(:reload).with(worker_tag: worker_tag)
  end

  def pause_binding_exist?
    bindings = Sneakers::Laces.api_client.list_queue_bindings(Sneakers::Laces.config.vhost, name)

    bindings.any? { |b| b.fetch('routing_key') == 'pause.Base64EncodedName' }
  end
end
