Given /^a remote bazaar cookbook named "(\w+)"$/ do |name|
  path = File.join(tmp_path, 'bzr-cookbooks', name)
  FileUtils.mkdir_p(path)

  Dir.chdir(path) do
    bzr('init')

    File.open('metadata.rb', 'w') do |f|
      f.write <<-EOH
        name '#{name}'
        version '1.0.0'
      EOH
    end

    bzr('add')
    bzr_commit('Initial commit')
  end
end

Given /^a remote bazaar cookbook named "(\w+)" with a ref named "(\w+)"$/ do |name, ref|
  path = File.join(tmp_path, 'bzr-cookbooks', name)
  steps %Q|Given a remote bazaar cookbook named "#{name}"|

  Dir.chdir(path) do
    File.open('metadata.rb', 'w') do |f|
      f.write <<-EOH
        name '#{name}'
        version '2.3.4'
      EOH
    end

    bzr('add')
    bzr_commit('More changes')
  end
end

def bzr(command)
  %x|bzr #{command}|
end

def bzr_commit(message)
  bzr %|commit -m "#{message}"|
end
