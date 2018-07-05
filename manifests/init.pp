# This class manages /etc/incron.allow and /etc/incron.deny and the
# incrond service.
#
# @param users
#   An Array of additional incron users, using the defined type
#   incron::user.
#
# @param system_table
#   Create incron::system_table resources with hiera
#
class incron (
  Array[String] $users          = [],
  Hash          $system_table   = {},
  String        $package_ensure = simplib::lookup('simp_options::package_ensure', { 'default_value' => 'installed' }),
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

  service { 'incrond':
    ensure     => 'running',
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
    require    => Package['incron']
  }
}
