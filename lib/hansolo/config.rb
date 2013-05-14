module Hansolo
  class << self
    attr_accessor :keydir,
      :urls,
      :app,
      :gateway,
      :runlist,
      :local_cookbooks_dir,
      :local_data_bags_dir,
      :before_rsync_cookbooks,
      :before_rsync_data_bags,
      :before_solo,
      :before_data_bags_read,
      :after_data_bags_write,
      :post_ssh_cmd
  end

  self.local_cookbooks_dir = File.join('', 'tmp', 'cookbooks')
  self.local_data_bags_dir = File.join('', 'tmp', 'data_bags')
  self.post_ssh_cmd = 'uptime'

  def self.configure
    yield self
  end

end
