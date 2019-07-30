# frozen_string_literal: true

# export CIAO_WEBHOOK_ENDPOINT__1=https://chat.yourhost.net/*****
# export CIAO_WEBHOOK_PAYLOAD_1='{"username":"Brot & Games","icon_url":"https://avatars0.githubusercontent.com/u/43862266?s=400&v=4","text":"Example message","attachments":[{"title":"Rocket.Chat","title_link":"https://rocket.chat","text":"Rocket.Chat, the best open source chat","image_url":"/images/integration-attachment-example.png","color":"#764FA5"}]}'

NOTIFICATIONS = Ciao::Parsers::WebhookParser.webhooks.map do |webhook|
  Ciao::Notifications::WebhookNotification.new(
    webhook[:endpoint],
    webhook[:payload],
    Ciao::Renderers::MustacheRenderer
  )
end
