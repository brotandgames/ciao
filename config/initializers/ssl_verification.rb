# frozen_string_literal: true

disable_ssl_verification = ActiveModel::Type::Boolean.new.cast(ENV.fetch('CIAO_DISABLE_SSL_VERIFICATION', false))
Net::HTTP.verify_mode = OpenSSL::SSL::VERIFY_NONE if disable_ssl_verification
