class JsonWebToken
  SECRET_KEY = Rails.application.credentials[:secret_key_base]
  ALGORITHM = 'HS512'.freeze

  private_constant :SECRET_KEY

  def self.encode(payload)
    payload[:exp] = Time.zone.now.to_i + 7.days
    JWT.encode(payload, SECRET_KEY, ALGORITHM)
  end

  def self.decode(token)
    decoded = JWT.decode(token, SECRET_KEY, true, { algorithm: ALGORITHM }).first
    ActiveSupport::HashWithIndifferentAccess.new(decoded)
  end
end
