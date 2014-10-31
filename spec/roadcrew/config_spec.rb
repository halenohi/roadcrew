require 'spec_helper'

describe Roadcrew::Config do
  let(:config) { Roadcrew::Config.new }

  describe '#garage' do
    it 'ハッシュを@garagesに追加すること' do
      config.garage({ sample_name: { endpoint: 'http://example.com' } })
      expect(config.garages[:sample_name]).to eq({ endpoint: 'http://example.com' })
      config.garage({ sample_name: { endpoint: 'http://example-2.com' } })
      expect(config.garages[:sample_name]).to eq({ endpoint: 'http://example-2.com' })
    end
  end
end
