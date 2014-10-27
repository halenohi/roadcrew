require 'spec_helper'

describe Roadcrew::Client do
  class SimpleModel
    include Roadcrew::Client
  end
  let!(:model) { SimpleModel.new(id: 32, title: 'Sample Title', date: Date.parse('2013-06-29')) }
  let(:connection) { double 'connection' }

  before do
    SimpleModel.instance_variables.each do |var|
      SimpleModel.instance_variable_set(var, nil) if [:@base_path, :@client].include? var
    end
    Roadcrew.configure do
      garage sample_garage: {
        endpoint: 'http://example.com'
      }
    end
  end

  describe '.garage' do
    it '指定したgarageの@garage_clientが設定されること' do
      expect(Roadcrew::Connection).to receive(:new).with(endpoint: 'http://example.com') { connection }
      SimpleModel.garage :sample_garage
      expect(SimpleModel.garage_client).to eq connection
    end
  end

  describe '.base_path' do
    it '@base_pathに保存すること' do
      expect(SimpleModel.base_path).to eq '/simple_models'
      SimpleModel.base_path('/users')
      expect(SimpleModel.base_path).to eq '/users'
    end
  end

  describe '.build_path' do
    it '正しいパスを返すこと' do
      expect(SimpleModel.build_path).to eq '/simple_models'
      SimpleModel.base_path('/posts')
      expect(SimpleModel.build_path).to eq '/posts'
      expect(SimpleModel.build_path('12')).to eq '/posts/12'
    end
  end

  context 'REST actions' do
    before do
      SimpleModel.garage :sample_garage
      SimpleModel.base_path '/news'
      model.id = 32
      model.title = 'Sample Title'
      model.date = Date.parse '2013-06-28'
    end

    describe '.find' do
      it '@clientで正しい通信をすること' do
        expect(SimpleModel.garage_client).to receive(:get).with('/news/11')
        SimpleModel.find(11)
      end
    end

    describe '.find_by' do
      it '@clientで正しい通信をすること' do
        expect(SimpleModel.garage_client).to receive(:get).with('/news', params: { q: { id: 11 } })
        SimpleModel.find_by(id: 11)
      end
    end

    describe '.all' do
      it '@clientで正しい通信をすること' do
        expect(SimpleModel.garage_client).to receive(:get).with('/news') { Hash.new }
        SimpleModel.all
      end
    end

    describe '#update' do
      it '@clientで正しい通信をすること' do
        expect(SimpleModel.garage_client).to receive(:patch).with('/news/32', body: model.params)
        model.update
      end
    end

    describe '#create' do
      it '@clientで正しい通信をすること' do
        expect(SimpleModel.garage_client).to receive(:post).with('/news', body: model.params)
        model.create
      end
    end

    describe '#delete' do
      it '@clientで正しい通信をすること' do
        expect(SimpleModel.garage_client).to receive(:delete).with('/news/32')
        model.delete
      end
    end
  end
end
