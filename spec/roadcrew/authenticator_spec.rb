require 'spec_helper'

describe Roadcrew::Authenticator do
  let(:authenticator) do
    Roadcrew::Authenticator
  end

  let(:fake_admin_class) do
    double 'fake Roadcrew::Models::Admin'
  end

  let(:fake_admin) do
    double 'fake Roadcrew::Models::Admin instance'
  end

  let(:credentials) do
    { email: 'sample@example.com', password: 'samplepass' }
  end

  let(:login_block) do
    -> (auth) {}
  end

  describe '.authenticate!' do
    before do
      allow(fake_admin_class).to receive(:new).and_return(fake_admin)
      allow(Roadcrew::Authenticator).to \
        receive(:admin_class).and_return(fake_admin_class)
    end

    context 'when call with no arg' do
      before do
        expect(fake_admin).to_not receive(:logged_in?)
      end

      subject do
        -> { Roadcrew::Authenticator.authenticate! }
      end

      it 'raise error' do
        expect(subject).to raise_error(Roadcrew::NotAuthenticatedError)
      end
    end

    context 'when call with auth' do
      subject do
        -> { Roadcrew::Authenticator.authenticate!('token' => 'sample token') }
      end

      context 'when valid auth' do
        before do
          allow(fake_admin).to receive(:logged_in?).and_return(true)
        end

        it 'not raise error' do
          expect(subject).to_not raise_error
        end
      end

      context 'when invalid auth' do
        before do
          allow(fake_admin).to receive(:logged_in?).and_return(false)
        end

        it 'raise error' do
          expect(subject).to raise_error(Roadcrew::NotAuthenticatedError)
        end
      end
    end
  end

  describe '.login!' do
    before do
      allow(fake_admin_class).to receive(:new).and_return(fake_admin)
      allow(fake_admin).to receive(:login).with(credentials).and_return(token)
      allow(Roadcrew::Authenticator).to \
        receive(:admin_class).and_return(fake_admin_class)
      expect(login_block).to receive(:call).with(auth)
    end

    context 'when fail login' do
      let(:token) do
        false
      end

      let(:auth) do
        false
      end

      subject do
        -> { Roadcrew::Authenticator.login!(credentials, &login_block) }
      end

      it 'raise error' do
        expect(subject).to raise_error(Roadcrew::NotAuthenticatedError)
      end
    end

    context 'when success login' do
      let(:token) do
        'sample_token_string'
      end

      let(:auth) do
        { 'token' => token }
      end

      subject do
        Roadcrew::Authenticator.login!(credentials, &login_block)
      end

      it 'return auth' do
        expect(subject).to eq(auth)
      end
    end
  end

  describe '.logout' do
    before do
      expect(fake_admin_class).to receive_message_chain(:new, :logout)
      allow(Roadcrew::Authenticator).to \
        receive(:admin_class).and_return(fake_admin_class)
    end

    it 'call Roadcrew::Models::Admin#logout' do
      Roadcrew::Authenticator.logout({})
    end
  end

  describe '.raise_error' do
    subject do
      -> { Roadcrew::Authenticator.raise_error }
    end

    it do
      expect(subject).to raise_error(Roadcrew::NotAuthenticatedError)
    end
  end

  describe '.admin_class' do
    before do
      expect(Roadcrew::Models::Admin).to receive(:garage).with(:admin).once
      expect(Roadcrew::Models::Admin).to receive(:base_path).with('/api').once
    end

    it 'return prepared Models::Admin' do
      expect(Roadcrew::Authenticator.admin_class).to eq(Roadcrew::Models::Admin)
      expect(Roadcrew::Authenticator.admin_class).to eq(Roadcrew::Models::Admin)
    end
  end
end
