stage('Install dependencies') {
  node {
    checkout scm
    sh 'bundle -v || gem install bundler'
    sh 'bundle install --path vendor/bundle'
  }
}

stage('Acceptance Testing') {
  parallel(
    CentOS7: {
      node {
        checkout scm
        env.PUPPET_INSTALL_VERSION = "1.5.2"

        env.PUPPET_INSTALL_TYPE = "agent"

        env.BEAKER_set = "centos-7-x64-vagrant_libvirt"

        print "Beaker Settings will be: ${env.PUPPET_INSTALL_VERSION}       ${env.PUPPET_INSTALL_TYPE} ${env.BEAKER_set}"

        wrap([$class: 'AnsiColorBuildWrapper', 'colorMapName': 'gnome-terminal']) {
          sh 'bundle exec rake acceptance'
        }
      }
    },
  )
}

def bundle_exec(command) {
  sh "bundle exec ${command}"
}
