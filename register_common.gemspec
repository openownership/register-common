# frozen_string_literal: true

require_relative 'lib/register_common/version'

Gem::Specification.new do |spec|
  spec.name = 'register_common'
  spec.version = RegisterCommon::VERSION
  spec.authors = ['Josh Williams']
  spec.email = ['josh@spacesnottabs.com']

  spec.summary = 'Shared functionality required by other Register repositories.'
  spec.description = spec.summary
  spec.homepage = 'https://github.com/openownership/register-common'
  spec.required_ruby_version = '>= 2.7'

  spec.metadata['allowed_push_host'] = 'https://rubygems.org'
  spec.metadata['source_code_uri'] = 'https://github.com/openownership/register-common'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'activesupport', '>= 6', '< 8'
  spec.add_dependency 'aws-sdk-athena'
  spec.add_dependency 'aws-sdk-firehose'
  spec.add_dependency 'aws-sdk-kinesis'
  spec.add_dependency 'aws-sdk-s3'
  spec.add_dependency 'dotenv'
  spec.add_dependency 'faraday', '>= 1', '< 2'
  spec.add_dependency 'faraday_middleware', '>= 1', '< 2'
  spec.add_dependency 'net-http-persistent'
  spec.add_dependency 'nokogiri'
  spec.add_dependency 'redis', '>= 3'
  spec.add_dependency 'rubyzip', '>= 2', '< 3'
  spec.add_dependency 'xxhash'
  spec.metadata['rubygems_mfa_required'] = 'true'
end
