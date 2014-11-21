require 'spec_helper'

def stubbing_request(verb, api_path, params = {})
  before do
    allow(admin).to receive_message_chain(:garage_client, verb)
      .with(fake_path, request_options.merge(params))
      .and_return(fake_response)

    allow(admin).to receive(:build_path)
      .with(api_path)
      .and_return(fake_path)
  end
end

describe Roadcrew::Models::Admin do
  let(:admin) do
    Roadcrew::Models::Admin.new(token)
  end

  let(:token) do
    'sample_token'
  end

  let(:fake_response) do
    FakeResponse.new
  end

  let(:request_options) do
    {
      cache_expires_in: -1,
      raise_errors: false
    }
  end

  let(:fake_path) do
    double '#build_path result'
  end

  describe '#logged_in?' do
    context 'when @token is nil' do
      stubbing_request(:get, '/user_sessions')

      let(:token) do
        nil
      end

      subject do
        admin.logged_in?
      end

      it 'return false' do
        expect(subject).to eq(false)
      end
    end

    context 'when @token is not nil' do
      stubbing_request(:get, '/user_sessions/sample_token')

      subject do
        admin.logged_in?
      end

      context 'when success request' do
        before do
          fake_response.status = 200
        end

        it 'return true' do
          expect(subject).to eq(true)
        end
      end

      context 'when fail request' do
        before do
          fake_response.status = 400
        end

        it 'return false' do
          expect(subject).to eq(false)
        end
      end
    end
  end

  describe '#login' do
    stubbing_request(:post, '/user_sessions', params: {})

    subject do
      admin.login({})
    end

    context 'when success request' do
      before do
        fake_response.status = 201
        fake_response.parsed = { 'authentication_token' => 'sample' }
      end

      it 'return authentication_token' do
        expect(subject).to eq('sample')
      end
    end

    context 'when fail request' do
      before do
        fake_response.status = 400
      end

      it 'return false' do
        expect(subject).to eq(false)
      end
    end
  end

  describe '#logout' do
    stubbing_request(:delete, '/user_sessions/sample_token')

    subject do
      admin.logout
    end

    context 'when success request' do
      before do
        fake_response.status = 204
      end

      it 'return true' do
        expect(subject).to eq(true)
      end
    end

    context 'when fail request' do
      before do
        fake_response.status = 400
      end

      it 'return false' do
        expect(subject).to eq(false)
      end
    end
  end
end
