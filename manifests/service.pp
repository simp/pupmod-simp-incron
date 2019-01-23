# This class wraps the incrond service
#
# @private
#
class incron::service {
  assert_private()

  service { 'incrond':
    ensure     => 'running',
    enable     => true,
    hasstatus  => true,
    hasrestart => false
  }
}
