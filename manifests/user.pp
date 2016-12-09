# Add the user ``$name`` to ``/etc/incron.allow``
#
# @option name
#   The user to add to ``/etc/incron.allow``
#
define incron::user {
  include '::incron'

  concat::fragment { "incron_user_${name}":
    target  => '/etc/incron.allow',
    content =>  "${name}\n"
  }
}
