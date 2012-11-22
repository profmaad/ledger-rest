module LedgerRest
  class Git
    class << self
      attr_reader :repository, :remote, :branch, :read_pull_block_time

      def configure options
        @repository = options[:git_repository] or File.dirname(options[:ledger_file] || 'main.ledger')
        @pull_before_read = options[:git_pull_before_read] || false
        @pull_before_write = options[:git_pull_before_write] || false
        @push_after_write = options[:git_push_after_write] || false
        @remote = options[:git_remote] || 'origin'
        @branch = options[:git_branch] || 'master'
        @read_pull_block_time = options[:git_read_pull_block_time] || 10*60

        @last_read_pull = Time.new
        if pull_before_read? or pull_before_write? or push_after_write?
          @git_repo = ::Git.open(repository)
          FileUtils.touch(options[:ledger_append_file])
          @git_repo.add(options[:ledger_append_file])
        end
      end

      def invoke hook
        case hook
        when :before_read
          pull if pull_before_read? and not blocked?
        when :before_write
          pull if pull_before_write?
        when :after_write
          push if push_after_write?
        end
      end

      def blocked_read_pull?
        (Time.new - @last_read_pull) > read_pull_block_time
      end

      def pull_before_read?
        @pull_before_read
      end

      def pull_before_write?
        @pull_before_write
      end

      def push_after_write?
        @push_after_write
      end

      # Execute the pull command.
      def pull
        @git_repo.pull(remote, branch)
        @last_read_pull = Time.new
      rescue Exception => e
        $stderr.puts "Git pull failed: #{e}"
      end

      # Execute the push command after commiting all.
      def push
        @git_repo.commit_all("transaction added via ledger-rest")
        @git_repo.push(remote, branch)
      rescue Exception => e
        $stderr.put "Git push failed: #{e}"
      end

    end
  end
end
