require 'aws-sdk-s3'
require 'tmpdir'

module RegisterCommon
  module Adapters
    class S3Adapter
      module Errors
        NoSuchKey = Class.new(StandardError)
      end

      def initialize(credentials:)
        @s3_client = Aws::S3::Client.new(
          region: credentials.AWS_REGION,
          access_key_id: credentials.AWS_ACCESS_KEY_ID,
          secret_access_key: credentials.AWS_SECRET_ACCESS_KEY
        )
      end

      def download_from_s3(s3_bucket:, s3_path:, local_path:)
        s3 = Aws::S3::Object.new(s3_bucket, s3_path, client: s3_client)
        s3.download_file(local_path)
      rescue Aws::S3::Errors::NoSuchKey, Aws::S3::Errors::NotFound
        raise Errors::NoSuchKey
      end

      def download_and_read(s3_bucket:, s3_path:)
        Dir.mktmpdir do |dir|
          local_path = File.join(dir, 'tmpfile')
          download_from_s3(s3_bucket: s3_bucket, s3_path: s3_path, local_path: local_path)
          File.read(local_path)
        end
      end

      def exists?(s3_bucket:, s3_path:)
        Dir.mktmpdir do |dir| # TODO: avoid downloading
          local_path = File.join(dir, 'tmpfile')
          download_from_s3(s3_bucket: s3_bucket, s3_path: s3_path, local_path: local_path)
          true
        rescue Errors::NoSuchKey
          false
        end
      end

      def upload_to_s3(s3_bucket:, s3_path:, local_path:)
        s3 = Aws::S3::Object.new(s3_bucket, s3_path, client: s3_client)
        s3.upload_file(local_path)
      end
      
      def upload_from_file_obj_to_s3(s3_bucket:, s3_path:, stream:)
        s3_client.put_object(bucket: s3_bucket, key: s3_path, body: stream)
      rescue Aws::S3::Errors::NoSuchKey, Aws::S3::Errors::NotFound
        raise Errors::NoSuchKey
      end     
      
      def list_objects(s3_bucket:, s3_prefix:)
        s3_client.list_objects({
          bucket: s3_bucket,
          prefix: s3_prefix
        }).contents.map(&:key)
      end

      private

      attr_reader :s3_client
    end
  end
end
