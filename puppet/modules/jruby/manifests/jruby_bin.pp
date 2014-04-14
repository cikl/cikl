
define jruby_bin($jruby_home) {
  file {"/usr/local/bin/${title}":
    content => "#!/bin/sh\n\nJRUBY_HOME=${jruby_home} ${jruby_home}/bin/${title} \"$@\"",
    mode    => '755'
  }
}
