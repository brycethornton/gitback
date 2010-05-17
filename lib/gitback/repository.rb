module Gitback
  class Repository
    attr_accessor :remote
    attr_accessor :branch

    def initialize(repository_path, &block)
      @repository_path = clean_path(repository_path)

      if File.exists?(@repository_path)
        prepare_git_repository

        if @repo
          yield self
          commit_git_changes
        end
      else
        puts "ERROR: it doesn't look like '#{@repository_path}' exists."
      end
    end

    # Creates a namespace for files to be stored under
    # Allows a single repository to be used for many different backups
    def namespace(name, &block)
      @namespace = clean_path(name)
      yield self
    end

    # Sets up the paths and copies the files into the git repo
    def backup(file_path)
      file_path = clean_path(file_path)

      begin
        dest_path = file_path
        dest_path = '/' + @namespace + file_path if @namespace
        dest_path = @repository_path + dest_path

        dirname = File.dirname(dest_path)

        # Make sure the path exists in the repo
        if !File.exists?(dirname)
          FileUtils.mkpath(dirname)
        end

        # Copy the file(s) to the repo
        if File.exists?(file_path)
          # We pass remove_destination to avoid issues with symlinks
          FileUtils.cp_r file_path, dest_path, :remove_destination => true
        else
          puts "ERROR: '#{file_path}' doesn't seem to exist."
        end
      rescue Errno::EACCES
        puts "ERROR: '#{file_path}' doesn't seem to be readable and/or writable by this user."
      end
    end

    private
    # Creates the Grit::Repo object for use throughout the class
    def prepare_git_repository
      # Allow one minute for slow repositories
      Grit::Git.git_timeout = 60.0

      Dir.chdir(@repository_path) do
        begin
          @repo = Grit::Repo.new('.')

          # Figure out the remote branch
          @remote = @repo.git.list_remotes.first
          @branch = @repo.head.name

          # Do a git-pull to make sure we have the newest changes from the repo
          if @remote
            puts "Pulling any changes from the remote git repository..."
            @repo.git.pull({}, @remote, @branch)
          end
        rescue Grit::InvalidGitRepositoryError
          puts "ERROR: #{@repository_path} doesn't seem to be a git repository."
        end
      end
    end

    # Use the repo object to commit and push the changes
    def commit_git_changes
      Dir.chdir(@repository_path) do
        status = @repo.status

        # Only add if we have untracked files
        if status.untracked.size > 0
          puts "Adding new files to the repository..."
          @repo.add(@repository_path + '/*')
        end

        commit_result = @repo.commit_all("Updating files")

        # Attempt to push if anything was committed and we have a remote repo
        if commit_result !~ /working directory clean/
          if @remote
            puts "Pushing repository changes..."
            @repo.git.push({}, @remote, @branch)
          end
        else
          puts "No changes committed."
        end
      end
    end

    # This just normalizes file/directory paths
    def clean_path(file_path)
      if File.directory?(file_path)
        file_path = File.expand_path(file_path)
      end

      file_path
    end
  end
end
