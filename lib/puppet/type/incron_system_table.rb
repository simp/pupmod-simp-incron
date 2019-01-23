Puppet::Type.newtype(:incron_system_table) do
  @doc = <<-EOM
  Creates an 'incrond' compatible system table

  Line order will be preserved

  Any paths that contain globs '*' will be expanded into the appropriate number
  of rules based on glob expansion on the target system

  Globbed paths that do not result in a valid path expansion will be ignored

  Globs starting with /** will also be ignored due to the burden placed on the system

  WARNING: TAKE CARE THAT YOU KNOW WHAT YOUR GLOBS WILL EXPAND TO!
  EOM

  ensurable do
    defaultvalues
    defaultto :present
  end

  newparam(:name) do
    isnamevar
    desc 'The filename to use for the table - Non-word characters will be replaced'

    munge do |value|

      # This is here for the use of later parameters and properties
      @valid_incron_masks = [
        'IN_ACCESS',
        'IN_ALL_EVENTS',
        'IN_ATTRIB',
        'IN_CLOSE',
        'IN_CLOSE_NOWRITE',
        'IN_CLOSE_WRITE',
        'IN_CREATE',
        'IN_DELETE',
        'IN_DELETE_SELF',
        'IN_DONT_FOLLOW',
        'IN_MODIFY',
        'IN_MOVE',
        'IN_MOVED_FROM',
        'IN_MOVED_TO',
        'IN_MOVE_SELF',
        'IN_NO_LOOP',
        'IN_ONESHOT',
        'IN_ONLYDIR',
        'IN_OPEN',
        'loopable=true',
        'recursive=false',
        'dotdirs=true'
      ]
      self.class.send(:attr_reader, 'valid_incron_masks')

      value.split(/\W+/).join('__')
    end
  end

  newparam(:path, :array_matching => :all, :parent => Puppet::Parameter::Path) do
    desc 'Path(s) to watch and apply the `command`'

    accept_arrays(true)

    munge do |value|
      Array(value)
    end
  end

  newparam(:mask, :array_matching => :all) do
    desc 'The incron "masks" to apply'

    munge do |value|
      value = Array(value).join(',').split(',')

      strip_new_features = true

      # Version 0.5.12 of incron added new features (denoted by items with an
      # '=' in them) that are not supported by older releases. In the interest
      # of cross-version functionality, we strip them out here.
      incrond_version = Facter.value(:incrond_version)
      if incrond_version && Puppet::Util::Package.versioncmp(incrond_version, '0.5.12') >= 0
        strip_new_features = false
      end

      if strip_new_features
        stripped_entries = value.select{|x| x.include?('=')}
        value = value - stripped_entries

        unless stripped_entries.empty?
          debug "Auto-stripped the following entries due to the installed version of 'incrond': #{stripped_entries.join(', ')}"
        end
      end

      value.sort.uniq.join(',')
    end

    validate do |value|
      value = value.split(',') if value.is_a?(String)

      invalid_masks = (value - resource.parameters[:name].valid_incron_masks)

      unless invalid_masks.empty?
        raise(Puppet::Error, %(Invalid masks '#{invalid_masks.join("', '")}'. Masks must be one of '#{resource.parameters[:name].valid_incron_masks.join("', '")}'.))
      end
    end
  end

  newparam(:command, :array_matching => :all, :parent => Puppet::Parameter::Path) do
    desc <<-EOM
    The command(s) to apply when the paths change

    If multiple paths and commands are specified, they will create multiple
    lines that contain all possible combinations
    EOM

    accept_arrays(true)

    munge do |value|
      Array(value)
    end
  end

  newparam(:content, :array_matching => :all) do
    desc 'Raw content to add to the file - Will be validated'

    errors = []

    validate do |values|
      Array(values).each do |value|
        path, mask, command = value.split(/\s+/)

        unless (path && path.start_with?('/'))
          errors << "Path '#{path}' is not an absolute path"
        end

        unless (mask && (mask.split(',') -  resource.parameters[:name].valid_incron_masks).empty?)
          errors << %(Masks must be some combination of '#{resource.parameters[:name].valid_incron_masks.join("', '")}')
        end

        unless (command && command.start_with?('/'))
          errors << "Command '#{command}' is not an absolute path"
        end
      end
    end

    munge do |value|
      Array(value).map(&:lines).flatten.map(&:strip)
    end
  end

  validate do
    unless self[:ensure] == :absent
      unless self[:content] || (self[:path] && self[:mask] && self[:command])
        raise(Puppet::Error,'You must specify either "content" or "path", "mask", and "command"')
      end

      if self[:content] && (self[:path] || self[:mask] || self[:command])
        raise(Puppet::Error,'You cannot specify "content" with "path", "mask", or "command"')
      end
    end
  end

  autorequire(:package) do
    ['incron']
  end

  autorequire(:file) do
    to_req = []

    # Require all commands that we're going to run
    if self[:command]
      self[:command].each do |cmd|
        unless cmd.include?('*')
          to_req << cmd
        end
      end
    end

    # Grab the commands out of 'content' lines and required those as well
    if self[:content]
      self[:content].join.each_line do |content|

        cmd = content.split(/\s+/)[2]

        unless cmd.include?('*')
          to_req << cmd
        end
      end
    end

    to_req
  end
end
