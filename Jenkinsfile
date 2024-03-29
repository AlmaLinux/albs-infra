pipeline {

  agent {
    node("imagebuilder-vmibuilder-box")
  }

  parameters {
      string(name: 'albs_web_server', defaultValue: 'master', description: 'albs-web-server branch/tag')
      string(name: 'albs_node', defaultValue: 'master', description: 'albs-node branch/tag')
      string(name: 'albs_frontend', defaultValue: 'master', description: 'albs-frontend branch/tag')
      string(name: 'albs_sign_node', defaultValue: 'master', description: 'albs-sign-node branch/tag')
      string(name: 'alts', defaultValue: 'master', description: 'alts branch/tag')
      string(name: 'nebula_endpoint', defaultValue: 'https://nebula-atm.cloudlinux.com:2633/RPC2', description: 'opennebula endpoint')
      string(name: 'nebula_username', defaultValue: 'alternatives', description: 'opennebula user')
      string(name: 'nebula_template_id', defaultValue: '42847', description: 'opennebula template id')
      string(name: 'nebula_image_id', defaultValue: '44562', description: 'opennebula image id')
      string(name: 'nebula_network_id', defaultValue: '6', description: 'opennebula network id (default is buildsys:mrybas)')
      booleanParam(defaultValue: true, description: 'Destroy nebula instance', name: 'DESTROY')
  }
  environment {
      TF_VAR_one_endpoint = "${params.nebula_endpoint}"
      TF_VAR_one_username = "${params.nebula_username}"
      TF_VAR_one_template_id = "${params.nebula_template_id}"
      TF_VAR_one_image_id = "${params.nebula_image_id}"
      TF_VAR_one_network_id  = "${params.nebula_network_id}"
      TF_VAR_one_password = credentials('alternatives_nebula_password')
      TF_VAR_albs_ssh_key = credentials('alternatives_public_ssh_key')
      ALBS_GITHUB_CLIENT = credentials('albs_github_client')
      ALBS_GITHUB_CLIENT_SECRET = credentials('albs_github_client_secret')
      ALBS_WEB_SERVER = "${params.albs_web_server}"
      ALBS_NODE = "${params.albs_node}"
      ALBS_FRONTEND = "${params.albs_frontend}"
      ALBS_SIGN_NODE = "${params.albs_sign_node}"
      ALTS = "${params.alts}"
  }

  stages {
      stage('Create instance') {
          steps {
              script {
                  sh "terraform -chdir=dev/terraform/nebula init"
                  sh "terraform -chdir=dev/terraform/nebula apply -auto-approve"
              }
          }
      }
      stage('Provision') {
          steps {
              script {
                  // TODO: terraform has ability to wait for vm to be ready,
                  // but we're waiting for vm to be ready here...
                  // https://stackoverflow.com/questions/62403030/terraform-wait-till-the-instance-is-reachable
                  sh "sleep 120"
                  sh ". ~/albc-ci-env/bin/activate && cd dev && ansible-playbook -i inventory/jenkins_inventory.py main.yml"
              }
          }
      }
      stage('Unit tests') {
          steps {
              script {
                  sh "echo Lets skip unittests for now..."
              }
          }
      }
      stage('Integration tests') {
          steps {
              script {
                  sh ". ~/albc-ci-env/bin/activate && cd dev && inventory/jenkins_inventory.py --albs-config > albs.json"
                  sh ". ~/albc-ci-env/bin/activate && cd dev && py.test --junitxml=../reports/integration.xml tests/"
              }
          }
      }
      stage('Destroy instance') {
          when {
              expression { params.DESTROY == true }
          }
          steps {
              script {
                  sh "terraform -chdir=dev/terraform/nebula destroy -auto-approve"
              }
          }
      }
  }

  post {
      always {
          junit 'reports/**/*.xml'
      }
      aborted {
          script {
              if (params.DESTROY == true) {
                sh "terraform -chdir=dev/terraform/nebula destroy -auto-approve"
              }
          }
      }
      failure {
          script {
              if (params.DESTROY == true) {
                sh "terraform -chdir=dev/terraform/nebula destroy -auto-approve"
              }
          }
      }
  }
}