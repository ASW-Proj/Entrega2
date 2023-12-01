Rails.application.config.content_security_policy do |policy|
    policy.default_src :self
    policy.connect_src :self, 'https://entrega2api.fly.dev'
  end
  