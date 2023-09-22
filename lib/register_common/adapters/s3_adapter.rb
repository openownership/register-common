# frozen_string_literal: true

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
          download_from_s3(s3_bucket:, s3_path:, local_path:)
          File.read(local_path)
        end
      end

      def exists?(s3_bucket:, s3_path:)
        Dir.mktmpdir do |dir| # TODO: avoid downloading
          local_path = File.join(dir, 'tmpfile')
          download_from_s3(s3_bucket:, s3_path:, local_path:)
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
        s3_client.list_objects(
          {
            bucket: s3_bucket,
            prefix: s3_prefix
          }
        ).contents.map(&:key)
      end

      def create_multipart_upload(s3_bucket:, s3_path:)
        s3_client.create_multipart_upload(
          {
            bucket: s3_bucket,
            key: s3_path
          }
        ).upload_id
      end

      def add_multipart_part(s3_bucket:, source_path:, dest_path:, part_number:, upload_id:)
        s3_client.upload_part_copy(
          {
            bucket: s3_bucket,
            copy_source: "/#{s3_bucket}/#{source_path}",
            key: dest_path,
            part_number:,
            upload_id:
          }
        )
      end

      def complete_multipart_upload(s3_bucket:, s3_path:, upload_id:, parts:)
        s3_client.complete_multipart_upload(
          {
            bucket: s3_bucket,
            key: s3_path,
            upload_id:,
            multipart_upload: {
              parts:
            }
          }
        )
      end

      def download_from_s3_to_memory(s3_bucket:, s3_path:)
        s3_client.get_object(bucket: s3_bucket, key: s3_path).body
      rescue Aws::S3::Errors::NoSuchKey, Aws::S3::Errors::NotFound
        raise Errors::NoSuchKey
      end

      private

      attr_reader :s3_client
    end
  end
end
