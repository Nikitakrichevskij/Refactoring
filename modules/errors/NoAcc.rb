class NoAcc < StandardError
  ERROR_MESSAGE = I18n.t(:no_acc)
  def initialize
    super(ERROR_MESSAGE)
  end
end
