class AwsService
  AWS_ID = Rails.application.credentials.dig(:aws, :access_key_id)
  AWS_KEY = Rails.application.credentials.dig(:aws, :secret_access_key)
  BUCKET  = 'new-funeraria'.freeze

  def self.s3
    Aws::S3::Resource.new(
      credentials: Aws::Credentials.new(AWS_ID, AWS_KEY),
      region: 'sa-east-1'
    )
  end

  def self.upload(file, name)
    obj = s3.bucket(BUCKET).object("#{Time.now.to_i}-#{name}")
    obj.upload_file(file)
    obj.public_url
  end

  def self.delete(path_file)
    bucket = s3.bucket(BUCKET)
    bucket.objects.each do |file|
      file.delete if file.key == File.basename(path_file)
    end
  end
end
