# frozen_string_literal: true

json.array! @checks, partial: 'checks/check', as: :check
