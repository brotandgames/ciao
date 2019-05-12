class Check < ApplicationRecord

  validates :url, http_url: true
  validates :name, presence: true
  validates :url, presence: true
  validates :cron, presence: true
  validates :cron, cron: true

  scope :active, -> { where(active: true) }
  scope :inactive, -> { where.not(active: false) }
  scope :healthy, -> { where(status: "200") }
  scope :failed, -> { where.not(status: "200") }

  def self.percentage_active
    if ! self.active.empty?
      ((active.count * 1.0 / count * 1.0) * 100.0).round(0)
    else
      0.0
    end
  end

  def self.percentage_healthy
    if ! self.active.empty?
      ((healthy.count * 1.0 / active.count * 1.0) * 100.0).round(0)
    else
      0.0
    end
  end

end
