# Add a system table $name to /etc/incron.d
#
# @param name
#   The name of the table in /etc/incron.d/
# @param path
#   Filesystem path to monitor
# @param mask
#   Symbolic array or numeric mask for events
# @param command
#   Command to run on detection of event in $path
# @param custom_content
#   Custom content to add to /etc/incron.d/$name
define incron::system_table (
  Optional[Stdlib::AbsolutePath] $path    = undef,
  Array[String] $mask                     = ['IN_MODIFY','IN_MOVE','IN_CREATE','IN_DELETE'],
  Optional[Stdlib::AbsolutePath] $command = undef,
  Optional[String] $custom_content        = undef
) {
  include '::incron'

  if !$path and !$command and !$custom_content {
    fail ('You must specify either $path and $command or $custom_content.')
  }

  if !is_integer($mask) {
    validate_re_array($mask,[
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
      'IN_OPEN'
    ])
  }

  $_mask    = join($mask,',')
  if $custom_content {
    $_content = $custom_content
  }
  else {
    $_content = "${path} ${_mask} ${command}\n"
  }

  file { "/etc/incron.d/${name}":
    content => $_content,
    owner   => 'root',
    group   => 'root',
    mode    => '0600',
    require => Package['incron'],
    notify  => Service['incrond']
  }
}
