# frozen_string_literal: true

module RegisterCommon
  AwsCredentials = Struct.new(
    :AWS_REGION,
    :AWS_ACCESS_KEY_ID,
    :AWS_SECRET_ACCESS_KEY
  )
end
