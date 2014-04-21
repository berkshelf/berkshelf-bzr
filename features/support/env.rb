require 'aruba/cucumber'
require 'aruba/in_process'
require 'berkshelf'

Before do
  Aruba::InProcess.main_class = Berkshelf::Cli::Runner
  Aruba.process = Aruba::InProcess

  @aruba_timeout_seconds = 30

  ENV['BERKSHELF_PATH'] = tmp_path

  ENV['BERKSHELF_CONFIG'] = Berkshelf.config.path.to_s
#  clean_tmp_path
  Berkshelf.initialize_filesystem
  Berkshelf::CookbookStore.instance.initialize_filesystem
#  reload_configs
  Berkshelf::CachedCookbook.instance_variable_set(:@loaded_cookbooks, nil)
end

def tmp_path
  File.expand_path('tmp/aruba')
end
