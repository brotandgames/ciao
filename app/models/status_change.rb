# frozen_string_literal: true

class StatusChange < ApplicationRecord
  belongs_to :check
end
