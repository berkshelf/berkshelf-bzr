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
      def initialize(command, path = nil, stderr = nil)
        out = "Bzr error: command `bzr #{command}` failed. If this error "
        out << "persists, try removing the cache directory at `#{path}'."
        
        if stderr
          out << "Output from the command:\n\n"
          out << stderr
        end
        super(out)
      end
    end

    attr_reader :uri
    attr_reader :revision
    attr_reader :ref

    def initialize(dependency, options = {})
      super

      @uri      = options[:bzr]
      @revision    = options[:revision]
      @ref      = options[:ref] || 'last:'
    end

    # Determine if this revision is installed.
    #
    # @return [Boolean]
    def installed?
      revision && install_path.exist?
    end

    # Install this bzr cookbook into the cookbook store. This method leverages
    # a cached bzr copy and a scratch directory to prevent bad cookbooks from
    # making their way into the cookbook store.
    #
    # @see BaseLocation#install
    def install

      if cached?
        Dir.chdir(cache_path) do
          bzr %|pull|
        end
      else
        FileUtils.mkdir_p(cache_path.dirname)
        bzr %|branch #{uri} #{cache_path}|
      end

      Dir.chdir(cache_path) do
        bzr %|update -r #{@revision || @ref}|
      end
      @revision ||= revid(cache_path)
      
      # Validate the scratched path is a valid cookbook
      validate_cached!(cache_path)

      # If we got this far, we should copy
      FileUtils.rm_rf(install_path) if install_path.exist?
      FileUtils.cp_r(cache_path, install_path)
      install_path.chmod(0777 & ~File.umask)
    end

    # @see BaseLocation#cached_cookbook
    def cached_cookbook
      if installed?
        @cached_cookbook ||= CachedCookbook.from_path(install_path)
      else
        nil
      end
    end

    def ==(other)
      other.is_a?(BzrLocation) &&
      other.uri == uri &&
      other.ref == ref
    end

    def to_s
      "#{uri} (at ref: #{ref[0...7]})"
    end

    def to_lock
      out =  "    bzr: #{uri}\n"
      out << "    revision: #{revision}\n"
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
        raise BzrCommandError.new(command, cache_path, stderr = response.stderr)
      end

      response.stdout.strip
    end

    # Get revid from bazaar repository.
    # @param [String] path
    #   the path to the bazaar repository
    # @return [String | nil]
    #   the bazaar revid
    def revid(path)
      Dir.chdir(path) do
        stdout = bzr %|testament --strict|
        if stdout
          testament = stdout.match(/revision-id: (.*)/)
          unless testament[1]
            raise BazaarError.new('Unable to find bazaar revid')
          end
          'revid:' + testament[1]
        end
      end
    end


    # Determine if this bazaar repo has already been downloaded.
    #
    # @return [Boolean]
    def cached?
      cache_path.exist?
    end


    # The path where this cookbook would live in the store, if it were
    # installed.
    #
    # @return [Pathname, nil]
    def install_path
      Berkshelf.cookbook_store.storage_path
        .join("#{dependency.name}-#{revision.gsub('-', '_')}")
    end

    # The path where this bazaar repository is cached.
    #
    # @return [Pathname]
    def cache_path
      Pathname.new(Berkshelf.berkshelf_path)
        .join('.cache', 'bzr', Digest::SHA1.hexdigest(uri))
    end

  end
end
