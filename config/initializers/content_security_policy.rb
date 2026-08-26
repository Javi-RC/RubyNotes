Rails.application.configure do
  config.content_security_policy do |policy|
    policy.default_src :self, :https
    policy.font_src    :self, :https, :data
    policy.img_src     :self, :https, :data, :blob
    policy.object_src  :none
    policy.script_src  :self, :https, :unsafe_inline
    policy.style_src   :self, :https, :unsafe_inline
    policy.connect_src :self, :https
    policy.frame_src   :none
  end

  # A random nonce per response, memoised by Rails so the header and the tags
  # always agree. The previous generator used request.session.id, which is
  # empty before a session exists — every anonymous visitor (landing, sign-in,
  # sign-up) would then get an unmatched nonce, and because a nonce makes
  # browsers ignore 'unsafe-inline', inline scripts were blocked there. It also
  # published the session id into the CSP header and every nonce attribute.
  config.content_security_policy_nonce_generator = ->(_request) { SecureRandom.base64(16) }
  config.content_security_policy_nonce_directives = %w[script-src style-src]
end
