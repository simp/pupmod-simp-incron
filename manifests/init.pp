# This class manages /etc/incron.allow and /etc/incron.deny and the
# incrond service.
#
# @param users
#   An array of additional incron users, using the defiend type incron::user.
#
class incron (
  Array[String] $users = []
) {


  $users.each |String $user| {
    ::incron::user { $user: }
  }
  ::incron::user { 'root': }

  simpcat_build { 'incron':
    order            => ['*.user'],
    clean_whitespace => 'leading',
    target           => '/etc/incron.allow'
  }

  file { '/etc/incron.deny':
    ensure => 'absent'
  }

  package { 'incron':
    ensure => latest
  }

  service { 'incrond':
    ensure     => 'running',
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
    require    => Package['incron']
  }
}
