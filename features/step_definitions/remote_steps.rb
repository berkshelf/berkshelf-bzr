Given(/^I write a Berksfile with:$/) do |string|
  File.open(File.join(tmp_path, 'Berksfile'), 'w') do |f|
    f.write string
  end
end


Then(/^the cookbook store should have the bzr cookbooks:$/) do |cookbooks|
  cookbooks.raw.each do |name, version, sha1|
    Berkshelf.cookbook_store.storage_path.join("#{name}-#{sha1}").exist?
  end
end

Given(/^the cookbook store has the bzr cookbooks:$/) do |cookbooks|
  cookbooks.raw.each do |name, version, sha|
    folder   = "#{name}-#{sha}"
    metadata = File.join(folder, 'metadata.rb')

    create_dir(folder)
    write_file(metadata, [
      "name '#{name}'",
      "version '#{version}'"
    ].join("\n"))
  end
end

Then /^the exit status should be "(.+)"$/ do |name|
  error = name.split('::').reduce(Berkshelf) { |klass, id| klass.const_get(id) }
  assert_exit_status(error.status_code)
end

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

Given(/^a remote bazaar cookbook named "(.*?)" with a ref named "(.*?)"$/) do |name, ref|
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


