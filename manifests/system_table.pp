# Add a system table $name to /etc/incron.d
#
# @option name
#   The name of the table in /etc/incron.d/
# @param path
#   Filesystem path to monitor
# @param mask
#   Symbolic array or numeric mask for events
# @param command
#   Command to run on detection of event in $path
# @param custom_content
#   Custom content to add to /etc/incron.d/$name.
#   Defining this disables validation on the content and take priority.
define incron::system_table (
  Optional[Stdlib::AbsolutePath] $path    = undef,
  Optional[Stdlib::AbsolutePath] $command = undef,
  Array[String] $mask                     = ['IN_MODIFY','IN_MOVE','IN_CREATE','IN_DELETE'],
  Optional[String] $custom_content        = undef
) {
  include '::incron'

  $mask.each |String $_tmp_mask| {
    if ! ($_tmp_mask in
    [
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
    ]) {
      fail("${_tmp_mask} is not a valid mask")
    }
  }

  $_mask = join($mask,',')
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
