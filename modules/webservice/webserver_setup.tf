######################################################
#               _____ _   _ _____  _    _ _______    #
#              |_   _| \ | |  __ \| |  | |__   __|   #
#     __ _  ___  | | |  \| | |__) | |  | |  | |      #
#    / _` |/ _ \ | | | . ` |  ___/| |  | |  | |      #
#   | (_| | (_) || |_| |\  | |    | |__| |  | |      #
#    \__, |\___/_____|_| \_|_|     \____/   |_|      #
#     __/ |                                          #
#    |___/                                           #
#                                                    #
######################################################

///////////////////////////////////////////////////////////
// Webserver config
///////////////////////////////////////////////////////////
resource "null_resource" "webserver_config" {

  depends_on = [
    hcloud_server.webserver
  ]

  count = length(hcloud_server.webserver)

  triggers = {
    saltmaster_public_ip = var.saltmaster_public_ip
    server_name          = hcloud_server.webserver[count.index].name
    private_key          = var.terraform_private_ssh_key
  }


  # copy etc/hosts file to web server
  /*provisioner "file" {
    source      = "salt/srv/salt/common/hosts"
    destination = "/etc/hosts"
  }*/

  # make the magic happen on web server
  provisioner "remote-exec" {
    inline = [

      "echo nameserver 8.8.8.8 > /etc/resolv.conf",

      "echo -e  'y\n'| ssh-keygen -b 4096 -t rsa -P '' -f /root/.ssh/id_rsa -q",

      "wget -O /tmp/bootstrap-salt.sh https://bootstrap.saltstack.com",
      "sh /tmp/bootstrap-salt.sh -L -X -A ${var.saltmaster_ip}",
      "echo '${self.triggers.server_name}' > /etc/salt/minion_id",
      "systemctl restart salt-minion",
      "systemctl enable salt-minion",
    ]

    connection {
      private_key = self.triggers.private_key
      host        = hcloud_server.webserver[count.index].ipv4_address
      user        = "root"
    }
  }
  # Accept minion key on master
  provisioner "remote-exec" {
    inline = [
      "salt-key -y -a '${self.triggers.server_name}'",
      "salt '${self.triggers.server_name}' state.apply"
    ]

    connection {
      private_key = self.triggers.private_key
      host        = var.saltmaster_public_ip
      user        = "root"
    }
  }

  # Add or update web server host name to local hosts file
  /*provisioner "local-exec" {
  }*/

  # delete minion key on master when destroying
  provisioner "remote-exec" {
    when = destroy

    inline = [
      "salt-key -y -d '${self.triggers.server_name}'",
    ]

    connection {
      private_key = self.triggers.private_key
      host        = self.triggers.saltmaster_public_ip
      user        = "root"
    }
  }

  # delete host from local hosts file when destroying
  /*provisioner "local-exec" {
    when    = "destroy"
    command = "sed -i '' '/${element(hcloud_server.webserver.*.name, count.index)}/d' salt/srv/salt/common/hosts"
  }*/
}