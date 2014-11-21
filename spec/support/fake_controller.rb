class FakeController
  attr_accessor :session

  class << self
    def rescue_from(error_class, &block)
    end

    def helper_method(*args)
    end
  end

  def initialize
    @session = {}
  end

  def redirect_to(path)
  end

  def login_path
    'login_path'
  end

  def roadcrew
    FakePathHelper.new
  end
end
