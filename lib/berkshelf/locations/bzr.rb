require 'buff/shell_out'
require 'digest/sha1'
require 'pathname'
require 'berkshelf'

module Berkshelf
  class BzrLocation < BaseLocation
    class BzrError < BerkshelfError; status_code(600); end

    class BzrNotInstalled < BzrError
      def initialize
        super 'You need to install Bazaar before you can download ' \
          'cookbooks from bzr repositories. For more information, please ' \
          'see the Bazaar docs: http://bazaar.canonical.com.'
      end
    end

    class BzrCommandError < BzrError
      def initialize(command, path = nil)
        super "Bzr error: command `bzr #{command}` failed. If this error " \
          "persists, try removing the cache directory at `#{path}'."
      end
    end

    attr_reader :uri
    attr_reader :revid
    attr_reader :ref

    def initialize(dependency, options = {})
      super

      @uri      = options[:hg]
      @revid    = options[:revid]
      @ref      = options[:revid] || options[:ref] || 'last:'
    end

    # Download the cookbook from the remote hg repository
    #
    # @return [CachedCookbook]
    def download
      if installed?
        cookbook = CachedCookbook.from_store_path(install_path)
        return super(cookbook)
      end

      if cached?
        # Update and checkout the correct ref
        Dir.chdir(cache_path) do
          bzr %|pull -r #{ref}|
        end
      else
        # Ensure the cache directory is present before doing anything
        FileUtils.mkdir_p(cache_path.dirname)

        Dir.chdir(cache_path) do
          bzr %|branch -r #{ref} #{uri} #{cache_path}|
        end
      end

      Dir.chdir(cache_path) do
        stdout = bzr %|testament --strict|
        testament = stdout.match(/revision-id: (.*)/)
        unless testament[1]
          raise BazaarError.new('Unable to find bazaar revid')
        end
        @revid ||= testament[1]
      end

      # Validate the thing we are copying is a Chef cookbook
      validate_cookbook!(cache_path)

      # Remove the current cookbook at this location (this is required or else
      # FileUtils will copy into a subdirectory in the next step)
      FileUtils.rm_rf(install_path)

      # Create the containing parent directory
      FileUtils.mkdir_p(install_path.parent)

      # Copy whatever is in the current cache over to the store
      FileUtils.cp_r(cache_path, install_path)

      # Remove the .bzr directory to save storage space
      if (bzr_path = install_path.join('.bzr')).exist?
        FileUtils.rm_r(bzr_path)
      end

      cookbook = CachedCookbook.from_store_path(install_path)
      super(cookbook)
    end

    def scm_location?
      true
    end

    def ==(other)
      other.is_a?(BzrLocation) &&
      other.uri == uri &&
      other.ref == ref &&
      other.revid == revid
    end

    def to_s
      "#{uri} (at revid: #{revid})"
    end

    def to_lock
      out =  "    bzr: #{uri}\n"
      out << "    revid: #{revid}\n"
      out
    end

    private

    # Perform a bazaar command.
    #
    # @param [String] command
    #   the command to run
    # @param [Boolean] error
    #   whether to raise error if the command fails
    #
    # @raise [String]
    #   the +$stdout+ from the command
    def bzr(command, error = true)
      unless Berkshelf.which('bzr') || Berkshelf.which('bzr.exe')
        raise BzrNotInstalled.new
      end

      response = Buff::ShellOut.shell_out(%|bzr #{command}|)

      if error && !response.success?
        raise BzrCommandError.new(command, cache_path)
      end

      response.stdout.strip
    end

    # Determine if this bazaar repo has already been downloaded.
    #
    # @return [Boolean]
    def cached?
      cache_path.exist?
    end

    # Determine if this revision is installed.
    #
    # @return [Boolean]
    def installed?
      revid && install_path.exist?
    end

    # The path where this cookbook would live in the store, if it were
    # installed.
    #
    # @return [Pathname, nil]
    def install_path
      Berkshelf.cookbook_store.storage_path
        .join("#{dependency.name}-#{revid.gsub('-', '_')}")
    end

    # The path where this hg repository is cached.
    #
    # @return [Pathname]
    def cache_path
      Pathname.new(Berkshelf.berkshelf_path)
        .join('.cache', 'bzr', Digest::SHA1.hexdigest(uri))
    end
  end
end
