# frozen_string_literal: true

json.extract! check, :id, :active, :name, :cron, :url, :status, :job,
              :last_contact_at, :next_contact_at, :created_at, :updated_at,
              :tls_expires_at, :tls_expires_in_days
json.check_url check_url(check, format: :json)
