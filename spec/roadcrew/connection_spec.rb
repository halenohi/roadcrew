require 'spec_helper'

describe Roadcrew::Connection do
  let(:access_token) { double 'AccessToken' }
  let(:response) { double 'Response' }
  let(:connection) { Roadcrew::Connection.new(access_token: 'sample_token', endpoint: 'http://example.com/api/') }

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
end
