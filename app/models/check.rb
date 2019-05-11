class Check < ApplicationRecord
  validates :url, http_url: true
  validates :name, presence: true
  validates :url, presence: true
  validates :cron, presence: true
  validates :cron, cron: true
end
