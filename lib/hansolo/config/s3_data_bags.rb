module Hansolo
  class << self
    attr_accessor :bucket_name, :aws_access_key_id, :aws_secret_access_key

    def s3_connection
      AWS::S3.new(:access_key_id => Hansolo.aws_access_key_id, :secret_access_key => Hansolo.aws_secret_access_key)
    end

    def s3_bucket_name
      if bucket_name.respond_to?(:call)
        name = instance_eval &bucket_name
        Util.check_exit_status
      else
        name = bucket_name
      end
    end

    def bucket
      s3_connection.buckets[s3_bucket_name].tap { |b| s3_connection.buckets.create(s3_bucket_name) unless b.exists? }
    end

    def download_data_bags(local_data_bags_dir)
      bucket.objects.each do |item|
        filename = File.join(local_data_bags_dir, item.key)
        FileUtils.mkdir_p(File.dirname(filename))
        File.open(filename, 'w') do |f|
          f.write item.read
        end unless filename =~/\/$/
      end
    end

    # TODO: Use Pathname
    def upload_data_bags(local_data_bags_dir)
      Dir["#{local_data_bags_dir}/*/**"].each do |filename|
        json = File.read(filename)
        object_key = filename.gsub(/^#{local_data_bags_dir}\//, '')
        bucket.objects[object_key].write json
      end
    end
  end

  self.after_data_bags_write  = Proc.new do
    upload_data_bags(local_data_bags_dir)
    FileUtils.rm_rf local_data_bags_dir
  end

  self.before_data_bags_read  = Proc.new do
    FileUtils.rm_rf local_data_bags_dir
    download_data_bags(local_data_bags_dir)
  end

  self.before_rsync_data_bags = Proc.new do
    FileUtils.rm_rf local_data_bags_dir
    download_data_bags(local_data_bags_dir)
  end

end
