class WrongPassword < StandardError
  def initialize
    super(I18n.t(:wrong_password))
  end
end
