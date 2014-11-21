require 'spec_helper'

describe Roadcrew::ControllerHelpers do
  let!(:fake_controller) do
    class FakeController
      include Roadcrew::ControllerHelpers
    end
    FakeController.new
  end

  let(:auth_key) do
    Roadcrew::ControllerHelpers::SESSION_AUTH_KEY
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

  let(:token) do
    'sample token'
  end

  before do
    allow(fake_admin_class).to receive(:new).and_return(fake_admin)
    allow(fake_admin).to receive(:login).with(credentials).and_return(token)
    allow(Roadcrew::Authenticator).to receive(:admin_class).and_return(fake_admin_class)
  end


  describe '#roadcrew_auth' do
    before do
      fake_controller.session[auth_key] = 'sample auth'
    end

    subject do
      fake_controller.send(:roadcrew_auth)
    end

    it 'return session auth' do
      expect(subject).to eq('sample auth')
    end
  end

  describe '#roadcrew_admin?' do
    subject do
      fake_controller.send(:roadcrew_admin?)
    end

    context 'when session auth is nil' do
      before do
        fake_controller.session[auth_key] = nil
      end

      it 'return false' do
        expect(subject).to eq(false)
      end
    end

    context 'when session auth is not nil' do
      before do
        fake_controller.session[auth_key] = 'sample auth'
      end

      it 'return true' do
        expect(subject).to eq(true)
      end
    end
  end

  describe '#authenticate_admin_by_roadcrew!' do
    subject do
      -> { fake_controller.send(:authenticate_admin_by_roadcrew!) }
    end

    context 'when session auth is nil' do
      before do
        fake_controller.session[auth_key] = nil
      end

      it 'raise error' do
        expect(subject).to raise_error(Roadcrew::NotAuthenticatedError)
      end
    end

    context 'when session auth is not nil' do
      before do
        fake_controller.session[auth_key] = { 'token' => 'sample auth' }
        allow(fake_admin).to receive(:logged_in?).and_return(true)
      end

      it 'not raise error' do
        expect(subject).to_not raise_error
      end
    end
  end

  describe '#login' do
    context 'when valid credentials' do
      let(:auth) do
        { 'token' => token }
      end

      subject do
        fake_controller.send(:login, credentials)
      end

      it 'return auth' do
        expect(subject).to eq(auth)
      end
    end

    context 'when invalid credentials' do
      let(:token) do
        false
      end

      subject do
        -> { fake_controller.send(:login, credentials) }
      end

      it 'raise_error' do
        expect(subject).to raise_error(Roadcrew::NotAuthenticatedError)
      end
    end
  end

  describe '#logout' do
    before do
      fake_controller.session[auth_key] = 'sample auth'
      expect(Roadcrew::Authenticator).to receive(:logout).with('sample auth')
      expect(fake_controller).to receive(:not_authenticated)
    end

    it 'execute logout process' do
      fake_controller.send(:logout)
    end
  end

  describe '#not_authenticated' do
    before do
      fake_controller.session[auth_key] = 'sample auth'
      expect(fake_controller).to receive(:redirect_to).with('login_path')
      fake_controller.send(:not_authenticated)
    end

    subject do
      fake_controller.session
    end

    it 'delete session auth and redirect to login path' do
      expect(subject).to eq({})
    end
  end
end
