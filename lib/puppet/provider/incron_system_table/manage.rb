Puppet::Type.type(:incron_system_table).provide(:manage) do
  desc 'Create the content for an Incron system table'

  def exists?
    @incron_dir = nil
    @target_file = nil
    @new_content = nil

    # Find out where to read the files from and fall back to the default if
    # nothing is found
    begin
      @incron_dir = File.read('/etc/incron.conf').lines.grep(/^\s*system_table_dir\s*=/).first.split('=').last.strip
    rescue
      @incron_dir = '/etc/incron.d'
    end

    unless File.directory?(@incron_dir)
      raise(Puppet::Error, "incron_system_table: Could not find configuration directory at '#{@incron_dir}'")
    end

    @target_file = File.join(@incron_dir, @resource[:name])

    @new_content = collate_resource

    return false unless File.readable?(@target_file)

    return (@new_content == File.read(@target_file).strip)
  end

  def create
    begin
      File.open(@target_file, 'w'){|fh| fh.puts(@new_content)}
    rescue => e
      raise(Puppet::Error, "incron_system_table: Could not write to '#{@target_file}': #{e}")
    end
  end

  def destroy
    # This resource is all or nothing so it doesn't make sense to cherry pick
    # items out of the results

    File.unlink(@target_file) if File.exist?(@target_file)
  end

  private

  # Expand the path into a resulting Array
  #
  # An empty Array will be returned if:
  #   * The path has overly aggressive globbing
  #   * The path is not found
  #   * Any errors occur
  #
  def expand_path(path)
    return [] if path.start_with?('/**')

    begin
      if path.include?('*')
        return Dir.glob(path)
      else
        return [path]
      end
    rescue
      Puppet.debug("incron_system_table: Error occurred processing '#{path}': #{e}")
      return []
    end
  end

  # Do the work necessary to build the content for the target file including
  # directory glob expansion, etc...
  def collate_resource
    content = []

    if @resource[:path]
      # Handle the singular case first
      @resource[:path].each do |orig_path|
        expand_path(orig_path).each do |path|
          @resource[:command].each do |command|
            content << [path, @resource[:mask], command].join(' ')
          end
        end
      end
    elsif @resource[:content]
      # Now the more complex fully specified content
      @resource[:content].each do |line|
        orig_path, *remainder = line.strip.split(' ')

        expand_path(orig_path).each do |path|
          content << "#{path} #{remainder.join(' ')}"
        end
      end
    end

    return content.join("\n")
  end
end
