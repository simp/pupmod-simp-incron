# Add a system table $name to /etc/incron.d
#
# If multiple ``path`` and/or ``command`` options are specified, they will be
# expanded into all matching possibilities.
#
# @example Multiplexed Path and Command
#   incron::system_table { 'test':
#     path    => ['/foo/bar', '/foo2/bar2'],
#     command => ['/bin/baz', '/bin/baz2']
#   }
#
#   Results in /etc/incron.d/test with contents:
#     /foo/bar IN_MODIFY,IN_MOVE,IN_CREATE,IN_DELETE /bin/baz
#     /foo/bar IN_MODIFY,IN_MOVE,IN_CREATE,IN_DELETE /bin/baz2
#     /foo2/bar2 IN_MODIFY,IN_MOVE,IN_CREATE,IN_DELETE /bin/baz
#     /foo2/bar2 IN_MODIFY,IN_MOVE,IN_CREATE,IN_DELETE /bin/baz2
#
# @example Path Globbing
#
#   For the following directory structure:
#      /foo/bar/one/one_more/baz/one.txt
#      /foo/bar/one/one_other/baz/ignore.me
#      /foo/bar/two/baz/two.txt
#
#   incron::system_table { 'glob':
#     path    => '/foo/bar/**/baz/*.txt',
#     command => '/bin/baz'
#   }
#
#   Results in /etc/incron.d/glob with contents:
#     /foo/bar/one/one_more/baz/one.txt IN_MODIFY,IN_MOVE,IN_CREATE,IN_DELETE /bin/baz
#     /foo/bar/two/baz/two.txt IN_MODIFY,IN_MOVE,IN_CREATE,IN_DELETE /bin/baz
#
# @option name
#   The name of the table in /etc/incron.d/
#
# @param enable
#   Whether to enable or disable the table
#
# @param path
#   Filesystem path(s) to monitor
#
#   * May contain Ruby ``Dir.glob`` compatible Strings
#
# @param mask
#   Symbolic array or numeric mask for events
#
# @param command
#   Command(s) to run on detection of event in $path
#
# @param custom_content
#   Custom content to add to /etc/incron.d/$name.
#   Defining this disables validation on the content and take priority.
#
define incron::system_table (
  Boolean                                  $enable         = true,
  Optional[Variant[Array[String], String]] $path           = undef,
  Optional[Variant[Array[String], String]] $command        = undef,
  Array[String]                            $mask           = ['IN_MODIFY','IN_MOVE','IN_CREATE','IN_DELETE'],
  Optional[String]                         $custom_content = undef
) {

  include 'incron'

  $_ensure = $enable ? { true => 'present', default => 'absent' }

  if $custom_content {
    incron_system_table { $name:
      ensure  => $_ensure,
      content => $custom_content,
      notify  => Class['incron::service']
    }
  }
  else {
    incron_system_table { $name:
      ensure  => $_ensure,
      path    => $path,
      mask    => $mask,
      command => $command,
      notify  => Class['incron::service']
    }
  }
}
