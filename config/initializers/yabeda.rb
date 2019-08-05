# frozen_string_literal: true

prometheus_enabled = ENV.fetch('PROMETHEUS_ENABLED', 'false')
if prometheus_enabled == 'true'
  Yabeda.configure do
    group :ciao do
      gauge :checks, comment: 'Number of checks'
      gauge :checks_active, comment: 'Number of active checks'
      gauge :checks_healthy, comment: 'Number of healthy checks'
      gauge :checks_active_status_1xx, comment: 'Number of active checks with status 1xx'
      gauge :checks_active_status_2xx, comment: 'Number of active checks with status 2xx'
      gauge :checks_active_status_3xx, comment: 'Number of active checks with status 3xx'
      gauge :checks_active_status_4xx, comment: 'Number of active checks with status 4xx'
      gauge :checks_active_status_5xx, comment: 'Number of active checks with status 5xx'
      gauge :checks_active_status_err, comment: 'Number of active checks with status err'
    end
    # This block will be executed periodically few times in a minute
    # (by timer or external request depending on adapter you're using)
    # Keep it fast and simple!
    collect do
      ciao.checks.set({}, Check.count)
      ciao.checks_active.set({}, Check.active.count)
      ciao.checks_healthy.set({}, Check.healthy.count)
      ciao.checks_active_status_1xx.set({}, Check.status_1xx.count)
      ciao.checks_active_status_2xx.set({}, Check.status_2xx.count)
      ciao.checks_active_status_3xx.set({}, Check.status_3xx.count)
      ciao.checks_active_status_4xx.set({}, Check.status_4xx.count)
      ciao.checks_active_status_5xx.set({}, Check.status_5xx.count)
      ciao.checks_active_status_err.set({}, Check.status_err.count)
    end
  end
end
