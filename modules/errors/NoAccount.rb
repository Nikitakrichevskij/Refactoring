class NoAccount < StandardError
  def initialize
    super(I18n.t(:no_account))
  end
end
