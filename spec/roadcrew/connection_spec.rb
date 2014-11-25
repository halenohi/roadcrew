require 'spec_helper'

describe Roadcrew::Connection do
  let(:access_token) { double 'AccessToken' }
  let(:response) { double 'Response' }
  let(:connection) { Roadcrew::Connection.new(access_token: 'sample_token', endpoint: 'http://example.com/api/') }
  let(:rails_module) { double('Rails module').as_null_object }

  before do
    allow(OAuth2::AccessToken).to receive(:new)
      .with(be_kind_of(OAuth2::Client), 'sample_token') { access_token }
  end

  describe '#get' do
    it 'OAuth2::AccessTokenに正しい引数を渡すこと' do
      expect(access_token).to receive(:get).with('/users') { response }
      expect(connection.get('/users')).to eq response
    end
  end

  describe '#post' do
    it 'OAuth2::AccessTokenに正しい引数を渡すこと' do
      expect(access_token).to receive(:post).with('/users/1') { response }
      expect(connection.post('/users/1')).to eq response
    end
  end

  describe '#delete' do
    it 'OAuth2::AccessTokenに正しい引数を渡すこと' do
      expect(access_token).to receive(:delete).with('/users/1') { response }
      expect(connection.delete('/users/1')).to eq response
    end
  end

  describe '#patch' do
    it 'OAuth2::AccessTokenに正しい引数を渡すこと' do
      expect(access_token).to receive(:patch).with('/users/1') { response }
      expect(connection.patch('/users/1')).to eq response
    end
  end

  describe '#put' do
    it 'OAuth2::AccessTokenに正しい引数を渡すこと' do
      expect(access_token).to receive(:put).with('/users/1') { response }
      expect(connection.put('/users/1')).to eq response
    end
  end

  describe '#mask_password' do
    subject do
      connection.send(:mask_password, [:hoge, password: 'hogehoge'])
    end

    it 'mask password value' do
      expect(subject).to eq([:hoge, password: '[FILTERD]'])
    end
  end

  describe '#log' do
    before do
      stub_const('Rails', rails_module)
    end

    subject do
      -> { connection.send(:log, []) }
    end

    it 'not raise error' do
      expect(subject).to_not raise_error
    end
  end
end
