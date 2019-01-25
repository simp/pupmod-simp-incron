# Returns the version of ``incrond`` that is installed

Facter.add('incrond_version') do
  incrond_cmd = Facter::Util::Resolution.which('incrond')
  confine { File.executable?(incrond_cmd) }

  setcode do
    require 'open3'
    # The version command outputs to stderr
    Open3.capture3(incrond_cmd, '--version')[1].split(/\s+/).last
  end
end
