Rails.application.config.content_security_policy do |policy|
    policy.default_src :self
    policy.connect_src :self, 'https://localhost:3000'
  end
  