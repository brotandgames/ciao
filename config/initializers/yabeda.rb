# frozen_string_literal: true

prometheus_enabled = ENV.fetch('PROMETHEUS_ENABLED', 'false')
if prometheus_enabled == 'true'
  Yabeda.configure do
    group :ciao do
      gauge :checks, comment: 'Number of checks'
      gauge :checks_active, comment: 'Number of active checks'
      gauge :checks_healthy, comment: 'Number of healthy checks'
    end
    # This block will be executed periodically few times in a minute
    # (by timer or external request depending on adapter you're using)
    # Keep it fast and simple!
    collect do
      ciao.checks.set({}, Check.count)
      ciao.checks_active.set({}, Check.active.count)
      ciao.checks_healthy.set({}, Check.healthy.count)
    end
  end
end
