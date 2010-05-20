require "#{File.dirname(__FILE__)}/helper"

class TestGitback < Test::Unit::TestCase
  context 'Gitback' do
    setup do
      @dirname = File.expand_path(File.dirname(__FILE__))
      @remote_path = File.expand_path(File.join(@dirname, *%w[repos remote_repo]))
      @local_path  = File.expand_path(File.join(@dirname, *%w[repos local_repo]))

      # Cleanup the "remote" repo from previous tests
      if File.exists?(@remote_path)
        FileUtils.remove_dir(@remote_path)
      end

      # Cleanup the "local" repo from previous tests
      if File.exists?(@local_path)
        FileUtils.remove_dir(@local_path)
      end

      # Create the "remote" repo directory
      FileUtils.mkdir_p(@remote_path)

      Dir.chdir(@remote_path) do
        # Init the "remote" git repo and make first commit
        `git init`
        `touch README`

        @remote_repo = Grit::Repo.new(@remote_path)
        @remote_repo.add(@remote_path + '/*')
        @remote_repo.commit_all("first commit")
      end

      # Clone the "remote" repo to a "local" repo
      `git clone #{@remote_path} #{@local_path}`
    end

    should "handle basic file backups" do
      files = []
      files << "#{@dirname}/data/testing.txt"
      files << "#{@dirname}/data/some/deep/nginx.conf"

      output = Gitback::Repository.new @local_path do |repo|
        files.each do |file|
          repo.backup file
        end
      end

      assert_files(files)
    end

    should "handle directory backups" do
      output = Gitback::Repository.new @local_path do |repo|
        repo.backup "#{@dirname}/data/another/"
        repo.backup "#{@dirname}/data/some/deep/nginx.conf"
      end

      files = []
      files << "#{@dirname}/data/another/file.txt"
      files << "#{@dirname}/data/another/test.txt"
      files << "#{@dirname}/data/some/deep/nginx.conf"

      assert_files(files)
    end

    should "use namespaces" do
      output = Gitback::Repository.new @local_path do |repo|
        repo.namespace 'blah.domain.com' do
          repo.backup "#{@dirname}/data/another/"
          repo.backup "#{@dirname}/data/some/deep/nginx.conf"
        end
      end

      # Make sure local repo has the files
      files = []
      files << "blah.domain.com/#{@dirname}/data/another/file.txt"
      files << "blah.domain.com/#{@dirname}/data/another/test.txt"
      files << "blah.domain.com/#{@dirname}/data/some/deep/nginx.conf"

      assert_files(files)
    end
  end

  def assert_files(file_array)
    file_array.each do |file|
      assert File.exists? "#{@local_path}/#{file}"
    end

    # Need to reset in order for the files to not be deleted
    Dir.chdir(@remote_path) do
      `git reset --hard`
    end

    file_array.each do |file|
      assert File.exists? "#{@remote_path}/#{file}"
    end
  end
end
