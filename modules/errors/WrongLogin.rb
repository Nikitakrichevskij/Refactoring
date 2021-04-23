# frozen_string_literal: true

class WrongLogin < StandardError
  def initialize
    super(I18n.t(:wrong_login))
  end
end
