require 'spec_helper'

describe Roadcrew::Connection do
  let(:access_token) { double 'AccessToken' }
  let(:response) { double 'Response' }
  let(:expires_at) { 2.hours.since.to_i }
  let(:refresh_token) { 'sample_refresh_token' }
  let(:connection) { Roadcrew::Connection.new(access_token: 'sample_token', endpoint: 'http://example.com/api/', expires_at: expires_at, refresh_token: 'sample_refresh_token') }
  let(:rails_module) { double('Rails module').as_null_object }

  class FakeRailsCache
    def fetch(*args, &block)
      block.call
    end
  end

  before do
    allow(OAuth2::AccessToken).to receive(:new)
      .with(be_kind_of(OAuth2::Client), 'sample_token', expires_at: expires_at, refresh_token: refresh_token) { access_token }

    allow_any_instance_of(Roadcrew::Connection).to receive(:defined_rails_cache?).and_return(true)
    allow(rails_module).to receive(:cache).and_return(FakeRailsCache.new)
    stub_const('Rails', rails_module)
  end

  describe '#get' do
    it 'OAuth2::AccessTokenに正しい引数を渡すこと' do
      expect(access_token).to receive(:expired?) { false }
      expect(access_token).to receive(:get).with('/users') { response }
      expect(connection.get('/users')).to eq response
    end

    context 'cache_expires_inオプションを渡した場合' do
      subject do
        -> { connection.get('/users', cache_expires_in: -1) }
      end

      it '例外が発生しないこと' do
        expect(access_token).to receive(:expired?) { false }
        expect(access_token).to receive(:get).with('/users', cache_expires_in: -1) { response }
        expect(subject).to_not raise_error
      end
    end

    context 'access_tokenが期限切れの場合' do
      it '#refresh!を実行すること' do
        expect(access_token).to receive(:expired?) { true }
        expect(access_token).to receive(:refresh!)
        expect(access_token).to receive(:get).with('/users') { response }
        expect(connection.get('/users')).to eq(response)
      end
    end
  end

  describe '#post' do
    it 'OAuth2::AccessTokenに正しい引数を渡すこと' do
      expect(access_token).to receive(:expired?) { false }
      expect(access_token).to receive(:post).with('/users/1') { response }
      expect(connection.post('/users/1')).to eq response
    end
  end

  describe '#delete' do
    it 'OAuth2::AccessTokenに正しい引数を渡すこと' do
      expect(access_token).to receive(:expired?) { false }
      expect(access_token).to receive(:delete).with('/users/1') { response }
      expect(connection.delete('/users/1')).to eq response
    end
  end

  describe '#patch' do
    it 'OAuth2::AccessTokenに正しい引数を渡すこと' do
      expect(access_token).to receive(:expired?) { false }
      expect(access_token).to receive(:patch).with('/users/1') { response }
      expect(connection.patch('/users/1')).to eq response
    end
  end

  describe '#put' do
    it 'OAuth2::AccessTokenに正しい引数を渡すこと' do
      expect(access_token).to receive(:expired?) { false }
      expect(access_token).to receive(:put).with('/users/1') { response }
      expect(connection.put('/users/1')).to eq response
    end
  end

  describe '#mask_password' do
    subject do
      connection.send(:mask_password, [:hoge, params: { password: 'hogehoge' }])
    end

    it 'mask password value' do
      expect(subject).to eq([:hoge, params: { password: '[FILTERD]' }])
    end
  end

  describe '#log' do
    before do
      allow(connection).to receive(:defined_rails_logger?).and_return(true)
    end

    subject do
      -> { connection.send(:log, []) }
    end

    it 'not raise error' do
      expect(subject).to_not raise_error
    end
  end
end
