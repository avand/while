Rails.application.config.session_store :cookie_store, {
  key: '_while_session',
  expire_after: 1.month
}
