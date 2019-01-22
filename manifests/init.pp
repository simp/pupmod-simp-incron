# This class manages /etc/incron.allow and /etc/incron.deny and the
# incrond service.
#
# @param users
#   An Array of additional incron users, using the defined type
#   incron::user.
#
# @param max_open_files
#   The maximum open files limit that should be set for incrond
#
#   * This should generally be left as ulimited since incrond could be watching
#     a great number of events. However, you may need to lower this if you find
#     that it is simply overwhelming your system (and analyze your incrond
#     rules).
#
# @param system_table
#   Create incron::system_table resources with hiera
#
# @param package_ensure
#   The ``ensure`` parameter of ``Package`` resources in the ``incron``
#   namespace.
#
class incron (
  Array[String[1]]                      $users          = [],
  Hash                                  $system_table   = {},
  Variant[Enum['unlimited'],Integer[0]] $max_open_files = 'unlimited',
  String[1]                             $package_ensure = simplib::lookup('simp_options::package_ensure', { 'default_value' => 'installed' }),
) {
  package { 'incron': ensure => $package_ensure }

  $system_table.each |String $name, Hash $values| {
    incron::system_table { $name: * => $values }
  }

  $users.each |String $user| {
    incron::user { $user: }
  }
  incron::user { 'root': }

  concat { '/etc/incron.allow':
    owner          => 'root',
    group          => 'root',
    mode           => '0400',
    ensure_newline => true,
    warn           => true
  }

  file { '/etc/incron.deny': ensure => 'absent' }

  file { '/etc/incron.d':
    ensure => 'directory',
    owner  => 'root',
    group  => 'root',
    mode   => '0755'
  }

  init_ulimit { 'mod_open_files_incrond':
    target => 'incrond',
    item   => 'max_open_files',
    value  => $max_open_files,
    notify => Service['incrond']
  }

  service { 'incrond':
    ensure     => 'running',
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
    require    => Package['incron']
  }
}
