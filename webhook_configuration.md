# Webhook Configuration

> New as of 1.4.0

You can configure as many webhooks as you like. Each webhook consists of 2 ENV variables:

* `CIAO_WEBHOOK_ENDPOINT_$NAME`
* `CIAO_WEBHOOK_PAYLOAD_$NAME`

`$NAME` can be any word `[A-Z0-9_]` and must be unique as it is used as an identifier.

like:

```
# Webhook for Rocket.Chat
CIAO_WEBHOOK_ENDPOINT_ROCKETCHAT="https://webhook.rocketchat.com/***/***"
CIAO_WEBHOOK_PAYLOAD_ROCKETCHAT='{"text":"[ciao] __name__: Status changed (__status_after__)"}'

# Webhook for Slack
CIAO_WEBHOOK_ENDPOINT_SLACK="https://webhook.slack.com/***/***"
CIAO_WEBHOOK_PAYLOAD_SLACK='{"text":"[ciao] __name__: Status changed (__status_after__)"}'

etc.
```

There are 5 placeholders which you can use in the payload:

* `__name__`
* `__url__`
* `__status_before__`
* `__status_after__`
* `__check_url__`

ENV variable `CIAO_WEBHOOK_PAYLOAD_$NAME` has to be a valid JSON one-liner wrapped in single quotes like `'{"name":"__name__", "status_before":"__status_before__", "status_after":"__status_after__", "check_url":"__check_url__", "url":"__url__"}'`

> New as of 1.9.0

You can configure webhooks for TLS certificate expiration with one additional ENV variable:

* `CIAO_WEBHOOK_PAYLOAD_TLS_EXPIRES_$NAME`

like:

```
# Webhook payload for TLS certificate expiration for Rocket.Chat
CIAO_WEBHOOK_PAYLOAD_TLS_EXPIRES_ROCKETCHAT='{"text": "[ciao] TLS certificate for __name__ expires at __tls_expires_at__ (in __tls_expires_in_days__ days)"}'


# Webhook payload for TLS certificate expiration for Slack
CIAO_WEBHOOK_PAYLOAD_TLS_EXPIRES_SLACK='{"text": "[ciao] TLS certificate for __name__ expires at __tls_expires_at__ (in __tls_expires_in_days__ days)"}'

etc.
```

There are 5 placeholders which you can use in the payload for TLS certificate expiration:

* `__name__`
* `__url__`
* `__tls_expires_at__`
* `__tls_expires_in_days__`
* `__check_url__`

## Notes

* If you are using `docker-compose`, you have to omit the outer `""` and `''` in `*_ENDPOINT_*` and `*_PAYLOAD_*` - take a look at these GitHub issues ([1](https://github.com/brotandgames/ciao/issues/40), [2](https://github.com/docker/compose/issues/2854)) and these Stack Overflow questions ([1](https://stackoverflow.com/questions/53082932/yaml-docker-compose-spaces-quotes), [2](https://stackoverflow.com/questions/41988809/docker-compose-how-to-escape-environment-variables))
* You can add an Example configuration for a Service that's missing in the list via PR

## Example configurations

### Rocket.Chat

````
# Endpoint
CIAO_WEBHOOK_ENDPOINT_ROCKETCHAT="https://chat.yourchat.net/hooks/****/****"

# Payload
CIAO_WEBHOOK_PAYLOAD_ROCKETCHAT='{"username":"Brot & Games","icon_url":"https://avatars0.githubusercontent.com/u/43862266?s=400&v=4","text":"[ciao] __name__: Status changed (__status_after__)"}'
````

### Slack

````
# Endpoint
- 'CIAO_WEBHOOK_ENDPOINT_SLACK=https://webhook.slack.com/***/***'
OR
- CIAO_WEBHOOK_ENDPOINT_SLACK=https://webhook.slack.com/***/***

# Payload
- 'CIAO_WEBHOOK_PAYLOAD_SLACK={"text":"[ciao] __name__: Status changed (__status_after__)"}'
````

### Office 365 Connector

```
# https://docs.microsoft.com/en-us/microsoftteams/platform/concepts/connectors/connectors-using

# Endpoint
CIAO_WEBHOOK_ENDPOINT_OFFICE_365="https://outlook.office.com/webhook/****/IncomingWebhook/****/****"

# Payload
CIAO_WEBHOOK_PAYLOAD_OFFICE_365='{ "@context": "https://schema.org/extensions", "@type": "MessageCard", "themeColor": "0072C6", "title": "MySystem (__name__) status change", "text": "Status changed from (__status_before__) to (__status_after__)", "potentialAction": [ { "@type": "OpenUri", "name": "Learn More", "targets": [ { "os": "default", "uri": "__check_url__" } ] } ] }'
```

### Telegram
```
# Endpoint
CIAO_WEBHOOK_ENDPOINT_TELEGRAM="https://api.telegram.org/bot****/sendMessage"

# Payload
CIAO_WEBHOOK_PAYLOAD_TELEGRAM='{ "chat_id": ****, "disable_web_page_preview":1, "text": "[__name__] Status changed from (__status_before__) to (__status_after__)"}'
```
