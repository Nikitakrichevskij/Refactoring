class WrongName < StandardError
  def initialize
    super(I18n.t(:wrong_name))
  end
end
