# frozen_string_literal: true

NET_HTTP_ERRORS = [
  EOFError,
  Errno::ECONNRESET,
  Errno::EINVAL,
  Errno::ECONNREFUSED,
  Net::HTTPBadResponse,
  Net::HTTPHeaderSyntaxError,
  Net::ProtocolError,
  Timeout::Error,
  SocketError,
  OpenSSL::SSL::SSLError
].freeze
