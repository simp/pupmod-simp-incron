# Add the user $name to /etc/incron.allow
#
# @option name
#   The user to add to /etc/incron.allow
#
define incron::user
{
  include '::incron'

  simpcat_fragment { "incron+${name}.user":
    content =>  "${name}\n"
  }
}
