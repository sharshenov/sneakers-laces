# frozen_string_literal: true

describe Sneakers::Laces, '.config' do
  subject { described_class.config }

  it { is_expected.to be_a Sneakers::Laces::Configuration }
end
